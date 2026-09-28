import hashlib, io, json, os, sys, zipfile

out, ver = sys.argv[1:3]
toc_name = open(f"{out}/" + next(f for f in sorted(os.listdir(out)) if f.startswith(f"toc_{ver}_"))).read().strip()
toc = json.load(open(f"{out}/{toc_name}"))
hash_name = toc["hash_file"]
hf = json.load(open(f"{out}/{hash_name}"))
table = toc["game_versions"][ver]

def iris(k):
    return table[k]["default"]["iris_asset"]

merged, dropped = {}, []
for k in sorted(table):
    base = k[:-2]
    if not (k.endswith("_2") and base in table):
        continue
    a, b = iris(base), iris(k)
    if not (os.path.exists(f"{out}/{a}") and os.path.exists(f"{out}/{b}")):
        continue
    files = {}
    for n in (a, b):
        with zipfile.ZipFile(f"{out}/{n}") as z:
            for i in z.infolist():
                files[i.filename] = z.read(i)
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_STORED) as z:
        for name, data in files.items():
            z.writestr(zipfile.ZipInfo(name, (1980, 1, 1, 0, 0, 0)), data)
    data = buf.getvalue()
    os.remove(f"{out}/{a}")
    open(f"{out}/{a}", "wb").write(data)
    cs = table[base]["default"]["chunk_size"]
    hf["file_metadata"][a] = {"size": len(data), "chunk_size": cs, "num_chunks": (len(data) + cs - 1) // cs,
                              "hashes": [hashlib.sha1(data[i:i + cs]).hexdigest() for i in range(0, len(data), cs)],
                              "uncompressed_size": len(data), "compression": "none"}
    merged[a] = data
    hf["file_metadata"].pop(b, None)
    dropped.append(b)
    del table[k]

if dropped:
    toc["bundle_version_revision"] = str(int(toc.get("bundle_version_revision") or 0) + 1)
for n, j in ((toc_name, toc), (hash_name, hf)):
    merged[n] = json.dumps(j, separators=(",", ":")).encode()
    os.remove(f"{out}/{n}")
    open(f"{out}/{n}", "wb").write(merged[n])

gone = set(dropped)
for f in os.listdir(out):
    if f.startswith("pad_") and f.endswith(".txt"):
        lines = []
        for l in open(f"{out}/{f}").read().splitlines():
            w = l.split(" ")
            if w[0].endswith("_2") and w[0][:-2] in table:
                continue
            lines.append(" ".join(x for x in w if x not in gone))
        open(f"{out}/{f}", "w").write("\n".join(lines) + "\n")

man = []
for l in open(f"{out}/manifest.txt").read().splitlines():
    n = l.split(" ")[0]
    if n in gone:
        continue
    if n in merged:
        d = merged[n]
        l = f"{n} {hashlib.sha256(d).hexdigest()} {hashlib.md5(d).hexdigest()} {len(d)}"
    man.append(l)
open(f"{out}/manifest.txt", "w").write("\n".join(man) + "\n")
for b in dropped:
    os.remove(f"{out}/{b}")
print(f"{out}: {len(dropped)} second packs folded into their first pack")
