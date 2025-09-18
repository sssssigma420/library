-- lib_modern.lua — Enhanced SketchUI with modern design, animations, and improved UX
-- Modern glassmorphism design, smooth animations, better interactions
-- RightShift toggles visibility.
-- FIXED VERSION - White background issue resolved
-- API:
--   local UI = loadfile("lib_modern.lua")()
--   local window = UI:CreateWindow("Modern UI")
--   local tab = window:CreateTab("Main", "⚡")
--   local section = tab:CreateSection("Settings")
--   section:AddToggle("Enabled", false, function(v) print(v) end)
--   section:AddSlider("FOV", 20, 400, 120, function(v) print(v) end)

local UI = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Modern Theme with glassmorphism and vibrant accents - FIXED VERSION
local Theme = {
    -- Main colors - ALL DARK, NO WHITE
    Background = Color3.fromRGB(15, 15, 17),
    Surface = Color3.fromRGB(22, 22, 26),
    SurfaceVariant = Color3.fromRGB(28, 28, 32),
    Sidebar = Color3.fromRGB(18, 18, 22),
    
    -- Text colors
    Text = Color3.fromRGB(245, 245, 250),
    TextMuted = Color3.fromRGB(156, 163, 175),
    TextDisabled = Color3.fromRGB(107, 114, 128),
    
    -- Accent system
    Primary = Color3.fromRGB(99, 102, 241),    -- Indigo
    PrimaryHover = Color3.fromRGB(129, 140, 248),
    PrimaryDim = Color3.fromRGB(67, 56, 202),
    
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(251, 191, 36),
    Error = Color3.fromRGB(239, 68, 68),
    
    -- Borders and strokes
    Border = Color3.fromRGB(55, 65, 81),
    BorderLight = Color3.fromRGB(75, 85, 99),
    
    -- Effects - FIXED: NO WHITE COLORS
    Shadow = Color3.fromRGB(0, 0, 0),
    Glow = Color3.fromRGB(99, 102, 241),
    GlassBlur = Color3.fromRGB(30, 30, 35),  -- FIXED: Was white, now dark
}

-- Animation constants
local AnimationSpeed = {
    Fast = 0.15,
    Medium = 0.25,
    Slow = 0.35,
}

-- Utility functions
local function noop() end

local function createRipple(button, color)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.BackgroundColor3 = color or Theme.Primary
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.Parent = button
    ripple.ZIndex = button.ZIndex + 1
    
    local corner = Instance.new("UICorner", ripple)
    corner.CornerRadius = UDim.new(1, 0)
    
    return ripple
end

local function playRipple(button, inputPos)
    local ripple = createRipple(button)
    local buttonPos = button.AbsolutePosition
    local buttonSize = button.AbsoluteSize
    
    ripple.Position = UDim2.new(0, inputPos.X - buttonPos.X, 0, inputPos.Y - buttonPos.Y)
    
    local maxSize = math.max(buttonSize.X, buttonSize.Y) * 2
    
    local expandTween = TweenService:Create(
        ripple,
        TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            Position = UDim2.new(0, inputPos.X - buttonPos.X - maxSize/2, 0, inputPos.Y - buttonPos.Y - maxSize/2),
            BackgroundTransparency = 1
        }
    )
    
    expandTween:Play()
    expandTween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- Accent registry for dynamic theming
local AccentRegistry = {}
local function registerAccent(inst, prop, accentType)
    accentType = accentType or "Primary"
    table.insert(AccentRegistry, {inst = inst, prop = prop, type = accentType})
    inst[prop] = Theme[accentType]
end

local function applyAccent(color, accentType)
    accentType = accentType or "Primary"
    Theme[accentType] = color
    
    for _, item in ipairs(AccentRegistry) do
        if item.type == accentType and item.inst and item.inst.Parent then
            pcall(function() item.inst[item.prop] = color end)
        end
    end
end

-- Create main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)

-- Enhanced loading animation
local LoadingContainer = Instance.new("Frame")
LoadingContainer.Name = "LoadingContainer"
LoadingContainer.Size = UDim2.fromScale(1, 1)
LoadingContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
LoadingContainer.BackgroundTransparency = 0.1
LoadingContainer.BorderSizePixel = 0
LoadingContainer.Parent = ScreenGui

-- Background blur effect
local BlurEffect = Instance.new("Frame")
BlurEffect.Size = UDim2.fromScale(1, 1)
BlurEffect.BackgroundColor3 = Theme.Background
BlurEffect.BackgroundTransparency = 0.3
BlurEffect.Parent = LoadingContainer

local BlurGradient = Instance.new("UIGradient", BlurEffect)
BlurGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(99, 102, 241)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 92, 246))
})
BlurGradient.Transparency = NumberSequence.new(0.9)
BlurGradient.Rotation = 45

-- Modern logo with glow effect
local LogoContainer = Instance.new("Frame")
LogoContainer.Name = "LogoContainer"
LogoContainer.AnchorPoint = Vector2.new(0.5, 0.5)
LogoContainer.Position = UDim2.fromScale(0.5, 0.5)
LogoContainer.Size = UDim2.new(0, 160, 0, 160)
LogoContainer.BackgroundTransparency = 1
LogoContainer.Parent = LoadingContainer

-- Glowing background for logo
local LogoGlow = Instance.new("Frame")
LogoGlow.Name = "Glow"
LogoGlow.Size = UDim2.fromScale(1.5, 1.5)
LogoGlow.AnchorPoint = Vector2.new(0.5, 0.5)
LogoGlow.Position = UDim2.fromScale(0.5, 0.5)
LogoGlow.BackgroundColor3 = Theme.Glow
LogoGlow.BackgroundTransparency = 0.8
LogoGlow.Parent = LogoContainer
LogoGlow.ZIndex = 1

local GlowCorner = Instance.new("UICorner", LogoGlow)
GlowCorner.CornerRadius = UDim.new(1, 0)

local GlowGradient = Instance.new("UIGradient", LogoGlow)
GlowGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Primary),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 92, 246))
})

-- Main logo
local Logo = Instance.new("ImageLabel")
Logo.Name = "Logo"
Logo.Size = UDim2.fromScale(1, 1)
Logo.AnchorPoint = Vector2.new(0.5, 0.5)
Logo.Position = UDim2.fromScale(0.5, 0.5)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://133603881881804"
Logo.ScaleType = Enum.ScaleType.Fit
Logo.Parent = LogoContainer
Logo.ZIndex = 2

local LogoCorner = Instance.new("UICorner", Logo)
LogoCorner.CornerRadius = UDim.new(0, 20)

-- Loading text with typing effect
local LoadingText = Instance.new("TextLabel")
LoadingText.Name = "LoadingText"
LoadingText.Size = UDim2.new(0, 300, 0, 40)
LoadingText.Position = UDim2.new(0.5, -150, 0.7, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Font = Enum.Font.GothamMedium
LoadingText.TextSize = 16
LoadingText.TextColor3 = Theme.Text
LoadingText.TextTransparency = 0.3
LoadingText.Text = ""
LoadingText.Parent = LoadingContainer

-- Animated loading dots
local LoadingDots = Instance.new("Frame")
LoadingDots.Name = "LoadingDots"
LoadingDots.Size = UDim2.new(0, 60, 0, 10)
LoadingDots.Position = UDim2.new(0.5, -30, 0.8, 0)
LoadingDots.BackgroundTransparency = 1
LoadingDots.Parent = LoadingContainer

for i = 1, 3 do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0, (i-1) * 20 + 6, 0, 1)
    dot.BackgroundColor3 = Theme.Primary
    dot.BorderSizePixel = 0
    dot.Parent = LoadingDots
    
    local dotCorner = Instance.new("UICorner", dot)
    dotCorner.CornerRadius = UDim.new(1, 0)
    
    -- Animate dots
    local dotTween = TweenService:Create(
        dot,
        TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {BackgroundTransparency = 0.8}
    )
    
    task.wait(0.2)
    dotTween:Play()
end

-- Enhanced sound
local LoadingSound = Instance.new("Sound")
LoadingSound.SoundId = "rbxassetid://624706518"
LoadingSound.Volume = 0.3
LoadingSound.Parent = LoadingContainer

-- Typing effect for loading text
local loadingMessages = {
    "Initializing modern interface...",
    "Loading components...",
    "Applying modern theme...",
    "Ready to launch!"
}

-- Loading sequence
task.spawn(function()
    LoadingSound:Play()
    
    -- Logo entrance animation
    LogoContainer.Size = UDim2.new(0, 0, 0, 0)
    local logoTween = TweenService:Create(
        LogoContainer,
        TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 160, 0, 160)}
    )
    logoTween:Play()
    
    -- Glow pulse animation
    local glowTween = TweenService:Create(
        LogoGlow,
        TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Size = UDim2.fromScale(2, 2), BackgroundTransparency = 0.95}
    )
    glowTween:Play()
    
    logoTween.Completed:Wait()
    
    -- Type loading messages
    for _, message in ipairs(loadingMessages) do
        for i = 1, #message do
            LoadingText.Text = string.sub(message, 1, i)
            task.wait(0.03)
        end
        task.wait(0.5)
    end
    
    task.wait(1)
    
    -- Exit animation
    local exitTween = TweenService:Create(
        LoadingContainer,
        TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {BackgroundTransparency = 1}
    )
    
    local logoExitTween = TweenService:Create(
        LogoContainer,
        TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 0, 0, 0)}
    )
    
    exitTween:Play()
    logoExitTween:Play()
    
    exitTween.Completed:Wait()
    LoadingContainer:Destroy()
    
    -- Show main interface
    task.wait(0.3)
    if UI.MainWindow then
        UI.MainWindow.Visible = true
        
        -- Entrance animation for main window
        UI.MainWindow.Size = UDim2.new(0, 0, 0, 0)
        local mainTween = TweenService:Create(
            UI.MainWindow,
            TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 940, 0, 520)}
        )
        mainTween:Play()
    end
end)

-- Create main window frame
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 940, 0, 520)
MainWindow.Position = UDim2.fromScale(0.5, 0.5)
MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
MainWindow.BackgroundColor3 = Theme.Background
MainWindow.BorderSizePixel = 0
MainWindow.Visible = false
MainWindow.Parent = ScreenGui
UI.MainWindow = MainWindow

-- Modern border with gradient
local MainBorder = Instance.new("UIStroke", MainWindow)
MainBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainBorder.Color = Theme.Border
MainBorder.Thickness = 1.5
MainBorder.Transparency = 0.3

local MainCorner = Instance.new("UICorner", MainWindow)
MainCorner.CornerRadius = UDim.new(0, 16)

-- Subtle background gradient
local MainGradient = Instance.new("UIGradient", MainWindow)
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 17))
})
MainGradient.Rotation = 135

-- Drop shadow effect
local ShadowFrame = Instance.new("Frame")
ShadowFrame.Size = UDim2.new(1, 20, 1, 20)
ShadowFrame.Position = UDim2.new(0, -10, 0, -5)
ShadowFrame.BackgroundColor3 = Theme.Shadow
ShadowFrame.BackgroundTransparency = 0.7
ShadowFrame.BorderSizePixel = 0
ShadowFrame.Parent = MainWindow
ShadowFrame.ZIndex = MainWindow.ZIndex - 1

local ShadowCorner = Instance.new("UICorner", ShadowFrame)
ShadowCorner.CornerRadius = UDim.new(0, 20)

-- Enhanced title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Theme.Surface
TitleBar.BackgroundTransparency = 0.1
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainWindow

local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 16)

-- Glass effect for title bar - FIXED VERSION
local TitleGradient = Instance.new("UIGradient", TitleBar)
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.GlassBlur),  -- Now dark instead of white
    ColorSequenceKeypoint.new(1, Theme.GlassBlur)
})
TitleGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.95),
    NumberSequenceKeypoint.new(1, 0.98)
})

-- Window title with modern typography
local WindowTitle = Instance.new("TextLabel")
WindowTitle.Size = UDim2.new(0, 300, 1, 0)
WindowTitle.Position = UDim2.new(0, 24, 0, 0)
WindowTitle.BackgroundTransparency = 1
WindowTitle.Font = Enum.Font.GothamBold
WindowTitle.TextSize = 20
WindowTitle.TextColor3 = Theme.Text
WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
WindowTitle.Text = "Modern UI"
WindowTitle.Parent = TitleBar

-- Version badge
local VersionBadge = Instance.new("Frame")
VersionBadge.Size = UDim2.new(0, 80, 0, 24)
VersionBadge.Position = UDim2.new(1, -100, 0.5, -12)
VersionBadge.BackgroundColor3 = Theme.Primary
VersionBadge.BackgroundTransparency = 0.1
VersionBadge.BorderSizePixel = 0
VersionBadge.Parent = TitleBar

local BadgeCorner = Instance.new("UICorner", VersionBadge)
BadgeCorner.CornerRadius = UDim.new(0, 12)

local BadgeStroke = Instance.new("UIStroke", VersionBadge)
BadgeStroke.Color = Theme.Primary
BadgeStroke.Transparency = 0.7
BadgeStroke.Thickness = 1

registerAccent(VersionBadge, "BackgroundColor3")
registerAccent(BadgeStroke, "Color")

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.fromScale(1, 1)
VersionText.BackgroundTransparency = 1
VersionText.Font = Enum.Font.GothamMedium
VersionText.TextSize = 12
VersionText.TextColor3 = Theme.Text
VersionText.Text = "v2.0"
VersionText.Parent = VersionBadge

-- Subtle underline
local TitleUnderline = Instance.new("Frame")
TitleUnderline.Size = UDim2.new(1, -40, 0, 1)
TitleUnderline.Position = UDim2.new(0, 20, 1, -1)
TitleUnderline.BackgroundColor3 = Theme.Border
TitleUnderline.BackgroundTransparency = 0.5
TitleUnderline.BorderSizePixel = 0
TitleUnderline.Parent = TitleBar

-- Enhanced dragging functionality
do
    local dragging = false
    local dragStart, startPos
    local dragConnection
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainWindow.Position
            
            -- Drag feedback
            TweenService:Create(MainWindow, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 938, 0, 518)
            }):Play()
            
            dragConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if dragConnection then
                        dragConnection:Disconnect()
                    end
                    
                    -- Reset size
                    TweenService:Create(MainWindow, TweenInfo.new(0.1), {
                        Size = UDim2.new(0, 940, 0, 520)
                    }):Play()
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainWindow.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Enhanced sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 240, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainWindow

local SidebarCorner = Instance.new("UICorner", Sidebar)
SidebarCorner.CornerRadius = UDim.new(0, 12)

local SidebarBorder = Instance.new("UIStroke", Sidebar)
SidebarBorder.Color = Theme.Border
SidebarBorder.Transparency = 0.6
SidebarBorder.Thickness = 1

-- Sidebar gradient
local SidebarGradient = Instance.new("UIGradient", Sidebar)
SidebarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 20))
})
SidebarGradient.Rotation = 90

-- Enhanced logo section
local LogoSection = Instance.new("Frame")
LogoSection.Name = "LogoSection"
LogoSection.Size = UDim2.new(1, 0, 0, 120)
LogoSection.BackgroundTransparency = 1
LogoSection.Parent = Sidebar

local SidebarLogo = Instance.new("ImageLabel")
SidebarLogo.Size = UDim2.new(0, 80, 0, 80)
SidebarLogo.Position = UDim2.new(0.5, -40, 0.5, -40)
SidebarLogo.BackgroundTransparency = 1
SidebarLogo.Image = "rbxassetid://124433474541732"
SidebarLogo.ScaleType = Enum.ScaleType.Fit
SidebarLogo.Parent = LogoSection

local LogoFrame = Instance.new("UICorner", SidebarLogo)
LogoFrame.CornerRadius = UDim.new(0, 16)

-- Logo glow effect
local SidebarLogoGlow = Instance.new("Frame")
SidebarLogoGlow.Size = UDim2.new(0, 100, 0, 100)
SidebarLogoGlow.Position = UDim2.new(0.5, -50, 0.5, -50)
SidebarLogoGlow.BackgroundColor3 = Theme.Glow
SidebarLogoGlow.BackgroundTransparency = 0.85
SidebarLogoGlow.BorderSizePixel = 0
SidebarLogoGlow.Parent = LogoSection
SidebarLogoGlow.ZIndex = SidebarLogo.ZIndex - 1

local GlowCorner2 = Instance.new("UICorner", SidebarLogoGlow)
GlowCorner2.CornerRadius = UDim.new(1, 0)

-- Breathing glow animation
local breatheTween = TweenService:Create(
    SidebarLogoGlow,
    TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    {
        Size = UDim2.new(0, 110, 0, 110),
        Position = UDim2.new(0.5, -55, 0.5, -55),
        BackgroundTransparency = 0.95
    }
)
breatheTween:Play()

-- Tabs section
local TabsSection = Instance.new("Frame")
TabsSection.Name = "TabsSection"
TabsSection.Size = UDim2.new(1, -24, 1, -280)
TabsSection.Position = UDim2.new(0, 12, 0, 130)
TabsSection.BackgroundTransparency = 1
TabsSection.Parent = Sidebar

local TabsList = Instance.new("UIListLayout", TabsSection)
TabsList.FillDirection = Enum.FillDirection.Vertical
TabsList.Padding = UDim.new(0, 6)
TabsList.SortOrder = Enum.SortOrder.LayoutOrder

-- Enhanced user section
local UserSection = Instance.new("Frame")
UserSection.Name = "UserSection"
UserSection.Size = UDim2.new(1, -16, 0, 100)
UserSection.Position = UDim2.new(0, 8, 1, -110)
UserSection.BackgroundColor3 = Theme.Surface
UserSection.BorderSizePixel = 0
UserSection.Parent = Sidebar

local UserCorner = Instance.new("UICorner", UserSection)
UserCorner.CornerRadius = UDim.new(0, 12)

local UserBorder = Instance.new("UIStroke", UserSection)
UserBorder.Color = Theme.BorderLight
UserBorder.Transparency = 0.7
UserBorder.Thickness = 1

-- Glass effect for user section - FIXED VERSION
local UserGradient = Instance.new("UIGradient", UserSection)
UserGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.GlassBlur),  -- Now dark
    ColorSequenceKeypoint.new(1, Theme.GlassBlur)
})
UserGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.88),
    NumberSequenceKeypoint.new(1, 0.92)
})
UserGradient.Rotation = 45

-- User avatar with modern styling
local UserAvatar = Instance.new("ImageLabel")
UserAvatar.Size = UDim2.new(0, 60, 0, 60)
UserAvatar.Position = UDim2.new(0, 16, 0.5, -30)
UserAvatar.BackgroundTransparency = 1
UserAvatar.ScaleType = Enum.ScaleType.Crop
UserAvatar.Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=420&height=420&format=png", LocalPlayer.UserId)
UserAvatar.Parent = UserSection

local AvatarCorner = Instance.new("UICorner", UserAvatar)
AvatarCorner.CornerRadius = UDim.new(0, 12)

-- Avatar border
local AvatarBorder = Instance.new("UIStroke", UserAvatar)
AvatarBorder.Color = Theme.Primary
AvatarBorder.Transparency = 0.3
AvatarBorder.Thickness = 2
registerAccent(AvatarBorder, "Color")

-- User info
local UserName = Instance.new("TextLabel")
UserName.Size = UDim2.new(1, -90, 0, 22)
UserName.Position = UDim2.new(0, 88, 0, 20)
UserName.BackgroundTransparency = 1
UserName.Font = Enum.Font.GothamSemibold
UserName.TextSize = 15
UserName.TextColor3 = Theme.Text
UserName.TextXAlignment = Enum.TextXAlignment.Left
UserName.Text = LocalPlayer.Name
UserName.Parent = UserSection

local UserStatus = Instance.new("TextLabel")
UserStatus.Size = UDim2.new(1, -90, 0, 18)
UserStatus.Position = UDim2.new(0, 88, 0, 42)
UserStatus.BackgroundTransparency = 1
UserStatus.Font = Enum.Font.Gotham
UserStatus.TextSize = 12
UserStatus.TextColor3 = Theme.TextMuted
UserStatus.TextXAlignment = Enum.TextXAlignment.Left
UserStatus.Text = "Press RightShift to toggle"
UserStatus.Parent = UserSection

-- Online indicator
local OnlineIndicator = Instance.new("Frame")
OnlineIndicator.Size = UDim2.new(0, 12, 0, 12)
OnlineIndicator.Position = UDim2.new(0, 64, 0, 4)
OnlineIndicator.BackgroundColor3 = Theme.Success
OnlineIndicator.BorderSizePixel = 0
OnlineIndicator.Parent = UserSection

local IndicatorCorner = Instance.new("UICorner", OnlineIndicator)
IndicatorCorner.CornerRadius = UDim.new(1, 0)

local IndicatorBorder = Instance.new("UIStroke", OnlineIndicator)
IndicatorBorder.Color = Theme.Background
IndicatorBorder.Thickness = 2

-- Content area - FIXED VERSION
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -240, 1, -50)
ContentArea.Position = UDim2.new(0, 240, 0, 50)
ContentArea.BackgroundColor3 = Theme.Background  -- FIXED: Explicit dark background
ContentArea.BackgroundTransparency = 0  -- FIXED: Make it opaque
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainWindow

-- Pages container - FIXED VERSION
local PagesContainer = Instance.new("Frame")
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -24, 1, -24)
PagesContainer.Position = UDim2.new(0, 12, 0, 12)
PagesContainer.BackgroundColor3 = Theme.Surface  -- FIXED: Dark background
PagesContainer.BackgroundTransparency = 0  -- FIXED: Opaque
PagesContainer.BorderSizePixel = 0
PagesContainer.Parent = ContentArea

-- Add corner and border to pages container
local PagesCorner = Instance.new("UICorner", PagesContainer)
PagesCorner.CornerRadius = UDim.new(0, 12)

local PagesBorder = Instance.new("UIStroke", PagesContainer)
PagesBorder.Color = Theme.Border
PagesBorder.Transparency = 0.7
PagesBorder.Thickness = 1

-- Internal storage
local Tabs = {}
local CurrentTab = nil

-- Enhanced tab button creation
local function createTabButton(name, icon)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(1, 0, 0, 44)
    TabButton.BackgroundColor3 = Theme.Surface
    TabButton.BackgroundTransparency = 0.3
    TabButton.BorderSizePixel = 0
    TabButton.AutoButtonColor = false
    TabButton.Text = ""
    TabButton.Parent = TabsSection
    
    local ButtonCorner = Instance.new("UICorner", TabButton)
    ButtonCorner.CornerRadius = UDim.new(0, 12)
    
    local ButtonBorder = Instance.new("UIStroke", TabButton)
    ButtonBorder.Color = Theme.Border
    ButtonBorder.Transparency = 0.8
    ButtonBorder.Thickness = 1
    
    -- Button content container
    local ButtonContent = Instance.new("Frame")
    ButtonContent.Size = UDim2.fromScale(1, 1)
    ButtonContent.BackgroundTransparency = 1
    ButtonContent.Parent = TabButton
    
    -- Icon
    local TabIcon = Instance.new("TextLabel")
    TabIcon.Size = UDim2.new(0, 20, 0, 20)
    TabIcon.Position = UDim2.new(0, 16, 0.5, -10)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Font = Enum.Font.GothamBold
    TabIcon.TextSize = 16
    TabIcon.TextColor3 = Theme.TextMuted
    TabIcon.Text = icon or "•"
    TabIcon.Parent = ButtonContent
    
    -- Tab name
    local TabName = Instance.new("TextLabel")
    TabName.Size = UDim2.new(1, -50, 1, 0)
    TabName.Position = UDim2.new(0, 44, 0, 0)
    TabName.BackgroundTransparency = 1
    TabName.Font = Enum.Font.GothamMedium
    TabName.TextSize = 14
    TabName.TextColor3 = Theme.TextMuted
    TabName.TextXAlignment = Enum.TextXAlignment.Left
    TabName.Text = name
    TabName.Parent = ButtonContent
    
    -- Hover effects
    TabButton.MouseEnter:Connect(function()
        if CurrentTab and CurrentTab.Button == TabButton then return end
        
        TweenService:Create(TabButton, TweenInfo.new(AnimationSpeed.Fast), {
            BackgroundTransparency = 0.1
        }):Play()
        
        TweenService:Create(TabName, TweenInfo.new(AnimationSpeed.Fast), {
            TextColor3 = Theme.Text
        }):Play()
        
        TweenService:Create(TabIcon, TweenInfo.new(AnimationSpeed.Fast), {
            TextColor3 = Theme.Primary
        }):Play()
    end)
    
    TabButton.MouseLeave:Connect(function()
        if CurrentTab and CurrentTab.Button == TabButton then return end
        
        TweenService:Create(TabButton, TweenInfo.new(AnimationSpeed.Fast), {
            BackgroundTransparency = 0.3
        }):Play()
        
        TweenService:Create(TabName, TweenInfo.new(AnimationSpeed.Fast), {
            TextColor3 = Theme.TextMuted
        }):Play()
        
        TweenService:Create(TabIcon, TweenInfo.new(AnimationSpeed.Fast), {
            TextColor3 = Theme.TextMuted
        }):Play()
    end)
    
    -- Click effects
    TabButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            playRipple(TabButton, input.Position)
        end
    end)
    
    return TabButton, TabIcon, TabName
end

-- Enhanced page creation - FIXED VERSION
local function createPage()
    local Page = Instance.new("ScrollingFrame")
    Page.Name = "Page"
    Page.Size = UDim2.fromScale(1, 1)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ScrollBarThickness = 6
    Page.ScrollingDirection = Enum.ScrollingDirection.Y
    Page.BackgroundColor3 = Theme.SurfaceVariant  -- FIXED: Dark background
    Page.BackgroundTransparency = 0  -- FIXED: Opaque
    Page.BorderSizePixel = 0
    Page.Visible = false
    Page.Parent = PagesContainer
    
    -- Add corner to page
    local PageCorner = Instance.new("UICorner", Page)
    PageCorner.CornerRadius = UDim.new(0, 8)
    
    -- Custom scrollbar styling
    Page.ScrollBarImageColor3 = Theme.Primary
    Page.ScrollBarImageTransparency = 0.3
    
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.FillDirection = Enum.FillDirection.Vertical
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 16)
    
    local PagePadding = Instance.new("UIPadding", Page)
    PagePadding.PaddingTop = UDim.new(0, 8)
    PagePadding.PaddingBottom = UDim.new(0, 24)
    
    -- Auto-resize canvas
    local function updateCanvas()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 32)
    end
    
    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    
    return Page
end

-- Tab switching with animations
local function switchToTab(name)
    local tabData = Tabs[name]
    if not tabData then return end
    
    -- Hide all pages with fade
    for _, data in pairs(Tabs) do
        if data.Page and data.Page.Visible then
            local fadeTween = TweenService:Create(data.Page, TweenInfo.new(0.15), {
                GroupTransparency = 1
            })
            fadeTween:Play()
            fadeTween.Completed:Connect(function()
                data.Page.Visible = false
                data.Page.GroupTransparency = 0
            end)
        end
        
        -- Reset button states
        if data.Button then
            TweenService:Create(data.Button, TweenInfo.new(AnimationSpeed.Fast), {
                BackgroundTransparency = 0.3
            }):Play()
            
            TweenService:Create(data.TabName, TweenInfo.new(AnimationSpeed.Fast), {
                TextColor3 = Theme.TextMuted
            }):Play()
            
            TweenService:Create(data.TabIcon, TweenInfo.new(AnimationSpeed.Fast), {
                TextColor3 = Theme.TextMuted
            }):Play()
        end
    end
    
    -- Show selected page
    task.wait(0.15)
    tabData.Page.Visible = true
    tabData.Page.GroupTransparency = 1
    
    local showTween = TweenService:Create(tabData.Page, TweenInfo.new(0.2), {
        GroupTransparency = 0
    })
    showTween:Play()
    
    -- Highlight active button
    TweenService:Create(tabData.Button, TweenInfo.new(AnimationSpeed.Fast), {
        BackgroundTransparency = 0.05
    }):Play()
    
    TweenService:Create(tabData.TabName, TweenInfo.new(AnimationSpeed.Fast), {
        TextColor3 = Theme.Text
    }):Play()
    
    TweenService:Create(tabData.TabIcon, TweenInfo.new(AnimationSpeed.Fast), {
        TextColor3 = Theme.Primary
    }):Play()
    
    CurrentTab = tabData
end

-- Enhanced section creation - COMPLETELY FIXED VERSION
local function createSection(page, title)
    local Section = Instance.new("Frame")
    Section.Name = "Section"
    Section.Size = UDim2.new(1, 0, 0, 0)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.BackgroundColor3 = Color3.fromRGB(32, 32, 38)  -- FIXED: Solid dark color
    Section.BackgroundTransparency = 0  -- FIXED: Completely opaque
    Section.BorderSizePixel = 0
    Section.Parent = page
    
    local SectionCorner = Instance.new("UICorner", Section)
    SectionCorner.CornerRadius = UDim.new(0, 14)
    
    local SectionBorder = Instance.new("UIStroke", Section)
    SectionBorder.Color = Theme.BorderLight
    SectionBorder.Transparency = 0.6
    SectionBorder.Thickness = 1
    
    -- REMOVED GLASS GRADIENT - NO MORE WHITE ISSUES
    
    -- Section header
    local SectionHeader = Instance.new("Frame")
    SectionHeader.Name = "Header"
    SectionHeader.Size = UDim2.new(1, 0, 0, 44)
    SectionHeader.BackgroundTransparency = 1
    SectionHeader.Parent = Section
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Size = UDim2.new(1, -24, 1, 0)
    SectionTitle.Position = UDim2.new(0, 20, 0, 0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextSize = 16
    SectionTitle.TextColor3 = Theme.Text
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Text = title or "Section"
    SectionTitle.Parent = SectionHeader
    
    -- Accent indicator
    local AccentBar = Instance.new("Frame")
    AccentBar.Name = "AccentBar"
    AccentBar.Size = UDim2.new(0, 4, 0, 20)
    AccentBar.Position = UDim2.new(0, 8, 0.5, -10)
    AccentBar.BackgroundColor3 = Theme.Primary
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = SectionHeader
    
    local AccentCorner = Instance.new("UICorner", AccentBar)
    AccentCorner.CornerRadius = UDim.new(0, 2)
    
    registerAccent(AccentBar, "BackgroundColor3")
    
    -- Section content - FIXED VERSION
    local SectionContent = Instance.new("Frame")
    SectionContent.Name = "Content"
    SectionContent.Size = UDim2.new(1, -32, 0, 0)
    SectionContent.Position = UDim2.new(0, 16, 0, 50)
    SectionContent.AutomaticSize = Enum.AutomaticSize.Y
    SectionContent.BackgroundColor3 = Color3.fromRGB(28, 28, 34)  -- FIXED: Slightly darker than section
    SectionContent.BackgroundTransparency = 0  -- FIXED: Opaque
    SectionContent.BorderSizePixel = 0
    SectionContent.Parent = Section
    
    -- Add corner to content
    local ContentCorner = Instance.new("UICorner", SectionContent)
    ContentCorner.CornerRadius = UDim.new(0, 10)
    
    local ContentLayout = Instance.new("UIListLayout", SectionContent)
    ContentLayout.FillDirection = Enum.FillDirection.Vertical
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 12)
    
    local ContentPadding = Instance.new("UIPadding", SectionContent)
    ContentPadding.PaddingTop = UDim.new(0, 12)
    ContentPadding.PaddingBottom = UDim2.new(0, 16)
    ContentPadding.PaddingLeft = UDim.new(0, 12)
    ContentPadding.PaddingRight = UDim.new(0, 12)
    
    return Section, SectionContent
end

-- Component creation helpers
local function createLabel(parent, text, size)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, size or 20)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Text = text
    Label.Parent = parent
    return Label
end

local function createBaseButton(parent, size)
    local Button = Instance.new("TextButton")
    Button.Size = size or UDim2.new(0, 100, 0, 32)
    Button.BackgroundColor3 = Theme.Surface
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.Font = Enum.Font.GothamMedium
    Button.TextSize = 13
    Button.TextColor3 = Theme.Text
    Button.Parent = parent
    
    local ButtonCorner = Instance.new("UICorner", Button)
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    
    local ButtonBorder = Instance.new("UIStroke", Button)
    ButtonBorder.Color = Theme.Border
    ButtonBorder.Transparency = 0.5
    ButtonBorder.Thickness = 1
    
    return Button
end

-- Enhanced Toggle Component
local function createToggle(parent, label, default, callback)
    callback = callback or noop
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 36)
    Container.BackgroundTransparency = 1
    Container.Parent = parent
    
    local Label = createLabel(Container, label, 20)
    Label.Position = UDim2.new(0, 0, 0.5, -10)
    
    -- Toggle switch
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 52, 0, 28)
    ToggleButton.Position = UDim2.new(1, -52, 0.5, -14)
    ToggleButton.BackgroundColor3 = default and Theme.Primary or Theme.Surface
    ToggleButton.BorderSizePixel = 0
    ToggleButton.AutoButtonColor = false
    ToggleButton.Text = ""
    ToggleButton.Parent = Container
    
    local ToggleCorner = Instance.new("UICorner", ToggleButton)
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    
    local ToggleBorder = Instance.new("UIStroke", ToggleButton)
    ToggleBorder.Color = default and Theme.Primary or Theme.Border
    ToggleBorder.Transparency = 0.3
    ToggleBorder.Thickness = 2
    
    -- Toggle knob
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.Position = UDim2.new(0, default and 28 or 4, 0.5, -10)
    Knob.BackgroundColor3 = Theme.Text
    Knob.BorderSizePixel = 0
    Knob.Parent = ToggleButton
    
    local KnobCorner = Instance.new("UICorner", Knob)
    KnobCorner.CornerRadius = UDim.new(1, 0)
    
    local KnobShadow = Instance.new("UIStroke", Knob)
    KnobShadow.Color = Theme.Shadow
    KnobShadow.Transparency = 0.8
    KnobShadow.Thickness = 1
    
    local state = default
    
    local function updateToggle(newState, animate)
        state = newState
        
        local tweenInfo = animate and TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out) or TweenInfo.new(0)
        
        if state then
            TweenService:Create(ToggleButton, tweenInfo, {BackgroundColor3 = Theme.Primary}):Play()
            TweenService:Create(ToggleBorder, tweenInfo, {Color = Theme.Primary}):Play()
            TweenService:Create(Knob, tweenInfo, {Position = UDim2.new(0, 28, 0.5, -10)}):Play()
        else
            TweenService:Create(ToggleButton, tweenInfo, {BackgroundColor3 = Theme.Surface}):Play()
            TweenService:Create(ToggleBorder, tweenInfo, {Color = Theme.Border}):Play()
            TweenService:Create(Knob, tweenInfo, {Position = UDim2.new(0, 4, 0.5, -10)}):Play()
        end
        
        if animate then
            callback(state)
        end
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        updateToggle(not state, true)
    end)
    
    -- Hover effects
    ToggleButton.MouseEnter:Connect(function()
        TweenService:Create(Knob, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(0, state and 26 or 3, 0.5, -11)
        }):Play()
    end)
    
    ToggleButton.MouseLeave:Connect(function()
        TweenService:Create(Knob, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, state and 28 or 4, 0.5, -10)
        }):Play()
    end)
    
    return {
        Set = function(_, value)
            updateToggle(value, false)
        end
    }
end

-- Enhanced Slider Component
local function createSlider(parent, label, min, max, default, callback)
    callback = callback or noop
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 50)
    Container.BackgroundTransparency = 1
    Container.Parent = parent
    
    local Label = createLabel(Container, label, 18)
    Label.Position = UDim2.new(0, 0, 0, 2)
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 60, 0, 18)
    ValueLabel.Position = UDim2.new(1, -60, 0, 2)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.TextSize = 13
    ValueLabel.TextColor3 = Theme.Primary
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Text = tostring(default)
    ValueLabel.Parent = Container
    
    registerAccent(ValueLabel, "TextColor3")
    
    -- Slider track
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 6)
    Track.Position = UDim2.new(0, 0, 1, -14)
    Track.BackgroundColor3 = Theme.Surface
    Track.BorderSizePixel = 0
    Track.Parent = Container
    
    local TrackCorner = Instance.new("UICorner", Track)
    TrackCorner.CornerRadius = UDim.new(0, 3)
    
    local TrackBorder = Instance.new("UIStroke", Track)
    TrackBorder.Color = Theme.Border
    TrackBorder.Transparency = 0.7
    TrackBorder.Thickness = 1
    
    -- Slider fill
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Primary
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    
    local FillCorner = Instance.new("UICorner", Fill)
    FillCorner.CornerRadius = UDim.new(0, 3)
    
    registerAccent(Fill, "BackgroundColor3")
    
    -- Slider handle
    local Handle = Instance.new("Frame")
    Handle.Size = UDim2.new(0, 18, 0, 18)
    Handle.Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9)
    Handle.BackgroundColor3 = Theme.Text
    Handle.BorderSizePixel = 0
    Handle.Parent = Track
    
    local HandleCorner = Instance.new("UICorner", Handle)
    HandleCorner.CornerRadius = UDim.new(1, 0)
    
    local HandleBorder = Instance.new("UIStroke", Handle)
    HandleBorder.Color = Theme.Primary
    HandleBorder.Transparency = 0.3
    HandleBorder.Thickness = 2
    
    registerAccent(HandleBorder, "Color")
    
    local dragging = false
    local currentValue = default
    
    local function setValue(value, animate)
        value = math.clamp(value, min, max)
        currentValue = value
        
        local ratio = (value - min) / (max - min)
        ValueLabel.Text = tostring(math.floor(value + 0.5))
        
        local tweenInfo = animate and TweenInfo.new(0.15) or TweenInfo.new(0)
        TweenService:Create(Fill, tweenInfo, {Size = UDim2.new(ratio, 0, 1, 0)}):Play()
        TweenService:Create(Handle, tweenInfo, {Position = UDim2.new(ratio, -9, 0.5, -9)}):Play()
        
        if animate then
            callback(value)
        end
    end
    
    local function updateFromInput(inputPos)
        local ratio = math.clamp((inputPos.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * ratio
        setValue(value, true)
    end
    
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromInput(input.Position)
            
            -- Visual feedback
            TweenService:Create(Handle, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 22, 0, 22),
                Position = UDim2.new((currentValue - min) / (max - min), -11, 0.5, -11)
            }):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromInput(input.Position)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            
            TweenService:Create(Handle, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new((currentValue - min) / (max - min), -9, 0.5, -9)
            }):Play()
        end
    end)
    
    setValue(default, false)
    
    return {
        Set = function(_, value)
            setValue(value, false)
        end
    }
end

-- Enhanced Dropdown Component
local function createDropdown(parent, label, options, default, callback)
    callback = callback or noop
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 42)
    Container.BackgroundTransparency = 1
    Container.Parent = parent
    
    local Label = createLabel(Container, label, 18)
    Label.Position = UDim2.new(0, 0, 0, 2)
    
    -- Main dropdown button
    local DropdownButton = createBaseButton(Container, UDim2.new(0, 150, 0, 32))
    DropdownButton.Position = UDim2.new(1, -150, 1, -32)
    DropdownButton.Text = default
    DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    
    local ButtonPadding = Instance.new("UIPadding", DropdownButton)
    ButtonPadding.PaddingLeft = UDim.new(0, 12)
    ButtonPadding.PaddingRight = UDim.new(0, 32)
    
    -- Dropdown arrow
    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 20, 0, 20)
    Arrow.Position = UDim2.new(1, -26, 0.5, -10)
    Arrow.BackgroundTransparency = 1
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 12
    Arrow.TextColor3 = Theme.TextMuted
    Arrow.Text = "▼"
    Arrow.Parent = DropdownButton
    
    -- Dropdown menu
    local DropdownMenu = Instance.new("Frame")
    DropdownMenu.Size = UDim2.new(0, 150, 0, math.min(#options * 36 + 8, 200))
    DropdownMenu.Position = UDim2.new(1, -150, 1, -28)
    DropdownMenu.BackgroundColor3 = Theme.Surface
    DropdownMenu.BorderSizePixel = 0
    DropdownMenu.Visible = false
    DropdownMenu.Parent = Container
    DropdownMenu.ZIndex = 100
    
    local MenuCorner = Instance.new("UICorner", DropdownMenu)
    MenuCorner.CornerRadius = UDim.new(0, 10)
    
    local MenuBorder = Instance.new("UIStroke", DropdownMenu)
    MenuBorder.Color = Theme.BorderLight
    MenuBorder.Transparency = 0.4
    MenuBorder.Thickness = 1
    
    -- Menu shadow
    local MenuShadow = Instance.new("Frame")
    MenuShadow.Size = UDim2.new(1, 8, 1, 8)
    MenuShadow.Position = UDim2.new(0, -4, 0, 2)
    MenuShadow.BackgroundColor3 = Theme.Shadow
    MenuShadow.BackgroundTransparency = 0.8
    MenuShadow.BorderSizePixel = 0
    MenuShadow.Parent = DropdownMenu
    MenuShadow.ZIndex = DropdownMenu.ZIndex - 1
    
    local ShadowCorner = Instance.new("UICorner", MenuShadow)
    ShadowCorner.CornerRadius = UDim.new(0, 12)
    
    -- Scrolling frame for options
    local OptionsFrame = Instance.new("ScrollingFrame")
    OptionsFrame.Size = UDim2.new(1, -8, 1, -8)
    OptionsFrame.Position = UDim2.new(0, 4, 0, 4)
    OptionsFrame.BackgroundTransparency = 1
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ScrollBarThickness = 4
    OptionsFrame.ScrollBarImageColor3 = Theme.Primary
    OptionsFrame.ScrollBarImageTransparency = 0.3
    OptionsFrame.Parent = DropdownMenu
    
    local OptionsLayout = Instance.new("UIListLayout", OptionsFrame)
    OptionsLayout.FillDirection = Enum.FillDirection.Vertical
OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    OptionsLayout.Padding = UDim.new(0, 2)
    
    -- Create option buttons
    local currentValue = default
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, -8, 0, 32)
        OptionButton.BackgroundColor3 = Theme.Surface
        OptionButton.BackgroundTransparency = 0.3
        OptionButton.BorderSizePixel = 0
        OptionButton.AutoButtonColor = false
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 13
        OptionButton.TextColor3 = Theme.Text
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.Text = option
        OptionButton.Parent = OptionsFrame
        
        local OptionCorner = Instance.new("UICorner", OptionButton)
        OptionCorner.CornerRadius = UDim.new(0, 6)
        
        local OptionPadding = Instance.new("UIPadding", OptionButton)
        OptionPadding.PaddingLeft = UDim.new(0, 12)
        
        -- Option hover effects
        OptionButton.MouseEnter:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.1
            }):Play()
        end)
        
        OptionButton.MouseLeave:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.3
            }):Play()
        end)
        
        OptionButton.MouseButton1Click:Connect(function()
            currentValue = option
            DropdownButton.Text = option
            DropdownMenu.Visible = false
            
            -- Animate arrow
            TweenService:Create(Arrow, TweenInfo.new(0.2), {
                Rotation = 0
            }):Play()
            
            callback(option)
        end)
    end
    
    -- Update canvas size
    OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, OptionsLayout.AbsoluteContentSize.Y + 8)
    OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, OptionsLayout.AbsoluteContentSize.Y + 8)
    end)
    
    local menuOpen = false
    
    DropdownButton.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        DropdownMenu.Visible = menuOpen
        
        -- Animate arrow
        TweenService:Create(Arrow, TweenInfo.new(0.2), {
            Rotation = menuOpen and 180 or 0
        }):Play()
        
        if menuOpen then
            -- Scale in animation
            DropdownMenu.Size = UDim2.new(0, 150, 0, 0)
            TweenService:Create(DropdownMenu, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 150, 0, math.min(#options * 36 + 8, 200))
            }):Play()
        end
    end)
    
    return {
        Set = function(_, value)
            if table.find(options, value) then
                currentValue = value
                DropdownButton.Text = value
            end
        end
    }
end

-- Enhanced Button Component
local function createButton(parent, text, callback)
    callback = callback or noop
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.BackgroundTransparency = 1
    Container.Parent = parent
    
    local Button = createBaseButton(Container, UDim2.new(0, 120, 0, 36))
    Button.Position = UDim2.new(0.5, -60, 0.5, -18)
    Button.Text = text
    Button.BackgroundColor3 = Theme.Primary
    Button.TextColor3 = Theme.Text
    
    registerAccent(Button, "BackgroundColor3")
    
    -- Button gradient
    local ButtonGradient = Instance.new("UIGradient", Button)
    ButtonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Primary),
        ColorSequenceKeypoint.new(1, Theme.PrimaryDim)
    })
    ButtonGradient.Rotation = 45
    
    -- Hover effects
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 126, 0, 38)
        }):Play()
        
        TweenService:Create(ButtonGradient, TweenInfo.new(0.2), {
            Rotation = 90
        }):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 120, 0, 36)
        }):Play()
        
        TweenService:Create(ButtonGradient, TweenInfo.new(0.2), {
            Rotation = 45
        }):Play()
    end)
    
    Button.MouseButton1Click:Connect(function()
        playRipple(Button, Vector2.new(Button.AbsoluteSize.X/2, Button.AbsoluteSize.Y/2))
        callback()
    end)
    
    return Button
end

-- Enhanced Input/TextBox Component
local function createInput(parent, label, placeholder, callback)
    callback = callback or noop
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 50)
    Container.BackgroundTransparency = 1
    Container.Parent = parent
    
    local Label = createLabel(Container, label, 18)
    Label.Position = UDim2.new(0, 0, 0, 2)
    
    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, 0, 0, 32)
    InputFrame.Position = UDim2.new(0, 0, 1, -32)
    InputFrame.BackgroundColor3 = Theme.Surface
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = Container
    
    local InputCorner = Instance.new("UICorner", InputFrame)
    InputCorner.CornerRadius = UDim.new(0, 8)
    
    local InputBorder = Instance.new("UIStroke", InputFrame)
    InputBorder.Color = Theme.Border
    InputBorder.Transparency = 0.5
    InputBorder.Thickness = 1
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -16, 1, 0)
    TextBox.Position = UDim2.new(0, 8, 0, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 13
    TextBox.TextColor3 = Theme.Text
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.PlaceholderText = placeholder or ""
    TextBox.PlaceholderColor3 = Theme.TextMuted
    TextBox.Text = ""
    TextBox.Parent = InputFrame
    
    -- Focus effects
    TextBox.Focused:Connect(function()
        TweenService:Create(InputBorder, TweenInfo.new(0.2), {
            Color = Theme.Primary,
            Transparency = 0.2
        }):Play()
    end)
    
    TextBox.FocusLost:Connect(function()
        TweenService:Create(InputBorder, TweenInfo.new(0.2), {
            Color = Theme.Border,
            Transparency = 0.5
        }):Play()
        
        callback(TextBox.Text)
    end)
    
    return {
        Set = function(_, text)
            TextBox.Text = text
        end,
        Get = function(_)
            return TextBox.Text
        end
    }
end

-- Toggle visibility functionality
local isVisible = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        isVisible = not isVisible
        
        local targetTransparency = isVisible and 0 or 1
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        
        TweenService:Create(MainWindow, tweenInfo, {
            GroupTransparency = targetTransparency
        }):Play()
        
        if isVisible then
            MainWindow.Visible = true
        else
            task.wait(0.3)
            MainWindow.Visible = false
        end
    end
end)

-- Main UI API
function UI:CreateWindow(title)
    WindowTitle.Text = title or "Modern UI"
    
    local Window = {}
    Window.Tabs = {}
    
    function Window:CreateTab(name, icon)
        local tabButton, tabIcon, tabName = createTabButton(name, icon)
        local page = createPage()
        
        local Tab = {
            Button = tabButton,
            TabIcon = tabIcon,
            TabName = tabName,
            Page = page,
            Sections = {}
        }
        
        Tabs[name] = Tab
        Window.Tabs[name] = Tab
        
        -- Auto-select first tab
        if not CurrentTab then
            switchToTab(name)
        end
        
        tabButton.MouseButton1Click:Connect(function()
            switchToTab(name)
        end)
        
        function Tab:CreateSection(title)
            local section, sectionContent = createSection(page, title)
            
            local Section = {
                Frame = section,
                Content = sectionContent
            }
            
            table.insert(Tab.Sections, Section)
            
            function Section:AddToggle(label, default, callback)
                return createToggle(sectionContent, label, default, callback)
            end
            
            function Section:AddSlider(label, min, max, default, callback)
                return createSlider(sectionContent, label, min, max, default, callback)
            end
            
            function Section:AddDropdown(label, options, default, callback)
                return createDropdown(sectionContent, label, options, default, callback)
            end
            
            function Section:AddButton(text, callback)
                return createButton(sectionContent, text, callback)
            end
            
            function Section:AddInput(label, placeholder, callback)
                return createInput(sectionContent, label, placeholder, callback)
            end
            
            function Section:AddLabel(text)
                return createLabel(sectionContent, text, 24)
            end
            
            return Section
        end
        
        return Tab
    end
    
    -- Theme functions
    function Window:SetAccent(color)
        applyAccent(color, "Primary")
    end
    
    function Window:SetTheme(themeName)
        if themeName == "dark" then
            -- Already dark theme
        elseif themeName == "blue" then
            Window:SetAccent(Color3.fromRGB(59, 130, 246))
        elseif themeName == "purple" then
            Window:SetAccent(Color3.fromRGB(147, 51, 234))
        elseif themeName == "green" then
            Window:SetAccent(Color3.fromRGB(34, 197, 94))
        elseif themeName == "red" then
            Window:SetAccent(Color3.fromRGB(239, 68, 68))
        end
    end
    
    return Window
end

-- Notification system
function UI:Notify(title, message, duration)
    duration = duration or 3
    
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, 320, 0, 80)
    Notification.Position = UDim2.new(1, -340, 1, -100)
    Notification.BackgroundColor3 = Theme.Surface
    Notification.BorderSizePixel = 0
    Notification.Parent = ScreenGui
    
    local NotifCorner = Instance.new("UICorner", Notification)
    NotifCorner.CornerRadius = UDim.new(0, 12)
    
    local NotifBorder = Instance.new("UIStroke", Notification)
    NotifBorder.Color = Theme.BorderLight
    NotifBorder.Transparency = 0.4
    NotifBorder.Thickness = 1
    
    -- Notification content
    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Size = UDim2.new(1, -20, 0, 24)
    NotifTitle.Position = UDim2.new(0, 16, 0, 12)
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextSize = 14
    NotifTitle.TextColor3 = Theme.Text
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.Text = title
    NotifTitle.Parent = Notification
    
    local NotifMessage = Instance.new("TextLabel")
    NotifMessage.Size = UDim2.new(1, -20, 0, 32)
    NotifMessage.Position = UDim2.new(0, 16, 0, 36)
    NotifMessage.BackgroundTransparency = 1
    NotifMessage.Font = Enum.Font.Gotham
    NotifMessage.TextSize = 12
    NotifMessage.TextColor3 = Theme.TextMuted
    NotifMessage.TextXAlignment = Enum.TextXAlignment.Left
    NotifMessage.TextYAlignment = Enum.TextYAlignment.Top
    NotifMessage.TextWrapped = true
    NotifMessage.Text = message
    NotifMessage.Parent = Notification
    
    -- Slide in animation
    Notification.Position = UDim2.new(1, 20, 1, -100)
    local slideIn = TweenService:Create(
        Notification,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -340, 1, -100)}
    )
    slideIn:Play()
    
    -- Auto-dismiss
    task.spawn(function()
        task.wait(duration)
        
        local slideOut = TweenService:Create(
            Notification,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 20, 1, -100)}
        )
        slideOut:Play()
        
        slideOut.Completed:Wait()
        Notification:Destroy()
    end)
end

return UI
