
--[[
    YRZ CLIENT | NEON UI
    UI library for Roblox / Luau
    Components: Window, Tabs, Sections, Buttons, Toggles,
    Sliders, Dropdowns, Labels and Notifications.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local YRZ = {}
YRZ.__index = YRZ

local C = {
    BG = Color3.fromRGB(10, 8, 18),
    TOP = Color3.fromRGB(18, 13, 31),
    SIDE = Color3.fromRGB(15, 11, 25),
    CARD = Color3.fromRGB(25, 19, 40),
    HOVER = Color3.fromRGB(43, 29, 65),
    BORDER = Color3.fromRGB(75, 49, 109),
    PURPLE = Color3.fromRGB(177, 76, 255),
    CYAN = Color3.fromRGB(57, 221, 255),
    WHITE = Color3.fromRGB(246, 241, 255),
    MUTED = Color3.fromRGB(166, 151, 188),
    GREEN = Color3.fromRGB(70, 230, 165),
    RED = Color3.fromRGB(255, 77, 117),
}

local function new(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function corner(obj, radius)
    new("UICorner", {
        CornerRadius = UDim.new(0, radius or 9)
    }, obj)
end

local function stroke(obj, color, transparency)
    return new("UIStroke", {
        Color = color or C.BORDER,
        Thickness = 1,
        Transparency = transparency or 0,
    }, obj)
end

local function animate(obj, props, duration, style)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(
            duration or 0.2,
            style or Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        props
    )
    t:Play()
    return t
end

local function text(parent, value, size, color, bold)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Text = value or "",
        TextSize = size or 13,
        Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium,
        TextColor3 = color or C.WHITE,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(1, 0, 0, 22),
    }, parent)
end

local function makeButton(parent, value, height)
    local b = new("TextButton", {
        AutoButtonColor = false,
        Text = value or "",
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextColor3 = C.WHITE,
        BackgroundColor3 = C.CARD,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or 36),
    }, parent)
    corner(b, 8)
    stroke(b, C.BORDER, 0.35)

    b.MouseEnter:Connect(function()
        animate(b, {BackgroundColor3 = C.HOVER}, 0.12)
    end)
    b.MouseLeave:Connect(function()
        animate(b, {BackgroundColor3 = C.CARD}, 0.15)
    end)

    return b
end

local function vertical(parent, spacing)
    return new("UIListLayout", {
        Padding = UDim.new(0, spacing or 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, parent)
end

-- Notification system
function YRZ:Notify(cfg)
    cfg = cfg or {}
    local toast = new("Frame", {
        BackgroundColor3 = C.CARD,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 68),
        Position = UDim2.new(1, 280, 0, 0),
    }, self.ToastHolder)
    corner(toast, 10)
    stroke(toast, C.PURPLE, 0.15)

    new("Frame", {
        BackgroundColor3 = C.PURPLE,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, -16),
        Position = UDim2.fromOffset(0, 8),
    }, toast)

    local title = text(toast, cfg.Title or "YRZ Client", 13, C.CYAN, true)
    title.Position = UDim2.fromOffset(13, 7)
    title.Size = UDim2.new(1, -22, 0, 21)

    local body = text(toast, cfg.Content or "Notification", 11, C.MUTED)
    body.Position = UDim2.fromOffset(13, 30)
    body.Size = UDim2.new(1, -22, 0, 25)
    body.TextWrapped = true

    animate(toast, {Position = UDim2.new(0, 0, 0, 0)}, 0.35, Enum.EasingStyle.Back)

    task.delay(cfg.Duration or 3, function()
        if toast.Parent then
            animate(toast, {
                Position = UDim2.new(1, 280, 0, 0),
                BackgroundTransparency = 1,
            }, 0.2)
            task.wait(0.25)
            if toast.Parent then toast:Destroy() end
        end
    end)
end

-- Create main window
function YRZ:CreateWindow(cfg)
    cfg = cfg or {}
    local player = Players.LocalPlayer
    assert(player, "YRZ Client must run on the client.")

    local playerGui = player:WaitForChild("PlayerGui")
    local previous = playerGui:FindFirstChild("YRZ_Client")
    if previous then previous:Destroy() end

    local gui = new("ScreenGui", {
        Name = "YRZ_Client",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, playerGui)

    local shadow = new("Frame", {
        Name = "WindowShadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(660, 455),
        BackgroundColor3 = C.PURPLE,
        BackgroundTransparency = 0.91,
        BorderSizePixel = 0,
    }, gui)
    corner(shadow, 17)

    local scale = new("UIScale", {Scale = 0.88}, shadow)

    local main = new("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(650, 445),
        BackgroundColor3 = C.BG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, shadow)
    corner(main, 15)
    stroke(main, C.BORDER, 0.05)

    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 15, 42)),
            ColorSequenceKeypoint.new(1, C.BG),
        }),
        Rotation = 35,
    }, main)

    -- Top bar
    local top = new("Frame", {
        Name = "Topbar",
        BackgroundColor3 = C.TOP,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 57),
    }, main)

    local logo = new("Frame", {
        BackgroundColor3 = C.PURPLE,
        Position = UDim2.fromOffset(14, 11),
        Size = UDim2.fromOffset(35, 35),
        BorderSizePixel = 0,
    }, top)
    corner(logo, 10)

    local logoText = text(logo, "Y", 21, C.WHITE, true)
    logoText.TextXAlignment = Enum.TextXAlignment.Center

    local title = text(top, cfg.Name or "YRZ Client", 15, C.WHITE, true)
    title.Position = UDim2.fromOffset(59, 7)
    title.Size = UDim2.new(0, 280, 0, 23)

    local subtitle = text(top, cfg.Subtitle or "NEON EDITION", 10, C.CYAN, true)
    subtitle.Position = UDim2.fromOffset(60, 30)
    subtitle.Size = UDim2.new(0, 260, 0, 16)

    local close = makeButton(top, "×", 30)
    close.Position = UDim2.new(1, -42, 0, 13)
    close.Size = UDim2.fromOffset(29, 30)
    close.TextSize = 21
    close.TextColor3 = C.RED

    local minimize = makeButton(top, "−", 30)
    minimize.Position = UDim2.new(1, -78, 0, 13)
    minimize.Size = UDim2.fromOffset(29, 30)
    minimize.TextSize = 18
    minimize.TextColor3 = C.CYAN

    -- Sidebar
    local sidebar = new("Frame", {
        Name = "Sidebar",
        Position = UDim2.fromOffset(0, 57),
        Size = UDim2.new(0, 157, 1, -57),
        BackgroundColor3 = C.SIDE,
        BorderSizePixel = 0,
    }, main)

    local navLabel = text(sidebar, "  WORKSPACE", 10, C.MUTED, true)
    navLabel.Position = UDim2.fromOffset(9, 12)
    navLabel.Size = UDim2.new(1, -18, 0, 22)

    local nav = new("ScrollingFrame", {
        Position = UDim2.fromOffset(8, 40),
        Size = UDim2.new(1, -16, 1, -50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = C.PURPLE,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
    }, sidebar)
    vertical(nav, 7)

    -- Page heading and content
    local pageTitle = text(main, "Home", 18, C.WHITE, true)
    pageTitle.Position = UDim2.fromOffset(178, 73)
    pageTitle.Size = UDim2.new(1, -200, 0, 25)

    local pageDescription = text(main, "Welcome to your workspace", 11, C.MUTED)
    pageDescription.Position = UDim2.fromOffset(179, 99)
    pageDescription.Size = UDim2.new(1, -200, 0, 18)

    local pages = new("Frame", {
        Name = "Pages",
        Position = UDim2.fromOffset(171, 126),
        Size = UDim2.new(1, -185, 1, -140),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, main)

    -- Toast area
    local toastHolder = new("Frame", {
        Position = UDim2.new(1, -285, 0, 15),
        Size = UDim2.fromOffset(270, 250),
        BackgroundTransparency = 1,
    }, gui)
    vertical(toastHolder, 8)

    local self = setmetatable({
        GUI = gui,
        Main = main,
        Pages = pages,
        Nav = nav,
        PageTitle = pageTitle,
        PageDescription = pageDescription,
        Tabs = {},
        ActiveTab = nil,
        ToastHolder = toastHolder,
        Minimized = false,
    }, YRZ)

    -- Drag window
    local dragging, dragStart, startPosition
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = shadow.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart
            shadow.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    close.MouseButton1Click:Connect(function()
        animate(scale, {Scale = 0.85}, 0.18)
        task.wait(0.19)
        if gui.Parent then gui:Destroy() end
    end)

    minimize.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        animate(main, {
            Size = self.Minimized
                and UDim2.fromOffset(650, 57)
                or UDim2.fromOffset(650, 445),
        }, 0.22)
        animate(shadow, {
            Size = self.Minimized
                and UDim2.fromOffset(660, 67)
                or UDim2.fromOffset(660, 455),
        }, 0.22)
        minimize.Text = self.Minimized and "+" or "−"
    end)

    animate(scale, {Scale = 1}, 0.4, Enum.EasingStyle.Back)

    return self
end

-- Tabs
function YRZ:CreateTab(name, description)
    local tab = {
        Name = name or "Tab",
        Description = description or "Manage your settings",
        Window = self,
        Sections = {},
    }

    local navButton = makeButton(self.Nav, "   ◈   " .. tab.Name, 37)
    navButton.TextXAlignment = Enum.TextXAlignment.Left
    navButton.LayoutOrder = #self.Tabs + 1

    local page = new("ScrollingFrame", {
        Name = tab.Name .. "Page",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.PURPLE,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Visible = false,
    }, self.Pages)

    new("UIPadding", {
        PaddingRight = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 8),
    }, page)
    vertical(page, 10)

    tab.Button = navButton
    tab.Page = page
    table.insert(self.Tabs, tab)

    local function selectTab()
        for _, other in ipairs(self.Tabs) do
            other.Page.Visible = false
            animate(other.Button, {
                BackgroundColor3 = C.CARD,
                TextColor3 = C.MUTED,
            }, 0.15)
        end

        page.Visible = true
        page.Position = UDim2.fromOffset(8, 0)
        animate(page, {Position = UDim2.fromOffset(0, 0)}, 0.22)
        animate(navButton, {
            BackgroundColor3 = C.PURPLE,
            TextColor3 = C.WHITE,
        }, 0.2)

        self.PageTitle.Text = tab.Name
        self.PageDescription.Text = tab.Description
        self.ActiveTab = tab
    end

    navButton.MouseButton1Click:Connect(selectTab)
    if #self.Tabs == 1 then selectTab() end

    function tab:CreateSection(sectionName)
        local section = {
            Name = sectionName or "Section",
            Tab = self,
            Window = self.Window,
        }

        local card = new("Frame", {
            Name = section.Name,
            BackgroundColor3 = C.CARD,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -3, 0, 45),
            AutomaticSize = Enum.AutomaticSize.Y,
        }, self.Page)
        corner(card, 10)
        stroke(card, C.BORDER, 0.4)

        new("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 11),
            PaddingLeft = UDim.new(0, 11),
            PaddingRight = UDim.new(0, 11),
        }, card)

        local heading = text(card, string.upper(section.Name), 11, C.CYAN, true)
        heading.Size = UDim2.new(1, 0, 0, 19)

        local holder = new("Frame", {
            Position = UDim2.fromOffset(0, 25),
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
        }, card)
        vertical(holder, 7)

        section.Container = holder

        function section:CreateLabel(cfg)
            cfg = typeof(cfg) == "table" and cfg or {Text = tostring(cfg)}
            local l = text(self.Container, cfg.Text or cfg.Name or "Label", 12, C.MUTED)
            l.Size = UDim2.new(1, 0, 0, 26)
            l.TextWrapped = true
            return {
                SetText = function(_, value) l.Text = tostring(value) end,
                Frame = l,
            }
        end

        function section:CreateButton(cfg)
            cfg = typeof(cfg) == "table" and cfg or {Name = tostring(cfg)}
            local b = makeButton(self.Container, cfg.Name or "Button", 36)
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Text = "   " .. b.Text
            local arrow = text(b, "›", 20, C.PURPLE, true)
            arrow.TextXAlignment = Enum.TextXAlignment.Center
            arrow.AnchorPoint = Vector2.new(1, 0)
            arrow.Position = UDim2.new(1, -8, 0, 0)
            arrow.Size = UDim2.fromOffset(20, 36)
            b.MouseButton1Click:Connect(function()
                if typeof(cfg.Callback) == "function" then
                    task.spawn(cfg.Callback)
                end
            end)
            return {
                Frame = b,
                Fire = function()
                    if cfg.Callback then task.spawn(cfg.Callback) end
                end,
            }
        end

        function section:CreateToggle(cfg)
            cfg = cfg or {}
            local f = new("Frame", {
                BackgroundColor3 = C.CARD,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 38),
            }, self.Container)
            corner(f, 8)

            local l = text(f, cfg.Name or "Toggle", 12, C.WHITE)
            l.Position = UDim2.fromOffset(10, 0)
            l.Size = UDim2.new(1, -60, 1, 0)

            local track = new("Frame", {
                BackgroundColor3 = C.BORDER,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -9, 0.5, 0),
                Size = UDim2.fromOffset(35, 18),
            }, f)
            corner(track, 20)

            local knob = new("Frame", {
                BackgroundColor3 = C.WHITE,
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.fromOffset(14, 14),
            }, track)
            corner(knob, 20)

            local hit = new("TextButton", {
                BackgroundTransparency = 1,
                Text = "",
                Size = UDim2.fromScale(1, 1),
            }, f)

            local value = cfg.Default == true
            local function render()
                animate(track, {
                    BackgroundColor3 = value and C.PURPLE or C.BORDER,
                }, 0.17)
                animate(knob, {
                    Position = value
                        and UDim2.new(1, -16, 0, 2)
                        or UDim2.fromOffset(2, 2),
                }, 0.17)
            end

            local function set(v, silent)
                value = not not v
                render()
                if not silent and typeof(cfg.Callback) == "function" then
                    task.spawn(cfg.Callback, value)
                end
            end

            hit.MouseButton1Click:Connect(function()
                set(not value)
            end)
            render()

            return {
                Frame = f,
                Get = function() return value end,
                Set = function(_, v) set(v) end,
            }
        end

        function section:CreateSlider(cfg)
            cfg = cfg or {}
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            local value = math.clamp(cfg.Default or min, min, max)

            local f = new("Frame", {
                BackgroundColor3 = C.CARD,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 57),
            }, self.Container)
            corner(f, 8)

            local l = text(f, cfg.Name or "Slider", 12, C.WHITE)
            l.Position = UDim2.fromOffset(10, 4)
            l.Size = UDim2.new(1, -75, 0, 20)

            local number = text(f, tostring(value), 11, C.CYAN, true)
            number.TextXAlignment = Enum.TextXAlignment.Right
            number.Position = UDim2.new(1, -65, 0, 4)
            number.Size = UDim2.fromOffset(55, 20)

            local rail = new("Frame", {
                BackgroundColor3 = C.BORDER,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 36),
                Size = UDim2.new(1, -20, 0, 5),
            }, f)
            corner(rail, 5)

            local fill = new("Frame", {
                BackgroundColor3 = C.PURPLE,
                BorderSizePixel = 0,
                Size = UDim2.new((value - min) / math.max(max - min, 0.001), 0, 1, 0),
            }, rail)
            corner(fill, 5)

            local knob = new("Frame", {
                BackgroundColor3 = C.WHITE,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new((value - min) / math.max(max - min, 0.001), 0, 0.5, 0),
                Size = UDim2.fromOffset(12, 12),
            }, rail)
            corner(knob, 8)
            stroke(knob, C.PURPLE)

            local hit = new("TextButton", {
                BackgroundTransparency = 1,
                Text = "",
                Position = UDim2.new(0, 0, 0, -8),
                Size = UDim2.new(1, 0, 0, 22),
            }, rail)

            local dragging = false
            local function set(v, silent)
                value = math.clamp(v, min, max)
                local pct = (value - min) / math.max(max - min, 0.001)
                animate(fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.08)
                animate(knob, {Position = UDim2.new(pct, 0, 0.5, 0)}, 0.08)
                number.Text = tostring(math.floor(value * 100 + 0.5) / 100)
                if not silent and typeof(cfg.Callback) == "function" then
                    task.spawn(cfg.Callback, value)
                end
            end

            local function update(input)
                local pct = math.clamp(
                    (input.Position.X - rail.AbsolutePosition.X) /
                    math.max(rail.AbsoluteSize.X, 1),
                    0, 1
                )
                set(min + (max - min) * pct)
            end

            hit.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                ) then
                    update(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            return {
                Frame = f,
                Get = function() return value end,
                Set = function(_, v) set(v) end,
            }
        end

        function section:CreateDropdown(cfg)
            cfg = cfg or {}
            local options = cfg.Options or {}
            local selected = cfg.Default or options[1]

            local holder = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 36),
                ClipsDescendants = true,
            }, self.Container)

            local head = makeButton(
                holder,
                (cfg.Name or "Dropdown") .. "  ▾  " .. tostring(selected or "Select"),
                36
            )
            head.TextXAlignment = Enum.TextXAlignment.Left

            local expanded = false
            local function toggle()
                expanded = not expanded
                if expanded then
                    for _, child in ipairs(holder:GetChildren()) do
                        if child.Name == "Option" then child:Destroy() end
                    end

                    for i, option in ipairs(options) do
                        local opt = makeButton(holder, tostring(option), 30)
                        opt.Name = "Option"
                        opt.Position = UDim2.fromOffset(0, 40 + (i - 1) * 34)
                        opt.MouseButton1Click:Connect(function()
                            selected = option
                            head.Text = (cfg.Name or "Dropdown") .. "  ▾  " .. tostring(option)
                            expanded = false
                            animate(holder, {Size = UDim2.new(1, 0, 0, 36)}, 0.18)
                            if typeof(cfg.Callback) == "function" then
                                task.spawn(cfg.Callback, selected)
                            end
                        end)
                    end
                    animate(holder, {
                        Size = UDim2.new(1, 0, 0, 40 + #options * 34),
                    }, 0.2)
                else
                    animate(holder, {Size = UDim2.new(1, 0, 0, 36)}, 0.18)
                end
            end

            head.MouseButton1Click:Connect(toggle)
            return {
                Frame = holder,
                Get = function() return selected end,
                Set = function(_, value)
                    selected = value
                    head.Text = (cfg.Name or "Dropdown") .. "  ▾  " .. tostring(value)
                end,
            }
        end

        table.insert(self.Sections, section)
        return section
    end

    return tab
end

return YRZ
