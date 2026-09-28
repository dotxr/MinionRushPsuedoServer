#import <Foundation/Foundation.h>
#import <Security/Security.h>

#define INTERPOSE(r, o) __attribute__((used)) static struct { const void *a, *b; } _ip_##o \
    __attribute__((section("__DATA,__interpose"))) = {(const void *)&r, (const void *)&o};
#define K(x) ((__bridge NSString *)x)

static NSMutableArray<NSMutableDictionary *> *items;
static NSString *path;
static BOOL fallback;

__attribute__((constructor)) static void init(void) {
    NSDictionary *probe = @{K(kSecClass): K(kSecClassGenericPassword), K(kSecAttrService): @"kcfallback.probe",
                            K(kSecAttrAccount): @"probe", K(kSecValueData): [NSData data]};
    OSStatus r = SecItemAdd((__bridge CFDictionaryRef)probe, NULL);
    if (r == errSecSuccess || r == errSecDuplicateItem) {
        SecItemDelete((__bridge CFDictionaryRef)probe);
        return;
    }
    if (r != errSecMissingEntitlement) return;
    fallback = YES;
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject
                     stringByAppendingPathComponent:@"Preferences"];
    [NSFileManager.defaultManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    path = [dir stringByAppendingPathComponent:[NSBundle.mainBundle.bundleIdentifier stringByAppendingString:@".keychain2.plist"]];
    items = [NSMutableArray new];
    for (NSDictionary *it in [NSArray arrayWithContentsOfFile:path] ?: @[])
        [items addObject:[@{@"attrs": [it[@"attrs"] mutableCopy], @"data": it[@"data"] ?: [NSData data]} mutableCopy]];
}

static void save(void) { [items writeToFile:path atomically:YES]; }

static BOOL isAttr(NSString *k) {
    return !([k hasPrefix:@"m_"] || [k hasPrefix:@"r_"] || [k hasPrefix:@"u_"] || [k isEqual:K(kSecValueData)] ||
             [k isEqual:K(kSecValueRef)] || [k isEqual:K(kSecValuePersistentRef)] || [k isEqual:K(kSecUseDataProtectionKeychain)] ||
             [k isEqual:@"sync"] || [k isEqual:K(kSecAttrAccessible)]);
}

static NSMutableDictionary *attrsOf(NSDictionary *d) {
    NSMutableDictionary *a = [NSMutableDictionary new];
    for (NSString *k in d) if (isAttr(k)) a[k] = d[k];
    return a;
}

static BOOL matches(NSDictionary *item, NSDictionary *q) {
    NSDictionary *a = item[@"attrs"];
    for (NSString *k in q)
        if (isAttr(k) && ![a[k] isEqual:q[k]]) return NO;
    return YES;
}

static NSArray *find(NSDictionary *q) {
    return [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id it, id b) { return matches(it, q); }]];
}

static id result(NSDictionary *q, NSDictionary *item) {
    BOOL data = [q[K(kSecReturnData)] boolValue], attrs = [q[K(kSecReturnAttributes)] boolValue];
    if (!attrs) return data ? item[@"data"] : nil;
    NSMutableDictionary *d = [item[@"attrs"] mutableCopy];
    if (data) d[K(kSecValueData)] = item[@"data"];
    return d;
}

static OSStatus my_SecItemCopyMatching(CFDictionaryRef query, CFTypeRef *out) {
    if (!fallback) return SecItemCopyMatching(query, out);
    @synchronized (items) {
        NSDictionary *q = (__bridge NSDictionary *)query;
        NSArray *found = find(q);
        if (!found.count) return errSecItemNotFound;
        id r;
        if ([q[K(kSecMatchLimit)] isEqual:K(kSecMatchLimitAll)]) {
            NSMutableArray *all = [NSMutableArray new];
            for (NSDictionary *it in found) { id x = result(q, it); if (x) [all addObject:x]; }
            r = all;
        } else r = result(q, found.firstObject);
        if (out) *out = r ? CFBridgingRetain(r) : NULL;
        return errSecSuccess;
    }
}

static OSStatus my_SecItemAdd(CFDictionaryRef attributes, CFTypeRef *out) {
    if (!fallback) return SecItemAdd(attributes, out);
    @synchronized (items) {
        NSDictionary *a = (__bridge NSDictionary *)attributes;
        NSMutableDictionary *key = [NSMutableDictionary new];
        for (NSString *k in @[K(kSecClass), K(kSecAttrService), K(kSecAttrAccount), K(kSecAttrAccessGroup)])
            key[k] = a[k] ?: [NSNull null];
        for (NSDictionary *it in items) {
            BOOL same = YES;
            for (NSString *k in key) same &= [(it[@"attrs"][k] ?: [NSNull null]) isEqual:key[k]];
            if (same) return errSecDuplicateItem;
        }
        [items addObject:[@{@"attrs": attrsOf(a), @"data": a[K(kSecValueData)] ?: [NSData data]} mutableCopy]];
        save();
        if (out) *out = NULL;
        return errSecSuccess;
    }
}

static OSStatus my_SecItemUpdate(CFDictionaryRef query, CFDictionaryRef attributes) {
    if (!fallback) return SecItemUpdate(query, attributes);
    @synchronized (items) {
        NSDictionary *a = (__bridge NSDictionary *)attributes;
        NSArray *found = find((__bridge NSDictionary *)query);
        if (!found.count) return errSecItemNotFound;
        for (NSMutableDictionary *it in found) {
            [it[@"attrs"] addEntriesFromDictionary:attrsOf(a)];
            if (a[K(kSecValueData)]) it[@"data"] = a[K(kSecValueData)];
        }
        save();
        return errSecSuccess;
    }
}

static OSStatus my_SecItemDelete(CFDictionaryRef query) {
    if (!fallback) return SecItemDelete(query);
    @synchronized (items) {
        NSArray *found = find((__bridge NSDictionary *)query);
        if (!found.count) return errSecItemNotFound;
        [items removeObjectsInArray:found];
        save();
        return errSecSuccess;
    }
}

INTERPOSE(my_SecItemCopyMatching, SecItemCopyMatching)
INTERPOSE(my_SecItemAdd, SecItemAdd)
INTERPOSE(my_SecItemUpdate, SecItemUpdate)
INTERPOSE(my_SecItemDelete, SecItemDelete)
