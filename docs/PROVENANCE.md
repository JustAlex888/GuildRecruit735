# Provenance / independent implementation

GuildRecruit735 is written from scratch for the user's requested gameplay workflow and WoW API references. It is NOT a fork or redistribution of SuperGuildInvite.

The original SuperGuildInvite addon is labeled **All Rights Reserved** on CurseForge; its Lua, embedded libraries, images, fonts, wording and existing zip files are excluded completely.

References used as *functional facts*, not copied code:
- Standard WoW 7.3.5 Lua add-on API (event registration, frames, SavedVariables, WHO events, GuildInvite).
- UWoW custom protocol message identifiers / field positions obtained from user-authorized read-only analysis of their own server UI and prior issue reports. No cached UWoW AIO source was copied.
- User-specified UI/behavior requirements for separate HC recruit modes, filters and manual messaging.

Blizzard UI Add-On Development Policy:
https://eu.forums.blizzard.com/en/wow/t/wow-user-interface-add-on-development-policy/1642/1
SGI provenance reference (never bundled):
https://www.curseforge.com/wow/addons/superguildinvite

Version 1.0.0 has been prepared for a future authorized GitHub publication. No GitHub push, tag or Release has been performed by the preparing chat.


## 0.1.1 independent lineage

Current code is a targeted edit of **our own** `GuildRecruit735 0.1.0-TEST / GR735-20261013-01` install ZIP SHA-256 `2b79d32d9626d81e309a71ae94cbdb9aaaee0f8445bddaafd8d81e8b56c91b83`, with **zero** SuperGuildInvite source/donor paths. WoW FrameXML provides standard Blizzard templates and APIs at runtime; no third-party library assets were copied into this repository. Personal-only test until approved publication.

## 0.1.2 historical provenance

Current private test is directly derived from our own independent `0.1.1-TEST / GR735-20261013-02`, install ZIP SHA `bf48b99f4c8d335655e308c901ba61ec82d2a9790847ea2f69f7ad13a905565c`, source SHA `f73d07d503d2424659f574a5e8ba4912eae93179785053a02c849507eab65dc0`. Behavior-only visual reference: historical SGI x1.7 user-approved class colors, with NO source, images, libraries or SavedVariables copied. Current Lua remains original MIT. No GitHub publication.

## 0.1.3 provenance

Derived strictly from our own independent `0.1.2-TEST / GR735-20261013-03` install SHA256 `872e240f39e4f3409075cba43cbe299a8998ca2b04a70849269b618cc307edc2` / source SHA256 `d6f010f296e856c8c157cdd4e7e6aab0eb398d587952bf13776037df2052af58`. Provenance label `GR735_20261013_04_FROM_GR735_20261013_03_872e240f_GT003_WHISPER_MINIMAP_FONT`. New minimap module is independently authored against Blizzard WoW APIs and our user-approved UI plan; no Guild Control, SuperGuildInvite, LibDBIcon or other third-party source/assets are included.

## 0.1.4 provenance

Exact parent `GuildRecruit735 0.1.3-TEST / GR735-20261013-04`, install SHA `e9d75a14c1413610c35fe3fc84f9b01e1551a1bb33dc5535935ad0d94776e3c1`, source SHA `ea5cf488c9b1cb521e0b50f383ef3c0489ce9d5a86b74d8ff88c78e7c9e70b9e`. Provenance label `GR735_20261014_01_FROM_GR735_20261013_04_e9d75a14_NATIVE_ROUND_MINIMAP_ONLY`. ExRT, DBM, Oilvl and WeakAuras were used only as comparative functional evidence; native Blizzard texture names and a distinct original module implementation replace our old button art. Their bundled libraries, Lua, and art were not transferred.

## 0.1.5 localization provenance

Derived solely from our own exact `0.1.4-TEST / GR735-20261014-01` install ZIP (SHA256 `9057be5828d5cfb35aa95893cf19c648bc851df2017caf53f9dd5bc72d4d3c5d`), source SHA256 `4821a8b75040d0a87307e35bf15a07599b0beed8bd4becb236bacec67578cc01`. Independent RU/EN localization table and small UI/text formatting changes; WoW client API and user's existing saved data untouched. No third-party localization data copied. The following stable/public release is a **separate future** build, not a relabel of this untested translation.

## 1.0.0 exact release lineage

Own independent source `0.1.5-TEST / GR735-20261014-02` install SHA-256 `fe2c7c4a420a9d38c109544bd48856c438037922db30cff5e00aaf12cb57aef3`, source SHA-256 `c76d77b8bd1827ed106a2d21083219ab365c8cc260de915425b33b9f587a8356`. 1.0.0 build `GR735-20261014-03`, provenance `GR735_20261014_03_FROM_GR735_20261014_02_fe2c7c4a_RELEASE_1_0_0_METADATA_ONLY`. The only runtime code-file change is Core.lua VERSION/BUILD text; .toc release metadata is updated. The original game API textures remain client-supplied; no third-party code, icons, libraries, fonts or samples have been added. Screenshots are clearly labelled with the actual test build on which they were captured.
