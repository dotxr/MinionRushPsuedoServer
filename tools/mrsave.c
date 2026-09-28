#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static uint32_t key[4];

static void make_key(void) {
    const char *s = "ERROR: invalid stream";
    uint8_t k[16] = {0};
    for (size_t i = 0; s[i]; i++) k[i & 15] ^= (uint8_t)s[i];
    memcpy(key, k, 16);
}

static void xtea(uint8_t *p, size_t n, int enc) {
    const uint32_t d = 0x9E3779B9;
    for (size_t i = 0; i + 8 <= n; i += 8) {
        uint32_t v[2];
        memcpy(v, p + i, 8);
        if (enc) {
            uint32_t s = 0;
            for (int r = 0; r < 32; r++) {
                v[0] += (((v[1] << 4) ^ (v[1] >> 5)) + v[1]) ^ (s + key[s & 3]);
                s += d;
                v[1] += (((v[0] << 4) ^ (v[0] >> 5)) + v[0]) ^ (s + key[(s >> 11) & 3]);
            }
        } else {
            uint32_t s = d * 32;
            for (int r = 0; r < 32; r++) {
                v[1] -= (((v[0] << 4) ^ (v[0] >> 5)) + v[0]) ^ (s + key[(s >> 11) & 3]);
                s -= d;
                v[0] -= (((v[1] << 4) ^ (v[1] >> 5)) + v[1]) ^ (s + key[s & 3]);
            }
        }
        memcpy(p + i, v, 8);
    }
}

static uint32_t crc32(const uint8_t *p, size_t n) {
    uint32_t c = 0xFFFFFFFF;
    while (n--) {
        c ^= *p++;
        for (int k = 0; k < 8; k++) c = (c >> 1) ^ (0xEDB88320 & -(c & 1));
    }
    return ~c;
}

static uint8_t *load(const char *path, size_t *n) {
    FILE *f = fopen(path, "rb");
    if (!f) { perror(path); exit(1); }
    fseek(f, 0, SEEK_END);
    *n = (size_t)ftell(f);
    rewind(f);
    uint8_t *b = malloc(*n ? *n : 1);
    if (fread(b, 1, *n, f) != *n) { perror(path); exit(1); }
    fclose(f);
    return b;
}

static uint32_t rd32(const uint8_t *p) { return p[0] | p[1] << 8 | p[2] << 16 | (uint32_t)p[3] << 24; }
static void wr32(uint8_t *p, uint32_t v) { p[0] = v; p[1] = v >> 8; p[2] = v >> 16; p[3] = v >> 24; }

static int next_record(const uint8_t *b, size_t n, size_t *pos, uint32_t *plain, size_t *enc) {
    for (size_t i = *pos; i + 13 <= n; i++) {
        if (b[i] != 0xED || rd32(b + i + 1) != 1) continue;
        uint32_t len = rd32(b + i + 9);
        size_t e = ((size_t)len + 8) & ~(size_t)7;
        if (len < 4 || i + 13 + e > n) continue;
        uint8_t *tmp = malloc(e);
        memcpy(tmp, b + i + 13, e);
        xtea(tmp, e, 0);
        int ok = rd32(tmp) == crc32(tmp + 4, len - 4);
        free(tmp);
        if (!ok) continue;
        *pos = i, *plain = len, *enc = e;
        return 1;
    }
    return 0;
}

int main(int argc, char **argv) {
    make_key();
    if (argc == 4 && !strcmp(argv[1], "dump")) {
        size_t n, pos = 0, enc;
        uint32_t len;
        uint8_t *b = load(argv[2], &n);
        int copies = 0;
        while (next_record(b, n, &pos, &len, &enc)) {
            uint8_t *p = malloc(enc);
            memcpy(p, b + pos + 13, enc);
            xtea(p, enc, 0);
            char out[1024];
            snprintf(out, sizeof out, "%s%d.bin", argv[3], copies);
            FILE *f = fopen(out, "wb");
            if (!f) { perror(out); return 1; }
            fwrite(p + 4, 1, len - 4, f);
            fclose(f);
            printf("%s: copy %d at 0x%zx, %u bytes\n", out, copies, pos, len - 4);
            free(p);
            copies++;
            pos += 13 + enc;
        }
        if (!copies) { fprintf(stderr, "no save records found\n"); return 1; }
        return 0;
    }
    if (argc == 5 && !strcmp(argv[1], "pack")) {
        size_t n, pn, pos = 0, last = 0, enc;
        uint32_t len;
        uint8_t *b = load(argv[2], &n), *plain = load(argv[3], &pn);
        size_t ne = (pn + 4 + 8) & ~(size_t)7;
        uint8_t *rec = calloc(1, ne);
        memcpy(rec + 4, plain, pn);
        wr32(rec, crc32(rec + 4, pn));
        xtea(rec, ne, 1);
        uint8_t *o = malloc(n + 64 * (ne + 13));
        size_t on = 0, at[64];
        int copies = 0;
        while (copies < 64 && next_record(b, n, &pos, &len, &enc)) {
            memcpy(o + on, b + last, pos - last);
            on += pos - last;
            at[copies++] = on;
            memcpy(o + on, b + pos, 13);
            wr32(o + on + 5, (uint32_t)(ne + 4));
            wr32(o + on + 9, (uint32_t)(pn + 4));
            memcpy(o + on + 13, rec, ne);
            on += 13 + ne;
            pos += 13 + enc;
            last = pos;
        }
        memcpy(o + on, b + last, n - last);
        on += n - last;
        for (int c = 0; c < copies; c++) {
            size_t r = at[c], span = 13 + ne;
            if (r < 0x200 || r + span > on) continue;
            uint32_t crc = crc32(o + r, span);
            for (size_t h = r - 0x200 + 0xB0; h < r; h += 0xB8) wr32(o + h, crc), wr32(o + h + 4, (uint32_t)span);
        }
        FILE *f = fopen(argv[4], "wb");
        if (!f) { perror(argv[4]); return 1; }
        fwrite(o, 1, on, f);
        fclose(f);
        if (!copies) { fprintf(stderr, "no save records found\n"); return 1; }
        printf("%s: %d copies replaced\n", argv[4], copies);
        return 0;
    }
    fprintf(stderr, "usage: %s dump <savegame_v2> <out_prefix>\n       %s pack <savegame_v2> <plain.bin> <out>\n", argv[0], argv[0]);
    return 2;
}
