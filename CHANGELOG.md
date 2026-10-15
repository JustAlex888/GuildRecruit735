# Changelog

## 1.0.4 — GR735-20261015-04 — 2026-10-15

Compact mini panel and docked settings/messages/filters; independent child toggles and family close; floating player list retained. Four visible name-filter rows with scrolling, twelve classes, six templates and draft retention. Original scan/HC/contact/filter model and SavedVariables retained. User accepted interface/filter behavior on the immediate 1.0.4-TEST parent. Final release changes only version/build metadata in the addon relative to that parent. Updated RU/EN documentation, current user-provided screenshot and docking regression tests. No code or asset dependency on Guild Control735.


## 1.0.2 — GR735-20261015-01 — 2026-10-15 — public stable release

Canonical direct TEST parent `1.0.2-TEST / GR735-20261014-05`, install SHA-256 `3e401fe4be322b626c27ed8df2cfb17807f51a81d818cd16d1b6e9bc87a35620`, source SHA-256 `07e8fa0b4757854de674fd39dd097a3c23362209f774ca47e19ce4d270bb958c`; provenance `GR735_20261015_01_FROM_GR735_20261014_05_3e401fe4_RELEASE_1_0_2_METADATA_ONLY`. This stable release alters `Core.lua` only VERSION/BUILD and `.toc` release metadata; all 7 other gameplay Lua and MIT LICENSE are byte-identical to the exact candidate. Existing SavedVariables and profiles are kept.

The cumulative 1.0.1-TEST and 1.0.2-TEST improvements since public v1.0.0 are: WHO candidate exclusion of attempted contacts for 30 days; independent HC/contact-choice menus mitigating a possible shared Blizzard UIDropDownMenu taint path (not a confirmed in-game root-cause fix); automatic level-range persistence with explicit Save still supported. User reported successfully retesting level-range saving in-game on 1.0.2-TEST; game coverage for exact stable build and full HC/x100/taint scenarios remains limited. Native Lua5.1/fixtures/packaging verification via GitHub Actions before release attachment.

---

## 1.0.2-TEST — GR735-20261014-05 — 2026-10-14 — private level-range fix TEST

Derived **only** from independent own `1.0.1-TEST / GR735-20261014-04` install SHA `b3968318ccda97a4825255f99d224a895911b4e33776ee9dfa4b6b0132769b28`, source SHA `1970fb1317a2b21eb94fa880b2a18331f85f3e0960a83957b6a38319f13f8085`. Provenance `GR735_20261014_05_FROM_GR735_20261014_04_b3968318_LEVEL_RANGE_AUTOSAVE`.

- **UI.lua**: user-reported regression — the level EditBoxes accepted text but silently reverted after closing/reopening preferences unless the separate Save button was clicked. Valid min/max (1..110, min<=max) and HC World ID now persist in the existing character/guild profile on user input, focus loss, Enter, and settings close; explicit Save remains. Invalid/incomplete values do not corrupt SavedVariables. Next manual `SendWho` consumes the saved range (fixture `10-90`). No schema changes.
- **Core.lua and .toc**: only release test version/build. Scanner.lua 30-day suppression, independent action/HC menus taint mitigation candidate, filters, HC, messages, minimap and all other runtime files remain byte-identical to 1.0.1-TEST.
- Local RU/EN mocked regression, scoped STATIC and syntax pass; exact 1.0.2-TEST in-game level-persistence recheck and native Lua 5.1 remain pending. Public GitHub v1.0.0 unchanged, 1.0.1-TEST remains historical user rollback.

## 1.0.1-TEST — GR735-20261014-04 — 2026-10-14 — internal TEST candidate

Based strictly on independent `1.0.0 / GR735-20261014-03` install SHA-256 `2684688b426d42d9c4bee8bae60ee43642ab429f935733fa6f1a3f0bc6f7f788`, source SHA `3d5bf874a10e5d9d163753164ff3b4ef42f15fc6e7b9b8e916f811196463a90e`; provenance `GR735_20261014_04_FROM_GR735_20261014_03_2684688b_WHO_CONTACT_HIDE_CUSTOM_DROPDOWN`.

- **Scanner.lua**: 30-day existing per-character/guild attempted-contact history is now checked when accepting WHO results into candidate list. Previously contacted guildless players count under `Исключено` and are not displayed on subsequent scans. Expired or explicitly reset entries can be shown again. No data migration, no change to contact send/cooldown semantics or class/HC filters.
- **UI.lua**: replace two Blizzard `UIDropDownMenu_*` selectors (HC and contact action modes) with independent original button/list controls. This removes a documented global-dropdown taint pathway associated with `CompactRaidFrame*:Show()` blocks in WoW. BugGrabber shows GuildRecruit735-attributed raid-frame taint in sessions 119 and 163; **specific causal chain is CANDIDATE**, not proven without client taint.log. Removal is `STATIC_VERIFIED_RISK_REDUCTION`, game taint regression **NOT_OBSERVED**.
- **Core.lua** and `.toc`: 1.0.1-TEST and exact build ID only; all other Lua files remain unchanged. `GR735DB`, `GR735CharDB`, profile format, WHO request limits, Hardcore/world44, message templates, minimap, explicit WHISPER-first and reset remain unchanged.
- User's two raw BugGrabber files are preserved in `System GPT`; other DBM, WeakAuras, Spammy, GuildControl and other add-on signatures have **no proven relation** to GuildRecruit735 and are not modified.
- Requires `GAME_TEST_006` to verify contact exclusion, custom selectors, and whether raid-frame action-blocked error recurs in natural group/combat conditions. Do **not** tag or publish a stable GitHub 1.0.1 from static results alone.


## 1.0.0 — GR735-20261014-03 — 2026-10-14

Первая согласованная публичная версия независимого GuildRecruit735 для WoW Legion 7.3.5 / Interface 70300. Release candidate constructed **only** from our exact `0.1.5-TEST / GR735-20261014-02` (SHA-256 `fe2c7c4a420a9d38c109544bd48856c438037922db30cff5e00aaf12cb57aef3`).

- Отдельный `1.0.0` build ID, версия в Core/.toc/документации и имя ZIP; удалён значок `TEST` из названия аддона в .toc.
- **Никаких функциональных правок Lua:** семь из восьми `.lua` файлов побайтово идентичны 0.1.5, а в `Core.lua` изменены лишь VERSION/BUILD. Не изменены WHO, HC, World ID44, фильтры, шаблоны, кулдаун, сохранённые настройки, кнопка мини-карты.
- В пользовательский ZIP включён текст MIT LICENSE; обновлены руководства RU/EN, релизные заметки и разделы ограничений, добавлены оригинальные тестовые снимки с указанием фактических сборок.
- Основания игровой приёмки — частичные `GAME_TEST_004` (0.1.4) и `GAME_TEST_005` (0.1.5). Полная приёмка нового 1.0.0 по SHA **не выполнялась**, x100 остаётся неподтверждённым; `STATIC_VERIFIED_WITH_LIMITATIONS / RELEASE_CANDIDATE_READY` не означает общий GAME PASS.
- Публикация на GitHub отдельным последующим действием, не частью сборки.

# Changelog

## 0.1.5-TEST — GR735-20261014-02 — 2026-10-14

Точечная RU/EN локализация собственной `0.1.4-TEST` (SHA install `9057be5828d5cfb35aa95893cf19c648bc851df2017caf53f9dd5bc72d4d3c5d`):

- Новый независимый `Locale.lua` с русскими исходными ключами и английскими UI-строками для `enUS`/`enGB`; прочие не-ruRU клиенты используют английский fallback.
- Перевод всех видимых статусов и окон, кнопок, всплывающих подсказок, подтверждений и ошибок; форматирование параметризованных сообщений для безопасной подстановки чисел и имен. WHO имена/расы/классы сохраняются в исходном виде от клиента/сервера.
- Язык автоматически определяется `GetLocale()`; необязательный аккаунтный `GR735DB.language` и команда `/gr735 lang ru|en|auto` для ручного QA-переключения с `/reload`.
- Пользовательские фильтры и шесть шаблонов сообщений, original SavedVariables format/schema, WHO, HC/WorldID44, контакты и функциональность кнопки мини-карты не менялись. Нет новых библиотек и стороннего кода.
- На момент сборки 0.1.5 игрового подтверждения нового перевода не было; позднее GAME_TEST_005 показал все пять окон на английском и WHO 12/9 (PARTIAL_OBSERVATION_ONLY).

## 0.1.4-TEST — GR735-20261014-01 — 2026-10-14

Точечная визуальная правка **только** мини-кнопки на основе нашей 0.1.3-TEST (`GR735-20261013-04`, SHA install `e9d75a14c1413610c35fe3fc84f9b01e1551a1bb33dc5535935ad0d94776e3c1`), после сравнения с установленными пользователем Oilvl/DBM/WeakAuras/ExRT.

- Убрана непрозрачная квадратная подложка `WHITE8X8`, крупные `GR` и растянутый на всю кнопку бордюр.
- Введён стандартный для Blizzard круглый вид: мини-фон 20×20, тематический встроенный значок `INV_Misc_GroupLooking` 17×17 с обрезанными краями, декоративный ободок `MiniMap-TrackingBorder` с прозрачными полями, подсветка `UI-Minimap-ZoomButton-Highlight`, hitbox 31×31.
- Кликовые действия, подсказка, поведение drag и сохранение `GR735DB.minimap` побайтово сохранены в остальном модуле. `Actions`, `Scanner`, `Hardcore`, `Filters`, `UI` — побайтово идентичны родительскому ZIP. Обновлены версия/build в `Core` и `.toc`.
- Не добавлялись библиотеки и арт сторонних аддонов. Результат только STATIC, `GAME_TEST_004` ещё не был проведён на новом ZIP.

## 0.1.3-TEST — GR735-20261013-04 — 2026-10-13

Точечное обновление собственной независимой 0.1.2-TEST (ZIP SHA-256 `872e240f39e4f3409075cba43cbe299a8998ca2b04a70849269b618cc307edc2`) после `GAME_TEST_003 PARTIAL_OBSERVATION_ONLY`.

- Режим `invite_whisper` выполняет **WHISPER, затем GuildInvite** из одного ручного клика, без задержки и ожидания `CHAT_MSG_SYSTEM`; нет заявлений, что `pcall` подтверждает фактическую доставку.
- Подтверждаемый сброс 30-дневной истории попыток в настройках и `/gr735 resetcontacts`, строго для текущего персонажа/гильдии, без удаления профилей/фильтров/шаблонов.
- Новая оригинальная мини-кнопка `GR`: ЛКМ показывает/скрывает панель, ПКМ открывает настройки, перетаскивание по окружности, сохранение угла и видимости в необязательном account-level `GR735DB.minimap`, команда восстановления `/gr735 minimap`. Без LibDataBroker/LibDBIcon и без исходников Guild Control.
- Шрифт строк кандидатов +2 пункта от родного Blizzard GameFontHighlight, заголовок/подпись списка и «Показать игроков» +1 пункт. Высота строк по фактическому размеру текста, список может прокручиваться.
- Существующие WHO/HC, имя/класс цвета, фильтры, старые SavedVariables и World ID 44 сохранены. Установка только тестовая; игровой тест новой версии ещё не проводился.

## 0.1.2-TEST — GR735-20261013-03 — 2026-10-13

Узкое исправление после `GAME_TEST_002` в собственной независимой сборке `0.1.1-TEST / GR735-20261013-02` (install SHA `bf48b99f4c8d335655e308c901ba61ec82d2a9790847ea2f69f7ad13a905565c`).

- Главное окно уменьшено с 564×145 до **455×118**, статистика и три прежние кнопки компактно размещены без изменения их действий.
- Исправлен формат цвета класса: теперь валидный `|cffRRGGBB` строится из штатных RGB-значений Blizzard (либо последних шести hex цифр `colorStr`). Невалидные префиксы `c9`, `0a`, `69` и прочие больше не должны появляться. Имя **и класс** одинакового цвета, уровень и раса нейтральные. Никакой код SuperGuildInvite не копировался.
- Шестишаблонный EditBox получает фокус при реальном нажатии мышью внутри редактора/прокрутки. Добавлен скролл к курсору, проверена логика ввода, переключения и сохранения всех 6 шаблонов на mock-стенде.
- Неизвестный HC-статус больше не загромождает каждую строку меткой `[?HC]`, но остаётся в подсказке при наведении; прежнее обязательное подтверждение перед контактом в HC-exclude сохранено. Для подтверждённого HC метка `[HC]` остаётся.
- WHO/Hardcore/Filters/Actions, ключи SavedVariables, профильные правила, World ID 44, 20–110 и механика ручных действий **не менялись**. x100 realm detection не добавлялся.
- `GAME_TEST_002` предыдущей сборки: `PARTIAL_OBSERVATION_ONLY`; цветовое отображение `GAME_FAILED` в узкой области, ввод редактора `USER_REPORTED_GAME_DEFECT`. Новая 0.1.2 ожидает **отдельный GAME_TEST_003**, пока только `STATIC_VERIFIED_WITH_LIMITATIONS / READY_FOR_GAME_TEST`.

## 0.1.1-TEST — GR735-20261013-02 — 2026-10-13

Узкое обновление исходного независимого билда `0.1.0-TEST / GR735-20261013-01` после первого пользовательского осмотра интерфейса.

- Главное окно по умолчанию закрыто; крестик, Esc, `/gr735`. Начальное состояние «Ожидание сканирования»; кнопка «Сканирование»/«Стоп».
- Два выпадающих списка вместо циклических кнопок HC/действия. World ID для HC **44**, уровни 20–110 и правила HC сохранены.
- Вкладки именных и классовых исключений. Простое пустое поле «Исключение по имени» без обязательных названий или предустановленных суффиксов; 12 галочек классов. Личные активные настройки отдельно для персонажа/гильдии; старый глобальный каталог и старые фильтры сохраняются.
- Перестроен широкий текстовый редактор 6 шаблонов: символы с пробелами + UTF-8 байты; пример переменных; нет `:sub(1,256)`; предел 255 байт проверяется при сохранении и после подстановки имени/гильдии на отправке. Переносы заменяются пробелами.
- WHO: во время контролируемого сканирования временно отключается только событие `WHO_LIST_UPDATE` стандартного неоткрытого FriendsFrame; после окончания/ошибки/тайм-аута регистрация и предыдущий `WhoToUI` восстанавливаются. Статистика по причинам исключений.
- Хардкод/источник HC-пакетов, `GuildInvite` ручное действие, cooldown, TOC-ключи SavedVariables, структура папки аддона — без изменений. Не добавлено неподтверждённого автоматического фильтра мира x100.
- Новые/расширенные offline mock regression tests; игровое подтверждение 0.1.1 ещё отсутствует. Статус `STATIC_VERIFIED_WITH_LIMITATIONS / READY_FOR_GAME_TEST`.

## 0.1.0-TEST — GR735-20261013-01 — 2026-10-13

Initial original-code test implementation for Legion 7.3.5:
- Independent WoW account-wide filter catalogue and per-character/per-guild activation.
- Explicit delete confirmation and filter-management help in Russian.
- One-pass bounded WHO search; 8-second pacing, capped range splitting, 45-second timeout.
- UWoW Hardcore ladder protocol adapter with three recruit modes and conservative UNKNOWN behavior.
- Manual-only selective GuildInvite/whisper workflows, six templates, 30-day local contact cooldown.
- Larger compact UI, closeable/dark candidate list with dynamic row positions and 30-row display cap.
- No third-party code/assets; original MIT-licensed source and GitHub-friendly documentation.
- Status: STATIC_VERIFIED_WITH_LIMITATIONS / READY_FOR_GAME_TEST; not GAME_VERIFIED.
