#define _GNU_SOURCE
#include <android/log.h>
#include <arpa/inet.h>
#include <elf.h>
#include <link.h>
#include <EGL/egl.h>
#include <netdb.h>
#include <netinet/in.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <unistd.h>

#if defined(__LP64__)
#define ELF_R_SYM ELF64_R_SYM
typedef Elf64_Rela Rel;
#define DT_RELTAB DT_RELA
#define DT_RELTABSZ DT_RELASZ
#define DT_PLT_IS_RELA 1
#else
#define ELF_R_SYM ELF32_R_SYM
typedef Elf32_Rel Rel;
#define DT_RELTAB DT_REL
#define DT_RELTABSZ DT_RELSZ
#define DT_PLT_IS_RELA 0
#endif

void offline_log(const char *fmt, ...);
static int (*real_connect)(int, const struct sockaddr *, socklen_t);
static int (*real_getaddrinfo)(const char *, const char *, const struct addrinfo *, struct addrinfo **);

extern int g_port_off;
static int local_port(int p) { return p == 18080 || p == 18081 || p == 18443 || p == 1808; }

static int hooked_connect(int fd, const struct sockaddr *sa, socklen_t len) {
    if (sa && sa->sa_family == AF_INET && len >= sizeof(struct sockaddr_in)) {
        const struct sockaddr_in *in = (const struct sockaddr_in *)sa;
        int port = ntohs(in->sin_port);
        in_addr_t a = in->sin_addr.s_addr;
        struct sockaddr_in to = *in;
        to.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
        if (a == inet_addr("185.182.9.183") || a == inet_addr("127.0.0.2")) {
            to.sin_port = htons((port == 443 ? 18443 : 18080) + g_port_off);
            offline_log("redirected connect :%d -> local", port);
            return real_connect(fd, (struct sockaddr *)&to, sizeof to);
        }
        if (a == htonl(INADDR_LOOPBACK) && local_port(port) && g_port_off) {
            to.sin_port = htons(port + g_port_off);
            return real_connect(fd, (struct sockaddr *)&to, sizeof to);
        }
        if (a != htonl(INADDR_LOOPBACK)) offline_log("connect %s:%d", inet_ntoa(in->sin_addr), port);
    }
    return real_connect(fd, sa, len);
}

static int hooked_getaddrinfo(const char *node, const char *svc, const struct addrinfo *hints, struct addrinfo **res) {
    if (node && strstr(node, "gameloft")) {
        offline_log("resolve %s -> local", node);
        return real_getaddrinfo("127.0.0.2", svc, hints, res);
    }
    if (node && strcmp(node, "127.0.0.1")) offline_log("resolve %s", node);
    return real_getaddrinfo(node, svc, hints, res);
}

static struct hostent *hooked_gethostbyname(const char *node) {
    if (node && strstr(node, "gameloft")) {
        offline_log("resolve %s -> local", node);
        return gethostbyname("185.182.9.183");
    }
    return gethostbyname(node);
}

static EGLDisplay h_eglGetDisplay(EGLNativeDisplayType d) { EGLDisplay r = eglGetDisplay(d); offline_log("egl GetDisplay(%p) = %p", d, r); return r; }
static EGLBoolean h_eglInitialize(EGLDisplay d, EGLint *a, EGLint *b) { EGLBoolean r = eglInitialize(d, a, b); offline_log("egl Initialize(%p) = %d err %x", d, r, eglGetError()); return r; }
static EGLBoolean h_eglChooseConfig(EGLDisplay d, const EGLint *at, EGLConfig *c, EGLint n, EGLint *num) {
    EGLBoolean r = eglChooseConfig(d, at, c, n, num);
    if ((!r || (num && !*num)) && at) {
        EGLint a[64];
        int k = 0;
        for (int i = 0; at[i] != EGL_NONE && k < 60; i += 2)
            if (at[i] != EGL_SAMPLE_BUFFERS && at[i] != EGL_SAMPLES) a[k++] = at[i], a[k++] = at[i + 1];
        a[k] = EGL_NONE;
        r = eglChooseConfig(d, a, c, n, num);
        offline_log("egl config without MSAA: %d", num ? *num : -1);
    }
    return r;
}
static EGLContext h_eglCreateContext(EGLDisplay d, EGLConfig c, EGLContext s, const EGLint *a) { EGLContext r = eglCreateContext(d, c, s, a); offline_log("egl CreateContext(%p, cfg %p, share %p) = %p err %x", d, c, s, r, eglGetError()); return r; }
static EGLSurface h_eglCreatePbufferSurface(EGLDisplay d, EGLConfig c, const EGLint *a) { EGLSurface r = eglCreatePbufferSurface(d, c, a); offline_log("egl CreatePbuffer(%p, cfg %p) = %p err %x", d, c, r, eglGetError()); return r; }
static EGLSurface h_eglCreateWindowSurface(EGLDisplay d, EGLConfig c, EGLNativeWindowType w, const EGLint *a) { EGLSurface r = eglCreateWindowSurface(d, c, w, a); offline_log("egl CreateWindowSurface(%p, cfg %p) = %p err %x", d, c, r, eglGetError()); return r; }
static EGLBoolean h_eglMakeCurrent(EGLDisplay d, EGLSurface a, EGLSurface b, EGLContext c) { EGLBoolean r = eglMakeCurrent(d, a, b, c); offline_log("egl MakeCurrent(%p, %p, %p, %p) = %d err %x tid %d", d, a, b, c, r, eglGetError(), gettid()); return r; }

static void *egl_hook(const char *n) {
    static const struct { const char *n; void *f; } t[] = {
        {"eglGetDisplay", h_eglGetDisplay}, {"eglInitialize", h_eglInitialize},
        {"eglCreateContext", h_eglCreateContext}, {"eglCreatePbufferSurface", h_eglCreatePbufferSurface},
        {"eglCreateWindowSurface", h_eglCreateWindowSurface}, {"eglMakeCurrent", h_eglMakeCurrent}};
    if (!strcmp(n, "eglChooseConfig")) return h_eglChooseConfig;
    if (access("/sdcard/mroffline_egl", F_OK)) return NULL;
    for (size_t i = 0; i < sizeof t / sizeof *t; i++) if (!strcmp(n, t[i].n)) return t[i].f;
    return NULL;
}

static void patch_table(ElfW(Addr) base, const Rel *rel, size_t size, const ElfW(Sym) *symtab, const char *strtab) {
    long page = sysconf(_SC_PAGESIZE);
    for (size_t i = 0; i < size / sizeof(Rel); i++) {
        const ElfW(Sym) *s = &symtab[ELF_R_SYM(rel[i].r_info)];
        const char *n = strtab + s->st_name;
        void *hook = !strcmp(n, "connect") ? (void *)hooked_connect : !strcmp(n, "getaddrinfo") ? (void *)hooked_getaddrinfo : !strcmp(n, "gethostbyname") ? (void *)hooked_gethostbyname : egl_hook(n);
        if (!hook) continue;
        void **slot = (void **)(base + rel[i].r_offset);
        mprotect((void *)((ElfW(Addr))slot & ~(page - 1)), page, PROT_READ | PROT_WRITE);
        if (*slot != hook) *slot = hook;
    }
}

static int each(struct dl_phdr_info *info, size_t sz, void *arg) {
    if (!info->dlpi_name || !strstr(info->dlpi_name, "libDespicableMe.so")) return 0;
    const ElfW(Dyn) *dyn = NULL;
    for (int i = 0; i < info->dlpi_phnum; i++)
        if (info->dlpi_phdr[i].p_type == PT_DYNAMIC) dyn = (const ElfW(Dyn) *)(info->dlpi_addr + info->dlpi_phdr[i].p_vaddr);
    if (!dyn) return 1;
    const ElfW(Sym) *symtab = NULL;
    const char *strtab = NULL;
    const Rel *jmprel = NULL, *reltab = NULL;
    size_t jmpsz = 0, relsz = 0;
    for (; dyn->d_tag != DT_NULL; dyn++) {
        switch (dyn->d_tag) {
            case DT_SYMTAB: symtab = (const ElfW(Sym) *)(info->dlpi_addr + dyn->d_un.d_ptr); break;
            case DT_STRTAB: strtab = (const char *)(info->dlpi_addr + dyn->d_un.d_ptr); break;
            case DT_JMPREL: jmprel = (const Rel *)(info->dlpi_addr + dyn->d_un.d_ptr); break;
            case DT_PLTRELSZ: jmpsz = dyn->d_un.d_val; break;
            case DT_RELTAB: reltab = (const Rel *)(info->dlpi_addr + dyn->d_un.d_ptr); break;
            case DT_RELTABSZ: relsz = dyn->d_un.d_val; break;
        }
    }
    if (!symtab || !strtab) return 1;
    if (jmprel) patch_table(info->dlpi_addr, jmprel, jmpsz, symtab, strtab);
    if (reltab) patch_table(info->dlpi_addr, reltab, relsz, symtab, strtab);
    return 1;
}

void offline_hook_connect(void) {
    real_connect = connect;
    real_getaddrinfo = getaddrinfo;
    dl_iterate_phdr(each, NULL);
}
