# UI behavior and source map

Mini counters/clear/scan/list/settings and compact editor/filter controls: UI.lua. Existing statistics/model: Scanner.lua, Filters.lua and Core.lua. Independent original dock manager and complete footprint fitting: Docking.lua. No dependency or copied files from Guild Control735.

Tests: tests/test_runtime.lua contains242 existing behavioral checks per locale; tests/test_docking.lua adds339 checks for family lifecycle, independent player list, anchors, drafts, filter row scrolling and48screen/scale/edge combinations. These are offline WoW API doubles. Real user screenshots and acceptance cover observed interface/filter behavior, not full combat/HC/taint/reload coverage.
