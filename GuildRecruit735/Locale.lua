-- GuildRecruit735 localization. Original MIT code; WoW Legion 7.3.5 / Lua 5.1.
-- Russian is the original UI source. English entries cover every displayed source label.
-- User-authored messages, filter values, character/guild names and server WHO names are NEVER translated.
local A=GR735
local EN={
    ["Версия %s / %s"]="Version %s / %s",
    ["Смена гильдии"]="Guild changed",
    ["Остановлено вручную"]="Stopped manually",
    ["Остановлено перед очисткой"]="Stopped before clearing",
    ["Остановлено"]="Stopped",
    ["Ожидание сканирования"]="Ready to scan",
    ["Сканирование"]="Scan",
    ["Ожидание HC"]="Waiting for HC data",
    ["Поиск /who"]="Searching /who",
    ["Подходящих: 0 | Запросов /who: 0"]="Eligible: 0 | /who queries: 0",
    ["Подходящих: %d | Запросов /who: %d"]="Eligible: %d | /who queries: %d",
    ["Сканирование не запускалось"]="No scan started yet",
    ["Ответов WHO: %d | Без гильдии: %d | Исключено: %d"]="WHO results: %d | Guildless: %d | Excluded: %d",
    ["Ожидание ответа сервера..."]="Waiting for server response...",
    ["Результатов сканирования пока нет"]="No scan results yet",
    ["Показать игроков (0)"]="Show players (0)",
    ["Показать игроков (%d)"]="Show players (%d)",
    ["Стоп"]="Stop",
    ["Очистить"]="Clear",
    ["Настройки"]="Settings",
    ["Очищает результаты текущего сканирования, но не настройки и фильтры."]="Clears the current scan results, not your settings or filters.",
    ["Найденные игроки — выбирайте вручную"]="Found players — select manually",
    ["Массовых приглашений нет."]="There are no bulk invitations.",
    ["Кандидатов: %d; показаны первые %d. ЛКМ — выбранное действие, массового приглашения нет."]="Candidates: %d; showing first %d. Left-click to contact; no bulk invites.",
    ["ур."]="lvl.",
    ["Hardcore: подтверждён ладдером."]="Hardcore: confirmed by the leaderboard.",
    ["Hardcore: статус неизвестен. При выборе в режиме исключения HC потребуется подтверждение."]="Hardcore: unknown status. Exclude-HC mode will ask for confirmation before contacting.",
    ["GuildRecruit735 — настройки"]="GuildRecruit735 — settings",
    ["Режим Hardcore:"]="Hardcore mode:",
    ["Действие при выборе игрока:"]="Action when selecting a player:",
    ["Уровни поиска (20–110 по умолчанию):"]="Level range (default 20–110):",
    ["World ID для HC (x1 = 44):"]="HC world ID (x1 = 44):",
    ["Сохранить настройки поиска"]="Save search settings",
    ["Некорректный уровень или World ID."]="Invalid level range or world ID.",
    ["Настройки поиска сохранены для этого персонажа и гильдии."]="Search settings saved for this character and guild.",
    ["Фильтры"]="Filters",
    ["Сообщения"]="Messages",
    ["Сбросить историю контактов (30 дней)"]="Reset contact history (30 days)",
    ["Каталог имён общий; фильтры включаются отдельно для персонажа."]="Name filters are shared; each character enables its own filters.",
    ["Фильтры игроков"]="Player filters",
    ["Исключения. ЛКМ — включить/выключить; ПКМ — удалить с подтверждением."]="Exclusions. Left-click: toggle; right-click: confirm deletion.",
    ["Имена"]="Names",
    ["Классы"]="Classes",
    ["Исключение по имени"]="Name exclusion",
    ["Исключение по имени: %s"]="Name exclusion: %s",
    ["Добавить"]="Add",
    ["Исключение добавлено в общий каталог; пока выключено."]="Exclusion added to the shared list; currently disabled.",
    ["Исключений пока нет."]="No exclusions yet.",
    ["Закрыть"]="Close",
    ["Не показывать игроков выбранных классов:"]="Hide players of the selected classes:",
    ["[ВКЛ]"]="[ON]",
    ["[ВЫКЛ]"]="[OFF]",
    ["Имя"]="Name",
    ["Класс"]="Class",
    ["Гильдия (старый)"]="Guild (legacy)",
    ["Суффикс (старый)"]="Suffix (legacy)",
    ["Класс (старый)"]="Class (legacy)",
    ["Старый фильтр"]="Legacy filter",
    ["Воин"]="Warrior",
    ["Паладин"]="Paladin",
    ["Рыцарь смерти"]="Death Knight",
    ["Охотник"]="Hunter",
    ["Разбойник"]="Rogue",
    ["Жрец"]="Priest",
    ["Шаман"]="Shaman",
    ["Маг"]="Mage",
    ["Чернокнижник"]="Warlock",
    ["Монах"]="Monk",
    ["Друид"]="Druid",
    ["Охотник на демонов"]="Demon Hunter",
    ["Шаблоны личных сообщений"]="Whisper templates",
    ["Шаблон 1 из 6"]="Template 1 of 6",
    ["Шаблон %d из 6"]="Template %d of 6",
    ["0 символов (с пробелами) | 0 / 255 байт"]="0 characters (incl. spaces) | 0 / 255 bytes",
    ["%d символов (с пробелами) | %d / 255 байт"]="%d characters (incl. spaces) | %d / 255 bytes",
    ["Переменные: {player}, {guild}, {level}, {class}."]="Variables: {player}, {guild}, {level}, {class}.",
    ["Пример: Привет, {player}! Приглашаем тебя в гильдию {guild}."]="Example: Hi {player}! Join our guild, {guild}.",
    ["Переносы строк при отправке заменяются пробелами."]="Line breaks are replaced with spaces when sending.",
    ["Сохранить шаблон"]="Save template",
    ["Шаблон сохранён для этого персонажа и гильдии."]="Template saved for this character and guild.",
    ["Удалить фильтр «%s» из ОБЩЕГО каталога этого WoW-аккаунта?"]="Remove filter '%s' from the SHARED list for this WoW account?",
    ["Удалить"]="Delete",
    ["Отмена"]="Cancel",
    ["Очистить всю историю контактов (30 дней) ТОЛЬКО для этого персонажа и гильдии? Фильтры и шаблоны останутся."]="Clear all 30-day contact history ONLY for this character and guild? Filters and templates will remain.",
    ["Статус HC игрока %s не подтверждён. Всё равно выполнить выбранное действие?"]="Hardcore status of %s is unconfirmed. Proceed with the selected action anyway?",
    ["Да"]="Yes",
    ["Исключать HC"]="Exclude HC",
    ["Только HC"]="HC only",
    ["Все игроки"]="All players",
    ["Только приглашение"]="Invite only",
    ["Сообщение, затем приглашение"]="Whisper, then invite",
    ["Только сообщение"]="Whisper only",
    ["Не удалось открыть подтверждение сброса; история не изменена."]="Could not open reset confirmation; history was not changed.",
    ["Проверьте название, условие и тип фильтра."]="Check the filter name, value and type.",
    ["Такой фильтр уже существует."]="This filter already exists.",
    ["Введите имя или часть имени."]="Enter a name or part of a name.",
    ["Такое исключение уже существует."]="This exclusion already exists.",
    ["HC: %s; мир %s; строк %d; дата %s"]="HC: %s; world %s; rows %d; date %s",
    ["данные сохранены"]="cached data available",
    ["неизвестно"]="unknown",
    ["HC-запрос недоступен; используется сохранённый ладдер."]="HC request unavailable; using cached leaderboard data.",
    ["HC-данные недоступны; поиск не запущен"]="HC data unavailable; scan not started",
    ["Завершено (неполный /who)"]="Finished (partial /who results)",
    ["Завершено"]="Finished",
    ["Нет полного HC-ладдера: безопасная остановка"]="HC leaderboard incomplete: scan safely stopped",
    ["WHO: нет ответа за 45 секунд"]="WHO: no response within 45 seconds",
    ["WHO: ограничение 120 запросов"]="WHO: limit of 120 requests reached",
    ["WHO API недоступен в этом клиенте"]="WHO API unavailable in this client",
    ["WHO API отклонил запрос"]="WHO API rejected the request",
    ["WHO: ошибка чтения результатов"]="WHO: failed to read results",
    ["Шаблон пустой."]="Template is empty.",
    ["нашей гильдии"]="our guild",
    ["Текст после подстановки переменных превышает 255 байт (%d)."]="Expanded message exceeds 255 bytes (%d).",
    ["Некорректный текст."]="Invalid message text.",
    ["Шаблон превышает 255 байт (%d)."]="Template exceeds 255 bytes (%d).",
    ["История контактов текущего персонажа и гильдии очищена (%d записей)."]="Contact history cleared for this character and guild (%d entries).",
    ["Кандидат больше не соответствует фильтрам."]="Candidate no longer passes the filters.",
    ["Этого персонажа уже приглашали/писали ему в последние 30 дней."]="This player was already contacted in the last 30 days.",
    ["Действие недоступно в бою."]="Action unavailable during combat.",
    ["Неизвестный режим контакта."]="Unknown contact mode.",
    ["Заполните выбранный шаблон личного сообщения."]="Fill in the selected whisper template.",
    ["Отправка личных сообщений недоступна."]="Whisper sending is unavailable.",
    ["Нет прав приглашать в гильдию."]="You do not have permission to invite to the guild.",
    ["Вызов приглашения недоступен."]="Guild invitation API is unavailable.",
    ["Не удалось вызвать отправку личного сообщения."]="Could not initiate sending a whisper.",
    ["Запрос личного сообщения сделан, но вызов приглашения отклонён; доставка сообщения не подтверждена."]="Whisper request made, but guild invite call failed; whisper delivery is unconfirmed.",
    ["GuildInvite отклонил вызов."]="GuildInvite call failed.",
    ["Запрос контакта для %s отправлен (подтверждение доставки сервером отсутствует)."]="Contact request sent for %s (server delivery not confirmed).",
    ["Статус HC неизвестен. Подтвердите вручную после включения интерфейса."]="HC status unknown. Confirm manually after enabling the interface.",
    ["ЛКМ — открыть/закрыть | ПКМ — настройки"]="Left-click: toggle | Right-click: settings",
    ["Перетащить — переместить вокруг мини-карты"]="Drag to reposition around the minimap",
    ["Мини-карта пока недоступна; используйте /gr735."]="Minimap unavailable; use /gr735.",
    ["Кнопка мини-карты скрыта (/gr735 minimap — вернуть)."]="Minimap button hidden (use /gr735 minimap to restore).",
    ["Кнопка мини-карты показана."]="Minimap button shown.",
    ["Язык интерфейса: %s. Выбор: /gr735 lang ru|en|auto."]="Interface language: %s. Choose: /gr735 lang ru|en|auto.",
    ["Язык интерфейса сохранён. Выполните /reload, чтобы обновить окна."]="Interface language saved. Use /reload to refresh the windows.",
    ["Неизвестный язык. Используйте /gr735 lang ru|en|auto."]="Unknown language. Use /gr735 lang ru|en|auto.",
}

function A:Language()
    local pref=type(GR735DB)=="table" and GR735DB.language or "auto"
    if pref=="ru" or pref=="en" then return pref end
    if GetLocale then
        local loc=GetLocale()
        if loc=="ruRU" then return "ru" end
        if type(loc)=="string" then return "en" end
    end
    return "ru" -- Conservative fallback when the client API is unavailable in tests.
end

-- Source strings are intentionally Russian, so existing ruRU UI is byte-for-byte unchanged.
-- Formatting is only applied for messages with explicit arguments; the same arguments
-- are used regardless of locale, and user templates never pass through this function.
function A:T(source,...)
    if type(source)~="string" then return source or "" end
    local translated=self:Language()=="en" and (EN[source] or source) or source
    if select("#",...)>0 then return string.format(translated,...) end
    return translated
end

function A:SelectLanguage(arg)
    arg=(arg or ""):match("^%s*(.-)%s*$"):lower()
    if arg=="" then
        self:Message(self:T("Язык интерфейса: %s. Выбор: /gr735 lang ru|en|auto.",self:Language()))
        return
    end
    if arg~="ru" and arg~="en" and arg~="auto" then
        self:Message(self:T("Неизвестный язык. Используйте /gr735 lang ru|en|auto."))
        return
    end
    self:Store()
    GR735DB.language=arg
    self:Message(self:T("Язык интерфейса сохранён. Выполните /reload, чтобы обновить окна."))
end

-- Exposed only to off-line tests; no external libraries or character data.
A._ENLocalization=EN
