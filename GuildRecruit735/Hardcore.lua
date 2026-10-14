-- UWoW optional packet observer. Implements documented wire fields independently.
local A = GR735
local H = A.hc
local function pieces(s,sep,limit)
    local result, at = {},1
    while #result < limit do
        local i,j = s:find(sep,at,true)
        if not i then result[#result+1]=s:sub(at); return result end
        result[#result+1]=s:sub(at,i-1)
        at = j+1
    end
    return nil
end
local function finalCache()
    if type(GR735CharDB) ~= "table" then GR735CharDB = {} end
    if type(GR735CharDB.ladderCache) ~= "table" then
        GR735CharDB.ladderCache = {realm=0, rows={},at=0,complete=false}
    end
    return GR735CharDB.ladderCache
end

local function enforceHidden()
    if not H.suppress then return end
    local f = _G.uLadderFrame
    if not f then return end
    if H.hookFrame ~= f and f.HookScript then
        H.hookFrame = f
        f:HookScript("OnShow",function(self)
            if H.suppress and self == _G.uLadderFrame then self:Hide() end
        end)
    end
    if f.IsShown and f:IsShown() then f:Hide() end
end

function A:StartLadder()
    self:Store()
    if self:Profile().hcMode == "all" then return true end
    H.active=true; H.requestTime=self:Clock()
    H.partOne=false;H.partTwo=false;H.partOneRows={};H.partTwoRows={};H.finish=false
    H.suppress = not (_G.uLadderFrame and _G.uLadderFrame.IsShown and _G.uLadderFrame:IsShown())
    enforceHidden()
    local sender = UnitName and UnitName("player")
    if not sender or not SendAddonMessage then H.active=false;H.suppress=false;return false end
    local ok = pcall(SendAddonMessage,"UIMSG_TO_SERVER","UIMSG_HARD_LADDER\t","WHISPER",sender)
    if not ok then H.active=false;H.suppress=false;return false end
    return true
end

function A:LadderCache()
    return finalCache()
end

function A:IsLadderMatch(name)
    if type(name) ~= "string" or name == "" then return false end
    local cache = finalCache()
    if not cache.complete or cache.realm ~= self:RealmID() then return false end
    local search = self:Fold(name)
    for _,r in ipairs(cache.rows) do
        if self:Fold(r.name)==search and r.realm==cache.realm and r.level<110 then
            return true
        end
    end
    return false
end

function A:CandidateHC(candidate)
    return self:IsLadderMatch(candidate.name) and "MATCH" or "UNKNOWN"
end

function A:AllowsHC(candidate)
    local mode = self:Profile().hcMode
    if mode == "all" then return true end
    local match = self:IsLadderMatch(candidate.name)
    if mode == "only" then return match end
    return not match
end

function A:LadderReady()
    local cache=finalCache()
    return cache.complete and cache.realm==self:RealmID()
end

function A:OnLadderMessage(prefix,msg)
    if prefix ~= "UISMSG_TO_CLIENT" or type(msg)~="string" or #msg>65536 then return end
    local fields=pieces(msg,":",210)
    if not fields then return end
    if fields[1]=="UISMSG_UCUSTOM_REALM_ID" then
        local realm=tonumber(fields[2])
        if realm and realm>=1 and realm==math.floor(realm) then self.liveRealmID=realm end
        return
    end
    if not H.active then return end
    local flag=fields[1]
    if flag~="UISMSG_HARD_LADDER_ONE" and flag~="UISMSG_HARD_LADDER_TWO"
       and flag~="UISMSG_HARD_LADDER_EMP" then return end
    enforceHidden()
    if flag=="UISMSG_HARD_LADDER_EMP" then
        GR735CharDB.ladderCache={realm=self:RealmID(),rows={},at=self:WallClock(),complete=true}
        H.active=false;H.finish=true
        return
    end
    -- Treat packet halves independently, including delayed or repeated halves.
    local buffer={}
    for k=2,#fields do
        if #buffer>=100 then break end
        local row=pieces(fields[k],"|",15)
        if row and #row>=11 then
            local name=row[2]
            local lvl,stat,realm=tonumber(row[7]),tonumber(row[10]),tonumber(row[11])
            if name and name~="" and #name<=80 and
               lvl and lvl>=1 and lvl<=110 and stat and realm and realm>=1 then
                buffer[#buffer+1]={name=name,level=lvl,state=stat,realm=realm}
            end
        end
    end
    if flag=="UISMSG_HARD_LADDER_ONE" then
        H.partOne=true
        H.partOneRows=buffer
    else
        H.partTwo=true
        H.partTwoRows=buffer
    end
    if H.partOne and H.partTwo then
        local combined={}
        for _,row in ipairs(H.partOneRows) do combined[#combined+1]=row end
        for _,row in ipairs(H.partTwoRows) do combined[#combined+1]=row end
        GR735CharDB.ladderCache={realm=self:RealmID(),rows=combined,at=self:WallClock(),complete=true}
        H.active=false;H.finish=true
    end
end

function A:TickLadder()
    if H.suppress then
        enforceHidden()
        if H.finish then H.suppress=false;H.finish=false end
    end
    if H.active and self:Clock()-H.requestTime>=15 then
        H.active=false;H.suppress=false
    end
end

function A:CancelLadder()
    H.active=false;H.suppress=false;H.finish=false
end

function A:LadderStatus()
    local c=finalCache()
    self:Message(self:T("HC: %s; мир %s; строк %d; дата %s",
       self:T(c.complete and "данные сохранены" or "неизвестно"),
       tostring(c.realm or "?"),#c.rows,tostring(c.at or "?")))
end
