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
