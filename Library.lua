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

local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)

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

local THEME = {
    Background = Color3.fromRGB(11, 11, 14),
    SidebarBg = Color3.fromRGB(15, 15, 20),
    SectionBg = Color3.fromRGB(16, 16, 23),
    Accent = Color3.fromRGB(255, 30, 60),
    Text = Color3.fromRGB(240, 240, 245),
    TextMuted = Color3.fromRGB(110, 112, 125),
    Border = Color3.fromRGB(24, 24, 30),
    Outline = Color3.fromRGB(32, 32, 44)
}

Library.Theme = THEME

local MenuBlur = Lighting:FindFirstChild("Perplexity_Blur")
if not MenuBlur then
    MenuBlur = Instance.new("BlurEffect")
    MenuBlur.Name = "Perplexity_Blur"
    MenuBlur.Size = 14
    MenuBlur.Enabled = true
    MenuBlur.Parent = Lighting
end

local optBlurEnabled, optSnowEnabled = true, true
local allParticles, allCheckboxes, allSliders, allDropdownArrows, allKeybinds, allTabs, allSubTabs, allSectionTitles, allWidgets = {}, {}, {}, {}, {}, {}, {}, {}, {}
local TitleTextLabel, WindowInstance = nil, nil

local activeParticleColors = {
    Color3.fromRGB(255, 30, 60),
    Color3.fromRGB(100, 10, 25),
    Color3.fromRGB(25, 25, 30)
}

local Flags, SaveFlags = {}, {}

-- =============================================================================
-- [[ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ]]
-- =============================================================================
local MenuFont = Enum.Font.GothamMedium
pcall(function()
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
            dragging, dragStart, startPos = true, input.Position, frame.Position
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

local function SetupMenuBackgroundParticles(parent)
    local particleContainer = Instance.new("Frame")
    particleContainer.Size, particleContainer.BackgroundTransparency, particleContainer.ClipsDescendants, particleContainer.ZIndex, particleContainer.Parent = UDim2.new(1, 0, 1, 0), 1, true, 1, parent
    
    local particles = {}
    for i = 1, 22 do
        local p = Instance.new("ImageLabel")
        local size = math.random(15, 30)
        p.Size, p.Image, p.ImageColor3, p.ImageTransparency, p.BackgroundTransparency, p.Position, p.ZIndex, p.Parent = UDim2.new(0, size, 0, size), "rbxassetid://10822615828", activeParticleColors[math.random(1, #activeParticleColors)], math.random(45, 55) / 100, 1, UDim2.new(math.random(), 0, math.random(), 0), 1, particleContainer
        
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
                if newY > 1 then newY, newX = -0.05, math.random() end
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
-- [[ ГЛОБАЛЬНЫЙ ЦВЕТОПЕРЕДАТЧИК ]]
-- =============================================================================
local ColorpickerWindow = Instance.new("Frame")
ColorpickerWindow.Size, ColorpickerWindow.BackgroundColor3, ColorpickerWindow.Visible, ColorpickerWindow.ZIndex = UDim2.new(0, 140, 0, 145), THEME.SidebarBg, false, 1000
AddCorner(ColorpickerWindow, 6)
AddDoubleStroke(ColorpickerWindow)
ColorpickerWindow.Parent = ScreenGui

local svGrid = Instance.new("Frame")
svGrid.Size, svGrid.Position, svGrid.BackgroundColor3, svGrid.ZIndex = UDim2.new(0, 95, 0, 95), UDim2.new(0, 10, 0, 10), Color3.fromRGB(255, 0, 0), 1001
AddCorner(svGrid, 3)
svGrid.Parent = ColorpickerWindow

local satGrad = Instance.new("Frame")
satGrad.Size, satGrad.BackgroundTransparency, satGrad.ZIndex = UDim2.new(1, 0, 1, 0), 0, 1002
AddCorner(satGrad, 3)
satGrad.Parent = svGrid

local sGradient = Instance.new("UIGradient")
sGradient.Color, sGradient.Transparency = ColorSequence.new(Color3.fromRGB(255, 255, 255)), NumberSequence.new(0, 1)
sGradient.Parent = satGrad

local valGrad = Instance.new("Frame")
valGrad.Size, valGrad.BackgroundTransparency, valGrad.ZIndex = UDim2.new(1, 0, 1, 0), 0, 1003
AddCorner(valGrad, 3)
valGrad.Parent = svGrid

local vGradient = Instance.new("UIGradient")
vGradient.Color, vGradient.Transparency, vGradient.Rotation = ColorSequence.new(Color3.fromRGB(0, 0, 0)), NumberSequence.new(1, 0), 90
vGradient.Parent = valGrad

local svKnob = Instance.new("Frame")
svKnob.AnchorPoint, svKnob.Size, svKnob.BackgroundColor3, svKnob.ZIndex = Vector2.new(0.5, 0.5), UDim2.new(0, 6, 0, 6), Color3.fromRGB(255, 255, 255), 1004
AddCorner(svKnob, 3)
AddStroke(svKnob, Color3.fromRGB(0, 0, 0), 1)
svKnob.Parent = svGrid

local hueSlider = Instance.new("Frame")
hueSlider.Size, hueSlider.Position, hueSlider.BackgroundColor3, hueSlider.ZIndex = UDim2.new(0, 12, 0, 95), UDim2.new(0, 118, 0, 10), Color3.fromRGB(255, 255, 255), 1001
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
hueKnob.AnchorPoint, hueKnob.Size, hueKnob.BackgroundColor3, hueKnob.ZIndex = Vector2.new(0.5, 0.5), UDim2.new(1, 4, 0, 2), Color3.fromRGB(255, 255, 255), 1002
AddCorner(hueKnob, 1)
AddStroke(hueKnob, Color3.fromRGB(0, 0, 0), 1)
hueKnob.Parent = hueSlider

local hexLabel = Instance.new("TextLabel")
hexLabel.Size, hexLabel.Position, hexLabel.BackgroundTransparency, hexLabel.TextColor3, hexLabel.Text, hexLabel.ZIndex = UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 115), 1, THEME.TextMuted, "HEX: #FFFFFF", 1001
ApplyFont(hexLabel, 9)
AddTextStroke(hexLabel)
hexLabel.Parent = ColorpickerWindow

local activeColorpicker = nil
local openedThisFrame = false

local function updateSV(pos)
    local relativeX = math.clamp((pos.X - svGrid.AbsolutePosition.X) / svGrid.AbsoluteSize.X, 0, 1)
    local relativeY = math.clamp((pos.Y - svGrid.AbsolutePosition.Y) / svGrid.AbsoluteSize.Y, 0, 1)
    local s, v = relativeX, 1 - relativeY
    svKnob.Position = UDim2.new(relativeX, 0, relativeY, 0)
    if activeColorpicker then
        activeColorpicker.S, activeColorpicker.V = s, v
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
            local wPos, wSize = ColorpickerWindow.AbsolutePosition, ColorpickerWindow.AbsoluteSize
            local inside = mPos.X >= wPos.X and mPos.X <= wPos.X + wSize.X and mPos.Y >= wPos.Y and mPos.Y <= wPos.Y + wSize.Y
            if not inside then ColorpickerWindow.Visible = false end
        end
    end
end)

local function CreateBaseWidget(name, size)
    local widgetFrame = Instance.new("Frame")
    widgetFrame.Size, widgetFrame.Position, widgetFrame.BackgroundColor3, widgetFrame.BackgroundTransparency, widgetFrame.Visible = size or UDim2.new(0, 180, 0, 100), UDim2.new(0.8, 0, 0.2, 0), THEME.SidebarBg, 0.12, false
    AddCorner(widgetFrame, 6)
    AddDoubleStroke(widgetFrame)
    widgetFrame.Parent = ScreenGui
    
    local topBar = Instance.new("Frame")
    topBar.Size, topBar.BackgroundTransparency, topBar.Parent = UDim2.new(1, 0, 0, 20), 1, widgetFrame
    
    local accentLine = Instance.new("Frame")
    accentLine.Size, accentLine.Position, accentLine.BackgroundColor3, accentLine.Parent = UDim2.new(1, 0, 0, 2), UDim2.new(0, 0, 0, 0), THEME.Accent, widgetFrame
    
    local title = Instance.new("TextLabel")
    title.Size, title.Position, title.BackgroundTransparency, title.Text, title.TextColor3, title.TextXAlignment = UDim2.new(1, -10, 1, 0), UDim2.new(0, 10, 0, 0), 1, name:upper(), THEME.Text, Enum.TextXAlignment.Left
    ApplyFont(title, 10)
    AddTextStroke(title)
    title.Parent = topBar
    
    MakeDraggable(widgetFrame, topBar)
    
    local container = Instance.new("Frame")
    container.Size, container.Position, container.BackgroundTransparency, container.Parent = UDim2.new(1, -20, 1, -30), UDim2.new(0, 10, 0, 25), 1, widgetFrame
    
    local widgetObj = {Frame = widgetFrame, Container = container, AccentLine = accentLine, TitleLabel = title}
    function widgetObj:SetVisibility(state) widgetFrame.Visible = state end
    
    table.insert(allWidgets, widgetObj)
    return widgetObj
end

-- =============================================================================
-- [[ РЕАЛИЗАЦИЯ ВСЕХ 12 ВИДЖЕТОВ ]]
-- =============================================================================

function Library:Watermark(options)
    local widget = CreateBaseWidget(options.Name or "Watermark", UDim2.new(0, 240, 0, 32))
    widget.TitleLabel:Destroy()
    widget.Frame.Size, widget.Frame.Position = UDim2.new(0, 240, 0, 26), UDim2.new(0.8, 0, 0.05, 0)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size, textLabel.Position, textLabel.BackgroundTransparency, textLabel.TextColor3, textLabel.TextXAlignment = UDim2.new(1, -20, 1, 0), UDim2.new(0, 10, 0, 0), 1, THEME.Text, Enum.TextXAlignment.Left
    ApplyFont(textLabel, 10)
    AddTextStroke(textLabel)
    textLabel.Parent = widget.Frame
    
    local fps, lastTime = 0, os.clock()
    RunService.RenderStepped:Connect(function()
        local currentTime = os.clock()
        fps = math.floor(1 / (currentTime - lastTime))
        lastTime = currentTime
        textLabel.Text = widget.TextProvider and widget.TextProvider(fps) or string.format("%s | %d FPS", options.Name or "Library", fps)
    end)
    
    function widget:SetDynamicTextProvider(callback) widget.TextProvider = callback end
    return widget
end

function Library:KeybindList(options)
    local widget = CreateBaseWidget(options.Name or "Keybinds", UDim2.new(0, 180, 0, 120))
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding, listLayout.Parent = UDim.new(0, 4), widget.Container
    
    function widget:Add(bindName)
        local itemFrame = Instance.new("Frame")
        itemFrame.Size, itemFrame.BackgroundTransparency, itemFrame.Parent = UDim2.new(1, 0, 0, 14), 1, widget.Container
        
        local labelName = Instance.new("TextLabel")
        labelName.Size, labelName.BackgroundTransparency, labelName.Text, labelName.TextColor3, labelName.TextXAlignment = UDim2.new(0.5, 0, 1, 0), 1, bindName, THEME.TextMuted, Enum.TextXAlignment.Left
        ApplyFont(labelName, 9)
        labelName.Parent = itemFrame
        
        local labelKey = Instance.new("TextLabel")
        labelKey.Size, labelKey.Position, labelKey.BackgroundTransparency, labelKey.Text, labelKey.TextColor3 = UDim2.new(0.2, 0, 1, 0), UDim2.new(0.5, 0, 0, 0), 1, "[None]", THEME.Accent
        ApplyFont(labelKey, 9)
        labelKey.Parent = itemFrame
        table.insert(allKeybinds, labelKey)
        
        local labelStatus = Instance.new("TextLabel")
        labelStatus.Size, labelStatus.Position, labelStatus.BackgroundTransparency, labelStatus.Text, labelStatus.TextColor3, labelStatus.TextXAlignment = UDim2.new(0.3, 0, 1, 0), UDim2.new(0.7, 0, 0, 0), 1, "", THEME.TextMuted, Enum.TextXAlignment.Right
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
    viewport.Size, viewport.BackgroundTransparency, viewport.Parent = UDim2.new(1, 0, 1, 0), 1, widget.Container
    
    local camera = Instance.new("Camera")
    camera.FieldOfView, camera.Parent = 35, viewport
    viewport.CurrentCamera = camera
    camera.CFrame = CFrame.new(Vector3.new(0, 0.3, -6.5), Vector3.new(0, -0.3, 0))
    
    task.spawn(function()
        local successModel, model = pcall(function() return Players:CreateHumanoidModelFromUserId(1) end)
        if successModel and model then
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then part.Anchored, part.CanCollide = true, false end
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
    espBox.Size, espBox.Position, espBox.BackgroundTransparency = UDim2.new(0, 80, 0, 140), UDim2.new(0.5, -40, 0.5, -70), 1
    local stroke = AddStroke(espBox, THEME.Accent, 1)
    espBox.Parent = viewport
    table.insert(allKeybinds, stroke)
    
    local espHealth = Instance.new("Frame")
    espHealth.Size, espHealth.Position, espHealth.BackgroundColor3, espHealth.BorderSizePixel = UDim2.new(0, 2, 0, 140), UDim2.new(0.5, -45, 0.5, -70), Color3.fromRGB(0, 255, 100), 0
    espHealth.Parent = viewport
    
    local espName = Instance.new("TextLabel")
    espName.Size, espName.Position, espName.AnchorPoint, espName.BackgroundTransparency, espName.Text, espName.TextColor3 = UDim2.new(0, 100, 0, 12), UDim2.new(0.5, 0, 0.5, -82), Vector2.new(0.5, 0.5), 1, "PREVIEW", Color3.fromRGB(255, 255, 255)
    ApplyFont(espName, 9)
    AddTextStroke(espName)
    espName.Parent = viewport
    
    function widget:SetText(name) espName.Text = tostring(name):upper() end
    return widget
end

function Library:TargetIndicator()
    local widget = CreateBaseWidget("Target Info", UDim2.new(0, 200, 0, 60))
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size, nameLabel.BackgroundTransparency, nameLabel.Text, nameLabel.TextColor3, nameLabel.TextXAlignment = UDim2.new(1, 0, 0, 12), 1, "Target: sametexe001", THEME.Text, Enum.TextXAlignment.Left
    ApplyFont(nameLabel, 9)
    nameLabel.Parent = widget.Container
    
    local barBg = Instance.new("Frame")
    barBg.Size, barBg.Position, barBg.BackgroundColor3 = UDim2.new(1, 0, 0, 4), UDim2.new(0, 0, 0, 18), Color3.fromRGB(24, 24, 30)
    AddCorner(barBg, 2)
    barBg.Parent = widget.Container
    
    local barFill = Instance.new("Frame")
    barFill.Size, barFill.BackgroundColor3 = UDim2.new(0.74, 0, 1, 0), THEME.Accent
    AddCorner(barFill, 2)
    barFill.Parent = barBg
    table.insert(allSliders, {BarFill = barFill, ValueDisplay = nameLabel})
    return widget
end

function Library:RadarWidget(options)
    local widget = CreateBaseWidget(options.Name or "Radar", UDim2.new(0, 140, 0, 140))
    widget.Frame.Size = UDim2.new(0, 140, 0, 160)
    
    local radarCircle = Instance.new("Frame")
    radarCircle.Size, radarCircle.BackgroundColor3 = UDim2.new(1, 0, 1, 0), Color3.fromRGB(20, 20, 25)
    AddCorner(radarCircle, 70)
    local stroke = AddStroke(radarCircle, THEME.Accent, 1)
    radarCircle.Parent = widget.Container
    table.insert(allKeybinds, stroke)
    
    local centerPoint = Instance.new("Frame")
    centerPoint.Size, centerPoint.Position, centerPoint.BackgroundColor3 = UDim2.new(0, 4, 0, 4), UDim2.new(0.5, -2, 0.5, -2), Color3.fromRGB(255, 255, 255)
    AddCorner(centerPoint, 2)
    centerPoint.Parent = radarCircle
    return widget
end

function Library:ConsoleLogger(options)
    local widget = CreateBaseWidget(options.Name or "Console", UDim2.new(0, 260, 0, 160))
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size, scroll.BackgroundTransparency, scroll.ScrollBarThickness, scroll.CanvasSize, scroll.AutomaticCanvasSize = UDim2.new(1, 0, 1, 0), 1, 2, UDim2.new(0, 0, 0, 0), Enum.AutomaticSize.Y
    scroll.Parent = widget.Container
    
    local layout = Instance.new("UIListLayout")
    layout.Padding, layout.Parent = UDim.new(0, 4), scroll
    
    function widget:AddOutput(text)
        local label = Instance.new("TextLabel")
        label.Size, label.BackgroundTransparency, label.Text, label.TextColor3, label.TextXAlignment = UDim2.new(1, -10, 0, 14), 1, " " .. tostring(text), THEME.TextMuted, Enum.TextXAlignment.Left
        ApplyFont(label, 9)
        label.Parent = scroll
    end
    return widget
end

function Library:ModeratorList(options)
    local widget = CreateBaseWidget(options.Name or "Moderators", UDim2.new(0, 180, 0, 100))
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding, listLayout.Parent = UDim.new(0, 4), widget.Container
    
    function widget:Add(name)
        local label = Instance.new("TextLabel")
        label.Size, label.BackgroundTransparency, label.Text, label.TextColor3, label.TextXAlignment = UDim2.new(1, 0, 0, 14), 1, tostring(name), Color3.fromRGB(255, 100, 100), Enum.TextXAlignment.Left
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
    listLayout.Padding, listLayout.Parent = UDim.new(0, 4), widget.Container
    
    function widget:SetLines(lines)
        widget.Container:ClearAllChildren()
        local l = Instance.new("UIListLayout")
        l.Padding, l.Parent = UDim.new(0, 4), widget.Container
        for _, line in ipairs(lines) do
            local label = Instance.new("TextLabel")
            label.Size, label.BackgroundTransparency, label.Text, label.TextColor3, label.TextXAlignment = UDim2.new(1, 0, 0, 14), 1, tostring(line), THEME.Text, Enum.TextXAlignment.Left
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
    barBg.Size, barBg.Position, barBg.BackgroundColor3 = UDim2.new(1, 0, 0, 4), UDim2.new(0, 0, 0, 10), Color3.fromRGB(24, 24, 30)
    AddCorner(barBg, 2)
    barBg.Parent = widget.Container
    
    local barFill = Instance.new("Frame")
    barFill.Size, barFill.BackgroundColor3 = UDim2.new(0.5, 0, 1, 0), THEME.Accent
    AddCorner(barFill, 2)
    barFill.Parent = barBg
    table.insert(allSliders, {BarFill = barFill, ValueDisplay = barFill})
    return widget
end

function Library:InventoryViewer(options) return CreateBaseWidget(options.Name or "Inventory", UDim2.new(0, 200, 0, 120)) end

function Library:SpotifyPlayer()
    local widget = CreateBaseWidget("Spotify", UDim2.new(0, 220, 0, 65))
    widget.Frame.Size = UDim2.new(0, 220, 0, 75)
    
    local songLabel = Instance.new("TextLabel")
    songLabel.Size, songLabel.BackgroundTransparency, songLabel.Text, songLabel.TextColor3, songLabel.TextXAlignment = UDim2.new(1, 0, 0, 12), 1, "Blinding Lights", THEME.Text, Enum.TextXAlignment.Left
    ApplyFont(songLabel, 10)
    songLabel.Parent = widget.Container
    
    local artistLabel = Instance.new("TextLabel")
    artistLabel.Size, artistLabel.Position, artistLabel.BackgroundTransparency, artistLabel.Text, artistLabel.TextColor3, artistLabel.TextXAlignment = UDim2.new(1, 0, 0, 12), UDim2.new(0, 0, 0, 14), 1, "The Weeknd", THEME.TextMuted, Enum.TextXAlignment.Left
    ApplyFont(artistLabel, 9)
    artistLabel.Parent = widget.Container
    return widget
end

function Library:Playerlist(options) return CreateBaseWidget(options.Name or "Players", UDim2.new(0, 180, 0, 120)) end

-- =============================================================================
-- [[ КОНСТРУКТОР ГЛАВНОГО ОКНА И СОВМЕСТИМОСТЬ ]]
-- =============================================================================

local Perplexity = {}
Perplexity.__index = Perplexity

function Perplexity.new(options)
    options = options or {}
    local self = setmetatable({}, Perplexity)
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 840, 0, 560)
    self.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.BackgroundTransparency = 1
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = ScreenGui
    
    local BgFrame = Instance.new("Frame")
    BgFrame.Size = UDim2.new(1, 0, 1, 0)
    BgFrame.BackgroundColor3 = THEME.Background
    BgFrame.ZIndex = 0
    AddCorner(BgFrame, 6)
    AddDoubleStroke(BgFrame)
    BgFrame.Parent = self.MainFrame
    
    SetupMenuBackgroundParticles(self.MainFrame)
    
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 180, 1, -20)
    Sidebar.Position = UDim2.new(0, 10, 0, 10)
    Sidebar.BackgroundColor3 = THEME.SidebarBg
    Sidebar.BackgroundTransparency = 0.12
    Sidebar.ZIndex = 2
    AddCorner(Sidebar, 4)
    AddDoubleStroke(Sidebar)
    Sidebar.Parent = self.MainFrame
    
    local LogoContainer = Instance.new("Frame")
    LogoContainer.Size = UDim2.new(1, 0, 0, 50)
    LogoContainer.BackgroundTransparency = 1
    LogoContainer.ZIndex = 3
    LogoContainer.Parent = Sidebar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -20, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = (options.Title or "PERPLEXITY"):upper() .. " <font color='rgb(255,255,255)'>.WIN</font>"
    TitleText.RichText = true
    TitleText.TextColor3 = THEME.Accent
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 14
    TitleText.ZIndex = 3
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    AddTextStroke(TitleText)
    ApplyFont(TitleText, 14)
    TitleText.Parent = LogoContainer
    TitleTextLabel = TitleText
    
    MakeDraggable(self.MainFrame, Sidebar)
    MakeDraggable(self.MainFrame, LogoContainer)
    
    local SearchFrame = Instance.new("Frame")
    SearchFrame.Size = UDim2.new(1, -20, 0, 24)
    SearchFrame.Position = UDim2.new(0, 10, 0, 50)
    SearchFrame.BackgroundColor3 = THEME.Background
    SearchFrame.ZIndex = 3
    AddCorner(SearchFrame, 4)
    AddDoubleStroke(SearchFrame)
    SearchFrame.Parent = Sidebar
    
    self.SearchInput = Instance.new("TextBox")
    self.SearchInput.Size = UDim2.new(1, -10, 1, 0)
    self.SearchInput.Position = UDim2.new(0, 5, 0, 0)
    self.SearchInput.BackgroundTransparency = 1
    self.SearchInput.Text = ""
    self.SearchInput.PlaceholderText = "Search features..."
    self.SearchInput.PlaceholderColor3 = THEME.TextMuted
    self.SearchInput.TextColor3 = THEME.Text
    self.SearchInput.Font = Enum.Font.GothamMedium
    self.SearchInput.TextSize = 10
    self.SearchInput.ZIndex = 3
    self.SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    AddTextStroke(self.SearchInput)
    ApplyFont(self.SearchInput, 10)
    self.SearchInput.Parent = SearchFrame
    
    self.TabButtonContainer = Instance.new("ScrollingFrame")
    self.TabButtonContainer.Size = UDim2.new(1, -10, 1, -115)
    self.TabButtonContainer.Position = UDim2.new(0, 5, 0, 100)
    self.TabButtonContainer.BackgroundTransparency = 1
    self.TabButtonContainer.ScrollBarThickness = 0
    self.TabButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.TabButtonContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.TabButtonContainer.ZIndex = 3
    self.TabButtonContainer.Parent = Sidebar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Vertical
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = self.TabButtonContainer
    
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Size = UDim2.new(1, -210, 1, -20)
    self.ContentArea.Position = UDim2.new(0, 200, 0, 10)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.ZIndex = 2
    self.ContentArea.Parent = self.MainFrame
    
    self.Tabs = {}
    self.ActiveTab = nil
    
    self.SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        if self.ActiveTab then
            local query = self.SearchInput.Text:lower()
            for _, section in ipairs(self.ActiveTab.Sections) do
                local visibleElements = 0
                for _, el in ipairs(section.Elements) do
                    if query == "" or el.Name:lower():find(query, 1, true) then
                        el.Frame.Visible = true
                        visibleElements = visibleElements + 1
                    else
                        el.Frame.Visible = false
                    end
                end
                section.Frame.Visible = (visibleElements > 0)
            end
        end
    end)
    
    self.SettingsTab = self:CreateTab("Settings")
    self.MenuControlSec = self.SettingsTab:CreateSection("Menu Control", 1)
    self.WidgetTogglesSec = self.SettingsTab:CreateSection("Widget Toggles", 1)
    self.ConfigsSec = self.SettingsTab:CreateSection("Configurations", 2)
    self.ThemesSec = self.SettingsTab:CreateSection("Theme Selection", 2)
    self.EffectsSec = self.SettingsTab:CreateSection("Background Effects", 3)
    
    self.MenuControlSec:CreateKeybind("Hide / Show Key", "RightShift", function(key)
        Notify("Интерфейс", "Клавиша скрытия изменена на: " .. key.Name)
    end)
    
    local ConfigNameBox = self.ConfigsSec:CreateDropdown("Select Slot", {"Config 1", "Config 2", "Config 3"}, "Config 1", function() end)
    self.ConfigsSec:CreateButton("Load Config", function() LoadConfig(ConfigNameBox.Selected) end)
    self.ConfigsSec:CreateButton("Save Config", function() SaveConfig(ConfigNameBox.Selected) end)
    self.ConfigsSec:CreateButton("Delete Config", function()
        pcall(function()
            local path = "perplexity/Configs/" .. ConfigNameBox.Selected .. ".json"
            if isfile(path) then
                delfile(path)
                Notify("Configs", "Файл удален: " .. ConfigNameBox.Selected, 3)
            else
                Notify("Configs", "Файл конфигурации не найден.", 4)
            end
        end)
    end)
    
    self.ThemesSec:CreateDropdown("Select Theme", {"Vibrant Red", "Perplexity Pink", "Dark Knight Blue", "Toxic Green"}, "Vibrant Red", function(themeName)
        if themeName == "Vibrant Red" then
            UpdateBackgroundTheme(Color3.fromRGB(255, 30, 60), {Color3.fromRGB(255, 30, 60), Color3.fromRGB(100, 10, 25), Color3.fromRGB(25, 25, 30)})
        elseif themeName == "Perplexity Pink" then
            UpdateBackgroundTheme(Color3.fromRGB(255, 60, 105), {Color3.fromRGB(255, 60, 105), Color3.fromRGB(180, 30, 80), Color3.fromRGB(240, 240, 255)})
        elseif themeName == "Dark Knight Blue" then
            UpdateBackgroundTheme(Color3.fromRGB(0, 150, 255), {Color3.fromRGB(0, 150, 255), Color3.fromRGB(0, 50, 120), Color3.fromRGB(20, 20, 25)})
        elseif themeName == "Toxic Green" then
            UpdateBackgroundTheme(Color3.fromRGB(50, 255, 100), {Color3.fromRGB(50, 255, 100), Color3.fromRGB(10, 80, 30), Color3.fromRGB(20, 20, 25)})
        end
    end)
    
    self.EffectsSec:CreateCheckbox("Background Snow", true, function(state)
        optSnowEnabled = state
        for _, p in ipairs(allParticles) do p.Obj.Visible = state end
    end)
    self.EffectsSec:CreateCheckbox("Screen Blur Effect", true, function(state)
        optBlurEnabled = state
        if MenuBlur then MenuBlur.Enabled = state and menuVisible end
    end)
    
    return self
end

function Perplexity:CreateTab(name)
    local tab = {Name = name, Sections = {}}
    
    tab.Button = Instance.new("TextButton")
    tab.Button.Size, tab.Button.BackgroundTransparency, tab.Button.Text, tab.Button.TextColor3, tab.Button.Font, tab.Button.TextSize, tab.Button.TextXAlignment, tab.Button.AutoButtonColor, tab.Button.ZIndex = UDim2.new(1, -10, 0, 34), 1, "     " .. name, THEME.TextMuted, Enum.Font.GothamMedium, 12, Enum.TextXAlignment.Left, false, 3
    AddTextStroke(tab.Button)
    ApplyFont(tab.Button, 12)
    tab.Button.Parent = self.TabButtonContainer
    AddCorner(tab.Button, 4)
    
    local hoverBg = Instance.new("Frame")
    hoverBg.Size, hoverBg.BackgroundColor3, hoverBg.BackgroundTransparency, hoverBg.ZIndex = UDim2.new(1, 0, 1, 0), Color3.fromRGB(255, 255, 255), 1, 0
    AddCorner(hoverBg, 4)
    hoverBg.Parent = tab.Button
    
    local indicator = Instance.new("Frame")
    indicator.Size, indicator.Position, indicator.BackgroundColor3, indicator.BackgroundTransparency, indicator.Visible = UDim2.new(0, 0, 0.4, 0), UDim2.new(0, 6, 0.3, 0), THEME.Accent, 1, false
    indicator.Parent = tab.Button
    
    tab.Frame = Instance.new("Frame")
    tab.Frame.Size, tab.Frame.BackgroundTransparency, tab.Frame.Visible, tab.Frame.ZIndex, tab.Frame.Parent = UDim2.new(1, 0, 1, 0), 1, false, 2, self.TabContentContainer or self.ContentArea
    
    tab.Columns = {}
    for i = 1, 3 do
        local col = Instance.new("ScrollingFrame")
        col.Size, col.Position, col.BackgroundTransparency, col.ScrollBarThickness, col.ZIndex, col.CanvasSize, col.AutomaticCanvasSize = UDim2.new(0.315, 0, 1, 0), UDim2.new((i - 1) * 0.34, 0, 0, 0), 1, 0, 2, UDim2.new(0, 0, 0, 0), Enum.AutomaticSize.Y
        col.Parent = tab.Frame
        
        local colList = Instance.new("UIListLayout")
        colList.Padding, colList.Parent = UDim.new(0, 12), col
        tab.Columns[i] = col
    end
    
    tab.Indicator = indicator
    table.insert(allTabs, tab)
    
    tab.SetTabState = function(active)
        if active then
            indicator.Visible = true
            Tween(tab.Button, 0.2, {TextColor3 = THEME.Accent})
            Tween(indicator, 0.2, {Size = UDim2.new(0, 3, 0.4, 0), BackgroundTransparency = 0})
            Tween(hoverBg, 0.2, {BackgroundTransparency = 0.95})
        else
            Tween(tab.Button, 0.2, {TextColor3 = THEME.TextMuted})
            local t = Tween(indicator, 0.2, {Size = UDim2.new(0, 0, 0.4, 0), BackgroundTransparency = 1})
            t.Completed:Connect(function() if self.ActiveTab ~= tab then indicator.Visible = false end end)
            Tween(hoverBg, 0.2, {BackgroundTransparency = 1})
        end
    end
    
    tab.Button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then Tween(tab.Button, 0.1, {TextColor3 = THEME.Text}); Tween(hoverBg, 0.1, {BackgroundTransparency = 0.97}) end
    end)
    tab.Button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then Tween(tab.Button, 0.1, {TextColor3 = THEME.TextMuted}); Tween(hoverBg, 0.1, {BackgroundTransparency = 1}) end
    end)
    
    tab.Button.MouseButton1Click:Connect(function()
        if self.ActiveTab == tab then return end
        local prevTab = self.ActiveTab
        self.ActiveTab = tab
        if prevTab then prevTab.SetTabState(false); prevTab.Frame.Visible = false end
        self.SearchInput.Text = ""
        tab.Frame.Visible = true
        tab.SetTabState(true)
        tab.Frame.Position = UDim2.new(0, 0, 0, 8)
        Tween(tab.Frame, 0.15, {Position = UDim2.new(0, 0, 0, 0)})
    end)
    
    if not self.ActiveTab then
        tab.SetTabState(true)
        tab.Frame.Visible = true
        self.ActiveTab = tab
    end
    
    tab.SubPage = function(self, sOptions)
        local subPage = {}
        function subPage:Section(secOptions)
            secOptions = secOptions or {}
            local colIndex = secOptions.Side or 1
            return tab:CreateSection(secOptions.Name or "Section", colIndex)
        end
        return subPage
    end
    
    function tab:CreateSection(title, columnIndex)
        local targetColIndex = (columnIndex == 3) and 3 or ((columnIndex == 2) and 2 or 1)
        local col = tab.Columns[targetColIndex]
        local section = {Elements = {}, SubTabs = {}, ActiveSubTab = nil}
        
        section.Frame = Instance.new("Frame")
        section.Frame.Size, section.Frame.AutomaticSize, section.Frame.BackgroundColor3, section.Frame.BackgroundTransparency, section.Frame.ZIndex = UDim2.new(1, 0, 0, 30), Enum.AutomaticSize.Y, THEME.SectionBg, 0.12, 2
        AddCorner(section.Frame, 6)
        AddDoubleStroke(section.Frame)
        section.Frame.Parent = col
        
        local secLayout = Instance.new("UIListLayout")
        secLayout.Padding, secLayout.Parent = UDim.new(0, 10), section.Frame
        
        local padding = Instance.new("UIPadding")
        padding.PaddingTop, padding.PaddingBottom, padding.PaddingLeft, padding.PaddingRight, padding.Parent = UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 14), UDim.new(0, 14), section.Frame
        
        section.TitleLabel = Instance.new("TextLabel")
        section.TitleLabel.Size, section.TitleLabel.BackgroundTransparency, section.TitleLabel.Text, section.TitleLabel.TextColor3, section.TitleLabel.Font, section.TitleLabel.TextSize, section.TitleLabel.TextXAlignment, section.TitleLabel.LayoutOrder, section.TitleLabel.ZIndex = UDim2.new(1, 0, 0, 16), 1, title:upper(), THEME.Accent, Enum.Font.GothamBold, 10, Enum.TextXAlignment.Left, 9999, 2
        AddTextStroke(section.TitleLabel)
        ApplyFont(section.TitleLabel, 10)
        section.TitleLabel.Parent = section.Frame
        table.insert(allSectionTitles, section.TitleLabel)
        
        function section:CreateSubTab(name)
            local subTab = {Name = name, Container = nil, Button = nil, Underline = nil}
            if not section.SubTabsHeader then
                section.SubTabsHeader = Instance.new("Frame")
                section.SubTabsHeader.Size, section.SubTabsHeader.BackgroundTransparency, section.SubTabsHeader.ZIndex, section.SubTabsHeader.LayoutOrder, section.SubTabsHeader.Parent = UDim2.new(1, 0, 0, 20), 1, 2, -1, section.Frame
                local headerLayout = Instance.new("UIListLayout")
                headerLayout.FillDirection, headerLayout.Padding, headerLayout.Parent = Enum.FillDirection.Horizontal, UDim.new(0, 12), section.SubTabsHeader
            end
            
            subTab.Button = Instance.new("TextButton")
            subTab.Button.Size, subTab.Button.AutomaticSize, subTab.Button.BackgroundTransparency, subTab.Button.Text, subTab.Button.TextColor3, subTab.Button.Font, subTab.Button.TextSize, subTab.Button.ZIndex, subTab.Button.Parent = UDim2.new(0, 0, 1, 0), Enum.AutomaticSize.X, 1, name, THEME.TextMuted, Enum.Font.GothamMedium, 10, 3, section.SubTabsHeader
            AddTextStroke(subTab.Button)
            
            subTab.Underline = Instance.new("Frame")
            subTab.Underline.Size, subTab.Underline.Position, subTab.Underline.BackgroundColor3, subTab.Underline.Visible, subTab.Underline.ZIndex, subTab.Underline.Parent = UDim2.new(1, 0, 0, 1.5), UDim2.new(0, 0, 1, -1), THEME.Accent, false, 3, subTab.Button
            
            subTab.Container = Instance.new("Frame")
            subTab.Container.Size, subTab.Container.AutomaticSize, subTab.Container.BackgroundTransparency, subTab.Container.Visible, subTab.Container.ZIndex, subTab.Container.Parent = UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y, 1, false, 2, section.Frame
            local containerLayout = Instance.new("UIListLayout")
            containerLayout.Padding, containerLayout.Parent = UDim.new(0, 10), subTab.Container
            
            subTab.Button.MouseButton1Click:Connect(function()
                if section.ActiveSubTab == subTab then return end
                if section.ActiveSubTab then
                    section.ActiveSubTab.Container.Visible, section.ActiveSubTab.Underline.Visible, section.ActiveSubTab.Button.TextColor3 = false, false, THEME.TextMuted
                end
                section.ActiveSubTab = subTab
                subTab.Container.Visible, subTab.Underline.Visible, subTab.Button.TextColor3 = true, true, THEME.Text
            end)
            
            if not section.ActiveSubTab then
                section.ActiveSubTab = subTab
                subTab.Container.Visible, subTab.Underline.Visible, subTab.Button.TextColor3 = true, true, THEME.Text
            end
            
            function subTab:CreateCheckbox(n, d, c) return section:CreateCheckboxInternal(n, d, c, subTab.Container) end
            function subTab:CreateSlider(n, mi, ma, d, c) return section:CreateSliderInternal(n, mi, ma, d, c, subTab.Container) end
            function subTab:CreateDropdown(n, l, d, c) return section:CreateDropdownInternal(n, l, d, c, subTab.Container) end
            function subTab:CreateKeybind(n, d, c) return section:CreateKeybindInternal(n, d, c, subTab.Container) end
            function subTab:CreateButton(n, c) return section:CreateButtonInternal(n, c, subTab.Container) end
            
            subTab.Toggle = function(_, o) return subTab:CreateCheckbox(o.Name, o.Default, o.Callback) end
            subTab.Slider = function(_, o) return subTab:CreateSlider(o.Name, o.Min, o.Max, o.Default, o.Callback) end
            subTab.Dropdown = function(_, o) return subTab:CreateDropdown(o.Name, o.List, o.Default, o.Callback) end
            subTab.Keybind = function(_, o) return subTab:CreateKeybind(o.Name, o.Default, o.Callback) end
            
            table.insert(allSubTabs, subTab)
            return subTab
        end
        
        function section:CreateButtonInternal(name, callback, parent)
            parent = parent or section.Frame
            local btnFrame = Instance.new("Frame")
            btnFrame.Size, btnFrame.BackgroundTransparency, btnFrame.ZIndex, btnFrame.Parent = UDim2.new(1, 0, 0, 24), 1, 2, parent
            
            local btn = Instance.new("TextButton")
            btn.Size, btn.BackgroundColor3, btn.Text, btn.TextColor3, btn.Font, btn.TextSize, btn.AutoButtonColor, btn.ZIndex = UDim2.new(1, 0, 1, 0), Color3.fromRGB(28, 28, 36), name, THEME.Text, Enum.Font.GothamMedium, 11, false, 2
            AddCorner(btn, 4)
            local btnStroke = AddStroke(btn, THEME.Border, 1)
            btn.Parent = btnFrame
            
            btn.MouseEnter:Connect(function() Tween(btnStroke, 0.1, {Color = THEME.Accent}) end)
            btn.MouseLeave:Connect(function() Tween(btnStroke, 0.1, {Color = THEME.Border}) end)
            btn.MouseButton1Click:Connect(function()
                Tween(btn, 0.05, {BackgroundColor3 = THEME.Accent})
                task.delay(0.05, function() Tween(btn, 0.1, {BackgroundColor3 = Color3.fromRGB(28, 28, 36)}) end)
                task.spawn(function() pcall(callback) end)
            end)
            table.insert(section.Elements, {Name = name, Frame = btnFrame})
            return btn
        end
        function section:CreateButton(name, callback) return section:CreateButtonInternal(name, callback, section.Frame) end
        
        function section:CreateCheckboxInternal(name, default, callback, parent)
            parent = parent or section.Frame
            local checkbox = {State = default or false}
            local boxFrame = Instance.new("Frame")
            boxFrame.Size, boxFrame.BackgroundTransparency, boxFrame.ZIndex, boxFrame.Parent = UDim2.new(1, 0, 0, 20), 1, 2, parent
            
            local clickContainer = Instance.new("TextButton")
            clickContainer.Size, clickContainer.BackgroundTransparency, clickContainer.Text, clickContainer.Active, clickContainer.AutoButtonColor, clickContainer.ZIndex, clickContainer.Parent = UDim2.new(1, -130, 1, 0), 1, "", true, false, 2, boxFrame
            
            local indicator = Instance.new("Frame")
            indicator.Size, indicator.Position, indicator.BackgroundColor3, indicator.ZIndex = UDim2.new(0, 14, 0, 14), UDim2.new(0, 0, 0.5, -7), checkbox.State and THEME.Accent or Color3.fromRGB(28, 28, 36), 2
            AddCorner(indicator, 2)
            local indStroke = AddStroke(indicator, THEME.Border, 1)
            indicator.Parent = clickContainer
            
            local dot = Instance.new("ImageLabel")
            dot.AnchorPoint, dot.Position, dot.Size, dot.Image, dot.ImageColor3, dot.ScaleType, dot.BackgroundTransparency, dot.ImageTransparency, dot.ZIndex, dot.Parent = Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0), checkbox.State and UDim2.new(1, -2, 1, -2) or UDim2.new(0, 0, 0, 0), "rbxassetid://3944680095", Color3.fromRGB(255, 255, 255), Enum.ScaleType.Fit, 1, checkbox.State and 0 or 1, 3, indicator
            
            local label = Instance.new("TextLabel")
            label.Size, label.Position, label.BackgroundTransparency, label.Text, label.TextColor3, label.Font, label.TextSize, label.TextXAlignment, label.ZIndex = UDim2.new(1, -22, 1, 0), UDim2.new(0, 22, 0, 0), 1, name, checkbox.State and THEME.Text or THEME.TextMuted, Enum.Font.GothamMedium, 11, Enum.TextXAlignment.Left, 2
            AddTextStroke(label)
            ApplyFont(label, 11)
            label.Parent = boxFrame
            
            local subElements = Instance.new("Frame")
            subElements.Size, subElements.Position, subElements.BackgroundTransparency, subElements.ZIndex, subElements.Parent = UDim2.new(0, 120, 1, 0), UDim2.new(1, -120, 0, 0), 1, 4, boxFrame
            local subLayout = Instance.new("UIListLayout")
            subLayout.FillDirection, subLayout.HorizontalAlignment, subLayout.VerticalAlignment, subLayout.Padding, subLayout.Parent = Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center, UDim.new(0, 6), subElements
            
            local function update()
                if checkbox.State then
                    Tween(indicator, 0.15, {BackgroundColor3 = THEME.Accent})
                    Tween(dot, 0.15, {Size = UDim2.new(1, -2, 1, -2), ImageTransparency = 0})
                    Tween(label, 0.15, {TextColor3 = THEME.Text})
                else
                    Tween(indicator, 0.15, {BackgroundColor3 = Color3.fromRGB(28, 28, 36)})
                    Tween(dot, 0.15, {Size = UDim2.new(0, 0, 0, 0), ImageTransparency = 1})
                    Tween(label, 0.15, {TextColor3 = THEME.TextMuted})
                end
                SaveFlags[name] = checkbox.State
                task.spawn(function() pcall(callback, checkbox.State) end)
            end
            
            clickContainer.MouseEnter:Connect(function() Tween(indStroke, 0.1, {Color = THEME.Accent}) end)
            clickContainer.MouseLeave:Connect(function() Tween(indStroke, 0.1, {Color = THEME.Border}) end)
            clickContainer.MouseButton1Click:Connect(function() checkbox.State = not checkbox.State; update() end)
            
            function checkbox:CreateKeybind(default, cb)
                local kb = {Key = default or "None", Binding = false}
                local bindBtn = Instance.new("TextButton")
                bindBtn.Size, bindBtn.BackgroundColor3, bindBtn.Text, bindBtn.TextColor3, bindBtn.Font, bindBtn.TextSize, bindBtn.AutoButtonColor, bindBtn.TextXAlignment, bindBtn.ZIndex = UDim2.new(0, 42, 0, 14), Color3.fromRGB(24, 24, 30), tostring(kb.Key), THEME.Accent, Enum.Font.GothamBold, 9, false, Enum.TextXAlignment.Center, 4
                AddCorner(bindBtn, 2)
                local kbStroke = AddStroke(bindBtn, THEME.Border, 1)
                bindBtn.Parent = subElements
                table.insert(allKeybinds, bindBtn)
                
                local function setKey(keyName) kb.Key = tostring(keyName); bindBtn.Text = kb.Key; SaveFlags[name .. "_key"] = kb.Key end
                
                bindBtn.MouseButton1Click:Connect(function()
                    if kb.Binding then return end
                    kb.Binding = true; bindBtn.Text = "..."; Tween(kbStroke, 0.1, {Color = THEME.Accent})
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(inKey)
                        if inKey.UserInputType == Enum.UserInputType.Keyboard then
                            setKey(inKey.KeyCode.Name); kb.Binding = false; Tween(kbStroke, 0.1, {Color = THEME.Border})
                            task.spawn(function() pcall(cb, inKey.KeyCode) end)
                            conn:Disconnect()
                        elseif inKey.UserInputType == Enum.UserInputType.MouseButton1 or inKey.UserInputType == Enum.UserInputType.MouseButton2 then
                            setKey(inKey.UserInputType.Name == "MouseButton1" and "MB1" or "MB2"); kb.Binding = false; Tween(kbStroke, 0.1, {Color = THEME.Border})
                            task.spawn(function() pcall(cb, inKey.UserInputType) end)
                            conn:Disconnect()
                        end
                    end)
                end)
                
                Flags[name .. "_key"] = {Set = function(val) setKey(val) end, Get = function() return kb.Key end}
                SaveFlags[name .. "_key"] = kb.Key
                return kb
            end
            
            function checkbox:CreateColorpicker(default, cb)
                local cp = {Value = default or Color3.fromRGB(255, 255, 255)}
                local cpBtn = Instance.new("TextButton")
                cpBtn.Size, cpBtn.BackgroundColor3, cpBtn.Text, cpBtn.AutoButtonColor, cpBtn.ZIndex = UDim2.new(0, 24, 0, 12), cp.Value, "", false, 4
                AddCorner(cpBtn, 3)
                AddStroke(cpBtn, THEME.Border, 1)
                cpBtn.Parent = subElements
                
                local function setColor(colorValue) cp.Value = colorValue; cpBtn.BackgroundColor3 = colorValue; SaveFlags[name .. "_color"] = colorValue:ToHex() end
                
                cpBtn.MouseButton1Click:Connect(function()
                    openedThisFrame = true
                    activeColorpicker = {H = 0, S = 1, V = 1, Button = cpBtn, Callback = cb}
                    local h, s, v = cp.Value:ToHSV()
                    activeColorpicker.H, activeColorpicker.S, activeColorpicker.V = h, s, v
                    ColorpickerWindow.Position, ColorpickerWindow.Visible = UDim2.new(0, cpBtn.AbsolutePosition.X - 150, 0, cpBtn.AbsolutePosition.Y), true
                    svGrid.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    svKnob.Position = UDim2.new(s, 0, 1 - v, 0)
                    hueKnob.Position = UDim2.new(0.5, 0, h, 0)
                    hexLabel.Text = "HEX: #" .. cp.Value:ToHex():upper()
                    task.wait()
                    openedThisFrame = false
                end)
                
                Flags[name .. "_color"] = {Set = function(val) setColor(Color3.fromHex(val)) end, Get = function() return cp.Value:ToHex() end}
                SaveFlags[name .. "_color"] = cp.Value:ToHex()
                return cp
            end
            
            Flags[name] = {Set = function(val) checkbox.State = val; update() end, Get = function() return checkbox.State end}
            table.insert(allCheckboxes, {Indicator = indicator, Label = label, CheckboxObj = checkbox})
            SaveFlags[name] = checkbox.State
            table.insert(section.Elements, {Name = name, Frame = boxFrame})
            return checkbox
        end
        function section:CreateCheckbox(name, default, callback) return section:CreateCheckboxInternal(name, default, callback, section.Frame) end
        
        function section:CreateSliderInternal(name, min, max, default, callback, parent)
            parent = parent or section.Frame
            local slider = {Value = default or min}
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size, sliderFrame.BackgroundTransparency, sliderFrame.ZIndex, sliderFrame.Parent = UDim2.new(1, 0, 0, 38), 1, 2, parent
            
            local title = Instance.new("TextLabel")
            title.Size, title.Position, title.BackgroundTransparency, title.Text, title.TextColor3, title.TextXAlignment, title.ZIndex = UDim2.new(1, 0, 0, 15), UDim2.new(0, 0, 0, 0), 1, name, THEME.TextMuted, Enum.TextXAlignment.Left, 2
            AddTextStroke(title)
            ApplyFont(title, 10)
            title.Parent = sliderFrame
            
            local valueDisplay = Instance.new("TextLabel")
            valueDisplay.Size, valueDisplay.Position, valueDisplay.BackgroundTransparency, valueDisplay.Text, valueDisplay.TextColor3, valueDisplay.TextXAlignment, valueDisplay.ZIndex = UDim2.new(1, 0, 0, 15), UDim2.new(0, 0, 0, 0), 1, tostring(slider.Value), THEME.Accent, Enum.TextXAlignment.Right, 2
            AddTextStroke(valueDisplay)
            ApplyFont(valueDisplay, 10)
            valueDisplay.Parent = sliderFrame
            
            local barBg = Instance.new("Frame")
            barBg.Size, barBg.Position, barBg.BackgroundColor3, barBg.ZIndex = UDim2.new(1, 0, 0, 4), UDim2.new(0, 0, 0, 24), Color3.fromRGB(24, 24, 30), 2
            AddCorner(barBg, 2)
            barBg.Parent = sliderFrame
            
            local barFill = Instance.new("Frame")
            local initPct = (slider.Value - min) / (max - min)
            barFill.Size, barFill.BackgroundColor3, barFill.ZIndex = UDim2.new(initPct, 0, 1, 0), THEME.Accent, 2
            AddCorner(barFill, 2)
            barFill.Parent = barBg
            
            local knob = Instance.new("Frame")
            knob.AnchorPoint, knob.Size, knob.Position, knob.BackgroundColor3, knob.ZIndex = Vector2.new(0.5, 0.5), UDim2.new(0, 10, 0, 10), UDim2.new(initPct, 0, 0.5, 0), Color3.fromRGB(255, 255, 255), 3
            AddCorner(knob, 5)
            knob.Parent = barBg
            
            local dragging = false
            local function updateSlider(val)
                slider.Value = math.clamp(val, min, max)
                valueDisplay.Text = tostring(slider.Value)
                local relativeX = (slider.Value - min) / (max - min)
                barFill.Size = UDim2.new(relativeX, 0, 1, 0)
                knob.Position = UDim2.new(relativeX, 0, 0.5, 0)
                SaveFlags[name] = slider.Value
                task.spawn(function() pcall(callback, slider.Value) end)
            end
            
            sliderFrame.Active = true
            sliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; local relativeX = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                    updateSlider(math.floor(min + (max - min) * relativeX))
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local relativeX = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                    updateSlider(math.floor(min + (max - min) * relativeX))
                end
            end)
            
            Flags[name] = {Set = function(val) updateSlider(val) end, Get = function() return slider.Value end}
            table.insert(allSliders, {BarFill = barFill, ValueDisplay = valueDisplay})
            SaveFlags[name] = slider.Value
            table.insert(section.Elements, {Name = name, Frame = sliderFrame})
            return slider
        end
        function section:CreateSlider(name, min, max, default, callback) return section:CreateSliderInternal(name, min, max, default, callback, section.Frame) end
        
        function section:CreateDropdownInternal(name, list, default, callback, parent)
            parent = parent or section.Frame
            local dropdown = {Selected = default or list[1], Open = false}
            local dropFrame = Instance.new("Frame")
            dropFrame.Size, dropFrame.BackgroundTransparency, dropFrame.ZIndex, dropFrame.Parent = UDim2.new(1, 0, 0, 40), 1, 2, parent
            
            local title = Instance.new("TextLabel")
            title.Size, title.BackgroundTransparency, title.Text, title.TextColor3, title.TextXAlignment, title.ZIndex = UDim2.new(1, 0, 0, 15), 1, name, THEME.TextMuted, Enum.TextXAlignment.Left, 2
            AddTextStroke(title)
            ApplyFont(title, 10)
            title.Parent = dropFrame
            
            local btn = Instance.new("TextButton")
            btn.Size, btn.Position, btn.BackgroundColor3, btn.Text, btn.TextColor3, btn.Font, btn.TextSize, btn.AutoButtonColor, btn.TextXAlignment, btn.ZIndex = UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 18), Color3.fromRGB(28, 28, 36), "  " .. dropdown.Selected, THEME.Text, Enum.Font.GothamMedium, 10, false, Enum.TextXAlignment.Left, 2
            AddCorner(btn, 4)
            local btnStroke = AddStroke(btn, THEME.Border, 1)
            btn.Parent = dropFrame
            
            local arrow = Instance.new("TextLabel")
            arrow.AnchorPoint, arrow.Size, arrow.Position, arrow.BackgroundTransparency, arrow.Text, arrow.TextColor3, arrow.Font, arrow.TextSize, arrow.ZIndex = Vector2.new(0.5, 0.5), UDim2.new(0, 14, 0, 14), UDim2.new(1, -12, 0.5, 0), 1, "+", THEME.Accent, Enum.Font.GothamBold, 12, 2
            arrow.Parent = btn
            table.insert(allDropdownArrows, arrow)
            
            local container = Instance.new("Frame")
            container.Size, container.Position, container.BackgroundColor3, container.ZIndex, container.ClipsDescendants, container.Visible = UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 1, 2), Color3.fromRGB(24, 24, 30), 50, true, false
            AddCorner(container, 4)
            AddStroke(container, THEME.Border, 1)
            container.Parent = btn
            local dropLayout = Instance.new("UIListLayout")
            dropLayout.Parent = container
            local targetHeight = #list * 18
            
            local function selectValue(item)
                dropdown.Selected = item; btn.Text = "  " .. item; SaveFlags[name] = item
                task.spawn(function() pcall(callback, item) end)
            end
            
            for _, item in ipairs(list) do
                local itemBtn = Instance.new("TextButton")
                itemBtn.Size, itemBtn.BackgroundTransparency, itemBtn.Text, itemBtn.TextColor3, itemBtn.Font, itemBtn.TextSize, itemBtn.AutoButtonColor, itemBtn.TextXAlignment, itemBtn.ZIndex = UDim2.new(1, 0, 0, 18), 1, "  " .. item, THEME.TextMuted, Enum.Font.Gotham, 10, false, Enum.TextXAlignment.Left, 51
                ApplyFont(itemBtn, 10)
                itemBtn.Parent = container
                itemBtn.MouseEnter:Connect(function() Tween(itemBtn, 0.1, {TextColor3 = THEME.Text}) end)
                itemBtn.MouseLeave:Connect(function() Tween(itemBtn, 0.1, {TextColor3 = THEME.TextMuted}) end)
                itemBtn.MouseButton1Click:Connect(function()
                    selectValue(item); dropdown.Open = false; Tween(container, 0.15, {Size = UDim2.new(1, 0, 0, 0)}); Tween(arrow, 0.15, {Rotation = 0})
                    task.delay(0.15, function() container.Visible = false end)
                end)
            end
            
            btn.MouseButton1Click:Connect(function()
                dropdown.Open = not dropdown.Open
                if dropdown.Open then
                    container.Visible = true; Tween(container, 0.2, {Size = UDim2.new(1, 0, 0, targetHeight)}); Tween(arrow, 0.2, {Rotation = 45})
                else
                    local t = Tween(container, 0.15, {Size = UDim2.new(1, 0, 0, 0)}); Tween(arrow, 0.15, {Rotation = 0})
                    local conn; conn = t.Completed:Connect(function() if not dropdown.Open then container.Visible = false end; conn:Disconnect() end)
                end
            end)
            
            btn.MouseEnter:Connect(function() Tween(btnStroke, 0.1, {Color = THEME.Accent}) end)
            btn.MouseLeave:Connect(function() Tween(btnStroke, 0.1, {Color = THEME.Border}) end)
            
            Flags[name] = {Set = function(val) selectValue(val) end, Get = function() return dropdown.Selected end}
            SaveFlags[name] = dropdown.Selected
            table.insert(section.Elements, {Name = name, Frame = dropFrame})
            return dropdown
        end
        function section:CreateDropdown(name, list, default, callback) return section:CreateDropdownInternal(name, list, default, callback, section.Frame) end
        
        function section:CreateKeybindInternal(name, default, callback, parent)
            parent = parent or section.Frame
            local keybind = {Key = default or "None", Binding = false}
            local kbFrame = Instance.new("Frame")
            kbFrame.Size, kbFrame.BackgroundTransparency, kbFrame.ZIndex, kbFrame.Parent = UDim2.new(1, 0, 0, 20), 1, 2, parent
            
            local label = Instance.new("TextLabel")
            label.Size, label.BackgroundTransparency, label.Text, label.TextColor3, label.TextXAlignment, label.ZIndex = UDim2.new(0.6, 0, 1, 0), 1, name, THEME.TextMuted, Enum.TextXAlignment.Left, 2
            AddTextStroke(label)
            ApplyFont(label, 11)
            label.Parent = kbFrame
            
            local bindBtn = Instance.new("TextButton")
            bindBtn.Size, bindBtn.Position, bindBtn.BackgroundColor3, bindBtn.Text, bindBtn.TextColor3, bindBtn.Font, bindBtn.TextSize, bindBtn.AutoButtonColor, bindBtn.TextXAlignment, bindBtn.ZIndex = UDim2.new(0.4, 0, 1, 0), UDim2.new(0.6, 0, 0, 0), Color3.fromRGB(28, 28, 36), tostring(keybind.Key), THEME.Accent, Enum.Font.GothamBold, 10, false, Enum.TextXAlignment.Center, 2
            AddCorner(bindBtn, 3)
            local bindStroke = AddStroke(bindBtn, THEME.Border, 1)
            bindBtn.Parent = kbFrame
            table.insert(allKeybinds, bindBtn)
            
            local function setKey(keyName) keybind.Key = tostring(keyName); bindBtn.Text = keybind.Key; SaveFlags[name] = keybind.Key end
            
            bindBtn.MouseEnter:Connect(function() Tween(bindStroke, 0.1, {Color = THEME.Accent}) end)
            bindBtn.MouseLeave:Connect(function() if not keybind.Binding then Tween(bindStroke, 0.1, {Color = THEME.Border}) end end)
            bindBtn.MouseButton1Click:Connect(function()
                if keybind.Binding then return end
                keybind.Binding, bindBtn.Text = true, "..."; Tween(bindStroke, 0.1, {Color = THEME.Accent})
                local conn; conn = UserInputService.InputBegan:Connect(function(inKey)
                    if inKey.UserInputType == Enum.UserInputType.Keyboard then
                        setKey(inKey.KeyCode.Name); keybind.Binding = false; Tween(bindStroke, 0.1, {Color = THEME.Border})
                        task.spawn(function() pcall(callback, inKey.KeyCode) end); conn:Disconnect()
                    elseif inKey.UserInputType == Enum.UserInputType.MouseButton1 or inKey.UserInputType == Enum.UserInputType.MouseButton2 then
                        setKey(inKey.UserInputType.Name == "MouseButton1" and "MB1" or "MB2"); keybind.Binding = false; Tween(bindStroke, 0.1, {Color = THEME.Border})
                        task.spawn(function() pcall(callback, inKey.UserInputType) end); conn:Disconnect()
                    end
                end)
            end)
            
            Flags[name] = {Set = function(val) setKey(val) end, Get = function() return keybind.Key end}
            SaveFlags[name] = keybind.Key
            table.insert(section.Elements, {Name = name, Frame = kbFrame})
            return keybind
        end
        function section:CreateKeybind(name, default, callback) return section:CreateKeybindInternal(name, default, callback, section.Frame) end
        
        -- СИНТАКСИС СОВМЕСТИМОСТИ ДЛЯ ОБЪЕКТА SECTION
        section.Toggle = function(_, o) return section:CreateCheckbox(o.Name, o.Default, o.Callback) end
        section.Slider = function(_, o) return section:CreateSlider(o.Name, o.Min, o.Max, o.Default, o.Callback) end
        section.Dropdown = function(_, o) return section:CreateDropdown(o.Name, o.List, o.Default, o.Callback) end
        section.Keybind = function(_, o) return section:CreateKeybind(o.Name, o.Default, o.Callback) end
        
        table.insert(tab.Sections, section)
        return section
    end
    return tab
end

-- =============================================================================
-- [[ МЕТОД СОЗДАНИЯ СТРАНИЦЫ НАСТРОЕК (ДЛЯ СОВМЕСТИМОСТИ С WINDOW) ]]
-- =============================================================================
function Perplexity:CreateSettingsPage()
    return self.SettingsTab
end

-- =============================================================================
-- [[ ОБНОВЛЕНИЕ ОФОРМЛЕНИЯ ПРИ СМЕНЕ ТЕМЫ ]]
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
-- [[ ОРИГИНАЛЬНЫЕ МЕТОДЫ СОХРАНЕНИЯ JSON-КОНФИГОВ ]]
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

-- =============================================================================
-- [[ ОБРАБОТКА ХОТКЕЕВ СКРЫТИЯ/ОТОБРАЖЕНИЯ ]]
-- =============================================================================
local toggleKey = Enum.KeyCode.RightShift

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == toggleKey then
        menuVisible = not menuVisible
        
        if WindowInstance and WindowInstance.MainFrame then
            if menuVisible then
                WindowInstance.MainFrame.Visible = true
                WindowInstance.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 50)
                Tween(WindowInstance.MainFrame, 0.25, {Position = UDim2.new(0.5, 0, 0.5, 0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                if optBlurEnabled and MenuBlur then MenuBlur.Enabled = true end
            else
                UserInputService.MouseIconEnabled = true
                if MenuBlur then MenuBlur.Enabled = false end
                local t = Tween(WindowInstance.MainFrame, 0.2, {Position = UDim2.new(0.5, 0, 0.5, 50)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                t.Completed:Connect(function()
                    if not menuVisible then WindowInstance.MainFrame.Visible = false end
                end)
            end
        end
    end
end)

local function Notify(title, message, duration)
    duration = duration or 3
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundColor3 = THEME.SectionBg
    notif.BackgroundTransparency = 0.1
    notif.ClipsDescendants = true
    AddCorner(notif, 6)
    AddDoubleStroke(notif)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = THEME.Accent
    titleLabel.Text = title:upper()
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ApplyFont(titleLabel, 11)
    AddTextStroke(titleLabel)
    titleLabel.Parent = notif
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -10, 0, 30)
    msgLabel.Position = UDim2.new(0, 10, 0, 22)
    msgLabel.BackgroundTransparency = 1
    msgLabel.TextColor3 = THEME.Text
    msgLabel.Text = message
    msgLabel.TextWrapped = true
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    ApplyFont(msgLabel, 11)
    AddTextStroke(msgLabel)
    msgLabel.Parent = notif
    
    notif.Parent = NotificationContainer
    Tween(notif, 0.25, {Size = UDim2.new(1, 0, 0, 60)})
    
    task.delay(duration, function()
        pcall(function()
            local t = Tween(notif, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
            t.Completed:Connect(function() notif:Destroy() end)
        end)
    end)
end

Library.Theme = THEME
getgenv().Perplexity = Library

return Library
