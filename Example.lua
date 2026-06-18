-- =============================================================================
-- [[ PERPLEXITY.WIN - HIGH-FIDELITY UI FRAMEWORK & COMPATIBILITY LAYER ]]
-- [[ Example.lua ]]
-- =============================================================================

-- Безопасный загрузчик библиотеки
local Library = getgenv().Perplexity

if not Library then
    -- Проверка 1: Безопасный поиск локального файла в Roblox Studio
    local success, res = pcall(function()
        return require(script.Parent.Library)
    end)
    if success then
        Library = res
    -- Проверка 2: Поиск локального файла на диске вашего чита (папка workspace)
    elseif typeof(readfile) == "function" and isfile and isfile("Library.lua") then
        local fileSuccess, fileData = pcall(readfile, "Library.lua")
        if fileSuccess then
            Library = loadstring(fileData)()
        end
    end
end

-- Если библиотека не найдена, сообщаем пользователю вместо вызова ошибки Parent
if not Library then
    error("[Perplexity.Win Error]: Сначала запустите файл Library.lua, либо сохраните его в папку workspace!")
end

_G.Library = Library
getgenv().Library = Library

-- =============================================================================
-- [[ ИНИЦИАЛИЗАЦИЯ ВИДЖЕТОВ ]]
-- =============================================================================

local Watermark = Library:Watermark({ Name = "Landryhaxx" })
Watermark:SetDynamicTextProvider(function(Fps)
    return string.format("Landryhaxx | %dfps | %s", Fps, os.date("%X"))
end)

local KeybindList = Library:KeybindList({ Name = "Keybinds" })
local ESPPreview = Library:ESPPreview({ Name = "ESP Preview" })
local TargetIndicator = Library:TargetIndicator()
local Radar = Library:RadarWidget({ Name = "Radar" })

local Logger = Library:ConsoleLogger({
    Name = "Console",
    Callback = function(Text, Log)
        Log:AddOutput(Text)
    end
})

local ModeratorList = Library:ModeratorList({ Name = "Moderators" })
local StatList = Library:StatListWidget({ Name = "Stats" })
StatList:SetLines({ "Kills: 0", "Deaths: 0", "KDR: 0.00" })

local ChargeShot = Library:ChargeShotWidget({ Name = "Charge Shot" })
local Inventory = Library:InventoryViewer({ Name = "Inventory" })
local Spotify = Library:SpotifyPlayer()
local Playerlist = Library:Playerlist({ Name = "Players" })

-- =============================================================================
-- [[ СОЗДАНИЕ ГЛАВНОГО ОКНА ]]
-- =============================================================================

local Window = Library:Window({
    Title = "Landryhaxx",
    ButtonName = "Main UI"
})

-- =============================================================================
-- [[ РЕГИСТРАЦИЯ ТУМБЛЕРОВ ВИДЖЕТОВ В НАСТРОЙКАХ ]]
-- =============================================================================

Library:RegisterSettingsWidget({ Name = "Watermark", Default = true, Callback = function(Value) Watermark:SetVisibility(Value) end })
Library:RegisterSettingsWidget({ Name = "Keybind List", Default = true, Callback = function(Value) KeybindList:SetVisibility(Value) end })
Library:RegisterSettingsWidget({ Name = "ESP Preview", Default = false, Callback = function(Value) ESPPreview:SetVisibility(Value) end })
Library:RegisterSettingsWidget({ Name = "Target Indicator", Default = false, Callback = function(Value) TargetIndicator:SetVisibility(Value) end })
Library:RegisterSettingsWidget({ Name = "Radar", Default = false, Callback = function(Value) Radar:SetVisibility(Value) end })
Library:RegisterSettingsWidget({ Name = "Console", Default = false, Callback = function(Value) Logger:SetVisibility(Value) end })
Library:RegisterSettingsWidget({ Name = "Moderator List", Default = false, Callback = function(Value) ModeratorList:SetVisibility(Value) end })
Library:RegisterSettingsWidget({ Name = "Stat List", Default = false, Callback = function(Value) StatList:SetVisibility(Value) end })
Library:RegisterSettingsWidget({ Name = "Charge Shot", Default = false, Callback = function(Value) ChargeShot:SetVisibility(Value) end })
Library:RegisterSettingsWidget({ Name = "Inventory", Default = false, Callback = function(Value) Inventory:SetVisibility(Value) end })
Library:RegisterSettingsWidget({ Name = "Spotify", Default = false, Callback = function(Value) Spotify:SetVisibility(Value) end })
Library:RegisterSettingsWidget({ Name = "Player List", Default = false, Callback = function(Value) Playerlist:SetVisibility(Value) end })

-- =============================================================================
-- [[ СТРУКТУРА СТРАНИЦ ]]
-- =============================================================================

local Page = Window:Page({ Name = "Main" })
local SubPage = Page:SubPage({ Name = "Combat" })

local LeftSection = SubPage:Section({ Name = "Aimbot", Side = 1 })
local RightSection = SubPage:Section({ Name = "Visuals", Side = 2 })

LeftSection:Toggle({
    Name = "Enable Aimbot",
    Flag = "AimbotEnabled",
    Default = false,
    Callback = function(Value)
        print("Aimbot:", Value)
    end
})

LeftSection:Slider({
    Name = "FOV",
    Flag = "AimbotFOV",
    Default = 90,
    Min = 1,
    Max = 360,
    Decimals = 0,
    Suffix = "",
    Callback = function(Value)
        print("FOV:", Value)
    end
})

RightSection:Toggle({
    Name = "ESP",
    Flag = "ESPEnabled",
    Default = false,
    Callback = function(Value)
        print("ESP:", Value)
    end
})

Library:Notification("Landryhaxx Loaded", 3, Library.Theme["Accent"])
