-- =============================================================================
-- [[ PERPLEXITY.WIN - EXAMPLE SCRIPT ]]
-- =============================================================================

-- Подтягиваем графическую библиотеку с вашего GitHub (замените на прямую ссылку при необходимости)
local Aurora = loadstring(game:HttpGet("https://raw.githubusercontent.com/GibkiyZXC/ui-Perplexity.win2-/main/Library.lua"))()

-- Инициализируем главное окно
local Window = Aurora.new()

-- Вкладка "Visuals"
local VisualsTab = Window:CreateTab("Visuals")

-- 1. Раздел: Player Esp (Колонка 1)
local PlayerEspSec = VisualsTab:CreateSection("Player Esp", 1)
local EnemyEspTab = PlayerEspSec:CreateSubTab("Enemy Esp")
local TeamEspTab = PlayerEspSec:CreateSubTab("Team Esp")
local EspSettingsTab = PlayerEspSec:CreateSubTab("Settings")

-- Настройки внутри вкладки Team Esp
TeamEspTab:CreateCheckbox("Chams", true, function() end):CreateColorpicker(Aurora.THEME.Accent, function(c) end)
TeamEspTab:CreateCheckbox("Box", false, function() end):CreateColorpicker(Color3.fromRGB(255, 255, 255), function(c) end)
TeamEspTab:CreateCheckbox("Filled Box", false, function() end):CreateColorpicker(Color3.fromRGB(255, 255, 255), function(c) end)
TeamEspTab:CreateCheckbox("Health Bar", true, function() end):CreateColorpicker(Color3.fromRGB(255, 30, 60), function(c) end)
TeamEspTab:CreateCheckbox("Armor Bar", false, function() end):CreateColorpicker(Color3.fromRGB(0, 150, 255), function(c) end)
TeamEspTab:CreateCheckbox("Tracer", false, function() end):CreateColorpicker(Color3.fromRGB(255, 255, 255), function(c) end)
TeamEspTab:CreateCheckbox("ViewAngle", false, function() end):CreateColorpicker(Color3.fromRGB(255, 255, 255), function(c) end)
TeamEspTab:CreateCheckbox("Name", true, function() end):CreateColorpicker(Color3.fromRGB(255, 255, 255), function(c) end)
TeamEspTab:CreateCheckbox("Weapon", true, function() end):CreateColorpicker(Color3.fromRGB(255, 255, 255), function(c) end)
TeamEspTab:CreateCheckbox("Offscreen", false, function() end):CreateColorpicker(Color3.fromRGB(255, 255, 255), function(c) end)
TeamEspTab:CreateCheckbox("Filled Offscreen", false, function() end):CreateColorpicker(Color3.fromRGB(255, 255, 255), function(c) end)

-- 2. Раздел: Item Esp (Колонка 1)
local ItemEspSec = VisualsTab:CreateSection("Item Esp", 1)
local ItemEspSub = ItemEspSec:CreateSubTab("Item Esp")
local ItemSettingsSub = ItemEspSec:CreateSubTab("Settings")

ItemEspSub.Container.Parent = ItemEspSec.Frame
ItemEspSec.ActiveSubTab = ItemEspSub

ItemEspSub:CreateCheckbox("Enabled", false, function() end)
ItemEspSub:CreateCheckbox("Dropped C4", false, function() end):CreateColorpicker(Color3.fromRGB(255, 255, 255), function(c) end)
ItemEspSub:CreateCheckbox("Planted C4 Timer", false, function() end):CreateColorpicker(Color3.fromRGB(255, 255, 255), function(c) end)
ItemEspSub:CreateCheckbox("Dropped Weapons", false, function() end):CreateColorpicker(Color3.fromRGB(255, 255, 255), function(c) end)

-- 3. Раздел: Combat Visuals (Колонка 2)
local CombatVisualsSec = VisualsTab:CreateSection("Combat Visuals", 2)
local CombatTab = CombatVisualsSec:CreateSubTab("Combat")
local FovTab = CombatVisualsSec:CreateSubTab("FOV")

FovTab:CreateCheckbox("Aim Assist Fov Circle", true, function() end):CreateColorpicker(Aurora.THEME.Accent, function(c) end)
FovTab:CreateCheckbox("Highlight On Target", true, function() end):CreateColorpicker(Aurora.THEME.Accent, function(c) end)

-- Текстовая надпись для Aim Assist Circle Position
local posLabel = Instance.new("TextLabel")
posLabel.Size = UDim2.new(1, 0, 0, 15)
posLabel.BackgroundTransparency = 1
posLabel.Text = "Aim Assist Circle Position"
posLabel.TextColor3 = Aurora.THEME.TextMuted
posLabel.TextXAlignment = Enum.TextXAlignment.Left
posLabel.ZIndex = 2
Aurora.AddTextStroke(posLabel)
Aurora.ApplyFont(posLabel, 10)
posLabel.Parent = FovTab.Container

local posDropdown = FovTab:CreateDropdown("", {"Mouse", "Center"}, "Mouse", function() end)

-- 4. Раздел: World Modulation (Колонка 2)
local WorldModSec = VisualsTab:CreateSection("World Modulation", 2)
local WorldSubTab = WorldModSec:CreateSubTab("World")
local GraphicsSubTab = WorldModSec:CreateSubTab("Graphics")

WorldSubTab:CreateCheckbox("Ambient", false, function() end):CreateColorpicker(Color3.fromRGB(255, 255, 255), function() end)
local WorldShiftCp = WorldSubTab:CreateCheckbox("Color Shift", false, function() end):CreateColorpicker(Aurora.THEME.Accent, function() end)
WorldSubTab:CreateSlider("Brightness", 0, 100, 0, function() end)

-- World Time Label
local wtLabel = Instance.new("TextLabel")
wtLabel.Size = UDim2.new(1, 0, 0, 15)
wtLabel.BackgroundTransparency = 1
wtLabel.Text = "World Time"
wtLabel.TextColor3 = Aurora.THEME.TextMuted
wtLabel.TextXAlignment = Enum.TextXAlignment.Left
wtLabel.ZIndex = 2
Aurora.AddTextStroke(wtLabel)
Aurora.ApplyFont(wtLabel, 10)
wtLabel.Parent = WorldSubTab.Container

WorldSubTab:CreateSlider("Time", 0, 24, 4, function() end)
WorldSubTab:CreateCheckbox("Custom Fog", false, function() end):CreateColorpicker(Color3.fromRGB(255, 255, 255), function() end)
WorldSubTab:CreateSlider("Fog Start", 0, 1000, 500, function() end)
WorldSubTab:CreateSlider("Fog End", 0, 2000, 1000, function() end)
WorldSubTab:CreateCheckbox("Change Skybox", false, function() end)
WorldSubTab:CreateDropdown("Skybox", {"Above Clouds", "Purple Nebula", "Default"}, "Above Clouds", function() end)

-- 5. Раздел: Screen (Колонка 3)
local ScreenSec = VisualsTab:CreateSection("Screen", 3)
local CameraSub = ScreenSec:CreateSubTab("Camera")
local ViewmodelSub = ScreenSec:CreateSubTab("Viewmodel")
local OthersSub = ScreenSec:CreateSubTab("Others")

-- Others Sub-tab elements
local remLabel = Instance.new("TextLabel")
remLabel.Size = UDim2.new(1, 0, 0, 15)
remLabel.BackgroundTransparency = 1
remLabel.Text = "Removals"
remLabel.TextColor3 = Aurora.THEME.TextMuted
remLabel.TextXAlignment = Enum.TextXAlignment.Left
remLabel.ZIndex = 2
Aurora.AddTextStroke(remLabel)
Aurora.ApplyFont(remLabel, 10)
remLabel.Parent = OthersSub.Container

OthersSub:CreateCheckbox("Force Crosshair", false, function() end)
OthersSub:CreateCheckbox("Dark Flashbang", false, function() end)
OthersSub:CreateCheckbox("Hud Color", true, function() end):CreateColorpicker(Aurora.THEME.Accent, function() end)
OthersSub:CreateCheckbox("Custom Scope Crosshair", false, function() end)

-- 6. Раздел: Self Chams (Колонка 3)
local SelfChamsSec = VisualsTab:CreateSection("Self Chams", 3)
local WeaponSub = SelfChamsSec:CreateSubTab("Weapon")
local ArmsSub = SelfChamsSec:CreateSubTab("Arms")
local AccSub = SelfChamsSec:CreateSubTab("Accessory")
local SelfSub = SelfChamsSec:CreateSubTab("Self")

WeaponSub:CreateDropdown("Type", {"Material", "Outline", "Wireframe"}, "Material", function() end)
WeaponSub:CreateCheckbox("Weapon Chams", true, function() end):CreateColorpicker(Aurora.THEME.Accent, function() end)
WeaponSub:CreateDropdown("Material", {"Foil", "Neon", "Glass"}, "Foil", function() end)
WeaponSub:CreateSlider("Reflectance", 0, 1, 16, function() end)
WeaponSub:CreateDropdown("Animation", {"None", "Pulse", "Wave"}, "None", function() end)

-- 7. Раздел: Grenade Modulation (Колонка 3)
local GrenadeSec = VisualsTab:CreateSection("Grenade Modulation", 3)
local SmokeSub = GrenadeSec:CreateSubTab("Smoke")
local MolSub = GrenadeSec:CreateSubTab("Molotov")
local HeSub = GrenadeSec:CreateSubTab("HE Grenade")

SmokeSub:CreateCheckbox("Remove Particles", false, function() end)

-- Пустые вкладки под функционал
local LegitTab = Window:CreateTab("Legit")
local RageTab = Window:CreateTab("Rage")
local MiscTab = Window:CreateTab("Misc")
local ChangerTab = Window:CreateTab("Changer")

-- Вкладка настроек и конфигурации
local SettingsTab = Window:CreateTab("Settings")

local SettingsSec = SettingsTab:CreateSection("Menu Control", 1)
SettingsSec:CreateKeybind("Hide / Show Key", "RightShift", function(key)
    Aurora.SetToggleKey(key)
    Aurora.Notify("Интерфейс", "Кнопка скрытия изменена на: " .. key.Name)
end)

local ConfigsSec = SettingsTab:CreateSection("Configurations", 2)
local ConfigNameBox = ConfigsSec:CreateDropdown("Select Slot", {"Config 1", "Config 2", "Config 3"}, "Config 1", function() end)

ConfigsSec:CreateButton("Load Config", function()
    Aurora.LoadConfig(ConfigNameBox.Selected)
end)

ConfigsSec:CreateButton("Save Config", function()
    Aurora.SaveConfig(ConfigNameBox.Selected)
end)

ConfigsSec:CreateButton("Delete Config", function()
    pcall(function()
        local path = "aurora/Configs/" .. ConfigNameBox.Selected .. ".json"
        if isfile(path) then
            delfile(path)
            Aurora.Notify("Configs", "Файл удален: " .. ConfigNameBox.Selected, 3)
        else
            Aurora.Notify("Configs", "Файл конфигурации не найден.", 4)
        end
    end)
end)

local ThemesSec = SettingsTab:CreateSection("Theme Selection", 2)
ThemesSec:CreateDropdown("Select Theme", {"Vibrant Red", "Aurora Pink", "Dark Knight Blue", "Toxic Green"}, "Vibrant Red", function(themeName)
    if themeName == "Vibrant Red" then
        Aurora.UpdateBackgroundTheme(Color3.fromRGB(255, 30, 60), {
            Color3.fromRGB(255, 30, 60),
            Color3.fromRGB(100, 10, 25),
            Color3.fromRGB(25, 25, 30)
        })
    elseif themeName == "Aurora Pink" then
        Aurora.UpdateBackgroundTheme(Color3.fromRGB(255, 60, 105), {
            Color3.fromRGB(255, 60, 105),
            Color3.fromRGB(180, 30, 80),
            Color3.fromRGB(240, 240, 255)
        })
    elseif themeName == "Dark Knight Blue" then
        Aurora.UpdateBackgroundTheme(Color3.fromRGB(0, 150, 255), {
            Color3.fromRGB(0, 150, 255),
            Color3.fromRGB(0, 50, 120),
            Color3.fromRGB(20, 20, 25)
        })
    elseif themeName == "Toxic Green" then
        Aurora.UpdateBackgroundTheme(Color3.fromRGB(50, 255, 100), {
            Color3.fromRGB(50, 255, 100),
            Color3.fromRGB(10, 80, 30),
            Color3.fromRGB(20, 20, 25)
        })
    end
end)

local EffectsSec = SettingsTab:CreateSection("Background Effects", 1)
EffectsSec:CreateCheckbox("Background Snow", true, function(state)
    Aurora.SetSnowEnabled(state)
end)
EffectsSec:CreateCheckbox("Screen Blur Effect", true, function(state)
    Aurora.SetBlurEnabled(state)
end)

Aurora.Notify("Aurora Legacy", "Интерфейс инициализирован через внешнюю библиотеку.", 4)
return AuroraExposed
-- =============================================================================
-- [[ СИСТЕМА СМЕНЫ ТЕМЫ (ОБНОВЛЕНИЕ ЦВЕТОВ) ]]
-- =============================================================================
local function UpdateBackgroundTheme(accentOrTable, particleColors)
    -- Поддерживаем как одиночный Color3 для акцента, так и таблицу со всеми цветами темы
    if typeof(accentOrTable) == "Color3" then
        THEME.Accent = accentOrTable
    elseif typeof(accentOrTable) == "table" then
        for k, v in pairs(accentOrTable) do
            if THEME[k] ~= nil and typeof(v) == "Color3" then
                THEME[k] = v
            end
        end
    end
    
    -- Обновляем палитру цветов для частиц
    if particleColors and typeof(particleColors) == "table" then
        activeParticleColors = particleColors
    end

    -- Плавно (через твины) обновляем цвета всех зарегистрированных UI элементов
    for _, item in ipairs(themeObjects) do
        pcall(function()
            if item.Obj and item.Prop and THEME[item.Key] then
                Tween(item.Obj, 0.3, {[item.Prop] = THEME[item.Key]})
            end
        end)
    end

    -- Плавно обновляем цвета уже летающих на экране частиц
    for _, p in ipairs(allParticles) do
        pcall(function()
            if p.Obj then
                local randomColor = activeParticleColors[math.random(1, #activeParticleColors)]
                Tween(p.Obj, 0.5, {ImageColor3 = randomColor})
            end
        end)
    end
end

AuroraExposed.UpdateBackgroundTheme = UpdateBackgroundTheme
