import os, re, sys, zipfile
import lief
from dailyrooms import one_day

src, bundle, out = sys.argv[1:4]
HERE = os.path.dirname(os.path.abspath(__file__))
URL = [(b"ListDataCenters http://185.182.9", b"ListDataCenters http://127.0.0.1"), (b".183/eee\x00", b":18080/e\x00")]

def patch_bin(data):
    for old, new in URL:
        assert len(old) == len(new) and data.count(old) == 1, old
        data = data.replace(old, new)
    tmp = out + ".bin"
    open(tmp, "wb").write(data)
    b = lief.parse(tmp)
    if not any(l.name.endswith("libmroffline.dylib") for l in b.libraries):
        b.add_library("@executable_path/Frameworks/libmroffline.dylib")
    b.write(tmp)
    data = open(tmp, "rb").read()
    os.remove(tmp)
    return data

with zipfile.ZipFile(src) as a, zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    app = next(n for n in a.namelist() if re.fullmatch(r"Payload/[^/]+\.app/", n) or re.fullmatch(r"Payload/[^/]+\.app/Info\.plist", n))
    app = app[:app.index(".app/") + 5]
    exe = app + "DespicableMe"
    for i in a.infolist():
        if "/_CodeSignature/" in i.filename:
            continue
        data = a.read(i)
        if i.filename == exe:
            data = patch_bin(data)
        elif i.filename == app + "levels/lairlib.blibclara":
            data = one_day(data)
        z.writestr(i, data)
    z.write(f"{HERE}/build/ios/libmroffline.dylib", app + "Frameworks/libmroffline.dylib")
    for n in sorted(os.listdir(bundle)):
        z.write(f"{bundle}/{n}", app + "offline/" + n, zipfile.ZIP_STORED)
print(out, round(os.path.getsize(out) / 1e6, 1), "MB")
