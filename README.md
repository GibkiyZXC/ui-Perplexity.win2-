Часть 1. Архитектурные исправления и оптимизация макета
Данное обновление направлено на исправление технических несовершенств интерфейса, повышение эргономики и компактности элементов:
Закрытие меню без конфликтов:
Стандартная проверка if processed then return end заменена на динамический перехват фокуса через UserInputService:GetFocusedTextBox(). Меню больше не блокируется системой Roblox, если клавиша RightShift была случайно помечена как "processed" игровым процессом. Скрытие меню блокируется только в том случае, если пользователь активно печатает текст во встроенном TextBox или в чате игры.
Двухколоночный компактный макет (2-Column Dense Design):
Разделы интерфейса перестроены в две функциональные колонки по 48.5% ширины. Полезная площадь увеличена, устранены зазоры в правой части экрана, названия элементов теперь отображаются полностью (например, «Aimbot Trigger Key» больше не обрезается).
Общее пропорциональное уменьшение интерфейса:
Для снижения загромождения экрана габариты элементов были уменьшены:
Главное окно: уменьшено с 840 x 560 до более аккуратных 760 x 480 пикселей.
Сайдбар: сужен со 180 до 160 пикселей.
Интерактивные элементы: высота чекбоксов, кнопок и биндов снижена с 24 до 20 пикселей.
Слайдеры: высота снижена с 42 до 34 пикселей, толщина трека уменьшена до 3 пикселей, диаметр ползунка уменьшен до 8 пикселей.
Выпадающие списки: высота сложенного меню уменьшена с 44 до 36 пикселей, высота кнопок выбора уменьшена до 16 пикселей.
Шрифты: базовый кегль текста уменьшен с 11/12 до 9/10 пунктов для сохранения читаемости при высокой плотности элементов.
Умная палитра цветов (Smart Colorpicker):
Окно палитры автоматически привязывается к левому краю главного фрейма. Если главное окно находится слишком близко к левому краю игрового экрана, палитра динамически переносится на его правую сторону, предотвращая выход за границы отображения. Палитра также уменьшена до габаритов 130 x 125 пикселей.
Улучшенные уведомления (Slide-In Notifications):
Система уведомлений использует плавное скольжение справа на экранах пользователей, переведена на лаконичный английский язык и снабжена цветной полосой, цвет которой изменяется синхронно с выбранным акцентным оттенком.
Логотип без лишних пробелов:
Текст логотипа рендерится в единую монолитную строку вида PERPLEXITY.WIN.
Часть 2. Визуальный эффект темы: «Цифровой дождь» (Code Rain)
Вместо стандартного эффекта снегопада или статических частиц интегрирована кастомизированная фоновая анимация Matrix Code Rain:
Эффект генерирует вертикально падающие цепочки символов цифр (от 0 до 9) с использованием моноширинного шрифта RobotoMono.
Каждая падающая цифра инициализируется со случайным размером и прозрачностью для создания ощущения 3D-глубины.
Значение символов динамически обновляется на лету случайным образом для симуляции непрерывного цифрового потока.
Цвет падающих частиц и фоновое свечение вкладок привязаны к центральной схеме кастомизации и перекрашиваются на лету при вызове цветовых функций.
Часть 3. Подробный гайд по добавлению вкладок и функций
Каждый элемент в разделах автоматически регистрируется в системе конфигурации при условии задания уникального текстового идентификатора.
code
Lua
local MyNewTab = Window:CreateTab("Название Вкладки")
Секция позиционируется в левую (индекс 1) или правую (индекс 2) колонки:
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
Вы можете прикреплять выбор цвета и назначение клавиши непосредственно к чекбоксу в виде компактного блока:
code
Lua
local Wallhack = MySection:CreateCheckbox("ESP Box", false, function(state)
    print("Состояние ESP:", state)
end)

-- Привязка выбора цвета к чекбоксу
Wallhack:CreateColorpicker(Color3.fromRGB(255, 0, 0), function(color)
    print("Цвет ESP изменен:", color)
end)

-- Привязка бинда клавиши к чекбоксу
Wallhack:CreateKeybind("X", function(key)
    print("Клавиша ESP переназначена:", key.Name)
end)
Часть 4. Внутреннее устройство системы конфигураций
Регистрация в таблицах Flags и SaveFlags:
При вызове методов создания элементов библиотека регистрирует их состояние:
SaveFlags — хранит сериализуемые значения (например, строки HEX вместо сложных объектов Color3 и имена клавиш в текстовом формате).
Flags — содержит ссылки на методы-мосты Set и Get [1]. При вызове LoadConfig() библиотека считывает конфигурационный JSON, сопоставляет сохраненные значения с зарегистрированными методами Set [1] и инициализирует восстановление положения элементов интерфейса с автоматическим триггером коллбэков.
Алгоритмы сохранения и загрузки:
Сохранение: Метод Window:SaveConfig(slotName) проверяет файловую структуру в каталоге perplexity/Configs/ вашего эксплоита, сериализует данные SaveFlags в строку формата JSON и сохраняет их на диск посредством функции writefile [1].
Загрузка: Метод Window:LoadConfig(slotName) считывает указанный файл функцией readfile [1], десериализует его структуру через HttpService:JSONDecode и восстанавливает параметры элементов, трансформируя HEX-кодировку обратно в Color3 и текстовые наименования клавиш в перечисления Enum.KeyCode [1].
Часть 5. Интеграция конфигураций и тем в ваш скрипт
Пример реализации вкладки «Settings» с встроенной панелью выбора тем оформления на базе реестра PRESETS и файловым менеджером:
code
Lua
-- 1. Инициализация вкладки настроек
local SettingsTab = Window:CreateTab("Settings")

-- 2. Менеджер конфигураций (Левая колонка)
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

-- 3. Настройки кастомизации интерфейса (Правая колонка)
local MenuSettings = SettingsTab:CreateSection("Menu Settings", 2)

-- Смена клавиши скрытия интерфейса
MenuSettings:CreateKeybind("Hide / Show Key", "RightShift", function(key)
    getgenv().toggleKey = key
end)

-- Интеграция выпадающего списка выбора готовых тем оформления
local themeList = {}
for themeName, _ in pairs(Perplexity.Presets) do
    table.insert(themeList, themeName)
end
table.sort(themeList)

MenuSettings:CreateDropdown("Theme Preset", themeList, "Red (Default)", function(selectedName)
    local selectedColor = Perplexity.Presets[selectedName]
    if selectedColor then
        -- Вызов встроенного метода динамического обновления темы оформления
        Window:UpdateTheme(selectedColor, {
            selectedColor,
            Color3.fromRGB(selectedColor.R * 255 * 0.4, selectedColor.G * 255 * 0.4, selectedColor.B * 255 * 0.4),
            Color3.fromRGB(25, 25, 30)
        })
    end
end)

-- Дополнительная кастомная палитра для произвольного цвета акцента
local CustomThemeColor = MenuSettings:CreateCheckbox("Custom Color Accent", false, function() end)
CustomThemeColor:CreateColorpicker(Color3.fromRGB(255, 30, 60), function(color)
    Window:UpdateTheme(color, {
        color, 
        Color3.fromRGB(color.R * 255 * 0.4, color.G * 255 * 0.4, color.B * 255 * 0.4),
        Color3.fromRGB(25, 25, 30)
    })
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
Library.Presets["Pink (Neon)"] = Color3.fromRGB(255, 105, 180) -- Пример добавления новой темы
local Window = Library.new()
