Часть 1. Архитектурные исправления и оптимизация макета
Данное обновление направлено на повышение эргономики, компактности элементов и устранение конфликтов при взаимодействии с интерфейсом:
Закрытие меню без конфликтов:
Стандартная проверка if processed then return end заменена на динамический перехват фокуса через UserInputService:GetFocusedTextBox(). Меню не блокируется системой Roblox, если клавиша закрытия была случайно помечена игровым процессом как обработанная. Скрытие меню блокируется только в том случае, если пользователь активно вводит текст в чат или поле ввода. Кроме того, добавлена проверка if not Window then return end, защищающая скрипт от ошибок, если клавиша скрытия была нажата в момент инициализации интерфейса.
Двухколоночный макет (2-Column Design):
Контентная область разделена на две функциональные колонки по 48.5% ширины с отступом между ними. Сайдбар имеет фиксированную ширину 210 пикселей, а контентная область смещена на 230 пикселей от левого края, что полностью решает проблему пустых зазоров на широких экранах.
Спецификации реального макета (Коэффициент 1.0):
Габариты всех элементов приведены к единому стандарту плотности:
Главное окно: Просторный формат 835 x 520 пикселей.
Сайдбар: 210 пикселей.
Кнопки: Высота контейнера 24 пикселя.
Чекбоксы: Высота контейнера 22 пикселя.
Слайдеры: Высота контейнера 38 пикселей (трек 3 пикселя, ползунок 8 пикселей).
Выпадающие списки: Высота кнопки выбора 22 пикселя, высота элементов списка 18 пикселей, общая высота контейнера 40 пикселей.
Шрифты: Базовый кегль для чекбоксов и названий секций — 12 пунктов, для слайдеров и выпадающих списков — 11 пунктов, для HEX-лейбла — 10 пунктов.
Умная палитра цветов (Smart Colorpicker):
Палитра имеет ультракомпактные размеры 130 x 125 пикселей. Она больше не привязывается к левому краю главного фрейма. Окно палитры автоматически рассчитывает свободное пространство по оси X относительно вызвавшей её кнопки (cpBtn), сдвигаясь влево на 140 пикселей или вправо, если места на экране недостаточно. По оси Y палитра ровно центрируется по кнопке вызова с автоматической коррекцией системного отступа Roblox (GuiService:GetGuiInset().Y), если у ScreenGui включено свойство IgnoreGuiInset.
Улучшенные уведомления (Slide-In Notifications):
Система уведомлений использует плавное скольжение справа на экранах пользователей, переведена на лаконичный английский язык и снабжена цветной полосой, оттенок которой изменяется синхронно с выбранным акцентным цветом интерфейса.
Логотип без лишних пробелов:
Текст логотипа рендерится в единую монолитную строку вида PERPLEXITY.WIN.
Часть 2. Visual Theme: Matrix «Code Rain»
Вместо стандартного эффекта снегопада интегрирована фоновая анимация Matrix Code Rain:
Эффект генерирует вертикально падающие цепочки символов цифр (от 0 до 9) с использованием моноширинного шрифта RobotoMono.
Каждая падающая цифра инициализируется со случайным размером (от 7 до 11 пикселей) и прозрачностью (от 40% до 75%) для создания ощущения глубины.
Значения символов динамически обновляются случайным образом с частотой около 0.08 секунды.
Цвет падающих частиц и фоновое свечение вкладок привязаны к центральной схеме кастомизации и перекрашиваются на лету при изменении акцентного оттенка.
Часть 3. Подробный гайд по добавлению вкладок и функций
Каждый элемент в разделах автоматически регистрируется в системе конфигурации при условии задания уникального текстового идентификатора.
Создание вкладки:
code
Lua
local MyNewTab = Window:CreateTab("Название Вкладки")
Создание секции (Левая колонка — индекс 1, правая колонка — индекс 2):
code
Lua
local MySection = MyNewTab:CreateSection("Aimbot Settings", 1)
Чекбокс (Checkbox):
code
Lua
MySection:CreateCheckbox("Enable Features", false, function(state)
    print("Состояние чекбокса:", state)
end)
Слайдер (Slider):
code
Lua
MySection:CreateSlider("FOV Range", 10, 800, 100, function(value)
    print("Новое значение FOV:", value)
end)
Выпадающий список (Dropdown):
code
Lua
MySection:CreateDropdown("Target Part", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(selected)
    print("Выбранная кость:", selected)
end)
Кнопка (Button):
code
Lua
MySection:CreateButton("Reset Config", function()
    print("Конфигурация сброшена!")
end)
Назначение клавиши (Keybind):
code
Lua
MySection:CreateKeybind("Trigger Key", "F", function(key)
    print("Нажата клавиша:", key.Name)
end)
Компактный блок (привязка выбора цвета и клавиши непосредственно к чекбоксу):
code
Lua
local Wallhack = MySection:CreateCheckbox("ESP Box", false, function(state)
    print("Состояние ESP:", state)
end)

-- Привязка выбора цвета к чекбоксу (аргументы: дефолтный цвет, callback)
Wallhack:CreateColorpicker(Color3.fromRGB(255, 0, 0), function(color)
    print("Цвет ESP изменен:", color)
end)

-- Привязка бинда клавиши к чекбоксу (аргументы: дефолтная клавиша, callback)
Wallhack:CreateKeybind("X", function(key)
    print("Клавиша ESP переназначена:", key.Name)
end)
Часть 4. Внутреннее устройство системы конфигураций
Регистрация в таблицах Flags и SaveFlags:
При вызове методов создания элементов библиотека регистрирует их текущее состояние:
SaveFlags — хранит сериализуемые значения (например, строки HEX вместо сложных объектов Color3 и имена клавиш в текстовом формате). При перетаскивании ползунков палитры функция SetColor автоматически перезаписывает выбранный цвет в SaveFlags[name .. "_color"] и обновляет cp.Value, предотвращая сброс настроек при повторном открытии палитры.
Flags — содержит ссылки на методы-мосты Set и Get. При вызове LoadConfig() библиотека считывает конфигурационный JSON, сопоставляет сохраненные значения с зарегистрированными методами Set и инициализирует восстановление положения элементов интерфейса с автоматическим вызовом коллбэков.
Алгоритмы сохранения и загрузки:
Сохранение: Метод Window:SaveConfig(slotName) проверяет файловую структуру в каталоге perplexity/Configs/ вашего эксплоита, сериализует данные SaveFlags в строку формата JSON и сохраняет их на диск посредством функции writefile.
Загрузка: Метод Window:LoadConfig(slotName) считывает указанный файл функцией readfile, десериализует его структуру через HttpService:JSONEncode и восстанавливает параметры элементов, трансформируя HEX-кодировку обратно в Color3 и текстовые наименования клавиш в перечисления Enum.KeyCode или Enum.UserInputType.
Часть 5. Интеграция конфигураций и тем в ваш скрипт (Встроенный метод)
Библиотека включает в себя готовый метод API — Window:CreateSettingsTab(). Этот метод автоматически создает готовую вкладку со всеми встроенными пресетами, кастомизацией акцента, сменой бинда открытия меню и встроенной системой сохранения.
Пример использования:
code
Lua
local Perplexity = loadstring(game:HttpGet("https://raw.githubusercontent.com/..."))()
local Window = Perplexity.new()

-- Ваша игровая вкладка
local CombatTab = Window:CreateTab("Combat")
local CombatSection = CombatTab:CreateSection("Aimbot Settings", 1)
CombatSection:CreateCheckbox("Silent Aim", false, function() end)

-- Автоматическое создание полнофункциональной вкладки Settings
Window:CreateSettingsTab()
Ручной пример создания аналогичной вкладки (для кастомизации структуры):
code
Lua
-- Ручной пример создания аналогичной вкладки
local SettingsTab = Window:CreateTab("Settings")

-- 1. Менеджер конфигураций (Левая колонка)
local ConfigSection = SettingsTab:CreateSection("Configuration Manager", 1)
local selectedSlot = "Slot 1"

ConfigSection:CreateDropdown("Selected Slot", {"Slot 1", "Slot 2", "Slot 3", "Legit", "Rage"}, "Slot 1", function(selected)
    selectedSlot = selected
end)

ConfigSection:CreateButton("Save Configuration", function()
    Window:SaveConfig(selectedSlot)
end)

ConfigSection:CreateButton("Load Configuration", function()
    Window:LoadConfig(selectedSlot)
end)

-- 2. Настройки кастомизации интерфейса (Правая колонка)
local MenuSettings = SettingsTab:CreateSection("Menu Settings", 2)

-- Смена клавиши скрытия интерфейса
MenuSettings:CreateKeybind("Hide / Show Key", "RightShift", function(key)
    getgenv().toggleKey = key
end)

-- Инициализация переменных для контроля темы
local currentPresetColor = Color3.fromRGB(255, 30, 60)
local lastCustomColor = Color3.fromRGB(255, 30, 60)
local customAccentEnabled = false

-- Интеграция выпадающего списка выбора готовых тем оформления
local themeList = {}
for themeName, _ in pairs(Perplexity.Presets) do
    table.insert(themeList, themeName)
end
table.sort(themeList)

MenuSettings:CreateDropdown("Theme Preset", themeList, "Red (Default)", function(selectedName)
    local selectedColor = Perplexity.Presets[selectedName]
    if selectedColor then
        currentPresetColor = selectedColor
        -- Тема применяется только если не включен кастомный цвет акцента
        if not customAccentEnabled then
            Window:UpdateTheme(selectedColor, {
                selectedColor,
                Color3.fromRGB(selectedColor.R * 255 * 0.4, selectedColor.G * 255 * 0.4, selectedColor.B * 255 * 0.4),
                Color3.fromRGB(25, 25, 30)
            })
        end
    end
end)

-- Дополнительная кастомная палитра для произвольного цвета акцента
local CustomThemeColor = MenuSettings:CreateCheckbox("Custom Color Accent", false, function(state)
    customAccentEnabled = state
    if state then
        -- Принудительно применяем кастомный цвет
        Window:UpdateTheme(lastCustomColor, {
            lastCustomColor,
            Color3.fromRGB(lastCustomColor.R * 255 * 0.4, lastCustomColor.G * 255 * 0.4, lastCustomColor.B * 255 * 0.4),
            Color3.fromRGB(25, 25, 30)
        })
    else
        -- Возвращаемся к стандартному пресету
        Window:UpdateTheme(currentPresetColor, {
            currentPresetColor,
            Color3.fromRGB(currentPresetColor.R * 255 * 0.4, currentPresetColor.G * 255 * 0.4, currentPresetColor.B * 255 * 0.4),
            Color3.fromRGB(25, 25, 30)
        })
    end
end)

CustomThemeColor:CreateColorpicker(Color3.fromRGB(255, 30, 60), function(color)
    lastCustomColor = color
    -- Применяем изменения на лету, только если функция активна
    if customAccentEnabled then
        Window:UpdateTheme(color, {
            color, 
            Color3.fromRGB(color.R * 255 * 0.4, color.G * 255 * 0.4, color.B * 255 * 0.4),
            Color3.fromRGB(25, 25, 30)
        })
    end
end)
Часть 6. Где хранятся файлы конфигураций?
Все файлы конфигурации сохраняются локально в директории вашего эксплоита:
Для Solara: Solara / workspace / perplexity / Configs /
Для Wave: Wave / workspace / perplexity / Configs /
Для MacSploit: MacSploit / workspace / perplexity / Configs /
Для других чит-клиентов: [папка вашего чита] ➔ workspace ➔ perplexity ➔ Configs
Файлы сохраняются в кроссплатформенном формате .json и при необходимости могут быть переданы другим пользователям для мгновенного импорта параметров.
Часть 7. Описание палитры пресетов тем (Presets Registry)
Библиотека экспортирует глобальный реестр тем Perplexity.Presets в виде стандартной таблицы соответствия строковых ключей и объектов Color3:
code
Lua
Perplexity.Presets = {
    ["Red (Default)"] = Color3.fromRGB(255, 30, 60),
    ["Green (Matrix)"] = Color3.fromRGB(0, 255, 120),
    ["Blue (Cyber)"] = Color3.fromRGB(30, 144, 255),
    ["Purple (Amethyst)"] = Color3.fromRGB(155, 89, 182),
    ["Yellow (Gold)"] = Color3.fromRGB(241, 196, 15),
    ["Orange (Fire)"] = Color3.fromRGB(230, 126, 34),
    ["White (Snow)"] = Color3.fromRGB(236, 240, 241)
}
Вы можете свободно добавлять собственные цветовые схемы в данный список прямо из вашего основного скрипта перед созданием оконного интерфейса:
code
Lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/..."))()
Library.Presets["Pink (Neon)"] = Color3.fromRGB(255, 105, 180) -- Добавление новой темы в реестр пресетов
local Window = Library.new()
