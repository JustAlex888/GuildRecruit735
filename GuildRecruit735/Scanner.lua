-- GuildRecruit735: one bounded, manual WHO scan; no automatic invitations.
local A=GR735
local GAP=8
local WHO_TIMEOUT=45
local MAX_QUERIES=120
local function band(low,high) return {low=low,high=high} end
local function newStats()
    return {rows=0,unguilded=0,filtered=0,hardcore=0,duplicates=0}
end

-- Do not permanently change the user's standard Friends/WHO interface state.
local function restoreWhoUI(s)
    if s.suspendedFriendsFrame and s.suspendedFriendsFrame.RegisterEvent then
        -- Only restore an event that was registered before this scan.
        pcall(s.suspendedFriendsFrame.RegisterEvent,s.suspendedFriendsFrame,"WHO_LIST_UPDATE")
    end
    s.suspendedFriendsFrame=nil
    if s.changedWhoUI and SetWhoToUI then
        -- Older clients may not expose GetWhoToUI; false is only a fallback.
        pcall(SetWhoToUI,s.previousWhoUI~=nil and s.previousWhoUI or false)
    end
    s.changedWhoUI=false
    s.previousWhoUI=nil
end

local function isolateWhoUI(s)
    local frame=_G.FriendsFrame
    if not frame or s.suspendedFriendsFrame then return end
    if not frame.IsEventRegistered or not frame.UnregisterEvent then return end
    -- Never intervene when the user has already opened the native Friends UI.
    if frame.IsShown and frame:IsShown() then return end
    local ok,registered=pcall(frame.IsEventRegistered,frame,"WHO_LIST_UPDATE")
    if ok and registered then
        local success=pcall(frame.UnregisterEvent,frame,"WHO_LIST_UPDATE")
        if success then s.suspendedFriendsFrame=frame end
    end
end

function A:StopScan(reason)
    local s=self.scan
    s.state=reason or "Остановлено"
    s.active=false;s.inFlight=false;s.pending={};s.lastRange=nil
    self:CancelLadder()
    restoreWhoUI(s)
    self:RefreshUI()
end

function A:StartScan()
    local s=self.scan
    if s.active then self:StopScan("Остановлено вручную");return end
    local p=self:Profile()
    local lo=math.max(1,math.min(110,tonumber(p.minLevel) or 20))
    local hi=math.max(lo,math.min(110,tonumber(p.maxLevel) or 110))
    p.minLevel=lo;p.maxLevel=hi
    self:ClearCandidates()
    s.stats=newStats()
    s.active=true;s.state="wait_hc";s.partial=false;s.pending={band(lo,hi)}
    s.seen={};s.inFlight=false;s.queryCount=0
    s.lastRange=nil;s.sendAfter=self:Clock()
    s.lastSend=-10000;s.changedWhoUI=false;s.previousWhoUI=nil
    s.suspendedFriendsFrame=nil
    if p.hcMode=="all" then
        s.state="ready"
    else
        if not self:StartLadder() then
            if self:LadderReady() then
                s.state="ready"
                self:Message("HC-запрос недоступен; используется сохранённый ладдер.")
            else
                self:StopScan("HC-данные недоступны; поиск не запущен")
                return
            end
        end
    end
    self:RefreshUI()
end

local function done(s,a)
    s.active=false
    s.state=s.partial and "Завершено (неполный /who)" or "Завершено"
    restoreWhoUI(s)
    a:RefreshUI()
end

function A:TickScanner()
    local s=self.scan
    if not s.active then return end
    local now=self:Clock()
    if s.state=="wait_hc" then
        if self.hc.active then return end
        if not self:LadderReady() then
            self:StopScan("Нет полного HC-ладдера: безопасная остановка")
            return
        end
        s.state="ready"
    end
    if s.inFlight then
        -- The native frame may be loaded after scan start; keep suppression scoped.
        isolateWhoUI(s)
        if now>=s.deadline then
            s.partial=true
            self:StopScan("WHO: нет ответа за 45 секунд")
        end
        return
    end
    if now<s.sendAfter then return end
    if #s.pending==0 then done(s,self);return end
    if s.queryCount>=MAX_QUERIES then
        s.partial=true
        self:StopScan("WHO: ограничение 120 запросов")
        return
    end
    if not SendWho or not GetNumWhoResults or not GetWhoInfo then
        self:StopScan("WHO API недоступен в этом клиенте")
        return
    end
    if s.queryCount==0 and SetWhoToUI then
        if GetWhoToUI then
            local ok,value=pcall(GetWhoToUI)
            if ok then s.previousWhoUI=value end
        end
        if pcall(SetWhoToUI,true) then s.changedWhoUI=true end
    end
    isolateWhoUI(s)
    local nextRange=table.remove(s.pending,1)
    s.lastRange=nextRange
    local query=tostring(nextRange.low).."-"..tostring(nextRange.high)
    local success=pcall(SendWho,query)
    if not success then self:StopScan("WHO API отклонил запрос");return end
    s.inFlight=true;s.state="wait_who";s.deadline=now+WHO_TIMEOUT
    s.lastSend=now;s.queryCount=s.queryCount+1
    self:RefreshUI()
end

function A:OnWhoResult()
    local s=self.scan
    if not s.active or not s.inFlight or not s.lastRange then return end
    local ok,num,total=pcall(GetNumWhoResults)
    if not ok or type(num)~="number" then
        self:StopScan("WHO: ошибка чтения результатов")
        return
    end
    num=math.max(0,math.min(200,math.floor(num)))
    total=tonumber(total) or num
    s.stats=s.stats or newStats()
    s.stats.rows=s.stats.rows+num
    for i=1,num do
        local name,guild,level,race,class,zone,classFile=GetWhoInfo(i)
        if type(name)=="string" and name~="" and tonumber(level) then
            local token=self:Fold(name)
            if s.seen[token] then
                s.stats.duplicates=s.stats.duplicates+1
            else
                s.seen[token]=true
                if not guild or guild=="" then
                    s.stats.unguilded=s.stats.unguilded+1
                    local person={name=name,guild=guild or "",level=level,
                                  race=race or "?",class=class or "?",
                                  classFile=classFile or "",zone=zone or ""}
                    -- A contact attempt is a per-character/guild 30-day exclusion.
                    -- WHO results must not reintroduce a recently contacted player.
                    if self:FilterHit(person) or self:RecentContact(person) then
                        s.stats.filtered=s.stats.filtered+1
                    elseif not self:AllowsHC(person) then
                        s.stats.hardcore=s.stats.hardcore+1
                    else
                        person.hc=self:CandidateHC(person)
                        self.candidates[#self.candidates+1]=person
                        self.candidateByName[token]=person
                    end
                end
            end
        end
    end
    local current=s.lastRange
    -- Never perform undocumented infinite retries when WHO returns the cap.
    if total>num or num>=50 then
        if current.low<current.high then
            local mid=math.floor((current.low+current.high)/2)
            table.insert(s.pending,1,band(mid+1,current.high))
            table.insert(s.pending,1,band(current.low,mid))
        else
            s.partial=true
        end
    end
    s.inFlight=false;s.state="ready"
    s.sendAfter=math.max(self:Clock(),s.lastSend+GAP)
    s.lastRange=nil
    self:RefreshUI()
end
