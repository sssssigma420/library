-- SketchUI (Full Library)
-- Modern dark theme, red accent, draggable, sidebar with logo+user, tabs, sections, and controls.
-- Controls: Toggle, Slider, Dropdown, Keybind, ColorPicker. Optional callbacks.
-- RightShift toggles visibility.

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
    AccentDim = Color3.fromRGB(80, 0, 30),
    Stroke = Color3.fromRGB(50, 50, 50),
}

local function noop() end

-- Track stylables so accent can be updated dynamically
local AccentRegistry = {}

local function setAccent(instance, prop, base)
    table.insert(AccentRegistry, {inst = instance, prop = prop, base = base})
    instance[prop] = base or Theme.Accent
end

local function applyAccent(color)
    for _, item in ipairs(AccentRegistry) do
        if item.inst and item.inst.Parent then
            item.inst[item.prop] = color
        end
    end
end

--// Root ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SketchUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

--// Main Window
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 820, 0, 520)
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
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Theme.Panel
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -20, 1, 0)
TitleText.Position = UDim2.fromOffset(10, 0)
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
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 180, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local sideStroke = Instance.new("UIStroke", Sidebar)
sideStroke.Thickness = 1
sideStroke.Color = Theme.Stroke
sideStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Logo area (top-left)
local LogoArea = Instance.new("Frame")
LogoArea.Name = "LogoArea"
LogoArea.Size = UDim2.new(1, 0, 0, 92)
LogoArea.BackgroundTransparency = 1
LogoArea.Parent = Sidebar

local LogoImage = Instance.new("ImageLabel")
LogoImage.Size = UDim2.new(0, 72, 0, 72)
LogoImage.Position = UDim2.new(0.5, 0, 0.5, 0)
LogoImage.AnchorPoint = Vector2.new(0.5, 0.5)
LogoImage.BackgroundTransparency = 1
LogoImage.Image = "rbxassetid://124433474541732"
LogoImage.Parent = LogoArea

-- Tab buttons container (between logo and user block)
local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Size = UDim2.new(1, 0, 1, -92 - 100)
TabButtons.Position = UDim2.new(0, 0, 0, 92)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = Sidebar

local TabLayout = Instance.new("UIListLayout", TabButtons)
TabLayout.FillDirection = Enum.FillDirection.Vertical
TabLayout.Padding = UDim.new(0, 6)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- User profile (bottom-left, blended)
local UserProfile = Instance.new("Frame")
UserProfile.Name = "UserProfile"
UserProfile.Size = UDim2.new(1, 0, 0, 100)
UserProfile.Position = UDim2.new(0, 0, 1, -100)
UserProfile.BackgroundTransparency = 1
UserProfile.Parent = Sidebar

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 64, 0, 64)
Avatar.Position = UDim2.new(0.5, 0, 0, 8)
Avatar.AnchorPoint = Vector2.new(0.5, 0)
Avatar.BackgroundTransparency = 1
Avatar.Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=420&height=420&format=png", LocalPlayer.UserId)
Avatar.Parent = UserProfile

local Username = Instance.new("TextLabel")
Username.Size = UDim2.new(1, -20, 0, 20)
Username.Position = UDim2.new(0.5, 0, 1, -8)
Username.AnchorPoint = Vector2.new(0.5, 1)
Username.BackgroundTransparency = 1
Username.Font = Enum.Font.GothamSemibold
Username.TextSize = 14
Username.TextColor3 = Color3.new(1,1,1)
Username.TextXAlignment = Enum.TextXAlignment.Center
Username.Text = LocalPlayer.Name
Username.Parent = UserProfile

--// Right panel (tabs content)
local RightPane = Instance.new("Frame")
RightPane.Name = "RightPane"
RightPane.Size = UDim2.new(1, -180, 1, -42)
RightPane.Position = UDim2.new(0, 180, 0, 42)
RightPane.BackgroundTransparency = 1
RightPane.Parent = Main

-- Container for pages
local Pages = Instance.new("Frame")
Pages.Name = "Pages"
Pages.Size = UDim2.new(1, 0, 1, 0)
Pages.BackgroundTransparency = 1
Pages.Parent = RightPane

-- Store tabs/pages
local Tabs = {}
local CurrentTab

-- Helper: Make a tab button
local function createTabButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 34)
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = text
    btn.TextColor3 = Theme.Muted
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = TabButtons

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)

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

-- Helper: Make a scrollable page
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
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    page.ChildAdded:Connect(function()
        task.defer(function()
            page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)
    end)
    return page
end

-- Helper: section container
local function createSection(parent, title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, -10, 0, 180)
    Section.BackgroundColor3 = Theme.Panel
    Section.BorderSizePixel = 0
    Section.Parent = parent

    local secCorner = Instance.new("UICorner", Section)
    secCorner.CornerRadius = UDim.new(0, 8)

    local secStroke = Instance.new("UIStroke", Section)
    secStroke.Color = Theme.Stroke
    secStroke.Thickness = 1

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 22)
    titleLabel.Position = UDim2.new(0, 10, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1,1,1)
    titleLabel.Parent = Section

    local titleAccent = Instance.new("Frame")
    titleAccent.Size = UDim2.new(0, 28, 0, 2)
    titleAccent.Position = UDim2.fromOffset(10, 30)
    titleAccent.BackgroundColor3 = Theme.Accent
    titleAccent.BorderSizePixel = 0
    titleAccent.Parent = Section
    setAccent(titleAccent, "BackgroundColor3")

    local Body = Instance.new("Frame")
    Body.Name = "Body"
    Body.Size = UDim2.new(1, -20, 1, -40)
    Body.Position = UDim2.fromOffset(10, 36)
    Body.BackgroundTransparency = 1
    Body.Parent = Section

    local bodyLayout = Instance.new("UIListLayout", Body)
    bodyLayout.FillDirection = Enum.FillDirection.Vertical
    bodyLayout.Padding = UDim.new(0, 8)
    bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", Body)
    pad.PaddingTop = UDim.new(0, 2)

    return Section, Body
end

-- Control helpers
local function makeButtonBase(parent, height)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, height or 30)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Btn.TextColor3 = Theme.Text
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.AutoButtonColor = false
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local st = Instance.new("UIStroke", Btn)
    st.Color = Theme.Stroke
    st.Thickness = 1
    Btn.MouseEnter:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end)
    Btn.MouseLeave:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35) end)
    return Btn
end

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

-- Slider track
local function makeSlider(parent, label, min, max, default, callback)
    callback = callback or noop
    local Holder = Instance.new("Frame")
    Holder.BackgroundTransparency = 1
    Holder.Size = UDim2.new(1, 0, 0, 48)
    Holder.Parent = parent

    local Top = Instance.new("Frame")
    Top.BackgroundTransparency = 1
    Top.Size = UDim2.new(1, 0, 0, 22)
    Top.Parent = Holder

    local Lbl = newLabel(Top, string.format("%s: %d", label, default))

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 6)
    Bar.Position = UDim2.fromOffset(0, 28)
    Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Bar.BorderSizePixel = 0
    Bar.Parent = Holder
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 4)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
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
        Set = function(_, v)
            local p = (v - min) / (max - min)
            setFromPct(p)
        end
    }
end

-- Dropdown
local function makeDropdown(parent, label, options, default, callback)
    callback = callback or noop
    local Btn = makeButtonBase(parent, 30)
    Btn.Text = string.format("%s: %s", label, default or (options[1] or ""))
    local Open = false

    local List = Instance.new("Frame")
    List.Size = UDim2.new(1, 0, 0, #options * 26)
    List.Position = UDim2.new(0, 0, 0, 32)
    List.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    List.Visible = false
    List.Parent = Btn
    Instance.new("UICorner", List).CornerRadius = UDim.new(0, 6)
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
        Instance.new("UICorner", Opt).CornerRadius = UDim.new(0, 4)
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
    local Btn = makeButtonBase(parent, 30)
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
    local Btn = makeButtonBase(parent, 30)
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
    local Btn = makeButtonBase(parent, 30)
    Btn.TextXAlignment = Enum.TextXAlignment.Left

    local swatch = Instance.new("Frame")
    swatch.Size = UDim2.new(0, 18, 0, 18)
    swatch.Position = UDim2.new(1, -24, 0.5, 0)
    swatch.AnchorPoint = Vector2.new(0, 0.5)
    swatch.BackgroundColor3 = default or Theme.Accent
    swatch.BorderSizePixel = 0
    swatch.Parent = Btn
    Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 4)

    Btn.Text = label

    local Popup = Instance.new("Frame")
    Popup.Size = UDim2.new(0, 220, 0, 140)
    Popup.Position = UDim2.new(0, 0, 0, 34)
    Popup.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Popup.Visible = false
    Popup.Parent = Btn
    Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 6)
    local popStroke = Instance.new("UIStroke", Popup)
    popStroke.Color = Theme.Stroke

    local function sliderRow(name, start, onChange)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -12, 0, 36)
        Row.Position = UDim2.new(0, 6, 0, 0)
        Row.BackgroundTransparency = 1
        Row.Parent = Popup

        local L = newLabel(Row, name, 14)

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(1, 0, 0, 6)
        Bar.Position = UDim2.new(0, 0, 1, -10)
        Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Bar.Parent = Row
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 4)

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

    local red = sliderRow("R", r, function(v) r=v end)
    local green = sliderRow("G", g, function(v) g=v end)
    local blue = sliderRow("B", b, function(v) b=v end)

    local Prev = Instance.new("Frame")
    Prev.Size = UDim2.new(0, 40, 0, 40)
    Prev.Position = UDim2.new(1, -46, 1, -46)
    Prev.BackgroundColor3 = Color3.fromRGB(r,g,b)
    Prev.BorderSizePixel = 0
    Prev.Parent = Popup
    Instance.new("UICorner", Prev).CornerRadius = UDim.new(0, 6)

    local ApplyBtn = makeButtonBase(Popup, 26)
    ApplyBtn.Position = UDim2.new(0, 6, 1, -30)
    ApplyBtn.Size = UDim2.new(1, -52, 0, 26)
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

function UI:CreateTab(name)
    name = tostring(name or "Tab")

    local Button = createTabButton(name)
    local Page = createPage()

    local TabObject = {
        Button = Button,
        Page = Page,
        CreateSection = function(self, secTitle)
            local Section, Body = createSection(Page, secTitle or "Section")

            local SectionAPI = {}

            function SectionAPI:AddLabel(text)
                return newLabel(Body, text)
            end

            function SectionAPI:AddToggle(text, default, cb)
                return makeToggle(Body, text or "Toggle", default, cb)
            end

            function SectionAPI:AddSlider(text, min, max, default, cb)
                return makeSlider(Body, text or "Slider", min or 0, max or 100, default or 0, cb)
            end

            function SectionAPI:AddDropdown(text, options, default, cb)
                options = options or {"Option A","Option B"}
                return makeDropdown(Body, text or "Dropdown", options, default or options[1], cb)
            end

            function SectionAPI:AddKeybind(text, defaultKey, cb)
                return makeKeybind(Body, text or "Keybind", defaultKey or Enum.KeyCode.E, cb)
            end

            function SectionAPI:AddColorPicker(text, default, cb)
                return makeColorPicker(Body, text or "Color", default or Theme.Accent, cb)
            end

            return SectionAPI
        end
    }

    Tabs[name] = TabObject

    Button.MouseButton1Click:Connect(function()
        if CurrentTab then
            CurrentTab.Page.Visible = false
            CurrentTab.Button.TextColor3 = Theme.Muted
        end
        CurrentTab = TabObject
        Page.Visible = true
        Button.TextColor3 = Color3.new(1,1,1)
    end)

    -- First tab auto-select
    if not CurrentTab then
        Button:MouseButton1Click()
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

-- Rainbow UI (optional helper)
local rainbowConn
function UI:EnableRainbow(enabled, speed)
    if rainbowConn then rainbowConn:Disconnect(); rainbowConn = nil end
    if enabled then
        speed = speed or 2
        local t = 0
        rainbowConn = RunService.Heartbeat:Connect(function(dt)
            t += dt * speed
            local r = (math.sin(t) * 127 + 128)
            local g = (math.sin(t + 2) * 127 + 128)
            local b = (math.sin(t + 4) * 127 + 128)
            UI:SetAccent(Color3.fromRGB(r, g, b))
        end)
    end
end

-- Start visible
UI:SetVisible(true)

return UI
