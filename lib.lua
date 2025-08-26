-- lib_fixed.lua — SketchUI (Full Library, Rainbow Removed, Fixed Tabs)
-- Modern dark theme, red accent, draggable, sidebar with logo + user,
-- vertical tab list with spacing, pages per tab, sections and common controls.
-- Tabs "Legitbot", "Visuals", "Misc", "Settings" are created by default (empty).
-- Toggle the whole UI with RightShift.

local UI = {}

--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// Theme
local Theme = {
    Bg = Color3.fromRGB(20, 20, 20),
    Panel = Color3.fromRGB(25, 25, 25),
    Sidebar = Color3.fromRGB(15, 15, 15),
    Text = Color3.fromRGB(220, 220, 220),
    Muted = Color3.fromRGB(180, 180, 180),
    Accent = Color3.fromRGB(255, 0, 80),
    Stroke = Color3.fromRGB(50, 50, 50),
}

local function noop() end

-- Track stylables so accent can be updated dynamically
local AccentRegistry = {}

local function setAccent(instance, prop, base)
    table.insert(AccentRegistry, {inst = instance, prop = prop})
    instance[prop] = base or Theme.Accent
end

local function applyAccent(color)
    for _, item in ipairs(AccentRegistry) do
        local inst = item.inst
        if inst and inst.Parent then
            inst[item.prop] = color
        end
    end
end

--// Root ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SketchUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
(ScreenGui :: any).Parent = (gethui and gethui()) or game:GetService("CoreGui")

--// Main Window
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 860, 0, 540)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local mainCorner = Instance.new("UICorner", Main)
mainCorner.CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Thickness = 1
mainStroke.Color = Theme.Stroke
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Title bar (for dragging)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Theme.Panel
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -20, 1, 0)
TitleText.Position = UDim2.fromOffset(12, 0)
TitleText.BackgroundTransparency = 1
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextSize = 18
TitleText.TextColor3 = Color3.new(1,1,1)
TitleText.Text = "SketchUI"
TitleText.Parent = TitleBar

local TitleUnderline = Instance.new("Frame")
TitleUnderline.Size = UDim2.new(1, 0, 0, 1)
TitleUnderline.Position = UDim2.new(0, 0, 1, -1)
TitleUnderline.BackgroundColor3 = Theme.Stroke
TitleUnderline.BorderSizePixel = 0
TitleUnderline.Parent = TitleBar

-- Draggable (manual)
do
    local dragging = false
    local dragStart, startPos
    TitleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = Main.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--// Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 200, 1, -44)
Sidebar.Position = UDim2.new(0, 0, 0, 44)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local sideStroke = Instance.new("UIStroke", Sidebar)
sideStroke.Thickness = 1
sideStroke.Color = Theme.Stroke
sideStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Logo area (top-left) (reserve space for your asset)
local LogoArea = Instance.new("Frame")
LogoArea.Name = "LogoArea"
LogoArea.Size = UDim2.new(1, 0, 0, 96)
LogoArea.BackgroundTransparency = 1
LogoArea.Parent = Sidebar

local LogoImage = Instance.new("ImageLabel")
LogoImage.Size = UDim2.new(0, 80, 0, 80)
LogoImage.Position = UDim2.new(0.5, 0, 0.5, 0)
LogoImage.AnchorPoint = Vector2.new(0.5, 0.5)
LogoImage.BackgroundTransparency = 1
LogoImage.Image = "rbxassetid://124433474541732" -- your logo
LogoImage.Parent = LogoArea

-- Tab buttons container (between logo and user block)
local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Size = UDim2.new(1, 0, 1, -96 - 110)
TabButtons.Position = UDim2.new(0, 0, 0, 96)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = Sidebar

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1, -20, 0, 40)
Button.Position = UDim2.new(0, 10, 0, (SidebarLayout.AbsoluteContentSize.Y)) -- UIListLayout handles spacing
Button.BackgroundColor3 = Color3.fromRGB(25,25,25)
Button.Text = name
Button.TextColor3 = Color3.fromRGB(220,220,220)
Button.Font = Enum.Font.Gotham
Button.TextSize = 14
Button.Parent = Sidebar

-- Add spacing
local SidebarLayout = Sidebar:FindFirstChild("UIListLayout") or Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0,5)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder


local TabPadding = Instance.new("UIPadding", TabButtons)
TabPadding.PaddingTop = UDim.new(0, 6)
TabPadding.PaddingLeft = UDim.new(0, 10)
TabPadding.PaddingRight = UDim.new(0, 10)

local TabLayout = Instance.new("UIListLayout", TabButtons)
TabLayout.FillDirection = Enum.FillDirection.Vertical
TabLayout.Padding = UDim.new(0, 8) -- small space between tabs
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Stretch

-- User profile (bottom-left)
local UserProfile = Instance.new("Frame")
UserProfile.Name = "UserProfile"
UserProfile.Size = UDim2.new(1, -16, 0, 110)
UserProfile.Position = UDim2.new(0, 8, 1, -118)
UserProfile.BackgroundColor3 = Theme.Panel
UserProfile.BorderSizePixel = 0
UserProfile.Parent = Sidebar
Instance.new("UICorner", UserProfile).CornerRadius = UDim.new(0, 8)

local userStroke = Instance.new("UIStroke", UserProfile)
userStroke.Thickness = 1
userStroke.Color = Theme.Stroke

local PlayerInfo = Instance.new("Frame")
PlayerInfo.Size = UDim2.new(1,0,0,90)
PlayerInfo.Position = UDim2.new(0,0,1,-90)
PlayerInfo.BackgroundTransparency = 1
PlayerInfo.Parent = Sidebar

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0,64,0,64)
Avatar.Position = UDim2.new(0,10,0,0)
Avatar.BackgroundTransparency = 1
Avatar.Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=420&height=420&format=png", Players.LocalPlayer.UserId)
Avatar.Parent = PlayerInfo

local Username = Instance.new("TextLabel")
Username.Size = UDim2.new(1,-20,0,20)
Username.Position = UDim2.new(0,10,0,68)
Username.BackgroundTransparency = 1
Username.Text = Players.LocalPlayer.Name
Username.TextColor3 = Color3.fromRGB(255,255,255)
Username.Font = Enum.Font.GothamSemibold
Username.TextSize = 14
Username.TextXAlignment = Enum.TextXAlignment.Left
Username.Parent = PlayerInfo


local Subtle = Instance.new("TextLabel")
Subtle.Size = UDim2.new(1, -76, 0, 20)
Subtle.Position = UDim2.new(0, 76, 0, 66)
Subtle.BackgroundTransparency = 1
Subtle.Font = Enum.Font.Gotham
Subtle.TextSize = 12
Subtle.TextColor3 = Theme.Muted
Subtle.TextXAlignment = Enum.TextXAlignment.Left
Subtle.Text = "RightShift to toggle"
Subtle.Parent = UserProfile

--// Right panel (tabs content)
local RightPane = Instance.new("Frame")
RightPane.Name = "RightPane"
RightPane.Size = UDim2.new(1, -200, 1, -44)
RightPane.Position = UDim2.new(0, 200, 0, 44)
RightPane.BackgroundTransparency = 1
RightPane.Parent = Main

-- Container for pages
local Pages = Instance.new("Frame")
Pages.Name = "Pages"
Pages.Size = UDim2.new(1, -20, 1, -20)
Pages.Position = UDim2.new(0, 10, 0, 10)
Pages.BackgroundTransparency = 1
Pages.Parent = RightPane

-- Store tabs/pages
local Tabs = {}  -- [name] = { Button = btn, Page = page }
local CurrentTab

-- Helpers
local function createTabButton(text, icon) -- icon optional (not used but kept for API)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = text
    btn.TextColor3 = Theme.Muted
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = TabButtons

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Theme.Stroke
    stroke.Thickness = 1

    btn.MouseEnter:Connect(function() btn.TextColor3 = Color3.new(1,1,1) end)
    btn.MouseLeave:Connect(function()
        if CurrentTab and CurrentTab.Button == btn then return end
        btn.TextColor3 = Theme.Muted
    end)

    return btn
end

local function createPage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollBarThickness = 4
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = Pages

    local layout = Instance.new("UIListLayout", page)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    page.ChildAdded:Connect(function()
        task.defer(function()
            page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)
    end)

    return page
end

local function switchTab(name)
    local tab = Tabs[name]
    if not tab then return end
    for _, data in pairs(Tabs) do
        if data.Page then data.Page.Visible = false end
        if data.Button then data.Button.TextColor3 = Theme.Muted end
    end
    tab.Page.Visible = true
    tab.Button.TextColor3 = Color3.new(1,1,1)
    CurrentTab = tab
end

-- Section helper
local function createSection(parent, title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, 0, 0, 200)
    Section.BackgroundColor3 = Theme.Panel
    Section.BorderSizePixel = 0
    Section.Parent = parent

    local secCorner = Instance.new("UICorner", Section)
    secCorner.CornerRadius = UDim.new(0, 10)

    local secStroke = Instance.new("UIStroke", Section)
    secStroke.Color = Theme.Stroke
    secStroke.Thickness = 1

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 24)
    Title.Position = UDim2.fromOffset(10, 10)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = title or ""
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Parent = Section

    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(0, 30, 0, 2)
    Accent.Position = UDim2.fromOffset(10, 34)
    Accent.BackgroundColor3 = Theme.Accent
    Accent.BorderSizePixel = 0
    Accent.Parent = Section
    setAccent(Accent, "BackgroundColor3")

    local Body = Instance.new("Frame")
    Body.Name = "Body"
    Body.Size = UDim2.new(1, -20, 1, -50)
    Body.Position = UDim2.fromOffset(10, 40)
    Body.BackgroundTransparency = 1
    Body.Parent = Section

    local bodyLayout = Instance.new("UIListLayout", Body)
    bodyLayout.FillDirection = Enum.FillDirection.Vertical
    bodyLayout.Padding = UDim.new(0, 8)
    bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder

    return Section, Body
end

-- Small text helper
local function newLabel(parent, text, size)
    local L = Instance.new("TextLabel")
    L.BackgroundTransparency = 1
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Font = Enum.Font.Gotham
    L.TextSize = size or 14
    L.TextColor3 = Theme.Text
    L.Text = text
    L.Size = UDim2.new(1, 0, 0, size and math.max(22, size+6) or 22)
    L.Parent = parent
    return L
end

-- Base button visual container
local function makeButtonBase(parent, height)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, height or 30)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Btn.TextColor3 = Theme.Text
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    local st = Instance.new("UIStroke", Btn)
    st.Color = Theme.Stroke
    st.Thickness = 1
    Btn.MouseEnter:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end)
    Btn.MouseLeave:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35) end)
    return Btn
end

-- Slider
local function makeSlider(parent, label, min, max, default, callback)
    callback = callback or noop
    local Holder = Instance.new("Frame")
    Holder.BackgroundTransparency = 1
    Holder.Size = UDim2.new(1, 0, 0, 56)
    Holder.Parent = parent

    local Top = Instance.new("Frame")
    Top.BackgroundTransparency = 1
    Top.Size = UDim2.new(1, 0, 0, 22)
    Top.Parent = Holder

    local Lbl = newLabel(Top, string.format("%s: %d", label, default))

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 8)
    Bar.Position = UDim2.fromOffset(0, 30)
    Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Bar.BorderSizePixel = 0
    Bar.Parent = Holder
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 6)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    setAccent(Fill, "BackgroundColor3")

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new(Fill.Size.X.Scale, 0, 0.5, 0)
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
            local pct = (i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
            setFromPct(pct)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local pct = (i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
            setFromPct(pct)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return {
        Set = function(_, v) setFromPct((v - min) / (max - min)) end
    }
end

-- Dropdown
local function makeDropdown(parent, label, options, default, callback)
    callback = callback or noop
    options = options or {}
    local Btn = makeButtonBase(parent, 32)
    Btn.Text = string.format("%s: %s", label, default or (options[1] or ""))
    local Open = false

    local List = Instance.new("Frame")
    List.Size = UDim2.new(1, 0, 0, #options * 26)
    List.Position = UDim2.new(0, 0, 0, 34)
    List.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    List.Visible = false
    List.Parent = Btn
    Instance.new("UICorner", List).CornerRadius = UDim.new(0, 8)
    local lstStroke = Instance.new("UIStroke", List)
    lstStroke.Color = Theme.Stroke

    local lay = Instance.new("UIListLayout", List)
    lay.Padding = UDim.new(0, 2)

    for _, opt in ipairs(options) do
        local Opt = Instance.new("TextButton")
        Opt.Size = UDim2.new(1, 0, 0, 24)
        Opt.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Opt.Text = opt
        Opt.TextColor3 = Theme.Text
        Opt.Font = Enum.Font.Gotham
        Opt.TextSize = 14
        Opt.Parent = List
        Instance.new("UICorner", Opt).CornerRadius = UDim.new(0, 6)
        Opt.MouseEnter:Connect(function() Opt.BackgroundColor3 = Color3.fromRGB(45, 45, 45) end)
        Opt.MouseLeave:Connect(function() Opt.BackgroundColor3 = Color3.fromRGB(35, 35, 35) end)
        Opt.MouseButton1Click:Connect(function()
            Btn.Text = string.format("%s: %s", label, opt)
            List.Visible = false
            Open = false
            callback(opt)
        end)
    end

    Btn.MouseButton1Click:Connect(function()
        Open = not Open
        List.Visible = Open
    end)

    return {
        Set = function(_, value)
            Btn.Text = string.format("%s: %s", label, value)
        end
    }
end

-- Toggle
local function makeToggle(parent, label, default, callback)
    callback = callback or noop
    local Btn = makeButtonBase(parent, 32)
    local state = not not default
    local function apply()
        Btn.Text = string.format("%s: %s", label, state and "ON" or "OFF")
        Btn.TextColor3 = state and Color3.new(1,1,1) or Theme.Muted
        callback(state)
    end
    apply()
    Btn.MouseButton1Click:Connect(function()
        state = not state
        apply()
    end)
    return {
        Set = function(_, v) state = not not v; apply() end,
        Get = function() return state end
    }
end

-- Keybind
local function makeKeybind(parent, label, defaultKey, callback)
    callback = callback or noop
    defaultKey = defaultKey or Enum.KeyCode.RightShift
    local Btn = makeButtonBase(parent, 32)
    local waiting = false
    local current = defaultKey
    Btn.Text = string.format("%s: %s", label, current.Name)

    Btn.MouseButton1Click:Connect(function()
        waiting = true
        Btn.Text = string.format("%s: ...", label)
    end)

    UserInputService.InputBegan:Connect(function(i, gpe)
        if waiting and not gpe and i.UserInputType == Enum.UserInputType.Keyboard then
            waiting = false
            current = i.KeyCode
            Btn.Text = string.format("%s: %s", label, current.Name)
            callback(current)
        end
    end)

    return {
        Get = function() return current end,
        Set = function(_, key) current = key; Btn.Text = string.format("%s: %s", label, current.Name) end
    }
end

-- Color Picker (popup with RGB sliders)
local function makeColorPicker(parent, label, default, callback)
    callback = callback or noop
    local Btn = makeButtonBase(parent, 32)
    Btn.TextXAlignment = Enum.TextXAlignment.Left

    local swatch = Instance.new("Frame")
    swatch.Size = UDim2.new(0, 18, 0, 18)
    swatch.Position = UDim2.new(1, -24, 0.5, 0)
    swatch.AnchorPoint = Vector2.new(0, 0.5)
    swatch.BackgroundColor3 = default or Theme.Accent
    swatch.BorderSizePixel = 0
    swatch.Parent = Btn
    Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 6)

    Btn.Text = label

    local Popup = Instance.new("Frame")
    Popup.Size = UDim2.new(0, 240, 0, 156)
    Popup.Position = UDim2.new(0, 0, 0, 36)
    Popup.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Popup.Visible = false
    Popup.Parent = Btn
    Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 8)
    local popStroke = Instance.new("UIStroke", Popup)
    popStroke.Color = Theme.Stroke

    local function sliderRow(name, start, onChange, y)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -12, 0, 40)
        Row.Position = UDim2.new(0, 6, 0, y)
        Row.BackgroundTransparency = 1
        Row.Parent = Popup

        local L = newLabel(Row, name, 14)

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(1, 0, 0, 8)
        Bar.Position = UDim2.new(0, 0, 1, -10)
        Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Bar.BorderSizePixel = 0
        Bar.Parent = Row
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 6)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(start/255, 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = Bar
        setAccent(Fill, "BackgroundColor3")

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 12, 0, 12)
        Knob.AnchorPoint = Vector2.new(0.5, 0.5)
        Knob.Position = UDim2.new(Fill.Size.X.Scale, 0, 0.5, 0)
        Knob.BackgroundColor3 = Color3.new(1,1,1)
        Knob.BorderSizePixel = 0
        Knob.Parent = Bar
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

        local dragging = false
        local function setPct(p)
            p = math.clamp(p, 0, 1)
            Fill.Size = UDim2.new(p, 0, 1, 0)
            Knob.Position = UDim2.new(p, 0, 0.5, 0)
            onChange(math.floor(255*p+0.5))
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
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        return {
            Set = function(_, v) setPct(v/255) end
        }
    end

    local r, g, b = 255, 0, 80
    if default then
        r = math.floor(default.R*255 + 0.5)
        g = math.floor(default.G*255 + 0.5)
        b = math.floor(default.B*255 + 0.5)
    end

    local red = sliderRow("R", r, function(v) r=v end, 6)
    local green = sliderRow("G", g, function(v) g=v end, 52)
    local blue = sliderRow("B", b, function(v) b=v end, 98)

    local Prev = Instance.new("Frame")
    Prev.Size = UDim2.new(0, 44, 0, 44)
    Prev.Position = UDim2.new(1, -50, 1, -50)
    Prev.BackgroundColor3 = Color3.fromRGB(r,g,b)
    Prev.BorderSizePixel = 0
    Prev.Parent = Popup
    Instance.new("UICorner", Prev).CornerRadius = UDim.new(0, 8)

    local ApplyBtn = makeButtonBase(Popup, 28)
    ApplyBtn.Position = UDim2.new(0, 6, 1, -34)
    ApplyBtn.Size = UDim2.new(1, -60, 0, 28)
    ApplyBtn.Text = "Apply"

    ApplyBtn.MouseButton1Click:Connect(function()
        local col = Color3.fromRGB(r, g, b)
        swatch.BackgroundColor3 = col
        Prev.BackgroundColor3 = col
        Popup.Visible = false
        callback(col)
    end)

    -- Live preview while dragging
    RunService.Heartbeat:Connect(function()
        Prev.BackgroundColor3 = Color3.fromRGB(r,g,b)
    end)

    Btn.MouseButton1Click:Connect(function()
        Popup.Visible = not Popup.Visible
    end)

    return {
        Set = function(_, col)
            r = math.floor(col.R*255+0.5)
            g = math.floor(col.G*255+0.5)
            b = math.floor(col.B*255+0.5)
            red:Set(r); green:Set(g); blue:Set(b)
            swatch.BackgroundColor3 = col
            Prev.BackgroundColor3 = col
        end
    }
end

--// Public API

function UI:CreateWindow(title)
    TitleText.Text = title or "SketchUI"
    return UI
end

-- returns a TabObject with CreateSection()
function UI:CreateTab(name, icon)
    if Tabs[name] then
        return Tabs[name].TabObject
    end

    local Button = createTabButton(name, icon)
    local Page = createPage()

    local TabObject = {}
    Tabs[name] = { Button = Button, Page = Page, TabObject = TabObject }

    Button.MouseButton1Click:Connect(function()
        switchTab(name)
    end)

    -- Auto-select first created tab
    if not CurrentTab then
        switchTab(name)
    end

    function TabObject:CreateSection(title)
        local Section, Body = createSection(Page, title or "")
        local SectionAPI = {}

        function SectionAPI:AddLabel(text, size)
            return newLabel(Body, text, size)
        end

        function SectionAPI:AddToggle(txt, default, callback)
            return makeToggle(Body, txt, default, callback)
        end

        function SectionAPI:AddSlider(txt, min, max, default, callback)
            return makeSlider(Body, txt, min, max, default, callback)
        end

        function SectionAPI:AddDropdown(txt, options, default, callback)
            return makeDropdown(Body, txt, options, default, callback)
        end

        function SectionAPI:AddKeybind(txt, defaultKey, callback)
            return makeKeybind(Body, txt, defaultKey, callback)
        end

        function SectionAPI:AddColorPicker(txt, default, callback)
            return makeColorPicker(Body, txt, default, callback)
        end

        return SectionAPI
    end

    return TabObject
end

-- Visibility / toggle with RightShift
local Visible = true
function UI:SetVisible(state)
    Visible = not not state
    Main.Visible = Visible
end
function UI:ToggleUI() UI:SetVisible(not Visible) end

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

-- NOTE: Rainbow helper intentionally removed as requested.

-- Create default tabs (empty) with small spacing; first opens automatically
local defaultTabs = {"Legitbot", "Visuals", "Misc", "Settings"}
for _, tName in ipairs(defaultTabs) do
    local tab = UI:CreateTab(tName)
    -- create an empty section as a placeholder (no controls inside)
    tab:CreateSection("") -- empty title; keep visual spacing
end

-- Start visible
UI:SetVisible(true)

return UI
