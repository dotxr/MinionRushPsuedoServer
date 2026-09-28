import hashlib, os, re, struct, subprocess, sys, zipfile, zlib
import lief
from dailyrooms import one_day

src, bundle, out = sys.argv[1:4]
HERE = os.path.dirname(os.path.abspath(__file__))
BT = os.path.expanduser("~/Library/Android/sdk/build-tools/34.0.0")
EVE_NEW = b"http://127.0.0.1:18080/eeeeee"
EVE_OLDS = [b"http://185.182.9.183:80/eeeee", b"http://eve.gameloft.com:20001"]
PAD_OLD, PAD_NEW = b"https://185.182.9.183/pad/", b"http://127.0.0.1:1808/pad/"
JEVE_OLD, JEVE_NEW = b"http://185.182.9.183/eem/config/", b"http://127.0.0.1:18080/e/config/"
assert all(len(o) == len(EVE_NEW) for o in EVE_OLDS) and len(PAD_OLD) == len(PAD_NEW) and len(JEVE_OLD) == len(JEVE_NEW)

GAIA_OLD, GAIA_NEW = b"/urls\x00http://\x00https://\x00", b"/urls\x00http://\x00http://\x00\x00"
IRIS_OLD, IRIS_NEW = b"Iris URL\x00https://\x00", b"Iris URL\x00http://\x00\x00"
GAIA2_OLD, GAIA2_NEW = b"game_portal\x00http:\x00https:\x00", b"game_portal\x00http:\x00http:\x00\x00"

def patch_so(data):
    assert sum(data.count(o) for o in EVE_OLDS) == 1 and data.count(GAIA_OLD) <= 1 and data.count(GAIA2_OLD) <= 1
    for o in EVE_OLDS:
        data = data.replace(o, EVE_NEW)
    tmp = f"{out}.so.tmp"
    open(tmp, "wb").write(data.replace(GAIA_OLD, GAIA_NEW).replace(GAIA2_OLD, GAIA2_NEW).replace(IRIS_OLD, IRIS_NEW))
    if not java_loads:
        elf = lief.parse(tmp)
        if "libmroffline.so" not in [l for l in elf.libraries]:
            elf.add_library("libmroffline.so")
        elf.write(tmp)
    data = open(tmp, "rb").read()
    os.remove(tmp)
    return data

def patch_odr(data):
    import json
    o = json.loads(data)
    packs = {p["name"]: p for p in o["ODRAssetsPacks"]}
    rec, allp = packs.get("assets_pack_recommended_content"), packs.get("assets_pack_check_content")
    if not rec or not allp:
        return data
    deps = rec["ODRAssetsPacksDependencies"]
    deps += [d for d in allp["ODRAssetsPacksDependencies"] if d not in deps]
    return json.dumps(o, indent=1).encode()

def patch_dex(data):
    if PAD_OLD not in data and JEVE_OLD not in data:
        return data
    d = bytearray(data.replace(PAD_OLD, PAD_NEW).replace(JEVE_OLD, JEVE_NEW))
    d[12:32] = hashlib.sha1(d[32:]).digest()
    d[8:12] = struct.pack("<I", zlib.adler32(bytes(d[12:])) & 0xFFFFFFFF)
    return bytes(d)

ver = re.search(r"(\d+\.\d+\.\d+\w)\.apk$", src).group(1)
fixed = os.path.exists(f"{HERE}/dex_{ver}.dex")
fixed_name = open(f"{HERE}/dex_{ver}.name").read().strip() if fixed else None
fixed_dex = open(f"{HERE}/dex_{ver}.dex", "rb").read() if fixed else None
extra = f"{HERE}/revivalpacks_{ver}.dex"
with zipfile.ZipFile(src) as a:
    dexes = [n for n in a.namelist() if re.fullmatch(r"classes\d*\.dex", n)]
    java_loads = any(b"\tmroffline\x00" in a.read(n) for n in dexes)
    pack_dex = next((n for n in dexes if a.getinfo(n).file_size < 200000 and b"RevivalPacks" in a.read(n)), None)
tmp = out + ".unsigned"
with zipfile.ZipFile(src) as a, zipfile.ZipFile(tmp, "w") as b:
    abis = set()
    for i in a.infolist():
        if i.filename.startswith("META-INF/"):
            continue
        data = a.read(i)
        if i.filename.endswith("/libDespicableMe.so"):
            data = patch_so(data)
            abis.add(i.filename.split("/")[1])
            lib_mode = i.compress_type
        elif i.filename == "assets/levels/lairlib.blibclara":
            data = one_day(data)
        elif i.filename == "assets/online/manhattan/odr/odr_config.json":
            data = patch_odr(data)
        elif i.filename == pack_dex and os.path.exists(extra):
            data = open(extra, "rb").read()
        elif i.filename.endswith(".dex"):
            data = patch_dex(fixed_dex if i.filename == fixed_name else data)
        b.writestr(i, data, compress_type=i.compress_type)
    if os.path.exists(extra) and not pack_dex:
        n = len(dexes)
        b.write(extra, f"classes{n + 1}.dex", zipfile.ZIP_DEFLATED)
    for abi in sorted(abis):
        b.write(f"{HERE}/build/android/{abi}/libmroffline.so", f"lib/{abi}/libmroffline.so", lib_mode)
    for n in sorted(os.listdir(bundle)):
        b.write(f"{bundle}/{n}", f"assets/offline/{n}", zipfile.ZIP_STORED)
subprocess.run([f"{BT}/zipalign", "-f", "-p", "4", tmp, tmp + ".a"], check=True)
os.remove(tmp)
subprocess.run([f"{BT}/apksigner", "sign", "--ks", os.environ["KEYSTORE"], "--ks-key-alias", os.environ["KEY_ALIAS"],
                "--ks-pass", "env:KS_PASS", "--key-pass", "env:KS_PASS", "--out", out, tmp + ".a"], check=True,
               stderr=subprocess.DEVNULL)
os.remove(tmp + ".a")
print(out, sorted(abis), round(os.path.getsize(out) / 1e6, 1), "MB")
