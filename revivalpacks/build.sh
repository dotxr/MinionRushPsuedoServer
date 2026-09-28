#!/bin/zsh
set -e
cd "$(dirname "$0")"
v=$1; base=$2
BT=${BT:-$(ls -d ~/Library/Android/sdk/build-tools/* | tail -1)}
rm -rf out && mkdir -p out/stub out/src out/dex out/pkg/com/google/android/play/core/assetpacks
javac --release 8 -nowarn -d out/stub $(find stub -name "*.java") 2>&1 | grep error && exit 1 || true
sed "s#@BASE@#$base#" RevivalPacks.java > out/pkg/com/google/android/play/core/assetpacks/RevivalPacks.java
javac --release 8 -nowarn -cp out/stub -d out/src out/pkg/com/google/android/play/core/assetpacks/RevivalPacks.java 2>&1 | grep -v "^warning\|^[0-9] warning" || true
$BT/d8 --min-api 21 --output out/dex out/src/com/google/android/play/core/assetpacks/*.class 2>/dev/null
cp out/dex/classes.dex ../revivalpacks_$v.dex
rm -rf out
echo "revivalpacks_$v.dex"
