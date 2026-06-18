-- =============================================================================
-- [[ PERPLEXITY.WIN - HIGH-FIDELITY UI FRAMEWORK & COMPATIBILITY LAYER ]]
-- [[ Library.lua ]]
-- =============================================================================

local Library = {}
Library.__index = Library

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    Players.Changed:Wait()
    LocalPlayer = Players.LocalPlayer
end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

-- Поиск PlayerGui
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Perplexity_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, err = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success or not ScreenGui.Parent then
    ScreenGui.Parent = PlayerGui
end

-- Палитра темы по умолчанию
local THEME = {
    Background = Color3.fromRGB(11, 11, 14),
    SidebarBg = Color3.fromRGB(15, 15, 20),
    SectionBg = Color3.fromRGB(16, 16, 23),
    Accent = Color3.fromRGB(255, 30, 60), -- Ярко-красный неон
    Text = Color3.fromRGB(240, 240, 245),
    TextMuted = Color3.fromRGB(110, 112, 125),
    Border = Color3.fromRGB(24, 24, 30),
    Outline = Color3.fromRGB(32, 32, 44)
}

Library.Theme = THEME

-- Размытие заднего плана
local MenuBlur = Lighting:FindFirstChild("Perplexity_Blur")
if not MenuBlur then
    MenuBlur = Instance.new("BlurEffect")
    MenuBlur.Name = "Perplexity_Blur"
    MenuBlur.Size = 14
    MenuBlur.Enabled = true
    MenuBlur.Parent = Lighting
end

local optBlurEnabled = true
local optSnowEnabled = true

-- Глобальные списки динамической регистрации для авто-смены темы
local allParticles = {}
local allCheckboxes = {}
local allSliders = {}
local allDropdownArrows = {}
local allKeybinds = {}
local allTabs = {}
local allSubTabs = {}
local allSectionTitles = {}
local allWidgets = {}

local TitleTextLabel = nil
local WindowInstance = nil

local activeParticleColors = {
    Color3.fromRGB(255, 30, 60),
    Color3.fromRGB(100, 10, 25),
    Color3.fromRGB(25, 25, 30)
}

local Flags = {}
local SaveFlags = {}

-- =============================================================================
-- [[ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ]]
-- =============================================================================
local MenuFont = Enum.Font.GothamMedium
local successLoad, errLoad = pcall(function()
    if not isfolder("nexonix") then makefolder("nexonix") end
    if not isfolder("nexonix/Assets") then makefolder("nexonix/Assets") end
    if not isfile("Figtree-Semibold") then
        writefile("Figtree-Semibold", game:HttpGet("https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/Figtree-SemiBold.ttf"))
    end
    local fontData = {
        name = "figtree-Semibold",
        faces = {{name = "figtree-Semibold", weight = 400, style = "Regular", assetId = getcustomasset("Figtree-Semibold")}}
    }
    writefile("nexonix/Assets/figtree-Semibold.font", HttpService:JSONEncode(fontData))
    MenuFont = Font.new(getcustomasset("nexonix/Assets/figtree-Semibold.font"))
end)

local function ApplyFont(label, size)
    if typeof(MenuFont) == "Font" then label.FontFace = MenuFont else label.Font = MenuFont end
    label.TextSize = size or 14
end

local function Tween(object, time, properties, style, direction)
    local t = TweenService:Create(object, TweenInfo.new(time, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), properties)
    t:Play()
    return t
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function AddStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function AddTextStroke(parent)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(0, 0, 0)
    s.Thickness = 1
    s.Transparency = 0.75
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    s.Parent = parent
    return s
end

local function AddDoubleStroke(parent)
    local outer = AddStroke(parent, Color3.fromRGB(4, 4, 6), 1.6)
    local inner = AddStroke(parent, THEME.Outline, 1)
    return outer, inner
end

local function MakeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- =============================================================================
-- [[ СИСТЕМА ЧАСТИЦ СНЕГА ]]
-- =============================================================================
local function SetupMenuBackgroundParticles(parent)
    local particleContainer = Instance.new("Frame")
    particleContainer.Size = UDim2.new(1, 0, 1, 0)
    particleContainer.BackgroundTransparency = 1
    particleContainer.ClipsDescendants = true
    particleContainer.ZIndex = 1
    particleContainer.Parent = parent
    
    local particles = {}
    for i = 1, 22 do
        local p = Instance.new("ImageLabel")
        local size = math.random(15, 30)
        p.Size = UDim2.new(0, size, 0, size)
        p.Image = "rbxassetid://10822615828"
        p.ImageColor3 = activeParticleColors[math.random(1, #activeParticleColors)]
        p.ImageTransparency = math.random(45, 55) / 100
        p.BackgroundTransparency = 1
        p.Position = UDim2.new(math.random(), 0, math.random(), 0)
        p.ZIndex = 1
        p.Parent = particleContainer
        
        local item = {Obj = p, Speed = math.random(4, 12) / 1000, Wind = math.random(-3, 3) / 1000}
        table.insert(particles, item)
        table.insert(allParticles, item)
    end
    
    RunService.RenderStepped:Connect(function(dt)
        if menuVisible and parent.Visible and optSnowEnabled then
            particleContainer.Visible = true
            for _, p in ipairs(particles) do
                local pos = p.Obj.Position
                local newY = pos.Y.Scale + p.Speed * (dt * 60)
                local newX = pos.X.Scale + p.Wind * (dt * 60)
                if newY > 1 then newY = -0.05; newX = math.random() end
                if newX > 1 or newX < 0 then newX = math.random() end
                p.Obj.Position = UDim2.new(newX, 0, newY, 0)
            end
        else
            particleContainer.Visible = false
        end
    end)
    return particleContainer
end

-- =============================================================================
-- [[ ГЛОБАЛЬНЫЙ ЦВЕТОПЕРЕДАТЧИК (COLORPICKER) ]]
-- =============================================================================
local ColorpickerWindow = Instance.new("Frame")
ColorpickerWindow.Size = UDim2.new(0, 140, 0, 145)
ColorpickerWindow.BackgroundColor3 = THEME.SidebarBg
ColorpickerWindow.Visible = false
ColorpickerWindow.ZIndex = 1000
AddCorner(ColorpickerWindow, 6)
AddDoubleStroke(ColorpickerWindow)
ColorpickerWindow.Parent = ScreenGui

local svGrid = Instance.new("Frame")
svGrid.Size = UDim2.new(0, 95, 0, 95)
svGrid.Position = UDim2.new(0, 10, 0, 10)
svGrid.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
svGrid.ZIndex = 1001
AddCorner(svGrid, 3)
svGrid.Parent = ColorpickerWindow

local satGrad = Instance.new("Frame")
satGrad.Size = UDim2.new(1, 0, 1, 0)
satGrad.BackgroundTransparency = 0
satGrad.ZIndex = 1002
AddCorner(satGrad, 3)
satGrad.Parent = svGrid

local sGradient = Instance.new("UIGradient")
sGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
sGradient.Transparency = NumberSequence.new(0, 1)
sGradient.Parent = satGrad

local valGrad = Instance.new("Frame")
valGrad.Size = UDim2.new(1, 0, 1, 0)
valGrad.BackgroundTransparency = 0
valGrad.ZIndex = 1003
AddCorner(valGrad, 3)
valGrad.Parent = svGrid

local vGradient = Instance.new("UIGradient")
vGradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
vGradient.Transparency = NumberSequence.new(1, 0)
vGradient.Rotation = 90
vGradient.Parent = valGrad

local svKnob = Instance.new("Frame")
svKnob.AnchorPoint = Vector2.new(0.5, 0.5)
svKnob.Size = UDim2.new(0, 6, 0, 6)
svKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
svKnob.ZIndex = 1004
AddCorner(svKnob, 3)
AddStroke(svKnob, Color3.fromRGB(0, 0, 0), 1)
svKnob.Parent = svGrid

local hueSlider = Instance.new("Frame")
hueSlider.Size = UDim2.new(0, 12, 0, 95)
hueSlider.Position = UDim2.new(0, 118, 0, 10)
hueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
hueSlider.ZIndex = 1001
AddCorner(hueSlider, 2)
hueSlider.Parent = ColorpickerWindow

local hGradient = Instance.new("UIGradient")
hGradient.Rotation = 90
hGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
})
hGradient.Parent = hueSlider

local hueKnob = Instance.new("Frame")
hueKnob.AnchorPoint = Vector2.new(0.5, 0.5)
hueKnob.Size = UDim2.new(1, 4, 0, 2)
hueKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
hueKnob.ZIndex = 1002
AddCorner(hueKnob, 1)
AddStroke(hueKnob, Color3.fromRGB(0, 0, 0), 1)
hueKnob.Parent = hueSlider

local hexLabel = Instance.new("TextLabel")
hexLabel.Size = UDim2.new(1, -20, 0, 20)
hexLabel.Position = UDim2.new(0, 10, 0, 115)
hexLabel.BackgroundTransparency = 1
hexLabel.TextColor3 = THEME.TextMuted
hexLabel.Text = "HEX: #FFFFFF"
hexLabel.ZIndex = 1001
ApplyFont(hexLabel, 9)
AddTextStroke(hexLabel)
hexLabel.Parent = ColorpickerWindow

local activeColorpicker = nil
local openedThisFrame = false

local function updateSV(pos)
    local relativeX = math.clamp((pos.X - svGrid.AbsolutePosition.X) / svGrid.AbsoluteSize.X, 0, 1)
    local relativeY = math.clamp((pos.Y - svGrid.AbsolutePosition.Y) / svGrid.AbsoluteSize.Y, 0, 1)
    local s = relativeX
    local v = 1 - relativeY
    svKnob.Position = UDim2.new(relativeX, 0, relativeY, 0)
    if activeColorpicker then
        activeColorpicker.S = s
        activeColorpicker.V = v
        local color = Color3.fromHSV(activeColorpicker.H, s, v)
        activeColorpicker.Button.BackgroundColor3 = color
        hexLabel.Text = "HEX: #" .. color:ToHex():upper()
        activeColorpicker.Callback(color)
    end
end

local function updateHue(pos)
    local relativeY = math.clamp((pos.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
    local h = relativeY
    hueKnob.Position = UDim2.new(0.5, 0, relativeY, 0)
    svGrid.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    if activeColorpicker then
        activeColorpicker.H = h
        local color = Color3.fromHSV(h, activeColorpicker.S, activeColorpicker.V)
        activeColorpicker.Button.BackgroundColor3 = color
        hexLabel.Text = "HEX: #" .. color:ToHex():upper()
        activeColorpicker.Callback(color)
    end
end

local svDragging = false
svGrid.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        svDragging = true; updateSV(input.Position)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if svDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSV(input.Position) end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then svDragging = false end
end)

local hueDragging = false
hueSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        hueDragging = true; updateHue(input.Position)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateHue(input.Position) end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then hueDragging = false end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if ColorpickerWindow.Visible then
            if openedThisFrame then return end
            local mPos = UserInputService:GetMouseLocation()
            local wPos = ColorpickerWindow.AbsolutePosition
            local wSize = ColorpickerWindow.AbsoluteSize
            local inside = mPos.X >= wPos.X and mPos.X <= wPos.X + wSize.X and mPos.Y >= wPos.Y and mPos.Y <= wPos.Y + wSize.Y
            if not inside then ColorpickerWindow.Visible = false end
        end
    end
end)

-- =============================================================================
-- [[ ШАБЛОН ДЛЯ СОЗДАНИЯ ПЛАВАЮЩИХ ВИДЖЕТОВ ]]
-- =============================================================================
local function CreateBaseWidget(name, size)
    local widgetFrame = Instance.new("Frame")
    widgetFrame.Size = size or UDim2.new(0, 180, 0, 100)
    widgetFrame.Position = UDim2.new(0.8, 0, 0.2, 0)
    widgetFrame.BackgroundColor3 = THEME.SidebarBg
    widgetFrame.BackgroundTransparency = 0.12
    widgetFrame.Visible = false
    AddCorner(widgetFrame, 6)
    AddDoubleStroke(widgetFrame)
    widgetFrame.Parent = ScreenGui
    
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 20)
    topBar.BackgroundTransparency = 1
    topBar.Parent = widgetFrame
    
    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(1, 0, 0, 2)
    accentLine.Position = UDim2.new(0, 0, 0, 0)
    accentLine.BackgroundColor3 = THEME.Accent
    accentLine.Parent = widgetFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name:upper()
    title.TextColor3 = THEME.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    ApplyFont(title, 10)
    AddTextStroke(title)
    title.Parent = topBar
    
    MakeDraggable(widgetFrame, topBar)
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 1, -30)
    container.Position = UDim2.new(0, 10, 0, 25)
    container.BackgroundTransparency = 1
    container.Parent = widgetFrame
    
    local widgetObj = {
        Frame = widgetFrame,
        Container = container,
        AccentLine = accentLine,
        TitleLabel = title
    }
    
    function widgetObj:SetVisibility(state)
        widgetFrame.Visible = state
    end
    
    table.insert(allWidgets, widgetObj)
    return widgetObj
end

-- =============================================================================
-- [[ РЕАЛИЗАЦИЯ ВСЕХ 12 ВИДЖЕТОВ ]]
-- =============================================================================

function Library:Watermark(options)
    local widget = CreateBaseWidget(options.Name or "Watermark", UDim2.new(0, 240, 0, 32))
    widget.TitleLabel:Destroy()
    widget.Frame.Size = UDim2.new(0, 240, 0, 26)
    widget.Frame.Position = UDim2.new(0.8, 0, 0.05, 0)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = THEME.Text
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    ApplyFont(textLabel, 10)
    AddTextStroke(textLabel)
    textLabel.Parent = widget.Frame
    
    local fps = 0
    local lastTime = os.clock()
    RunService.RenderStepped:Connect(function()
        local currentTime = os.clock()
        fps = math.floor(1 / (currentTime - lastTime))
        lastTime = currentTime
        if widget.TextProvider then
            textLabel.Text = widget.TextProvider(fps)
        else
            textLabel.Text = string.format("%s | %d FPS", options.Name or "Library", fps)
        end
    end)
    
    function widget:SetDynamicTextProvider(callback)
        widget.TextProvider = callback
    end
    
    return widget
end

function Library:KeybindList(options)
    local widget = CreateBaseWidget(options.Name or "Keybinds", UDim2.new(0, 180, 0, 120))
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = widget.Container
    
    function widget:Add(bindName)
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, 0, 0, 14)
        itemFrame.BackgroundTransparency = 1
        itemFrame.Parent = widget.Container
        
        local labelName = Instance.new("TextLabel")
        labelName.Size = UDim2.new(0.5, 0, 1, 0)
        labelName.BackgroundTransparency = 1
        labelName.Text = bindName
        labelName.TextColor3 = THEME.TextMuted
        labelName.TextXAlignment = Enum.TextXAlignment.Left
        ApplyFont(labelName, 9)
        labelName.Parent = itemFrame
        
        local labelKey = Instance.new("TextLabel")
        labelKey.Size = UDim2.new(0.2, 0, 1, 0)
        labelKey.Position = UDim2.new(0.5, 0, 0, 0)
        labelKey.BackgroundTransparency = 1
        labelKey.Text = "[None]"
        labelKey.TextColor3 = THEME.Accent
        ApplyFont(labelKey, 9)
        labelKey.Parent = itemFrame
        table.insert(allKeybinds, labelKey)
        
        local labelStatus = Instance.new("TextLabel")
        labelStatus.Size = UDim2.new(0.3, 0, 1, 0)
        labelStatus.Position = UDim2.new(0.7, 0, 0, 0)
        labelStatus.BackgroundTransparency = 1
        labelStatus.Text = ""
        labelStatus.TextColor3 = THEME.TextMuted
        labelStatus.TextXAlignment = Enum.TextXAlignment.Right
        ApplyFont(labelStatus, 9)
        labelStatus.Parent = itemFrame
        
        local bindObj = {}
        function bindObj:Set(key) labelKey.Text = "[" .. tostring(key) .. "]" end
        function bindObj:SetStatus(status) labelStatus.Text = tostring(status) end
        function bindObj:SetVis(val) itemFrame.Visible = val end
        return bindObj
    end
    
    return widget
end

function Library:ESPPreview(options)
    local widget = CreateBaseWidget(options.Name or "ESP Preview", UDim2.new(0, 160, 0, 220))
    
    local viewport = Instance.new("ViewportFrame")
    viewport.Size = UDim2.new(1, 0, 1, 0)
    viewport.BackgroundTransparency = 1
    viewport.Parent = widget.Container
    
    local camera = Instance.new("Camera")
    camera.FieldOfView = 35
    camera.Parent = viewport
    viewport.CurrentCamera = camera
    camera.CFrame = CFrame.new(Vector3.new(0, 0.3, -6.5), Vector3.new(0, -0.3, 0))
    
    task.spawn(function()
        local successModel, model = pcall(function()
            return Players:CreateHumanoidModelFromUserId(1)
        end)
        if successModel and model then
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then part.Anchored = true; part.CanCollide = false end
            end
            model:PivotTo(CFrame.new(0, -0.5, 0))
            model.Parent = viewport
            
            local rotAngle = 0
            RunService.RenderStepped:Connect(function(dt)
                if widget.Frame.Visible then
                    rotAngle = rotAngle + dt * 45
                    model:PivotTo(CFrame.new(0, -0.4, 0) * CFrame.Angles(0, math.rad(rotAngle), 0))
                end
            end)
        end
    end)
    
    local espBox = Instance.new("Frame")
    espBox.Size = UDim2.new(0, 80, 0, 140)
    espBox.Position = UDim2.new(0.5, -40, 0.5, -70)
    espBox.BackgroundTransparency = 1
    local stroke = AddStroke(espBox, THEME.Accent, 1)
    espBox.Parent = viewport
    table.insert(allKeybinds, stroke)
    
    local espHealth = Instance.new("Frame")
    espHealth.Size = UDim2.new(0, 2, 0, 140)
    espHealth.Position = UDim2.new(0.5, -45, 0.5, -70)
    espHealth.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    espHealth.BorderSizePixel = 0
    espHealth.Parent = viewport
    
    local espName = Instance.new("TextLabel")
    espName.Size = UDim2.new(0, 100, 0, 12)
    espName.Position = UDim2.new(0.5, 0, 0.5, -82)
    espName.AnchorPoint = Vector2.new(0.5, 0.5)
    espName.BackgroundTransparency = 1
    espName.Text = "PREVIEW"
    espName.TextColor3 = Color3.fromRGB(255, 255, 255)
    ApplyFont(espName, 9)
    AddTextStroke(espName)
    espName.Parent = viewport
    
    function widget:SetText(name) espName.Text = tostring(name):upper() end
    return widget
end

function Library:TargetIndicator()
    local widget = CreateBaseWidget("Target Info", UDim2.new(0, 200, 0, 60))
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 12)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Target: sametexe001"
    nameLabel.TextColor3 = THEME.Text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    ApplyFont(nameLabel, 9)
    nameLabel.Parent = widget.Container
    
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, 0, 0, 4)
    barBg.Position = UDim2.new(0, 0, 0, 18)
    barBg.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    AddCorner(barBg, 2)
    barBg.Parent = widget.Container
    
    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0.74, 0, 1, 0)
    barFill.BackgroundColor3 = THEME.Accent
    AddCorner(barFill, 2)
    barFill.Parent = barBg
    table.insert(allSliders, {BarFill = barFill, ValueDisplay = nameLabel})
    
    return widget
end

function Library:RadarWidget(options)
    local widget = CreateBaseWidget(options.Name or "Radar", UDim2.new(0, 140, 0, 140))
    widget.Frame.Size = UDim2.new(0, 140, 0, 160)
    
    local radarCircle = Instance.new("Frame")
    radarCircle.Size = UDim2.new(1, 0, 1, 0)
    radarCircle.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    AddCorner(radarCircle, 70)
    local stroke = AddStroke(radarCircle, THEME.Accent, 1)
    radarCircle.Parent = widget.Container
    table.insert(allKeybinds, stroke)
    
    local centerPoint = Instance.new("Frame")
    centerPoint.Size = UDim2.new(0, 4, 0, 4)
    centerPoint.Position = UDim2.new(0.5, -2, 0.5, -2)
    centerPoint.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    AddCorner(centerPoint, 2)
    centerPoint.Parent = radarCircle
    
    return widget
end

function Library:ConsoleLogger(options)
    local widget = CreateBaseWidget(options.Name or "Console", UDim2.new(0, 260, 0, 160))
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 2
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = widget.Container
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scroll
    
    function widget:AddOutput(text)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 14)
        label.BackgroundTransparency = 1
        label.Text = " " .. tostring(text)
        label.TextColor3 = THEME.TextMuted
        label.TextXAlignment = Enum.TextXAlignment.Left
        ApplyFont(label, 9)
        label.Parent = scroll
    end
    
    return widget
end

function Library:ModeratorList(options)
    local widget = CreateBaseWidget(options.Name or "Moderators", UDim2.new(0, 180, 0, 100))
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = widget.Container
    
    function widget:Add(name)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 14)
        label.BackgroundTransparency = 1
        label.Text = tostring(name)
        label.TextColor3 = Color3.fromRGB(255, 100, 100)
        label.TextXAlignment = Enum.TextXAlignment.Left
        ApplyFont(label, 9)
        label.Parent = widget.Container
    end
    function widget:Remove(name) end
    function widget:Clear() widget.Container:ClearAllChildren() end
    return widget
end

function Library:StatListWidget(options)
    local widget = CreateBaseWidget(options.Name or "Stats", UDim2.new(0, 180, 0, 100))
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = widget.Container
    
    function widget:SetLines(lines)
        widget.Container:ClearAllChildren()
        local l = Instance.new("UIListLayout")
        l.Padding = UDim.new(0, 4)
        l.Parent = widget.Container
        
        for _, line in ipairs(lines) do
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 14)
            label.BackgroundTransparency = 1
            label.Text = tostring(line)
            label.TextColor3 = THEME.Text
            label.TextXAlignment = Enum.TextXAlignment.Left
            ApplyFont(label, 9)
            label.Parent = widget.Container
        end
    end
    return widget
end

function Library:ChargeShotWidget(options)
    local widget = CreateBaseWidget(options.Name or "Charge Shot", UDim2.new(0, 180, 0, 45))
    widget.Frame.Size = UDim2.new(0, 180, 0, 50)
    
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, 0, 0, 4)
    barBg.Position = UDim2.new(0, 0, 0, 10)
    barBg.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    AddCorner(barBg, 2)
    barBg.Parent = widget.Container
    
    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0.5, 0, 1, 0)
    barFill.BackgroundColor3 = THEME.Accent
    AddCorner(barFill, 2)
    barFill.Parent = barBg
    table.insert(allSliders, {BarFill = barFill, ValueDisplay = barFill})
    
    return widget
end

function Library:InventoryViewer(options)
    return CreateBaseWidget(options.Name or "Inventory", UDim2.new(0, 200, 0, 120))
end

function Library:SpotifyPlayer()
    local widget = CreateBaseWidget("Spotify", UDim2.new(0, 220, 0, 65))
    widget.Frame.Size = UDim2.new(0, 220, 0, 75)
    
    local songLabel = Instance.new("TextLabel")
    songLabel.Size = UDim2.new(1, 0, 0, 12)
    songLabel.BackgroundTransparency = 1
    songLabel.Text = "Blinding Lights"
    songLabel.TextColor3 = THEME.Text
    songLabel.TextXAlignment = Enum.TextXAlignment.Left
    ApplyFont(songLabel, 10)
    songLabel.Parent = widget.Container
    
    local artistLabel = Instance.new("TextLabel")
    artistLabel.Size = UDim2.new(1, 0, 0, 12)
    artistLabel.Position = UDim2.new(0, 0, 0, 14)
    artistLabel.BackgroundTransparency = 1
    artistLabel.Text = "The Weeknd"
    artistLabel.TextColor3 = THEME.TextMuted
    artistLabel.TextXAlignment = Enum.TextXAlignment.Left
    ApplyFont(artistLabel, 9)
    artistLabel.Parent = widget.Container
    
    return widget
end

function Library:Playerlist(options)
    local widget = CreateBaseWidget(options.Name or "Players", UDim2.new(0, 180, 0, 120))
    return widget
end

-- =============================================================================
-- [[ КОНСТРУКТОР ГЛАВНОГО ОКНА ]]
-- =============================================================================

function Library:Window(options)
    WindowInstance = Perplexity.new(options)
    return WindowInstance
end

function Library:RegisterSettingsWidget(options)
    if WindowInstance and WindowInstance.WidgetTogglesSec then
        WindowInstance.WidgetTogglesSec:CreateCheckbox(options.Name, options.Default, options.Callback)
    end
end

function Library:Notification(text, duration, color)
    Notify("Perplexity.win", text, duration)
end

-- =============================================================================
-- [[ ОБНОВЛЕНИЕ ТЕМЫ ]]
-- =============================================================================
function UpdateBackgroundTheme(accentColor, particleColors)
    THEME.Accent = accentColor
    activeParticleColors = particleColors
    
    if TitleTextLabel then
        TitleTextLabel.TextColor3 = accentColor
    end
    
    for _, p in ipairs(allParticles) do
        p.Obj.ImageColor3 = particleColors[math.random(1, #particleColors)]
    end
    
    for _, widget in ipairs(allWidgets) do
        if widget.AccentLine then widget.AccentLine.BackgroundColor3 = accentColor end
    end
    
    for _, cb in ipairs(allCheckboxes) do
        if cb.CheckboxObj.State then cb.Indicator.BackgroundColor3 = THEME.Accent end
    end
    
    for _, sl in ipairs(allSliders) do
        if sl.BarFill then sl.BarFill.BackgroundColor3 = THEME.Accent end
        if sl.ValueDisplay and sl.ValueDisplay:IsA("TextLabel") then sl.ValueDisplay.TextColor3 = THEME.Accent end
    end
    
    for _, kb in ipairs(allKeybinds) do
        if kb:IsA("UIStroke") then
            kb.Color = THEME.Accent
        elseif kb:IsA("TextButton") or kb:IsA("TextLabel") then
            kb.TextColor3 = THEME.Accent
        end
    end
    
    for _, t in ipairs(allTabs) do
        t.Indicator.BackgroundColor3 = THEME.Accent
        if WindowInstance and WindowInstance.ActiveTab == t then t.Button.TextColor3 = THEME.Accent end
    end
    
    for _, st in ipairs(allSubTabs) do
        st.Underline.BackgroundColor3 = THEME.Accent
    end
    
    for _, title in ipairs(allSectionTitles) do
        title.TextColor3 = THEME.Accent
    end
end

-- =============================================================================
-- [[ СОХРАНЕНИЕ / ЗАГРУЗКА ]]
-- =============================================================================
function SaveConfig(slotName)
    pcall(function()
        if not isfolder("perplexity") then makefolder("perplexity") end
        if not isfolder("perplexity/Configs") then makefolder("perplexity/Configs") end
        writefile("perplexity/Configs/" .. slotName .. ".json", HttpService:JSONEncode(SaveFlags))
        Notify("Configs", "Настройки сохранены в слот: " .. slotName, 3)
    end)
end

function LoadConfig(slotName)
    pcall(function()
        local path = "perplexity/Configs/" .. slotName .. ".json"
        if isfile(path) then
            local data = HttpService:JSONDecode(readfile(path))
            for flagName, value in pairs(data) do
                if Flags[flagName] then pcall(function() Flags[flagName].Set(value) end) end
            end
            Notify("Configs", "Конфиг " .. slotName .. " успешно загружен!", 3)
        else
            Notify("Configs", "Конфигурация " .. slotName .. " не найдена.", 4)
        end
    end)
end

Library.Theme = THEME
getgenv().Perplexity = Library

return Library
