-- lib_full.lua — SketchUI (Complete: Tabs, Sections, Toggle, Slider, Dropdown, Keybind, ColorPicker)
-- Modern dark + glow/shadow accents, draggable, sidebar with logo + user,
-- Tabs: Legitbot, Visuals, Misc, Settings created by default (empty sections).
-- RightShift toggles visibility.
-- API:
--   local UI = loadfile("lib_full.lua")()
--   UI:CreateWindow("Title")
--   s:AddToggle("Enabled", false, function(v) print(v) end)
--   s:AddSlider("FOV", 20, 400, 120, function(v) print(v) end)
--   s:AddDropdown("AimPart", {"Head","HumanoidRootPart"}, "Head", function(v) print(v) end)
--   s:AddKeybind("Toggle UI", Enum.KeyCode.RightShift, function(k) print(k) end)
--   s:AddColorPicker("Accent", Color3.fromRGB(255,0,80), function(c) UI:SetAccent(c) end)

local UI = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer


-- Theme (modifiable)
local Theme = {
    Bg = Color3.fromRGB(18, 18, 18),
    Panel = Color3.fromRGB(28, 28, 30),
    Sidebar = Color3.fromRGB(14, 14, 16),
    Text = Color3.fromRGB(230, 230, 230),
    Muted = Color3.fromRGB(170, 170, 170),
    Accent = Color3.fromRGB(255, 0, 80),
    AccentDim = Color3.fromRGB(70, 10, 30),
    Stroke = Color3.fromRGB(40, 40, 45),
    Glow = Color3.fromRGB(255, 0, 120),
}

local function noop() end

-- Accent registry (for dynamic accent change)
local AccentRegistry = {}
local function registerAccent(inst, prop)
    table.insert(AccentRegistry, {inst = inst, prop = prop})
    inst[prop] = Theme.Accent
end
local function applyAccent(color)
    for _, it in ipairs(AccentRegistry) do
        local inst = it.inst
        local prop = it.prop
        if inst and inst.Parent then
            pcall(function() inst[prop] = color end)
        end
    end
end

-- Root ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Vetrion.vip"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
-- try to parent to gethui if available for exploits; otherwise CoreGui
pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)

-- Main window
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 920, 0, 490)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Main.Visible = false -- start hidden

-- Logo (centered image as "loading screen")
local Logo = Instance.new("ImageLabel")
Logo.AnchorPoint = Vector2.new(0.5, 0.5)
Logo.Position = UDim2.fromScale(0.5, 0.5)
Logo.Size = UDim2.new(0, 120, 0, 120)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://133603881881804" -- your picture
Logo.ZIndex = 9999
Logo.Parent = ScreenGui

-- Whoosh Sound
local Whoosh = Instance.new("Sound")
Whoosh.SoundId = "rbxassetid://624706518"
Whoosh.Volume = 1
Whoosh.Parent = Logo

-- Tweens
local tweenIn = TweenService:Create(
    Logo,
    TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {Size = UDim2.new(0, 140, 0, 140)}
)
local tweenOut = TweenService:Create(
    Logo,
    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    {ImageTransparency = 1}
)

-- Sequence
task.spawn(function()
    Whoosh:Play()
    tweenIn:Play()
    tweenIn.Completed:Wait()
    task.wait(2.0)
    tweenOut:Play()
    tweenOut.Completed:Wait()
    Logo:Destroy()

    -- ⏳ wait a bit before Main shows
    task.wait(2.0) -- adjust delay time here

    Main.Visible = true
end)


local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Color = Theme.Stroke
MainStroke.Thickness = 1

-- subtle background gradient
local MainGradient = Instance.new("UIGradient", Main)
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16,16,16))
}
MainGradient.Rotation = 90

-- Title bar (dragging)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 46)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Theme.Panel
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -220, 1, 0)
TitleText.Position = UDim2.new(0, 18, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 18
TitleText.TextColor3 = Theme.Text
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Text = "Vetrion.vip"
TitleText.Parent = TitleBar

-- small subtitle
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 180, 1, 0)
Subtitle.Position = UDim2.new(1, -200, 0, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 12
Subtitle.TextColor3 = Theme.Muted
Subtitle.TextXAlignment = Enum.TextXAlignment.Right
Subtitle.Text = "Version · Debug · 1.0"
Subtitle.Parent = TitleBar

local TitleUnderline = Instance.new("Frame")
TitleUnderline.Size = UDim2.new(1, 0, 0, 1)
TitleUnderline.Position = UDim2.new(0, 0, 1, -1)
TitleUnderline.BackgroundColor3 = Theme.Stroke
TitleUnderline.BorderSizePixel = 0
TitleUnderline.Parent = TitleBar

-- Draggable implementation (manual so we don't rely on Draggable)
do
    local dragging = false
    local dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 220, 1, -46)
Sidebar.Position = UDim2.new(0, 0, 0, 46)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)
local SideStroke = Instance.new("UIStroke", Sidebar)
SideStroke.Color = Theme.Stroke
SideStroke.Thickness = 1

-- Logo area (top)
local LogoArea = Instance.new("Frame")
LogoArea.Name = "LogoArea"
LogoArea.Size = UDim2.new(1, 0, 0, 110)
LogoArea.BackgroundTransparency = 1
LogoArea.Parent = Sidebar

local LogoImg = Instance.new("ImageLabel")
LogoImg.Size = UDim2.new(0, 84, 0, 84)
LogoImg.Position = UDim2.new(0.5, 0, 0.5, -6)
LogoImg.AnchorPoint = Vector2.new(0.5, 0.5)
LogoImg.BackgroundTransparency = 1
LogoImg.Image = "rbxassetid://124433474541732" -- your logo asset
LogoImg.Parent = LogoArea
Instance.new("UICorner", LogoImg).CornerRadius = UDim.new(0, 12)

-- Glow behind logo (subtle)
local LogoGlow = Instance.new("Frame")
LogoGlow.Size = UDim2.new(0, 98, 0, 98)
LogoGlow.Position = UDim2.new(0.5, 0, 0.5, -6)
LogoGlow.AnchorPoint = Vector2.new(0.5, 0.5)
LogoGlow.BackgroundColor3 = Theme.Glow
LogoGlow.BackgroundTransparency = 0.9
LogoGlow.Parent = LogoArea
LogoGlow.ZIndex = LogoImg.ZIndex - 1
Instance.new("UICorner", LogoGlow).CornerRadius = UDim.new(0, 48)

-- Tabs container (middle)
local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Size = UDim2.new(1, -24, 1, -260)
TabsFrame.Position = UDim2.new(0, 12, 0, 120)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = Sidebar

local TabsLayout = Instance.new("UIListLayout", TabsFrame)
TabsLayout.FillDirection = Enum.FillDirection.Vertical
TabsLayout.Padding = UDim.new(0, 8)
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder

local TabsPadding = Instance.new("UIPadding", TabsFrame)
TabsPadding.PaddingTop = UDim.new(0, 6)
TabsPadding.PaddingBottom = UDim.new(0, 6)

-- User block (bottom-left)
local UserBlock = Instance.new("Frame")
UserBlock.Name = "UserBlock"
UserBlock.Size = UDim2.new(1, -20, 0, 120)
UserBlock.Position = UDim2.new(0, 10, 1, -130)
UserBlock.BackgroundColor3 = Theme.Panel
UserBlock.BorderSizePixel = 0
UserBlock.Parent = Sidebar
Instance.new("UICorner", UserBlock).CornerRadius = UDim.new(0, 10)
local UserStroke = Instance.new("UIStroke", UserBlock)
UserStroke.Color = Theme.Stroke
UserStroke.Thickness = 1

local UserAvatar = Instance.new("ImageLabel")
UserAvatar.Size = UDim2.new(0, 64, 0, 64)
UserAvatar.Position = UDim2.new(0, 12, 0, 12)
UserAvatar.BackgroundTransparency = 1
UserAvatar.ScaleType = Enum.ScaleType.Crop
UserAvatar.Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=420&height=420&format=png", LocalPlayer.UserId)
UserAvatar.Parent = UserBlock
Instance.new("UICorner", UserAvatar).CornerRadius = UDim.new(0, 8)

local UserNameLabel = Instance.new("TextLabel")
UserNameLabel.Size = UDim2.new(1, -96, 0, 28)
UserNameLabel.Position = UDim2.new(0, 88, 0, 18)
UserNameLabel.BackgroundTransparency = 1
UserNameLabel.Font = Enum.Font.GothamSemibold
UserNameLabel.TextSize = 14
UserNameLabel.TextColor3 = Theme.Text
UserNameLabel.TextXAlignment = Enum.TextXAlignment.Left
UserNameLabel.Text = LocalPlayer.Name
UserNameLabel.Parent = UserBlock

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(1, -96, 0, 18)
SubLabel.Position = UDim2.new(0, 88, 0, 46)
SubLabel.BackgroundTransparency = 1
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextSize = 12
SubLabel.TextColor3 = Theme.Muted
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Text = "RightShift to toggle"
SubLabel.Parent = UserBlock

-- Right pane (content)
local RightPane = Instance.new("Frame")
RightPane.Name = "RightPane"
RightPane.Size = UDim2.new(1, -220, 1, -46)
RightPane.Position = UDim2.new(0, 220, 0, 46)
RightPane.BackgroundTransparency = 1
RightPane.Parent = Main

-- Pages container (scrollable pages per tab)
local Pages = Instance.new("Frame")
Pages.Name = "Pages"
Pages.Size = UDim2.new(1, -20, 1, -20)
Pages.Position = UDim2.new(0, 10, 0, 10)
Pages.BackgroundTransparency = 1
Pages.Parent = RightPane

-- internal storage
local Tabs = {} -- name => { Button = , Page = , TabObject = {} }
local CurrentTab = nil

-- helper: create tab button visual (returns button)
local function createTabButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = text
    btn.TextColor3 = Theme.Muted
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = TabsFrame

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Theme.Stroke
    stroke.Thickness = 1

    -- hover
    btn.MouseEnter:Connect(function()
        if CurrentTab and CurrentTab.Button == btn then return end
        TweenService:Create(btn, TweenInfo.new(0.12), {TextColor3 = Theme.Text}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if CurrentTab and CurrentTab.Button == btn then return end
        TweenService:Create(btn, TweenInfo.new(0.12), {TextColor3 = Theme.Muted}):Play()
    end)

    return btn
end

-- helper: create a page (scrolling) for tab content
local function createPage()
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.ScrollBarThickness = 8
    sf.ScrollingDirection = Enum.ScrollingDirection.Y
    sf.BackgroundTransparency = 1
    sf.Visible = false
    sf.Parent = Pages

    local layout = Instance.new("UIListLayout", sf)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)

    sf.ChildAdded:Connect(function()
        task.defer(function()
            sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)
    end)
    return sf
end

-- switch to tab by name
local function switchTab(name)
    local data = Tabs[name]
    if not data then return end
    -- hide all pages
    for k, v in pairs(Tabs) do
        if v.Page then v.Page.Visible = false end
        if v.Button then
            v.Button.TextColor3 = Theme.Muted
            v.Button.BackgroundColor3 = Theme.Panel
        end
    end
    data.Page.Visible = true
    data.Button.TextColor3 = Theme.Text
    -- accent highlight tween
    TweenService:Create(data.Button, TweenInfo.new(0.12), {BackgroundColor3 = Theme.AccentDim}):Play()
    CurrentTab = data
end

-- Section creator for page
local function createSection(page, title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, 0, 0, 200)
    Section.BackgroundColor3 = Theme.Panel
    Section.BorderSizePixel = 0
    Section.Parent = page

    local corner = Instance.new("UICorner", Section)
    corner.CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", Section)
    stroke.Color = Theme.Stroke
    stroke.Thickness = 1

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 26)
    titleLabel.Position = UDim2.new(0, 12, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title or ""
    titleLabel.Parent = Section

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 36, 0, 3)
    accentBar.Position = UDim2.new(0, 12, 0, 38)
    accentBar.BackgroundColor3 = Theme.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = Section
    registerAccent(accentBar, "BackgroundColor3")

    local Body = Instance.new("Frame")
    Body.Name = "Body"
    Body.Size = UDim2.new(1, -24, 1, -64)
    Body.Position = UDim2.new(0, 12, 0, 50)
    Body.BackgroundTransparency = 1
    Body.Parent = Section

    local layout = Instance.new("UIListLayout", Body)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    -- small padding
    local pad = Instance.new("UIPadding", Body)
    pad.PaddingTop = UDim.new(0, 4)

    return Section, Body
end

-- small label helper
local function newLabel(parent, text, size)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = size or 14
    lbl.TextColor3 = Theme.Text
    lbl.Text = text or ""
    lbl.Size = UDim2.new(1, 0, 0, size and math.max(22, size + 6) or 20)
    lbl.Parent = parent
    return lbl
end

-- Base button (styled)
local function makeButtonBase(parent, height)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, height or 32)
    btn.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local st = Instance.new("UIStroke", btn)
    st.Color = Theme.Stroke
    st.Thickness = 1
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(42,42,44)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(36,36,38)}):Play() end)
    return btn
end

-- Toggle control
local function makeToggle(parent, label, default, callback)
    callback = callback or noop
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 34)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local lbl = newLabel(container, label, 14)
    lbl.Position = UDim2.new(0, 0, 0, 0)

    local btn = makeButtonBase(container, 28)
    btn.Position = UDim2.new(0, 0, 0, 6)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = default and Theme.Text or Theme.Muted

    local state = not not default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.TextColor3 = state and Theme.Text or Theme.Muted
        callback(state)
    end)

    return {
        Set = function(_, v)
            state = not not v
            btn.Text = state and "ON" or "OFF"
            btn.TextColor3 = state and Theme.Text or Theme.Muted
        end,
        Get = function() return state end
    }
end

-- Slider control
local function makeSlider(parent, label, min, max, default, callback)
    callback = callback or noop
    min = min or 0
    max = max or 100
    default = default or min

    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 56)
    Holder.BackgroundTransparency = 1
    Holder.Parent = parent

    local Lbl = newLabel(Holder, string.format("%s: %d", label, default), 14)
    Lbl.Position = UDim2.new(0, 0, 0, 0)

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 10)
    Bar.Position = UDim2.new(0, 0, 0, 30)
    Bar.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Bar.BorderSizePixel = 0
    Bar.Parent = Holder
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 6)

    local Fill = Instance.new("Frame")
    local pct = (default - min) / math.max(1, (max - min))
    Fill.Size = UDim2.new(pct, 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    registerAccent(Fill, "BackgroundColor3")

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new(pct, 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.new(1,1,1)
    Knob.BorderSizePixel = 0
    Knob.Parent = Bar
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function setFromPct(p)
        p = math.clamp(p, 0, 1)
        local val = math.floor(min + (max - min) * p + 0.5)
        Fill.Size = UDim2.new(p, 0, 1, 0)
        Knob.Position = UDim2.new(p, 0, 0.5, 0)
        Lbl.Text = string.format("%s: %d", label, val)
        callback(val)
    end

    Bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local p = (i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
            setFromPct(p)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local p = (i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
            setFromPct(p)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return {
        Set = function(_, v)
            local p = (v - min) / (max - min)
            setFromPct(p)
        end
    }
end

-- Dropdown
local function makeDropdown(parent, label, options, default, callback)
    callback = callback or noop
    options = options or {}
    default = default or options[1]

    local Wrap = Instance.new("Frame")
    Wrap.Size = UDim2.new(1, 0, 0, 36)
    Wrap.BackgroundTransparency = 1
    Wrap.Parent = parent

    local Lbl = newLabel(Wrap, label .. ": " .. tostring(default), 14)
    Lbl.Position = UDim2.new(0, 0, 0, 0)

    local Btn = makeButtonBase(Wrap, 28)
    Btn.Position = UDim2.new(0, 0, 0, 6)
    Btn.Text = tostring(default)
    Btn.TextXAlignment = Enum.TextXAlignment.Left

    local List = Instance.new("Frame")
    List.Size = UDim2.new(1, 0, 0, #options * 28)
    List.Position = UDim2.new(0, 0, 0, 36)
    List.BackgroundColor3 = Color3.fromRGB(34,34,36)
    List.BorderSizePixel = 0
    List.Parent = Wrap
    List.Visible = false
    Instance.new("UICorner", List).CornerRadius = UDim.new(0, 8)

    local listLayout = Instance.new("UIListLayout", List)
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, -8, 0, 26)
        optBtn.Position = UDim2.new(0, 4, 0, 0)
        optBtn.BackgroundColor3 = Color3.fromRGB(40,40,42)
        optBtn.Text = opt
        optBtn.TextColor3 = Theme.Text
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 14
        optBtn.Parent = List
        Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 6)
        optBtn.MouseButton1Click:Connect(function()
            Btn.Text = opt
            List.Visible = false
            callback(opt)
        end)
        optBtn.MouseEnter:Connect(function() optBtn.BackgroundColor3 = Color3.fromRGB(46,46,48) end)
        optBtn.MouseLeave:Connect(function() optBtn.BackgroundColor3 = Color3.fromRGB(40,40,42) end)
    end

    Btn.MouseButton1Click:Connect(function()
        List.Visible = not List.Visible
    end)

    return {
        Set = function(_, v)
            Btn.Text = tostring(v)
        end
    }
end

-- Keybind
local function makeKeybind(parent, label, defaultKey, callback)
    callback = callback or noop
    defaultKey = defaultKey or Enum.KeyCode.RightShift

    local Wrap = Instance.new("Frame")
    Wrap.Size = UDim2.new(1, 0, 0, 36)
    Wrap.BackgroundTransparency = 1
    Wrap.Parent = parent

    local Lbl = newLabel(Wrap, label, 14)
    Lbl.Position = UDim2.new(0, 0, 0, 0)

    local Btn = makeButtonBase(Wrap, 28)
    Btn.Position = UDim2.new(0, 0, 0, 6)
    Btn.Text = defaultKey.Name

    local waiting = false
    Btn.MouseButton1Click:Connect(function()
        waiting = true
        Btn.Text = "..."
    end)

    local current = defaultKey
    local conn
    conn = UserInputService.InputBegan:Connect(function(i, gpe)
        if waiting and not gpe then
            if i.UserInputType == Enum.UserInputType.Keyboard then
                current = i.KeyCode
                Btn.Text = current.Name
                waiting = false
                callback(current)
            end
        end
    end)

    return {
        Get = function() return current end,
        Set = function(_, key) current = key; Btn.Text = key.Name end,
        Disconnect = function()
        if conn then conn:Disconnect() end
        end
    }  
end

-- Color Picker
local function makeColorPicker(parent, label, defaultColor, callback)
    callback = callback or noop
    defaultColor = defaultColor or Theme.Accent

    local Wrap = Instance.new("Frame")
    Wrap.Size = UDim2.new(1, 0, 0, 36)
    Wrap.BackgroundTransparency = 1
    Wrap.Parent = parent

    local Lbl = newLabel(Wrap, label, 14)
    Lbl.Position = UDim2.new(0, 0, 0, 0)

    local Btn = makeButtonBase(Wrap, 28)
    Btn.Position = UDim2.new(0, 0, 0, 6)
    Btn.Text = ""
    Btn.TextXAlignment = Enum.TextXAlignment.Left

    local swatch = Instance.new("Frame")
    swatch.Size = UDim2.new(0, 18, 0, 18)
    swatch.Position = UDim2.new(1, -28, 0.5, 0)
    swatch.AnchorPoint = Vector2.new(0.5, 0.5)
    swatch.BackgroundColor3 = defaultColor
    swatch.BorderSizePixel = 0
    swatch.Parent = Btn
    Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 6)

    -- Popup
    local Popup = Instance.new("Frame")
    Popup.Size = UDim2.new(0, 260, 0, 170)
    Popup.Position = UDim2.new(0, 0, 0, 40)
    Popup.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Popup.BorderSizePixel = 0
    Popup.Parent = Wrap
    Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 8)
    Popup.Visible = false
    local popStroke = Instance.new("UIStroke", Popup)
    popStroke.Color = Theme.Stroke
    popStroke.Thickness = 1

    -- rgb sliders
    local function sliderRow(name, start, y, onChange)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -12, 0, 40)
        Row.Position = UDim2.new(0, 6, 0, y)
        Row.BackgroundTransparency = 1
        Row.Parent = Popup

        local L = newLabel(Row, name, 12)

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(1, 0, 0, 8)
        Bar.Position = UDim2.new(0, 0, 1, -10)
        Bar.BackgroundColor3 = Color3.fromRGB(45,45,45)
        Bar.Parent = Row
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 6)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(start/255, 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.Parent = Bar
        registerAccent(Fill, "BackgroundColor3")

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 12, 0, 12)
        Knob.AnchorPoint = Vector2.new(0.5, 0.5)
        Knob.Position = UDim2.new(Fill.Size.X.Scale, 0, 0.5, 0)
        Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        Knob.Parent = Bar
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

        local dragging = false
        local function setPct(p)
            p = math.clamp(p, 0, 1)
            Fill.Size = UDim2.new(p, 0, 1, 0)
            Knob.Position = UDim2.new(p, 0, 0.5, 0)
            onChange(math.floor(255*p + 0.5))
        end

        Bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local p = (i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
                setPct(p)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local p = (i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
                setPct(p)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)

        return {
            Set = function(_, v) setPct(v/255) end
        }
    end

    local r = math.floor(defaultColor.R*255 + 0.5)
    local g = math.floor(defaultColor.G*255 + 0.5)
    local b = math.floor(defaultColor.B*255 + 0.5)

    local rCtrl = sliderRow("R", r, 6, function(v) r = v end)
    local gCtrl = sliderRow("G", g, 52, function(v) g = v end)
    local bCtrl = sliderRow("B", b, 98, function(v) b = v end)

    local Preview = Instance.new("Frame")
    Preview.Size = UDim2.new(0, 48, 0, 48)
    Preview.Position = UDim2.new(1, -56, 1, -56)
    Preview.BackgroundColor3 = Color3.fromRGB(r,g,b)
    Preview.BorderSizePixel = 0
    Preview.Parent = Popup
    Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 8)

    local Apply = makeButtonBase(Popup, 28)
    Apply.Position = UDim2.new(0, 8, 1, -40)
    Apply.Size = UDim2.new(1, -72, 0, 28)
    Apply.Text = "Apply"

    Apply.MouseButton1Click:Connect(function()
        local col = Color3.fromRGB(r,g,b)
        swatch.BackgroundColor3 = col
        Preview.BackgroundColor3 = col
        Popup.Visible = false
        callback(col)
    end)

    -- live preview
    local heartbeatConn
    heartbeatConn = RunService.Heartbeat:Connect(function()
        Preview.BackgroundColor3 = Color3.fromRGB(r,g,b)
    end)

    Btn.MouseButton1Click:Connect(function()
        Popup.Visible = not Popup.Visible
    end)

    return {
        Set = function(_, col)
            r = math.floor(col.R*255 + 0.5)
            g = math.floor(col.G*255 + 0.5)
            b = math.floor(col.B*255 + 0.5)
            rCtrl:Set(r); gCtrl:Set(g); bCtrl:Set(b)
            swatch.BackgroundColor3 = col
            Preview.BackgroundColor3 = col
        end,
        Disconnect = function()
            if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn = nil end
        end
    }
end

-- Public API: CreateWindow sets title and returns UI table
function UI:CreateWindow(title)
    TitleText.Text = title or TitleText.Text
    return UI
end

-- CreateTab: returns TabObject with CreateSection
function UI:CreateTab(name, icon)
    if Tabs[name] then
        return Tabs[name].TabObject
    end

    local btn = createTabButton(name)
    local page = createPage()
    local tabObj = {}

    Tabs[name] = { Button = btn, Page = page, TabObject = tabObj }

    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)

    -- auto-select first created tab
    if not CurrentTab then
        switchTab(name)
    end

    function tabObj:CreateSection(title)
        local sec, body = createSection(page, title)
        local API = {}

        function API:AddLabel(txt, size)
            return newLabel(body, txt, size)
        end
        function API:AddToggle(txt, def, cb) return makeToggle(body, txt, def, cb) end
        function API:AddSlider(txt, min, max, def, cb) return makeSlider(body, txt, min, max, def, cb) end
        function API:AddDropdown(txt, opts, def, cb) return makeDropdown(body, txt, opts, def, cb) end
        function API:AddKeybind(txt, def, cb) return makeKeybind(body, txt, def, cb) end
        function API:AddColorPicker(txt, def, cb) return makeColorPicker(body, txt, def, cb) end

        return API
    end

    return tabObj
end

-- Visibility toggle
local Visible = true
function UI:SetVisible(state)
    Visible = not not state
    Main.Visible = Visible
end
function UI:ToggleUI()
    UI:SetVisible(not Visible)
end

UserInputService.InputBegan:Connect(function(i, gpe)
    if not gpe and i.KeyCode == Enum.KeyCode.RightShift then
        UI:ToggleUI()
    end
end)

-- Accent API
function UI:SetAccent(color)
    Theme.Accent = color
    applyAccent(color)
end


-- ensure user avatar/name stay updated if player changes display name or avatar
Players.PlayerRemoving:Connect(function(plr)
    if plr == LocalPlayer then
        -- nothing
    end
end)
Players.LocalPlayer:GetPropertyChangedSignal("DisplayName"):Connect(function()
    pcall(function() UserNameLabel.Text = Players.LocalPlayer.DisplayName or Players.LocalPlayer.Name end)
end)
-- occasionally refresh avatar (some environments may need a refresh)
pcall(function()
    UserAvatar.Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=420&height=420&format=png", LocalPlayer.UserId)
    UserNameLabel.Text = LocalPlayer.Name
end)

-- start visible
UI:SetVisible(true)

return UI
