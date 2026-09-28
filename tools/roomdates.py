import re, sys, datetime

D = re.compile(rb"(20\d\d)-(\d\d)-(\d\d) (\d\d:\d\d:\d\d)")

def shift(m, years=3):
    y, mo, d = int(m.group(1)) + years, int(m.group(2)), int(m.group(3))
    if mo == 2 and d == 29:
        d = 28
    return b"%04d-%02d-%02d %s" % (y, mo, d, m.group(4))

def patch(b):
    b = bytearray(b)
    n_long = n_shift = 0
    for m in re.finditer(rb"RoomLifetimeInterval", bytes(b)):
        seg = slice(m.end(), m.end() + 140)
        dates = list(D.finditer(bytes(b[seg])))[:4]
        if not dates:
            continue
        start_year = int(dates[0].group(1))
        for dm in dates:
            a, z = m.end() + dm.start(), m.end() + dm.end()
            if start_year <= 2019:
                if dm is not dates[0] and dm.group(0) > dates[0].group(0):
                    b[a:z] = b"2037-12-31 00:00:00"
                    n_long += 1
            else:
                b[a:z] = shift(dm)
                n_shift += 1
    return bytes(b), n_long, n_shift

if __name__ == "__main__":
    src, dst = sys.argv[1], sys.argv[2]
    out, nl, ns = patch(open(src, "rb").read())
    open(dst, "wb").write(out)
    print(f"{dst}: {nl} permanent end dates, {ns} shifted dates")
