-- lib_modern.lua — Enhanced SketchUI with modern design, animations, and improved UX
-- Modern glassmorphism design, smooth animations, better interactions
-- RightShift toggles visibility.
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

-- Modern Theme with glassmorphism and vibrant accents
local Theme = {
    -- Main colors
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
    
    -- Effects
    Shadow = Color3.fromRGB(0, 0, 0),
    Glow = Color3.fromRGB(99, 102, 241),
    GlassBlur = Color3.fromRGB(30, 30, 35),
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
ScreenGui.Name = "Vetrion.vip"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)

-- REMOVED THE PROBLEMATIC DEBUG CODE THAT WAS CAUSING WHITE BACKGROUNDS

-- PARTICLE EFFECTS & DIM OVERLAY SYSTEM
-- 1. CREATE DIM OVERLAY
local DimOverlay = Instance.new("Frame")
DimOverlay.Name = "DimOverlay"
DimOverlay.Size = UDim2.fromScale(1, 1)
DimOverlay.Position = UDim2.fromScale(0, 0)
DimOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DimOverlay.BackgroundTransparency = 1  -- Start invisible
DimOverlay.BorderSizePixel = 0
DimOverlay.ZIndex = 1  -- Behind the menu
DimOverlay.Visible = false
DimOverlay.Parent = ScreenGui

-- 2. CREATE PARTICLE SYSTEM CONTAINER
local ParticleContainer = Instance.new("Frame")
ParticleContainer.Name = "ParticleContainer"
ParticleContainer.Size = UDim2.fromScale(1, 1)
ParticleContainer.Position = UDim2.fromScale(0, 0)
ParticleContainer.BackgroundTransparency = 1
ParticleContainer.BorderSizePixel = 0
ParticleContainer.ZIndex = 2  -- Above dim overlay, below menu
ParticleContainer.Visible = false
ParticleContainer.Parent = ScreenGui

-- 3. PARTICLE CREATION FUNCTION
local particles = {}
local particleCount = 0
local maxParticles = 50

local function createParticle()
    if particleCount >= maxParticles then return end
    
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
    particle.Position = UDim2.new(
        math.random(0, 100) / 100, 0,
        math.random(0, 100) / 100, 0
    )
    particle.BackgroundColor3 = Color3.fromRGB(
        math.random(99, 255),   -- Random blue/purple/white
        math.random(102, 200),
        math.random(241, 255)
    )
    particle.BackgroundTransparency = math.random(30, 70) / 100
    particle.BorderSizePixel = 0
    particle.ZIndex = 3
    particle.Parent = ParticleContainer
    
    -- Make particle round
    local corner = Instance.new("UICorner", particle)
    corner.CornerRadius = UDim.new(1, 0)
    
    -- Add glow effect
    local glow = Instance.new("UIStroke", particle)
    glow.Color = particle.BackgroundColor3
    glow.Transparency = 0.7
    glow.Thickness = 1
    
    table.insert(particles, particle)
    particleCount = particleCount + 1
    
    -- Animate particle
    local moveTime = math.random(30, 60) / 10  -- 3-6 seconds
    local endX = math.random(-20, 120) / 100
    local endY = math.random(-20, 120) / 100
    
    -- Floating movement
    local moveTween = TweenService:Create(
        particle,
        TweenInfo.new(moveTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {
            Position = UDim2.new(endX, 0, endY, 0),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0)
        }
    )
    
    -- Pulse effect
    local pulseTween = TweenService:Create(
        particle,
        TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {
            BackgroundTransparency = particle.BackgroundTransparency + 0.3
        }
    )
    
    moveTween:Play()
    pulseTween:Play()
    
    -- Cleanup when animation completes
    moveTween.Completed:Connect(function()
        pulseTween:Cancel()
        particle:Destroy()
        for i, p in ipairs(particles) do
            if p == particle then
                table.remove(particles, i)
                particleCount = particleCount - 1
                break
            end
        end
    end)
end

-- 4. PARTICLE SPAWNER SYSTEM
local particleConnection
local function startParticles()
    if particleConnection then return end
    
    ParticleContainer.Visible = true
    particleConnection = RunService.Heartbeat:Connect(function()
        if math.random(1, 10) == 1 then  -- 10% chance each frame
            createParticle()
        end
    end)
end

local function stopParticles()
    if particleConnection then
        particleConnection:Disconnect()
        particleConnection = nil
    end
    
    -- Fade out existing particles
    for _, particle in ipairs(particles) do
        if particle and particle.Parent then
            TweenService:Create(
                particle,
                TweenInfo.new(0.5),
                {BackgroundTransparency = 1}
            ):Play()
        end
    end
    
    task.wait(1)
    ParticleContainer.Visible = false
    
    -- Clear particles array
    for i = #particles, 1, -1 do
        if particles[i] and particles[i].Parent then
            particles[i]:Destroy()
        end
        table.remove(particles, i)
    end
    particleCount = 0
end

-- 5. MENU SHOW/HIDE EFFECTS FUNCTIONS
local function showMenuEffects()
    -- Show dim overlay
    DimOverlay.Visible = true
    DimOverlay.BackgroundTransparency = 1
    
    local dimTween = TweenService:Create(
        DimOverlay,
        TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0.6}  -- 40% dim
    )
    dimTween:Play()
    
    -- Start particles
    startParticles()
end

local function hideMenuEffects()
    -- Hide dim overlay
    local dimTween = TweenService:Create(
        DimOverlay,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {BackgroundTransparency = 1}
    )
    dimTween:Play()
    
    dimTween.Completed:Connect(function()
        DimOverlay.Visible = false
    end)
    
    -- Stop particles
    stopParticles()
    
    -- Remove blur effect
    local blurEffect = DimOverlay:GetAttribute("BlurEffect")
    if blurEffect and blurEffect.Parent then
        local blurTween = TweenService:Create(
            blurEffect,
            TweenInfo.new(0.3),
            {Size = 0}
        )
        blurTween:Play()
        
        blurTween.Completed:Connect(function()
            blurEffect:Destroy()
        end)
    end
end

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

-- Glass effect for title bar
local TitleGradient = Instance.new("UIGradient", TitleBar)
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.GlassBlur),
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

-- Glass effect for user section
local UserGradient = Instance.new("UIGradient", UserSection)
UserGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.GlassBlur),
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

-- Content area
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -240, 1, -50)
ContentArea.Position = UDim2.new(0, 240, 0, 50)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainWindow

-- Pages container
local PagesContainer = Instance.new("Frame")
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -24, 1, -24)
PagesContainer.Position = UDim2.new(0, 12, 0, 12)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = ContentArea

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

-- Enhanced page creation
local function createPage()
    local Page = Instance.new("ScrollingFrame")
    Page.Name = "Page"
    Page.Size = UDim2.fromScale(1, 1)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ScrollBarThickness = 6
    Page.ScrollingDirection = Enum.ScrollingDirection.Y
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.Visible = false
    Page.Parent = PagesContainer
    
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
                BackgroundTransparency = 0
            })
            fadeTween:Play()
            fadeTween.Completed:Connect(function()
                data.Page.Visible = false
                data.Page.BackgroundTransparency = 0
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
    tabData.Page.BackgroundTransparency = 0
    
    local showTween = TweenService:Create(tabData.Page, TweenInfo.new(0.2), {
        BackgroundTransparency = 0
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

-- FIXED SECTION CREATION - This was the main issue causing white backgrounds
local function createSection(page, title)
    local Section = Instance.new("Frame")
    Section.Name = "Section"
    Section.Size = UDim2.new(1, 0, 0, 0)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.BackgroundColor3 = Theme.Surface  -- Using proper theme color
    Section.BackgroundTransparency = 0.95  -- Much higher transparency to avoid white appearance
    Section.BorderSizePixel = 0
    Section.Parent = page
    
    local SectionCorner = Instance.new("UICorner", Section)
    SectionCorner.CornerRadius = UDim.new(0, 14)
    
    local SectionBorder = Instance.new("UIStroke", Section)
    SectionBorder.Color = Theme.BorderLight
    SectionBorder.Transparency = 0.7  -- Higher transparency
    SectionBorder.Thickness = 1
    
    -- REMOVED problematic glass gradient that was causing issues
    -- Instead using simple dark background with proper transparency
    
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
    
    -- Section content
    local SectionContent = Instance.new("Frame")
    SectionContent.Name = "Content"
    SectionContent.Size = UDim2.new(1, -32, 0, 0)
    SectionContent.Position = UDim2.new(0, 16, 0, 50)
    SectionContent.AutomaticSize = Enum.AutomaticSize.Y
    SectionContent.BackgroundTransparency = 1
    SectionContent.Parent = Section
    
    local ContentLayout = Instance.new("UIListLayout", SectionContent)
    ContentLayout.FillDirection = Enum.FillDirection.Vertical
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 12)
    
    local ContentPadding = Instance.new("UIPadding", SectionContent)
    ContentPadding.PaddingBottom = UDim.new(0, 16)
    
    return Section, SectionContent
end
