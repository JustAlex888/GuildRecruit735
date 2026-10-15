-- GuildRecruit735. Original implementation. MIT License.
-- Target: WoW Legion 7.3.5 / Interface 70300. No SuperGuildInvite code.
GR735 = {
    VERSION = "1.0.4",
    BUILD = "GR735-20261015-04",
    currentProfile = nil,
    currentGuildKey = nil,
    selected = {},
    candidates = {},
    candidateByName = {},
    scan = { state = "idle", pending = {}, seen = {}, sendAfter = 0, lastSend = 0,
             deadline = 0, inFlight = false, partial = false, queryCount = 0 },
    hc = {active = false, requestTime = 0, partOne = false, partTwo = false,
          staged = {}, suppress = false, finish = false, hookFrame = nil},
    clock = 0,
}
local A = GR735

-- WoW Lua 5.1 string.lower covers ASCII, but not UTF-8 Cyrillic.
local UPPER = {"А","Б","В","Г","Д","Е","Ё","Ж","З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф","Х","Ц","Ч","Ш","Щ","Ъ","Ы","Ь","Э","Ю","Я"}
local LOWER = {"а","б","в","г","д","е","ё","ж","з","и","й","к","л","м","н","о","п","р","с","т","у","ф","х","ц","ч","ш","щ","ъ","ы","ь","э","ю","я"}
function A:Fold(text)
    text=string.lower(type(text)=="string" and text or "")
    for i=1,#UPPER do text=text:gsub(UPPER[i],LOWER[i]) end
    return text
end

local function NewProfile()
    return {
        hcMode = "exclude", realmId = 44, minLevel = 20, maxLevel = 110,
        activeFilters = {}, inviteMode = "invite", selectedTemplate = 1,
        templates = {"","","","","",""}, contacts = {}, excludedClasses = {},
        panelX = 0, panelY = 125, quiet = false,
    }
end

function A:Message(text)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cff69cff0<GuildRecruit735>|r "..tostring(self.T and self:T(text) or text))
    end
end

function A:Store()
    if type(GR735DB) ~= "table" then GR735DB = {} end
    if type(GR735DB.filters) ~= "table" then GR735DB.filters = {} end
    GR735DB.nextFilterId = tonumber(GR735DB.nextFilterId) or 1
    GR735DB.schema = 1
    if type(GR735CharDB) ~= "table" then GR735CharDB = {} end
    if type(GR735CharDB.profiles) ~= "table" then GR735CharDB.profiles = {} end
    GR735CharDB.schema = 1
end

function A:GuildKey()
    local realm = (GetRealmName and GetRealmName()) or "UnknownRealm"
    local guild = (GetGuildInfo and GetGuildInfo("player")) or "_NO_GUILD"
    return tostring(realm).." / "..tostring(guild)
end

function A:Profile()
    self:Store()
    local key = self:GuildKey()
    if key ~= self.currentGuildKey or not self.currentProfile then
        if type(GR735CharDB.profiles[key]) ~= "table" then
            GR735CharDB.profiles[key] = NewProfile()
        end
        self.currentProfile = GR735CharDB.profiles[key]
        self.currentGuildKey = key
    end
    local p = self.currentProfile
    if type(p.activeFilters) ~= "table" then p.activeFilters = {} end
    if type(p.contacts) ~= "table" then p.contacts = {} end
    if type(p.excludedClasses) ~= "table" then p.excludedClasses = {} end
    if type(p.templates) ~= "table" then p.templates = {"","","","","",""} end
    if p.hcMode ~= "exclude" and p.hcMode ~= "only" and p.hcMode ~= "all" then p.hcMode="exclude" end
    return p
end

function A:Clock()
    return (GetTime and GetTime()) or self.clock or 0
end

function A:WallClock()
    return (time and time()) or 0
end

function A:RealmID()
    local p = self:Profile()
    return self.liveRealmID or tonumber(p.realmId) or 44
end

function A:HasInvitePermission()
    if IsInGuild and not IsInGuild() then return false end
    if CanGuildInvite then return CanGuildInvite() == true end
    return true
end

function A:RefreshUI()
    if self.UpdateMini then self:UpdateMini() end
    if self.UpdateCandidates then self:UpdateCandidates() end
    if self.UpdateFilters then self:UpdateFilters() end
    if self.UpdateSettings then self:UpdateSettings() end
end

function A:ClearCandidates()
    self.candidates = {}
    self.candidateByName = {}
    self:RefreshUI()
end

-- UTF-8 codepoint count for display. Byte count is Lua string length (#s).
function A:UTF8Length(s)
    if type(s)~="string" then return 0 end
    local count=0
    for i=1,#s do
        local c=s:byte(i)
        if c<128 or c>=192 then count=count+1 end
    end
    return count
end

function A:Info()
    self:Message(self:T("Версия %s / %s",self.VERSION,self.BUILD))
end

-- All event routing is ours; no hooks on other add-ons, guild notes, or UWoW client code.
local driver = CreateFrame("Frame", "GR735EventDriver")
A.driver = driver
driver:RegisterEvent("ADDON_LOADED")
driver:RegisterEvent("PLAYER_LOGIN")
driver:RegisterEvent("PLAYER_GUILD_UPDATE")
driver:RegisterEvent("WHO_LIST_UPDATE")
driver:RegisterEvent("CHAT_MSG_ADDON")
driver:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == "GuildRecruit735" then A:Store() end
    elseif event == "PLAYER_LOGIN" then
        A:Store()
        A:Profile()
        if A.BuildUI then A:BuildUI() end
        if A.CreateMinimapButton then A:CreateMinimapButton() end
        A:RefreshUI()
    elseif event == "PLAYER_GUILD_UPDATE" then
        A.currentGuildKey = nil
        A:Profile()
        if A.StopScan then A:StopScan("Смена гильдии") end
        A:ClearCandidates()
        A:RefreshUI()
    elseif event == "WHO_LIST_UPDATE" then
        if A.OnWhoResult then A:OnWhoResult() end
    elseif event == "CHAT_MSG_ADDON" then
        if A.OnLadderMessage then A:OnLadderMessage(...) end
    end
end)
driver:SetScript("OnUpdate",function(_,elapsed)
    A.clock = (A.clock or 0) + (elapsed or 0)
    if A.TickLadder then A:TickLadder() end
    if A.TickScanner then A:TickScanner() end
end)
SLASH_GR7351 = "/gr735"
SLASH_GR7352 = "/guildrecruit735"
SlashCmdList["GR735"] = function(msg)
    msg = string.lower((msg or ""):match("^%s*(.-)%s*$"))
    if msg == "version" then A:Info()
    elseif msg == "scan" then if A.StartScan then A:StartScan() end
    elseif msg == "stop" then if A.StopScan then A:StopScan("Остановлено вручную") end
    elseif msg == "hc" then if A.LadderStatus then A:LadderStatus() end
    elseif msg == "filters" then if A.ShowFilterWindow then A:ShowFilterWindow() end
    elseif msg == "messages" then if A.ShowMessages then A:ShowMessages() end
    elseif msg == "minimap" then if A.ToggleMinimapButton then A:ToggleMinimapButton() end
    elseif msg == "lang" or msg:match("^lang%s+") then
        if A.SelectLanguage then A:SelectLanguage(msg:match("^lang%s*(.-)%s*$")) end
    elseif msg == "resetcontacts" then if A.ConfirmResetContacts then A:ConfirmResetContacts() end
    elseif msg == "options" or msg == "config" then if A.ShowSettings then A:ShowSettings() end
    else if A.ToggleMini then A:ToggleMini() end end
end
