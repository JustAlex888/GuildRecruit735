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
