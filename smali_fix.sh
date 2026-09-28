#!/bin/zsh
set -e
v=$1; apk=$2; J=${APKTOOL:?set APKTOOL to apktool.jar}; d=smali_$v
cd "$(dirname "$0")"
rm -rf $d; java -jar $J d -r -f -o $d "$apk" >/dev/null
f=$(ls $d/smali*/com/gameloft/android/ANMP/GloftDMHM/DataSharing.smali)
sed -i '' 's/const-string v6, "com.gameloft"/const-string v6, ".KeyProvider"/' $f
cp gpg_stubs/*.smali $d/smali_classes2/com/gameloft/GLSocialLib/GameAPI/
dexdir=$(echo $f | cut -d/ -f2)
java -jar $J b -o $d.apk $d >/dev/null
n=$([ $dexdir = smali ] && echo classes.dex || echo ${dexdir#smali_}.dex)
unzip -p $d.apk $n > dex_$v.dex
echo "$v: $n $(wc -c < dex_$v.dex)"
echo $n > dex_$v.name
rm -rf $d $d.apk 2>/dev/null || true
