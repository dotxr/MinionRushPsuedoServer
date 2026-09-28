# MinionRushPsuedoServer

Turns old Minion Rush builds into fully offline apps. A small Gaia/iris server runs inside the app, and the game data
ships next to it. On Android a stand-in for Play Asset Delivery loads the packs, and a few patches point the game at
the local server.

## Supported versions

| Version | Platform | Status | Game data |
|---|---|---|---|
| 9.7.1b | Android | experimental | `build_bundle.py` |
| 9.6.1b | Android, iOS | experimental | `build_bundle.py` |
| 7.3.0i | Android | experimental | `build_bundle.py` (Amazon 7.3.0b set) |
| 5.7.0h | Android | buggy | `build_bundle_1677.py` |

Prebuilt APKs and IPAs are in [Minion-Rush-Revival-Builds](https://github.com/dotxr/Minion-Rush-Revival-Builds).

## Game data

All game data (TOCs, hash files and iris assets) comes from
[Minion-Rush-Cache-Archive](https://github.com/dotxr/Minion-Rush-Cache-Archive).

## Layout

- `src/`: the in-app server (C, mbedTLS, cJSON), plus the Android and iOS start-up code and connect hooks
- `revivalpacks/`: `RevivalPacks`, the Android pack loader
- `build.sh`, `build_bundle.py`, `build_bundle_1677.py`, `merge_parts.py`, `build_apk.py`, `build_ipa.py`,
  `dailyrooms.py`, `smali_fix.sh`: the build steps
- `data/`: the hestia config and the tables the bundles are built from
- `tools/`: `mrsave.c` (decrypts and re-encrypts saves), `roomdates.py`, `pad_toc.py`

What's patched in each build, and how to rebuild them, is in [PATCHES.md](PATCHES.md).
