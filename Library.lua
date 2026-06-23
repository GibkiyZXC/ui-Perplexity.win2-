-- =============================================================================
-- [[ PERPLEXITY.WIN - OPEN-SOURCE HIGH-FIDELITY UI FRAMEWORK ]]
-- [[ Reactive Theme Customize & Perfect Layout Edition ]]
-- =============================================================================

if getgenv().Perplexity then
    pcall(function()
        getgenv().Perplexity.ScreenGui:Destroy()
    end)
end

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

local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
if not PlayerGui then
    PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Perplexity_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 
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
    Border = Color3.fromRGB(34, 34, 44),
    Outline = Color3.fromRGB(48, 50, 64)
}

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
local toggleKey = Enum.KeyCode.RightShift 

local allParticles = {}
local allCheckboxes = {}
local allSliders = {}
local allDropdownArrows = {}
local allKeybinds = {}
local allTabs = {}
local allSubTabs = {}
local allSectionTitles = {}
local allHoverGlows = {} 
local allSections = {}

local TitleTextLabel = nil
local Window = nil
local menuVisible = true

local activeParticleColors = {
    Color3.fromRGB(255, 30, 60),  
    Color3.fromRGB(100, 10, 25),  
    Color3.fromRGB(25, 25, 30)    
}

local Flags = {}
local SaveFlags = {}

local MenuFont = Enum.Font.GothamMedium
local successLoad, errLoad = pcall(function()
    if not isfolder("nexonix") then makefolder("nexonix") end
    if not isfolder("nexonix/Assets") then makefolder("nexonix/Assets") end
    
    if not isfile("Figtree-Semibold") then
        writefile("Figtree-Semibold", game:HttpGet("https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/Figtree-SemiBold.ttf"))
    end
    
    local fontData = {
        name = "figtree-Semibold",
        faces = {
            {
                name = "figtree-Semibold",
                weight = 400,
                style = "Regular",
                assetId = getcustomasset("Figtree-Semibold")
            }
        }
    }
    
    writefile("nexonix/Assets/figtree-Semibold.font", HttpService:JSONEncode(fontData))
    MenuFont = Font.new(getcustomasset("nexonix/Assets/figtree-Semibold.font"))
end)

local function ApplyFont(label, size)
    if typeof(MenuFont) == "Font" then
        label.FontFace = MenuFont
    elseif typeof(MenuFont) == "EnumItem" then
        label.Font = MenuFont
    else
        label.Font = Enum.Font.GothamMedium
    end
    label.TextSize = size or 14
end

local function Tween(object, time, properties, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(time, style, direction)
    local t = TweenService:Create(object, info, properties)
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
    stroke.Thickness = thickness or 1
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
    local stroke = Instance.new("UIStroke")
    stroke.Color = THEME.Border
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function MakeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect() 
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function toggleDropdownZIndex(dropFrame, btn, isOpen)
    local targetZ = isOpen and 100 or 2
    dropFrame.ZIndex = targetZ
    btn.ZIndex = targetZ
    
    local current = dropFrame.Parent
    while current and not current:IsA("ScrollingFrame") and current.Name ~= "Perplexity_UI" and current.Name ~= "ContentArea" do
        if current:IsA("Frame") or current:IsA("TextButton") then
            current.ZIndex = targetZ
        end
        current = current.Parent
    end
end

local NotificationContainer = Instance.new("Frame")
NotificationContainer.Size = UDim2.new(0, 280, 1, 0)
NotificationContainer.Position = UDim2.new(1, -300, 0, 20)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 10)
NotifLayout.Parent = NotificationContainer

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
            t.Completed:Connect(function()
                notif:Destroy()
            end)
        end)
    end)
end

local mouse = nil
pcall(function()
    mouse = LocalPlayer:GetMouse()
end)
while not mouse do
    task.wait(0.1)
    pcall(function()
        mouse = LocalPlayer:GetMouse()
    end)
end

pcall(function()
    UserInputService.MouseIconEnabled = true
    if mouse then
        mouse.Icon = "rbxassetid://76631660114196"
    end
end)

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
        
        local item = {
            Obj = p,
            Speed = math.random(4, 12) / 1000,
            Wind = math.random(-3, 3) / 1000
        }
        
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
                
                if newY > 1 then
                    newY = -0.05
                    newX = math.random()
                end
                if newX > 1 or newX < 0 then
                    newX = math.random()
                end
                p.Obj.Position = UDim2.new(newX, 0, newY, 0)
            end
        else
            particleContainer.Visible = false
        end
    end)
    return particleContainer
end

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
local svKnobStroke = AddStroke(svKnob, Color3.fromRGB(0, 0, 0), 1)
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
        svDragging = true
        updateSV(input.Position)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if svDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSV(input.Position)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        svDragging = false
    end
end)

local hueDragging = false
hueSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        hueDragging = true
        updateHue(input.Position)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateHue(input.Position)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        hueDragging = false
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if ColorpickerWindow.Visible then
            if openedThisFrame then return end
            
            local mPos = UserInputService:GetMouseLocation()
            local wPos = ColorpickerWindow.AbsolutePosition
            local wSize = ColorpickerWindow.AbsoluteSize
            
            local inside = mPos.X >= wPos.X and mPos.X <= wPos.X + wSize.X and
                           mPos.Y >= wPos.Y and mPos.Y <= wPos.Y + wSize.Y
            if not inside then
                ColorpickerWindow.Visible = false
            end
        end
    end
end)

-- Глобальная функция обновления цветов (Вынесена наверх)
local function UpdateTheme(themeConfig)
    for k, v in pairs(themeConfig) do
        if THEME[k] ~= nil then
            THEME[k] = v
        end
    end
    
    if TitleTextLabel then 
        TitleTextLabel.TextColor3 = THEME.Accent 
    end
    
    if Window and Window.MainFrame then
        local bg = Window.MainFrame:FindFirstChild("BgFrame")
        if bg then
            bg.BackgroundColor3 = THEME.Background
            local stroke = bg:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = THEME.Border end
        end
        
        local sidebar = Window.MainFrame:FindFirstChild("Sidebar") or (bg and bg:FindFirstChild("Sidebar"))
        if sidebar then
            sidebar.BackgroundColor3 = THEME.SidebarBg
            local stroke = sidebar:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = THEME.Border end
        end
    end
    
    for _, secFrame in ipairs(allSections) do
        if secFrame and secFrame.Parent then
            secFrame.BackgroundColor3 = THEME.SectionBg
            local stroke = secFrame:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = THEME.Border end
        end
    end
    
    for _, cb in ipairs(allCheckboxes) do
        cb.Label.TextColor3 = cb.CheckboxObj.State and THEME.Text or THEME.TextMuted
        cb.Indicator.BackgroundColor3 = cb.CheckboxObj.State and THEME.Accent or Color3.fromRGB(34, 34, 46)
        local stroke = cb.Indicator:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = cb.CheckboxObj.State and THEME.Accent or Color3.fromRGB(56, 56, 74) end
    end
    
    for _, sl in ipairs(allSliders) do
        sl.BarFill.BackgroundColor3 = THEME.Accent
        sl.ValueDisplay.TextColor3 = THEME.Accent
        local barBg = sl.BarFill.Parent
        if barBg then barBg.BackgroundColor3 = THEME.Border end
    end
    
    for _, kb in ipairs(allKeybinds) do
        kb.TextColor3 = THEME.Accent
        kb.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
        local stroke = kb:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = Color3.fromRGB(56, 56, 74) end
    end
    
    for _, arr in ipairs(allDropdownArrows) do
        arr.TextColor3 = THEME.Accent
    end
    
    for _, t in ipairs(allTabs) do
        t.Indicator.BackgroundColor3 = THEME.Accent
        local lbl = t.Button:FindFirstChildOfClass("TextLabel")
        if lbl then
            lbl.TextColor3 = (Window.ActiveTab == t) and THEME.Accent or THEME.TextMuted
        end
    end
    
    for _, st in ipairs(allSubTabs) do
        st.Underline.BackgroundColor3 = THEME.Accent
    end
    
    for _, title in ipairs(allSectionTitles) do
        title.TextColor3 = THEME.Accent
    end
    
    for _, glow in ipairs(allHoverGlows) do
        glow.ImageColor3 = THEME.Accent
    end
end

local Perplexity = {}
Perplexity.__index = Perplexity

function Perplexity.new()
    local self = setmetatable({}, Perplexity)
    Window = self 
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 840, 0, 560)
    self.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.BackgroundTransparency = 1
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = ScreenGui
    
    local BgFrame = Instance.new("Frame")
    BgFrame.Name = "BgFrame"
    BgFrame.Size = UDim2.new(1, 0, 1, 0)
    BgFrame.BackgroundColor3 = THEME.Background
    BgFrame.ZIndex = 0
    AddCorner(BgFrame, 6)
    AddDoubleStroke(BgFrame)
    BgFrame.Parent = self.MainFrame
    
    SetupMenuBackgroundParticles(self.MainFrame)
    
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
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
    TitleText.Text = "PERPLEXITY <font color='rgb(255,255,255)'>.WIN</font>"
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
    
    return self
end

function Perplexity:Toggle(state)
    menuVisible = state
    self.MainFrame.Visible = state
    
    local MenuBlur = Lighting:FindFirstChild("Perplexity_Blur")
    if MenuBlur then
        MenuBlur.Enabled = state
    end
    
    pcall(function()
        UserInputService.MouseIconEnabled = state
        if state and mouse then
            mouse.Icon = "rbxassetid://76631660114196"
        elseif mouse then
            mouse.Icon = ""
        end
    end)
end

function Perplexity:CreateTab(name)
    local tab = {
        Name = name,
        Sections = {}
    }
    
    tab.Button = Instance.new("TextButton")
    tab.Button.Size = UDim2.new(1, -10, 0, 34)
    tab.Button.BackgroundTransparency = 1
    tab.Button.Text = "" 
    tab.Button.AutoButtonColor = false
    tab.Button.ZIndex = 3
    tab.Button.Parent = self.TabButtonContainer
    AddCorner(tab.Button, 4)
    
    local tabLabel = Instance.new("TextLabel")
    tabLabel.Size = UDim2.new(1, -24, 1, 0)
    tabLabel.Position = UDim2.new(0, 24, 0, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = name
    tabLabel.TextColor3 = THEME.TextMuted
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.ZIndex = 4
    AddTextStroke(tabLabel)
    ApplyFont(tabLabel, 12)
    tabLabel.Parent = tab.Button
    
    local hoverBg = Instance.new("Frame")
    hoverBg.Size = UDim2.new(1, 0, 1, 0)
    hoverBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hoverBg.BackgroundTransparency = 1
    hoverBg.ZIndex = 0
    hoverBg.ClipsDescendants = true 
    AddCorner(hoverBg, 4)
    hoverBg.Parent = tab.Button
    
    local hoverGlow = Instance.new("ImageLabel")
    hoverGlow.Size = UDim2.new(0, 130, 0, 130) 
    hoverGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    hoverGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    hoverGlow.BackgroundTransparency = 1
    hoverGlow.Image = "rbxassetid://10822615828" 
    hoverGlow.ImageColor3 = THEME.Accent
    hoverGlow.ImageTransparency = 1 
    hoverGlow.ZIndex = 1
    hoverGlow.Parent = hoverBg
    
    table.insert(allHoverGlows, hoverGlow)
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 0, 0.5, 0)
    indicator.Position = UDim2.new(0, 8, 0.25, 0)
    indicator.BackgroundColor3 = THEME.Accent
    indicator.BackgroundTransparency = 1
    indicator.Visible = false
    indicator.Parent = tab.Button
    AddCorner(indicator, 2)
    
    tab.Frame = Instance.new("Frame")
    tab.Frame.Size = UDim2.new(1, 0, 1, 0)
    tab.Frame.BackgroundTransparency = 1
    tab.Frame.Visible = false
    tab.Frame.ZIndex = 2
    tab.Frame.Parent = self.TabContentContainer or self.ContentArea
    
    tab.Columns = {}
    for i = 1, 3 do
        local col = Instance.new("ScrollingFrame")
        col.Size = UDim2.new(0.315, 0, 1, 0)
        col.Position = UDim2.new((i - 1) * 0.34, 0, 0, 0)
        col.BackgroundTransparency = 1
        col.ScrollBarThickness = 0
        col.ZIndex = 2
        col.CanvasSize = UDim2.new(0, 0, 0, 0)
        col.AutomaticCanvasSize = Enum.AutomaticSize.Y
        col.Parent = tab.Frame
        
        local colList = Instance.new("UIListLayout")
        colList.SortOrder = Enum.SortOrder.LayoutOrder
        colList.Padding = UDim.new(0, 12)
        colList.Parent = col
        
        tab.Columns[i] = col
    end
    
    tab.Indicator = indicator
    table.insert(allTabs, tab)
    
    tab.SetTabState = function(active)
        if active then
            indicator.Visible = true
            Tween(tabLabel, 0.2, {TextColor3 = THEME.Accent})
            Tween(indicator, 0.2, {Size = UDim2.new(0, 3, 0.5, 0), BackgroundTransparency = 0})
            Tween(hoverBg, 0.2, {BackgroundTransparency = 0.95})
        else
            Tween(tabLabel, 0.2, {TextColor3 = THEME.TextMuted})
            local t = Tween(indicator, 0.2, {Size = UDim2.new(0, 0, 0.5, 0), BackgroundTransparency = 1})
            t.Completed:Connect(function()
                if self.ActiveTab ~= tab then
                    indicator.Visible = false
                end
            end)
            Tween(hoverBg, 0.2, {BackgroundTransparency = 1})
        end
    end
    
    tab.Button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tabLabel, 0.1, {TextColor3 = THEME.Text})
            Tween(hoverBg, 0.1, {BackgroundTransparency = 0.97})
        end
        Tween(hoverGlow, 0.15, {ImageTransparency = 0.88}) 
    end)
    
    tab.Button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tabLabel, 0.1, {TextColor3 = THEME.TextMuted})
            Tween(hoverBg, 0.1, {BackgroundTransparency = 1})
        end
        Tween(hoverGlow, 0.15, {ImageTransparency = 1}) 
    end)
    
    tab.Button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = input.Position.X - tab.Button.AbsolutePosition.X
            local relativeY = input.Position.Y - tab.Button.AbsolutePosition.Y
            Tween(hoverGlow, 0.08, {Position = UDim2.new(0, relativeX, 0, relativeY)})
        end
    end)
    
    tab.Button.MouseButton1Click:Connect(function()
        if self.ActiveTab == tab then return end
        
        local prevTab = self.ActiveTab
        self.ActiveTab = tab
        
        if prevTab then
            prevTab.SetTabState(false)
            prevTab.Frame.Visible = false
        end
        
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
    
    function tab:CreateSection(title, columnIndex)
        local targetColIndex = (columnIndex == 3) and 3 or ((columnIndex == 2) and 2 or 1)
        local col = tab.Columns[targetColIndex]
        local section = {
            Elements = {},
            SubTabs = {},
            ActiveSubTab = nil,
            ElementCount = 0 
        }
        
        section.Frame = Instance.new("Frame")
        section.Frame.Size = UDim2.new(1, 0, 0, 30)
        section.Frame.AutomaticSize = Enum.AutomaticSize.Y
        section.Frame.BackgroundColor3 = THEME.SectionBg
        section.Frame.BackgroundTransparency = 0.12
        section.Frame.ZIndex = 2
        AddCorner(section.Frame, 6)
        AddDoubleStroke(section.Frame)
        section.Frame.Parent = col
        
        table.insert(allSections, section.Frame) -- Регистрация секции для динамического перекрашивания
        
        local secLayout = Instance.new("UIListLayout")
        secLayout.SortOrder = Enum.SortOrder.LayoutOrder 
        secLayout.Padding = UDim.new(0, 10)
        secLayout.Parent = section.Frame
        
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 12)
        padding.PaddingBottom = UDim.new(0, 12)
        padding.PaddingLeft = UDim.new(0, 14)
        padding.PaddingRight = UDim.new(0, 14)
        padding.Parent = section.Frame
        
        section.TitleLabel = Instance.new("TextLabel")
        section.TitleLabel.Size = UDim2.new(1, 0, 0, 16)
        section.TitleLabel.BackgroundTransparency = 1
        section.TitleLabel.Text = title:upper()
        section.TitleLabel.TextColor3 = THEME.Accent
        section.TitleLabel.Font = Enum.Font.GothamBold
        section.TitleLabel.TextSize = 10
        section.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        section.TitleLabel.LayoutOrder = -100 
        section.TitleLabel.ZIndex = 2
        AddTextStroke(section.TitleLabel)
        ApplyFont(section.TitleLabel, 10)
        section.TitleLabel.Parent = section.Frame
        
        table.insert(allSectionTitles, section.TitleLabel)
        
        function section:CreateSubTab(name)
            local subTab = {
                Name = name,
                Container = nil,
                Button = nil,
                Underline = nil
            }
            
            if not section.SubTabsHeader then
                section.SubTabsHeader = Instance.new("Frame")
                section.SubTabsHeader.Size = UDim2.new(1, 0, 0, 20)
                section.SubTabsHeader.BackgroundTransparency = 1
                section.SubTabsHeader.ZIndex = 2
                section.SubTabsHeader.LayoutOrder = -50 
                section.SubTabsHeader.Parent = section.Frame
                
                local headerLayout = Instance.new("UIListLayout")
                headerLayout.FillDirection = Enum.FillDirection.Horizontal
                headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
                headerLayout.Padding = UDim.new(0, 12)
                headerLayout.Parent = section.SubTabsHeader
            end
            
            subTab.Button = Instance.new("TextButton")
            subTab.Button.Size = UDim2.new(0, 0, 1, 0)
            subTab.Button.AutomaticSize = Enum.AutomaticSize.X
            subTab.Button.BackgroundTransparency = 1
            subTab.Button.Text = name
            subTab.Button.TextColor3 = THEME.TextMuted
            subTab.Button.Font = Enum.Font.GothamMedium
            subTab.Button.TextSize = 10
            subTab.Button.ZIndex = 3
            subTab.Button.Parent = section.SubTabsHeader
            AddTextStroke(subTab.Button)
            
            subTab.Underline = Instance.new("Frame")
            subTab.Underline.Size = UDim2.new(1, 0, 0, 1.5)
            subTab.Underline.Position = UDim2.new(0, 0, 1, -1)
            subTab.Underline.BackgroundColor3 = THEME.Accent
            subTab.Underline.Visible = false
            subTab.Underline.ZIndex = 3
            subTab.Underline.Parent = subTab.Button
            
            subTab.Container = Instance.new("Frame")
            subTab.Container.Size = UDim2.new(1, 0, 0, 0)
            subTab.Container.AutomaticSize = Enum.AutomaticSize.Y
            subTab.Container.BackgroundTransparency = 1
            subTab.Container.Visible = false
            subTab.Container.ZIndex = 2
            subTab.Container.Parent = section.Frame
            
            local containerLayout = Instance.new("UIListLayout")
            containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            containerLayout.Padding = UDim.new(0, 10)
            containerLayout.Parent = subTab.Container
            
            subTab.Button.MouseButton1Click:Connect(function()
                if section.ActiveSubTab == subTab then return end
                
                if section.ActiveSubTab then
                    section.ActiveSubTab.Container.Visible = false
                    section.ActiveSubTab.Underline.Visible = false
                    section.ActiveSubTab.Button.TextColor3 = THEME.TextMuted
                end
                
                section.ActiveSubTab = subTab
                subTab.Container.Visible = true
                subTab.Underline.Visible = true
                subTab.Button.TextColor3 = THEME.Text
            end)
            
            if not section.ActiveSubTab then
                section.ActiveSubTab = subTab
                subTab.Container.Visible = true
                subTab.Underline.Visible = true
                subTab.Button.TextColor3 = THEME.Text
            end
            
            function subTab:CreateCheckbox(name, default, callback)
                return section:CreateCheckboxInternal(name, default, callback, subTab.Container)
            end
            
            function subTab:CreateSlider(name, min, max, default, callback)
                return section:CreateSliderInternal(name, min, max, default, callback, subTab.Container)
            end
            
            function subTab:CreateDropdown(name, list, default, callback)
                return section:CreateDropdownInternal(name, list, default, callback, subTab.Container)
            end
            
            function subTab:CreateKeybind(name, default, callback)
                return section:CreateKeybindInternal(name, default, callback, subTab.Container)
            end
            
            function subTab:CreateButton(name, callback)
                return section:CreateButtonInternal(name, callback, subTab.Container)
            end
            
            table.insert(allSubTabs, subTab)
            return subTab
        end
        
        function section:CreateButtonInternal(name, callback, parent)
            parent = parent or section.Frame
            
            section.ElementCount = section.ElementCount + 1
            local btnFrame = Instance.new("Frame")
            btnFrame.Size = UDim2.new(1, 0, 0, 24)
            btnFrame.BackgroundTransparency = 1
            btnFrame.ZIndex = 2
            btnFrame.LayoutOrder = section.ElementCount
            btnFrame.Parent = parent
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
            btn.Text = name
            btn.TextColor3 = THEME.Text
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 11
            btn.AutoButtonColor = false
            btn.ZIndex = 2
            AddCorner(btn, 4)
            local btnStroke = AddStroke(btn, THEME.Border, 1)
            btn.Parent = btnFrame
            
            btn.MouseEnter:Connect(function()
                Tween(btnStroke, 0.1, {Color = THEME.Accent})
            end)
            btn.MouseLeave:Connect(function()
                Tween(btnStroke, 0.1, {Color = THEME.Border})
            end)
            
            btn.MouseButton1Click:Connect(function()
                Tween(btn, 0.05, {BackgroundColor3 = THEME.Accent})
                task.delay(0.05, function()
                    Tween(btn, 0.1, {BackgroundColor3 = Color3.fromRGB(28, 28, 36)})
                end)
                task.spawn(function()
                    pcall(callback)
                end)
            end)
            
            table.insert(section.Elements, {Name = name, Frame = btnFrame})
            return btn
        end
        function section:CreateButton(name, callback)
            return section:CreateButtonInternal(name, callback, section.Frame)
        end
        
        function section:CreateCheckboxInternal(name, default, callback, parent)
            parent = parent or section.Frame
            local checkbox = {State = default or false}
            
            section.ElementCount = section.ElementCount + 1
            local boxFrame = Instance.new("Frame")
            boxFrame.Size = UDim2.new(1, 0, 0, 24) 
            boxFrame.BackgroundTransparency = 1
            boxFrame.ZIndex = 2
            boxFrame.LayoutOrder = section.ElementCount
            boxFrame.Parent = parent
            
            local clickContainer = Instance.new("TextButton")
            clickContainer.Size = UDim2.new(1, 0, 1, 0) 
            clickContainer.BackgroundTransparency = 1
            clickContainer.Text = ""
            clickContainer.Active = true
            clickContainer.AutoButtonColor = false
            clickContainer.ZIndex = 2
            clickContainer.Parent = boxFrame
            
            local indicator = Instance.new("Frame")
            indicator.Size = UDim2.new(0, 16, 0, 16) 
            indicator.Position = UDim2.new(0, 0, 0.5, -8) 
            indicator.BackgroundColor3 = checkbox.State and THEME.Accent or Color3.fromRGB(34, 34, 46)
            indicator.ZIndex = 2
            AddCorner(indicator, 3)
            local indStroke = AddStroke(indicator, Color3.fromRGB(56, 56, 74), 1)
            indicator.Parent = clickContainer
            
            local dot = Instance.new("ImageLabel")
            dot.AnchorPoint = Vector2.new(0.5, 0.5)
            dot.Position = UDim2.new(0.5, 0, 0.5, 0)
            dot.Size = checkbox.State and UDim2.new(1, -2, 1, -2) or UDim2.new(0, 0, 0, 0)
            dot.Image = "rbxassetid://3944680095"
            dot.ImageColor3 = Color3.fromRGB(255, 255, 255)
            dot.ScaleType = Enum.ScaleType.Fit
            dot.BackgroundTransparency = 1
            dot.ImageTransparency = checkbox.State and 0 or 1
            dot.ZIndex = 3
            dot.Parent = indicator
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -24, 1, 0)
            label.Position = UDim2.new(0, 24, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = checkbox.State and THEME.Text or THEME.TextMuted
            label.Font = Enum.Font.GothamMedium
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.ZIndex = 1 
            label.Active = false
            AddTextStroke(label)
            ApplyFont(label, 11)
            label.Parent = clickContainer
            
            local subElements = Instance.new("Frame")
            subElements.Size = UDim2.new(0, 0, 1, 0) 
            subElements.AutomaticSize = Enum.AutomaticSize.X
            subElements.Position = UDim2.new(1, 0, 0, 0)
            subElements.AnchorPoint = Vector2.new(1, 0) 
            subElements.BackgroundTransparency = 1
            subElements.ZIndex = 4
            subElements.Parent = boxFrame
            
            local subLayout = Instance.new("UIListLayout")
            subLayout.FillDirection = Enum.FillDirection.Horizontal
            subLayout.SortOrder = Enum.SortOrder.LayoutOrder
            subLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            subLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            subLayout.Padding = UDim.new(0, 8)
            subLayout.Parent = subElements
            
            local function updateLayout()
                local subWidth = subElements.AbsoluteSize.X
                local paddingOffset = (subWidth > 0) and (subWidth + 8) or 0
                clickContainer.Size = UDim2.new(1, -paddingOffset, 1, 0)
            end
            subElements:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout)
            task.spawn(updateLayout)
            
            local function update()
                if checkbox.State then
                    Tween(indicator, 0.15, {BackgroundColor3 = THEME.Accent})
                    Tween(indStroke, 0.15, {Color = THEME.Accent})
                    Tween(dot, 0.15, {Size = UDim2.new(1, -2, 1, -2), ImageTransparency = 0})
                    Tween(label, 0.15, {TextColor3 = THEME.Text})
                else
                    Tween(indicator, 0.15, {BackgroundColor3 = Color3.fromRGB(34, 34, 46)})
                    Tween(indStroke, 0.15, {Color = Color3.fromRGB(56, 56, 74)})
                    Tween(dot, 0.15, {Size = UDim2.new(0, 0, 0, 0), ImageTransparency = 1})
                    Tween(label, 0.15, {TextColor3 = THEME.TextMuted})
                end
                
                SaveFlags[name] = checkbox.State
                
                task.spawn(function()
                    pcall(callback, checkbox.State)
                end)
            end
            
            clickContainer.MouseEnter:Connect(function()
                Tween(indStroke, 0.1, {Color = THEME.Accent})
            end)
            clickContainer.MouseLeave:Connect(function()
                if not checkbox.State then
                    Tween(indStroke, 0.1, {Color = Color3.fromRGB(56, 56, 74)})
                end
            end)
            
            clickContainer.MouseButton1Click:Connect(function()
                checkbox.State = not checkbox.State
                update()
            end)
            
            function checkbox:CreateKeybind(default, cb)
                local kb = {Key = default or "None", Binding = false}
                
                local bindBtn = Instance.new("TextButton")
                bindBtn.Size = UDim2.new(0, 0, 0, 18) 
                bindBtn.AutomaticSize = Enum.AutomaticSize.X
                bindBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
                bindBtn.Text = tostring(kb.Key)
                bindBtn.TextColor3 = THEME.Accent
                bindBtn.Font = Enum.Font.GothamBold
                bindBtn.TextSize = 9
                bindBtn.AutoButtonColor = false
                bindBtn.TextXAlignment = Enum.TextXAlignment.Center
                bindBtn.ZIndex = 4
                AddCorner(bindBtn, 3)
                local kbStroke = AddStroke(bindBtn, Color3.fromRGB(56, 56, 74), 1)
                bindBtn.Parent = subElements
                
                local btnPadding = Instance.new("UIPadding")
                btnPadding.PaddingLeft = UDim.new(0, 6)
                btnPadding.PaddingRight = UDim.new(0, 6)
                btnPadding.Parent = bindBtn
                
                local sizeConstraint = Instance.new("UISizeConstraint")
                sizeConstraint.MinSize = Vector2.new(40, 0)
                sizeConstraint.MaxSize = Vector2.new(110, 18)
                sizeConstraint.Parent = bindBtn
                
                table.insert(allKeybinds, bindBtn)
                
                local function setKey(keyName)
                    -- Сокращение длинных названий клавиш
                    local cleanName = tostring(keyName)
                    cleanName = cleanName:gsub("MouseButton", "MB")
                    cleanName = cleanName:gsub("LeftShift", "LShift")
                    cleanName = cleanName:gsub("RightShift", "RShift")
                    cleanName = cleanName:gsub("LeftControl", "LCtrl")
                    cleanName = cleanName:gsub("RightControl", "RCtrl")
                    cleanName = cleanName:gsub("LeftAlt", "LAlt")
                    cleanName = cleanName:gsub("RightAlt", "RAlt")

                    kb.Key = cleanName
                    bindBtn.Text = cleanName
                    SaveFlags[name .. "_key"] = cleanName
                end
                
                -- Инициализация красивого короткого имени сразу при создании
                setKey(kb.Key)

                bindBtn.MouseEnter:Connect(function()
                    Tween(kbStroke, 0.1, {Color = THEME.Accent})
                end)
                bindBtn.MouseLeave:Connect(function()
                    if not kb.Binding then
                        Tween(kbStroke, 0.1, {Color = Color3.fromRGB(56, 56, 74)})
                    end
                end)
                
                bindBtn.MouseButton1Click:Connect(function()
                    if kb.Binding then return end
                    kb.Binding = true
                    bindBtn.Text = "..."
                    Tween(kbStroke, 0.1, {Color = THEME.Accent})
                    
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(inKey)
                        if inKey.UserInputType == Enum.UserInputType.Keyboard then
                            setKey(inKey.KeyCode.Name)
                            kb.Binding = false
                            Tween(kbStroke, 0.1, {Color = Color3.fromRGB(56, 56, 74)})
                            task.spawn(function() pcall(cb, inKey.KeyCode) end)
                            conn:Disconnect()
                        elseif inKey.UserInputType == Enum.UserInputType.MouseButton1 or inKey.UserInputType == Enum.UserInputType.MouseButton2 then
                            setKey(inKey.UserInputType.Name == "MouseButton1" and "MB1" or "MB2")
                            kb.Binding = false
                            Tween(kbStroke, 0.1, {Color = Color3.fromRGB(56, 56, 74)})
                            task.spawn(function() pcall(cb, inKey.UserInputType) end)
                            conn:Disconnect()
                        end
                    end)
                end)
                
                Flags[name .. "_key"] = {
                    Set = function(val)
                        setKey(val)
                    end,
                    Get = function()
                        return kb.Key
                    end
                }
                
                SaveFlags[name .. "_key"] = kb.Key
                return kb
            end
            
            function checkbox:CreateColorpicker(default, cb)
                local cp = {Value = default or Color3.fromRGB(255, 255, 255)}
                
                local cpBtn = Instance.new("TextButton")
                cpBtn.Size = UDim2.new(0, 24, 0, 14)
                cpBtn.BackgroundColor3 = cp.Value
                cpBtn.Text = ""
                cpBtn.AutoButtonColor = false
                cpBtn.ZIndex = 4
                AddCorner(cpBtn, 3)
                local cpStroke = AddStroke(cpBtn, Color3.fromRGB(56, 56, 74), 1)
                cpBtn.Parent = subElements
                
                local function setColor(colorValue)
                    cp.Value = colorValue
                    cpBtn.BackgroundColor3 = colorValue
                    SaveFlags[name .. "_color"] = colorValue:ToHex()
                end
                
                cpBtn.MouseEnter:Connect(function()
                    Tween(cpStroke, 0.1, {Color = THEME.Accent})
                end)
                cpBtn.MouseLeave:Connect(function()
                    Tween(cpStroke, 0.1, {Color = Color3.fromRGB(56, 56, 74)})
                end)
                
                cpBtn.MouseButton1Click:Connect(function()
                    openedThisFrame = true
                    activeColorpicker = {
                        H = 0, S = 1, V = 1,
                        Button = cpBtn,
                        Callback = cb
                    }
                    
                    local h, s, v = cp.Value:ToHSV()
                    activeColorpicker.H = h
                    activeColorpicker.S = s
                    activeColorpicker.V = v
                    
                    ColorpickerWindow.Position = UDim2.new(0, cpBtn.AbsolutePosition.X - 150, 0, cpBtn.AbsolutePosition.Y)
                    ColorpickerWindow.Visible = true
                    
                    svGrid.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    svKnob.Position = UDim2.new(s, 0, 1 - v, 0)
                    hueKnob.Position = UDim2.new(0.5, 0, h, 0)
                    hexLabel.Text = "HEX: #" .. cp.Value:ToHex():upper()
                    
                    task.wait()
                    openedThisFrame = false
                end)
                
                Flags[name .. "_color"] = {
                    Set = function(val)
                        setColor(Color3.fromHex(val))
                    end,
                    Get = function()
                        return cp.Value:ToHex()
                    end
                }
                
                SaveFlags[name .. "_color"] = cp.Value:ToHex()
                return cp
            end
            
            Flags[name] = {
                Set = function(val)
                    checkbox.State = val
                    update()
                end,
                Get = function()
                    return checkbox.State
                end
            }
            
            table.insert(allCheckboxes, {Indicator = indicator, Label = label, CheckboxObj = checkbox})
            SaveFlags[name] = checkbox.State
            table.insert(section.Elements, {Name = name, Frame = boxFrame})
            return checkbox
        end
        function section:CreateCheckbox(name, default, callback)
            return section:CreateCheckboxInternal(name, default, callback, section.Frame)
        end
        
        function section:CreateSliderInternal(name, min, max, default, callback, parent)
            parent = parent or section.Frame
            local slider = {Value = default or min}
            
            section.ElementCount = section.ElementCount + 1
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 42) 
            sliderFrame.BackgroundTransparency = 1
            sliderFrame.ZIndex = 2
            sliderFrame.LayoutOrder = section.ElementCount
            sliderFrame.Parent = parent
            
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -45, 0, 15)
            title.Position = UDim2.new(0, 0, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = name
            title.TextColor3 = THEME.TextMuted
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.TextTruncate = Enum.TextTruncate.AtEnd
            title.ZIndex = 2
            AddTextStroke(title)
            ApplyFont(title, 11)
            title.Parent = sliderFrame
            
            local valueDisplay = Instance.new("TextLabel")
            valueDisplay.Size = UDim2.new(1, 0, 0, 15)
            valueDisplay.Position = UDim2.new(0, 0, 0, 0)
            valueDisplay.BackgroundTransparency = 1
            valueDisplay.Text = tostring(slider.Value)
            valueDisplay.TextColor3 = THEME.Accent
            valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
            valueDisplay.ZIndex = 2
            AddTextStroke(valueDisplay)
            ApplyFont(valueDisplay, 11)
            valueDisplay.Parent = sliderFrame
            
            local barBg = Instance.new("Frame")
            barBg.Size = UDim2.new(1, 0, 0, 4)
            barBg.Position = UDim2.new(0, 0, 0, 26) 
            barBg.BackgroundColor3 = Color3.fromRGB(34, 34, 46) 
            barBg.ZIndex = 2
            AddCorner(barBg, 2)
            barBg.Parent = sliderFrame
            
            local barFill = Instance.new("Frame")
            local initPct = (slider.Value - min) / (max - min)
            barFill.Size = UDim2.new(initPct, 0, 1, 0)
            barFill.BackgroundColor3 = THEME.Accent
            barFill.ZIndex = 2
            AddCorner(barFill, 2)
            barFill.Parent = barBg
            
            local knob = Instance.new("Frame")
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Size = UDim2.new(0, 10, 0, 10)
            knob.Position = UDim2.new(initPct, 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.ZIndex = 3
            AddCorner(knob, 5)
            AddStroke(knob, Color3.fromRGB(0, 0, 0), 1)
            knob.Parent = barBg
            
            local dragging = false
            local function updateSlider(val)
                slider.Value = math.clamp(val, min, max)
                valueDisplay.Text = tostring(slider.Value)
                
                local relativeX = (slider.Value - min) / (max - min)
                barFill.Size = UDim2.new(relativeX, 0, 1, 0)
                knob.Position = UDim2.new(relativeX, 0, 0.5, 0)
                
                SaveFlags[name] = slider.Value
                task.spawn(function()
                    pcall(callback, slider.Value)
                end)
            end
            
            sliderFrame.Active = true
            sliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    local relativeX = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                    updateSlider(math.floor(min + (max - min) * relativeX))
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local relativeX = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                    updateSlider(math.floor(min + (max - min) * relativeX))
                end
            end)
            
            Flags[name] = {
                Set = function(val)
                    updateSlider(val)
                end,
                Get = function()
                    return slider.Value
                end
            }
            
            table.insert(allSliders, {BarFill = barFill, ValueDisplay = valueDisplay})
            SaveFlags[name] = slider.Value
            table.insert(section.Elements, {Name = name, Frame = sliderFrame})
            return slider
        end
        function section:CreateSlider(name, min, max, default, callback)
            return section:CreateSliderInternal(name, min, max, default, callback, section.Frame)
        end
        
        function section:CreateDropdownInternal(name, list, default, callback, parent)
            parent = parent or section.Frame
            local dropdown = {Selected = default or list[1], Open = false}
            
            section.ElementCount = section.ElementCount + 1
            local dropFrame = Instance.new("Frame")
            dropFrame.Size = UDim2.new(1, 0, 0, 44) 
            dropFrame.BackgroundTransparency = 1
            dropFrame.ZIndex = 2
            dropFrame.LayoutOrder = section.ElementCount
            dropFrame.Parent = parent
            
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, 0, 0, 15)
            title.BackgroundTransparency = 1
            title.Text = name
            title.TextColor3 = THEME.TextMuted
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 2
            AddTextStroke(title)
            ApplyFont(title, 11)
            title.Parent = dropFrame
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 22) 
            btn.Position = UDim2.new(0, 0, 0, 18)
            btn.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
            btn.Text = "  " .. dropdown.Selected
            btn.TextColor3 = THEME.Text
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 10
            btn.AutoButtonColor = false
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 2
            AddCorner(btn, 4)
            local btnStroke = AddStroke(btn, Color3.fromRGB(56, 56, 74), 1)
            btn.Parent = dropFrame
            
            local arrow = Instance.new("TextLabel")
            arrow.AnchorPoint = Vector2.new(0.5, 0.5)
            arrow.Size = UDim2.new(0, 14, 0, 14)
            arrow.Position = UDim2.new(1, -12, 0.5, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "+"
            arrow.TextColor3 = THEME.Accent
            arrow.Font = Enum.Font.GothamBold
            arrow.TextSize = 12
            arrow.ZIndex = 2
            arrow.Parent = btn
            
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 0)
            container.Position = UDim2.new(0, 0, 0, 41) 
            container.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
            container.ZIndex = 50
            container.ClipsDescendants = true
            container.Visible = false
            AddCorner(container, 4)
            AddStroke(container, Color3.fromRGB(56, 56, 74), 1)
            container.Parent = dropFrame
            
            local dropLayout = Instance.new("UIListLayout")
            dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
            dropLayout.Parent = container
            
            local targetHeight = #list * 20
            
            local function selectValue(item)
                dropdown.Selected = item
                btn.Text = "  " .. item
                SaveFlags[name] = item
                task.spawn(function()
                    pcall(callback, item)
                end)
            end
            
            for index, item in ipairs(list) do
                local itemBtn = Instance.new("TextButton")
                itemBtn.Size = UDim2.new(1, 0, 0, 20)
                itemBtn.BackgroundTransparency = 1
                itemBtn.Text = "  " .. item
                itemBtn.TextColor3 = THEME.TextMuted
                itemBtn.Font = Enum.Font.Gotham
                itemBtn.TextSize = 10
                itemBtn.AutoButtonColor = false
                itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                itemBtn.LayoutOrder = index
                itemBtn.ZIndex = 51
                ApplyFont(itemBtn, 10)
                itemBtn.Parent = container
                
                itemBtn.MouseEnter:Connect(function()
                    Tween(itemBtn, 0.1, {TextColor3 = THEME.Text})
                end)
                itemBtn.MouseLeave:Connect(function()
                    Tween(itemBtn, 0.1, {TextColor3 = THEME.TextMuted})
                end)
                
                itemBtn.MouseButton1Click:Connect(function()
                    selectValue(item)
                    dropdown.Open = false
                    toggleDropdownZIndex(dropFrame, btn, false) 
                    Tween(container, 0.15, {Size = UDim2.new(1, 0, 0, 0)})
                    Tween(arrow, 0.15, {Rotation = 0})
                    task.delay(0.15, function() container.Visible = false end)
                end)
            end
            
            btn.MouseButton1Click:Connect(function()
                dropdown.Open = not dropdown.Open
                toggleDropdownZIndex(dropFrame, btn, dropdown.Open) 
                if dropdown.Open then
                    container.Visible = true
                    Tween(container, 0.2, {Size = UDim2.new(1, 0, 0, targetHeight)})
                    Tween(arrow, 0.2, {Rotation = 45})
                else
                    local t = Tween(container, 0.15, {Size = UDim2.new(1, 0, 0, 0)})
                    Tween(arrow, 0.15, {Rotation = 0})
                    
                    local conn
                    conn = t.Completed:Connect(function()
                        if not dropdown.Open then
                            container.Visible = false
                        end
                        conn:Disconnect()
                    end)
                end
            end)
            
            btn.MouseEnter:Connect(function() Tween(btnStroke, 0.1, {Color = THEME.Accent}) end)
            btn.MouseLeave:Connect(function() Tween(btnStroke, 0.1, {Color = Color3.fromRGB(56, 56, 74)}) end)
            
            Flags[name] = {
                Set = function(val)
                    selectValue(val)
                end,
                Get = function()
                    return dropdown.Selected
                end
            }
            
            table.insert(allDropdownArrows, arrow)
            SaveFlags[name] = dropdown.Selected
            table.insert(section.Elements, {Name = name, Frame = dropFrame})
            return dropdown
        end
        function section:CreateDropdown(name, list, default, callback)
            return section:CreateDropdownInternal(name, list, default, callback, section.Frame)
        end
        
        function section:CreateKeybindInternal(name, default, callback, parent)
            parent = parent or section.Frame
            local keybind = {Key = default or "None", Binding = false}
            
            section.ElementCount = section.ElementCount + 1
            local kbFrame = Instance.new("Frame")
            kbFrame.Size = UDim2.new(1, 0, 0, 24) 
            kbFrame.BackgroundTransparency = 1
            kbFrame.ZIndex = 2
            kbFrame.LayoutOrder = section.ElementCount
            kbFrame.Parent = parent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 1, 0) -- Изначально, будет реактивно обновлено под размер кнопки
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = THEME.TextMuted
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.ZIndex = 2
            AddTextStroke(label)
            ApplyFont(label, 11)
            label.Parent = kbFrame
            
            local bindBtn = Instance.new("TextButton")
            bindBtn.AnchorPoint = Vector2.new(1, 0.5)
            bindBtn.Position = UDim2.new(1, 0, 0.5, 0)
            bindBtn.Size = UDim2.new(0, 0, 0, 18) -- Высота 18, ширина автоматическая
            bindBtn.AutomaticSize = Enum.AutomaticSize.X
            bindBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
            bindBtn.Text = tostring(keybind.Key)
            bindBtn.TextColor3 = THEME.Accent
            bindBtn.Font = Enum.Font.GothamBold
            bindBtn.TextSize = 10
            bindBtn.AutoButtonColor = false
            bindBtn.TextXAlignment = Enum.TextXAlignment.Center
            bindBtn.ZIndex = 2
            AddCorner(bindBtn, 3)
            local bindStroke = AddStroke(bindBtn, Color3.fromRGB(56, 56, 74), 1)
            bindBtn.Parent = kbFrame
            
            local btnPadding = Instance.new("UIPadding")
            btnPadding.PaddingLeft = UDim.new(0, 8)
            btnPadding.PaddingRight = UDim.new(0, 8)
            btnPadding.Parent = bindBtn
            
            local sizeConstraint = Instance.new("UISizeConstraint")
            sizeConstraint.MinSize = Vector2.new(45, 0)
            sizeConstraint.MaxSize = Vector2.new(120, 18)
            sizeConstraint.Parent = bindBtn
            
            table.insert(allKeybinds, bindBtn)
            
            local function setKey(keyName)
                -- Сокращение длинных названий клавиш
                local cleanName = tostring(keyName)
                cleanName = cleanName:gsub("MouseButton", "MB")
                cleanName = cleanName:gsub("LeftShift", "LShift")
                cleanName = cleanName:gsub("RightShift", "RShift")
                cleanName = cleanName:gsub("LeftControl", "LCtrl")
                cleanName = cleanName:gsub("RightControl", "RCtrl")
                cleanName = cleanName:gsub("LeftAlt", "LAlt")
                cleanName = cleanName:gsub("RightAlt", "RAlt")

                keybind.Key = cleanName
                bindBtn.Text = cleanName
                SaveFlags[name] = cleanName
            end
            
            setKey(keybind.Key)

            bindBtn.MouseEnter:Connect(function()
                Tween(bindStroke, 0.1, {Color = THEME.Accent})
            end)
            bindBtn.MouseLeave:Connect(function()
                if not keybind.Binding then
                    Tween(bindStroke, 0.1, {Color = Color3.fromRGB(56, 56, 74)})
                end
            end)
            
            bindBtn.MouseButton1Click:Connect(function()
                if keybind.Binding then return end
                keybind.Binding = true
                bindBtn.Text = "..."
                Tween(bindStroke, 0.1, {Color = THEME.Accent})
                
                local conn
                conn = UserInputService.InputBegan:Connect(function(inKey)
                    if inKey.UserInputType == Enum.UserInputType.Keyboard then
                        setKey(inKey.KeyCode.Name)
                        keybind.Binding = false
                        Tween(bindStroke, 0.1, {Color = Color3.fromRGB(56, 56, 74)})
                        task.spawn(function() pcall(callback, inKey.KeyCode) end)
                        conn:Disconnect()
                    elseif inKey.UserInputType == Enum.UserInputType.MouseButton1 or inKey.UserInputType == Enum.UserInputType.MouseButton2 then
                        setKey(inKey.UserInputType.Name == "MouseButton1" and "MB1" or "MB2")
                        keybind.Binding = false
                        Tween(bindStroke, 0.1, {Color = Color3.fromRGB(56, 56, 74)})
                        task.spawn(function() pcall(callback, inKey.UserInputType) end)
                        conn:Disconnect()
                    end
                end)
            end)
            
            -- Реактивное управление шириной текстового поля
            local function updateLabelSize()
                local btnWidth = bindBtn.AbsoluteSize.X
                label.Size = UDim2.new(1, -btnWidth - 10, 1, 0)
            end
            bindBtn:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLabelSize)
            task.spawn(updateLabelSize)

            Flags[name] = {
                Set = function(val)
                    setKey(val)
                end,
                Get = function()
                    return keybind.Key
                end
            }
            
            SaveFlags[name] = keybind.Key
            table.insert(section.Elements, {Name = name, Frame = kbFrame})
            return keybind
        end
        function section:CreateKeybind(name, default, callback)
            return section:CreateKeybindInternal(name, default, callback, section.Frame)
        end
        
        table.insert(tab.Sections, section)
        return section
    end
    
    return tab
end

-- Публичный метод обновления темы (Вынесен в класс Perplexity)
function Perplexity:UpdateTheme(themeTable)
    UpdateTheme(themeTable)
end

local function UpdateBackgroundTheme(accentColor, particleColors)
    UpdateTheme({
        Accent = accentColor
    })
    activeParticleColors = particleColors
end

local function SaveConfig(slotName)
    pcall(function()
        if not isfolder("perplexity") then makefolder("perplexity") end
        if not isfolder("perplexity/Configs") then makefolder("perplexity/Configs") end
        
        local encoded = HttpService:JSONEncode(SaveFlags)
        writefile("perplexity/Configs/" .. slotName .. ".json", encoded)
        Notify("Configs", "Настройки сохранены в слот: " .. slotName, 3)
    end)
end

local function LoadConfig(slotName)
    pcall(function()
        local path = "perplexity/Configs/" .. slotName .. ".json"
        if isfile(path) then
            local content = readfile(path)
            local data = HttpService:JSONDecode(content)

            for flagName, value in pairs(data) do
                if Flags[flagName] then
                    pcall(function()
                        Flags[flagName].Set(value)
                    end)
                end
            end
            Notify("Configs", "Конфиг " .. slotName .. " успешно загружен!", 3)
        else
            Notify("Configs", "Конфигурация " .. slotName .. " не найдена.", 4)
        end
    end)
end

return Perplexity
```

---

### Обновленный код Loader-скрипта (Основного скрипта)

Мы добавили в раздел **Menu Settings** динамические палитры цветов, которые позволят вам полностью перекрасить интерфейс в любой цвет прямо во время игры.

```lua
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
    AimFOV = 100,                                    -- :Запись по умолчанию
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

-- // 2. УМНАЯ ОЧИСТКА DRAWING ИЗ ГЛОБАЛЬНОГО ОКРУЖЕНИЯ
if getgenv().Premium_FOVCircle then
    pcall(function() getgenv().Premium_FOVCircle:Remove() end)
    getgenv().Premium_FOVCircle = nil
end
if getgenv().Premium_TargetLine then
    pcall(function() getgenv().Premium_TargetLine:Remove() end)
    getgenv().Premium_TargetLine = nil
end
if getgenv().Premium_ESP_Connection then
    pcall(function() getgenv().Premium_ESP_Connection:Disconnect() end)
    getgenv().Premium_ESP_Connection = nil
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

-- // ОБХОД КЭША GITHUB И ЗАГРУЗКА БИБЛИОТЕКИ
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
local Window = Perplexity.new("Premium Suite") 

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

-- // НОВЫЙ РАЗДЕЛ: НАСТРОЙКА ЦВЕТОВОЙ ПАЛИТРЫ ИНТЕРФЕЙСА (ТЕМИЗАЦИЯ)
local AccentColorPicker = MenuSettings:CreateCheckbox("Accent Color", true, function() end)
AccentColorPicker:CreateColorpicker(Color3.fromRGB(255, 30, 60), function(color)
    Perplexity:UpdateTheme({ Accent = color })
end)

local MainBgPicker = MenuSettings:CreateCheckbox("Background Color", true, function() end)
MainBgPicker:CreateColorpicker(Color3.fromRGB(11, 11, 14), function(color)
    Perplexity:UpdateTheme({ Background = color })
end)

local SidebarBgPicker = MenuSettings:CreateCheckbox("Sidebar Color", true, function() end)
SidebarBgPicker:CreateColorpicker(Color3.fromRGB(15, 15, 20), function(color)
    Perplexity:UpdateTheme({ SidebarBg = color })
end)

local SectionBgPicker = MenuSettings:CreateCheckbox("Section Cards Color", true, function() end)
SectionBgPicker:CreateColorpicker(Color3.fromRGB(16, 16, 23), function(color)
    Perplexity:UpdateTheme({ SectionBg = color })
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
    HealthGlow.Size = UDim2.new(1, 12, 1, 12) 
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
    NameLabel.Text = player.DisplayName or player.Name
    NameLabel.Parent = MainFrame

    local NameStroke = Instance.new("UIStroke")
    NameStroke.Color = Color3.fromRGB(0, 0, 0)
    NameStroke.Thickness = 1
    NameStroke.Transparency = 0.25
    NameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    NameStroke.Parent = NameLabel

    -- Дистанция
    local DistanceLabel = Instance.new("TextLabel")
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.Position = UDim2.new(0.5, 0, 1, 7)
    DistanceLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    DistanceLabel.Size = UDim2.new(0, 200, 0, 15)
    DistanceLabel.Font = CONFIG.Font
    DistanceLabel.TextSize = CONFIG.TextSize - 1
    DistanceLabel.TextColor3 = CONFIG.DistanceColor
    DistanceLabel.Text = "0 studs"
    DistanceLabel.Parent = MainFrame

    local DistanceStroke = Instance.new("UIStroke")
    DistanceStroke.Color = Color3.fromRGB(0, 0, 0)
    DistanceStroke.Thickness = 1
    DistanceStroke.Transparency = 0.25
    DistanceStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    DistanceStroke.Parent = DistanceLabel

    -- ХП числом
    local HealthText = Instance.new("TextLabel")
    HealthText.BackgroundTransparency = 1
    HealthText.AnchorPoint = Vector2.new(1, 0.5)
    HealthText.Size = UDim2.new(0, 30, 0, 12)
    HealthText.Font = CONFIG.Font
    HealthText.TextSize = CONFIG.TextSize - 2
    HealthText.TextColor3 = Color3.fromRGB(255, 255, 255)
    HealthText.TextXAlignment = Enum.TextXAlignment.Right
    HealthText.Visible = false
    HealthText.Parent = MainFrame

    local HealthStroke = Instance.new("UIStroke")
    HealthStroke.Color = Color3.fromRGB(0, 0, 0)
    HealthStroke.Thickness = 1
    HealthStroke.Transparency = 0.25
    HealthStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    HealthStroke.Parent = HealthText

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
        if key == "MouseButton1" or key == "MouseButton2" or key == "MB1" or key == "MB2" then
            local map = { MB1 = "MouseButton1", MB2 = "MouseButton2" }
            local rawType = map[key] or key
            return UserInputService:IsMouseButtonPressed(Enum.UserInputType[rawType])
        else
            local mapKeys = { LShift = "LeftShift", RShift = "RightShift", LCtrl = "LeftControl", RCtrl = "RightControl" }
            local rawName = mapKeys[key] or key
            local successCode, keyCode = pcall(function() return Enum.KeyCode[rawName] end)
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
getgenv().Premium_ESP_Connection = RunService.RenderStepped:Connect(function()
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
                    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                    
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
