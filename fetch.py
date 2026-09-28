import json, os, sys, urllib.request, concurrent.futures as cf
BACK = os.path.dirname(os.path.abspath(__file__))
BASE = "https://raw.githubusercontent.com/dotxr/Minion-Rush-Cache-Archive/main/native-3493"
idx = json.load(open(f"{BACK}/data/legacy_index.json"))
names = set()
for toc, ver in (a.split("@") for a in sys.argv[1:]):
    p = toc if os.path.exists(toc) else f"{BACK}/data/legacy/{toc}"
    for v in json.load(open(p))["game_versions"][ver].values():
        names.add(v["default"]["iris_asset"])
os.chdir(os.path.dirname(os.path.abspath(__file__)))
os.makedirs("cache", exist_ok=True)
def get(n):
    if n not in idx: return n, "missing"
    out = f"cache/{n}"
    if os.path.exists(out) and os.path.getsize(out) == idx[n]["size"]: return n, "ok"
    for _ in range(4):
        try:
            d = urllib.request.urlopen(f"{BASE}/{idx[n]['dir']}/{n}", timeout=300).read()
            if len(d) == idx[n]["size"]:
                open(out + ".part", "wb").write(d); os.replace(out + ".part", out); return n, "ok"
        except Exception as e:
            err = e
    return n, "fail"
with cf.ThreadPoolExecutor(8) as ex:
    res = list(ex.map(get, sorted(names)))
bad = [r for r in res if r[1] != "ok"]
print(len(res), "assets;", bad)
