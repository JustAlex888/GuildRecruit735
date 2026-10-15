# Architecture 1.0.4

Independent MIT, WoW7.3.5 / Lua5.1 / Interface70300. Core owns schema1 profile state; Locale maps client labels; Filters retains an account-wide catalogue and per-profile flags; Hardcore consumes existing ladder messages; Scanner performs one bounded manual WHO pass; Actions guards deliberate contact; MinimapButton is independent native UI.

UI.lua constructs controls. Docking.lua owns Open/Close/ToggleSettings, CloseSettingsFamily, independent child toggles and screen fitting. Native frame parents: settings→mini, messages/filters→settings; list→UIParent. Anchors: settings TOPRIGHT→mini BOTTOMRIGHT, messages TOPLEFT→settings BOTTOMLEFT, filters TOPLEFT→settings TOPRIGHT. Mini movement carries the docks; only existing panelX/panelY store mini position. One local scale and complete-footprint clamping fit the available UI; global UI settings are not modified. Hidden windows release menus/focus/tooltips.

GR735DB/GR735CharDB names, schema1, profile/filter IDs, six templates and contacts remain unchanged. Unsaved template drafts are held per profile in memory; only explicit Save persists. Clear scan and confirmed contact-history reset are separate. Native private choice menus avoid shared Blizzard dropdown globals.
