# GuildRecruit735 1.0.2 — release notes

**WoW Legion 7.3.5 / Interface 70300** · **Build `GR735-20261015-01`** · **MIT**.

Changes since v1.0.0:

- **Level range:** valid min/max fields auto-save without needing the separate Save button; Enter, blur and closing preferences also commit. A manually selected `10–90` range is used by the next bounded WHO scan.
- **Contact history:** players already contacted by whisper or invitation are excluded from repeat candidate lists for 30 days. Contact expiry and confirmed reset are preserved.
- **Settings menus:** custom HC/action selectors replace shared Blizzard UIDropDownMenu controls as mitigation for possible protected-frame taint. **A runtime fix for `CompactRaidFrame*:Show()` has not been conclusively verified.**

**Installation:** download this release ZIP, open it, then copy the `GuildRecruit735` folder into `World of Warcraft/Interface/AddOns/`; retain your existing WTF settings.

**Verification:** the directly preceding 1.0.2-TEST candidate passed static checks, and the user confirmed successful level-range saving in-game. This stable version changes only release metadata compared with that candidate. There is no separate complete game run for the exact stable ZIP. GitHub Actions tests the exact release with native Lua 5.1, mocks and deterministic packaging. HC, x100, cross-realm WHO and protected-frame taint remain incompletely game-verified.

Original independent MIT addon, not a SuperGuildInvite fork. All outgoing invitations and whispers require a deliberate user click.
