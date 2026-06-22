local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- // КОНФИГУРАЦИЯ ПО УМОЛЧАНИЮ
local CONFIG = {
    -- Визуалы (ESP)
    EnableESP = true,
    ShowBox = true,
    ShowNames = true,
    ShowDistance = true,
    ShowHealth = true,
    TeamCheck = false,

    BoxColor = Color3.fromRGB(255, 255, 255),       -- Цвет рамки ESP (Box)
    BoxOutlineColor = Color3.fromRGB(0, 0, 0),      -- Цвет внешней обводки рамки
    NameColor = Color3.fromRGB(255, 255, 255),       -- Цвет ника
    DistanceColor = Color3.fromRGB(180, 180, 180),   -- Цвет дистанции
    GlowTransparency = 0.65,                         -- Прозрачность неонового свечения ХП
    TextSize = 11,                                   -- Размер текста
    Font = Enum.Font.RobotoMono,                     -- Шрифт
    
    -- Настройки 3D свечения персонажа
    Enable3DHighlight = true,                        -- Включить свечение тела персонажа цветом ХП
    HighlightFillTransparency = 0.88,                -- Заливка тела (тусклая)
    HighlightOutlineTransparency = 1.0,              -- Обводка персонажа полностью отключена (1.0)

    -- Настройки Аимбота & Aim ESP
    AimActive = false,
    AimKey = Enum.UserInputType.MouseButton2,        -- Клавиша зажима аима (по умолчанию ПКМ)
    AimPart = "Head",                                -- Часть тела для захвата
    AimFOV = 100,                                    -- Радиус фова
    AimSmoothness = 3,                               -- Плавность аима (чем больше, тем медленнее)
    AimTeamCheck = false,                            -- Игнорировать тиммейтов в аиме
    
    ShowFOV = false,                                 -- Показывать круг FOV
    FOVColor = Color3.fromRGB(255, 30, 60),          -- Цвет круга FOV
    
    ShowTargetTracer = false,                        -- Рисовать линию до захваченной цели
    TracerColor = Color3.fromRGB(255, 30, 60)         -- Цвет линии захвата
}

-- Таблица для ESP игроков
local ActiveESPs = {}

-- // 1. ОЧИСТКА ЭЛЕМЕНТОВ ИНТЕРФЕЙСА (Вызывается до создания новых!)
local function cleanupGUI()
    pcall(function()
        local existing = CoreGui:FindFirstChild("Premium_ESP_Container") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Premium_ESP_Container")
        if existing then
            existing:Destroy()
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local hl = p.Character:FindFirstChild("ESPHighlight")
                if hl then hl:Destroy() end
            end
        end
    end)
end

cleanupGUI()

-- // 2. УМНАЯ ОЧИСТКА DRAWING ИЗ ГЛОБАЛЬНОГО ОКРУЖЕНИЯ (Решает проблему "призраков")
if getgenv().Premium_FOVCircle then
    pcall(function() getgenv().Premium_FOVCircle:Remove() end)
    getgenv().Premium_FOVCircle = nil
end
if getgenv().Premium_TargetLine then
    pcall(function() getgenv().Premium_TargetLine:Remove() end)
    getgenv().Premium_TargetLine = nil
end

-- // 3. ИНИЦИАЛИЗАЦИЯ НОВЫХ DRAWING ЭЛЕМЕНТОВ С ЗАПИСЬЮ В GETGENV()
local FOVCircle
local TargetLine

pcall(function()
    getgenv().Premium_FOVCircle = Drawing.new("Circle")
    FOVCircle = getgenv().Premium_FOVCircle
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 64
    FOVCircle.Filled = false
    FOVCircle.Color = CONFIG.FOVColor
    FOVCircle.Transparency = 1
    FOVCircle.Visible = false

    getgenv().Premium_TargetLine = Drawing.new("Line")
    TargetLine = getgenv().Premium_TargetLine
    TargetLine.Thickness = 1.5
    TargetLine.Color = CONFIG.TracerColor
    TargetLine.Transparency = 1
    TargetLine.Visible = false
end)

-- // ОБХОД КЭША GITHUB
local cacheBypassUrl = "https://raw.githubusercontent.com/GibkiyZXC/ui-Perplexity.win2-/main/Library.lua?t=" .. tostring(os.time())

local successLoad, rawLibrary = pcall(function()
    return game:HttpGet(cacheBypassUrl)
end)

if not successLoad then
    warn("[Loader Error]: Не удалось получить код библиотеки с GitHub.")
    return
end

local loaderFunction, compileError = loadstring(rawLibrary)

if not loaderFunction then
    warn("==========================================================")
    warn("[Syntax Error in Library.lua]: Код библиотеки повреждён!")
    warn("Ошибка компиляции: " .. tostring(compileError))
    warn("==========================================================")
    return
end

local Perplexity = loaderFunction()
local Window = Perplexity.new("Premium Suite") -- Инициализируем проект!

-- Вкладка Аимбота
local AimbotTab = Window:CreateTab("Aimbot")
local AimSettings = AimbotTab:CreateSection("Aimbot Settings", 1)
local AimVisuals = AimbotTab:CreateSection("Aim Visuals", 2)

-- Вкладка ESP
local VisualsTab = Window:CreateTab("Visuals")
local ESPSettings = VisualsTab:CreateSection("ESP Settings", 1)
local ESPColors = VisualsTab:CreateSection("Colors & Transparency", 2)

-- Вкладка Настроек Меню
local SettingsTab = Window:CreateTab("Settings")
local MenuSettings = SettingsTab:CreateSection("Menu Settings", 1)

-- // ЗАПОЛНЕНИЕ ИНТЕРФЕЙСА

-- Раздел Аимбота
AimSettings:CreateCheckbox("Enable Aimbot", false, function(state)
    CONFIG.AimActive = state
end)

AimSettings:CreateKeybind("Aimbot Trigger Key", "MouseButton2", function(key)
    CONFIG.AimKey = key
end)

AimSettings:CreateDropdown("Aim Targeting Bone", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(selected)
    CONFIG.AimPart = selected
end)

AimSettings:CreateSlider("Aimbot FOV Range", 10, 800, 100, function(value)
    CONFIG.AimFOV = value
end)

AimSettings:CreateSlider("Smoothness Value", 1, 20, 3, function(value)
    CONFIG.AimSmoothness = value
end)

AimSettings:CreateCheckbox("Team Check (Aim)", false, function(state)
    CONFIG.AimTeamCheck = state
end)

-- Раздел визуалов Аимбота
local FOVBox = AimVisuals:CreateCheckbox("Show FOV Circle", false, function(state)
    CONFIG.ShowFOV = state
end)
FOVBox:CreateColorpicker(CONFIG.FOVColor, function(color)
    CONFIG.FOVColor = color
end)

local TracerBox = AimVisuals:CreateCheckbox("Show Target Tracer", false, function(state)
    CONFIG.ShowTargetTracer = state
end)
TracerBox:CreateColorpicker(CONFIG.TracerColor, function(color)
    CONFIG.TracerColor = color
end)

-- Раздел ESP настроек
ESPSettings:CreateCheckbox("Master Toggle", true, function(state)
    CONFIG.EnableESP = state
    if not state then
        for _, esp in pairs(ActiveESPs) do
            if esp and esp.MainFrame then
                esp.MainFrame.Visible = false
            end
        end
    end
end)

local ESPBoxCheck = ESPSettings:CreateCheckbox("Draw Boxes", true, function(state)
    CONFIG.ShowBox = state
end)
ESPBoxCheck:CreateColorpicker(CONFIG.BoxColor, function(color)
    CONFIG.BoxColor = color
end)

local ESPNameCheck = ESPSettings:CreateCheckbox("Show Usernames", true, function(state)
    CONFIG.ShowNames = state
end)
ESPNameCheck:CreateColorpicker(CONFIG.NameColor, function(color)
    CONFIG.NameColor = color
end)

local ESPDistCheck = ESPSettings:CreateCheckbox("Show Distance", true, function(state)
    CONFIG.ShowDistance = state
end)
ESPDistCheck:CreateColorpicker(CONFIG.DistanceColor, function(color)
    CONFIG.DistanceColor = color
end)

ESPSettings:CreateCheckbox("Draw Health Bar", true, function(state)
    CONFIG.ShowHealth = state
end)

ESPSettings:CreateCheckbox("Team Check (ESP)", false, function(state)
    CONFIG.TeamCheck = state
end)

-- Раздел цветов & прозрачности ESP
ESPColors:CreateCheckbox("Enable 3D Body Highlight", true, function(state)
    CONFIG.Enable3DHighlight = state
    if not state then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local hl = p.Character:FindFirstChild("ESPHighlight")
                if hl then hl:Destroy() end
            end
        end
    end
end)

ESPColors:CreateSlider("Highlight Fill %", 0, 100, 88, function(value)
    CONFIG.HighlightFillTransparency = value / 100
end)

ESPColors:CreateSlider("Highlight Outline %", 0, 100, 100, function(value)
    CONFIG.HighlightOutlineTransparency = value / 100
end)

ESPColors:CreateSlider("Health Glow Transparency %", 0, 100, 65, function(value)
    CONFIG.GlowTransparency = value / 100
end)

-- Раздел настроек управления интерфейсом
getgenv().toggleKey = Enum.KeyCode.RightShift
_G.toggleKey = Enum.KeyCode.RightShift

MenuSettings:CreateKeybind("Hide / Show Key", "RightShift", function(key)
    getgenv().toggleKey = key
    _G.toggleKey = key
end)

-- // СОЗДАНИЕ КОНТЕЙНЕРА ИНТЕРФЕЙСА ДЛЯ ESP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Premium_ESP_Container"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local success, _ = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Функция плавного изменения цвета (Зеленый -> Желтый -> Красный)
local function getHealthColor(percent)
    local r = math.clamp(2 - percent * 2, 0, 1)
    local g = math.clamp(percent * 2, 0, 1)
    return Color3.new(r, g, 0.15)
end

-- Функция создания ESP объектов
local function createESP(player)
    if player == LocalPlayer then return end

    local esp = {}

    local MainFrame = Instance.new("Frame")
    MainFrame.BackgroundTransparency = 1
    MainFrame.Size = UDim2.new(0, 100, 0, 100)
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui

    -- Рамка ESP
    local Box = Instance.new("Frame")
    Box.BackgroundTransparency = 1
    Box.Size = UDim2.new(1, 0, 1, 0)
    Box.Parent = MainFrame

    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Color = CONFIG.BoxColor
    BoxStroke.Thickness = 1
    BoxStroke.LineJoinMode = Enum.LineJoinMode.Miter
    BoxStroke.Parent = Box

    local BoxOutline = Instance.new("UIStroke")
    BoxOutline.Color = CONFIG.BoxOutlineColor
    BoxOutline.Thickness = 2.5
    BoxOutline.Transparency = 0.6
    BoxOutline.LineJoinMode = Enum.LineJoinMode.Miter
    BoxOutline.Parent = Box

    -- Здоровье
    local HealthBG = Instance.new("Frame")
    HealthBG.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    HealthBG.BackgroundTransparency = 0.5
    HealthBG.BorderSizePixel = 0
    HealthBG.Position = UDim2.new(0, -6, 0, 0)
    HealthBG.Size = UDim2.new(0, 3, 1, 0)
    HealthBG.Parent = MainFrame

    local HealthBGCorners = Instance.new("UICorner")
    HealthBGCorners.CornerRadius = UDim.new(0, 2)
    HealthBGCorners.Parent = HealthBG

    local HealthBar = Instance.new("Frame")
    HealthBar.BorderSizePixel = 0
    HealthBar.AnchorPoint = Vector2.new(0, 1)
    HealthBar.Position = UDim2.new(0, 0, 1, 0)
    HealthBar.Size = UDim2.new(1, 0, 1, 0)
    HealthBar.Parent = HealthBG

    local HealthBarCorners = Instance.new("UICorner")
    HealthBarCorners.CornerRadius = UDim.new(0, 2)
    HealthBarCorners.Parent = HealthBar

    local HealthGlow = Instance.new("ImageLabel")
    HealthGlow.Name = "HealthGlow"
    HealthGlow.BackgroundTransparency = 1
    HealthGlow.Image = "rbxassetid://1316045217"
    HealthGlow.ScaleType = Enum.ScaleType.Slice
    HealthGlow.SliceCenter = Rect.new(10, 10, 118, 118)
    HealthGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    HealthGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    HealthGlow.Size = UDim2.new(1, 28, 1, 28)
    HealthGlow.ImageTransparency = CONFIG.GlowTransparency
    HealthGlow.ZIndex = HealthBar.ZIndex - 1
    HealthGlow.Parent = HealthBar

    -- Никнейм
    local NameLabel = Instance.new("TextLabel")
    NameLabel.BackgroundTransparency = 1
    NameLabel.Position = UDim2.new(0.5, 0, 0, -14)
    NameLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    NameLabel.Size = UDim2.new(0, 200, 0, 15)
    NameLabel.Font = CONFIG.Font
    NameLabel.TextSize = CONFIG.TextSize
    NameLabel.TextColor3 = CONFIG.NameColor
    NameLabel.TextStrokeTransparency = 0.1
    NameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    NameLabel.Text = player.DisplayName or player.Name
    NameLabel.Parent = MainFrame

    -- Дистанция
    local DistanceLabel = Instance.new("TextLabel")
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.Position = UDim2.new(0.5, 0, 1, 7)
    DistanceLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    DistanceLabel.Size = UDim2.new(0, 200, 0, 15)
    DistanceLabel.Font = CONFIG.Font
    DistanceLabel.TextSize = CONFIG.TextSize - 1
    DistanceLabel.TextColor3 = CONFIG.DistanceColor
    DistanceLabel.TextStrokeTransparency = 0.1
    DistanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    DistanceLabel.Text = "0 studs"
    DistanceLabel.Parent = MainFrame

    -- ХП числом
    local HealthText = Instance.new("TextLabel")
    HealthText.BackgroundTransparency = 1
    HealthText.AnchorPoint = Vector2.new(1, 0.5)
    HealthText.Size = UDim2.new(0, 30, 0, 12)
    HealthText.Font = CONFIG.Font
    HealthText.TextSize = CONFIG.TextSize - 2
    HealthText.TextColor3 = Color3.fromRGB(255, 255, 255)
    HealthText.TextStrokeTransparency = 0.1
    HealthText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    HealthText.TextXAlignment = Enum.TextXAlignment.Right
    HealthText.Visible = false
    HealthText.Parent = MainFrame

    esp.MainFrame = MainFrame
    esp.Box = Box
    esp.BoxStroke = BoxStroke
    esp.HealthBar = HealthBar
    esp.HealthGlow = HealthGlow
    esp.HealthText = HealthText
    esp.DistanceLabel = DistanceLabel
    esp.NameLabel = NameLabel
    esp.Player = player

    ActiveESPs[player] = esp
end

local function removeESP(player)
    if ActiveESPs[player] then
        pcall(function()
            ActiveESPs[player].MainFrame:Destroy()
        end)
        ActiveESPs[player] = nil
    end
    if player.Character then
        local hl = player.Character:FindFirstChild("ESPHighlight")
        if hl then hl:Destroy() end
    end
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

-- Вспомогательная функция для безопасного отслеживания нажатия AimKey
local function isAimKeyPressed()
    local key = CONFIG.AimKey
    if not key then return false end
    
    if typeof(key) == "EnumItem" then
        if key.Name:find("MouseButton") then
            return UserInputService:IsMouseButtonPressed(key)
        else
            return UserInputService:IsKeyDown(key)
        end
    elseif typeof(key) == "string" then
        if key == "MouseButton1" or key == "MouseButton2" then
            return UserInputService:IsMouseButtonPressed(Enum.UserInputType[key])
        else
            local successCode, keyCode = pcall(function() return Enum.KeyCode[key] end)
            if successCode and keyCode then
                return UserInputService:IsKeyDown(keyCode)
            end
        end
    end
    return false
end

-- Безопасный определитель кости для R6/R15
local function getAimPart(character)
    if not character then return nil end
    local partName = CONFIG.AimPart or "Head"
    if partName == "Torso" then
        return character:FindFirstChild("HumanoidRootPart") 
            or character:FindFirstChild("UpperTorso") 
            or character:FindFirstChild("Torso")
    end
    return character:FindFirstChild(partName)
end

-- Поиск ближайшего игрока к курсору (в пределах FOV)
local function getClosestPlayer()
    local target = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local Camera = Workspace.CurrentCamera
    if not Camera then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if CONFIG.AimTeamCheck and player.Team == LocalPlayer.Team then
                continue
            end

            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local hitPart = getAimPart(player.Character)

            if humanoid and humanoid.Health > 0 and hitPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance and distance <= CONFIG.AimFOV then
                        shortestDistance = distance
                        target = player
                    end
                end
            end
        end
    end
    return target
end

-- Резервный принудительный слушатель клавиши скрытия
local menuVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if UserInputService:GetFocusedTextBox() then return end
    
    local currentKey = getgenv().toggleKey or Enum.KeyCode.RightShift
    if input.KeyCode == currentKey then
        if Window and Window.MainFrame then
            menuVisible = not menuVisible
            Window.MainFrame.Visible = menuVisible
            
            local MenuBlur = game:GetService("Lighting"):FindFirstChild("Perplexity_Blur")
            if MenuBlur then
                MenuBlur.Enabled = menuVisible
            end
        end
    end
end)

-- // ГЛАВНЫЙ ИГРОВОЙ ЦИКЛ ОБНОВЛЕНИЯ (ЗАЩИЩЕННЫЙ РАСПРЕДЕЛЕННЫМИ PCALL)
RunService.RenderStepped:Connect(function()
    local Camera = Workspace.CurrentCamera
    if not Camera then return end

    local mousePos
    pcall(function()
        mousePos = UserInputService:GetMouseLocation()
    end)
    if not mousePos then mousePos = Vector2.new(0, 0) end

    -- 1. Обновление визуалов Аимбота (FOVCircle)
    pcall(function()
        if FOVCircle then
            if CONFIG.ShowFOV then
                FOVCircle.Position = mousePos
                FOVCircle.Radius = CONFIG.AimFOV
                FOVCircle.Color = CONFIG.FOVColor
                FOVCircle.Transparency = 1
                FOVCircle.Visible = true
            else
                FOVCircle.Visible = false
            end
        end
    end)

    local targetPlayer
    pcall(function()
        targetPlayer = getClosestPlayer()
    end)

    -- 2. Обновление Target Line (Tracer)
    pcall(function()
        if TargetLine then
            if CONFIG.ShowTargetTracer and targetPlayer and targetPlayer.Character then
                local part = getAimPart(targetPlayer.Character)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        TargetLine.From = mousePos
                        TargetLine.To = Vector2.new(screenPos.X, screenPos.Y)
                        TargetLine.Color = CONFIG.TracerColor
                        TargetLine.Transparency = 1
                        TargetLine.Visible = true
                    else
                        TargetLine.Visible = false
                    end
                else
                    TargetLine.Visible = false
                end
            else
                TargetLine.Visible = false
            end
        end
    end)

    -- 3. Логика Аимбота (Доводка камеры)
    pcall(function()
        if CONFIG.AimActive and isAimKeyPressed() and targetPlayer and targetPlayer.Character then
            local part = getAimPart(targetPlayer.Character)
            if part then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                if CONFIG.AimSmoothness > 1 then
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / CONFIG.AimSmoothness)
                else
                    Camera.CFrame = targetCFrame
                end
            end
        end
    end)

    -- 4. Обновление ESP Игроков
    for player, esp in pairs(ActiveESPs) do
        pcall(function()
            if not esp or typeof(esp) ~= "table" then return end
            if not esp.MainFrame then return end

            local character = player.Character
            if not character then
                esp.MainFrame.Visible = false
                return
            end

            if CONFIG.EnableESP then
                if CONFIG.TeamCheck and player.Team == LocalPlayer.Team then
                    esp.MainFrame.Visible = false
                    local hl = character:FindFirstChild("ESPHighlight")
                    if hl then hl:Destroy() end
                    return
                end

                local hrp = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")

                if hrp and humanoid and humanoid.Health > 0 then
                    local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                    if onScreen then
                        local topViewport = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                        local bottomViewport = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))

                        local height = math.abs(topViewport.Y - bottomViewport.Y)
                        local width = height * 0.58

                        -- Позиционирование рамки
                        esp.MainFrame.Size = UDim2.new(0, width, 0, height)
                        esp.MainFrame.Position = UDim2.new(0, topViewport.X - width/2, 0, topViewport.Y)
                        esp.MainFrame.Visible = true

                        -- Обновление динамических цветов
                        if esp.BoxStroke then esp.BoxStroke.Color = CONFIG.BoxColor end
                        if esp.NameLabel then esp.NameLabel.TextColor3 = CONFIG.NameColor end
                        if esp.DistanceLabel then esp.DistanceLabel.TextColor3 = CONFIG.DistanceColor end

                        if esp.Box then esp.Box.Visible = CONFIG.ShowBox end
                        if esp.NameLabel then esp.NameLabel.Visible = CONFIG.ShowNames end
                        
                        if esp.DistanceLabel then 
                            esp.DistanceLabel.Visible = CONFIG.ShowDistance
                            local distance = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                            esp.DistanceLabel.Text = tostring(distance) .. " studs"
                        end

                        -- Шкала здоровья
                        if esp.HealthBar and esp.HealthBar.Parent then
                            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                            esp.HealthBar.Size = UDim2.new(1, 0, healthPercent, 0)
                            esp.HealthBar.Parent.Visible = CONFIG.ShowHealth

                            local healthColor = getHealthColor(healthPercent)
                            esp.HealthBar.BackgroundColor3 = healthColor
                            
                            if esp.HealthGlow then
                                esp.HealthGlow.ImageColor3 = healthColor
                                esp.HealthGlow.ImageTransparency = CONFIG.GlowTransparency
                            end

                            -- Число ХП
                            if esp.HealthText then
                                if CONFIG.ShowHealth and healthPercent < 0.98 then
                                    esp.HealthText.Text = tostring(math.floor(humanoid.Health))
                                    esp.HealthText.Position = UDim2.new(0, -10, 1 - healthPercent, 0)
                                    esp.HealthText.Visible = true
                                else
                                    esp.HealthText.Visible = false
                                end
                            end
                        end

                        -- Свечение 3D Highlight
                        if CONFIG.Enable3DHighlight then
                            local highlight = character:FindFirstChild("ESPHighlight")
                            if not highlight then
                                highlight = Instance.new("Highlight")
                                highlight.Name = "ESPHighlight"
                                highlight.Parent = character
                            end
                            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                            highlight.FillColor = getHealthColor(healthPercent)
                            highlight.OutlineColor = getHealthColor(healthPercent)
                            highlight.FillTransparency = CONFIG.HighlightFillTransparency
                            highlight.OutlineTransparency = CONFIG.HighlightOutlineTransparency
                        else
                            local hl = character:FindFirstChild("ESPHighlight")
                            if hl then hl:Destroy() end
                        end
                    else
                        esp.MainFrame.Visible = false
                    end
                else
                    esp.MainFrame.Visible = false
                    local hl = character:FindFirstChild("ESPHighlight")
                    if hl then hl:Destroy() end
                end
            else
                esp.MainFrame.Visible = false
                local hl = character:FindFirstChild("ESPHighlight")
                if hl then hl:Destroy() end
            end
        end)
    end
end)
