# Architecture — GuildRecruit735 1.0.0 / GR735-20261014-03


Product: GuildRecruit735 **1.0.0** / GR735-20261014-03, original independent MIT-licensed Lua for WoW Legion 7.3.5 (Interface 70300). Direct parent: 0.1.5-TEST / GR735-20261014-02; original 0.1.0 baseline and intervening builds remain historical.

- `Core.lua`: account and per-character SavedVariables; guild-separated profiles; UTF-8 Cyrillic fold; event dispatcher, version commands.
- `Filters.lua`: global filter catalogue with monotonic IDs; per-character + per-guild `activeFilters` booleans; matching.
- `Hardcore.lua`: independent UWoW `CHAT_MSG_ADDON` observer and optional scan-time request. The only copied material is *knowledge of the wire-field layout* confirmed by user-provided protocol research, not any third-party code. ONE/TWO parts assemble in either order. No client AIO source modified.
- `Scanner.lua`: finite WHO batches and cap splitting; manual start/stop; only guildless WHO results; applies filter catalogue and HC mode.
- `Actions.lua`: manually triggered contact; same-click WHISPER before invitation in combined mode; local per-profile attempted-contact cooldown and explicit confirmed reset. No ack-dependent outgoing action, guild-note writes or bulk actions.
- `UI.lua`: original native-frame UI, built only from Blizzard templates, compact panel, resized candidate typography, settings, filters, confirmation popups and message editor.
- `MinimapButton.lua`: original independent clickable 31×31 launcher, scale-correct dragging, optional `GR735DB.minimap` settings and slash visibility recovery; no external addon library.

State:
- `GR735DB`: shared account catalogue of named filters, next monotonic ID.
- `GR735CharDB`: per-character `{profiles[realm/guild]}` and HC cache.
- runtime `GR735`: current scan and candidate list only, not SavedVariables.
- No external library, data export, cross-account synchronization or inter-guild member messaging.
- No SavedVariables migration from SGI. This is a clean start and does not touch the old plugin.

Important operational boundaries:
- WHO replies may be truncated or affected by other addons sending WHO queries. No request ID exists in legacy WHO_LIST_UPDATE; source doesn't claim infallible online coverage.
- HC absence in leaderboard is UNKNOWN, not NORMAL. HC-only admits positively matched level <110 rows; this isn't formal proof of a currently active HC state.
- `GuildInvite()` may require a real click/hardware event; never call it from OnUpdate, addon messages or a periodic timer.
- Auto-server HC query is UWoW-specific and may display a native ladder window; temporary passive hooks avoid a persistent lockout of manual operation. Game confirmation is still required.
- The combined action does not wait for localized invite acknowledgements: `SendChatMessage` is called first, then `GuildInvite` synchronously. Server delivery and receiving UI must be verified on a second client; `pcall` is not proof.


## 0.1.1 UI and stored-data compatibility

- `GR735DB.filters`, `GR735DB.nextFilterId`, `GR735CharDB.profiles`, `activeFilters` and both SavedVariables identities are **unchanged**.
- New `profile.excludedClasses` is an optional table of classFile tokens (true means excluded) scoped to existing character/guild profiles. No migration/deletion of old entries.
- Only simple `name` filters are newly creatable in UI. Historical `guild/realm/class` rule records are still displayed/deletable and evaluated by the old engine for backward compatibility.
- Native 7.3.5 `UIDropDownMenuTemplate` is used for the three HC and action choices; checkbox template for class exclusions.
- `Scanner` temporarily removes `WHO_LIST_UPDATE` from a hidden FriendsFrame **only if it was registered**, restores it at completion/abort/timeout, and restores previous `WhoToUI` routing. It does not overwrite Blizzard globals or change the owner's macros.
- UTF-8 editor counts codepoints for UI, Lua bytes for conservative chat length, validates final substituted text, and does not byte-truncate.
- Auto-targeted x100 cross-realm filter is **out of scope** until the real server WHO world evidence is observed.

## 0.1.2 targeted GAME_TEST_002 UX repair

- UI-only changes: smaller `GR735MiniPanel`, exact RGB `|cffRRGGBB` formatting for name/class, neutral level/race, UNKNOWN HC status shown via hover instead of every row.
- EditBox uses `EnableMouse(true)` and explicit left-click focus; scrolling area forwards click focus, caret scrolling stays bounded. Each template's save and all six navigation states are tested offline.
- No modification to `Hardcore.lua`, `Scanner.lua`, `Actions.lua`, `Filters.lua`, SavedVariables keys/schema, guild profile rules, x1 HC world ID 44 or chat actions.

## 0.1.3 GAME_TEST_003 repair and launcher

- Existing mode ID `invite_whisper` is retained in SavedVariables; its display label changes to «Сообщение, затем приглашение» to match execution order. The system-text ack wait/timer is no longer used for outgoing whispers.
- Before both calls, validates template byte length, invitation permissions and combat state. If either API throws, the UI reports only a locally attempted action. Contact history is recorded after an attempted contact, not only rejection.
- A reset button and `/gr735 resetcontacts` use a StaticPopup confirmation; only `A:Profile().contacts` is emptied. Filters, six templates, other profiles and World ID 44 are unchanged.
- Launcher is initialized on PLAYER_LOGIN after main UI; hitbox/artwork share one 32×32 button. Angle/hidden live in optional account-global `GR735DB.minimap`. Normal slash remains usable if minimap is absent.
- Candidate row font is increased by 2 Blizzard font units; captions/title by 1. Dynamic row measurement protects multiline candidates at the old WHO cap 30.

## 0.1.4 minimap-only appearance revision

Preserves manual 0.1.3 launcher behaviour and `GR735DB.minimap` storage; changes only the three Blizzard-native texture regions and 31×31 click frame size. Old square WHITE8X8 and GR text removed. Small 17×17 existing client `Interface\Icons\INV_Misc_GroupLooking` icon, native round rim/background and button highlight have no bundled asset dependencies. `GetMinimapShape` support remains future optional work; default position RADIUS=81, drag math unchanged. No third-party minmap code copied.

## Localization (0.1.5-TEST)

A separate original `Locale.lua` is loaded directly after Core.lua. Current ruRU source text is the key and English is an explicit matching dictionary. On `GetLocale()=="ruRU"` display Russian, otherwise English when the API is available, with safe Russian fallback in headless fixtures. `GR735DB.language` is an OPTIONAL `auto|ru|en` account-level preference. `/gr735 lang ru|en|auto` saves it; `/reload` rebuilds pre-created UI text. No user-authored templates/filters/names are passed to translation, no SavedVariables schema migration. All other behavior, including 30-day cooldown, WHO, Hardcore and mode action IDs, is retained from the exact 0.1.4 parent.

## Version 1.0.0 release metadata (2026-10-14)

Exact source baseline: independent own `0.1.5-TEST / GR735-20261014-02 / fe2c7c4a420a9d38c109544bd48856c438037922db30cff5e00aaf12cb57aef3`.
Build `GR735-20261014-03` changes **only** `Core.lua` version/build constants and `.toc` version/build/title; the other seven Lua files are byte-identical. A copy of the existing MIT license is shipped at `GuildRecruit735/LICENSE` in the install ZIP for redistribution completeness. The core behavior, SavedVariables keys, WHO/HC and manual contact actions remain unchanged. Offline fixtures are rerun; the new release version itself has no separate full game test.
