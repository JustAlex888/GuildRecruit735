# Known limitations — GuildRecruit735 1.0.0

Version 1.0.0 is the **user-approved release designation**, not proof of exhaustive `GAME_VERIFIED` gameplay coverage.

- **`GAME_TEST_004` (v0.1.4)** observed the round minimap icon, left/right click behavior, manual WHO candidates and an actual received whisper plus guild invitation. The **precise recipient-side order** of whisper versus invitation popup is not verified; the receiver's chat showed the invite line above the whisper even though Lua submits WHISPER first.
- **`GAME_TEST_005` (v0.1.5)** showed all five principal GUI windows translated into English and WHO 12 results / 9 candidates. The user reported no visible localization issue. The Russian reference screenshot is from older 0.1.4; a fresh screenshot of Russian 0.1.5 and controlled language-switch/reload session were not supplied.
- The 1.0.0 release is metadata/documentation packaging derived from 0.1.5; it has **no independent full game regression run**. Offline tests are not a substitute for game tests.
- **`BLOCKED_DEPENDENCY`**: native Lua 5.1 compiler/interpreter are unavailable in the build environment. The GitHub CI workflow will parse/test Lua 5.1 when publishing.
- **`NOT_OBSERVED`**: x100, cross-realm candidate identification, exhaustive WHO completeness, all three HC paths in the live game, every Blizzard WHO restoration case, all reload/relog settings cases and all button dragging configurations.
- HC World ID **44** is a realm/world identifier for x1, **not a TCP port**. There is deliberately no guessed realm-suffix classifier for x100.
- A missing HC leaderboard entry means **UNKNOWN**, never conclusively normal. When excluding HC, unknown status requires user confirmation.
- The 255 **UTF-8 byte** outgoing-message limit is conservative; the actual server-side whisper limit has not been exhaustively verified.
- The thirty-day cooldown covers attempted contacts, not just rejected invitations; it does not sync across accounts.
- Other client languages fall back to English; the server's WHO strings and the user's own templates are not translated.

Recruitment is always manual, one candidate at a time; no mass-invite or automatic spam feature.
