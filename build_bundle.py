import hashlib, json, os, re, shutil, subprocess, sys, zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
BACK = HERE
LOCAL = f"{BACK}/data/legacy"
ARCHIVE = "https://raw.githubusercontent.com/dotxr/Minion-Rush-Cache-Archive/main/native-3493"
CACHE = f"{HERE}/cache"

STUBS = ["dlc_rooms_2_shared", "dlc_rooms_2_winter_res"]
SUBSTITUTE = {"dlc_mc_2_punk_amazon_dlc_mc_2_punk_4": "dlc_mc_2_punk_android_dlc_mc_2_punk_2",
              "dlc_mc_2_striker_amazon_dlc_mc_2_striker_3": "dlc_mc_2_striker_amazon_dlc_mc_2_striker_1",
              "dlc_mc_2_stuart_kungfu_amazon_dlc_mc_2_stuart_kungfu_4": "dlc_mc_2_stuart_kungfu_android_dlc_mc_2_stuart_kungfu_2",
              "dlc_mc_2_stuart_roller_2_ios_dlc_mc_2_stuart_roller_2_1": "dlc_mc_2_stuart_roller_2_ios_dlc_mc_2_stuart_roller_2_2"}

out = sys.argv[1]
shutil.rmtree(out, ignore_errors=True)
os.makedirs(out)
os.makedirs(CACHE, exist_ok=True)
idx = json.load(open(f"{BACK}/data/legacy_index.json"))

def fetch(name, dest):
    if not os.path.exists(dest):
        import urllib.request
        urllib.request.urlretrieve(f"{ARCHIVE}/{idx[name]['dir']}/{name}", dest)
    return dest

fetch("mnhtn_toc_ios_904", f"{HERE}/mnhtn_toc_ios_904")
daily = json.load(open(f"{BACK}/data/legacy_daily_rooms.json"))

def put(name, data):
    open(f"{out}/{name}", "wb").write(data)

def link(name, src):
    try:
        os.link(src, f"{out}/{name}")
    except OSError:
        shutil.copyfile(src, f"{out}/{name}")

served = []
substituted = {}
for f in os.listdir(LOCAL):
    if f != "hestia_config.json" and not f.startswith("."):
        link(f, f"{LOCAL}/{f}")
        served.append(f)

cfg = json.load(open(f"{LOCAL}/hestia_config.json"))
for slot in cfg["game"]["_Slots"].values():
    for entry in slot.values():
        entry["end_date"] = entry["outgoing_date"] = "2037-12-31 23:59:59"
FREE = [{"price": [{"currency": "bananas", "price": 1}], "replaced_price": None, "name": "offline", "type": "offline"}]
for p in cfg["iap"]["prices"]:
    p["billing_methods"] = FREE
text = json.dumps(cfg, separators=(",", ":"))
assert '"_Slots":{' in text
put("hestia_config.json", text.encode())

for spec in sys.argv[2:]:
    toc, vp = spec.split("@")
    ver, plat = vp.split(":")
    p = next((f for f in (f"{LOCAL}/{toc}", f"{HERE}/{toc}") if os.path.exists(f)), None) or fetch(toc, f"{HERE}/{toc}")
    if toc not in served:
        link(toc, p)
        served.append(toc)
    t = json.load(open(p))
    if plat == "android":
        ios = json.load(open(f"{HERE}/mnhtn_toc_ios_904"))["game_versions"].get(ver, {})
        entries = t["game_versions"][ver]
        for k in sorted(set(ios) - set(entries)):
            alt = [t["game_versions"][w][k] for w in t["game_versions"] if k in t["game_versions"][w]]
            names = sorted((n for n in idx if re.fullmatch(re.escape(k) + r"_(amazon|android)_" + re.escape(k) + r"_\d+", n)),
                           key=lambda n: int(n.rsplit("_", 1)[1]))
            if alt:
                entries[k] = alt[-1]
            elif names:
                entries[k] = {"metadata": {"active": 1, "mandatory": 0}, "default": {"iris_asset": names[-1], "chunk_size": 262144}}
            else:
                print("no android build of", k)
                continue
            n = entries[k]["default"]["iris_asset"]
            fetch(n, f"{CACHE}/{n}")
            substituted.setdefault(t.get("hash_file"), []).append(n)
    entries = t["game_versions"][ver]
    for k in STUBS:
        if k not in entries:
            n = f"{k}_{plat}_{k}_0"
            if not os.path.exists(f"{CACHE}/{n}"):
                with zipfile.ZipFile(f"{CACHE}/{n}", "w", zipfile.ZIP_STORED) as z:
                    z.writestr(zipfile.ZipInfo(f"{k}.txt", (1980, 1, 1, 0, 0, 0)), b"")
            entries[k] = {"metadata": {"active": 1, "mandatory": 0}, "default": {"iris_asset": n, "chunk_size": 262144}}
            substituted.setdefault(t.get("hash_file"), []).append(n)
    if toc in served:
        os.remove(f"{out}/{toc}")
    put(toc, json.dumps(t, separators=(",", ":")).encode())
    hf = t.get("hash_file")
    if hf and hf not in served and (os.path.exists(f"{LOCAL}/{hf}") or fetch(hf, f"{HERE}/{hf}")):
        link(hf, f"{HERE}/{hf}")
        served.append(hf)
    put(f"toc_{ver}_{plat}.txt", toc.encode())
    if plat == "android":
        put(f"toc_{ver}_amazon.txt", toc.encode())
    rooms = daily.get(f"{ver}:{plat}") or daily["9.6.1b:ios"]
    put(f"daily_{ver}_{plat}.txt", "\n".join(rooms).encode())
    entries = t["game_versions"][ver]
    if plat == "android":
        packs = {}
        for k in entries:
            base = re.sub(r"_\d+$", "", k)
            packs.setdefault(base, []).append(k)
            packs.setdefault(k, []).append(k)
        for group, pat in {"dlc_2_recommend": r"dlc_(mc|ra|boss|ch)_2_", "dlc_2_recommend_rooms": r"dlc_rooms_2_"}.items():
            packs[group] = sorted(k for k in entries if re.match(pat, k))
        lines = []
        for pack, keys in sorted(packs.items()):
            keys = sorted(set(keys), key=lambda k: (len(k), k)) if pack not in ("dlc_2_recommend", "dlc_2_recommend_rooms") else keys
            lines.append(" ".join([pack] + [entries[k]["default"]["iris_asset"] for k in keys]))
        put(f"pad_{ver}.txt", "\n".join(lines).encode())
    for v in entries.values():
        n = v["default"]["iris_asset"]
        if n in served:
            continue
        src = f"{CACHE}/{n}"
        if not os.path.exists(src) and n in idx:
            fetch(n, src)
        if not os.path.exists(src):
            alt = SUBSTITUTE.get(n)
            if not alt:
                print("missing", n)
                continue
            print("substitute", n, "<-", alt)
            src = fetch(alt, f"{CACHE}/{alt}")
            substituted.setdefault(hf, []).append(n)
        link(n, src)
        served.append(n)

for hf, names in substituted.items():
    h = json.load(open(f"{out}/{hf}"))
    for n in names:
        d, e = open(f"{out}/{n}", "rb").read(), h["file_metadata"].setdefault(n, {"chunk_size": 262144, "compression": "none"})
        cs = e["chunk_size"]
        e.update(size=len(d), uncompressed_size=len(d), num_chunks=(len(d) + cs - 1) // cs,
                 hashes=[hashlib.sha1(d[i:i + cs]).hexdigest() for i in range(0, len(d), cs)])
    os.remove(f"{out}/{hf}")
    put(hf, json.dumps(h, separators=(",", ":")).encode())

with open(f"{out}/manifest.txt", "w") as m:
    for n in sorted(served):
        sha, md5, size = hashlib.sha256(), hashlib.md5(), 0
        with open(f"{out}/{n}", "rb") as f:
            while chunk := f.read(1 << 20):
                sha.update(chunk), md5.update(chunk)
                size += len(chunk)
        m.write(f"{n} {sha.hexdigest()} {md5.hexdigest()} {size}\n")
for spec in sys.argv[2:]:
    subprocess.run([sys.executable, f"{HERE}/merge_parts.py", out, spec.split("@")[1].split(":")[0]], check=True)
print(out, len(served), "files", round(sum(os.path.getsize(f"{out}/{n}") for n in os.listdir(out)) / 1e6, 1), "MB")
