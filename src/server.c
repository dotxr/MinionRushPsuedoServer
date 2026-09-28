#include <arpa/inet.h>
#include <ctype.h>
#include <dirent.h>
#include <errno.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <poll.h>
#include <pthread.h>
#include <signal.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

#include "cJSON.h"
#ifdef __ANDROID__
#include <android/log.h>
void offline_log(const char *fmt, ...);
#define LOGE(...) offline_log(__VA_ARGS__)
#else
#define LOGE(...) fprintf(stderr, __VA_ARGS__)
#endif
#include "certs.h"
#include "mbedtls/ctr_drbg.h"
#include "mbedtls/entropy.h"
#include "mbedtls/error.h"
#include "mbedtls/net_sockets.h"
#include "mbedtls/pk.h"
#include "mbedtls/ssl.h"
#include "mbedtls/x509_crt.h"
#include "psa/crypto.h"

#define PLAIN_PORT 18080
#define ALERTS_PORT 18081
#define TLS_PORT 18443
#define PAD_PORT 1808
int g_port_off;
#define HOST "127.0.0.1"
#define ALIAS "discord.gg/Mez4nyyTsD"
#define SCOPE "storage message config auth social leaderboard_ro storage_ro alert transaction"

static char g_data[1024];
static char g_bundle[1024];
static int g_apk;
static pthread_mutex_t g_lock = PTHREAD_MUTEX_INITIALIZER;

typedef struct { char *p; size_t n, cap; } buf_t;

static void buf_add(buf_t *b, const void *d, size_t n) {
    if (b->n + n + 1 > b->cap) {
        b->cap = (b->n + n + 1) * 2;
        b->p = realloc(b->p, b->cap);
    }
    memcpy(b->p + b->n, d, n);
    b->n += n;
    b->p[b->n] = 0;
}

static void buf_fmt(buf_t *b, const char *fmt, ...) {
    char tmp[4096];
    va_list ap;
    va_start(ap, fmt);
    int n = vsnprintf(tmp, sizeof tmp, fmt, ap);
    va_end(ap);
    if (n < (int)sizeof tmp) { buf_add(b, tmp, n); return; }
    char *big = malloc(n + 1);
    va_start(ap, fmt);
    vsnprintf(big, n + 1, fmt, ap);
    va_end(ap);
    buf_add(b, big, n);
    free(big);
}

static char *read_file(const char *path, size_t *len) {
    FILE *f = fopen(path, "rb");
    if (!f) return NULL;
    fseek(f, 0, SEEK_END);
    long n = ftell(f);
    fseek(f, 0, SEEK_SET);
    char *d = malloc(n + 1);
    if (fread(d, 1, n, f) != (size_t)n) { free(d); fclose(f); return NULL; }
    d[n] = 0;
    fclose(f);
    if (len) *len = n;
    return d;
}

static int write_file(const char *path, const void *d, size_t n) {
    char tmp[1200];
    snprintf(tmp, sizeof tmp, "%s.tmp", path);
    FILE *f = fopen(tmp, "wb");
    if (!f) return -1;
    fwrite(d, 1, n, f);
    fclose(f);
    return rename(tmp, path);
}

static void url_decode(char *s) {
    char *o = s;
    for (; *s; s++) {
        if (*s == '+') *o++ = ' ';
        else if (*s == '%' && isxdigit((unsigned char)s[1]) && isxdigit((unsigned char)s[2])) {
            char h[3] = {s[1], s[2], 0};
            *o++ = (char)strtol(h, NULL, 16);
            s += 2;
        } else *o++ = *s;
    }
    *o = 0;
}

static char *form_get(const char *q, size_t qlen, const char *key, size_t *outlen) {
    size_t kl = strlen(key);
    const char *p = q, *end = q + qlen;
    while (p < end) {
        const char *amp = memchr(p, '&', end - p);
        if (!amp) amp = end;
        if ((size_t)(amp - p) > kl && !memcmp(p, key, kl) && p[kl] == '=') {
            size_t n = amp - p - kl - 1;
            char *v = malloc(n + 1);

            size_t o = 0;
            for (const char *s = p + kl + 1; s < amp; s++) {
                if (*s == '+') v[o++] = ' ';
                else if (*s == '%' && s + 2 < amp && isxdigit((unsigned char)s[1]) && isxdigit((unsigned char)s[2])) {
                    char h[3] = {s[1], s[2], 0};
                    v[o++] = (char)strtol(h, NULL, 16);
                    s += 2;
                } else v[o++] = *s;
            }
            v[o] = 0;
            if (outlen) *outlen = o;
            return v;
        }
        p = amp + 1;
    }
    return NULL;
}

static void now_z(char *out) {
    time_t t = time(NULL);
    struct tm tm;
    gmtime_r(&t, &tm);
    strftime(out, 32, "%Y-%m-%d %H:%M:%SZ", &tm);
}

static void rand_hex(char *out, int bytes) {
    static const char *hx = "0123456789abcdef";
    FILE *f = fopen("/dev/urandom", "rb");
    for (int i = 0; i < bytes; i++) {
        unsigned char c = f ? (unsigned char)fgetc(f) : (unsigned char)rand();
        out[i * 2] = hx[c >> 4];
        out[i * 2 + 1] = hx[c & 15];
    }
    out[bytes * 2] = 0;
    if (f) fclose(f);
}

static void data_path(char *out, size_t n, const char *name) { snprintf(out, n, "%s/%s", g_data, name); }

typedef struct { char *name; long off, size; } zent_t;
static zent_t *g_zents;
static int g_nzents;

static int zent_cmp(const void *a, const void *b) { return strcmp(((zent_t *)a)->name, ((zent_t *)b)->name); }

static void apk_index(void) {
    FILE *f = fopen(g_bundle, "rb");
    if (!f) return;
    fseek(f, 0, SEEK_END);
    long size = ftell(f), start = size > 70000 ? size - 70000 : 0;
    unsigned char *tail = malloc(size - start);
    fseek(f, start, SEEK_SET);
    fread(tail, 1, size - start, f);
    long eocd = -1;
    for (long i = size - start - 22; i >= 0; i--)
        if (!memcmp(tail + i, "PK\5\6", 4)) { eocd = i; break; }
    if (eocd < 0) { free(tail); fclose(f); return; }
    uint32_t cd_size = tail[eocd + 12] | tail[eocd + 13] << 8 | tail[eocd + 14] << 16 | (uint32_t)tail[eocd + 15] << 24;
    uint32_t cd_off = tail[eocd + 16] | tail[eocd + 17] << 8 | tail[eocd + 18] << 16 | (uint32_t)tail[eocd + 19] << 24;
    free(tail);
    unsigned char *cd = malloc(cd_size);
    fseek(f, cd_off, SEEK_SET);
    fread(cd, 1, cd_size, f);
    const char *prefix = "assets/offline/";
    size_t pl = strlen(prefix);
    int cap = 0;
    for (uint32_t p = 0; p + 46 <= cd_size && !memcmp(cd + p, "PK\1\2", 4);) {
        uint16_t method = cd[p + 10] | cd[p + 11] << 8;
        uint32_t csize = cd[p + 20] | cd[p + 21] << 8 | cd[p + 22] << 16 | (uint32_t)cd[p + 23] << 24;
        uint16_t nl = cd[p + 28] | cd[p + 29] << 8, xl = cd[p + 30] | cd[p + 31] << 8, cl = cd[p + 32] | cd[p + 33] << 8;
        uint32_t lho = cd[p + 42] | cd[p + 43] << 8 | cd[p + 44] << 16 | (uint32_t)cd[p + 45] << 24;
        if (method == 0 && nl > pl && !memcmp(cd + p + 46, prefix, pl)) {
            unsigned char lh[30];
            long save = ftell(f);
            fseek(f, lho, SEEK_SET);
            fread(lh, 1, 30, f);
            fseek(f, save, SEEK_SET);
            if (g_nzents == cap) g_zents = realloc(g_zents, (cap = cap ? cap * 2 : 256) * sizeof(zent_t));
            zent_t *z = &g_zents[g_nzents++];
            z->name = strndup((char *)cd + p + 46 + pl, nl - pl);
            z->off = lho + 30 + (lh[26] | lh[27] << 8) + (lh[28] | lh[29] << 8);
            z->size = csize;
        }
        p += 46 + nl + xl + cl;
    }
    free(cd);
    fclose(f);
    qsort(g_zents, g_nzents, sizeof(zent_t), zent_cmp);
}

static FILE *bundle_open(const char *name, long *size) {
    if (strstr(name, "..") || strchr(name, '/')) return NULL;
    if (g_apk) {
        zent_t key = {(char *)name, 0, 0}, *z = bsearch(&key, g_zents, g_nzents, sizeof(zent_t), zent_cmp);
        if (!z) return NULL;
        FILE *f = fopen(g_bundle, "rb");
        if (!f) return NULL;
        fseek(f, z->off, SEEK_SET);
        *size = z->size;
        return f;
    }
    char p[1200];
    snprintf(p, sizeof p, "%s/%s", g_bundle, name);
    FILE *f = fopen(p, "rb");
    if (!f) return NULL;
    fseek(f, 0, SEEK_END);
    *size = ftell(f);
    fseek(f, 0, SEEK_SET);
    return f;
}

static char *bundle_read(const char *name, size_t *len) {
    long size;
    FILE *f = bundle_open(name, &size);
    if (!f) return NULL;
    char *d = malloc(size + 1);
    size_t got = fread(d, 1, size, f);
    fclose(f);
    d[got] = 0;
    if (len) *len = got;
    return d;
}

typedef struct { char *name; char sha[65], md5[33]; long size; } asset_t;
static asset_t *g_assets;
static int g_nassets;

static int asset_cmp(const void *a, const void *b) { return strcmp(((asset_t *)a)->name, ((asset_t *)b)->name); }

static void load_manifest(void) {
    size_t n;
    char *m = bundle_read("manifest.txt", &n);
    if (!m) return;
    int cap = 0;
    for (char *line = strtok(m, "\n"); line; line = strtok(NULL, "\n")) {
        char name[512], sha[65], md5[33];
        long size;
        if (sscanf(line, "%511s %64s %32s %ld", name, sha, md5, &size) != 4) continue;
        if (g_nassets == cap) g_assets = realloc(g_assets, (cap = cap ? cap * 2 : 512) * sizeof(asset_t));
        asset_t *a = &g_assets[g_nassets++];
        a->name = strdup(name);
        strcpy(a->sha, sha);
        strcpy(a->md5, md5);
        a->size = size;
    }
    free(m);
    qsort(g_assets, g_nassets, sizeof(asset_t), asset_cmp);
}

static asset_t *asset_find(const char *name) {
    asset_t key = {(char *)name};
    return bsearch(&key, g_assets, g_nassets, sizeof(asset_t), asset_cmp);
}

static cJSON *g_acct;

static void acct_save(void) {
    char p[1200];
    data_path(p, sizeof p, "account.json");
    char *s = cJSON_PrintUnformatted(g_acct);
    write_file(p, s, strlen(s));
    free(s);
}

static void acct_load(void) {
    char p[1200];
    data_path(p, sizeof p, "account.json");
    char *s = read_file(p, NULL);
    g_acct = s ? cJSON_Parse(s) : NULL;
    free(s);
    if (!g_acct) {
        char hex[33], id[40], ts[32];
        rand_hex(hex, 16);
        snprintf(id, sizeof id, "%.8s-%.4s-11f1-%.4s-%.12s", hex, hex + 8, hex + 16, hex + 20);
        now_z(ts);
        g_acct = cJSON_CreateObject();
        cJSON_AddStringToObject(g_acct, "fed", id);
        cJSON_AddStringToObject(g_acct, "created", ts);
        cJSON_AddStringToObject(g_acct, "modified", ts);
        cJSON_AddObjectToObject(g_acct, "meta");
        cJSON_AddObjectToObject(g_acct, "data");
        acct_save();
    }
}

static const char *fed_id(void) { return cJSON_GetObjectItem(g_acct, "fed")->valuestring; }
static cJSON *acct_obj(const char *k) { return cJSON_GetObjectItem(g_acct, k); }

static cJSON *acct_sub(const char *k) {
    cJSON *o = acct_obj(k);
    return o ? o : cJSON_AddObjectToObject(g_acct, k);
}

static void set_str(cJSON *o, const char *k, const char *v) {
    cJSON_DeleteItemFromObject(o, k);
    if (v) cJSON_AddStringToObject(o, k, v);
    else cJSON_AddNullToObject(o, k);
}

static void touch(void) {
    char ts[32];
    now_z(ts);
    set_str(g_acct, "modified", ts);
}

typedef struct {
    int fd;
    mbedtls_ssl_context *ssl;
    int port;
} conn_t;

typedef struct {
    char method[16], path[4096], query[8192], raw[512];
    char *seg[16];
    int nseg;
    char *body;
    size_t blen;
    char token[2048];
    long range_start, range_end;
    char host[256];
} req_t;

typedef struct {
    int status;
    const char *ctype;
    buf_t hdr, body;
    FILE *file;
    long file_size;
} resp_t;

static int c_read(conn_t *c, void *b, size_t n) {
    if (c->ssl) {
        for (;;) {
            int r = mbedtls_ssl_read(c->ssl, b, n);
            if (r == MBEDTLS_ERR_SSL_WANT_READ || r == MBEDTLS_ERR_SSL_WANT_WRITE) continue;
#ifdef MBEDTLS_ERR_SSL_RECEIVED_NEW_SESSION_TICKET
            if (r == MBEDTLS_ERR_SSL_RECEIVED_NEW_SESSION_TICKET) continue;
#endif
            return r;
        }
    }
    return (int)recv(c->fd, b, n, 0);
}

static int c_write(conn_t *c, const void *b, size_t n) {
    const unsigned char *p = b;
    while (n) {
        int r = c->ssl ? mbedtls_ssl_write(c->ssl, p, n) : (int)send(c->fd, p, n, 0);
        if (c->ssl && (r == MBEDTLS_ERR_SSL_WANT_READ || r == MBEDTLS_ERR_SSL_WANT_WRITE)) continue;
        if (r <= 0) return -1;
        p += r;
        n -= r;
    }
    return 0;
}

static const char *reason(int s) {
    switch (s) {
        case 200: return "OK";
        case 206: return "Partial Content";
        case 302: return "Found";
        case 400: return "Bad Request";
        case 401: return "Unauthorized";
        case 404: return "Not Found";
        default: return "Error";
    }
}

static void send_resp(conn_t *c, req_t *q, resp_t *r) {
    buf_t h = {0};
    long len = r->file ? r->file_size : (long)r->body.n;
    char date[64];
    time_t now = time(NULL);
    struct tm tm;
    gmtime_r(&now, &tm);
    strftime(date, sizeof date, "%a, %d %b %Y %H:%M:%S GMT", &tm);
    buf_fmt(&h, "HTTP/1.1 %d %s\r\nServer: BaseHTTP/0.6 Python/3.14.7\r\nDate: %s\r\nContent-Type: %s\r\nContent-Length: %ld\r\nConnection: keep-alive\r\n",
            r->status, reason(r->status), date, r->ctype ? r->ctype : "application/json", len);
    if (r->hdr.n) buf_add(&h, r->hdr.p, r->hdr.n);
    buf_add(&h, "\r\n", 2);
    c_write(c, h.p, h.n);
    free(h.p);
    if (strcmp(q->method, "HEAD")) {
        if (r->file) {
            char chunk[65536];
            long left = r->file_size;
            while (left > 0) {
                size_t n = fread(chunk, 1, left < (long)sizeof chunk ? left : sizeof chunk, r->file);
                if (!n || c_write(c, chunk, n)) break;
                left -= n;
            }
        } else if (r->body.n) c_write(c, r->body.p, r->body.n);
    }
    if (r->file) fclose(r->file);
    free(r->hdr.p);
    free(r->body.p);
}

static void r_text(resp_t *r, int status, const char *ctype, const char *s) {
    r->status = status;
    r->ctype = ctype;
    buf_add(&r->body, s, strlen(s));
}

static void r_json(resp_t *r, int status, cJSON *j) {
    char *s = cJSON_PrintUnformatted(j);
    r_text(r, status, "application/json", s);
    free(s);
    cJSON_Delete(j);
}

static const char *SERVICES[][2] = {
    {"federation", "/fed"}, {"federation-internal", "/fed"}, {"game_portal", "/portal"}, {"etsv2", "/sink"},
    {"gdid", "/gdid"}, {"ecomm_api_root", "/iap"}, {"crm_iap", "/iap/inapp_crm/index.php"}, {"ads_agency", "/sink"},
    {"customer_care", "/sink"}, {"marketing_site", "/sink"}, {"online_connectivity", "/sink"}, {"ets", "/sink"},
    {"ets_gs", "/sink"}, {"glid", "/sink"}, {"gllive-asa", "/sink"}, {"gllive-bdc", "/sink"}, {"gllive-ope", "/sink"},
    {"livewebapp", "/sink"}, {"statetrackers", "/sink"}, {"tapjoy", "/sink"}, {"china_regulation", "/sink"},
    {"apple_iap", "/iap"}, {"standalone_iap", "/iap"}, {"offline_apple_iap", "/sink"}, {"offline_items", "/sink"},
    {"master_federation", "/fed"}};

static void client_ver(const char *client_id, char *ver, char *plat) {
    ver[0] = plat[0] = 0;
    const char *p = client_id;
    for (int i = 0; i < 2 && p; i++) p = strchr(p, ':'), p = p ? p + 1 : NULL;
    if (!p) return;
    const char *e = strchr(p, ':');
    if (!e) return;
    snprintf(ver, 32, "%.*s", (int)(e - p), p);
    const char *f = strchr(e + 1, ':');
    snprintf(plat, 32, "%.*s", (int)(f ? f - e - 1 : (long)strlen(e + 1)), e + 1);
}

static void token_client(const char *tok, char *client_id) {
    client_id[0] = 0;
    const char *p = tok;
    for (int i = 0; i < 2 && p; i++) p = strchr(p, ','), p = p ? p + 1 : NULL;
    if (!p) return;
    const char *e = strchr(p, ',');
    snprintf(client_id, 128, "%.*s", (int)(e ? e - p : (long)strlen(p)), p);
}

static cJSON *token_json(const char *cred, const char *client_id, const char *device_id) {
    char hex[33], hex2[33], buf[4096];
    double now = (double)time(NULL);
    rand_hex(hex, 16);
    rand_hex(hex2, 16);
    cJSON *j = cJSON_CreateObject();
    snprintf(buf, sizeof buf, "%s,%s,%s,%.6f,%s,%s,local|%s", fed_id(), SCOPE, client_id, now + 14400, cred, device_id, hex);
    cJSON_AddStringToObject(j, "access_token", buf);
    cJSON_AddStringToObject(j, "token_type", "gameloft_online");
    cJSON_AddStringToObject(j, "fed_id", fed_id());
    cJSON_AddStringToObject(j, "scope", SCOPE);
    snprintf(buf, sizeof buf, "refresh|%s,%s,%s,%.6f,%s,%s,local|%s", fed_id(), SCOPE, client_id, now + 3e6, cred, device_id, hex2);
    cJSON_AddStringToObject(j, "refresh_token", buf);
    return j;
}

static void h_authorize(req_t *q, resp_t *r) {
    char *grant = form_get(q->body, q->blen, "grant_type", NULL), *client = form_get(q->body, q->blen, "client_id", NULL);
    const char *client_id = client ? client : "";
    if (grant && !strcmp(grant, "refresh_token")) {
        char *rt = form_get(q->body, q->blen, "refresh_token", NULL);
        char f[6][512] = {{0}};
        if (rt) {
            char *s = rt + (strncmp(rt, "refresh|", 8) ? 0 : 8), *save = NULL;
            int i = 0;
            for (char *t = strtok_r(s, ",", &save); t && i < 6; t = strtok_r(NULL, ",", &save)) snprintf(f[i++], 512, "%s", t);
        }
        cJSON *j = token_json(f[4], client_id, f[5]);
        char *s = cJSON_PrintUnformatted(j);
        r_text(r, 200, "application/json;charset=utf-8", s);
        free(s);
        cJSON_Delete(j);
        free(rt);
    } else {
        char *cred = form_get(q->body, q->blen, "username", NULL);
        if (!cred) {
            r_text(r, 400, "text/plain", "400 Bad Request : missing username");
        } else {
            char *dev = form_get(q->body, q->blen, "device_id", NULL), *fw = form_get(q->body, q->blen, "device_firmware", NULL),
                 *model = form_get(q->body, q->blen, "device_model", NULL),
                 *country = form_get(q->body, q->blen, "device_country", NULL),
                 *lang = form_get(q->body, q->blen, "device_language", NULL);
            pthread_mutex_lock(&g_lock);
            cJSON *meta = cJSON_CreateObject(), *device = cJSON_CreateObject();
            cJSON_AddNullToObject(device, "carrier");
            cJSON_AddNullToObject(device, "download_code");
            set_str(device, "firmware", fw);
            set_str(device, "id", dev ? dev : "");
            set_str(device, "model", model);
            set_str(meta, "credential", cred);
            set_str(meta, "current_client_id", client_id);
            set_str(meta, "country", country && *country ? country : "US");
            set_str(meta, "language", lang);
            cJSON_AddItemToObject(meta, "current_device", cJSON_Duplicate(device, 1));
            set_str(meta, "current_device_id", dev ? dev : "");
            cJSON *devs = cJSON_AddArrayToObject(meta, "devices");
            cJSON_AddItemToArray(devs, device);
            set_str(meta, "datacenter", "local");
            cJSON_ReplaceItemInObject(g_acct, "meta", meta);
            acct_save();
            cJSON *j = token_json(cred, client_id, dev ? dev : "");
            char *scope = form_get(q->body, q->blen, "scope", NULL);
            if (scope && *scope) cJSON_ReplaceItemInObject(j, "scope", cJSON_CreateString(scope));
            free(scope);
            pthread_mutex_unlock(&g_lock);
            char *s = cJSON_PrintUnformatted(j);
            r_text(r, 200, "application/json;charset=utf-8", s);
            free(s);
            cJSON_Delete(j);
            free(dev), free(fw), free(model), free(country), free(lang);
        }
        free(cred);
    }
    free(grant);
    free(client);
}

static void profile_get(resp_t *r) {
    cJSON *data = acct_obj("data");
    if (!data || !data->child) {
        r_text(r, 404, "text/plain", "404 Not Found : Profile not found");
        return;
    }
    cJSON *o = cJSON_Duplicate(acct_obj("meta"), 1);
    for (cJSON *it = data->child; it; it = it->next) {
        cJSON_DeleteItemFromObject(o, it->string);
        cJSON_AddItemToObject(o, it->string, cJSON_Duplicate(it, 1));
    }
    char *ds = cJSON_PrintUnformatted(data);
    const char *created = cJSON_GetObjectItem(g_acct, "created")->valuestring,
               *modified = cJSON_GetObjectItem(g_acct, "modified")->valuestring;
    cJSON_AddStringToObject(o, "fed_id", fed_id());
    cJSON_AddStringToObject(o, "created", created);
    cJSON_AddStringToObject(o, "modified", modified);
    cJSON_AddStringToObject(o, "last_session", modified);
    cJSON_AddNumberToObject(o, "profile_size", strlen(ds));
    free(ds);
    cJSON *quota = cJSON_AddObjectToObject(o, "@quota"), *sg = cJSON_AddObjectToObject(quota, "@savegamelib");
    cJSON_AddNumberToObject(sg, "max", 1500000);
    cJSON_AddNumberToObject(sg, "max_files", 1);
    cJSON_AddNumberToObject(sg, "remaining", 9999);
    cJSON_AddNumberToObject(sg, "total", 0);
    cJSON_AddNumberToObject(o, "total_refund", 0.0);
    cJSON_AddNumberToObject(o, "total_spent", 0.0);
    cJSON_AddNumberToObject(o, "total_transactions", 0);
    r_json(r, 200, o);
}

static char *param(req_t *q, const char *key, size_t *len) {
    char *v = form_get(q->query, strlen(q->query), key, len);
    return v ? v : form_get(q->body, q->blen, key, len);
}

static void h_profile(req_t *q, resp_t *r) {
    pthread_mutex_lock(&g_lock);
    cJSON *data = acct_obj("data");
    if (q->nseg == 4 && !strcmp(q->method, "POST")) {
        char *obj = param(q, "object", NULL);
        cJSON *v = obj ? cJSON_Parse(obj) : cJSON_CreateNull();
        free(obj);
        if (!v) {
            r_text(r, 400, "text/plain", "400 Bad Request : invalid object");
        } else {
            cJSON_DeleteItemFromObject(data, q->seg[3]);
            cJSON_AddItemToObject(data, q->seg[3], v);
            touch();
            acct_save();
            profile_get(r);
        }
    } else if (!strcmp(q->method, "GET")) {
        profile_get(r);
    } else {
        char *obj = param(q, "object", NULL), *op = param(q, "operation", NULL);
        cJSON *o = cJSON_Parse(obj ? obj : "{}");
        if (!o || !cJSON_IsObject(o)) {
            r_text(r, 400, "text/plain", "400 Bad Request : invalid object");
        } else {
            if (op && strcmp(op, "merge")) {
                cJSON_ReplaceItemInObject(g_acct, "data", cJSON_CreateObject());
                data = acct_obj("data");
            }
            for (cJSON *it = o->child; it; it = it->next) {
                cJSON_DeleteItemFromObject(data, it->string);
                cJSON_AddItemToObject(data, it->string, cJSON_Duplicate(it, 1));
            }
            touch();
            acct_save();
            r_text(r, 200, "application/json", "{\"response\": \"OK\"}");
        }
        cJSON_Delete(o);
        free(obj);
        free(op);
    }
    pthread_mutex_unlock(&g_lock);
}

static void h_identity(req_t *q, resp_t *r) {
    pthread_mutex_lock(&g_lock);
    cJSON *id = acct_sub("identity");
    if (!strcmp(q->method, "POST") && q->nseg == 3) {
        static const char *keys[] = {"country", "language", "name", "mobile", "birth_date", "birthDate"};
        for (size_t i = 0; i < sizeof keys / sizeof *keys; i++) {
            char *v = param(q, keys[i], NULL);
            if (!v) continue;
            cJSON_DeleteItemFromObject(id, keys[i]);
            cJSON_AddStringToObject(id, keys[i], v);
            free(v);
        }
        touch();
        acct_save();
    }
    r_json(r, 200, cJSON_Duplicate(q->nseg == 3 ? id : acct_sub("regulations"), 1));
    pthread_mutex_unlock(&g_lock);
}

static void h_seshat(req_t *q, resp_t *r) {
    char name[600], p[1200];
    const char *key = q->seg[2];
    if (strchr(key, '/') || strstr(key, "..")) { r_text(r, 400, "text/plain", "bad key"); return; }
    snprintf(name, sizeof name, "seshat_%s", key);
    data_path(p, sizeof p, name);
    pthread_mutex_lock(&g_lock);
    if (!strcmp(q->method, "GET")) {
        size_t n;
        char *d = read_file(p, &n);
        if (!d) {
            char msg[700];
            snprintf(msg, sizeof msg, "404 Not Found : Key %s not found in namespace 3493 for user me", key);
            r_text(r, 404, "text/plain", msg);
        } else {
            r->status = 200;
            r->ctype = "application/octet-stream";
            buf_add(&r->body, d, n);
            free(d);
        }
    } else if (!strcmp(q->method, "DELETE")) {
        unlink(p);
        char msg[700];
        snprintf(msg, sizeof msg, "Key %s deleted", key);
        r_text(r, 200, "text/plain", msg);
    } else {
        size_t n = 0;
        char *d = form_get(q->body, q->blen, "data", &n);
        write_file(p, d ? d : "", n);
        free(d);
        char msg[700];
        snprintf(msg, sizeof msg, "Data of length %zu saved in namespace 3493 for user me under private key %s", n, key);
        r_text(r, 200, "text/plain", msg);
    }
    pthread_mutex_unlock(&g_lock);
}

static void h_users_me(resp_t *r) {
    pthread_mutex_lock(&g_lock);
    cJSON *meta = acct_obj("meta"), *dev = cJSON_GetObjectItem(meta, "current_device");
    cJSON *o = cJSON_CreateObject();
    cJSON_AddStringToObject(o, "account", fed_id());
    cJSON *creds = cJSON_AddArrayToObject(o, "credentials");
    cJSON *cred = cJSON_GetObjectItem(meta, "credential");
    if (cJSON_IsString(cred)) cJSON_AddItemToArray(creds, cJSON_CreateString(cred->valuestring));
    cJSON_AddArrayToObject(o, "client_ids");
    cJSON_AddItemToArray(cJSON_AddArrayToObject(o, "alias"), cJSON_CreateString(ALIAS));
    cJSON *inst = cJSON_AddArrayToObject(o, "installations"), *i = cJSON_CreateObject();
    cJSON_AddItemToArray(inst, i);
#define DUP(dst, src, k) cJSON_AddItemToObject(dst, k, cJSON_GetObjectItem(src, k) ? cJSON_Duplicate(cJSON_GetObjectItem(src, k), 1) : cJSON_CreateNull())
    cJSON *d = dev ? dev : cJSON_CreateObject();
    cJSON_AddItemToObject(i, "device_id", cJSON_GetObjectItem(d, "id") ? cJSON_Duplicate(cJSON_GetObjectItem(d, "id"), 1) : cJSON_CreateNull());
    cJSON_AddNullToObject(i, "carrier");
    DUP(i, d, "model");
    cJSON_AddNullToObject(i, "download_code");
    DUP(i, meta, "language");
    DUP(i, meta, "country");
    cJSON_AddNullToObject(i, "resolution");
    DUP(i, d, "firmware");
    if (!dev) cJSON_Delete(d);
    cJSON_AddNullToObject(o, "last_login");
    cJSON_AddFalseToObject(o, "is_ghost");
    pthread_mutex_unlock(&g_lock);
    r_json(r, 200, o);
}

static void h_account(req_t *q, resp_t *r) {
    pthread_mutex_lock(&g_lock);
    cJSON *data = acct_obj("data"), *meta = acct_obj("meta");
    char cred[1024];
    snprintf(cred, sizeof cred, "%s", q->seg[1]);
    if (!strcmp(cred, "me")) {
        cJSON *c = cJSON_GetObjectItem(meta, "credential");
        snprintf(cred, sizeof cred, "%s", cJSON_IsString(c) ? c->valuestring : "");
    }
    cJSON *o = cJSON_CreateObject();
    cJSON_AddStringToObject(o, "credential", cred);
    cJSON *name = cJSON_GetObjectItem(data, "name");
    const char *colon = strchr(cred, ':');
    cJSON_AddStringToObject(o, "name", cJSON_IsString(name) ? name->valuestring : colon ? colon + 1 : cred);
    cJSON_AddStringToObject(o, "avatar", "");
    cJSON_AddStringToObject(o, "game", "3493");
    cJSON_AddStringToObject(o, "status_line", "");
    cJSON_AddStringToObject(o, "fed_id", fed_id());
    cJSON_AddNullToObject(o, "avatar_name");
    cJSON_AddTrueToObject(o, "online");
    cJSON_AddNullToObject(o, "seconds_since_last_status_change");
    cJSON *games = cJSON_AddObjectToObject(o, "games"), *g = cJSON_AddObjectToObject(games, "3493");
    cJSON_AddNumberToObject(g, "last_time_played", (double)time(NULL));
    DUP(o, data, "country");
    cJSON_AddNullToObject(o, "language");
    cJSON_AddArrayToObject(o, "groups");
    cJSON_AddArrayToObject(o, "participations");
    pthread_mutex_unlock(&g_lock);
    r_json(r, 200, o);
}

static void h_config(req_t *q, resp_t *r) {
    char client_id[128], ver[32], plat[32], fname[128];
    token_client(q->token, client_id);
    client_ver(client_id, ver, plat);
    snprintf(fname, sizeof fname, "daily_%s_%s.txt", ver, plat);
    size_t n;
    char *cfg = bundle_read("hestia_config.json", &n), *rooms = bundle_read(fname, NULL);
    if (!rooms) rooms = bundle_read("daily_9.6.1b_ios.txt", NULL);
    if (!cfg) { r_text(r, 404, "text/plain", "no config"); free(rooms); return; }
    char *ids[512];
    int nids = 0;
    for (char *s = rooms ? strtok(rooms, "\n") : NULL; s && nids < 512; s = strtok(NULL, "\n")) ids[nids++] = s;
    buf_t slot = {0};
    buf_add(&slot, "\"DAYCHALLENGE_Slot\":{", 21);
    long today = time(NULL) / 86400;
    int first = 1;
    char used[512] = {0};
    for (long d = today - 1; d < today + 15 && nids; d++) {
        time_t t = d * 86400;
        struct tm tm;
        gmtime_r(&t, &tm);
        char day[16];
        strftime(day, sizeof day, "%Y-%m-%d", &tm);
        int pick = (int)(d % nids);
        for (int i = 0; i < nids; i++) {
            size_t L = strlen(ids[i]);
            if (L < 10) continue;
            const char *dt = ids[i] + L - 10;
            char want[16];
            snprintf(want, sizeof want, "%04d-%.2s-%.2s", atoi(dt + 6) + 3, dt + 3, dt);
            if (!strcmp(want, day)) { pick = i; break; }
        }
        if (used[pick]) continue;
        used[pick] = 1;
        buf_fmt(&slot, "%s\"%s\":{\"incoming_date\":\"%s 00:00:00\",\"start_date\":\"%s 00:00:00\",\"end_date\":\"%s 23:59:59\",\"outgoing_date\":\"%s 23:59:59\"}",
                first ? "" : ",", ids[pick], day, day, day, day);
        first = 0;
    }
    for (int i = 0; i < nids; i++)
        if (!used[i]) {
            buf_fmt(&slot, "%s\"%s\":{\"incoming_date\":\"2020-01-01 00:00:00\",\"start_date\":\"2020-01-01 00:00:00\",\"end_date\":\"2020-01-01 23:59:59\",\"outgoing_date\":\"2020-01-01 23:59:59\"}",
                    first ? "" : ",", ids[i]);
            first = 0;
        }
    buf_add(&slot, "},", 2);
    char *at = strstr(cfg, "\"_Slots\":{");
    r->status = 200;
    r->ctype = "application/json";
    if (at) {
        size_t pre = at - cfg + 10;
        buf_add(&r->body, cfg, pre);
        buf_add(&r->body, slot.p, slot.n);
        buf_add(&r->body, cfg + pre, n - pre);
    } else buf_add(&r->body, cfg, n);
    free(slot.p);
    free(cfg);
    free(rooms);
}

static void asset_headers(resp_t *r, asset_t *a) {
    buf_fmt(&r->hdr, "Etag: \"%s\"\r\nasset_hash: %s\r\nasset-hash: %s\r\n", a->sha, a->sha, a->sha);
}

static void h_assets(req_t *q, resp_t *r) {
    const char *client_id = q->seg[1], *name = q->seg[2];
    char ver[32], plat[32];
    client_ver(client_id, ver, plat);
    if (!strncmp(name, "mnhtn_index_", 12)) {
        char fname[96];
        snprintf(fname, sizeof fname, "toc_%s_%s.txt", ver, name + 12);
        char *toc = bundle_read(fname, NULL);
        if (toc) {
            for (char *e = toc + strlen(toc); e > toc && isspace((unsigned char)e[-1]);) *--e = 0;
            r_text(r, 200, "text/plain", toc);
            free(toc);
            return;
        }
    }
    asset_t *a = asset_find(name);
    if (!a || !strcmp(name, "hestia_config.json")) {
        char msg[700];
        snprintf(msg, sizeof msg, "404 Not Found : Asset %s not found for client %s", name, client_id);
        r_text(r, 404, "text/plain", msg);
        return;
    }
    char url[800];
    if (!strncmp(client_id, "1677:", 5)) snprintf(url, sizeof url, "https://offline.gameloft.com/lfile/%s", name);
    else if (strstr(client_id, ":android:")) snprintf(url, sizeof url, "http://%s:%d/lfile/%s", HOST, PLAIN_PORT, name);
    else snprintf(url, sizeof url, "https://%s:%d/lfile/%s", HOST, TLS_PORT, name);
    asset_headers(r, a);
    if (q->nseg >= 4 && !strcmp(q->seg[3], "url")) {
        r_text(r, 200, "text/html; charset=\"UTF-8\"", url);
    } else {
        r->status = 302;
        r->ctype = "text/html; charset=\"UTF-8\"";
        buf_fmt(&r->hdr, "Location: %s\r\n", url);
    }
}

static void h_lfile(req_t *q, resp_t *r) {
    const char *name = q->seg[1];
    asset_t *a = asset_find(name);
    long size;
    FILE *f = a && strcmp(name, "hestia_config.json") ? bundle_open(name, &size) : NULL;
    if (!f) { r_text(r, 404, "text/plain", "404 Not Found"); return; }
    r->status = 200;
    size_t L = strlen(name);
    r->ctype = L > 5 && !strcmp(name + L - 5, ".json") ? "application/json" : "application/octet-stream";
    buf_fmt(&r->hdr, "ETag: \"%s\"\r\nAccept-Ranges: bytes\r\nLast-Modified: Thu, 08 Sep 2022 09:42:10 GMT\r\n", a->md5);
    if (q->range_start >= 0 && q->range_start < size) {
        long end = q->range_end >= 0 && q->range_end < size ? q->range_end : size - 1;
        fseek(f, q->range_start, SEEK_CUR);
        r->status = 206;
        buf_fmt(&r->hdr, "Content-Range: bytes %ld-%ld/%ld\r\n", q->range_start, end, size);
        size = end - q->range_start + 1;
    }
    r->file = f;
    r->file_size = size;
}

static cJSON *boards_load(void) {
    char p[1200];
    data_path(p, sizeof p, "boards.json");
    char *s = read_file(p, NULL);
    cJSON *b = s ? cJSON_Parse(s) : NULL;
    free(s);
    return b ? b : cJSON_CreateObject();
}

static void boards_save(cJSON *b) {
    char p[1200];
    data_path(p, sizeof p, "boards.json");
    char *s = cJSON_PrintUnformatted(b);
    write_file(p, s, strlen(s));
    free(s);
}

static void week(char *wid, long *end) {
    long day = time(NULL) / 86400, start = day * 86400 - ((day + 3) % 7) * 86400;
    time_t t = start;
    struct tm tm;
    gmtime_r(&t, &tm);
    strftime(wid, 16, "%Y%W", &tm);
    *end = start + 7 * 86400;
}

static const char *player_name(void) {
    cJSON *n = cJSON_GetObjectItem(acct_obj("data"), "name");
    if (cJSON_IsString(n)) return n->valuestring;
    cJSON *c = cJSON_GetObjectItem(acct_obj("meta"), "credential");
    const char *s = cJSON_IsString(c) ? c->valuestring : fed_id(), *colon = strchr(s, ':');
    static char buf[16];
    snprintf(buf, sizeof buf, "%.12s", colon ? colon + 1 : s);
    return buf;
}

static void board_post(cJSON *b, const char *board, double score) {
    cJSON *cur = cJSON_GetObjectItem(b, board);
    if (cur && cur->valuedouble >= score) return;
    cJSON_DeleteItemFromObject(b, board);
    cJSON_AddNumberToObject(b, board, score);
}

static void h_portal(req_t *q, resp_t *r) {
    char task[1024] = {0}, wid[16], cc[8] = "US";
    for (int i = 1; i < q->nseg; i++) strcat(strcat(task, q->seg[i]), "/");
    long end;
    week(wid, &end);
    pthread_mutex_lock(&g_lock);
    cJSON *country = cJSON_GetObjectItem(acct_obj("meta"), "country");
    if (cJSON_IsString(country)) snprintf(cc, sizeof cc, "%s", country->valuestring);
    cJSON *b = boards_load();
    char board[64];
    snprintf(board, sizeof board, "topbanana_%s", wid);
    size_t tl = strlen(task);
#define ENDS(s) (tl >= strlen(s) && !strcmp(task + tl - strlen(s), s))
    if (ENDS("leaderboards/get_best_run_leaderboards/")) {
        char *pc = param(q, "country_code", NULL), code[8];
        snprintf(code, sizeof code, "%s", pc && *pc ? pc : cc);
        free(pc);
        for (char *c = code; *c; c++) *c = toupper((unsigned char)*c);
        cJSON *o = cJSON_CreateObject(), *arr = cJSON_AddArrayToObject(o, "available_leaderboards");
        const char *kinds[3] = {code, "global", "friends"};
        for (int i = 0; i < 3; i++) {
            cJSON *e = cJSON_CreateObject();
            char nm[64];
            snprintf(nm, sizeof nm, "bestrun_%s_%s", wid, kinds[i]);
            cJSON_AddStringToObject(e, "name", nm);
            cJSON_AddStringToObject(e, "type", i == 2 ? "friends" : "regional");
            if (i < 2) {
                cJSON_AddStringToObject(e, "country_flag_code", i ? "" : code);
                cJSON_AddBoolToObject(e, "multiregional", i == 1);
            }
            cJSON_AddNumberToObject(e, "expiration", end);
            cJSON_AddItemToArray(arr, e);
        }
        r_json(r, 200, o);
    } else if (ENDS("leaderboards/post/")) {
        char *d = param(q, "data_to_post", NULL);
        cJSON *posts = cJSON_Parse(d ? d : "[]");
        free(d);
        if (cJSON_IsObject(posts)) {
            cJSON *arr = cJSON_CreateArray();
            cJSON_AddItemToArray(arr, posts);
            posts = arr;
        }
        cJSON *e;
        cJSON_ArrayForEach(e, posts) {
            cJSON *nm = cJSON_GetObjectItem(e, "leaderboard_name"), *sc = cJSON_GetObjectItem(e, "score");
            if (cJSON_IsString(nm)) board_post(b, nm->valuestring, cJSON_IsNumber(sc) ? sc->valuedouble : cJSON_IsString(sc) ? atof(sc->valuestring) : 0);
        }
        cJSON_Delete(posts);
        boards_save(b);
        r_text(r, 200, "application/json", "{\"status\": \"ok\"}");
    } else if (ENDS("endless_run/get_top_banana_stage_info/")) {
        cJSON *o = cJSON_CreateObject();
        cJSON_AddStringToObject(o, "stage_id", wid);
        cJSON_AddNumberToObject(o, "stage_end_date", end);
        cJSON_AddStringToObject(o, "leaderboard_name", board);
        r_json(r, 200, o);
    } else if (ENDS("endless_run/post_score/") || ENDS("endless_run/finish_top_banana_stage/")) {
        if (ENDS("endless_run/post_score/")) {
            char *s = param(q, "score", NULL);
            board_post(b, board, s ? atof(s) : 0);
            free(s);
            boards_save(b);
        }
        char *ln = param(q, "leaderboard_name", NULL);
        cJSON *sc = cJSON_GetObjectItem(b, ln && *ln ? ln : board);
        free(ln);
        cJSON *o = cJSON_CreateObject();
        cJSON_AddNumberToObject(o, "position", sc ? 1 : 0);
        cJSON_AddNumberToObject(o, "score", sc ? (long)sc->valuedouble : 0);
        r_json(r, 200, o);
    } else if (ENDS("general/transfer_profile_exists.php/")) {
        r_text(r, 200, "application/json", "{\"body\": {\"has_old_profile\": false}}");
    } else if (ENDS("general/identify_game_mode.php/")) {
        r_text(r, 200, "application/json", "{\"body\": {\"game_mode\": \"lair\"}}");
    } else r_text(r, 200, "application/json", "{}");
    cJSON_Delete(b);
    pthread_mutex_unlock(&g_lock);
}

static void h_board_read(req_t *q, resp_t *r) {
    pthread_mutex_lock(&g_lock);
    cJSON *b = boards_load(), *sc = cJSON_GetObjectItem(b, q->seg[2]), *arr = cJSON_CreateArray();
    char *off = param(q, "offset", NULL);
    if (sc && (!off || atoi(off) == 0)) {
        cJSON *cc = cJSON_GetObjectItem(acct_obj("meta"), "country");
        cJSON *e = cJSON_CreateObject();
        cJSON_AddNumberToObject(e, "rank", 1);
        cJSON_AddNumberToObject(e, "score", (long)sc->valuedouble);
        cJSON_AddStringToObject(e, "display_name", player_name());
        cJSON_AddStringToObject(e, "credential", fed_id());
        cJSON_AddStringToObject(e, "fed_id", fed_id());
        cJSON_AddStringToObject(e, "anonymous_name", player_name());
        cJSON_AddStringToObject(e, "avatar_url", "");
        cJSON_AddStringToObject(e, "country_code", cJSON_IsString(cc) ? cc->valuestring : "US");
        cJSON_AddItemToArray(arr, e);
    }
    free(off);
    cJSON_Delete(b);
    pthread_mutex_unlock(&g_lock);
    r_json(r, 200, arr);
}

static void h_pad(req_t *q, resp_t *r) {
    char ver[32], plat[32], fname[64];
    client_ver(q->seg[1], ver, plat);
    snprintf(fname, sizeof fname, "pad_%s.txt", ver);
    char *tab = bundle_read(fname, NULL);
    size_t pl = strlen(q->seg[2]);
    r->status = 200;
    r->ctype = "text/plain";
    for (char *line = tab ? strtok(tab, "\n") : NULL; line; line = strtok(NULL, "\n")) {
        if (strncmp(line, q->seg[2], pl) || line[pl] != ' ') continue;
        for (char *n = strtok(line + pl + 1, " "); n; n = strtok(NULL, " "))
            if (asset_find(n)) buf_fmt(&r->body, "http://%s:%d/lfile/%s\n", HOST, PLAIN_PORT, n);
        break;
    }
    free(tab);
}

static void h_eve(req_t *q, resp_t *r) {
    int skip = strcmp(q->seg[0], "config") != 0;
    char **s = q->seg + skip;
    int n = q->nseg - skip;
    if (n && !strcmp(s[0], "v1")) s++, n--;
    if (n >= 3 && !strcmp(s[0], "config") && !strcmp(s[2], "datacenters")) {
        if (n == 5 && !strcmp(s[4], "urls")) {
            cJSON *o = cJSON_CreateObject();
            char url[512];
            int tls = !strncmp(s[1], "1677:", 5);
            for (size_t i = 0; i < sizeof SERVICES / sizeof *SERVICES; i++) {
                if (tls) snprintf(url, sizeof url, "https://offline.gameloft.com%s", strcmp(SERVICES[i][1], "/sink") ? SERVICES[i][1] : "");
                else snprintf(url, sizeof url, "http://%s:%d%s", HOST, PLAIN_PORT, SERVICES[i][1]);
                cJSON_AddStringToObject(o, SERVICES[i][0], url);
            }
            if (tls) snprintf(url, sizeof url, "https://offline.gameloft.com/pandora/%s", s[1]);
            else if (strstr(s[1], ":android:")) snprintf(url, sizeof url, "http://%s:%d/pandora/%s", HOST, PLAIN_PORT, s[1]);
            else snprintf(url, sizeof url, "https://%s:%d/pandora/%s", HOST, TLS_PORT, s[1]);
            cJSON_AddStringToObject(o, "pandora", url);
            cJSON_AddStringToObject(o, "status", "none");
            r_json(r, 200, o);
            return;
        }
        r_text(r, 200, "application/json",
               "[{\"name\": \"mdc\", \"status\": \"active\", \"preferred\": true, \"country_code\": \"US\", \"_datacenter_id\": \"local\"}]");
        return;
    }
    r_text(r, 200, "application/json", "{}");
}

static void h_gdid(req_t *q, resp_t *r) {
    char *dev = param(q, "idfv", NULL);
    if (!dev) dev = param(q, "android_id", NULL);
    if (!dev) dev = param(q, "device_id", NULL);
    uint64_t h = 1469598103934665603ULL;
    for (const char *p = dev ? dev : fed_id(); *p; p++) h = (h ^ (unsigned char)*p) * 1099511628211ULL;
    free(dev);
    char out[32];
    snprintf(out, sizeof out, "%llu", (unsigned long long)(h % 9000000000000000000ULL + 1000000000000000000ULL));
    if (strstr(q->query, "source=Gaia_1.")) {
        char js[96];
        snprintf(js, sizeof js, "{\"globalDeviceID\": \"%s\"}", out);
        return r_text(r, 200, "application/json", js);
    }
    r_text(r, 200, "text/plain", out);
}

static int seg_is(req_t *q, int i, const char *s) { return q->nseg > i && !strcmp(q->seg[i], s); }

static void route(conn_t *c, req_t *q, resp_t *r) {
    const char *head = q->nseg ? q->seg[0] : "";
    int e = *head == 'e';
    for (const char *p = head; *p && e; p++) e = *p == 'e' || (*p == 'm' && !p[1]);
    if (e || !strcmp(head, "config")) return h_eve(q, r);
    if (!strcmp(head, "pandora")) {
        char loc[64];
        if (q->nseg > 1 && !strncmp(q->seg[1], "1677:", 5)) snprintf(loc, sizeof loc, "offline.gameloft.com:443");
        else snprintf(loc, sizeof loc, "%s:%d", HOST, q->nseg > 1 && strstr(q->seg[1], ":android:") ? PLAIN_PORT : TLS_PORT);
        return r_text(r, 200, "text/plain", loc);
    }
    if (!strcmp(head, "alerts") || (seg_is(q, 0, "v1") && seg_is(q, 1, "alerts")) || (seg_is(q, 0, "v2") && seg_is(q, 1, "alerts"))) {
        if (c->port == ALERTS_PORT || strstr(q->query, "1677%3A") || strstr(q->query, ",1677:")) sleep(20);
        return r_text(r, 200, "application/json", "[]");
    }
    if (!strcmp(head, "gdid")) return h_gdid(q, r);
    if (!strcmp(head, "iap")) return r_text(r, 200, "application/json", "{\"enabled\": false}");
    if (!strcmp(head, "portal") && q->nseg > 1 && *q->seg[1]) return h_portal(q, r);
    if (!strcmp(head, "authorize") && !strcmp(q->method, "POST")) return h_authorize(q, r);
    if (!strcmp(head, "assets") && q->nseg >= 3) return h_assets(q, r);
    if ((!strcmp(head, "lfile") || !strcmp(head, "rfile")) && q->nseg == 2) return h_lfile(q, r);
    if (seg_is(q, 0, "profiles") && seg_is(q, 1, "me") && seg_is(q, 2, "myprofile")) return h_profile(q, r);
    if (!strcmp(head, "data") && q->nseg == 3) return h_seshat(q, r);
    if (seg_is(q, 0, "users") && seg_is(q, 1, "me") && q->nseg == 2) return h_users_me(r);
    if (seg_is(q, 0, "games") && seg_is(q, 2, "alias")) return r_text(r, 200, "application/json", "{\"alias\": \"" ALIAS "\"}");
    if (seg_is(q, 0, "users") && seg_is(q, 1, "me") && seg_is(q, 2, "identity")) return h_identity(q, r);
    if (!strcmp(head, "messages") || (seg_is(q, 0, "alerts") && seg_is(q, 1, "me"))) return r_text(r, 200, "application/json", "[]");
    if (!strcmp(head, "accounts") && q->nseg == 2 && !strcmp(q->method, "GET")) return h_account(q, r);
    if (seg_is(q, 0, "configs") && seg_is(q, 1, "users") && seg_is(q, 2, "me")) return h_config(q, r);
    if (!strcmp(head, "leaderboards") && q->nseg >= 3) return h_board_read(q, r);
    if (!strcmp(head, "pad") && q->nseg == 3) return h_pad(q, r);
    r_text(r, 200, "application/json", "{}");
}

static int read_request(conn_t *c, req_t *q, char *buf, size_t cap, size_t *have) {
    char *end;
    for (;;) {
        buf[*have] = 0;
        if ((end = strstr(buf, "\r\n\r\n"))) break;
        if (*have >= cap - 1) return -1;
        int n = c_read(c, buf + *have, cap - 1 - *have);
        if (n <= 0) return -1;
        *have += n;
    }
    size_t hlen = end - buf + 4;
    char *line_end = strstr(buf, "\r\n"), target[12288] = {0};
    *line_end = 0;
    if (sscanf(buf, "%15s %12287s", q->method, target) != 2) return -1;
    *line_end = '\r';
    char *qs = strchr(target, '?');
    if (qs) *qs++ = 0;
    snprintf(q->path, sizeof q->path, "%s", target);
    snprintf(q->raw, sizeof q->raw, "%s", target);
    snprintf(q->query, sizeof q->query, "%s", qs ? qs : "");
    long clen = 0;
    int expect = 0;
    q->token[0] = q->host[0] = 0;
    q->range_start = q->range_end = -1;
    for (char *h = strstr(buf, "\r\n") + 2; h < end;) {
        char *e2 = strstr(h, "\r\n");
        if (!e2) break;
        *e2 = 0;
        if (!strncasecmp(h, "Content-Length:", 15)) clen = atol(h + 15);
        else if (!strncasecmp(h, "Expect:", 7) && strcasestr(h, "100-continue")) expect = 1;
        else if (!strncasecmp(h, "Access-Token:", 13)) snprintf(q->token, sizeof q->token, "%s", h + 13 + strspn(h + 13, " "));
        else if (!strncasecmp(h, "Authorization:", 14) && !q->token[0]) {
            const char *v = h + 14 + strspn(h + 14, " ");
            snprintf(q->token, sizeof q->token, "%s", strncmp(v, "Bearer ", 7) ? v : v + 7);
        } else if (!strncasecmp(h, "Range:", 6)) {
            const char *v = strstr(h, "bytes=");
            if (v) {
                q->range_start = strtol(v + 6, NULL, 10);
                const char *dash = strchr(v, '-');
                q->range_end = dash && isdigit((unsigned char)dash[1]) ? strtol(dash + 1, NULL, 10) : -1;
            }
        } else if (!strncasecmp(h, "Host:", 5)) snprintf(q->host, sizeof q->host, "%s", h + 5 + strspn(h + 5, " "));
        *e2 = '\r';
        h = e2 + 2;
    }
    if (expect && clen > 0 && *have == hlen) c_write(c, "HTTP/1.1 100 Continue\r\n\r\n", 25);
    q->body = malloc(clen + 1);
    q->blen = clen;
    size_t got = *have - hlen < (size_t)clen ? *have - hlen : (size_t)clen;
    memcpy(q->body, buf + hlen, got);
    while ((long)got < clen) {
        int n = c_read(c, q->body + got, clen - got);
        if (n <= 0) { free(q->body); return -1; }
        got += n;
    }
    q->body[clen] = 0;
    size_t used = hlen + (*have - hlen < (size_t)clen ? *have - hlen : (size_t)clen);
    memmove(buf, buf + used, *have - used);
    *have -= used;

    static const int MAXSEG = 16;
    q->nseg = 0;
    char *p = q->path;
    while (*p == '/') p++;
    while (*p && q->nseg < MAXSEG) {
        q->seg[q->nseg++] = p;
        char *s = strchr(p, '/');
        if (!s) break;
        *s = 0;
        p = s + 1;
    }
    for (int i = 0; i < q->nseg; i++) url_decode(q->seg[i]);
    if (!q->token[0]) {
        char *t = form_get(q->query, strlen(q->query), "access_token", NULL);
        if (!t) t = form_get(q->body, q->blen, "access_token", NULL);
        if (t) snprintf(q->token, sizeof q->token, "%s", t);
        free(t);
    }
    return 0;
}

static mbedtls_ssl_config g_conf;
static mbedtls_x509_crt g_cert;
static mbedtls_pk_context g_key;
static mbedtls_entropy_context g_entropy;
static mbedtls_ctr_drbg_context g_drbg;

static pthread_mutex_t g_tls_lock = PTHREAD_MUTEX_INITIALIZER, g_rng_lock = PTHREAD_MUTEX_INITIALIZER;

static int locked_rng(void *p, unsigned char *out, size_t n) {
    pthread_mutex_lock(&g_rng_lock);
    int r = mbedtls_ctr_drbg_random(p, out, n);
    pthread_mutex_unlock(&g_rng_lock);
    return r;
}

static int net_send(void *ctx, const unsigned char *b, size_t n) {
    int r = (int)send(*(int *)ctx, b, n, 0);
    return r < 0 ? (errno == EINTR ? MBEDTLS_ERR_SSL_WANT_WRITE : MBEDTLS_ERR_NET_SEND_FAILED) : r;
}

static int net_recv(void *ctx, unsigned char *b, size_t n) {
    int r = (int)recv(*(int *)ctx, b, n, 0);
    if (r == 0) return MBEDTLS_ERR_NET_CONN_RESET;
    return r < 0 ? (errno == EINTR ? MBEDTLS_ERR_SSL_WANT_READ : MBEDTLS_ERR_NET_RECV_FAILED) : r;
}

static void *serve_conn(void *arg) {
    conn_t *c = arg;
    mbedtls_ssl_context ssl;
    unsigned char first = 0;
    int tls = c->port == TLS_PORT || (recv(c->fd, &first, 1, MSG_PEEK) == 1 && first == 0x16);
    if (tls) {
        mbedtls_ssl_init(&ssl);
        if (mbedtls_ssl_setup(&ssl, &g_conf)) goto done;
        mbedtls_ssl_set_bio(&ssl, &c->fd, net_send, net_recv, NULL);
        int r;
        struct pollfd pf = {c->fd, POLLIN, 0};
        if (poll(&pf, 1, 30000) <= 0) goto done;
        pthread_mutex_lock(&g_tls_lock);
        while ((r = mbedtls_ssl_handshake(&ssl)) == MBEDTLS_ERR_SSL_WANT_READ || r == MBEDTLS_ERR_SSL_WANT_WRITE) {}
        pthread_mutex_unlock(&g_tls_lock);
        if (r) {
            LOGE("tls handshake failed -0x%04x (alert %d)\n", -r, r == MBEDTLS_ERR_SSL_FATAL_ALERT_MESSAGE ? ssl.MBEDTLS_PRIVATE(in_msg)[1] : -1);
            goto done;
        }
        c->ssl = &ssl;
    }
    size_t cap = 65536, have = 0;
    char *buf = malloc(cap);
    for (;;) {
        req_t *q = calloc(1, sizeof *q);
        if (read_request(c, q, buf, cap, &have)) {
            if (have) LOGE("%d bad request (%zu bytes, first %02x)\n", c->port, have, (unsigned char)buf[0]);
            free(q);
            break;
        }
        resp_t r = {0};
        route(c, q, &r);
#ifdef __ANDROID__
        LOGE("%d %s %s%s%.80s -> %d", c->port, q->method, q->raw, q->query[0] ? "?" : "", q->query, r.status);
        if (!access("/sdcard/mroffline_body", F_OK) && (strstr(q->raw, "identity") || strstr(q->raw, "complian") || strstr(q->raw, "profile")))
            LOGE("  body %.*s | reply %.*s", (int)(q->blen < 600 ? q->blen : 600), q->body ? q->body : "", (int)(r.body.n < 600 ? r.body.n : 600), r.body.p ? r.body.p : "");
#else
#ifdef __ANDROID__
        LOGE("%d %s %s%s%.80s -> %d", c->port, q->method, q->raw, q->query[0] ? "?" : "", q->query, r.status);
        if (!access("/sdcard/mroffline_body", F_OK) && (strstr(q->raw, "identity") || strstr(q->raw, "complian") || strstr(q->raw, "profile")))
            LOGE("  body %.*s | reply %.*s", (int)(q->blen < 600 ? q->blen : 600), q->body ? q->body : "", (int)(r.body.n < 600 ? r.body.n : 600), r.body.p ? r.body.p : "");
#else
#ifdef __ANDROID__
        LOGE("%d %s %s%s%.80s -> %d", c->port, q->method, q->raw, q->query[0] ? "?" : "", q->query, r.status);
        if (!access("/sdcard/mroffline_body", F_OK) && (strstr(q->raw, "identity") || strstr(q->raw, "complian") || strstr(q->raw, "profile")))
            LOGE("  body %.*s | reply %.*s", (int)(q->blen < 600 ? q->blen : 600), q->body ? q->body : "", (int)(r.body.n < 600 ? r.body.n : 600), r.body.p ? r.body.p : "");
#else
        if (getenv("OFFLINE_LOG")) fprintf(stderr, "%d %s %s%s%.80s -> %d\n", c->port, q->method, q->raw, q->query[0] ? "?" : "", q->query, r.status);
#endif
#endif
#endif
        send_resp(c, q, &r);
        free(q->body);
        free(q);
    }
    free(buf);
done:
    if (tls) {
        if (c->ssl) mbedtls_ssl_close_notify(&ssl);
        mbedtls_ssl_free(&ssl);
    }
    close(c->fd);
    free(c);
    return NULL;
}

static int open_listener(int port) {
    int s = socket(AF_INET, SOCK_STREAM, 0), one = 1;
    setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &one, sizeof one);
    struct sockaddr_in a = {0};
    a.sin_family = AF_INET;
    a.sin_port = htons(port + g_port_off);
    a.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    if (bind(s, (struct sockaddr *)&a, sizeof a) || listen(s, 64)) {
        LOGE("port %d: %s\n", port + g_port_off, strerror(errno));
        close(s);
        return -1;
    }
    return s;
}

static void *listen_loop(void *arg) {
    int port = (int)(intptr_t)arg, one = 1, s = -1;
    for (;;) {
        if (s < 0 && (s = open_listener(port)) < 0) { sleep(1); continue; }
        struct pollfd p = {s, POLLIN, 0};
        int ready = poll(&p, 1, 1000);
        struct sockaddr_in me;
        socklen_t ml = sizeof me;
        int type = 0;
        socklen_t tl = sizeof type;
        struct sockaddr_in peer;
        socklen_t pl = sizeof peer;
        if (getsockname(s, (struct sockaddr *)&me, &ml) || me.sin_family != AF_INET || ntohs(me.sin_port) != port + g_port_off ||
            getsockopt(s, SOL_SOCKET, SO_TYPE, &type, &tl) || type != SOCK_STREAM ||
            !getpeername(s, (struct sockaddr *)&peer, &pl)) {
            s = -1;
            continue;
        }
        if (ready <= 0 || !(p.revents & POLLIN)) continue;
        int fd = accept(s, NULL, NULL);
        if (fd < 0) { usleep(10000); continue; }
        setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &one, sizeof one);
        struct timeval tv = {30, 0};
        setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof tv);
#ifdef SO_NOSIGPIPE
        setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &one, sizeof one);
#endif
        conn_t *c = calloc(1, sizeof *c);
        c->fd = fd;
        c->port = port;
        pthread_t t;
        pthread_attr_t at;
        pthread_attr_init(&at);
        pthread_attr_setdetachstate(&at, PTHREAD_CREATE_DETACHED);
        pthread_attr_setstacksize(&at, 1 << 20);
        if (pthread_create(&t, &at, serve_conn, c)) { close(fd); free(c); }
        pthread_attr_destroy(&at);
    }
}

static char g_content[2][1024];

void offline_set_content_dirs(const char *dlc, const char *packs) {
    snprintf(g_content[0], sizeof g_content[0], "%s", dlc ? dlc : "");
    snprintf(g_content[1], sizeof g_content[1], "%s", packs ? packs : "");
}

static void clear_dir(const char *path) {
    DIR *d = opendir(path);
    if (!d) return;
    for (struct dirent *e; (e = readdir(d));) {
        if (!strcmp(e->d_name, ".") || !strcmp(e->d_name, "..")) continue;
        char p[1400];
        snprintf(p, sizeof p, "%s/%s", path, e->d_name);
        struct stat st;
        if (lstat(p, &st)) continue;
        if (S_ISDIR(st.st_mode)) { clear_dir(p); rmdir(p); } else unlink(p);
    }
    closedir(d);
}

static void content_sync(void) {
    const char *toc = NULL;
    for (int i = 0; i < g_nassets && !toc; i++) if (!strncmp(g_assets[i].name, "mnhtn_toc_", 10)) toc = g_assets[i].sha;
    if (!toc || !*g_content[0]) return;
    char mark[1200], seen[80] = "";
    snprintf(mark, sizeof mark, "%s/content_toc", g_data);
    FILE *f = fopen(mark, "r");
    if (f) { if (!fgets(seen, sizeof seen, f)) *seen = 0; fclose(f); }
    if (!strcmp(seen, toc)) return;
    for (int i = 0; i < 2; i++) if (*g_content[i]) clear_dir(g_content[i]);
    if ((f = fopen(mark, "w"))) { fputs(toc, f); fclose(f); }
}

int offline_start(const char *data_dir, const char *bundle, int is_apk) {
    static int started;
    if (started) return 0;
    started = 1;
    signal(SIGPIPE, SIG_IGN);
    snprintf(g_data, sizeof g_data, "%s", data_dir);
    snprintf(g_bundle, sizeof g_bundle, "%s", bundle);
    g_apk = is_apk;
    char parent[1100];
    snprintf(parent, sizeof parent, "%s", g_data);
    char *slash = strrchr(parent, '/');
    if (slash) { *slash = 0; mkdir(parent, 0755); }
    mkdir(g_data, 0755);
    if (g_apk) apk_index();
    load_manifest();
    content_sync();
    acct_load();
    mbedtls_ssl_config_init(&g_conf);
    mbedtls_x509_crt_init(&g_cert);
    mbedtls_pk_init(&g_key);
    mbedtls_entropy_init(&g_entropy);
    mbedtls_ctr_drbg_init(&g_drbg);
    psa_crypto_init();
    if (mbedtls_ctr_drbg_seed(&g_drbg, mbedtls_entropy_func, &g_entropy, (const unsigned char *)"mr-offline", 10) ||
        mbedtls_x509_crt_parse(&g_cert, (const unsigned char *)CERT_PEM, sizeof CERT_PEM) ||
        mbedtls_pk_parse_key(&g_key, (const unsigned char *)KEY_PEM, sizeof KEY_PEM, NULL, 0, mbedtls_ctr_drbg_random, &g_drbg) ||
        mbedtls_ssl_config_defaults(&g_conf, MBEDTLS_SSL_IS_SERVER, MBEDTLS_SSL_TRANSPORT_STREAM, MBEDTLS_SSL_PRESET_DEFAULT))
        return -1;
    mbedtls_ssl_conf_rng(&g_conf, locked_rng, &g_drbg);
    mbedtls_ssl_conf_ca_chain(&g_conf, g_cert.next, NULL);
    mbedtls_ssl_conf_max_tls_version(&g_conf, MBEDTLS_SSL_VERSION_TLS1_2);
    if (mbedtls_ssl_conf_own_cert(&g_conf, &g_cert, &g_key)) return -1;
    int ports[4] = {PLAIN_PORT, ALERTS_PORT, TLS_PORT, PAD_PORT};
    for (int i = 0; i < 4; i++) {
        pthread_t t;
        pthread_create(&t, NULL, listen_loop, (void *)(intptr_t)ports[i]);
        pthread_detach(t);
    }
    return 0;
}

#ifdef OFFLINE_MAIN
int main(int argc, char **argv) {
    if (argc < 3) { fprintf(stderr, "usage: %s <data_dir> <bundle_dir|apk> [apk]\n", argv[0]); return 1; }
    if (offline_start(argv[1], argv[2], argc > 3)) { fprintf(stderr, "start failed\n"); return 1; }
    fprintf(stderr, "offline server on %d/%d/%d, %d assets\n", PLAIN_PORT, ALERTS_PORT, TLS_PORT, g_nassets);
    for (;;) pause();
}
#endif
