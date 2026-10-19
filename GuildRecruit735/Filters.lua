-- Public shared filter catalogue, private activation per character/guild profile.
local A = GR735
local kindName = {name = true, guild = true, realm = true, class = true}
local function norm(s)
    if type(s) ~= "string" then return "" end
    return A:Fold((s:gsub("^%s+",""):gsub("%s+$","")))
end

function A:CreateFilter(title,kind,needle)
    self:Store()
    title = type(title) == "string" and title:match("^%s*(.-)%s*$") or ""
    needle = type(needle) == "string" and needle:match("^%s*(.-)%s*$") or ""
    if #title < 1 or #title > 56 or #needle < 1 or #needle > 64 or not kindName[kind] then
        return false,"Проверьте название, условие и тип фильтра."
    end
    for _,f in ipairs(GR735DB.filters) do
        if norm(f.title) == norm(title) and f.kind == kind and norm(f.needle) == norm(needle) then
            return false,"Такой фильтр уже существует."
        end
    end
    local id = "f"..tostring(GR735DB.nextFilterId)
    GR735DB.nextFilterId = GR735DB.nextFilterId + 1
    GR735DB.filters[#GR735DB.filters+1] = {id=id,title=title,kind=kind,needle=needle,match="explicit"}
    -- New filters are visible but OFF in every character/guild profile.
    self:RefreshUI()
    return true,id
end

-- New simplified name exclusion: shared rule, disabled for all profiles initially.
function A:AddNameExclusion(needle)
    self:Store()
    if type(needle)~="string" then return false,"Введите имя или часть имени." end
    needle=needle:match("^%s*(.-)%s*$")
    if needle=="" then return false,"Введите имя или часть имени." end
    for _,f in ipairs(GR735DB.filters) do
        if f.kind=="name" and norm(f.needle)==norm(needle) then
            return false,"Такое исключение уже существует."
        end
    end
    if self:WorldToken(needle)then return self:AddRealmExclusion(needle)end
    return self:CreateFilter("Исключение по имени","name",needle)
end

local knownClasses={WARRIOR=true,PALADIN=true,HUNTER=true,ROGUE=true,PRIEST=true,
    SHAMAN=true,MAGE=true,WARLOCK=true,DRUID=true,MONK=true,DEATHKNIGHT=true,DEMONHUNTER=true}
function A:SetClassExcluded(classFile,on)
    if not knownClasses[classFile] then return false end
    self:Profile().excludedClasses[classFile]=(on==true) or nil
    if self.SelectionChanged then self:SelectionChanged()end
    self:RefreshUI()
    return true
end

function A:GetFilter(id)
    self:Store()
    for _,f in ipairs(GR735DB.filters) do
        if f.id == id then return f end
    end
end

function A:ToggleFilter(id)
    if not self:GetFilter(id) then return false end
    local p = self:Profile()
    p.activeFilters[id] = not (p.activeFilters[id] == true)
    if self.SelectionChanged then self:SelectionChanged()end
    self:RefreshUI()
    return p.activeFilters[id]
end

function A:DeleteFilter(id)
    self:Store()
    for i=#GR735DB.filters,1,-1 do
        if GR735DB.filters[i].id == id then
            table.remove(GR735DB.filters,i)
            -- Other characters may retain inert IDs; monotonic IDs prevent accidental reuse.
            self:Profile().activeFilters[id] = nil
            if self.SelectionChanged then self:SelectionChanged()end
            self:RefreshUI()
            return true
        end
    end
    return false
end

function A:FilterHit(candidate)
    local profile=self:Profile()
    if candidate.classFile and profile.excludedClasses[candidate.classFile]==true then
        return "Класс"
    end
    local enabled = profile.activeFilters
    for _,f in ipairs(GR735DB.filters) do
        if enabled[f.id] == true then
            local value = candidate[f.kind] or ""
            if self:IsRealmFilter(f)then
                local _,realm=self:SplitPlayerName(candidate.name)
                realm=realm or self:CurrentRealmSuffix()
                if realm and realm==self:NormalizeRealm(f.needle)then return f.title end
                value=""
            end
            local filterValue = norm(f.needle)
            if filterValue ~= "" and norm(value):find(filterValue,1,true) then
                return f.title
            end
        end
    end
    return nil
end

function A:WorldToken(text)
 local s=norm(text):gsub("^%-","")
 return s:match("^plusx%d+$")or s:match("^x%d+$")
end
function A:NormalizeRealm(text)
 local s=norm(text):gsub("%s+",""):gsub("^%-","")
 if s:match("^x%d+$")then s="plus"..s end
 return s
end
function A:CurrentRealmSuffix()
 local raw=self:Fold(GetRealmName and GetRealmName()or "")
 local n=raw:match("plus%s*x(%d+)")or raw:match("legion%s*x(%d+)")
 if n then return "plusx"..n end
 local token=self:WorldToken(raw);if token then return self:NormalizeRealm(token)end
 return nil -- Never infer a world from the numeric HC ID alone.
end
function A:SplitPlayerName(name)
 local s=norm(name);local base,realm=s:match("^([^%-]+)%-(.+)$")
 return base or s,realm and self:NormalizeRealm(realm)or nil
end
function A:CandidateKey(name)
 local base,realm=self:SplitPlayerName(name)
 realm=realm or self:CurrentRealmSuffix()
 return realm and(base.."-"..realm)or base
end
function A:IsRealmFilter(f)
 -- Old UI accepted x7/plusx7 as name rules for world exclusion. Interpret
 -- only those exact legacy tokens as worlds, retaining IDs/activation/bytes.
 return f.kind=="realm"or(f.kind=="name"and not f.match and self:WorldToken(f.needle)~=nil)
end
function A:AddRealmExclusion(needle)
 if type(needle)~="string"or not self:WorldToken(needle)then return false,"Введите суффикс мира: plusx7 или x7."end
 return self:CreateFilter("Исключение по миру","realm",self:NormalizeRealm(needle))
end
