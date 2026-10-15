-- Offline compatibility fixture for independent GuildRecruit735 implementation.
-- All WoW APIs below are explicit test doubles; NOT an in-game test.
local path=arg[1] or error("Usage: texlua test_runtime.lua <addon>")
local checks=0
local function ok(cond,msg)
    if not cond then error("FAIL: "..msg,2) end
    checks=checks+1
end
local now,epoch=500,1791900000
local requestedLocale=(arg[2]=="en" and "enUS") or "ruRU"
GetLocale=function() return requestedLocale end
GetTime=function() return now end
time=function() return epoch+math.floor(now) end
local guildName="Тестовая Гильдия"
GetGuildInfo=function(unit) return guildName end
GetRealmName=function() return "Legion x1" end
UnitName=function() return "Tester" end
IsInGuild=function() return true end
CanGuildInvite=function() return true end
InCombatLockdown=function() return false end
local frames={}
local function fakeFrame(kind,name,parent)
    local f={type=kind,name=name,parent=parent,w=0,h=0,shown=false,scripts={}}
    function f:RegisterEvent(e) self[e]=true end
    function f:UnregisterEvent(e) self[e]=nil end
    function f:IsEventRegistered(e) return self[e]==true end
    function f:RegisterForDrag(...) self.drags={...} end
    function f:RegisterForClicks(...) self.clicks={...} end
    function f:SetScript(e,func) self.scripts[e]=func end
    function f:GetScript(e) return self.scripts[e] end
    function f:SetSize(w,h) self.w=w;self.h=h end
    function f:SetFrameStrata(strata) self.strata=strata end
    function f:SetFrameLevel(level) self.frameLevel=level end
    function f:GetFrameLevel() return self.frameLevel or 1 end
    function f:GetEffectiveScale() return self.effectiveScale or 1 end
    function f:GetCenter() return self.centerX or 500,self.centerY or 500 end
    function f:SetWidth(w) self.w=w end
    function f:GetWidth() return self.w end
    function f:SetHeight(h) self.h=h end
    function f:GetHeight() return self.h end
    function f:SetPoint(...) self.point={...} end
    function f:ClearAllPoints() self.point=nil end
    function f:SetBackdrop(data) self.backdrop=data end
    function f:SetBackdropColor(r,g,b,a) self.color={r,g,b,a} end
    function f:SetBackdropBorderColor(...) end
    function f:SetMovable(v) self.movable=v end
    function f:EnableMouse(v) self.mouse=v end
    function f:StartMoving() self.moving=true end
    function f:StopMovingOrSizing() self.moving=false end
    function f:Show()
        if not self.shown then
            self.shown=true
            if self.scripts.OnShow then self.scripts.OnShow(self) end
            for _,h in ipairs(self.showHooks or {}) do h(self) end
        end
    end
    function f:Hide()
        if self.shown then
            self.shown=false
            if self.scripts.OnHide then self.scripts.OnHide(self) end
            for _,h in ipairs(self.hideHooks or {}) do h(self) end
        end
    end
    function f:IsShown() return self.shown end
    function f:HookScript(e,callback)
        if e=="OnShow" then
            self.showHooks=self.showHooks or {}
            self.showHooks[#self.showHooks+1]=callback
        elseif e=="OnHide" then
            self.hideHooks=self.hideHooks or {}
            self.hideHooks[#self.hideHooks+1]=callback
        end
    end
    function f:SetScrollChild(o) self.scrollChild=o end
    function f:SetText(s)
        self.text=s or ""
        if self.type=="EditBox" and self.scripts.OnTextChanged then
            -- WoW SetText() is programmatic; its userInput argument is false.
            self.scripts.OnTextChanged(self,false)
        end
    end
    function f:GetText() return self.text or "" end
    function f:SetJustifyH(t) self.justify=t end
    function f:SetWordWrap(t) self.wrap=t end
    function f:SetAutoFocus(t) self.autofocus=t end
    function f:SetChecked(v) self.checked=v end
    function f:GetChecked() return self.checked end
    function f:SetFontObject(font) self.font=font end
    function f:GetFont() return self.fontPath or "Fonts\\FRIZQT__.TTF",self.fontSize or 12,self.fontFlags or "" end
    function f:SetFont(path,size,flags) self.fontPath=path;self.fontSize=size;self.fontFlags=flags end
    function f:GetFontString()
        if not self.fontString then self.fontString=fakeFrame("FontString",nil,self) end
        return self.fontString
    end
    function f:CreateTexture(_,_) return fakeFrame("Texture",nil,self) end
    function f:SetAllPoints(frame) self.allPoints=frame end
    function f:SetTexture(path) self.texture=path end
    function f:SetTexCoord(...) self.texcoords={...} end
    function f:SetHighlightTexture(path) self.highlight=path end
    function f:SetVertexColor(r,g,b,a) self.vertex={r,g,b,a} end
    function f:SetTextColor(r,g,b,a) self.textColor={r,g,b,a} end
    function f:GetTextHeight() return self:GetStringHeight() end
    function f:SetMaxLetters(n) self.maxletters=n end
    function f:SetMultiLine(x) self.multiline=x end
    function f:SetTextInsets(...) end
    function f:SetFocus() self.focused=true end
    function f:ClearFocus() self.focused=false end
    function f:HasFocus() return self.focused==true end
    function f:SetVerticalScroll(v) self.verticalScroll=v end
    function f:GetVerticalScroll() return self.verticalScroll or 0 end
    function f:GetStringHeight()
        local s=(self.text or ""):gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r","")
        local lineLimit=math.max(1,math.floor((self.w>0 and self.w or 500)/7))
        return math.max(1,math.ceil(#s/lineLimit))*((self.fontSize or 12)+4)
    end
    function f:CreateFontString(_,_,_) return fakeFrame("FontString",nil,self) end
    if name then _G[name]=f end
    frames[#frames+1]=f
    return f
end
CreateFrame=fakeFrame
UIParent=fakeFrame("Frame","UIParent")
Minimap=fakeFrame("Frame","Minimap",UIParent)
Minimap:SetSize(140,140)
local mouseX,mouseY=500,580
GetCursorPosition=function() return mouseX,mouseY end
UISpecialFrames={}
ChatFontNormal={}
GameTooltip={lines={}}
function GameTooltip:SetOwner() self.lines={} end
function GameTooltip:AddLine(line) self.lines[#self.lines+1]=line end
function GameTooltip:Show() self.visible=true end
function GameTooltip:Hide() self.visible=false end
RAID_CLASS_COLORS={
    DEMONHUNTER={r=163/255,g=48/255,b=201/255,colorStr="ffa330c9"},
    DRUID={colorStr="ffff7d0a"},
    HUNTER={r=170/255,g=211/255,b=114/255,colorStr="ffaaD372"}
}
-- The fixture fails if code touches global Blizzard dropdown APIs (taint candidate).
local function forbiddenDropdown() error("Blizzard shared UIDropDownMenu must not be used") end
UIDropDownMenu_SetWidth=forbiddenDropdown
UIDropDownMenu_Initialize=forbiddenDropdown
UIDropDownMenu_CreateInfo=forbiddenDropdown
UIDropDownMenu_AddButton=forbiddenDropdown
UIDropDownMenu_SetSelectedValue=forbiddenDropdown
UIDropDownMenu_SetText=forbiddenDropdown
CloseDropDownMenus=forbiddenDropdown
StaticPopupDialogs={}
SlashCmdList={}
YES="Да";CANCEL="Отмена"
DEFAULT_CHAT_FRAME={AddMessage=function() end}
local popups={}
StaticPopup_Show=function(which,display,unused,data)
    popups[#popups+1]={which=which,display=display,data=data}
end
local whoResults, whoTotal={},0
local requests, packets, invites, whispers={},{},{},{}
local outbound={}
SendWho=function(s) requests[#requests+1]=s end
GetNumWhoResults=function() return #whoResults,whoTotal end
GetWhoInfo=function(i)
    local t=whoResults[i]
    return t.name,t.guild,t.level,t.race,t.class,t.zone,t.classFile
end
SendAddonMessage=function(prefix,msg,mode,target)
    packets[#packets+1]={prefix,msg,mode,target}
end
GuildInvite=function(n) invites[#invites+1]=n;outbound[#outbound+1]="invite" end
SendChatMessage=function(txt,channel,lang,who)
    whispers[#whispers+1]={text=txt,target=who,channel=channel}
    outbound[#outbound+1]="whisper"
end
local nativeWhoUI=false
GetWhoToUI=function() return nativeWhoUI end
SetWhoToUI=function(v) nativeWhoUI=v end
FriendsFrame=fakeFrame("Frame","FriendsFrame")
FriendsFrame:RegisterEvent("WHO_LIST_UPDATE")
FriendsFrame:Hide()
local libs={"Core.lua","Locale.lua","Filters.lua","Hardcore.lua","Scanner.lua","Actions.lua","UI.lua","MinimapButton.lua"}
for _,f in ipairs(libs) do dofile(path.."/"..f) end
local A=GR735
A.driver.scripts.OnEvent(A.driver,"ADDON_LOADED","GuildRecruit735")
A.driver.scripts.OnEvent(A.driver,"PLAYER_LOGIN")
ok(not A.ui.mini:IsShown(),"mini hidden at login")
ok(A.minimapButton and A.minimapButton:IsShown(),"minimap launcher appears on login")
ok(A.minimapButton.mouse==true and #A.minimapButton.clicks==2 and
   #A.minimapButton.drags==1,"minimap real left/right clicks and dragging enabled")
ok(A.minimapButton.parent==Minimap and A.minimapButton:GetWidth()==31 and
   A.minimapButton:GetHeight()==31,"standard 31x31 circular launcher hitbox")
ok(A.minimapButton.frameLevel>Minimap:GetFrameLevel(),"minimap button above minimap")
ok(A.minimapButton.background and A.minimapButton.background.texture==
   "Interface\\Minimap\\UI-Minimap-Background" and
   A.minimapButton.background.w==20 and A.minimapButton.background.h==20,
   "round Blizzard minimap underlay is 20x20")
ok(A.minimapButton.icon and A.minimapButton.icon.texture==
   "Interface\\Icons\\INV_Misc_GroupLooking" and
   A.minimapButton.icon.w==17 and A.minimapButton.icon.h==17,
   "small classic WoW group icon replaces oversize GR text")
ok(A.minimapButton.icon.texcoords and A.minimapButton.icon.texcoords[1]==.08 and
   A.minimapButton.icon.texcoords[2]==.92,
   "group icon crops square icon edges")
ok(A.minimapButton.border and A.minimapButton.border.texture==
   "Interface\\Minimap\\MiniMap-TrackingBorder" and
   A.minimapButton.border.w==53 and A.minimapButton.border.h==53,
   "circular rim uses uncropped native atlas with transparent padding")
ok(A.minimapButton.highlight=="Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight",
   "native circular hover highlight enabled")
ok(A.minimapButton.icon.parent==A.minimapButton and
   A.minimapButton.border.parent==A.minimapButton,
   "icon and rim are non-interactive textures inside the clickable button")

ok(not A.ui.mini:IsShown(),"minimap launcher does not force main panel")
A.minimapButton.scripts.OnClick(A.minimapButton,"LeftButton")
ok(A.ui.mini:IsShown(),"minimap left click opens panel")
A.minimapButton.scripts.OnClick(A.minimapButton,"LeftButton")
ok(not A.ui.mini:IsShown(),"minimap left click closes panel")
A.minimapButton.scripts.OnClick(A.minimapButton,"RightButton")
ok(A.ui.prefs:IsShown(),"minimap right click opens settings")
ok(#invites==0 and #whispers==0,"minimap actions never contact anyone")
local originalMini=A.minimapButton
A:CreateMinimapButton()
ok(A.minimapButton==originalMini,"minimap initialization is idempotent")
A.minimapButton.scripts.OnDragStart(A.minimapButton)
ok(A.minimapButton.isDragging and A.minimapButton.scripts.OnUpdate,
   "drag starts live cursor tracking")
mouseX,mouseY=580,500
A.minimapButton.scripts.OnUpdate(A.minimapButton,0.1)
ok(GR735DB.minimap.angle<1 or GR735DB.minimap.angle>359,
   "drag computes angle in minimap effective coordinates")
-- Cursor location is expressed in physical pixels, not minimap UI units.
Minimap.effectiveScale=1.25
mouseX,mouseY=625,725
A.minimapButton.scripts.OnUpdate(A.minimapButton,0.1)
ok(GR735DB.minimap.angle>89 and GR735DB.minimap.angle<91,
   "drag correctly compensates for 125% effective minimap scale")
Minimap.effectiveScale=1
A.minimapButton.scripts.OnDragStop(A.minimapButton)
ok(A.minimapButton.scripts.OnUpdate==nil and not A.minimapButton.isDragging,
   "drag end removes live OnUpdate tracking")
A.minimapButton.scripts.OnClick(A.minimapButton,"LeftButton")
ok(not A.ui.mini:IsShown(),"drag finish does not click the launcher")
SlashCmdList.GR735("minimap")
ok(GR735DB.minimap.hidden and not A.minimapButton:IsShown(),"slash command hides minimap icon")
SlashCmdList.GR735("minimap")
ok(not GR735DB.minimap.hidden and A.minimapButton:IsShown(),"slash command restores minimap icon")
SlashCmdList.GR735("")
ok(A.ui.mini:IsShown(),"slash command opens mini")
SlashCmdList.GR735("")
ok(not A.ui.mini:IsShown(),"slash command closes mini")
ok(A.ui.state:GetText()==A:T("Ожидание сканирования"),"initial state waiting in client locale")
ok(A.ui.scanButton:GetText()==A:T("Сканирование"),"scan button in client locale")
ok(A.ui.hcDropdown.menuWidth==259,"HC dropdown actual width")
ok(A.ui.modeDropdown.menuWidth==259,"invite dropdown actual width")
ok(#UISpecialFrames>=5,"Esc registers windows")
-- Private menu controls avoid Blizzard's shared dropdown taint state.
ok(A.ui.hcDropdown.type=="Button" and A.ui.modeDropdown.type=="Button",
   "both selectors use private simple buttons, not shared Blizzard dropdowns")
ok(#A.ui.hcDropdown.choiceButtons==3 and #A.ui.modeDropdown.choiceButtons==3,
   "both selectors offer the original three choices")
A.ui.hcDropdown.scripts.OnClick(A.ui.hcDropdown)
ok(A.ui.hcDropdown.choiceMenu:IsShown(),"HC private menu opens")
A.ui.modeDropdown.scripts.OnClick(A.ui.modeDropdown)
ok(not A.ui.hcDropdown.choiceMenu:IsShown() and A.ui.modeDropdown.choiceMenu:IsShown(),
   "opening the other selector closes the previous menu")
A.ui.modeDropdown.scripts.OnClick(A.ui.modeDropdown)
ok(not A.ui.modeDropdown.choiceMenu:IsShown(),"second click closes a private menu")
A.ui.hcDropdown.scripts.OnClick(A.ui.hcDropdown)
A.ui.hcDropdown.choiceButtons[2].scripts.OnClick()
ok(A:Profile().hcMode=="only" and not A.ui.hcDropdown.choiceMenu:IsShown(),
   "HC private menu selection persists and menu closes")
ok(A.ui.hcDropdown.selected=="only","HC selector displays selected value")
A:Profile().hcMode="exclude";A:UpdateSettings()
A.ui.modeDropdown.scripts.OnClick(A.ui.modeDropdown)
A.ui.modeDropdown.choiceButtons[3].scripts.OnClick()
ok(A:Profile().inviteMode=="whisper" and not A.ui.modeDropdown.choiceMenu:IsShown(),
   "contact mode private menu selection persists")
A:Profile().inviteMode="invite";A:UpdateSettings()
A.ui.modeDropdown.scripts.OnClick(A.ui.modeDropdown)
A.ui.prefs:Hide()
ok(not A.ui.modeDropdown.choiceMenu:IsShown(),"closing settings closes private menu")
A.ui.prefs:Show()

-- GAME_TEST_006 user report: levels were editable but reopening reverted to
-- 20..110 unless explicit Save was clicked. Simulate real user text changes;
-- the mock SetText itself correctly emits userInput=false (not a keystroke).
local function userEdit(field,value)
    field:SetFocus()
    field:SetText(value)
    if field.scripts.OnTextChanged then field.scripts.OnTextChanged(field,true) end
end
ok(A.ui.minLevel.scripts.OnTextChanged and A.ui.maxLevel.scripts.OnTextChanged and
   A.ui.minLevel.scripts.OnEnterPressed and A.ui.maxLevel.scripts.OnEditFocusLost,
   "level fields actively capture user edits, Enter and focus changes")
A:ShowSettings()
userEdit(A.ui.minLevel,"10")
userEdit(A.ui.maxLevel,"90")
ok(A:Profile().minLevel==10 and A:Profile().maxLevel==90,
   "actual user typing 10..90 automatically saves the per-guild profile")
A.ui.prefs:Hide();A:ShowSettings()
ok(A.ui.minLevel:GetText()=="10" and A.ui.maxLevel:GetText()=="90",
   "closing and reopening settings shows typed 10..90 without explicit Save")
local whoRequestsBefore=#requests
A:Profile().hcMode="all"
A:StartScan();A:TickScanner()
ok(#requests==whoRequestsBefore+1 and requests[#requests]=="10-90",
   "real WHO request range uses auto-saved 10..90 rather than old 20..110")
A:StopScan("Fixture range 10..90");A:Profile().hcMode="exclude"
A:UpdateSettings()
userEdit(A.ui.minLevel,"15")
A.ui.minLevel.scripts.OnEnterPressed(A.ui.minLevel)
ok(A:Profile().minLevel==15,"pressing Enter commits a changed minimum")
userEdit(A.ui.maxLevel,"80")
A.ui.modeDropdown.scripts.OnClick(A.ui.modeDropdown)
A.ui.modeDropdown.choiceButtons[2].scripts.OnClick()
ok(A:Profile().minLevel==15 and A:Profile().maxLevel==80 and
   A.ui.minLevel:GetText()=="15" and A.ui.maxLevel:GetText()=="80",
   "selecting invitation action does not silently revert pending level edits")
A:Profile().inviteMode="invite";A:UpdateSettings()
A.ui.prefs:Hide()
A.currentGuildKey=nil;A.currentProfile=nil
A:ShowSettings()
ok(A:Profile().minLevel==15 and A:Profile().maxLevel==80 and
   A.ui.minLevel:GetText()=="15" and A.ui.maxLevel:GetText()=="80",
   "saved range persists when profile object is reconstructed (relog simulation)")
userEdit(A.ui.minLevel,"100")
ok(A:Profile().minLevel==15,"invalid minimum above maximum is rejected")
A.ui.prefs:Hide();A:ShowSettings()
ok(A.ui.minLevel:GetText()=="15" and A.ui.maxLevel:GetText()=="80",
   "invalid range does not overwrite persistent settings when window closes")
userEdit(A.ui.maxLevel,"0")
A.ui.prefs:Hide();A:ShowSettings()
ok(A:Profile().maxLevel==80 and A.ui.maxLevel:GetText()=="80",
   "zero maximum is rejected and restored")
userEdit(A.ui.realmId,"45")
A.ui.prefs:Hide();A:ShowSettings()
ok(A:Profile().realmId==45 and A.ui.realmId:GetText()=="45",
   "World ID field also saves and displays values on window reopen")
userEdit(A.ui.realmId,"44")
A.ui.minLevel:SetText("21")
A.ui.maxLevel:SetText("91")
ok(A:Profile().minLevel==15 and A:Profile().maxLevel==80,
   "programmatic SetText never saves settings without real user input")
A.ui.savePrefs.scripts.OnClick(A.ui.savePrefs)
ok(A:Profile().minLevel==21 and A:Profile().maxLevel==91,
   "original explicit Save button still commits valid search limits")
A.ui.minLevel:SetText("17")
A.ui.minLevel.scripts.OnEditFocusLost(A.ui.minLevel)
ok(A:Profile().minLevel==17,"focus-lost fallback commits a completed edit")
userEdit(A.ui.minLevel,"abc")
A.ui.minLevel.scripts.OnEscapePressed(A.ui.minLevel)
ok(A:Profile().minLevel==17 and A.ui.minLevel:GetText()=="17",
   "Escape cancels invalid input without corrupting saved profile")
userEdit(A.ui.minLevel,"20")
userEdit(A.ui.maxLevel,"110")
ok(A:Profile().minLevel==20 and A:Profile().maxLevel==110 and A:Profile().realmId==44,
   "fixture resets normal default 20..110 and HC World ID44")
A.ui.prefs:Hide();A:ShowSettings()
-- The existing WHO regression below expects its own request log to start empty.
requests={}

ok(A.ui.mini:GetWidth()==455 and A.ui.mini:GetHeight()==118,"mini panel substantially reduced")
ok(A.ui.showButton:GetWidth()==157 and A.ui.scanButton:GetWidth()==127 and
   A.ui.clearButton:GetWidth()==124,"three mini buttons fit compact panel")
ok(A.ui.list.color[4]>=.95,"candidate list opaque")
ok(A.ui.listTitle.fontSize==13 and A.ui.listCaption.fontSize==13,
   "candidate title and caption fonts enlarged by one point")
ok(A.ui.showButton:GetFontString().fontSize==13,
   "open-candidate-list button font enlarged by one point")
ok(A:Profile().hcMode=="exclude","HC excludes by default")
ok(A:Profile().minLevel==20,"minlevel 20")
ok(A:Profile().realmId==44,"default world 44")
ok(GR735DB.schema==1,"account store schema")
ok(GR735CharDB.schema==1,"char store schema")
local fOK,id=A:CreateFilter("Отсеять X7","name","plusx7")
ok(fOK,"filter created")
ok(A:GetFilter(id).needle=="plusx7","filter persists in global catalogue")
ok(not A:FilterHit({name="Max-plusx7"}),"new filter starts disabled")
A:ToggleFilter(id)
ok(A:FilterHit({name="Max-plusx7"})=="Отсеять X7","enabled name substring")
ok(not A:FilterHit({name="Max-plusx1"}),"other suffix not blocked")
ok(A:Profile().activeFilters[id]==true,"char profile activation true")
ok(A:SetClassExcluded("MAGE",true),"class checkbox stored in this profile")
ok(A:FilterHit({name="SafeName",classFile="MAGE",class="Маг"})=="Класс","class exclusion applies exact classFile")
ok(not A:FilterHit({name="SafeName",classFile="PRIEST",class="Жрец"}),"class exclusions do not cross-match")
A:SetClassExcluded("MAGE",false)
ok(not A:FilterHit({name="SafeName",classFile="MAGE"}),"class exclusion disabled")
A.ui.filterTab="classes";A:UpdateFilters()
ok(A.ui.classesArea:IsShown() and not A.ui.namesArea:IsShown(),"class tab visible")
A.ui.filterTab="names";A:UpdateFilters()
ok(A.ui.namesArea:IsShown() and not A.ui.classesArea:IsShown(),"name tab visible")
local addName,wrong=A:AddNameExclusion(" ")
ok(not addName,"blank exclusion refused")

A:UpdateFilters()
ok(A.ui.filterButtons[1].filterId==id,"filter row identity")
ok(A.ui.filterButtons[1]:GetText():find(A:T("[ВКЛ]"),1,true)~=nil,"green filter status")
A.ui.filterButtons[1].scripts.OnClick(A.ui.filterButtons[1],"RightButton")
ok(popups[#popups].which=="GR735_REMOVE_FILTER","right click confirmation only")
ok(A:GetFilter(id)~=nil,"not deleted on first right click")
local dupeOK=A:AddNameExclusion(" plusx7 ")
ok(not dupeOK,"simple exclusion rejects old duplicate by needle")
local newOK,newID=A:AddNameExclusion("ДРУГОЙ")
ok(newOK and A:GetFilter(newID).title=="Исключение по имени","simple name exclusion automatically titled")
ok(not A:FilterHit({name="другой"}),"simple exclusion starts disabled")
A:ToggleFilter(newID)
ok(A:FilterHit({name="другой"})=="Исключение по имени","simple exclusion becomes active")
A:DeleteFilter(newID)

-- Same WoW account, another character: catalogue present, activation OFF.
local firstCharacter=GR735CharDB
GR735CharDB={}
A.currentGuildKey=nil
A:Store()
local secondProfile=A:Profile()
ok(#GR735DB.filters==1,"common catalogue second character")
ok(secondProfile.activeFilters[id]~=true,"different character filter OFF")
ok(secondProfile.excludedClasses.MAGE==nil,"classes default OFF for second character")
A:ToggleFilter(id)
ok(A:Profile().activeFilters[id]==true,"second independent ON")
GR735CharDB=firstCharacter; A.currentGuildKey=nil
ok(A:Profile().activeFilters[id]==true,"first character retained ON")
guildName="Другая Гильдия";A.currentGuildKey=nil
ok(A:Profile().activeFilters[id]~=true,"other guild separate profile")
guildName="Тестовая Гильдия";A.currentGuildKey=nil
-- Hardcore wire protocol fixtures match source-documented packet fields:
-- marker, name, faction, class, race, gender, level, levelTime, totalTime, pstatus, realm.
local hc1="UISMSG_HARD_LADDER_ONE:1|HardcoreA|x|x|x|x|54|x|x|0|44"
local hc2="UISMSG_HARD_LADDER_TWO:1|HardcoreB|x|x|x|x|72|x|x|5|44"
ok(A:StartLadder(),"ladder request allowed")
ok(#packets==1 and packets[1][2]=="UIMSG_HARD_LADDER\t","known server request contract")
uLadderFrame=fakeFrame("Frame","uLadderFrame")
uLadderFrame:Hide()
A.hc.suppress=true
A:OnLadderMessage("UISMSG_TO_CLIENT",hc1)
uLadderFrame:Show()
ok(not uLadderFrame:IsShown(),"HC native frame hidden during auto request")
A:OnLadderMessage("UISMSG_TO_CLIENT",hc2)
ok(A:LadderReady(),"both HC parts persisted")
ok(A:IsLadderMatch("HardcoreA") and A:IsLadderMatch("HardcoreB"),"HC matching independent pstatus")
ok(not A:IsLadderMatch("UnknownNormal"),"ladder absence does not prove HC")
A:TickLadder()
uLadderFrame:Show()
ok(uLadderFrame:IsShown(),"manual ladder opens after request")
A:Profile().hcMode="only"
ok(A:AllowsHC({name="HardcoreA"}),"HC-only include")
ok(not A:AllowsHC({name="UnknownNormal"}),"HC-only excludes unknown")
A:Profile().hcMode="exclude"
ok(not A:AllowsHC({name="HardcoreA"}),"HC-exclude removes match")
ok(A:AllowsHC({name="UnknownNormal"}),"normal-recruitment unknown remains reviewable")
A:Profile().hcMode="all"
ok(A:AllowsHC({name="HardcoreA"}),"all permits HC")
-- Test manual WHO pass; exclude HC and plusx7 through shared filter.
A:Profile().hcMode="exclude"
A:StartScan()
A:OnLadderMessage("UISMSG_TO_CLIENT",hc1)
A:OnLadderMessage("UISMSG_TO_CLIENT",hc2)
A:TickScanner()
ok(requests[1]=="20-110","bounded broad /who query")
ok(nativeWhoUI==true,"WHO results routed to event")
ok(not FriendsFrame:IsEventRegistered("WHO_LIST_UPDATE"),"Blizzard WHO UI event is temporarily suspended")
whoResults={
 {name="HardcoreA",guild="",level=54,race="Человек",class="Воин",zone="",classFile="WARRIOR"},
 {name="UnknownNormal",guild="",level=25,race="Эльф",class="Охотник",zone="",classFile="HUNTER"},
 {name="Max-plusx7",guild="",level=60,race="Гном",class="Маг",zone="",classFile="MAGE"},
 {name="InGuild",guild="Чужая",level=65,race="Орк",class="Воин",zone="",classFile="WARRIOR"},
}
whoTotal=4
A:OnWhoResult()
ok(#A.candidates==1 and A.candidates[1].name=="UnknownNormal","who + guild + HC + shared filters")
ok(A.scan.stats.rows==4 and A.scan.stats.unguilded==3,"WHO statistics count returned and unguilded")
ok(A.scan.stats.filtered==1 and A.scan.stats.hardcore==1,"WHO statistics count excluded causes")
now=now+8.1;A:TickScanner()
ok(A.scan.state=="Завершено","scan stops after single pass")
ok(#invites==0,"no automatic invitations")
ok(#whispers==0,"no automatic whisper")
A:UpdateCandidates()
ok(A.ui.rows[1]:GetHeight()>=27,"candidate measured line-height")
ok(A.ui.rows[1].text.fontSize==14,"player class, level, name font enlarged two points")
ok(A.ui.rows[1].person==A.candidates[1],"row clicks exact candidate")
ok(not A.ui.rows[1].text:GetText():find("[?HC]",1,true),"unknown HC no longer clutters list")
A.ui.rows[1].scripts.OnEnter(A.ui.rows[1])
ok(GameTooltip.visible and GameTooltip.lines[2] and
   GameTooltip.lines[2]:find(A:T("Hardcore: статус неизвестен. При выборе в режиме исключения HC потребуется подтверждение."),1,true),"unknown HC explained via tooltip")
A.ui.rows[1].scripts.OnLeave(A.ui.rows[1])
ok(not GameTooltip.visible,"candidate tooltip closes")
-- Unknown status requires another explicit click on confirmation.
A.ui.rows[1].scripts.OnClick(A.ui.rows[1],"LeftButton")
ok(#invites==0 and #popups>=2,"unknown HC asks confirmation, no instant invite")
local confirm=popups[#popups]
ok(confirm.which=="GR735_CONFIRM_UNKNOWN","unknown popup is distinct")
StaticPopupDialogs[confirm.which].OnAccept(nil,confirm.data)
ok(#invites==1 and invites[1]=="UnknownNormal","manual click confirms invite")
ok(A:RecentContact(A.candidates[1]),"30-day contact cooldown")
ok(not A:DoContact(A.candidates[1]),"repeat contact blocked")
-- New requested workflow: WHISPER first then immediate invitation in ONE manual action.
A:ConfirmResetContacts()
local reset=popups[#popups]
ok(reset.which=="GR735_RESET_CONTACTS","contact history reset requires confirmation")
ok(A:RecentContact(A.candidates[1]),"opening reset popup does not erase cooldown")
StaticPopupDialogs[reset.which].OnAccept(nil)
ok(not A:RecentContact(A.candidates[1]),"confirmed cooldown reset only affects current profile")
A:Profile().inviteMode="invite_whisper"
A:Profile().templates[1]="Привет, {player}! Мы из {guild}."
A:Profile().selectedTemplate=1
ok(A:DoContact(A.candidates[1]),"combined contact action succeeds")
ok(#whispers==1 and #invites==2,"whisper and guild invitation both attempted")
ok(outbound[#outbound-1]=="whisper" and outbound[#outbound]=="invite",
   "whisper definitely called BEFORE GuildInvite on single manual click")
ok(whispers[1].text:find("UnknownNormal",1,true)~=nil,"template inserted player name")
ok(whispers[1].text:find("Тестовая Гильдия",1,true)~=nil,"template inserted current guild")
ok(A:RecentContact(A.candidates[1]),"combined attempt sets cooldown once")
ok(not A:DoContact(A.candidates[1]),"repeat combined contact is blocked")
A:ResetContacts()
local inviteCount,whisperCount=#invites,#whispers
local canInvite=CanGuildInvite
CanGuildInvite=function() return false end
ok(not A:DoContact(A.candidates[1]),"no invitation rights blocks mixed action")
ok(#invites==inviteCount and #whispers==whisperCount,
   "no invitation rights also blocks whisper BEFORE it starts")
CanGuildInvite=canInvite
-- A protected-call failure must not turn into a real invitation.
local originalSend=SendChatMessage
SendChatMessage=function() error("simulated local send failure") end
ok(not A:DoContact(A.candidates[1]),"local whisper failure aborts combined action")
ok(#invites==inviteCount and #whispers==whisperCount,
   "failed whisper means no invitation and no outgoing whisper")
ok(not A:RecentContact(A.candidates[1]),"failed whisper does not poison history")
SendChatMessage=originalSend
ok(A:DoContact(A.candidates[1]),"second controlled contact without system acknowledgement")
ok(#whispers==2 and #invites==3,"combined mode never waits for localized system text")
-- Confirmed test reset does not alter templates / filter state or world ID.
A:ResetContacts()
ok(A:Profile().templates[1]:find("Привет",1,true)~=nil and A:Profile().realmId==44,
   "history reset preserves template, HC world ID and other profile settings")
-- Reset must never accidentally affect a second guild's contact table.
local baseProfile=A:Profile()
baseProfile.contacts[A:Fold("FirstGuildOnly")]=A:WallClock()
guildName="Тестовая Другая Гильдия"
A.currentGuildKey=nil
local otherProfile=A:Profile()
otherProfile.contacts[A:Fold("OtherGuildOnly")]=A:WallClock()
A:ResetContacts()
ok(not otherProfile.contacts[A:Fold("OtherGuildOnly")],"other guild current history can be reset")
guildName="Тестовая Гильдия"
A.currentGuildKey=nil
ok(A:Profile()==baseProfile and baseProfile.contacts[A:Fold("FirstGuildOnly")],
   "reset did not erase a different guild's contact history")
A:ResetContacts()
-- Empty template blocks sending (never sends legacy <NO WHISPER SET>).
A:Profile().contacts={}
A:Profile().templates[1]=""
A:Profile().inviteMode="whisper"
ok(not A:DoContact(A.candidates[1]),"empty template safely blocked")
ok(#whispers==2,"no empty whisper sent")
-- UTF-8 byte limit and final expanded-message limit; spaces count as characters.
ok(A:UTF8Length("Привет мир!")==11,"Cyrillic and space count as characters")
ok(#"Привет мир!"==20,"UTF-8 byte length differs from codepoint count")
local tooLong=string.rep("Я",128)
local templateOK,templateWhy=A:ValidateTemplate(tooLong)
ok(not templateOK and templateWhy:find("255",1,true),"template rejects 256 UTF-8 bytes without truncating")
ok(A:ValidateTemplate(string.rep("Я",127)),"254 byte Cyrillic template is permitted")
A:Profile().templates[1]="Привет, {player}!\nДобро пожаловать в {guild}."
local body=A:TemplateText(A.candidates[1])
ok(body and not body:find("\n",1,true) and body:find(" Привет",1,true)==nil,
    "message newlines normalized into one outgoing whisper")
ok(body and body:find("UnknownNormal",1,true) and body:find("Тестовая Гильдия",1,true),
    "template variables expanded in final message")
A:Profile().templates[1]=string.rep("Я",124).."{player}"
local rejected,why=A:TemplateText(A.candidates[1])
ok(rejected==nil and why:find("255",1,true),"expanded variable length rejected")
A:Profile().contacts={}
ok(not A:DoContact(A.candidates[1]),"overlong expanded whisper cannot send")
ok(#whispers==2 and #invites==3,"overlong text leaves all outgoing actions untouched")
A:Profile().templates[1]=""
A:ShowMessages()
A.ui.msgbox:SetText("Привет, мир!")
A:UpdateMessageCounter()
ok(A.ui.messageCount:GetText():find(A:T("%d символов (с пробелами) | %d / 255 байт",12,21),1,true)~=nil,"live message counter includes space")
ok(A.ui.messageCount:GetText():find("21 / 255",1,true)~=nil,"live message byte counter reflects Cyrillic")
-- Simulate actual user focus/click and save, not just programmatic SetText.
ok(A.ui.msgbox.mouse==true and A.ui.messageScroll.mouse==true,
   "message editor and scroll frame receive mouse input")
A.ui.msgbox.scripts.OnMouseDown(A.ui.msgbox,"LeftButton")
ok(A.ui.msgbox:HasFocus(),"message text box gains focus on left click")
A.ui.msgbox.scripts.OnEscapePressed(A.ui.msgbox)
ok(not A.ui.msgbox:HasFocus(),"Escape releases editor focus")
A.ui.messageScroll.scripts.OnMouseDown(A.ui.messageScroll,"LeftButton")
ok(A.ui.msgbox:HasFocus(),"clicking the editor scroll area also gives text focus")
A.ui.msgbox.scripts.OnCursorChanged(A.ui.msgbox,0,-220,2,16)
ok(A.ui.messageScroll:GetVerticalScroll()>0,"typing caret scrolled into view")
A.ui.msgbox.scripts.OnCursorChanged(A.ui.msgbox,0,-5,2,16)
ok(A.ui.messageScroll:GetVerticalScroll()<=5,"scroll returns to top for first line")
for i=1,6 do
    A:Profile().selectedTemplate=i
    A:UpdateMessages()
    A.ui.msgbox.scripts.OnMouseDown(A.ui.msgbox,"LeftButton")
    A.ui.msgbox:SetText("Шаблон №"..i..": привет, {player}!")
    A.ui.saveMessage.scripts.OnClick(A.ui.saveMessage)
    ok(A:Profile().templates[i]=="Шаблон №"..i..": привет, {player}!",
       "manual text entry and save template "..i)
end
A:Profile().selectedTemplate=6
A.ui.nextTemplate.scripts.OnClick(A.ui.nextTemplate)
ok(A:Profile().selectedTemplate==1 and
   A.ui.msgbox:GetText()==A:Profile().templates[1],"next arrow loads saved template one")
A.ui.previousTemplate.scripts.OnClick(A.ui.previousTemplate)
ok(A:Profile().selectedTemplate==6 and
   A.ui.msgbox:GetText()==A:Profile().templates[6],"previous arrow loads saved template six")
A.currentGuildKey=nil
ok(A:Profile().templates[3]=="Шаблон №3: привет, {player}!",
   "saved templates survive profile re-selection")


ok(A:Fold("КОТЁНОК")=="котёнок","UTF-8 uppercase Cyrillic folds")
local yesCyr=A:CreateFilter("Тест кириллицы","name","КОТЁНОК")
ok(yesCyr,"Cyrillic filter created")
local cid=GR735DB.filters[#GR735DB.filters].id
A:ToggleFilter(cid)
ok(A:FilterHit({name="котёнок"})=="Тест кириллицы","Cyrillic case-insensitive match")
A:DeleteFilter(cid)
-- Out-of-order ladder halves must still assemble both sources.
A:StartLadder()
A:OnLadderMessage("UISMSG_TO_CLIENT",hc2)
A:OnLadderMessage("UISMSG_TO_CLIENT",hc1)
ok(A:LadderReady() and #A:LadderCache().rows==2,"out-of-order halves complete")
-- Manually pre-opened UWoW ladder must not be closed by our refresh.
uLadderFrame:Show()
ok(A:StartLadder(),"manual frame before request")
ok(not A.hc.suppress,"manual frame prevents suppression")
A:OnLadderMessage("UISMSG_TO_CLIENT",hc1)
A:OnLadderMessage("UISMSG_TO_CLIENT",hc2)
ok(uLadderFrame:IsShown(),"manual ladder remains visible")
A:StartLadder()
A:OnLadderMessage("UISMSG_TO_CLIENT","UISMSG_HARD_LADDER_EMP")
ok(A:LadderReady() and #A:LadderCache().rows==0,"EMP caches complete empty generation")
-- Ten very long localized candidate strings produce nonoverlapping visible rows.
A:ClearCandidates()
for i=1,10 do
    local person={name="ДлинныйПерсонаж"..i.."ОченьДлинныйНик",
       level=110,race="Ночная эльфийка с длинным названием",
       class="Охотница на демонов",classFile="DEMONHUNTER",hc="UNKNOWN"}
    A.candidates[i]=person
    A.candidateByName[A:Fold(person.name)]=person
end
A:ShowCandidates()
local colored=A.ui.rows[1].text:GetText()
ok(colored:find("|cffa330c9ДлинныйПерсонаж1",1,true)~=nil,
   "candidate name is proper six-digit demon hunter color")
ok(colored:find("|cffa330c9Охотница на демонов|r",1,true)~=nil,
   "candidate class uses identical color")
ok(colored:find("|r, "..A:T("ур.").." 110 Ночная эльфийка",1,true)~=nil,
   "level and race remain neutral")
ok(not colored:find("|cffFFA330C9") and not colored:find("[?HC]",1,true),
   "no alpha leakage or unknown HC suffix")
A.candidates[2].classFile="DRUID";A.candidates[2].class="Друид"
A:UpdateCandidates()
local druid=A.ui.rows[2].text:GetText()
ok(druid:find("|cfffF7d0a",1,true)==nil and druid:find("|cffff7d0a",1,true)~=nil,
   "fallback palette reads last six hex digits")
ok(druid:find("|cffff7d0aДруид|r",1,true)~=nil,
   "fallback class text uses same color")
A.candidates[3].hc="MATCH";A:UpdateCandidates()
ok(A.ui.rows[3].text:GetText():find("[HC]",1,true)~=nil,
   "confirmed HC remains visibly flagged")
local lastBottom
for i=1,10 do
    local row=A.ui.rows[i]
    local y=row.point[5]
    ok(row:GetHeight()>=row.text:GetStringHeight()+10,"measured row height "..i)
    if lastBottom then ok(y<=lastBottom-5,"row gap "..i) end
    lastBottom=y-row:GetHeight()
end
-- Bounded WHO cap: broad query splits only when 50 results are returned.
A:Profile().hcMode="all"
A:StartScan()
A:TickScanner()
ok(requests[#requests]=="20-110","second broad /who")
whoResults={}
for i=1,50 do whoResults[i]={name="Player"..i,guild="",level=22,race="Человек",class="Маг",zone="",classFile="MAGE"} end
whoTotal=50
A:OnWhoResult()
ok(#A.scan.pending==2,"50 cap creates two bounded segments")
now=now+8.1
A:TickScanner()
ok(requests[#requests]=="20-65","first cap-bisection range")
A:StopScan("Fixture stop")
ok(not A.scan.active and #A.scan.pending==0,"stop clears pending /who")
ok(nativeWhoUI==false,"WHO routing is restored")
ok(FriendsFrame:IsEventRegistered("WHO_LIST_UPDATE"),"Blizzard event restored on stop")
-- Never interfere if the player manually opened the native Friends frame.
FriendsFrame:Show()
nativeWhoUI=true
A:StartScan();A:TickScanner()
ok(FriendsFrame:IsEventRegistered("WHO_LIST_UPDATE"),"open native frame retains its events")
A:StopScan("Fixture manual UI")
ok(nativeWhoUI==true,"existing WHO routing true is preserved")
FriendsFrame:Hide();nativeWhoUI=false
-- Timeout restores both Blizzard handler and WHO destination.
A:StartScan();A:TickScanner()
ok(not FriendsFrame:IsEventRegistered("WHO_LIST_UPDATE"),"WHO handler suspended in timeout trial")
now=now+46;A:TickScanner()
ok(not A.scan.active and FriendsFrame:IsEventRegistered("WHO_LIST_UPDATE"),"timeout restores Blizzard handler")
ok(nativeWhoUI==false,"timeout restores WHO routing")

-- No automatic action from those 50 candidates, even after timer progression.
ok(#invites==3 and #whispers==2,"search does not auto-invite or whisper")

-- New 1.0.1 regression: already contacted players are excluded *during /who*.
A:Profile().hcMode="all"
local previouslyContacted="Отказавшийся"
local contactToken=A:Fold(previouslyContacted)
local contactTime=A:WallClock()
A:Profile().contacts[contactToken]=contactTime
whoResults={
    {name="ОТКАЗАВШИЙСЯ",guild="",level=64,race="Эльф",class="Маг",zone="",classFile="MAGE"},
    {name="НовыйИгрок",guild="",level=53,race="Эльф",class="Друид",zone="",classFile="DRUID"},
}
whoTotal=2
A:StartScan();A:TickScanner();A:OnWhoResult()
ok(#A.candidates==1 and A.candidates[1].name=="НовыйИгрок",
   "recent contact hidden from WHO candidates using case-folded Cyrillic name")
ok(A.scan.stats.unguilded==2 and A.scan.stats.filtered==1,
   "recent contact counted in excluded candidates, not silently lost WHO results")
A:StopScan("Fixture 30-day suppression")
now=now+30*86400-1
ok(A:RecentContact({name=previouslyContacted}),"contact still blocked immediately before 30-day deadline")
now=now+1
ok(not A:RecentContact({name=previouslyContacted}),"contact automatically expires at 30 days")
A:StartScan();A:TickScanner();A:OnWhoResult()
ok(#A.candidates==2,"expired contact appears again after new WHO search")
A:StopScan("Fixture expiration")
A:Profile().contacts[contactToken]=A:WallClock()
A:ResetContacts()
A:StartScan();A:TickScanner();A:OnWhoResult()
ok(#A.candidates==2,"explicit reset restores candidate during new WHO search")
A:StopScan("Fixture cleared history")
A:Profile().contacts[contactToken]=A:WallClock()
guildName="Тестовая Другая Гильдия"
A.currentGuildKey=nil
A:Profile().hcMode="all"
A:StartScan();A:TickScanner();A:OnWhoResult()
ok(#A.candidates==2,"30-day exclusion stays within the character/guild profile")
A:StopScan("Fixture other-guild history")
guildName="Тестовая Гильдия"
A.currentGuildKey=nil
A:Profile().contacts[contactToken]=nil


-- Deletion is shared, but performed only via accepted dialog.
A:DeleteFilter(id)
ok(A:GetFilter(id)==nil and #GR735DB.filters==0,"global filter removed intentionally")
-- No direct guild note setter allowed anywhere.
-- Localization acceptance uses BOTH ruRU and enUS executions of this same fixture.
-- It must not rewrite user templates or the shared filter text.
local expectedLanguage=(requestedLocale=="enUS") and "en" or "ru"
ok(A:Language()==expectedLanguage,"auto locale derived from WoW client")
ok(A:T("Настройки")==((expectedLanguage=="en") and "Settings" or "Настройки"),
   "settings translation matches WoW locale")
ok(A:T("Сообщение, затем приглашение")==((expectedLanguage=="en") and "Whisper, then invite" or "Сообщение, затем приглашение"),
   "mode translation matches real whisper-first implementation")
ok(A:T("Хардкор не существует") == "Хардкор не существует",
   "unknown translation falls back without a crash")
ok(A:T("Кандидатов: %d; показаны первые %d. ЛКМ — выбранное действие, массового приглашения нет.",3,3):find("3")~=nil,
   "localized candidate caption interpolates its counts")
ok(A.ui.listTitle:GetText()==A:T("Найденные игроки — выбирайте вручную"),
   "candidate window title localized")
ok(A.ui.hcDropdown.text==A:T(({exclude="Исключать HC",only="Только HC",all="Все игроки"})[A:Profile().hcMode]),"HC dropdown selection localized")
ok(A.ui.modeDropdown.text==A:T(({invite="Только приглашение",invite_whisper="Сообщение, затем приглашение",whisper="Только сообщение"})[A:Profile().inviteMode]),"contact dropdown selection localized")
local originalTemplates=A:Profile().templates[3]
local firstFilter=GR735DB.filters[1]
SlashCmdList.GR735("lang en")
ok(GR735DB.language=="en" and A:Language()=="en","English language override stored")
SlashCmdList.GR735("lang ru")
ok(GR735DB.language=="ru" and A:Language()=="ru","Russian language override stored")
SlashCmdList.GR735("lang auto")
ok(GR735DB.language=="auto" and A:Language()==expectedLanguage,"auto language override stored")
ok(A:Profile().templates[3]==originalTemplates and GR735DB.filters[1]==firstFilter,
   "language switch leaves templates and filter data unchanged")
local activeLocale=GetLocale
GetLocale=function() return "enGB" end
ok(A:Language()=="en","enGB client falls back to English translation")
GetLocale=function() return "deDE" end
ok(A:Language()=="en","non-Russian client without translations falls back to English")
GetLocale=activeLocale
ok(A:Language()==expectedLanguage,"test restores original client locale")
print("GR735 fixture PASS "..checks.." assertions")
