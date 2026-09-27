--[[
    NonoLib v1.0
    UI Library injectable - Inspiré de Rayfield, Fluent, XenaScript, PulseHub
    Par Nono — from scratch, aucune lib externe
]]

local NonoLib = {}
NonoLib.__index = NonoLib

-- ============================================================
--  SERVICES
-- ============================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
--  DETECTION MOBILE
-- ============================================================
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ============================================================
--  UTILS INTERNES
-- ============================================================
local function tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(t or 0.25, style, dir), props):Play()
end

local function newInst(class, props, parent)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do i[k] = v end
    if parent then i.Parent = parent end
    return i
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
--  THEME
-- ============================================================
local Theme = {
    Background   = Color3.fromRGB(12, 12, 18),
    Surface      = Color3.fromRGB(18, 18, 28),
    SurfaceLight = Color3.fromRGB(26, 26, 40),
    Accent       = Color3.fromRGB(120, 80, 255),
    AccentHover  = Color3.fromRGB(140, 100, 255),
    Text         = Color3.fromRGB(230, 230, 240),
    SubText      = Color3.fromRGB(140, 140, 160),
    Border       = Color3.fromRGB(40, 40, 60),
    Success      = Color3.fromRGB(80, 200, 120),
    Danger       = Color3.fromRGB(220, 70, 70),
    Warning      = Color3.fromRGB(220, 170, 60),
    Shadow       = Color3.fromRGB(0, 0, 0),
}

-- ============================================================
--  ROOT GUI
-- ============================================================
local ScreenGui = newInst("ScreenGui", {
    Name            = "NonoLib",
    ResetOnSpawn    = false,
    ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    DisplayOrder    = 999,
})

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ============================================================
--  NOTIFICATION SYSTEM
-- ============================================================
local NotifHolder = newInst("Frame", {
    Size            = UDim2.new(0, 300, 1, 0),
    Position        = UDim2.new(1, -310, 0, 0),
    BackgroundTransparency = 1,
    AnchorPoint     = Vector3.new and nil or nil,
}, ScreenGui)

newInst("UIListLayout", {
    SortOrder       = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding         = UDim.new(0, 8),
}, NotifHolder)

function NonoLib:Notify(opts)
    opts = opts or {}
    local title   = opts.Title   or "NonoLib"
    local desc    = opts.Description or ""
    local ntype   = opts.Type    or "info"  -- info / success / danger / warning
    local duration = opts.Duration or 4

    local color = Theme.Accent
    if ntype == "success" then color = Theme.Success
    elseif ntype == "danger"  then color = Theme.Danger
    elseif ntype == "warning" then color = Theme.Warning end

    local notif = newInst("Frame", {
        Size                  = UDim2.new(1, 0, 0, 70),
        BackgroundColor3      = Theme.Surface,
        BackgroundTransparency = 0,
        BorderSizePixel       = 0,
        ClipsDescendants      = true,
    }, NotifHolder)
    newInst("UICorner",   { CornerRadius = UDim.new(0, 10) }, notif)
    newInst("UIStroke",   { Color = color, Thickness = 1.5, Transparency = 0.4 }, notif)

    -- Accent bar gauche
    newInst("Frame", {
        Size             = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = color,
        BorderSizePixel  = 0,
    }, notif)

    newInst("TextLabel", {
        Text              = title,
        Font              = Enum.Font.GothamBold,
        TextSize          = 14,
        TextColor3        = Theme.Text,
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, -16, 0, 20),
        Position          = UDim2.new(0, 12, 0, 8),
        TextXAlignment    = Enum.TextXAlignment.Left,
    }, notif)

    newInst("TextLabel", {
        Text              = desc,
        Font              = Enum.Font.Gotham,
        TextSize          = 12,
        TextColor3        = Theme.SubText,
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, -16, 0, 32),
        Position          = UDim2.new(0, 12, 0, 30),
        TextXAlignment    = Enum.TextXAlignment.Left,
        TextWrapped       = true,
    }, notif)

    -- Progress bar
    local bar = newInst("Frame", {
        Size             = UDim2.new(1, 0, 0, 3),
        Position         = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = color,
        BorderSizePixel  = 0,
    }, notif)

    notif.Position = UDim2.new(1, 10, 0, 0)
    tween(notif, { Position = UDim2.new(0, 0, 0, 0) }, 0.35)
    tween(bar, { Size = UDim2.new(0, 0, 0, 3) }, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

    task.delay(duration, function()
        tween(notif, { Position = UDim2.new(1, 10, 0, 0) }, 0.3)
        task.wait(0.35)
        notif:Destroy()
    end)
end

-- ============================================================
--  MOBILE TOGGLE BUTTON
-- ============================================================
local MobileToggle
local WindowRef

if isMobile then
    MobileToggle = newInst("TextButton", {
        Text              = "☰",
        Font              = Enum.Font.GothamBold,
        TextSize          = 20,
        TextColor3        = Theme.Text,
        Size              = UDim2.new(0, 48, 0, 48),
        Position          = UDim2.new(0, 10, 0.5, -24),
        BackgroundColor3  = Theme.Accent,
        BorderSizePixel   = 0,
        ZIndex            = 999,
    }, ScreenGui)
    newInst("UICorner", { CornerRadius = UDim.new(1, 0) }, MobileToggle)
    newInst("UIStroke", { Color = Theme.AccentHover, Thickness = 2 }, MobileToggle)
    makeDraggable(MobileToggle)
end

-- ============================================================
--  WINDOW
-- ============================================================
function NonoLib:CreateWindow(opts)
    opts = opts or {}
    local title    = opts.Title    or "NonoLib"
    local subtitle = opts.Subtitle or "v1.0"
    local size     = opts.Size     or UDim2.new(0, 580, 0, 420)

    -- Backdrop blur fake (frame sombre)
    local Backdrop = newInst("Frame", {
        Size                  = UDim2.new(1, 0, 1, 0),
        BackgroundColor3      = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.5,
        ZIndex                = 1,
        Visible               = false,
    }, ScreenGui)

    -- Main Window
    local Win = newInst("Frame", {
        Size                  = size,
        Position              = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint           = Vector2.new(0.5, 0.5),
        BackgroundColor3      = Theme.Background,
        BorderSizePixel       = 0,
        ClipsDescendants      = true,
        ZIndex                = 2,
        Visible               = not isMobile,
    }, ScreenGui)
    newInst("UICorner", { CornerRadius = UDim.new(0, 14) }, Win)
    newInst("UIStroke", { Color = Theme.Border, Thickness = 1.5 }, Win)

    -- Shadow
    local Shadow = newInst("ImageLabel", {
        Size              = UDim2.new(1, 40, 1, 40),
        Position          = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image             = "rbxassetid://6014261993",
        ImageColor3       = Theme.Shadow,
        ImageTransparency = 0.5,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(49, 49, 450, 450),
        ZIndex            = 1,
    }, Win)

    -- TOPBAR
    local TopBar = newInst("Frame", {
        Size             = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, Win)
    newInst("UICorner", { CornerRadius = UDim.new(0, 14) }, TopBar)

    -- Fix coins bas du topbar
    newInst("Frame", {
        Size             = UDim2.new(1, 0, 0, 14),
        Position         = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, TopBar)

    -- Accent dot
    newInst("Frame", {
        Size             = UDim2.new(0, 8, 0, 8),
        Position         = UDim2.new(0, 16, 0.5, -4),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 4,
    }, TopBar):FindFirstChildOfClass("UICorner") or newInst("UICorner", { CornerRadius = UDim.new(1,0) }, TopBar:FindFirstChild("Frame") or TopBar)

    -- Title
    newInst("TextLabel", {
        Text              = title,
        Font              = Enum.Font.GothamBold,
        TextSize          = 16,
        TextColor3        = Theme.Text,
        BackgroundTransparency = 1,
        Size              = UDim2.new(0, 300, 1, 0),
        Position          = UDim2.new(0, 32, 0, 0),
        TextXAlignment    = Enum.TextXAlignment.Left,
        ZIndex            = 4,
    }, TopBar)

    -- Subtitle
    newInst("TextLabel", {
        Text              = subtitle,
        Font              = Enum.Font.Gotham,
        TextSize          = 12,
        TextColor3        = Theme.SubText,
        BackgroundTransparency = 1,
        Size              = UDim2.new(0, 200, 1, 0),
        Position          = UDim2.new(0, 120, 0, 2),
        TextXAlignment    = Enum.TextXAlignment.Left,
        ZIndex            = 4,
    }, TopBar)

    -- Minimize/Close buttons
    local CloseBtn = newInst("TextButton", {
        Text              = "✕",
        Font              = Enum.Font.GothamBold,
        TextSize          = 14,
        TextColor3        = Theme.SubText,
        Size              = UDim2.new(0, 28, 0, 28),
        Position          = UDim2.new(1, -38, 0.5, -14),
        BackgroundColor3  = Theme.SurfaceLight,
        BorderSizePixel   = 0,
        ZIndex            = 5,
    }, TopBar)
    newInst("UICorner", { CornerRadius = UDim.new(0, 8) }, CloseBtn)

    local MinBtn = newInst("TextButton", {
        Text              = "–",
        Font              = Enum.Font.GothamBold,
        TextSize          = 16,
        TextColor3        = Theme.SubText,
        Size              = UDim2.new(0, 28, 0, 28),
        Position          = UDim2.new(1, -72, 0.5, -14),
        BackgroundColor3  = Theme.SurfaceLight,
        BorderSizePixel   = 0,
        ZIndex            = 5,
    }, TopBar)
    newInst("UICorner", { CornerRadius = UDim.new(0, 8) }, MinBtn)

    makeDraggable(Win, TopBar)

    -- SIDEBAR (tabs)
    local Sidebar = newInst("Frame", {
        Size             = UDim2.new(0, 140, 1, -48),
        Position         = UDim2.new(0, 0, 0, 48),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, Win)

    newInst("UIListLayout", {
        SortOrder         = Enum.SortOrder.LayoutOrder,
        Padding           = UDim.new(0, 4),
    }, Sidebar)
    newInst("UIPadding", {
        PaddingTop    = UDim.new(0, 10),
        PaddingLeft   = UDim.new(0, 8),
        PaddingRight  = UDim.new(0, 8),
    }, Sidebar)

    -- CONTENT AREA
    local ContentArea = newInst("Frame", {
        Size             = UDim2.new(1, -140, 1, -48),
        Position         = UDim2.new(0, 140, 0, 48),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = 3,
    }, Win)

    -- Minimize logic
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(Win, {
            Size = minimized
                and UDim2.new(0, size.X.Offset, 0, 48)
                or  size
        }, 0.3)
    end)

    -- Close logic
    CloseBtn.MouseButton1Click:Connect(function()
        tween(Win, { Size = UDim2.new(0, size.X.Offset, 0, 0) }, 0.25)
        task.wait(0.3)
        Win.Visible = false
    end)

    -- Mobile toggle
    if isMobile and MobileToggle then
        MobileToggle.MouseButton1Click:Connect(function()
            Win.Visible = not Win.Visible
            Backdrop.Visible = Win.Visible
            if Win.Visible then
                Win.Size = UDim2.new(0, 0, 0, 0)
                tween(Win, { Size = size }, 0.3)
            end
        end)
    end

    -- =========================================================
    --  WINDOW OBJECT
    -- =========================================================
    local Window    = {}
    local tabs      = {}
    local activeTab = nil

    local function setActiveTab(tab)
        for _, t in pairs(tabs) do
            tween(t.Button, { BackgroundColor3 = Theme.SurfaceLight }, 0.2)
            t.Button.TextColor3 = Theme.SubText
            t.Content.Visible   = false
        end
        tween(tab.Button, { BackgroundColor3 = Theme.Accent }, 0.2)
        tab.Button.TextColor3 = Theme.Text
        tab.Content.Visible   = true
        activeTab = tab
    end

    -- =========================================================
    --  CREATE TAB
    -- =========================================================
    function Window:CreateTab(opts2)
        opts2 = opts2 or {}
        local tabName = opts2.Name or "Tab"
        local tabIcon = opts2.Icon or ""

        -- Tab button in sidebar
        local TabBtn = newInst("TextButton", {
            Text              = tabIcon ~= "" and (tabIcon .. "  " .. tabName) or tabName,
            Font              = Enum.Font.GothamSemibold,
            TextSize          = 13,
            TextColor3        = Theme.SubText,
            Size              = UDim2.new(1, 0, 0, 36),
            BackgroundColor3  = Theme.SurfaceLight,
            BorderSizePixel   = 0,
            TextXAlignment    = Enum.TextXAlignment.Left,
            ZIndex            = 4,
        }, Sidebar)
        newInst("UICorner",  { CornerRadius = UDim.new(0, 8) }, TabBtn)
        newInst("UIPadding", { PaddingLeft = UDim.new(0, 10) }, TabBtn)

        -- Tab content scroll
        local TabContent = newInst("ScrollingFrame", {
            Size              = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel   = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            Visible           = false,
            ZIndex            = 4,
            CanvasSize        = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, ContentArea)
        newInst("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 8),
        }, TabContent)
        newInst("UIPadding", {
            PaddingTop    = UDim.new(0, 12),
            PaddingLeft   = UDim.new(0, 12),
            PaddingRight  = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12),
        }, TabContent)

        local tabObj = { Button = TabBtn, Content = TabContent }
        table.insert(tabs, tabObj)

        if #tabs == 1 then setActiveTab(tabObj) end

        TabBtn.MouseButton1Click:Connect(function()
            setActiveTab(tabObj)
        end)

        -- =====================================================
        --  TAB API
        -- =====================================================
        local Tab = {}

        -- SECTION LABEL
        function Tab:Section(name)
            local sec = newInst("TextLabel", {
                Text              = name,
                Font              = Enum.Font.GothamBold,
                TextSize          = 11,
                TextColor3        = Theme.Accent,
                BackgroundTransparency = 1,
                Size              = UDim2.new(1, 0, 0, 24),
                TextXAlignment    = Enum.TextXAlignment.Left,
                ZIndex            = 5,
            }, TabContent)
            return sec
        end

        -- BUTTON
        function Tab:Button(bopts)
            bopts = bopts or {}
            local label    = bopts.Name     or "Button"
            local desc     = bopts.Description or ""
            local callback = bopts.Callback or function() end

            local Holder = newInst("Frame", {
                Size             = UDim2.new(1, 0, 0, 48),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel  = 0,
                ZIndex           = 5,
            }, TabContent)
            newInst("UICorner", { CornerRadius = UDim.new(0, 10) }, Holder)

            newInst("TextLabel", {
                Text              = label,
                Font              = Enum.Font.GothamSemibold,
                TextSize          = 14,
                TextColor3        = Theme.Text,
                BackgroundTransparency = 1,
                Size              = UDim2.new(1, -100, 0, 24),
                Position          = UDim2.new(0, 14, 0, 6),
                TextXAlignment    = Enum.TextXAlignment.Left,
                ZIndex            = 6,
            }, Holder)

            if desc ~= "" then
                newInst("TextLabel", {
                    Text              = desc,
                    Font              = Enum.Font.Gotham,
                    TextSize          = 11,
                    TextColor3        = Theme.SubText,
                    BackgroundTransparency = 1,
                    Size              = UDim2.new(1, -100, 0, 18),
                    Position          = UDim2.new(0, 14, 0, 28),
                    TextXAlignment    = Enum.TextXAlignment.Left,
                    ZIndex            = 6,
                }, Holder)
            end

            local Btn = newInst("TextButton", {
                Text              = "Run",
                Font              = Enum.Font.GothamBold,
                TextSize          = 12,
                TextColor3        = Theme.Text,
                Size              = UDim2.new(0, 70, 0, 28),
                Position          = UDim2.new(1, -82, 0.5, -14),
                BackgroundColor3  = Theme.Accent,
                BorderSizePixel   = 0,
                ZIndex            = 6,
            }, Holder)
            newInst("UICorner", { CornerRadius = UDim.new(0, 8) }, Btn)

            Btn.MouseButton1Click:Connect(function()
                tween(Btn, { BackgroundColor3 = Theme.AccentHover }, 0.1)
                task.wait(0.15)
                tween(Btn, { BackgroundColor3 = Theme.Accent }, 0.15)
                pcall(callback)
            end)
        end

        -- TOGGLE
        function Tab:Toggle(topts)
            topts = topts or {}
            local label    = topts.Name     or "Toggle"
            local desc     = topts.Description or ""
            local default  = topts.Default  or false
            local callback = topts.Callback or function() end
            local state    = default

            local Holder = newInst("Frame", {
                Size             = UDim2.new(1, 0, 0, 48),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel  = 0,
                ZIndex           = 5,
            }, TabContent)
            newInst("UICorner", { CornerRadius = UDim.new(0, 10) }, Holder)

            newInst("TextLabel", {
                Text              = label,
                Font              = Enum.Font.GothamSemibold,
                TextSize          = 14,
                TextColor3        = Theme.Text,
                BackgroundTransparency = 1,
                Size              = UDim2.new(1, -80, 0, 24),
                Position          = UDim2.new(0, 14, 0, 6),
                TextXAlignment    = Enum.TextXAlignment.Left,
                ZIndex            = 6,
            }, Holder)

            if desc ~= "" then
                newInst("TextLabel", {
                    Text              = desc,
                    Font              = Enum.Font.Gotham,
                    TextSize          = 11,
                    TextColor3        = Theme.SubText,
                    BackgroundTransparency = 1,
                    Size              = UDim2.new(1, -80, 0, 18),
                    Position          = UDim2.new(0, 14, 0, 28),
                    TextXAlignment    = Enum.TextXAlignment.Left,
                    ZIndex            = 6,
                }, Holder)
            end

            -- Toggle track
            local Track = newInst("Frame", {
                Size             = UDim2.new(0, 44, 0, 24),
                Position         = UDim2.new(1, -58, 0.5, -12),
                BackgroundColor3 = state and Theme.Accent or Theme.SurfaceLight,
                BorderSizePixel  = 0,
                ZIndex           = 6,
            }, Holder)
            newInst("UICorner", { CornerRadius = UDim.new(1, 0) }, Track)

            -- Thumb
            local Thumb = newInst("Frame", {
                Size             = UDim2.new(0, 18, 0, 18),
                Position         = state
                    and UDim2.new(0, 23, 0.5, -9)
                    or  UDim2.new(0, 3,  0.5, -9),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel  = 0,
                ZIndex           = 7,
            }, Track)
            newInst("UICorner", { CornerRadius = UDim.new(1, 0) }, Thumb)

            local ClickArea = newInst("TextButton", {
                Text              = "",
                Size              = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex            = 8,
            }, Holder)

            ClickArea.MouseButton1Click:Connect(function()
                state = not state
                tween(Track, {
                    BackgroundColor3 = state and Theme.Accent or Theme.SurfaceLight
                }, 0.2)
                tween(Thumb, {
                    Position = state
                        and UDim2.new(0, 23, 0.5, -9)
                        or  UDim2.new(0, 3,  0.5, -9)
                }, 0.2)
                pcall(callback, state)
            end)

            local ToggleObj = {}
            function ToggleObj:Set(v)
                state = v
                tween(Track, { BackgroundColor3 = v and Theme.Accent or Theme.SurfaceLight }, 0.2)
                tween(Thumb, {
                    Position = v
                        and UDim2.new(0, 23, 0.5, -9)
                        or  UDim2.new(0, 3,  0.5, -9)
                }, 0.2)
                pcall(callback, v)
            end
            return ToggleObj
        end

        -- SLIDER
        function Tab:Slider(sopts)
            sopts = sopts or {}
            local label    = sopts.Name     or "Slider"
            local desc     = sopts.Description or ""
            local min      = sopts.Min      or 0
            local max      = sopts.Max      or 100
            local default  = sopts.Default  or min
            local callback = sopts.Callback or function() end
            local val      = default

            local Holder = newInst("Frame", {
                Size             = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel  = 0,
                ZIndex           = 5,
            }, TabContent)
            newInst("UICorner", { CornerRadius = UDim.new(0, 10) }, Holder)

            newInst("TextLabel", {
                Text              = label,
                Font              = Enum.Font.GothamSemibold,
                TextSize          = 14,
                TextColor3        = Theme.Text,
                BackgroundTransparency = 1,
                Size              = UDim2.new(1, -60, 0, 22),
                Position          = UDim2.new(0, 14, 0, 8),
                TextXAlignment    = Enum.TextXAlignment.Left,
                ZIndex            = 6,
            }, Holder)

            local ValLabel = newInst("TextLabel", {
                Text              = tostring(val),
                Font              = Enum.Font.GothamBold,
                TextSize          = 13,
                TextColor3        = Theme.Accent,
                BackgroundTransparency = 1,
                Size              = UDim2.new(0, 50, 0, 22),
                Position          = UDim2.new(1, -64, 0, 8),
                TextXAlignment    = Enum.TextXAlignment.Right,
                ZIndex            = 6,
            }, Holder)

            -- Track bg
            local TrackBg = newInst("Frame", {
                Size             = UDim2.new(1, -28, 0, 6),
                Position         = UDim2.new(0, 14, 0, 42),
                BackgroundColor3 = Theme.SurfaceLight,
                BorderSizePixel  = 0,
                ZIndex           = 6,
            }, Holder)
            newInst("UICorner", { CornerRadius = UDim.new(1, 0) }, TrackBg)

            -- Fill
            local Fill = newInst("Frame", {
                Size             = UDim2.new((val - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel  = 0,
                ZIndex           = 7,
            }, TrackBg)
            newInst("UICorner", { CornerRadius = UDim.new(1, 0) }, Fill)

            -- Knob
            local Knob = newInst("Frame", {
                Size             = UDim2.new(0, 16, 0, 16),
                Position         = UDim2.new((val - min) / (max - min), -8, 0.5, -8),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel  = 0,
                ZIndex           = 8,
            }, TrackBg)
            newInst("UICorner", { CornerRadius = UDim.new(1, 0) }, Knob)

            -- Drag logic
            local sliding = false
            TrackBg.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement
                    or inp.UserInputType == Enum.UserInputType.Touch) then
                    local absPos  = TrackBg.AbsolutePosition.X
                    local absSize = TrackBg.AbsoluteSize.X
                    local rel     = math.clamp((inp.Position.X - absPos) / absSize, 0, 1)
                    val = math.floor(min + rel * (max - min))
                    ValLabel.Text = tostring(val)
                    Fill.Size     = UDim2.new(rel, 0, 1, 0)
                    Knob.Position = UDim2.new(rel, -8, 0.5, -8)
                    pcall(callback, val)
                end
            end)
        end

        -- DROPDOWN
        function Tab:Dropdown(dopts)
            dopts = dopts or {}
            local label    = dopts.Name     or "Dropdown"
            local options  = dopts.Options  or {}
            local callback = dopts.Callback or function() end
            local selected = options[1] or "Select"

            local Holder = newInst("Frame", {
                Size             = UDim2.new(1, 0, 0, 48),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel  = 0,
                ClipsDescendants = false,
                ZIndex           = 5,
            }, TabContent)
            newInst("UICorner", { CornerRadius = UDim.new(0, 10) }, Holder)

            newInst("TextLabel", {
                Text              = label,
                Font              = Enum.Font.GothamSemibold,
                TextSize          = 14,
                TextColor3        = Theme.Text,
                BackgroundTransparency = 1,
                Size              = UDim2.new(0.5, 0, 1, 0),
                Position          = UDim2.new(0, 14, 0, 0),
                TextXAlignment    = Enum.TextXAlignment.Left,
                ZIndex            = 6,
            }, Holder)

            local SelBtn = newInst("TextButton", {
                Text              = selected .. "  ▾",
                Font              = Enum.Font.Gotham,
                TextSize          = 12,
                TextColor3        = Theme.SubText,
                Size              = UDim2.new(0, 130, 0, 28),
                Position          = UDim2.new(1, -144, 0.5, -14),
                BackgroundColor3  = Theme.SurfaceLight,
                BorderSizePixel   = 0,
                ZIndex            = 6,
            }, Holder)
            newInst("UICorner", { CornerRadius = UDim.new(0, 8) }, SelBtn)

            -- Dropdown list
            local List = newInst("Frame", {
                Size             = UDim2.new(0, 130, 0, #options * 32 + 8),
                Position         = UDim2.new(1, -144, 1, 4),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel  = 0,
                Visible          = false,
                ZIndex           = 20,
                ClipsDescendants = true,
            }, Holder)
            newInst("UICorner", { CornerRadius = UDim.new(0, 8) }, List)
            newInst("UIStroke", { Color = Theme.Border, Thickness = 1 }, List)
            newInst("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,2) }, List)
            newInst("UIPadding", { PaddingTop = UDim.new(0,4), PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4) }, List)

            for _, opt in ipairs(options) do
                local OptBtn = newInst("TextButton", {
                    Text              = opt,
                    Font              = Enum.Font.Gotham,
                    TextSize          = 12,
                    TextColor3        = Theme.Text,
                    Size              = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3  = Theme.SurfaceLight,
                    BorderSizePixel   = 0,
                    ZIndex            = 21,
                }, List)
                newInst("UICorner", { CornerRadius = UDim.new(0, 6) }, OptBtn)
                OptBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    SelBtn.Text = opt .. "  ▾"
                    List.Visible = false
                    pcall(callback, opt)
                end)
            end

            SelBtn.MouseButton1Click:Connect(function()
                List.Visible = not List.Visible
            end)
        end

        -- TEXTBOX
        function Tab:Input(iopts)
            iopts = iopts or {}
            local label       = iopts.Name        or "Input"
            local placeholder = iopts.Placeholder  or "Type here..."
            local callback    = iopts.Callback     or function() end

            local Holder = newInst("Frame", {
                Size             = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel  = 0,
                ZIndex           = 5,
            }, TabContent)
            newInst("UICorner", { CornerRadius = UDim.new(0, 10) }, Holder)

            newInst("TextLabel", {
                Text              = label,
                Font              = Enum.Font.GothamSemibold,
                TextSize          = 13,
                TextColor3        = Theme.SubText,
                BackgroundTransparency = 1,
                Size              = UDim2.new(1, -28, 0, 18),
                Position          = UDim2.new(0, 14, 0, 6),
                TextXAlignment    = Enum.TextXAlignment.Left,
                ZIndex            = 6,
            }, Holder)

            local Box = newInst("TextBox", {
                PlaceholderText   = placeholder,
                Text              = "",
                Font              = Enum.Font.Gotham,
                TextSize          = 13,
                TextColor3        = Theme.Text,
                PlaceholderColor3 = Theme.SubText,
                BackgroundColor3  = Theme.SurfaceLight,
                BorderSizePixel   = 0,
                Size              = UDim2.new(1, -28, 0, 24),
                Position          = UDim2.new(0, 14, 0, 24),
                ClearTextOnFocus  = false,
                ZIndex            = 6,
            }, Holder)
            newInst("UICorner", { CornerRadius = UDim.new(0, 6) }, Box)
            newInst("UIPadding", { PaddingLeft = UDim.new(0, 8) }, Box)

            Box.FocusLost:Connect(function(enter)
                if enter then pcall(callback, Box.Text) end
            end)
        end

        -- LABEL
        function Tab:Label(text)
            newInst("TextLabel", {
                Text              = text or "",
                Font              = Enum.Font.Gotham,
                TextSize          = 13,
                TextColor3        = Theme.SubText,
                BackgroundTransparency = 1,
                Size              = UDim2.new(1, 0, 0, 28),
                TextXAlignment    = Enum.TextXAlignment.Left,
                ZIndex            = 5,
            }, TabContent)
        end

        return Tab
    end

    -- =========================================================
    WindowRef = Window
    return Window
end

-- ============================================================
--  KEYBIND TOGGLE (Desktop)
-- ============================================================
function NonoLib:SetToggleKey(key)
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == key and WindowRef then
            -- find win
        end
    end)
end

-- ============================================================
--  INIT NOTIF
-- ============================================================
task.delay(0.5, function()
    NonoLib:Notify({
        Title       = isMobile and "📱 Mobile détecté" or "💻 Desktop détecté",
        Description = isMobile
            and "Bouton flottant actif — tap pour ouvrir"
            or  "NonoLib injecté avec succès",
        Type        = "success",
        Duration    = 4,
    })
end)

return NonoLib
