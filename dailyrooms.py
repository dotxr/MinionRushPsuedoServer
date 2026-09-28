import datetime, re

SLOT = re.compile(rb"DAILY_[A-Z_]+_\d\d_\d\d_\d{4}_Save\x01\x01e\x14\x00RoomLifetimeInterval")
DATE = re.compile(rb"(20\d\d-\d\d-\d\d) 00:00:00")

def one_day(data):
    b = bytearray(data)
    for m in SLOT.finditer(data):
        ds = list(DATE.finditer(data, m.end(), m.end() + 200))[:4]
        if len(ds) < 4:
            continue
        end = (datetime.date.fromisoformat(ds[0].group(1).decode()) + datetime.timedelta(days=1)).isoformat().encode()
        for d in ds[2:]:
            b[d.start(1):d.end(1)] = end
    return bytes(b)
