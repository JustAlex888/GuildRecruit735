-- Behavioral acceptance against the actual loaded UI/controller, with explicit
-- WoW frame doubles supplied by test_runtime. STATIC only, never a game run.
return function(A,frames,ok)
    local U=A.ui
    local function click(b) b.scripts.OnClick(b,"LeftButton") end
    local function close(f)
        for _,b in ipairs(frames) do
            if b.parent==f and b.type=="Button" and b:GetText()=="X" then click(b);return end
        end
        error("Missing close button")
    end
    local function family(settings,messages,filters)
        ok(U.prefs:IsShown()==settings and U.messages:IsShown()==messages and U.filters:IsShown()==filters,
            "family visibility "..tostring(settings).."/"..tostring(messages).."/"..tostring(filters))
    end
    A:CloseSettingsFamily();U.mini:Hide();U.list:Hide()
    A:ToggleMini();click(U.settingsButton);family(true,false,false)
    click(U.messagesButton);family(true,true,false)
    click(U.filtersButton);family(true,true,true)
    click(U.messagesButton);family(true,false,true)
    click(U.messagesButton);click(U.filtersButton);family(true,true,false)
    click(U.filtersButton);family(true,true,true)
    click(U.settingsButton);family(false,false,false)
    ok(U.mini:IsShown(),"settings toggle leaves mini shown")
    click(U.settingsButton);family(true,false,false)
    click(U.messagesButton);click(U.filtersButton);close(U.prefs);family(false,false,false)
    click(U.settingsButton);click(U.messagesButton);click(U.filtersButton)
    close(U.messages);family(true,false,true)
    click(U.messagesButton);close(U.filters);family(true,true,false)
    click(U.filtersButton)
    A:ShowCandidates();U.scroll:SetVerticalScroll(19)
    U.list:SetPoint("TOPLEFT",UIParent,"TOPLEFT",60,-60)
    local listPoint=U.list.point
    local candidates=A.candidates
    click(U.settingsButton);family(false,false,false)
    click(U.settingsButton);family(true,false,false)
    ok(U.list:IsShown() and U.scroll:GetVerticalScroll()==19 and U.list.point==listPoint and A.candidates==candidates,
        "settings lifecycle preserves floating list, scroll and results")
    click(U.messagesButton);click(U.filtersButton);close(U.mini);family(false,false,false)
    ok(U.list:IsShown(),"mini X leaves independent player list")
    A:ToggleMini();click(U.settingsButton);click(U.messagesButton);click(U.filtersButton)
    A:ToggleMini();family(false,false,false)
    A:ToggleMini();click(U.settingsButton);family(true,false,false)
    ok(not U.prefs.movable and not U.messages.movable and not U.filters.movable and U.list.movable,
        "docks cannot drift independently, list retains drag")
    ok(U.prefs.point[1]=="TOPRIGHT" and U.prefs.point[2]==U.mini and U.prefs.point[3]=="BOTTOMRIGHT",
        "settings right edge anchored below mini")
    ok(U.messages.point[1]=="TOPLEFT" and U.messages.point[2]==U.prefs and U.messages.point[3]=="BOTTOMLEFT",
        "messages anchored below settings")
    ok(U.filters.point[1]=="TOPLEFT" and U.filters.point[2]==U.prefs and U.filters.point[3]=="TOPRIGHT",
        "filters anchored right of settings")
    -- Unsaved drafts survive hide/show, sibling toggles and template arrows.
    click(U.messagesButton)
    local p=A:Profile();p.selectedTemplate=1;A:UpdateMessages()
    local saved=p.templates[1]
    U.msgbox:SetText("Черновик {player} / draft")
    click(U.messagesButton);click(U.filtersButton);click(U.messagesButton)
    ok(U.msgbox:GetText()=="Черновик {player} / draft" and p.templates[1]==saved,
        "sibling switches preserve draft without implicit save")
    click(U.nextTemplate);U.msgbox:SetText("draft two")
    click(U.previousTemplate)
    ok(U.msgbox:GetText()=="Черновик {player} / draft","template arrows retain per-template draft")
    A:CloseSettingsFamily();A:OpenSettings();click(U.messagesButton)
    ok(U.msgbox:GetText()=="Черновик {player} / draft","settings cascade does not discard message draft")
    click(U.saveMessage)
    ok(p.templates[1]=="Черновик {player} / draft","only explicit save stores draft")
    local checks=0;for _ in pairs(U.classChecks) do checks=checks+1 end
    ok(checks==12,"all 12 class checkboxes remain")
    local oldFilters=GR735DB.filters
    GR735DB.filters={};A:UpdateFilters()
    ok(U.filterScroll:GetHeight()==32,"empty names list is compact")
    local ids={}
    for i=1,7 do local yes,id=A:AddNameExclusion("dock"..i);ok(yes,"add scroll fixture filter");ids[i]=id end
    A:UpdateFilters()
    ok(#GR735DB.filters==7 and U.filterScroll:GetHeight()==128,"seven saved filters, exactly four visible rows")
    ok(U.filterParent:GetHeight()==224,"scroll child contains every saved row")
    U.filterScroll:SetVerticalScroll(96)
    local last=U.filterButtons[7]
    ok(last.filterId==ids[7] and last.point[5]==-192,"scroll reaches seventh row with unchanged identity")
    click(last);ok(p.activeFilters[ids[7]]==true,"seventh filter toggles current profile")
    for i=7,2,-1 do A:DeleteFilter(ids[i]) end
    ok(U.filterScroll:GetHeight()==32,"one filter uses one visible row")
    A:DeleteFilter(ids[1]);GR735DB.filters=oldFilters;A:UpdateFilters()
    -- Counters are the scanner's real categories, never total minus excluded.
    local oldStats=A.scan.stats
    A.scan.stats={rows=20,unguilded=15,filtered=4,hardcore=1,duplicates=2}
    A:UpdateMini()
    ok(U.counter:GetText()==A:T("Всего: %d | Исключено: %d | Без гильдии: %d",20,5,15),"real overlapping scan statistics shown")
    local templates,contacts,filters,classes=p.templates,p.contacts,p.activeFilters,p.excludedClasses
    click(U.clearButton)
    ok(p.templates==templates and p.contacts==contacts and p.activeFilters==filters and p.excludedClasses==classes,
        "clear scan preserves all profile tables")
    ok(A.scan.stats.rows==0 and A.scan.stats.unguilded==0,"clear resets scan counters")
    A.scan.stats=oldStats
    -- All visible families fit edge placements and screen/UI scale combinations.
    local resolutions={{1920,1080},{1280,720},{1024,768},{800,600}}
    for _,size in ipairs(resolutions) do
        for _,globalScale in ipairs({.64,1,1.25}) do
            UIParent:SetSize(size[1]/globalScale,size[2]/globalScale)
            for _,edge in ipairs({{0,0},{0,1},{1,0},{1,1}}) do
                A:CloseSettingsFamily();A:OpenSettings()
                U.mini:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",edge[1]*UIParent.w,edge[2]*UIParent.h)
                click(U.messagesButton);click(U.filtersButton)
                A:FitDockedPanels()
                for _,f in ipairs({U.mini,U.prefs,U.messages,U.filters}) do
                    local l,b,r,t=f:Bounds()
                    ok(l>=7.99 and b>=7.99 and r<=UIParent.w-7.99 and t<=UIParent.h-7.99,
                        "visible family fits "..size[1].."x"..size[2].." scale "..globalScale)
                end
                local points={U.prefs.point,U.messages.point,U.filters.point}
                U.mini.scripts.OnDragStart(U.mini);U.mini.scripts.OnDragStop(U.mini)
                ok(U.prefs.point==points[1] and U.messages.point==points[2] and U.filters.point==points[3],
                    "drag preserves relative dock anchors")
                ok(U.list.point==listPoint,"drag does not move independent list")
            end
        end
    end
    UIParent:SetSize(1920,1080);A:FitDockedPanels()
    -- Esc traverses the actual registered frames; no child/menu retains input.
    U.modeDropdown.scripts.OnClick(U.modeDropdown)
    U.msgbox:SetFocus()
    for _,name in ipairs(UISpecialFrames) do local f=_G[name];if f then f:Hide() end end
    family(false,false,false)
    ok(not U.modeDropdown.choiceMenu:IsShown() and not U.msgbox:HasFocus(),"Esc cleans private menus and editor focus")
    for _,f in ipairs({U.prefs,U.messages,U.filters,U.hcDropdown.choiceMenu,U.modeDropdown.choiceMenu}) do
        ok(not f:IsVisible(),"hidden controls cannot intercept mouse by effective visibility")
    end
    A:OpenSettings();click(U.messagesButton);click(U.filtersButton)
    print("GR735 docking matrix PASS")
end
