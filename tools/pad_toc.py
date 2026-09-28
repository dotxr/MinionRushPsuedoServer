import json, os, re, urllib.request

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(HERE, "data")
ARCHIVE = "https://raw.githubusercontent.com/dotxr/Minion-Rush-Cache-Archive/main/native-3493"
INDEX = json.load(open(os.path.join(DATA, "legacy_index.json")))
VERSIONS_PATH = os.path.join(DATA, "legacy_versions.json")
VERSIONS = json.load(open(VERSIONS_PATH))

def fetch(name):
    with urllib.request.urlopen(f"{ARCHIVE}/{INDEX[name]['dir']}/{name}", timeout=120) as r:
        return json.loads(r.read())

def base(v):
    return re.sub(r"[a-z]+$", "", v)

ONLY = {"mnhtn_toc_android_603"}

def main():
    amazon = {}
    for toc in sorted({t for t in VERSIONS["amazon"].values()}, key=lambda n: int(n.rsplit("_", 1)[1])):
        t = fetch(toc)
        for v, e in t["game_versions"].items():
            if len(e) > 2:
                amazon[base(v)] = (e, t["hash_file"])
    for toc in sorted(ONLY):
        t = fetch(toc)
        patched, hashes = [], set()
        for v, e in t["game_versions"].items():
            if len(e) <= 2 and base(v) in amazon and VERSIONS["android"].get(v) == toc:
                src, hf = amazon[base(v)]
                t["game_versions"][v] = {**src, **{k: e[k] for k in e}}
                patched.append(v)
                hashes.add(hf)
        if not patched:
            continue
        meta = fetch(t["hash_file"])
        for hf in hashes:
            meta["file_metadata"].update(fetch(hf)["file_metadata"])
        t["hash_file"] += "x"
        json.dump(meta, open(os.path.join(DATA, "legacy", t["hash_file"]), "w"), separators=(",", ":"))
        json.dump(t, open(os.path.join(DATA, "legacy", toc + "x"), "w"), separators=(",", ":"))
        for v in patched:
            VERSIONS["android"][v] = toc + "x"
        print(toc, "->", toc + "x", len(patched), "versions:", " ".join(patched))
    json.dump(VERSIONS, open(VERSIONS_PATH, "w"), indent=1, sort_keys=True)

if __name__ == "__main__":
    main()
