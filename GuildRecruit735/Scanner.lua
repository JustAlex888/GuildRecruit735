-- Eligibility functions live in this existing TOC file so upgrades do not depend on discovering a new file.
-- Original single eligibility gate and bounded in-memory WHO snapshot.
local A=GR735
local reasonText={guild="Уже в гильдии",level="Вне диапазона уровней",class="Исключённый класс",
 filter="Исключение",contact="Контакт за последние 30 дней",hardcore="HC-фильтр",
 invalid="Некорректные данные",accepted="Подходит"}
function A:CandidateReason(person)
 if not person or type(person.name)~="string"or person.name==""then return "invalid"end
 local level=tonumber(person.level);local p=self:Profile()
 local lo,hi=tonumber(p.minLevel),tonumber(p.maxLevel)
 if not lo or not hi or lo~=math.floor(lo)or hi~=math.floor(hi)or lo<1 or hi>110 or hi<lo then return "invalid"end
 if not level or level~=math.floor(level)or level<1 or level>110 then return "invalid"end
 if person.guild and person.guild~=""then return "guild"end
 if level<lo or level>hi then return "level"end
 if p.excludedClasses[person.classFile or ""]then return "class"end
 local hit=self:FilterHit(person);if hit then return "filter",hit end
 if self:RecentContact(person)then return "contact"end
 if not self:AllowsHC(person)then return "hardcore"end
 return nil
end
function A:RebuildCandidates()
 if not self.scan.records or self.rebuildingCandidates then return end
    if self.scan.recordGuild and self.scan.recordGuild~=self:GuildKey()then
        self.scan.records=nil;self.scan.recordIndex=nil;self.candidates={};self.candidateByName={};return
    end
 self.rebuildingCandidates=true
 local list,byName={},{};local counts={};local unguilded=0
 for _,person in ipairs(self.scan.records)do
  if person.guild==""then unguilded=unguilded+1 end
  local reason,detail=self:CandidateReason(person)
  person.exclusionReason=reason;person.exclusionDetail=detail
  if reason then counts[reason]=(counts[reason]or 0)+1 else
   person.hc=self:CandidateHC(person);list[#list+1]=person;byName[self:Fold(person.name)]=person
  end
 end
 self.candidates=list;self.candidateByName=byName
 local stats=self.scan.stats or{};self.scan.stats=stats
 stats.unguilded=unguilded;stats.reasons=counts
 stats.filtered=(counts.class or 0)+(counts.filter or 0)+(counts.contact or 0)+(counts.level or 0)+(counts.invalid or 0)
 stats.hardcore=counts.hardcore or 0
 self.rebuildingCandidates=false
end
function A:SelectionChanged()
 self.candidatePage=1
 if self.scan.active then self.scan.partial=true;self:StopScan("Настройки изменены — запустите новый поиск")end
 self:RebuildCandidates()
 -- Do not overwrite an EditBox while a user is completing another field.
 if self.UpdateCandidates then self:UpdateCandidates()end
 if self.UpdateMini then self:UpdateMini()end
end
function A:ExplainCandidate(name)
 name=self:Fold((name or ""):match("^%s*(.-)%s*$"))
 if name==""then self:Message("Используйте /gr735 why Имя-плюс-мир");return end
 self:RebuildCandidates()
 local found={}
 for _,p in ipairs(self.scan.records or{})do
  local base=self:SplitPlayerName(p.name)
  if self:Fold(p.name)==name or base==name then found[#found+1]=p end
 end
 if #found==0 then self:Message("Игрок не получен в текущих ответах /who. Это не доказательство отсутствия игрока онлайн.");return end
 for _,p in ipairs(found)do
  local reason,detail=self:CandidateReason(p)
  self:Message(p.name..": "..self:T(reasonText[reason or "accepted"])..(detail and (" — "..detail)or ""))
 end
end
function A:ScanStatusText()
 local s=self.scan;local state=s.state
 local names={idle="Поиск не запущен",wait_hc="Ожидание HC-данных",ready="Сканирование",wait_who="Ожидание /who"}
 local text=self:T(names[state]or state or "Поиск не запущен")
 if s.partial and not text:find(self:T("Неполный поиск"),1,true)then text=text.." — "..self:T("Неполный поиск")end
 return text
end
function A:ScanDetailsText()
 local s=self.scan;local c=s.stats and s.stats.reasons or{}
 return self:T("Запросов: %d/120; уникальных игроков: %d; подходят: %d",s.queryCount or 0,#(s.records or{}),#self.candidates).."\n"..
  self:T("Гильдия: %d; уровни: %d; классы: %d; правила: %d; контакты: %d; HC: %d",c.guild or 0,c.level or 0,c.class or 0,c.filter or 0,c.contact or 0,c.hardcore or 0).."\n"..
  self:T("/gr735 why Имя — причина отбора. Снимок /who не подтверждает текущий онлайн.")
end

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

local CLASS_ORDER={"WARRIOR","PALADIN","HUNTER","ROGUE","PRIEST","DEATHKNIGHT","SHAMAN","MAGE","WARLOCK","MONK","DRUID","DEMONHUNTER"}
local function classes()
    if type(WHO_TAG_CLASS)~="string"or WHO_TAG_CLASS==""or type(LOCALIZED_CLASS_NAMES_MALE)~="table"then return nil end
    local result={}
    for _,file in ipairs(CLASS_ORDER)do
        local name=LOCALIZED_CLASS_NAMES_MALE[file]
        if type(name)~="string"or name==""or name:find('["%c]')then return nil end
        result[#result+1]={file=file,name=name}
    end
    return result
end
function A:SelectionSignature()
    local p=self:Profile();local fields={tostring(p.minLevel),tostring(p.maxLevel),p.hcMode,tostring(self:RealmID())}
    for _,f in ipairs(GR735DB.filters)do if p.activeFilters[f.id]then fields[#fields+1]=f.id..":"..f.kind..":"..f.needle end end
    for file,on in pairs(p.excludedClasses)do if on then fields[#fields+1]=file end end
    table.sort(fields);return table.concat(fields,"|")
end
function A:StopScan(reason)
    local s=self.scan
    if s.active and(s.inFlight or #s.pending>0 or s.state=="wait_hc")then s.partial=true end
    s.state=reason or "Остановлено"
    s.active=false;s.inFlight=false;s.pending={};s.lastRange=nil
    self:CancelLadder();restoreWhoUI(s);self:RefreshUI()
end
function A:StartScan()
    local s=self.scan
    if s.active then self:StopScan("Остановлено вручную");return end
    local p=self:Profile()
    local lo,hi=tonumber(p.minLevel),tonumber(p.maxLevel)
    if not lo or not hi or lo~=math.floor(lo)or hi~=math.floor(hi)or lo<1 or hi>110 or hi<lo then
        s.state="Некорректный диапазон уровней";self:RefreshUI();return
    end
    self:ClearCandidates()
    s.stats=newStats();s.records={};s.recordIndex={};s.recordGuild=self:GuildKey()
    s.active=true;s.state="wait_hc";s.partial=false;s.pending={band(lo,hi)}
    s.seen={};s.inFlight=false;s.queryCount=0;s.signature=self:SelectionSignature()
    s.lastRange=nil;s.sendAfter=self:Clock();s.lastSend=-10000
    s.changedWhoUI=false;s.previousWhoUI=nil;s.suspendedFriendsFrame=nil
    if p.hcMode=="all"then s.state="ready"
    elseif not self:StartLadder()then
        if self:LadderReady()then s.state="ready";self:Message("HC-запрос недоступен; используется сохранённый ладдер.")
        else self:StopScan("HC-данные недоступны; поиск не запущен");return end
    end
    s.signature=self:SelectionSignature();self:RefreshUI()
end
local function done(s,a)
    s.active=false;s.state=s.partial and "Завершено (неполный /who)"or "Завершено"
    restoreWhoUI(s);a:RefreshUI()
end
function A:WatchWhoRequests()
    if self.whoHooked or type(hooksecurefunc)~="function"then return end
    local ok=pcall(hooksecurefunc,"SendWho",function()
        if A.scan.active and not A.sendingWho then
            A.scan.partial=true;A:StopScan("Другой запрос /who — поиск остановлен")
        end
    end)
    if ok then self.whoHooked=true end
end
function A:TickScanner()
    local s=self.scan;if not s.active then return end
    if s.signature~=self:SelectionSignature()then self:SelectionChanged();return end
    local now=self:Clock()
    if s.state=="wait_hc"then
        if self.hc.active then return end
        if not self:LadderReady()then self:StopScan("Нет полного HC-ладдера: безопасная остановка");return end
        s.state="ready"
    end
    if s.inFlight then
        isolateWhoUI(s)
        if now>=s.deadline then s.partial=true;self:StopScan("WHO: нет ответа за 45 секунд")end
        return
    end
    if now<s.sendAfter then return end
    if #s.pending==0 then done(s,self);return end
    if s.queryCount>=MAX_QUERIES then s.partial=true;self:StopScan("WHO: ограничение 120 запросов");return end
    if not SendWho or not GetNumWhoResults or not GetWhoInfo then self:StopScan("WHO API недоступен в этом клиенте");return end
    if s.queryCount==0 and SetWhoToUI then
        if GetWhoToUI then local ok,value=pcall(GetWhoToUI);if ok then s.previousWhoUI=value end end
        if pcall(SetWhoToUI,true)then s.changedWhoUI=true end
    end
    self:WatchWhoRequests();isolateWhoUI(s)
    local nextRange=table.remove(s.pending,1);s.lastRange=nextRange
    local query=tostring(nextRange.low).."-"..tostring(nextRange.high)
    if nextRange.className then query=query.." "..WHO_TAG_CLASS..'"'..nextRange.className..'"'end
    self.sendingWho=true;local success=pcall(SendWho,query);self.sendingWho=false
    if not success then self:StopScan("WHO API отклонил запрос");return end
    s.inFlight=true;s.state="wait_who";s.deadline=now+WHO_TIMEOUT
    s.lastSend=now;s.queryCount=s.queryCount+1;self:RefreshUI()
end
function A:OnWhoResult()
    local s=self.scan
    if not s.active or not s.inFlight or not s.lastRange then return end
    if s.signature~=self:SelectionSignature()then self:SelectionChanged();return end
    local ok,num,total=pcall(GetNumWhoResults)
    if not ok or type(num)~="number"or num~=math.floor(num)or num<0 or num>200 then
        self:StopScan("WHO: ошибка чтения результатов");return
    end
    total=tonumber(total)or num
    if total~=total or total<0 or total>100000 then self:StopScan("WHO: ошибка чтения результатов");return end
    local current=s.lastRange;local batch={}
    -- Validate the entire native reply before mutating the snapshot. The API
    -- has no request ID; a foreign or ignored query must not silently enter it.
    for i=1,num do
        local success,name,guild,level,race,class,zone,classFile=pcall(GetWhoInfo,i)
        level=tonumber(level)
        if not success or type(name)~="string"or name==""or #name>160 or name:find('[%c|]')or
           not level or level~=math.floor(level)or level<current.low or level>current.high or
           (guild~=nil and type(guild)~="string")or(current.classFile and classFile~=current.classFile)then
            s.stats.rejectedReplies=(s.stats.rejectedReplies or 0)+1;s.partial=true
            self:StopScan("Ответ /who не соответствует запросу — повторите поиск");return
        end
        batch[#batch+1]={name=name,guild=guild or "",level=level,race=race or "?",class=class or "?",zone=zone or "",classFile=classFile or ""}
    end
    s.stats.rows=s.stats.rows+num
    for _,person in ipairs(batch)do
        local token=self:CandidateKey(person.name);local index=s.recordIndex[token]
        if index then s.stats.duplicates=s.stats.duplicates+1;s.records[index]=person
        elseif #s.records<5000 then
            s.records[#s.records+1]=person;s.recordIndex[token]=#s.records;s.seen[token]=true
        else s.partial=true;self:StopScan("WHO: предел 5000 уникальных игроков");return end
    end
    if total>num or num>=50 then
        if current.low<current.high then
            local mid=math.floor((current.low+current.high)/2)
            table.insert(s.pending,1,band(mid+1,current.high));table.insert(s.pending,1,band(current.low,mid))
        elseif not current.classFile then
            local split=classes()
            if split then
                for i=#split,1,-1 do table.insert(s.pending,1,{low=current.low,high=current.high,classFile=split[i].file,className=split[i].name})end
            else s.partial=true;s.stats.saturated=(s.stats.saturated or 0)+1 end
        else s.partial=true;s.stats.saturated=(s.stats.saturated or 0)+1 end
    end
    s.inFlight=false;s.state="ready";s.sendAfter=math.max(self:Clock(),s.lastSend+GAP);s.lastRange=nil
    self:RebuildCandidates();self:RefreshUI()
end
