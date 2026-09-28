#include <android/log.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <time.h>

int offline_start(const char *data_dir, const char *bundle, int is_apk);
void offline_set_content_dirs(const char *dlc, const char *packs);
extern int g_port_off;

int offline_port_off(const char *pkg) {
    return strstr(pkg, "MinionRush961") ? 0 : strstr(pkg, "MinionRushLegacy") ? 10 : strstr(pkg, "MinionRush730") ? 20 : 30;
}
void offline_hook_connect(void);

static FILE *g_log;
static char g_log_path[512];

void offline_log(const char *fmt, ...) {
    char msg[1024];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(msg, sizeof msg, fmt, ap);
    va_end(ap);
    __android_log_print(ANDROID_LOG_WARN, "mroffline", "%s", msg);
    if (!g_log && *g_log_path) g_log = fopen(g_log_path, "w");
    if (g_log) {
        char ts[16];
        time_t now = time(NULL);
        strftime(ts, sizeof ts, "%H:%M:%S", localtime(&now));
        fprintf(g_log, "%s %s%s", ts, msg, msg[0] && msg[strlen(msg) - 1] == '\n' ? "" : "\n");
        fflush(g_log);
    }
}

__attribute__((constructor)) static void start(void) {
    char pkg[256] = {0}, apk[1024] = {0}, data[512], line[1400];
    FILE *f = fopen("/proc/self/cmdline", "r");
    if (f) { fgets(pkg, sizeof pkg, f); fclose(f); }
    char *colon = strchr(pkg, ':');
    if (colon) *colon = 0;
    if (!*pkg) return;
    g_port_off = offline_port_off(pkg);
    snprintf(data, sizeof data, "/sdcard/Android/data/%s", pkg);
    mkdir(data, 0770);
    snprintf(data, sizeof data, "/sdcard/Android/data/%s/files", pkg);
    mkdir(data, 0770);
    snprintf(g_log_path, sizeof g_log_path, "/sdcard/Android/data/%s/files/offline.log", pkg);
    g_log = fopen(g_log_path, "w");
    offline_hook_connect();
    f = fopen("/proc/self/maps", "r");
    while (f && fgets(line, sizeof line, f)) {
        char *p = strstr(line, "/base.apk");
        if (p && strstr(line, pkg)) {
            char *s = strchr(line, '/');
            p[9] = 0;
            snprintf(apk, sizeof apk, "%s", s);
            break;
        }
    }
    if (f) fclose(f);
    if (!*apk) return;
    char dlc[512], packs[512];
    snprintf(dlc, sizeof dlc, "/sdcard/Android/data/%s/files/dlcs_1", pkg);
    snprintf(packs, sizeof packs, "/data/data/%s/files/revival_packs", pkg);
    offline_set_content_dirs(dlc, packs);
    snprintf(data, sizeof data, "/data/data/%s/files/offline_server", pkg);
    offline_start(data, apk, 1);
}
