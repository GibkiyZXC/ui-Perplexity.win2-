# Aurora Legacy UI Library
Современная, оптимизированная и анимированная библиотека интерфейса для Roblox с поддержкой 3D ESP Preview, динамической сменой тем и сохранениями.

## Быстрый старт (Использование библиотеки)
```lua
local Aurora = loadstring(game:HttpGet("ссылка_на_ваш_github_raw"))()
local Window = Aurora.new()

-- Создание вкладки
local Tab = Window:CreateTab("My Tab")

-- Создание карточки раздела в 1-ой колонке
local Section = Tab:CreateSection("My Section", 1)

-- Создание внутренних под-вкладок (Sub-Tabs)
local SubTab = Section:CreateSubTab("My SubTab")

-- Добавление элементов управления во внутреннюю вкладку
SubTab:CreateCheckbox("My Option", true, function(state) print(state) end)
SubTab:CreateSlider("My Slider", 0, 100, 50, function(val) print(val) end)
