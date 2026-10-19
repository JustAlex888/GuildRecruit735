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
