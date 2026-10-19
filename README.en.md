# GuildRecruit735 1.0.7 — module loading hotfix

Build GR735-20261019-02 / Legion7.3.5 / Interface70300. Prerelease.
Fixes missing RebuildCandidates and ScanDetailsText by loading eligibility/status functions through the existing Scanner.lua. Selection.lua remains a compatibility placeholder. All1.0.6 filtering features and saved settings are retained.
Reproduced the reported error by omitting Selection.lua; all798RU/EN assertions pass on Lua5.1/LuaJIT2.1 with normal and legacy file lists. Exact107game verification pending.
Fully exit WoW before replacing the addon folder; preserve WTF/SavedVariables. Restart and check /gr735 version, mini-panel, status tooltip and scanning.

--- Historical notes ---

# GuildRecruit735 1.0.6

**WoW Legion 7.3.5 / Interface 70300** · **Build GR735-20261019-01** · **MIT**

Prerelease for in-game testing. Real-client validation of the new logic is not yet confirmed.

- Reach all accepted candidates through 30-row pages; keep the 1.0.5 wheel, arrow, thumb and resize controls.
- Match world exclusions by exact suffix instead of fragments inside character names.
- Apply one eligibility check to scanning, display and manual contact. Filter changes rebuild received data and stop an active scan.
- Resolve HC and contact-history name aliases only within a known matching world.
- Validate WHO level/class replies before acceptance. Split saturated levels by native classes when supported and show remaining gaps, timeouts and limits.
- Use `/gr735 status` for scan details and `/gr735 why Name-world` for selection reasons.

Install by replacing `GuildRecruit735` with the game closed. Preserve WTF, settings, templates, filter IDs and contact history. The ZIP with `SOURCE` in its name is for developers. All invitations remain manual; public-chat advertising was not added.

Validation: 11 Lua files; 798 assertions per RU/EN run on Lua 5.1 and LuaJIT 2.1; 81 local static/package checks. Publication repeats standalone Lua 5.1 checks and verifies the exact install SHA.

No complete online coverage or delivery guarantee is claimed. Scans keep 8-second spacing, a 45-second timeout, at most 120 queries and an explicit 5000-player snapshot bound. Contact history remains 30 days from the attempted action. Historical screenshots are not new 1.0.6 evidence.

Install SHA-256: `039850dc1d81ab87f413f27bf78b88b53bd9155ef96e681be47eb40e2702174c`.

--- Historical development notes ---

# GuildRecruit735 1.0.6 — GR735-20261019-01

Private Drive game-test candidate; no GitHub release changed.

All accepted candidates are reachable via30-row pages. World suffix exclusions are exact; scan/view/manual contact share one eligibility gate. Received WHO rows are held in a bounded memory-only snapshot and refiltered when settings change. Active scans stop on selection changes or detected competing WHO requests. HC/contact identity aliases are limited to a known same world. Level/class replies are validated atomically. Saturated levels may split by native localized classes; remaining gaps/timeouts/limits are explicitly marked incomplete.8second spacing,45second timeout,120requests and5000unique rows bound the scan. No automatic recruitment messages or invitations added.

Use `/gr735 status` for counts and `/gr735 why Name-world` for current-snapshot selection reasons. Existing settings/templates/history retained; pages preserve105wheel/thumb/resize controls. Server/nativeUI behavior and secureWHOobserver require game testing. Historical screenshots below are not106evidence.

TEST_CANDIDATE / STATIC_VERIFIED / READY_FOR_GAME_TEST; GAME_NOT_OBSERVED.

--- Previous development history ---

# 1.0.5 hotfix — GR735-20261016-01

Explicit candidate arrows, slider and mouse-wheel handlers; bottom-right resize grip; responsive row widths; refresh no longer resets window dimensions. Existing 30 displayed-candidate limit is preserved. Session-only size retention; no SavedVariables schema change.

Status: HOTFIX_CANDIDATE / STATIC_VERIFIED / GAME_RETEST_PENDING. Earlier screenshot shows 1.0.4. No GitHub publication performed for this candidate. Retest arrows, wheel over rows, thumb dragging, resizing, refresh and reopening in the WoW client.

---

# GuildRecruit735

**Version 1.0.4** · **WoW Legion 7.3.5 / Interface 70300** · **MIT**

Independent manual guild recruitment assistant with Russian and English UI. Searches and contacts are initiated deliberately by the user; no bulk or automatic invitations.

[Русский](README.md) · [Changelog](CHANGELOG.md) · [Known limitations](docs/KNOWN_LIMITATIONS.en.md)

![Compact interface, Russian client](docs/screenshots/ui-compact-russian-1.0.4.png)

User-provided screenshot from the directly tested release parent. The final 1.0.4 addon differs from that parent only in version/build metadata.

## Changes in 1.0.4

- Compact scan panel with three real counters and Clear / Scan-Stop / Show players / Settings controls.
- Settings dock below the mini panel, aligned right; messages dock below settings, filters to their right. Both children can stay open together and toggle independently.
- Settings toggle/X closes the whole dock family. Docks move together and fit the available screen. The player list stays a separate movable window.
- Names/classes filter tabs, all twelve classes, up to four visible name-filter rows with scrolling for the rest. Existing catalogue and per-character/guild flags retained. Right-click global deletion still requires confirmation.
- Six templates, explicit Save, Unicode/UTF8 counters and 255-byte validation. Variables: `{player}`, `{guild}`, `{level}`, `{class}`. Drafts survive panel switches; save explicitly before reload.
- Existing saved levels, profile keys, 30-day contact suppression, HC-UNKNOWN confirmation and deliberate whisper-before-invite behavior retained.

## Install

Close WoW. Download the **installation ZIP** from [Releases](https://github.com/JustAlex888/GuildRecruit735/releases/latest) and replace only `Interface/AddOns/GuildRecruit735`. Keep WTF. Open with the minimap button or `/gr735`; verify with `/gr735 version`. Minimap left-click toggles mini; right-click opens settings.

Commands: `/gr735 options`, `filters`, `messages`, `scan`, `stop`, `minimap`, `resetcontacts`; `/gr735 lang ru|en|auto` applies after reload.

The user accepted the interface and filters on the direct release parent. Actual screenshots show WHO results and candidates. Native Lua5.1, RU/EN fixtures and deterministic packaging are checked by CI. Full combat/taint/HC/x100/cross-realm coverage is not claimed; see [limitations](docs/KNOWN_LIMITATIONS.en.md).

Original independent MIT code. No SuperGuildInvite source, third-party addon libraries or borrowed artwork.
