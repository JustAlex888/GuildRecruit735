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
    GR735DB.filters[#GR735DB.filters+1] = {id=id,title=title,kind=kind,needle=needle}
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
    return self:CreateFilter("Исключение по имени","name",needle)
end

local knownClasses={WARRIOR=true,PALADIN=true,HUNTER=true,ROGUE=true,PRIEST=true,
    SHAMAN=true,MAGE=true,WARLOCK=true,DRUID=true,MONK=true,DEATHKNIGHT=true,DEMONHUNTER=true}
function A:SetClassExcluded(classFile,on)
    if not knownClasses[classFile] then return false end
    self:Profile().excludedClasses[classFile]=(on==true) or nil
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
            if f.kind == "realm" then
                value = candidate.name or ""
            end
            local filterValue = norm(f.needle)
            if filterValue ~= "" and norm(value):find(filterValue,1,true) then
                return f.title
            end
        end
    end
    return nil
end
