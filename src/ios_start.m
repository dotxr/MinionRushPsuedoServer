#import <Foundation/Foundation.h>

int offline_start(const char *data_dir, const char *bundle, int is_apk);
void offline_set_content_dirs(const char *dlc, const char *packs);

__attribute__((constructor)) static void start(void) {
    NSString *support = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject;
    offline_set_content_dirs([support stringByAppendingPathComponent:@"dlcs"].fileSystemRepresentation, NULL);
    NSString *data = [support stringByAppendingPathComponent:[NSBundle.mainBundle.bundleIdentifier stringByAppendingString:@"/offline_server"]];
    [NSFileManager.defaultManager createDirectoryAtPath:data withIntermediateDirectories:YES attributes:nil error:nil];
    offline_start(data.fileSystemRepresentation, [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"offline"].fileSystemRepresentation, 0);
}

#import <arpa/inet.h>
#import <sys/socket.h>

static int my_connect(int fd, const struct sockaddr *sa, socklen_t len) {
    if (sa && sa->sa_family == AF_INET && len >= sizeof(struct sockaddr_in) &&
        ((const struct sockaddr_in *)sa)->sin_addr.s_addr == inet_addr("185.182.9.183")) {
        struct sockaddr_in to = *(const struct sockaddr_in *)sa;
        to.sin_port = htons(ntohs(to.sin_port) == 443 ? 18443 : 18080);
        to.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
        return connect(fd, (struct sockaddr *)&to, sizeof to);
    }
    return connect(fd, sa, len);
}

__attribute__((used)) static struct { const void *a, *b; } _ip_connect __attribute__((section("__DATA,__interpose"))) =
    {(const void *)&my_connect, (const void *)&connect};
