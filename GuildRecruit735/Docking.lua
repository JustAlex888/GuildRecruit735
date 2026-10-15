-- GuildRecruit735: original independent docking controller (Lua 5.1 / 70300).
-- Guild Control735 was read as a UX reference only; no code dependency.
local A=GR735
local GAP=4

local function dismiss(frame)
    if frame then frame:Hide() end
    if GameTooltip then GameTooltip:Hide() end
end

function A:CloseSettingsFamily()
    local U=self.ui;if not U then return end
    dismiss(U.messages);dismiss(U.filters)
    if U.msgbox then U.msgbox:ClearFocus() end
    dismiss(U.prefs)
    self:FitDockedPanels()
end

function A:OpenSettings()
    local U=self.ui;if not U then return end
    if not U.prefs:IsShown() then
        dismiss(U.messages);dismiss(U.filters)
        U.mini:Show()
        self:UpdateSettings();U.prefs:Show()
    end
    self:FitDockedPanels()
end

function A:ToggleSettings()
    if not self.ui then return end
    if self.ui.prefs:IsShown() then self:CloseSettingsFamily() else self:OpenSettings() end
end

function A:ToggleDock(kind)
    local U=self.ui;if not U then return end
    self:OpenSettings()
    local f=U[kind];if not f then return end
    if f:IsShown() then
        dismiss(f)
    else
        if kind=="messages" then self:UpdateMessages() else self:UpdateFilters() end
        f:Show()
    end
    self:FitDockedPanels()
end

-- Fit the complete visible footprint. Scale only this addon, never the global UI.
-- Children inherit mini's scale; only mini is repositioned, preserving all anchors.
function A:FitDockedPanels()
    local U=self.ui
    if not U or not U.prefs or U.fitting then return end
    local sw,sh=UIParent:GetWidth(),UIParent:GetHeight()
    if not sw or not sh or sw<=0 or sh<=0 then return end
    U.fitting=true
    local left,right,down=0,0,U.mini:GetHeight()
    if U.prefs:IsShown() then
        left=U.prefs:GetWidth()-U.mini:GetWidth()
        down=down+GAP+U.prefs:GetHeight()
        if U.messages:IsShown() then down=down+GAP+U.messages:GetHeight() end
        if U.filters:IsShown() then
            right=GAP+U.filters:GetWidth()
            down=math.max(down,U.mini:GetHeight()+GAP+U.filters:GetHeight())
        end
    end
    local scale=math.min(1,(sw-16)/(left+U.mini:GetWidth()+right),(sh-16)/down)
    U.mini:SetScale(scale)
    if U.mini.SetClampRectInsets then
        U.mini:SetClampRectInsets(-left,-right,0,-(down-U.mini:GetHeight()))
    end
    local x,y=U.mini:GetLeft(),U.mini:GetTop()
    if x and y then
        local lo=8+left*scale
        local hi=sw-8-(U.mini:GetWidth()+right)*scale
        local topLo=8+down*scale
        local topHi=sh-8
        local px=math.max(lo,math.min(hi,x*scale))
        local py=math.max(topLo,math.min(topHi,y*scale))
        U.mini:ClearAllPoints()
        U.mini:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",px/scale,py/scale)
    end
    U.fitting=false
end

function A:InitializeDocking()
    local U=self.ui
    U.prefs:ClearAllPoints();U.prefs:SetPoint("TOPRIGHT",U.mini,"BOTTOMRIGHT",0,-GAP)
    U.messages:ClearAllPoints();U.messages:SetPoint("TOPLEFT",U.prefs,"BOTTOMLEFT",0,-GAP)
    U.filters:ClearAllPoints();U.filters:SetPoint("TOPLEFT",U.prefs,"TOPRIGHT",GAP,0)
    U.prefs:SetFrameLevel(U.mini:GetFrameLevel()+2)
    U.messages:SetFrameLevel(U.prefs:GetFrameLevel()+2)
    U.filters:SetFrameLevel(U.prefs:GetFrameLevel()+2)
    local p=self:Profile()
    U.mini:ClearAllPoints()
    U.mini:SetPoint("CENTER",UIParent,"CENTER",p.panelX or 0,p.panelY or 125)
    U.mini:SetScript("OnDragStop",function(f)
        f:StopMovingOrSizing();A:FitDockedPanels()
        local x,y=f:GetCenter();local cx,cy=UIParent:GetCenter()
        if x and y and cx and cy then
            local scale=f:GetScale()
            local profile=A:Profile()
            profile.panelX=x*scale-cx;profile.panelY=y*scale-cy
        end
    end)
    U.mini:HookScript("OnHide",function() A:CloseSettingsFamily() end)
    U.list:HookScript("OnHide",function() if GameTooltip then GameTooltip:Hide() end end)
    U.prefs:HookScript("OnHide",function()
        dismiss(U.messages);dismiss(U.filters)
        U.msgbox:ClearFocus()
        A:FitDockedPanels()
    end)
    U.messages:HookScript("OnHide",function()
        U.msgbox:ClearFocus();if GameTooltip then GameTooltip:Hide() end
        A:FitDockedPanels()
    end)
    U.filters:HookScript("OnHide",function()
        U.nameExclusion:ClearFocus();if GameTooltip then GameTooltip:Hide() end
        A:FitDockedPanels()
    end)
    U.mini:HookScript("OnShow",function() A:FitDockedPanels() end)
    local events=CreateFrame("Frame",nil,UIParent)
    events:RegisterEvent("DISPLAY_SIZE_CHANGED");events:RegisterEvent("UI_SCALE_CHANGED")
    events:SetScript("OnEvent",function() A:FitDockedPanels() end)
    U.layoutEvents=events
end
