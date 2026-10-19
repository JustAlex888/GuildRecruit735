-- Original GuildRecruit735 candidate-window controls; WoW 7.3.5 / Lua 5.1.
-- Explicit slider/arrow/wheel wiring avoids relying on inherited XML callbacks.
local A=GR735
local STEP=36

local function arrow(parent,direction,callback)
    local b=CreateFrame("Button",nil,parent)
    b:SetSize(18,18);b:EnableMouse(true);b:RegisterForClicks("LeftButtonUp")
    local texture="Interface\\Buttons\\UI-ScrollBar-Scroll"..direction.."Button-"
    b:SetNormalTexture(texture.."Up");b:SetPushedTexture(texture.."Down")
    b:SetDisabledTexture(texture.."Disabled");b:SetHighlightTexture(texture.."Highlight")
    b:SetScript("OnClick",callback)
    return b
end

function A:SetCandidateScroll(value)
    local U=self.ui
    if not U or not U.candidateBar or U.candidateScrollSync then return end
    local max=U.candidateScrollMax or 0
    value=math.max(0,math.min(max,tonumber(value) or 0))
    U.candidateScrollSync=true
    U.scroll:SetVerticalScroll(value)
    U.candidateBar:SetValue(value)
    U.candidateScrollSync=false
    if value>0 then U.candidateUp:Enable() else U.candidateUp:Disable() end
    if value<max then U.candidateDown:Enable() else U.candidateDown:Disable() end
    if max>0 then U.candidateBar:Enable() else U.candidateBar:Disable() end
end

function A:ScrollCandidatesBy(steps)
    local U=self.ui;if not U then return end
    self:SetCandidateScroll((U.scroll:GetVerticalScroll() or 0)+(tonumber(steps) or 0)*STEP)
end

function A:UpdateCandidateScrollRange()
    local U=self.ui
    if not U or not U.candidateBar or U.candidateLayoutBusy or U.candidateScrollSync then return end
    local value=U.scroll:GetVerticalScroll() or 0
    U.candidateScrollMax=math.max(0,U.rowsParent:GetHeight()-U.scroll:GetHeight())
    U.candidateScrollSync=true
    U.candidateBar:SetMinMaxValues(0,U.candidateScrollMax)
    U.candidateScrollSync=false
    self:SetCandidateScroll(value)
end

function A:LayoutCandidateWindow()
    local U=self.ui;if not U or not U.candidateBar then return end
    local width,height=U.list:GetWidth(),U.list:GetHeight()
    U.pageLabel:SetWidth(width-210)
    U.listTitle:SetWidth(width-75)
    U.listClose:ClearAllPoints();U.listClose:SetPoint("TOPRIGHT",U.list,"TOPRIGHT",-11,-12)
    local captionTop=17+math.ceil(U.listTitle:GetStringHeight())+10
    U.listCaption:SetWidth(width-40)
    U.listCaption:ClearAllPoints();U.listCaption:SetPoint("TOPLEFT",U.list,"TOPLEFT",18,-captionTop)
    local top=captionTop+math.ceil(U.listCaption:GetStringHeight())+12
    U.scroll:ClearAllPoints();U.scroll:SetPoint("TOPLEFT",U.list,"TOPLEFT",17,-top)
    U.scroll:SetSize(width-62,math.max(40,height-top-60))
    U.rowsParent:SetWidth(U.scroll:GetWidth())
    local bar=U.candidateBar
    bar:ClearAllPoints();bar:SetPoint("TOPLEFT",U.scroll,"TOPRIGHT",8,-18)
    bar:SetSize(16,math.max(16,U.scroll:GetHeight()-36))
    U.candidateUp:ClearAllPoints();U.candidateUp:SetPoint("BOTTOM",bar,"TOP",0,0)
    U.candidateDown:ClearAllPoints();U.candidateDown:SetPoint("TOP",bar,"BOTTOM",0,0)
end

function A:ConstrainCandidateWindow()
    local U=self.ui;if not U then return end
    local factor=U.list:GetEffectiveScale()/UIParent:GetEffectiveScale()
    local maxW=math.max(420,UIParent:GetWidth()/factor-16)
    local maxH=math.max(240,UIParent:GetHeight()/factor-16)
    U.list:SetMinResize(420,240);U.list:SetMaxResize(maxW,maxH)
    local w=math.max(420,math.min(maxW,U.list:GetWidth()))
    local h=math.max(240,math.min(maxH,U.list:GetHeight()))
    if w~=U.list:GetWidth() or h~=U.list:GetHeight() then U.list:SetSize(w,h) end
end

function A:InitializeCandidateWindow()
    local U=self.ui;local list=U.list;local scroll=U.scroll
    local bar=CreateFrame("Slider","GR735CandidateScrollBar",list)
    U.candidateBar=bar
    bar:SetOrientation("VERTICAL");bar:SetValueStep(1)
    bar:SetMinMaxValues(0,0);bar:SetValue(0);bar:EnableMouse(true)
    bar:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background"})
    bar:SetBackdropColor(.025,.025,.025,.8)
    bar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    bar:GetThumbTexture():SetSize(16,24)
    U.candidateUp=arrow(list,"Up",function() A:ScrollCandidatesBy(-1) end)
    U.candidateDown=arrow(list,"Down",function() A:ScrollCandidatesBy(1) end)
    bar:SetScript("OnValueChanged",function(_,value) A:SetCandidateScroll(value) end)
    local function wheel(_,delta) A:ScrollCandidatesBy(-(tonumber(delta) or 0)) end
    for _,f in ipairs({list,scroll,U.rowsParent,bar}) do
        f:EnableMouseWheel(true);f:SetScript("OnMouseWheel",wheel)
    end
    scroll:SetScript("OnScrollRangeChanged",function() A:UpdateCandidateScrollRange() end)
    scroll:SetScript("OnVerticalScroll",function(_,value)
        if not U.candidateScrollSync then A:SetCandidateScroll(value) end
    end)
    list:SetResizable(true)
    local grip=CreateFrame("Button",nil,list)
    U.candidateResize=grip
    grip:SetSize(18,18);grip:SetPoint("BOTTOMRIGHT",list,"BOTTOMRIGHT",-3,3)
    grip:EnableMouse(true)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetScript("OnMouseDown",function(_,button)
        if button=="LeftButton" then
            A:ConstrainCandidateWindow();U.candidateResizing=true;list:StartSizing("BOTTOMRIGHT")
        end
    end)
    local function stop()
        if U.candidateResizing then
            list:StopMovingOrSizing();U.candidateResizing=false
            A:ConstrainCandidateWindow();A:UpdateCandidates()
        end
    end
    grip:SetScript("OnMouseUp",stop)
    list:HookScript("OnHide",stop)
    list:SetScript("OnSizeChanged",function()
        if not U.candidateLayoutBusy then A:UpdateCandidates() end
    end)
    local events=CreateFrame("Frame",nil,UIParent)
    U.candidateWindowEvents=events
    events:RegisterEvent("DISPLAY_SIZE_CHANGED");events:RegisterEvent("UI_SCALE_CHANGED")
    events:SetScript("OnEvent",function() A:ConstrainCandidateWindow();A:UpdateCandidates() end)
    A:ConstrainCandidateWindow()
end
