# GuildRecruit735 localization — 1.0.1-TEST

**Target:** WoW Legion 7.3.5 / Interface `70300`, `GetLocale()`. Current UI source language is Russian. English translations are in `GuildRecruit735/Locale.lua`. No external libraries or unrelated add-on source.

## Supported locales

| WoW locale | GUI language |
| --- | --- |
| `ruRU` | Русский |
| `enUS`, `enGB` | English |
| Other known client locale | English fallback |
| `GetLocale()` unavailable | Русский safe fallback |

Command: `/gr735 lang ru`, `/gr735 lang en`, `/gr735 lang auto` (default). The chosen override is stored as optional account-wide `GR735DB.language` and requires **`/reload`** to rebuild all pre-existing GUI text. The command does NOT switch the client's locale; it only changes GuildRecruit735 UI strings.

The original `GR735DB` and `GR735CharDB` structures and schema versions remain unchanged. Filter IDs, titles, values and per-character switches persist identically. Player names, guild names and class/race text returned by the WHO API are untouched. User-provided templates persist verbatim across UI language changes. Placeholder names `{player}`, `{guild}`, `{level}`, `{class}` are language-neutral and must NOT be translated in stored messages. Empty templates remain empty; no forced sample text is saved.

## QA plan

1. On ruRU, `/gr735 lang auto`, `/reload`; verify mini, settings, candidate list, filters, HC mode dropdowns, template editor, tooltips, confirmation popups and no clipped strings.
2. Still on ruRU, `/gr735 lang en`, `/reload`; verify every corresponding English label, error and popup. Scan once; WHO player names remain unchanged, but UI captions and colored status labels are English.
3. Save a distinct manual Russian whisper template, then switch to English, reload and confirm that exact saved text and contact history remain untouched. Save another English template if desired, without sending unless intentionally tested.
4. `/gr735 lang ru`, `/reload`; verify Russian restored. `/gr735 lang auto`, `/reload` returns to actual client locale.
5. Optional real enUS/enGB client: auto selection chooses English. Native Lua 5.1 test in GitHub CI is planned; local texlua fixture tests both languages but is NOT a game test.

## Limitations

- Russian UI is the source for the translation dictionary, not a destructive data migration.
- Other client languages display English unless translated in future versions.
- WoW server-originated strings, NPC names, race/class name tokens and custom addon data are NOT automatically translated.
- The distinct 1.0.0 build follows the observed English GAME_TEST_005 UI sample; controlled /reload and auto locale tests remain outside the provided game evidence.
