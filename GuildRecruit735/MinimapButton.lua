-- Original GuildRecruit735 minimap launcher. MIT License.
-- No external library or Guild Control/SuperGuildInvite code is included.
local A=GR735
local DEFAULT_ANGLE=225
local RADIUS=81
local cos,sin,rad=math.cos,math.sin,math.rad

local function minimapPrefs()
    A:Store()
    if type(GR735DB.minimap)~="table" then GR735DB.minimap={} end
    local prefs=GR735DB.minimap
    local a=tonumber(prefs.angle)
    if not a or a~=a or a<-36000 or a>36000 then a=DEFAULT_ANGLE end
    prefs.angle=a%360
    prefs.hidden=prefs.hidden==true
    return prefs
end

local function currentCursorAngle()
    if not Minimap or not Minimap.GetCenter or not GetCursorPosition then return nil end
    local cx,cy=Minimap:GetCenter()
    if not cx or not cy then return nil end
    local x,y=GetCursorPosition()
    if not x or not y then return nil end
    local scale=(Minimap.GetEffectiveScale and Minimap:GetEffectiveScale()) or 1
    if scale<=0 then return nil end
    local dx,dy=x/scale-cx,y/scale-cy
    if dx==0 and dy==0 then return nil end
    -- math.atan(y,x) is not portable across Lua 5.1 builds.
    local angle
    if math.atan2 then
        angle=math.atan2(dy,dx)
    elseif dx==0 then
        angle=dy>0 and math.pi/2 or -math.pi/2
    else
        angle=math.atan(dy/dx)
        if dx<0 then angle=angle+math.pi end
    end
    return (math.deg(angle)+360)%360
end

function A:PositionMinimapButton()
    local b=self.minimapButton
    if not b or not Minimap then return end
    local a=rad(minimapPrefs().angle)
    b:ClearAllPoints()
    b:SetPoint("CENTER",Minimap,"CENTER",RADIUS*cos(a),RADIUS*sin(a))
end

function A:CreateMinimapButton()
    if self.minimapButton then return self.minimapButton end
    if not Minimap or not CreateFrame then return nil end
    local b=CreateFrame("Button","GR735MinimapLauncher",Minimap)
    self.minimapButton=b
    b:SetSize(31,31)
    b:SetFrameStrata("HIGH")
    if Minimap.GetFrameLevel and b.SetFrameLevel then
        b:SetFrameLevel((Minimap:GetFrameLevel() or 0)+8)
    end
    b:EnableMouse(true)
    b:RegisterForClicks("LeftButtonUp","RightButtonUp")
    b:RegisterForDrag("LeftButton")

    -- The Blizzard mini-map style uses a tiny icon and an alpha-masked
    -- circular rim; no opaque square texture or external art is bundled.
    -- Decorations are Texture regions, never separate mouse-catching frames.
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local background=b:CreateTexture(nil,"BACKGROUND")
    background:SetSize(20,20)
    background:SetPoint("TOPLEFT",b,"TOPLEFT",6,-5)
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    b.background=background

    -- This classic Blizzard icon is a silhouette of players looking for
    -- a group; it is present in the 7.3.5 client, not copied from Oilvl.
    local emblem=b:CreateTexture(nil,"ARTWORK")
    emblem:SetSize(17,17)
    emblem:SetPoint("CENTER",background,"CENTER",0,0)
    emblem:SetTexture("Interface\\Icons\\INV_Misc_GroupLooking")
    emblem:SetTexCoord(.08,.92,.08,.92)
    b.icon=emblem

    -- The client texture contains the round rim within a larger transparent
    -- atlas. Keep that transparent margin, instead of stretching it across
    -- the whole clickable frame (the source of the square-looking old icon).
    local rim=b:CreateTexture(nil,"OVERLAY")
    rim:SetSize(53,53)
    rim:SetPoint("TOPLEFT",b,"TOPLEFT",0,0)
    rim:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    b.border=rim

    b:SetScript("OnEnter",function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self,"ANCHOR_LEFT")
        GameTooltip:AddLine("GuildRecruit735",1,.85,.35)
        GameTooltip:AddLine(A:T("ЛКМ — открыть/закрыть | ПКМ — настройки"),1,1,1,true)
        GameTooltip:AddLine(A:T("Перетащить — переместить вокруг мини-карты"),.8,.8,.8,true)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave",function()
        if GameTooltip then GameTooltip:Hide() end
    end)
    b:SetScript("OnClick",function(self,mouse)
        -- An OnClick emitted when finishing a drag must not toggle an addon window.
        if self.dragFinished and A:Clock()-self.dragFinished<.16 then return end
        if mouse=="LeftButton" then
            A:ToggleMini()
        elseif mouse=="RightButton" then
            A:ShowSettings()
        end
    end)
    b:SetScript("OnDragStart",function(self)
        self.isDragging=true
        if GameTooltip then GameTooltip:Hide() end
        self:SetScript("OnUpdate",function()
            local a=currentCursorAngle()
            if a then
                minimapPrefs().angle=a
                A:PositionMinimapButton()
            end
        end)
    end)
    b:SetScript("OnDragStop",function(self)
        self.isDragging=false
        self:SetScript("OnUpdate",nil)
        self.dragFinished=A:Clock()
    end)

    self:PositionMinimapButton()
    if minimapPrefs().hidden then b:Hide() else b:Show() end
    return b
end

function A:ToggleMinimapButton()
    local b=self:CreateMinimapButton()
    if not b then self:Message("Мини-карта пока недоступна; используйте /gr735.");return end
    local prefs=minimapPrefs()
    prefs.hidden=not prefs.hidden
    if prefs.hidden then b:Hide() else b:Show() end
    self:Message(prefs.hidden and "Кнопка мини-карты скрыта (/gr735 minimap — вернуть)." or "Кнопка мини-карты показана.")
end
