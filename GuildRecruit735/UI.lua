-- GuildRecruit735 0.1.5 UI. Native Blizzard widgets; original MIT implementation.
local A=GR735
local function panel(name,w,h)
    local f=CreateFrame("Frame",name,UIParent)
    f:SetSize(w,h);f:SetFrameStrata("DIALOG")
    f:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",tile=true,tileSize=16,edgeSize=16,
        insets={left=5,right=5,top=5,bottom=5}})
    f:SetBackdropColor(.045,.035,.03,.96)
    f:SetBackdropBorderColor(.58,.45,.20,1)
    f:SetMovable(true);f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart",function(self) self:StartMoving() end)
    f:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
    if f.SetClampedToScreen then f:SetClampedToScreen(true) end
    if UISpecialFrames then table.insert(UISpecialFrames,name) end
    f:Hide()
    return f
end
local function label(p,text,x,y,width,font)
    local f=p:CreateFontString(nil,"OVERLAY",font or "GameFontNormal")
    f:SetPoint("TOPLEFT",p,"TOPLEFT",x,y)
    f:SetWidth(width);f:SetJustifyH("LEFT");f:SetText(A:T(text or ""))
    return f
end
-- Increase readability using the user's localized Blizzard font, not a bundled font.
-- One or two points only; measured row heights handle longer strings.
local function growFont(fontString,delta)
    if not fontString or not fontString.GetFont or not fontString.SetFont then return end
    local path,size,flags=fontString:GetFont()
    if path and type(size)=="number" then
        fontString:SetFont(path,size+delta,flags)
    end
end

local function button(parent,text,w,h,x,y,func)
    local b=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
    b:SetSize(w,h);b:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
    b:SetText(A:T(text or ""));b:RegisterForClicks("LeftButtonUp","RightButtonUp")
    if func then b:SetScript("OnClick",func) end
    return b
end
local function input(parent,w,x,y,maxlen)
    local b=CreateFrame("EditBox",nil,parent,"InputBoxTemplate")
    b:SetSize(w,24);b:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
    b:SetAutoFocus(false);b:SetMaxLetters(maxlen or 64)
    return b
end
local function closeButton(f)
    return button(f,"X",27,25,f:GetWidth()-38,-12,function() f:Hide() end)
end
local function tip(btn,text)
    btn:SetScript("OnEnter",function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
        GameTooltip:AddLine(A:T(text),1,.94,.35,true);GameTooltip:Show()
    end)
    btn:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
end
local HC_MODES={{"exclude","Исключать HC"},{"only","Только HC"},{"all","Все игроки"}}
local INV_MODES={{"invite","Только приглашение"},{"invite_whisper","Сообщение, затем приглашение"},
    {"whisper","Только сообщение"}}
local CLASS_CHOICES={{"WARRIOR","Воин"},{"PALADIN","Паладин"},
    {"DEATHKNIGHT","Рыцарь смерти"},{"HUNTER","Охотник"},
    {"ROGUE","Разбойник"},{"PRIEST","Жрец"},{"SHAMAN","Шаман"},
    {"MAGE","Маг"},{"WARLOCK","Чернокнижник"},{"MONK","Монах"},
    {"DRUID","Друид"},{"DEMONHUNTER","Охотник на демонов"}}
local OLD_TYPES={name="Имя",guild="Гильдия (старый)",realm="Суффикс (старый)",class="Класс (старый)"}
local function dropdown(parent,name,x,y,width,choices,property)
    local d=CreateFrame("Frame",name,parent,"UIDropDownMenuTemplate")
    d:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
    UIDropDownMenu_SetWidth(d,width)
    UIDropDownMenu_Initialize(d,function(_,level)
        if level~=1 then return end
        for _,choice in ipairs(choices) do
            local value,title=choice[1],choice[2]
            local info=UIDropDownMenu_CreateInfo()
            info.text=A:T(title);info.value=value
            info.checked=A:Profile()[property]==value
            info.func=function()
                A:Profile()[property]=value
                A:UpdateSettings()
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info,level)
        end
    end)
    return d
end

-- Blizzard color escape requires exactly six hexadecimal RGB digits after |cff.
-- On some clients colorStr already starts with alpha (ff); never concatenate it verbatim.
local function classColorEscape(classFile)
    local c=RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
    if type(c)~="table" then return "|cffffffff" end
    if type(c.r)=="number" and type(c.g)=="number" and type(c.b)=="number" then
        local function component(v)
            return math.floor(math.max(0,math.min(1,v))*255+0.5)
        end
        return string.format("|cff%02x%02x%02x",component(c.r),component(c.g),component(c.b))
    end
    -- Defensive fallback for older/classic class palettes exposing only colorStr.
    local rgb=type(c.colorStr)=="string" and c.colorStr:match("(%x%x%x%x%x%x)$")
    return rgb and ("|cff"..rgb) or "|cffffffff"
end

function A:BuildUI()
    if self.ui then return end
    self.ui={}
    local U=self.ui
    -- Compact panel is initially HIDDEN. /gr735 shows/hides it deliberately.
    local mini=panel("GR735MiniPanel",455,118)
    U.mini=mini;mini:SetPoint("CENTER",UIParent,"CENTER",0,125)
    U.state=label(mini,"Ожидание сканирования",16,-12,283,"GameFontNormal")
    U.counter=label(mini,"Подходящих: 0 | Запросов /who: 0",16,-37,420,"GameFontHighlightSmall")
    U.scanDetails=label(mini,"Сканирование не запускалось",16,-56,420,"GameFontHighlightSmall")
    button(mini,"Настройки",99,23,309,-10,function() A:ShowSettings() end)
    closeButton(mini)
    U.showButton=button(mini,"Показать игроков (0)",157,27,14,-80,function() A:ShowCandidates() end)
    if U.showButton.GetFontString then growFont(U.showButton:GetFontString(),1) end
    U.scanButton=button(mini,"Сканирование",127,27,180,-80,function() A:StartScan() end)
    U.clearButton=button(mini,"Очистить",124,27,317,-80,function()
        if A.scan.active then A:StopScan("Остановлено перед очисткой") end
        A:ClearCandidates()
        A.scan.stats={rows=0,unguilded=0,filtered=0,hardcore=0,duplicates=0}
        A.scan.queryCount=0;A.scan.state="idle"
        A:UpdateMini()
    end)
    tip(U.clearButton,"Очищает результаты текущего сканирования, но не настройки и фильтры.")

    -- Existing candidate list layout and safe manual click actions are preserved.
    local list=panel("GR735CandidateList",608,330)
    U.list=list;list:SetPoint("CENTER",UIParent,"CENTER",0,0)
    U.listTitle=label(list,"Найденные игроки — выбирайте вручную",18,-17,535,"GameFontNormalLarge")
    growFont(U.listTitle,1)
    closeButton(list)
    U.listCaption=label(list,"Массовых приглашений нет.",18,-45,544,"GameFontHighlightSmall")
    growFont(U.listCaption,1)
    local scroll=CreateFrame("ScrollFrame",nil,list,"UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT",list,"TOPLEFT",17,-90);scroll:SetSize(555,225)
    local child=CreateFrame("Frame",nil,scroll)
    child:SetSize(526,225);scroll:SetScrollChild(child)
    U.scroll=scroll;U.rowsParent=child;U.rows={}

    local prefs=panel("GR735Preferences",548,463)
    U.prefs=prefs;prefs:SetPoint("CENTER",UIParent,"CENTER",0,0)
    label(prefs,"GuildRecruit735 — настройки",18,-15,485,"GameFontNormalLarge")
    closeButton(prefs)
    U.guildText=label(prefs,"",20,-55,500,"GameFontHighlightSmall")
    label(prefs,"Режим Hardcore:",22,-89,210)
    U.hcDropdown=dropdown(prefs,"GR735HCDropdown",231,-68,259,HC_MODES,"hcMode")
    label(prefs,"Действие при выборе игрока:",22,-133,220)
    U.modeDropdown=dropdown(prefs,"GR735InviteDropdown",231,-113,259,INV_MODES,"inviteMode")
    label(prefs,"Уровни поиска (20–110 по умолчанию):",22,-178,310)
    U.minLevel=input(prefs,70,344,-168,3)
    U.maxLevel=input(prefs,70,449,-168,3)
    label(prefs,"—",432,-175,17)
    -- World ID 44 is intentionally unchanged until the server behavior is verified.
    label(prefs,"World ID для HC (x1 = 44):",22,-219,310)
    U.realmId=input(prefs,90,360,-211,4)
    U.savePrefs=button(prefs,"Сохранить настройки поиска",256,29,261,-250,function()
        local p=A:Profile()
        local lo,hi,r=tonumber(U.minLevel:GetText()),tonumber(U.maxLevel:GetText()),tonumber(U.realmId:GetText())
        if not lo or not hi or not r or lo<1 or hi>110 or hi<lo or r<1 or
           lo~=math.floor(lo) or hi~=math.floor(hi) or r~=math.floor(r) then
            A:Message("Некорректный уровень или World ID.")
            return
        end
        p.minLevel=lo;p.maxLevel=hi;p.realmId=r
        A.liveRealmID=nil;A:UpdateSettings()
        A:Message("Настройки поиска сохранены для этого персонажа и гильдии.")
    end)
    button(prefs,"Фильтры",231,32,22,-300,function() A:ShowFilterWindow() end)
    button(prefs,"Сообщения",231,32,287,-300,function() A:ShowMessages() end)
    U.resetContacts=button(prefs,"Сбросить историю контактов (30 дней)",354,29,22,-342,function()
        A:ConfirmResetContacts()
    end)
    label(prefs,"Каталог имён общий; фильтры включаются отдельно для персонажа.",22,-389,502,"GameFontHighlightSmall")
    label(prefs,"/gr735 minimap • /gr735 resetcontacts • /gr735 version",22,-419,505,"GameFontHighlightSmall")

    -- Two clear filter tabs. No technical "substring kind" or example realm suffix.
    local filters=panel("GR735Filters",572,296)
    U.filters=filters;filters:SetPoint("CENTER",UIParent,"CENTER",0,0)
    label(filters,"Фильтры игроков",18,-15,500,"GameFontNormalLarge")
    closeButton(filters)
    label(filters,"Исключения. ЛКМ — включить/выключить; ПКМ — удалить с подтверждением.",19,-50,524,"GameFontHighlightSmall")
    U.filterTab="names"
    U.namesTab=button(filters,"Имена",247,29,18,-79,function() U.filterTab="names";A:UpdateFilters() end)
    U.classesTab=button(filters,"Классы",247,29,292,-79,function() U.filterTab="classes";A:UpdateFilters() end)
    local namesArea=CreateFrame("Frame",nil,filters)
    namesArea:SetSize(545,240);namesArea:SetPoint("TOPLEFT",filters,"TOPLEFT",0,0)
    U.namesArea=namesArea
    label(namesArea,"Исключение по имени",22,-119,290)
    U.nameExclusion=input(namesArea,380,22,-144,64)
    U.addName=button(namesArea,"Добавить",116,27,431,-144,function()
        local ok,why=A:AddNameExclusion(U.nameExclusion:GetText())
        if ok then
            U.nameExclusion:SetText("")
            A:Message("Исключение добавлено в общий каталог; пока выключено.")
            A:UpdateFilters()
        else A:Message(why) end
    end)
    local fscroll=CreateFrame("ScrollFrame",nil,namesArea,"UIPanelScrollFrameTemplate")
    fscroll:SetPoint("TOPLEFT",namesArea,"TOPLEFT",18,-189)
    fscroll:SetSize(528,36)
    local fchild=CreateFrame("Frame",nil,fscroll)
    fchild:SetSize(500,36);fscroll:SetScrollChild(fchild)
    U.filterScroll=fscroll;U.filterParent=fchild;U.filterButtons={}
    U.noFilters=label(namesArea,"Исключений пока нет.",25,-200,490,"GameFontHighlightSmall")
    U.closeFilters=button(filters,"Закрыть",172,29,373,-257,function() filters:Hide() end)
    U.closeFilters:ClearAllPoints()
    U.closeFilters:SetPoint("BOTTOMRIGHT",filters,"BOTTOMRIGHT",-18,16)
    local classesArea=CreateFrame("Frame",nil,filters)
    classesArea:SetSize(545,245);classesArea:SetPoint("TOPLEFT",filters,"TOPLEFT",0,0)
    U.classesArea=classesArea
    label(classesArea,"Не показывать игроков выбранных классов:",22,-118,510,"GameFontHighlightSmall")
    U.classChecks={}
    for i,c in ipairs(CLASS_CHOICES) do
        local col=math.floor((i-1)/6)
        local row=(i-1)%6
        local x=20+col*275
        local y=-142-row*29
        local cb=CreateFrame("CheckButton",nil,classesArea,"UICheckButtonTemplate")
        cb:SetSize(25,25);cb:SetPoint("TOPLEFT",classesArea,"TOPLEFT",x,y)
        cb.classFile=c[1]
        label(classesArea,c[2],x+27,y-4,232,"GameFontHighlight")
        cb:SetScript("OnClick",function(self) A:SetClassExcluded(self.classFile,self:GetChecked()==true) end)
        U.classChecks[c[1]]=cb
    end
    classesArea:Hide()

    local messages=panel("GR735Messages",650,424)
    U.messages=messages;messages:SetPoint("CENTER",UIParent,"CENTER",0,0)
    label(messages,"Шаблоны личных сообщений",18,-15,570,"GameFontNormalLarge")
    closeButton(messages)
    U.previousTemplate=button(messages,"<",57,28,22,-64,function()
        local p=A:Profile();p.selectedTemplate=((p.selectedTemplate or 1)+4)%6+1
        A:UpdateMessages()
    end)
    U.templateLabel=label(messages,"Шаблон 1 из 6",100,-68,360)
    U.nextTemplate=button(messages,">",57,28,571,-64,function()
        local p=A:Profile();p.selectedTemplate=((p.selectedTemplate or 1)%6)+1
        A:UpdateMessages()
    end)
    local editorBackdrop=CreateFrame("Frame",nil,messages)
    editorBackdrop:SetSize(606,165)
    editorBackdrop:SetPoint("TOPLEFT",messages,"TOPLEFT",21,-110)
    editorBackdrop:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",tile=true,tileSize=16,edgeSize=12,
        insets={left=4,right=4,top=4,bottom=4}})
    editorBackdrop:SetBackdropColor(.025,.025,.025,.97)
    local messageScroll=CreateFrame("ScrollFrame",nil,editorBackdrop,"UIPanelScrollFrameTemplate")
    messageScroll:SetPoint("TOPLEFT",editorBackdrop,"TOPLEFT",11,-9)
    messageScroll:SetSize(566,145)
    U.messageScroll=messageScroll
    local msgbox=CreateFrame("EditBox",nil,messageScroll)
    U.msgbox=msgbox
    msgbox:SetSize(551,147);msgbox:SetMultiLine(true);msgbox:SetAutoFocus(false)
    msgbox:EnableMouse(true)
    msgbox:SetMaxLetters(512)
    if ChatFontNormal then msgbox:SetFontObject(ChatFontNormal) end
    msgbox:SetTextInsets(3,3,4,4)
    -- A bare EditBox with AutoFocus(false) must acquire focus on a real click.
    -- Keep Enter available for multiline input; Esc only releases keyboard focus.
    msgbox:SetScript("OnMouseDown",function(self,mouse)
        if mouse=="LeftButton" then self:SetFocus() end
    end)
    messageScroll:EnableMouse(true)
    messageScroll:SetScript("OnMouseDown",function(_,mouse)
        if mouse=="LeftButton" then msgbox:SetFocus() end
    end)
    msgbox:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
    msgbox:SetScript("OnTextChanged",function(self)
        if self.GetTextHeight then
            local h=self:GetTextHeight()
            if type(h)=="number" then self:SetHeight(math.max(147,h+22)) end
        end
        A:UpdateMessageCounter()
    end)
    msgbox:SetScript("OnCursorChanged",function(_,x,y,w,h)
        if not messageScroll.GetVerticalScroll or not messageScroll.SetVerticalScroll then return end
        local top=math.max(0,-(y or 0))
        local scrolled=messageScroll:GetVerticalScroll() or 0
        local viewHeight=messageScroll:GetHeight()
        if top<scrolled then
            messageScroll:SetVerticalScroll(top)
        elseif top+(h or 0)>scrolled+viewHeight then
            messageScroll:SetVerticalScroll(math.max(0,top+(h or 0)-viewHeight))
        end
    end)
    messageScroll:SetScrollChild(msgbox)
    U.messageCount=label(messages,"0 символов (с пробелами) | 0 / 255 байт",22,-289,600,"GameFontHighlightSmall")
    label(messages,"Переменные: {player}, {guild}, {level}, {class}.",22,-313,602,"GameFontHighlightSmall")
    label(messages,"Пример: Привет, {player}! Приглашаем тебя в гильдию {guild}.",22,-337,606,"GameFontHighlightSmall")
    label(messages,"Переносы строк при отправке заменяются пробелами.",22,-358,594,"GameFontHighlightSmall")
    U.saveMessage=button(messages,"Сохранить шаблон",284,32,20,-380,function()
        local p=A:Profile();local raw=U.msgbox:GetText()
        local ok,why=A:ValidateTemplate(raw)
        if not ok then A:Message(why);return end
        p.templates[p.selectedTemplate or 1]=raw
        U.msgbox:ClearFocus()
        A:Message("Шаблон сохранён для этого персонажа и гильдии.")
    end)
    button(messages,"Закрыть",284,32,345,-380,function() messages:Hide() end)

    StaticPopupDialogs["GR735_REMOVE_FILTER"]={
        text=A:T("Удалить фильтр «%s» из ОБЩЕГО каталога этого WoW-аккаунта?"),
        button1=YES or A:T("Удалить"),button2=CANCEL or A:T("Отмена"),
        OnAccept=function(_,id) A:DeleteFilter(id) end,
        timeout=0,whileDead=1,hideOnEscape=1,preferredIndex=3
    }
    StaticPopupDialogs["GR735_RESET_CONTACTS"]={
        text=A:T("Очистить всю историю контактов (30 дней) ТОЛЬКО для этого персонажа и гильдии? Фильтры и шаблоны останутся."),
        button1=YES or A:T("Очистить"),button2=CANCEL or A:T("Отмена"),
        OnAccept=function() A:ResetContacts() end,
        timeout=0,whileDead=1,hideOnEscape=1,preferredIndex=3
    }
    StaticPopupDialogs["GR735_CONFIRM_UNKNOWN"]={
        text=A:T("Статус HC игрока %s не подтверждён. Всё равно выполнить выбранное действие?"),
        button1=YES or A:T("Да"),button2=CANCEL or A:T("Отмена"),
        OnAccept=function(_,name)
            local who=A.candidateByName[A:Fold(name or "")]
            if who then A:DoContact(who) end
        end,
        timeout=0,whileDead=1,hideOnEscape=1,preferredIndex=3
    }
    -- Do not call mini:Show() at login; the user opens it with /gr735.
end

function A:UpdateMini()
    local U=self.ui;if not U then return end
    local s=self.scan
    local states={idle="Ожидание сканирования",ready="Сканирование",wait_hc="Ожидание HC",wait_who="Поиск /who"}
    U.state:SetText(self:T(states[s.state] or s.state))
    U.counter:SetText(self:T("Подходящих: %d | Запросов /who: %d",#self.candidates,s.queryCount or 0))
    local stats=s.stats
    if stats and (stats.rows or 0)>0 then
        U.scanDetails:SetText(self:T("Ответов WHO: %d | Без гильдии: %d | Исключено: %d",
            stats.rows,stats.unguilded,stats.filtered+stats.hardcore))
    else
        U.scanDetails:SetText(self:T(s.active and "Ожидание ответа сервера..." or "Результатов сканирования пока нет"))
    end
    U.showButton:SetText(self:T("Показать игроков (%d)",#self.candidates))
    U.scanButton:SetText(self:T(s.active and "Стоп" or "Сканирование"))
end

function A:UpdateCandidates()
    local U=self.ui;if not U then return end
    local total=math.min(#self.candidates,30)
    U.listCaption:SetText(self:T("Кандидатов: %d; показаны первые %d. ЛКМ — выбранное действие, массового приглашения нет.",
        #self.candidates,total))
    local y=0
    for i=1,math.max(total,#U.rows) do
        local line=U.rows[i]
        if not line and i<=total then
            line=CreateFrame("Button",nil,U.rowsParent)
            line:SetWidth(505);line:SetHeight(32);line:RegisterForClicks("LeftButtonUp")
            line.text=line:CreateFontString(nil,"OVERLAY","GameFontHighlight")
            growFont(line.text,2)
            line.text:SetPoint("TOPLEFT",line,"TOPLEFT",7,-4)
            line.text:SetWidth(487);line.text:SetJustifyH("LEFT");line.text:SetWordWrap(true)
            line:SetScript("OnClick",function(self) if self.person then A:Contact(self.person) end end)
            line:SetScript("OnEnter",function(self)
                if not GameTooltip or not self.person then return end
                GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
                GameTooltip:AddLine(self.person.name,1,.94,.35)
                if self.person.hc=="MATCH" then
                    GameTooltip:AddLine(A:T("Hardcore: подтверждён ладдером."),1,.65,.45,true)
                elseif self.person.hc=="UNKNOWN" then
                    GameTooltip:AddLine(A:T("Hardcore: статус неизвестен. При выборе в режиме исключения HC потребуется подтверждение."),1,.75,.35,true)
                end
                GameTooltip:Show()
            end)
            line:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
            U.rows[i]=line
        end
        if line then
            if i<=total then
                local p=self.candidates[i]
                local status=p.hc=="MATCH" and " [HC]" or ""
                local rgb=classColorEscape(p.classFile)
                -- Apply the SAME correct class color to name and class.
                -- Level/race remain neutral; p.name itself is untouched for invites.
                line.text:SetText(i..". "..rgb..p.name.."|r, "..self:T("ур.").." "..tostring(p.level)..
                    " "..p.race.." "..rgb..p.class.."|r"..status)
                local rowH=math.max(27,math.ceil(line.text:GetStringHeight()+12))
                line:SetHeight(rowH);line:ClearAllPoints()
                line:SetPoint("TOPLEFT",U.rowsParent,"TOPLEFT",0,-y)
                line.person=p;line:Show();y=y+rowH+5
            else
                line:Hide();line.person=nil
            end
        end
    end
    U.rowsParent:SetHeight(math.max(225,y+15))
    U.list:SetHeight(math.max(175,math.min(600,146+math.min(440,math.max(62,y+16)))))
    U.scroll:SetHeight(math.max(62,math.min(440,y+16)))
end

function A:UpdateFilters()
    local U=self.ui;if not U then return end
    local list=GR735DB and GR735DB.filters or {}
    local profile=self:Profile()
    local enabled=profile.activeFilters
    U.namesArea:Hide();U.classesArea:Hide()
    local y=0
    for i=1,math.max(#list,#U.filterButtons) do
        local b=U.filterButtons[i]
        if not b and i<=#list then
            b=CreateFrame("Button",nil,U.filterParent,"UIPanelButtonTemplate")
            b:SetSize(496,29);b:RegisterForClicks("LeftButtonUp","RightButtonUp")
            b:SetScript("OnClick",function(self,mouse)
                if not self.filterId then return end
                if mouse=="RightButton" then
                    local f=A:GetFilter(self.filterId)
                    if f then StaticPopup_Show("GR735_REMOVE_FILTER",f.title,nil,f.id) end
                else A:ToggleFilter(self.filterId) end
            end)
            U.filterButtons[i]=b
        end
        if b then
            if i<=#list then
                local f=list[i]
                local desc=(f.kind=="name") and self:T("Исключение по имени: %s",f.needle) or
                    (self:T(OLD_TYPES[f.kind] or "Старый фильтр")..": "..f.needle)
                b.filterId=f.id
                b:SetText((enabled[f.id] and ("|cff54eb5a"..self:T("[ВКЛ]").."|r ") or
                    ("|cffff6d6d"..self:T("[ВЫКЛ]").."|r "))..desc)
                b:ClearAllPoints();b:SetPoint("TOPLEFT",U.filterParent,"TOPLEFT",0,-y)
                b:Show();y=y+32
            else b:Hide();b.filterId=nil end
        end
    end
    local rows=math.max(1,math.min(4,#list))
    U.filterScroll:SetHeight(rows*32)
    U.filterParent:SetHeight(math.max(rows*32,y+8))
    if #list==0 then U.noFilters:Show() else U.noFilters:Hide() end
    if U.filterTab=="classes" then
        U.filters:SetHeight(368)
        U.classesArea:Show()
        for key,cb in pairs(U.classChecks) do
            cb:SetChecked(profile.excludedClasses[key]==true)
        end
    else
        U.filters:SetHeight(275+(rows-1)*32)
        U.namesArea:Show()
    end
end

function A:UpdateSettings()
    local U=self.ui;if not U then return end
    local p=self:Profile()
    U.guildText:SetText(self:GuildKey())
    for _,choice in ipairs(HC_MODES) do
        if choice[1]==p.hcMode then
            UIDropDownMenu_SetSelectedValue(U.hcDropdown,choice[1])
            UIDropDownMenu_SetText(U.hcDropdown,self:T(choice[2]))
        end
    end
    for _,choice in ipairs(INV_MODES) do
        if choice[1]==p.inviteMode then
            UIDropDownMenu_SetSelectedValue(U.modeDropdown,choice[1])
            UIDropDownMenu_SetText(U.modeDropdown,self:T(choice[2]))
        end
    end
    U.minLevel:SetText(tostring(p.minLevel or 20))
    U.maxLevel:SetText(tostring(p.maxLevel or 110))
    U.realmId:SetText(tostring(p.realmId or 44))
end

function A:UpdateMessageCounter()
    local U=self.ui;if not U or not U.msgbox then return end
    local text=U.msgbox:GetText() or ""
    local bytes=#text
    local count=self:UTF8Length(text)
    local color=bytes>255 and "|cffff6363" or "|cffb8e4b8"
    U.messageCount:SetText(color..self:T("%d символов (с пробелами) | %d / 255 байт",count,bytes).."|r")
end

function A:UpdateMessages()
    local U=self.ui;if not U then return end
    local p=self:Profile()
    local index=p.selectedTemplate or 1
    U.templateLabel:SetText(self:T("Шаблон %d из 6",index))
    U.msgbox:SetText(p.templates[index] or "")
    self:UpdateMessageCounter()
end

function A:ConfirmResetContacts()
    if StaticPopup_Show then
        StaticPopup_Show("GR735_RESET_CONTACTS")
    else
        self:Message("Не удалось открыть подтверждение сброса; история не изменена.")
    end
end

function A:ToggleMini()
    if not self.ui then return end
    if self.ui.mini:IsShown() then self.ui.mini:Hide() else self.ui.mini:Show() end
end
function A:ShowCandidates()
    if not self.ui then return end
    self.ui.list:Show();self:UpdateCandidates()
end
function A:ShowSettings()
    if not self.ui then return end
    self:UpdateSettings();self.ui.prefs:Show()
end
function A:ShowFilterWindow()
    if not self.ui then return end
    self:UpdateFilters();self.ui.filters:Show()
end
function A:ShowMessages()
    if not self.ui then return end
    self:UpdateMessages();self.ui.messages:Show()
end
