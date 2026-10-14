-- Every outgoing player action begins with a real UI click.
-- No automated bulk invitations, no note setters and no chat broadcasts.
local A=GR735
local COOLDOWN_SECONDS=30*86400

function A:TemplateText(person)
    local p=self:Profile()
    local raw=p.templates[p.selectedTemplate or 1]
    if type(raw)~="string" then return nil end
    if not raw:find("%S") then return nil,"Шаблон пустой." end
    -- A multi-line editor is allowed; one whisper is sent as one line.
    raw=raw:gsub("\r\n"," "):gsub("[\r\n]"," ")
    local guild=(GetGuildInfo and GetGuildInfo("player")) or self:T("нашей гильдии")
    local substitutions={
        ["{player}"]=person.name or "",
        ["{guild}"]=guild,
        ["{level}"]=tostring(person.level or ""),
        ["{class}"]=person.class or ""
    }
    for tag,value in pairs(substitutions) do
        raw=raw:gsub(tag, function() return value end)
    end
    if #raw>255 then
        return nil,self:T("Текст после подстановки переменных превышает 255 байт (%d).",#raw)
    end
    return raw
end

function A:ValidateTemplate(raw)
    if type(raw)~="string" then return false,"Некорректный текст." end
    if #raw>255 then return false,self:T("Шаблон превышает 255 байт (%d).",#raw) end
    return true
end

function A:RecentContact(person)
    local last=self:Profile().contacts[self:Fold(person.name)]
    if type(last)=="number" and self:WallClock()>0 then
        return self:WallClock()-last < COOLDOWN_SECONDS
    end
    return false
end

-- The cooldown tracks attempted contact; it is not a list of rejected invitations.
-- Explicit reset is per character/guild, never account-wide.
function A:ResetContacts()
    local profile=self:Profile()
    local count=0
    for _ in pairs(profile.contacts) do count=count+1 end
    profile.contacts={}
    self:Message(self:T("История контактов текущего персонажа и гильдии очищена (%d записей).",count))
    self:RefreshUI()
    return count
end

function A:DoContact(person)
    if not person or not self.candidateByName[self:Fold(person.name)] then return false end
    if self:FilterHit(person) or not self:AllowsHC(person) then
        self:Message("Кандидат больше не соответствует фильтрам.")
        return false
    end
    if self:RecentContact(person) then
        self:Message("Этого персонажа уже приглашали/писали ему в последние 30 дней.")
        return false
    end
    if InCombatLockdown and InCombatLockdown() then
        self:Message("Действие недоступно в бою.")
        return false
    end
    local mode=self:Profile().inviteMode
    if mode~="invite" and mode~="whisper" and mode~="invite_whisper" then
        self:Message("Неизвестный режим контакта.")
        return false
    end
    local message
    if mode~="invite" then
        local errorText
        message,errorText=self:TemplateText(person)
        if not message then
            self:Message(errorText or "Заполните выбранный шаблон личного сообщения.")
            return false
        end
        if not SendChatMessage then
            self:Message("Отправка личных сообщений недоступна.")
            return false
        end
    end
    -- Check invitation permission BEFORE whisper to avoid messaging when no invite is possible.
    if mode~="whisper" then
        if not self:HasInvitePermission() then
            self:Message("Нет прав приглашать в гильдию.")
            return false
        end
        if not GuildInvite then
            self:Message("Вызов приглашения недоступен.")
            return false
        end
    end
    local attempted=false
    if mode~="invite" then
        -- One manual click sends WHISPER first, without waiting for UWoW-specific
        -- localized CHAT_MSG_SYSTEM acknowledgement. pcall is NOT delivery proof.
        local ok=pcall(SendChatMessage,message,"WHISPER",nil,person.name)
        if not ok then self:Message("Не удалось вызвать отправку личного сообщения.");return false end
        attempted=true
    end
    if mode~="whisper" then
        -- The invitation is sent synchronously in the same real user click.
        local ok=pcall(GuildInvite,person.name)
        if not ok then
            if attempted then
                self:Profile().contacts[self:Fold(person.name)]=self:WallClock()
                self:Message("Запрос личного сообщения сделан, но вызов приглашения отклонён; доставка сообщения не подтверждена.")
                self:RefreshUI()
            else
                self:Message("GuildInvite отклонил вызов.")
            end
            return false
        end
        attempted=true
    end
    if attempted then
        self:Profile().contacts[self:Fold(person.name)]=self:WallClock()
        self:Message(self:T("Запрос контакта для %s отправлен (подтверждение доставки сервером отсутствует).",person.name))
        self:RefreshUI()
    end
    return attempted
end

function A:Contact(person)
    if not person then return end
    if self:Profile().hcMode=="exclude" and person.hc=="UNKNOWN" then
        if StaticPopup_Show then
            StaticPopup_Show("GR735_CONFIRM_UNKNOWN",person.name,nil,person.name)
        else
            self:Message("Статус HC неизвестен. Подтвердите вручную после включения интерфейса.")
        end
        return
    end
    self:DoContact(person)
end

