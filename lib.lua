-- SketchUI.lua
-- Modern dark/red themed UI library with draggable window
-- Features: Window + Sidebar + Tabs + Sections + Toggles, Sliders, Dropdowns, Keybinds, ColorPicker
-- Starts visible, toggle with RightShift

local UI = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SketchUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 700, 0, 450)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- ✅ draggable
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Top area for logo
local LogoArea = Instance.new("Frame")
LogoArea.Name = "LogoArea"
LogoArea.Size = UDim2.new(1, 0, 0, 80) -- space for logo
LogoArea.BackgroundTransparency = 1
LogoArea.Parent = Sidebar

-- Logo image
local LogoImage = Instance.new("ImageLabel")
LogoImage.Size = UDim2.new(0, 84, 0, 84)
LogoImage.Position = UDim2.new(0.5, 0, 0.7, 0)
LogoImage.AnchorPoint = Vector2.new(0.5, 0.5)
LogoImage.BackgroundTransparency = 1
LogoImage.Image = "rbxassetid://124433474541732"
LogoImage.Parent = LogoArea

-- Tab buttons container
local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Size = UDim2.new(1, 0, 1, -180) -- leave space for logo + user profile
TabButtons.Position = UDim2.new(0, 0, 0, 80)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = Sidebar

local TabButtonLayout = Instance.new("UIListLayout", TabButtons)
TabButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabButtonLayout.Padding = UDim.new(0, 2)

-- User profile (BOTTOM, blended with sidebar)
local UserProfile = Instance.new("Frame")
UserProfile.Name = "UserProfile"
UserProfile.Size = UDim2.new(1, 0, 0, 100)
UserProfile.Position = UDim2.new(0, 0, 1, -100)
UserProfile.BackgroundTransparency = 1 -- blend with sidebar
UserProfile.Parent = Sidebar

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 64, 0, 64)
Avatar.Position = UDim2.new(0.5, 0, 0, 10)
Avatar.AnchorPoint = Vector2.new(0.5, 0)
Avatar.BackgroundTransparency = 1
Avatar.Image = string.format(
    "https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=420&height=420&format=png",
    LocalPlayer.UserId
)
Avatar.Parent = UserProfile

local Username = Instance.new("TextLabel")
Username.Size = UDim2.new(1, -20, 0, 20)
Username.Position = UDim2.new(0.5, 0, 1, -5)
Username.AnchorPoint = Vector2.new(0.5, 1)
Username.BackgroundTransparency = 1
Username.Text = LocalPlayer.Name
Username.TextColor3 = Color3.fromRGB(255, 255, 255)
Username.TextSize = 14
Username.Font = Enum.Font.GothamSemibold
Username.TextXAlignment = Enum.TextXAlignment.Center
Username.Parent = UserProfile


-- Tab container
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -150, 1, 0)
TabContainer.Position = UDim2.new(0, 150, 0, 0)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- Tabs store
local Tabs = {}

-- Window Title
function UI:CreateWindow(title)
    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Text = title
    TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.Font = Enum.Font.GothamBold
    TitleBar.TextSize = 18
    TitleBar.TextXAlignment = Enum.TextXAlignment.Center
    TitleBar.Parent = MainFrame
    return UI
end

-- Tabs
function UI:CreateTab(name)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.Parent = Sidebar

    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 1, -40)
    TabFrame.Position = UDim2.new(0, 0, 0, 40)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.Parent = TabContainer

    local Layout = Instance.new("UIListLayout", TabFrame)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 8)

    Tabs[name] = TabFrame

    Button.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end
        TabFrame.Visible = true
    end)

    return {
        CreateSection = function(_, title)
            local Section = Instance.new("Frame")
            Section.Size = UDim2.new(1, -20, 0, 150)
            Section.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Section.BorderSizePixel = 0
            Section.Parent = TabFrame

            local SectionCorner = Instance.new("UICorner", Section)
            SectionCorner.CornerRadius = UDim.new(0, 6)

            local SecTitle = Instance.new("TextLabel")
            SecTitle.Size = UDim2.new(1, -10, 0, 25)
            SecTitle.Position = UDim2.new(0, 5, 0, 5)
            SecTitle.BackgroundTransparency = 1
            SecTitle.Text = title
            SecTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
            SecTitle.Font = Enum.Font.GothamBold
            SecTitle.TextSize = 14
            SecTitle.TextXAlignment = Enum.TextXAlignment.Left
            SecTitle.Parent = Section

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, -10, 1, -30)
            Container.Position = UDim2.new(0, 5, 0, 30)
            Container.BackgroundTransparency = 1
            Container.Parent = Section

            local UIList = Instance.new("UIListLayout", Container)
            UIList.SortOrder = Enum.SortOrder.LayoutOrder
            UIList.Padding = UDim.new(0, 5)

            return {
                AddToggle = function(_, txt, default, callback)
                    local Toggle = Instance.new("TextButton")
                    Toggle.Size = UDim2.new(1, 0, 0, 25)
                    Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    Toggle.Text = txt .. ": " .. tostring(default)
                    Toggle.TextColor3 = Color3.fromRGB(220, 220, 220)
                    Toggle.Font = Enum.Font.Gotham
                    Toggle.TextSize = 14
                    Toggle.Parent = Container

                    local state = default
                    Toggle.MouseButton1Click:Connect(function()
                        state = not state
                        Toggle.Text = txt .. ": " .. tostring(state)
                        callback(state)
                    end)
                end,

                AddSlider = function(_, txt, min, max, default, callback)
                    local Frame = Instance.new("Frame")
                    Frame.Size = UDim2.new(1, 0, 0, 40)
                    Frame.BackgroundTransparency = 1
                    Frame.Parent = Container

                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, 0, 0, 20)
                    Label.Text = txt .. ": " .. default
                    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
                    Label.BackgroundTransparency = 1
                    Label.Font = Enum.Font.Gotham
                    Label.TextSize = 14
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = Frame

                    local Bar = Instance.new("Frame")
                    Bar.Size = UDim2.new(1, -10, 0, 6)
                    Bar.Position = UDim2.new(0, 5, 0, 25)
                    Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    Bar.Parent = Frame

                    local Fill = Instance.new("Frame")
                    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
                    Fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    Fill.Parent = Bar

                    local dragging = false
                    Bar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local pct = math.clamp((input.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,0,1)
                            local val = math.floor(min+(max-min)*pct)
                            Fill.Size = UDim2.new(pct,0,1,0)
                            Label.Text = txt..": "..val
                            callback(val)
                        end
                    end)
                end,

                AddDropdown = function(_, txt, options, default, callback)
                    local Drop = Instance.new("TextButton")
                    Drop.Size = UDim2.new(1,0,0,25)
                    Drop.BackgroundColor3 = Color3.fromRGB(35,35,35)
                    Drop.Text = txt..": "..default
                    Drop.TextColor3 = Color3.fromRGB(220,220,220)
                    Drop.Font = Enum.Font.Gotham
                    Drop.TextSize = 14
                    Drop.Parent = Container

                    local Open = false
                    local ListFrame = Instance.new("Frame")
                    ListFrame.Size = UDim2.new(1,0,0,#options*25)
                    ListFrame.Position = UDim2.new(0,0,1,0)
                    ListFrame.Visible = false
                    ListFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
                    ListFrame.Parent = Drop

                    local Layout = Instance.new("UIListLayout", ListFrame)

                    for _,opt in ipairs(options) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Size = UDim2.new(1,0,0,25)
                        OptBtn.Text = opt
                        OptBtn.TextColor3 = Color3.fromRGB(200,200,200)
                        OptBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
                        OptBtn.Parent = ListFrame
                        OptBtn.MouseButton1Click:Connect(function()
                            Drop.Text = txt..": "..opt
                            ListFrame.Visible = false
                            Open = false
                            callback(opt)
                        end)
                    end

                    Drop.MouseButton1Click:Connect(function()
                        Open = not Open
                        ListFrame.Visible = Open
                    end)
                end,

                AddKeybind = function(_, txt, default, callback)
                    local Btn = Instance.new("TextButton")
                    Btn.Size = UDim2.new(1,0,0,25)
                    Btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
                    Btn.Text = txt..": "..default.Name
                    Btn.TextColor3 = Color3.fromRGB(220,220,220)
                    Btn.Font = Enum.Font.Gotham
                    Btn.TextSize = 14
                    Btn.Parent = Container

                    local waiting = false
                    Btn.MouseButton1Click:Connect(function()
                        Btn.Text = txt..": ..."
                        waiting = true
                    end)

                    UserInputService.InputBegan:Connect(function(input,gpe)
                        if waiting and not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
                            Btn.Text = txt..": "..input.KeyCode.Name
                            waiting = false
                            callback(input.KeyCode)
                        end
                    end)
                end,

                AddColorPicker = function(_, txt, default, callback)
                    local Btn = Instance.new("TextButton")
                    Btn.Size = UDim2.new(1,0,0,25)
                    Btn.BackgroundColor3 = default
                    Btn.Text = txt
                    Btn.TextColor3 = Color3.fromRGB(255,255,255)
                    Btn.Font = Enum.Font.Gotham
                    Btn.TextSize = 14
                    Btn.Parent = Container

                    Btn.MouseButton1Click:Connect(function()
                        -- simple RGB random demo
                        local col = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
                        Btn.BackgroundColor3 = col
                        callback(col)
                    end)
                end,

                AddLabel = function(_, txt)
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1,0,0,20)
                    Label.BackgroundTransparency = 1
                    Label.Text = txt
                    Label.TextColor3 = Color3.fromRGB(200,200,200)
                    Label.Font = Enum.Font.Gotham
                    Label.TextSize = 14
                    Label.Parent = Container
                end
            }
        end
    }
end

-- Visibility handling
local Visible = true
function UI:SetVisible(state)
    MainFrame.Visible = state
    Visible = state
end
function UI:ToggleUI()
    UI:SetVisible(not Visible)
end
UI:SetVisible(true)

-- RightShift toggle
UserInputService.InputBegan:Connect(function(input,gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        UI:ToggleUI()
    end
end)

return UI
