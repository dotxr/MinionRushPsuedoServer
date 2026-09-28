import hashlib, json, os, re, shutil, sys, urllib.request, zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
LOCAL = f"{HERE}/data/legacy"
ARCHIVE = "https://raw.githubusercontent.com/dotxr/Minion-Rush-Cache-Archive/main/native-1677"
CACHE = f"{HERE}/cache"

out, spec = sys.argv[1:3]
ver, plat = spec.split(":")
shutil.rmtree(out, ignore_errors=True)
os.makedirs(out)
os.makedirs(CACHE, exist_ok=True)

def fetch(path, name):
    dest = f"{CACHE}/{name}"
    if not os.path.exists(dest):
        urllib.request.urlretrieve(f"{ARCHIVE}/{path}/{name}", dest + ".part")
        os.rename(dest + ".part", dest)
    return dest

def link(name, src):
    try:
        os.link(src, f"{out}/{name}")
    except OSError:
        shutil.copyfile(src, f"{out}/{name}")

versions = json.load(open(fetch("", "versions.json")))
entry = versions[plat][ver]
toc_name = entry["toc"]
toc = json.load(open(fetch("tocs", toc_name)))
hf = toc.get("hash_file")
if hf:
    link(hf, fetch("hash_files", hf))
link(toc_name, fetch("tocs", toc_name))
for n in entry["assets"].values():
    link(n, fetch("assets", n))
for f in os.listdir(LOCAL):
    if f.startswith(("mnhtn_", ".")):
        continue
    link(f, f"{LOCAL}/{f}")
for n in filter(lambda n: zipfile.is_zipfile(f"{out}/{n}"), entry["assets"].values()):
    z = zipfile.ZipFile(f"{out}/{n}")
    items = [(i, z.read(i)) for i in z.infolist()]
    z.close()
    hit = False
    for k, (i, d) in enumerate(items):
        if i.filename.startswith("storyevent_up44maya"):
            items[k] = (i, re.sub(rb"(Currency_Seasonal1_Black_Market\x01\x13\x00\d{4}-\d\d-\d\d 00:00:00\x01\x13\x00)"
                                  rb"\d{4}-\d\d-\d\d 00:00:00\x01\x13\x00\d{4}-\d\d-\d\d",
                                  lambda m: m[1] + b"2099-12-30 00:00:00\x01\x13\x002099-12-31", d))
            hit = True
    if hit:
        os.remove(f"{out}/{n}")
        with zipfile.ZipFile(f"{out}/{n}", "w") as z:
            for i, d in items:
                z.writestr(i, d)
open(f"{out}/toc_{ver}_{plat}.txt", "w").write(toc_name)
if hf:
    h = json.load(open(f"{out}/{hf}"))
    for n in entry["assets"].values():
        d, m = open(f"{out}/{n}", "rb").read(), h["file_metadata"].get(n)
        cs = (m or {}).get("chunk_size", 262144)
        hs = [hashlib.sha1(d[i:i + cs]).hexdigest() for i in range(0, len(d), cs)]
        if not m or m.get("size") != len(d) or m.get("hashes") != hs:
            h["file_metadata"][n] = {"size": len(d), "chunk_size": cs, "num_chunks": len(hs), "hashes": hs,
                                     "uncompressed_size": len(d), "compression": "none"}
            print("rehashed", n)
    os.remove(f"{out}/{hf}")
    open(f"{out}/{hf}", "w").write(json.dumps(h, separators=(",", ":")))
with open(f"{out}/manifest.txt", "w") as m:
    for n in sorted(os.listdir(out)):
        d = open(f"{out}/{n}", "rb").read()
        m.write(f"{n} {hashlib.sha256(d).hexdigest()} {hashlib.md5(d).hexdigest()} {len(d)}\n")
print(out, len(os.listdir(out)), "files", round(sum(os.path.getsize(f"{out}/{n}") for n in os.listdir(out)) / 1e6, 1), "MB")
