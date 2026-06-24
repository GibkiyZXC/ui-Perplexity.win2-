Полный обновленный гайд по интеграции и разработке
Часть 1. Архитектурные исправления и оптимизация макета
Данное обновление исправляет базовые технические несовершенства интерфейса:
Закрытие меню без конфликтов:
Старая проверка if processed then return end заменена на динамический метод UserInputService:GetFocusedTextBox(). Меню больше не блокируется Roblox при случайной пометке клавиши RightShift как "processed" системой Roblox. Скрытие блокируется только тогда, когда игрок вводит сообщение в игровой чат или пишет текст в текстовые поля чита.
Двухколоночный макет (2-Column Design):
Исходный интерфейс жестко разбивался на 3 узкие колонки по 31.5% ширины (около 198 пикселей). Это приводило к тому, что длинный текст настроек (например, «Aimbot Trigger Key») не помещался и обрезался до невзрачного «Aimbot...».
Теперь макет перестроен на две широкие колонки по 48.5% ширины. Это увеличило полезную площадь разделов, убрало пустое место в правой части экрана и позволило названиям всех функций полностью отображаться на экране.
Умная палитра цветов (Smart Colorpicker):
Ранее окно палитры открывалось жестко слева от кнопки, полностью перекрывая названия соседних чекбоксов внутри карточки.
В новой версии палитра автоматически прикрепляется к левому краю главного окна меню.
Если вы перетащите чит близко к левому краю экрана, палитра автоматически изменит направление и прикрепится к правой стороне главного окна, предотвращая выход за границы экрана.
Улучшенные уведомления (Slide-In Notifications):
Прежние уведомления использовали грубое масштабирование по высоте и были на русском языке.
Теперь они полностью переведены на английский, оформлены в лаконичном стиле с левой цветной акцентной полосой, а их появление анимировано плавным выдвижением (slide-in) с правого края экрана.
Логотип без пробелов:
Из названия логотипа исключен некорректный пробел перед точкой. Текст теперь рендерится как монолитный PERPLEXITY.WIN.
Часть 2. Визуальный эффект темы: «Цифровой дождь» (Code Rain)
Вместо стандартных текстур падающего снега в систему частиц интегрирован хакерский эффект бегущего матричного кода:
Эффект генерирует падающие сверху вниз зеленые/акцентные символы цифр (от 0 до 9) моноширинного шрифта RobotoMono.
Каждая цифра имеет случайный размер и уровень прозрачности для создания 3D-глубины.
Каждые несколько кадров цифры на лету случайно меняют свое значение, симулируя активную работу терминала.
Фоновое свечение (акцентный цвет) и цвет цифровых частиц синхронизированы и плавно изменяются при перекрашивании палитры.
Часть 3. Подробный гайд по добавлению вкладок и функций
Каждый элемент управления в секциях автоматически биндится в систему сохранения.
1. Как добавить новую вкладку (Tab)
code
Lua
local MyNewTab = Window:CreateTab("Название Вкладки")
2. Как добавить секцию (Section) во вкладку
Поскольку макет переведен на двухколоночный режим, вы можете указывать для секции индекс 1 (левая колонка) или 2 (правая колонка).
code
Lua
local MySection = MyNewTab:CreateSection("Aimbot Settings", 1)
3. Как добавить функции в секцию
Чекбокс (Checkbox):
code
Lua
MySection:CreateCheckbox("Enable Features", false, function(state)
    print("State:", state)
end)
Слайдер (Slider):
code
Lua
MySection:CreateSlider("FOV Range", 10, 800, 100, function(value)
    print("New FOV:", value)
end)
Выпадающий список (Dropdown):
code
Lua
MySection:CreateDropdown("Target Part", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(selected)
    print("Bone Target:", selected)
end)
Кнопка (Button):
code
Lua
MySection:CreateButton("Reset Config", function()
    print("Reset complete!")
end)
Бинд клавиши (Keybind):
code
Lua
MySection:CreateKeybind("Trigger Key", "F", function(key)
    print("Pressed:", key.Name)
end)
4. Как добавить сложные элементы (Палитра + Бинд)
Вы можете расширять чекбокс, прикрепляя к нему выбор цвета или бинд клавиши:
code
Lua
local Wallhack = MySection:CreateCheckbox("ESP Box", false, function(state)
    print("ESP active:", state)
end)

-- Привязка выбора цвета к чекбоксу
Wallhack:CreateColorpicker(Color3.fromRGB(255, 0, 0), function(color)
    print("ESP Color:", color)
end)

-- Привязка бинда клавиши к чекбоксу
Wallhack:CreateKeybind("X", function(key)
    print("ESP toggled via key:", key.Name)
end)
Часть 4. Внутреннее устройство системы конфигураций
1. Регистрация данных в SaveFlags и Flags
При создании интерактивного элемента библиотека резервирует его состояние в двух внутренних таблицах:
SaveFlags — хранит "сырые" значения для записи в файл (например, ["Draw Boxes"] = true, ["Box Color_color"] = "ffffff").
Flags — содержит методы-мосты (Set и Get) [1]. Когда вы вызываете LoadConfig(), библиотека считывает значения из JSON-файла и передает их в метод Flags[Имя].Set(значение) [1].
Метод Set не только обновляет визуальное положение кнопок и слайдеров, но и самостоятельно вызывает callback-функции, применяя настройки в самой игре [1].
2. Как работает сохранение и загрузка
Сохранение (Window:SaveConfig(slotName)): Проверяет наличие папок в workspace/perplexity/Configs/, преобразует текущую таблицу SaveFlags в строку JSON и записывает на диск через writefile [1].
Загрузка (Window:LoadConfig(slotName)): Считывает файл через readfile, парсит его обратно в таблицу через HttpService:JSONDecode [1]. После этого пробегается по всем элементам и восстанавливает их состояние, автоматически преобразуя строковые данные (Hex-цвета и строки клавиш) обратно в форматы Color3 и Enum.KeyCode/Enum.UserInputType для коллбэков.
Часть 5. Интеграция конфигураций и тем в ваш скрипт
Вы можете добавить этот готовый блок в ваш скрипт для управления файлами настроек и кастомизации визуальных эффектов:
code
Lua
-- 1. Создаем вкладку "Settings"
local SettingsTab = Window:CreateTab("Settings")

-- 2. Секция управления файлами конфигурации (Левая колонка)
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

-- 3. Секция управления меню (Правая колонка)
local MenuSettings = SettingsTab:CreateSection("Menu Settings", 2)

-- Смена клавиши открытия
getgenv().toggleKey = Enum.KeyCode.RightShift
MenuSettings:CreateKeybind("Hide / Show Key", "RightShift", function(key)
    getgenv().toggleKey = key
end)

-- Палитра для смены акцентного цвета темы меню
local ThemeColor = MenuSettings:CreateCheckbox("Custom Theme Accent", true, function() end)
ThemeColor:CreateColorpicker(Color3.fromRGB(255, 30, 60), function(color)
    -- Функция UpdateBackgroundTheme моментально перекрашивает весь интерфейс и бегущие цифры!
    UpdateBackgroundTheme(color, {
        color, 
        Color3.fromRGB(color.R * 255 * 0.4, color.G * 255 * 0.4, color.B * 255 * 0.4),
        Color3.fromRGB(25, 25, 30)
    })
end)
Часть 6. Где хранятся файлы конфигураций?
Все конфигурационные файлы сохраняются локально на вашем ПК в папке вашего эксплоита:
Для Solara: Solara / workspace / perplexity / Configs /
Для Wave: Wave / workspace / perplexity / Configs /
Для других читов: Папка вашего чит-клиента ➔ папка workspace ➔ perplexity ➔ Configs
Файлы сохраняются в формате .json (например, Slot 1.json или Rage.json). Вы можете свободно обмениваться ими с другими пользователями.
Citations
