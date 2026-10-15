#!/usr/bin/env python3
"""Scoped validation. Does NOT claim WoW game runtime verification."""
from pathlib import Path
from zipfile import ZipFile
import subprocess,shutil,json,hashlib,re,sys
ROOT=Path(__file__).resolve().parents[1]
ADDON=ROOT/"GuildRecruit735"
DIST=ROOT/"dist"
BUILD="GR735-20261015-01"
VERSION="1.0.2"
INSTALL=DIST/f"GuildRecruit735-{VERSION}-{BUILD}.zip"
SOURCE=DIST/f"GuildRecruit735-{VERSION}-{BUILD}-SOURCE.zip"
passed=[]
def must(name,yes):
    if not yes: raise AssertionError(name)
    passed.append(name)

with ZipFile(INSTALL) as z:
    must("install ZIP CRC",z.testzip() is None)
    files={n:z.read(n) for n in z.namelist()}
    must("10 install paths including MIT",len(files)==10 and len([n for n in files if n.endswith(".lua")])==8)
    must("no extra libraries or assets",all(n.startswith("GuildRecruit735/") and
        n.split("/")[-1] in {"GuildRecruit735.toc","Core.lua","Filters.lua","Hardcore.lua",
                               "Scanner.lua","Actions.lua","UI.lua","MinimapButton.lua","Locale.lua","LICENSE"} for n in files))
    must("MIT license bundled in installation",files["GuildRecruit735/LICENSE"] == (ROOT/"LICENSE").read_bytes())
    toc=files["GuildRecruit735/GuildRecruit735.toc"].decode("utf-8-sig")
    must("Stable release title", "## Title: GuildRecruit735\n" in toc)
    paths=[x.strip() for x in toc.splitlines() if x.strip() and not x.lstrip().startswith("#")]
    must("TOC references exist",len(paths)==8 and all("GuildRecruit735/"+x in files for x in paths))
    must("Interface / version / build",all(x in toc for x in
       ["## Interface: 70300","## Version: 1.0.2","## X-Build: GR735-20261015-01",
        "## SavedVariables: GR735DB","## SavedVariablesPerCharacter: GR735CharDB"]))
    src="".join(v.decode("utf-8-sig") for k,v in files.items() if k.endswith(".lua"))
    must("no borrowed SGI globals",not re.search(r"\bSGI_|(?:LibWho|GuildShield|SGI_DATA|SGI_BACKUP|SGI_HC_Diagnostic)\b",src))
    must("no guild notes writes",not re.search(r"(?:GuildRosterSetPublicNote|GuildRosterSetOfficerNote|GuildControlSetRank|SetGuildInfoText)",src))
    must("no auto bulk invite iteration",src.count("pcall(GuildInvite,")==1)
    must("minimap new independent module", "GuildRecruit735/MinimapButton.lua" in files and
         b'CreateMinimapButton' in files["GuildRecruit735/MinimapButton.lua"])
    must("minipanel hidden on login", not re.search(r"(?m)^\s*mini:Show\(\)",files["GuildRecruit735/UI.lua"].decode("utf-8")) and "Ожидание сканирования" in src)
    must("close via ESC registered", "UISpecialFrames" in src)
    must("own isolated menus for HC and actions", "GR735HCDropdown" in src and "GR735InviteDropdown" in src and
         'd.choiceButtons={}' in src and 'd:SetScript("OnClick"' in src)
    must("legacy shared Blizzard dropdown calls completely absent",
         not re.search(r"\b(?:UIDropDownMenu_\w+|CloseDropDownMenus)\s*\(",src) and
         '"UIDropDownMenuTemplate"' not in src)
    locale=files["GuildRecruit735/Locale.lua"].decode("utf-8")
    must("new Locale.lua loaded immediately after Core",paths[:2]==["Core.lua","Locale.lua"])
    must("GetLocale and manual override without schema change", "GetLocale" in locale and
         "GR735DB.language=arg" in locale and 'msg == "lang"' in src and
         "GR735CharDB.schema = 1" in src and "GR735DB.schema = 1" in src)
    must("no automatic translation of user templates", 'p.templates[index] or ""' in src and
         "p.templates[p.selectedTemplate or 1]=raw" in src and "User-authored messages" in locale)
    must("English text coverage for user interface", len(re.findall(r'\["[^"\n]+"\]="[^"\n]+"',locale))>=130 and
         all(x in locale for x in ['"Whisper, then invite"','"Reset contact history (30 days)"',
                                '"Hardcore status of %s is unconfirmed.', '"Show players (%d)"',
                                '"%d characters (incl. spaces)']))
    must("localization no external assets", "LibStub" not in locale and "LibDataBroker" not in locale)
    must("localize candidate and error messages", 'self:T("Кандидатов: %d;' in src and
         'self:T("Подходящих: %d' in src and 'self:T("Версия %s' in src)

    must("name filter without preset example", "Исключение по имени" in src and "Пример: имя" not in src)
    must("profile-scoped class exclusions", "excludedClasses" in src and "SetClassExcluded" in src)
    must("WHO event isolation and restoration", "suspendedFriendsFrame" in src and "IsEventRegistered" in src and "restoreWhoUI" in src)
    must("WHO return/skip counters", "s.stats.unguilded" in src and "s.stats.filtered" in src)
    must("contact-history exclusion in WHO candidate acceptance",
         'self:FilterHit(person) or self:RecentContact(person)' in files["GuildRecruit735/Scanner.lua"].decode("utf-8"))
    must("level controls auto-commit valid user changes",
         'field:SetScript("OnTextChanged",function(_,userInput)' in src and
         'if userInput then commitSearchPreferences(false) end' in src)
    must("level controls commit on Enter, blur and settings dismissal",
         'field:SetScript("OnEditFocusLost",function() commitSearchPreferences(false) end)' in src and
         'field:SetScript("OnEnterPressed",function(self)' in src and
         'prefs:HookScript("OnHide",function()' in src and
         'commitSearchPreferences(true)' in src)
    must("level and World ID validation keeps 1..110 integer bounds",
         'lo<1 or lo>110 or hi<lo or hi>110 or r<1' in src and
         'lo~=math.floor(lo)' in src and 'r~=math.floor(r)' in src)
    must("level changes live in existing per-guild profile, not new database",
         'p.minLevel=lo;p.maxLevel=hi;p.realmId=r' in src and
         'GR735CharDB.profiles' in src)
    must("30-day contact reset logic preserved",
         'local COOLDOWN_SECONDS=30*86400' in src and 'profile.contacts={}' in src)
    must("no UTF-8 byte truncation", ":sub(1,256)" not in src and "ValidateTemplate" in src)
    must("final substituted message byte validation", "if #raw>255 then" in src)
    must("multiline editor and text counters", "SetMultiLine(true)" in src and "UpdateMessageCounter" in src)
    must("world and packet fields",all(k in src for k in
         ["UISMSG_HARD_LADDER_ONE","UISMSG_HARD_LADDER_TWO","UISMSG_HARD_LADDER_EMP",
          "UISMSG_UCUSTOM_REALM_ID","UIMSG_HARD_LADDER"]))
    must("HC all/exclude/only",all(k in src for k in ['"exclude"','"only"','"all"']))
    must("filter confirmation",'"GR735_REMOVE_FILTER"' in src and "RightButton" in src)
    must("account and character filters",all(k in src for k in ["GR735DB.filters","GR735CharDB.profiles","activeFilters"]))
    must("manual guild invite callback", "line:SetScript(\"OnClick\"" in src and "A:Contact(self.person)" in src)
    must("bounded /who", all(k in src for k in ["local GAP=8","local WHO_TIMEOUT=45","local MAX_QUERIES=120"]))
    must("dark UI", 'f:SetBackdropColor(.045,.035,.03,.96)' in src)
    ui=files["GuildRecruit735/UI.lua"].decode("utf-8")
    must("new compact panel 455x118", 'panel("GR735MiniPanel",455,118)' in ui)
    must("class RGB protected from alpha leakage", 'classColorEscape' in ui and
         'string.format("|cff%02x%02x%02x"' in ui and
         'c.colorStr or "ffffffff"' not in ui)
    must("same color for name and class", '..rgb..p.name.."|r, "..self:T("ур.")' in ui and
         '..rgb..p.class.."|r"' in ui)
    must("unknown HC not appended to candidate rows", '" [?HC]"' not in ui and
         'person.hc=="UNKNOWN"' in ui)
    must("editor explicitly mouse enabled", 'msgbox:EnableMouse(true)' in ui and
         'messageScroll:EnableMouse(true)' in ui)
    must("editor acquires focus on real clicks", 'msgbox:SetFocus()' in ui and
         'self:SetFocus()' in ui)
    must("caret scroll and mouse scripts", 'msgbox:SetScript("OnCursorChanged"' in ui and
         'messageScroll:SetScript("OnMouseDown"' in ui)
    must("contact history reset gated by confirmation",'GR735_RESET_CONTACTS' in src and
         'A:ResetContacts()' in src and 'StaticPopup_Show("GR735_RESET_CONTACTS")' in src)
    mini=files["GuildRecruit735/MinimapButton.lua"].decode("utf-8")
    must("native round button hitbox",'b:SetSize(31,31)' in mini and
         r'b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")' in mini)
    must("no opaque square block behind minimap icon",'WHITE8X8' not in mini and
         'CreateFontString' not in mini and 'letters:SetText' not in mini)
    must("small group emblem has safe centered crop",'INV_Misc_GroupLooking' in mini and
         'emblem:SetSize(17,17)' in mini and 'emblem:SetTexCoord(.08,.92,.08,.92)' in mini)
    must("Blizzard circular background and rim",'UI-Minimap-Background' in mini and
         'MiniMap-TrackingBorder' in mini and 'rim:SetSize(53,53)' in mini)
    must("not another borrowed icon implementation",'LibDBIcon' not in mini and
         'LibDataBroker' not in mini and 'GuildControl' not in mini)
    must("minimap click and drag lifecycle",all(x in src for x in
         ['EnableMouse(true)','RegisterForClicks("LeftButtonUp","RightButtonUp")',
          'RegisterForDrag("LeftButton")','OnDragStart','OnDragStop','OnUpdate']))
    must("whisper before manual invite and no pending system ack",'self.pendingMessage' not in src and
         src.find('pcall(SendChatMessage,message') < src.find('pcall(GuildInvite,person.name)'))
    must("candidate title and row +2pt font", 'growFont(U.listTitle,1)' in src and
         'growFont(line.text,2)' in src)
    must("six templates save callback", 'U.saveMessage=button' in ui and
         'U.nextTemplate=button' in ui and 'U.previousTemplate=button' in ui)
    must("no executable payloads",all(not x.lower().endswith((".dll",".exe",".bat",".ps1",".zip",".bak")) for x in files))
    must("new action label matches actual order",'Сообщение, затем приглашение' in src)
    must("slash recovery and reset preserved",'msg == "minimap"' in src and
         'msg == "resetcontacts"' in src)
    must("no post-5.1 syntax",not re.search(r"\bgoto\b|(?:^|\s)//|(?<![~])~(?!=)|\btable\.unpack\b",src))
    must("exact file hashes match",all(hashlib.sha256(v).digest()==hashlib.sha256((ROOT/k).read_bytes()).digest()
         for k,v in files.items()))
with ZipFile(SOURCE) as z:
    must("source ZIP CRC",z.testzip() is None)
    names=set(z.namelist())
    must("public license and docs included",all(k in names for k in
         ["README.md","README.en.md","LICENSE","CHANGELOG.md","docs/LOCALIZATION.md","docs/ARCHITECTURE.md",
          "docs/KNOWN_LIMITATIONS.md","docs/PUBLICATION_CHECKLIST.md",
          "docs/PROVENANCE.md","docs/SCREENSHOTS.md","docs/RELEASE_NOTES_RU.md","docs/RELEASE_NOTES_EN.md","docs/KNOWN_LIMITATIONS.en.md",".github/workflows/static-check.yml"]))
    must("full code is visible in source ZIP", all(k in names for k in files))
compiler=shutil.which("luac5.1")
native={"status":"BLOCKED_DEPENDENCY" if compiler is None else "PASS","files":0}
if compiler:
    for p in sorted(ADDON.glob("*.lua")):
        proc=subprocess.run([compiler,"-p",str(p)],capture_output=True,text=True)
        must("native Lua 5.1 parse "+p.name,proc.returncode==0)
        native["files"]+=1
parser=shutil.which("texluac")
parse5_3={"status":"BLOCKED_DEPENDENCY" if parser is None else "PASS","files":0}
if parser:
    for p in sorted(ADDON.glob("*.lua")):
        proc=subprocess.run([parser,"-p",str(p)],capture_output=True,text=True)
        must("Lua 5.3 parse "+p.name,proc.returncode==0)
        parse5_3["files"]+=1
runtime=shutil.which("lua5.1") or shutil.which("texlua")
assert runtime, "No Lua runtime to execute mock fixture"
fixture_results={}
for loc in ("ru","en"):
    args=[runtime,str(ROOT/"tests/test_runtime.lua"),str(ADDON)]
    if loc=="en": args.append("en")
    p=subprocess.run(args,capture_output=True,text=True)
    match=re.search(r"GR735 fixture PASS (\d+) assertions",p.stdout)
    assertions=int(match.group(1)) if match else 0
    must("mock regression "+loc+" >=200 assertions",p.returncode==0 and assertions>=200)
    fixture_results[loc]=assertions
manifest=json.loads((DIST/f"{BUILD}_MANIFEST.json").read_text())
must("manifest new install SHA",manifest["user_install"]["sha256"]==hashlib.sha256(INSTALL.read_bytes()).hexdigest())
must("manifest source SHA",manifest["source_archive"]["sha256"]==hashlib.sha256(SOURCE.read_bytes()).hexdigest())
report={"product":"GuildRecruit735","version":VERSION,"build":BUILD,
        "pass":len(passed),"fail":0,"checks":passed,
        "lua_5_1":native,"lua_5_3":parse5_3,
        "fixture":{"status":"PASS","languages":fixture_results,"runtime":runtime},
        "game":"1_0_2_TEST_LEVEL_RANGE_PASS_USER_REPORTED; EXACT_STABLE_NOT_OBSERVED","status":"STATIC_VERIFIED_WITH_LIMITATIONS / USER_REPORTED_LEVEL_PASS / TAINT_RETEST_PENDING"}
(DIST/f"{BUILD}_RESULTS.json").write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
print(json.dumps({"pass":report["pass"],"fail":report["fail"],"native_lua_5_1":native,
                 "mock_assertions":fixture_results},ensure_ascii=False))
