#!/bin/zsh
set -e
cd "$(dirname "$0")"
M=mbedtls-3.6.4
[ -d $M ] || curl -sL https://github.com/Mbed-TLS/mbedtls/releases/download/$M/$M.tar.bz2 | tar xj
I=(-I$M/include -I$M/library -Isrc)
S=(src/server.c src/cJSON.c $M/library/*.c)
mkdir -p build/ios build/mac
clang -O2 -DOFFLINE_MAIN $I -o build/mac/offline_server $S -lpthread
xcrun clang -target arm64-apple-ios14.0-macabi -O2 -dynamiclib -fobjc-arc $I -framework Foundation -framework Security \
  -install_name @executable_path/Frameworks/libmroffline.dylib -o build/ios/cat.dylib src/ios_start.m src/kcfallback.m $S
vtool -set-build-version ios 11.0 14.0 -replace -output build/ios/libmroffline.dylib build/ios/cat.dylib
for fw in Foundation:C Security:A CoreFoundation:A; do
  install_name_tool -change /System/Library/Frameworks/${fw%:*}.framework/Versions/${fw#*:}/${fw%:*} \
    /System/Library/Frameworks/${fw%:*}.framework/${fw%:*} build/ios/libmroffline.dylib 2>/dev/null
done
NDK=${NDK:-$(ls -d ~/Library/Android/sdk/ndk/* | tail -1)}/toolchains/llvm/prebuilt/darwin-x86_64/bin
for t in aarch64-linux-android24:arm64-v8a armv7a-linux-androideabi24:armeabi-v7a x86_64-linux-android24:x86_64 i686-linux-android24:x86; do
  mkdir -p build/android/${t#*:}
  $NDK/${t%%:*}-clang -O2 -fPIC -shared $I -o build/android/${t#*:}/libmroffline.so src/android_start.c src/android_hook.c $S -llog -lEGL
  $NDK/llvm-strip build/android/${t#*:}/libmroffline.so
done
echo built
