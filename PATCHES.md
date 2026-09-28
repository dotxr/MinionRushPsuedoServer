# Patch Info

## The in-app server (`src/server.c`)

It serves eve, pandora, `/authorize`, iris `/assets`, `/data/me`, profiles, hestia config, leaderboards, the portal
scripts and `/pad`, and only listens on 127.0.0.1:
- 18080: HTTP
- 18081: alerts long-poll
- 18443: TLS
- 1808: `RevivalPacks`

On Android each build adds its own offset to those ports: 9.6.1b +0, 9.7.1b +10, 7.3.0i +20, others +30. That lets
several builds run at once. The `connect()` hook applies the offset.

Player state lives in the app's data folder. Logs go to logcat (`mroffline`) and to `<external files>/offline.log`.

`libmroffline` hooks these functions in the game lib's GOT:
- `connect()`: anything aimed at 185.182.9.183 goes to the local server.
- `getaddrinfo()` and `gethostbyname()`: every `*gameloft*` host resolves locally.
- `eglChooseConfig()`: retries without MSAA when the device has no 4x MSAA config.

The server also has:
- **Free shop:** sets every hestia `offline_store` price to 1. A price of 0 hides the item, and prices are cached in
  the save, so this only reaches a fresh install.
- **Content resync:** when the bundled TOC changes, it clears downloaded content so the game fetches it again.
- **Daily challenge:** schedules one daily challenge room per day.

## Game data
Everything is downloaded from [Minion-Rush-Cache-Archive](https://github.com/dotxr/Minion-Rush-Cache-Archive).
- `build_bundle.py` builds the data for 7.x and 9.x from the archive.
- `build_bundle_1677.py` builds it for the original client from the archive's `native-1677` folder.

The finished bundle ships in the app: `assets/offline/` in the APK (stored uncompressed), `offline/` in the .app.

What the bundle steps fix:
- **Archive gaps:** missing revisions are filled from another revision (`SUBSTITUTE`), and the hash file is rewritten
  to match.
- **One pack per item:** `merge_parts.py` folds each `<item>_2` pack into `<item>` and bumps the TOC revision. 9.x
  treats a two-pack item as not installed, which left costumes missing and rooms stuck on "downloading".
- **Room stubs:** `dlc_rooms_2_shared` and `dlc_rooms_2_winter_res` are in no archived TOC, so they're added as empty
  packs.
- **Room dates:** `dailyrooms.py` and `tools/roomdates.py` rewrite the dates in `lairlib.blibclara`, so old rooms stay
  open and each daily slot lasts one day.

## Pack loader (`revivalpacks/`) 
`RevivalPacks` replaces Play Asset Delivery. It fetches packs as zip lists from `/pad/<client>/<pack>`, and it writes
each archive to `dlcs_1/<asset>.jpk`, the only place the game looks for installed content.
- **9.x:** it fetches in the background, and prefetches the groups at start so costumes aren't checkered cubes.
- **7.x:** it fetches right away, because 7.x reads a pack before asking for it.

## Per build
- **9.6.1b and 9.7.1b:** the Play split APKs are merged. In `libDespicableMe.so` the discovery URL points at
  `127.0.0.1:18080`, and the Gaia `https://` schemes become `http://`. `libmroffline.so` is added as a DT_NEEDED.
- **7.3.0i** (Amazon 7.3.0b data):
  - `MainActivity` loads `libmroffline.so`; a DT_NEEDED breaks this lib's data segment.
  - Iris is switched to `http://`.
  - Its `api_v13` portal expects every reply wrapped as `{"body": {...}}`. A bare reply shows as "ERROR CONNECTING TO
    SERVER 115".
  - `identify_game_mode` returns `lair`, and `transfer_profile_exists` returns `false`.
  - `/authorize` echoes the requested scope.
- **5.7.0h** (original client `1677:…`):
  - Five hardcoded package-name strings are replaced.
  - Its Gaia only accepts https with no port, so it gets `https://offline.gameloft.com/...` URLs. Gameloft hosts resolve
    to 185.182.9.183, because a 127.x answer reads as offline.
  - gdid replies in JSON, and alerts long-poll.
  - The MAYA story event (and its Black Market) stays open until 2099.
- **iOS 9.6.1b:**
  - The executable's discovery URL points at `127.0.0.1:18080`, and it loads `libmroffline.dylib`.
  - The dylib interposes `connect()`.
  - It emulates the keychain in a plist when the app has no keychain entitlement.

## Rebuilding
```sh
./build.sh                                          # libmroffline for Android (arm64, armv7, x86_64, x86), iOS, macOS
python3 build_bundle.py bundle_a961 mnhtn_toc_android_603x@9.6.1b:android
python3 build_bundle.py bundle_ios mnhtn_toc_ios_904@9.6.1b:ios
python3 build_bundle_1677.py bundle_a570 5.7.0h:android
./smali_fix.sh 9.6.1b /abs/path/MinionRushRevived-9.6.1b.apk
python3 build_apk.py MinionRushRevived-9.6.1b.apk bundle_a961 MinionRushRevived-9.6.1b-offline.apk
python3 build_ipa.py MinionRushRevived-9.6.1b.ipa bundle_ios MinionRushRevived-9.6.1b-offline.ipa
```

## Saves (`tools/mrsave.c`)
`mrsave dump` decrypts `files/savegame_v2`, and `mrsave pack` writes an edited copy back.
- The file holds 5 copies of the slot. Each has a 0x200-byte header, then a record: 0xED, a flag, the encrypted
  length, the plain length, then XTEA-ECB data.
- The key is "ERROR: invalid stream" XOR-folded into 16 bytes.
- CRC32s are checked both inside the record and in the header (at +0xB0 and +0x168).
