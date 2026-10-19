# GuildRecruit735 1.0.7 — module loading hotfix

Build GR735-20261019-02 / Legion7.3.5 / Interface70300. Prerelease.
Fixes missing RebuildCandidates and ScanDetailsText by loading eligibility/status functions through the existing Scanner.lua. Selection.lua remains a compatibility placeholder. All1.0.6 filtering features and saved settings are retained.
Reproduced the reported error by omitting Selection.lua; all798RU/EN assertions pass on Lua5.1/LuaJIT2.1 with normal and legacy file lists. Exact107game verification pending.
Fully exit WoW before replacing the addon folder; preserve WTF/SavedVariables. Restart and check /gr735 version, mini-panel, status tooltip and scanning.
