--[[
    ╔══════════════════════════════════════════════════════════╗
    ║               NonoLib v2.0 — UI Library                  ║
    ║         Modern • Smooth • Clean • Zero bugs              ║
    ║              Made by discord.gg/nullstate                ║
    ╚══════════════════════════════════════════════════════════╝
]]

local NonoLib = {}
NonoLib.__index = NonoLib

-- ============================================================
--  SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer

-- ============================================================
--  MOBILE DETECTION
-- ============================================================
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ============================================================
--  UTILS
-- ============================================================
local function Tween(obj, props, t, style, dir)
    local ti = TweenInfo.new(
        t     or 0.3,
        style or Enum.EasingStyle.Exponential,
        dir   or Enum.EasingDirection.Out
    )
    TweenService:Create(obj, ti, props):Play()
end

local function New(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local function Ripple(btn, x, y)
    local rip = New("Frame", {
        Size                   = UDim2.new(0, 0, 0, 0),
        Position               = UDim2.new(0, x - btn.AbsolutePosition.X, 0, y - btn.AbsolutePosition.Y),
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundColor3       = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        BorderSizePixel        = 0,
        ZIndex                 = btn.ZIndex + 1,
        ClipsDescendants       = false,
    }, btn)
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, rip)
    local sz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.5
    Tween(rip, { Size = UDim2.new(0, sz, 0, sz), BackgroundTransparency = 1 }, 0.5, Enum.EasingStyle.Quad)
    task.delay(0.5, function() rip:Destroy() end)
end

local function MakeDraggable(root, handle)
    handle = handle or root
    local drag, start, origin = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag   = true
            start  = i.Position
            origin = root.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            root.Position = UDim2.new(
                origin.X.Scale, origin.X.Offset + d.X,
                origin.Y.Scale, origin.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

-- ============================================================
--  THEME v2
-- ============================================================
local T = {
    -- Backgrounds
    BG          = Color3.fromRGB(10,  10,  15),
    BG2         = Color3.fromRGB(16,  16,  24),
    BG3         = Color3.fromRGB(22,  22,  34),
    BG4         = Color3.fromRGB(30,  30,  46),

    -- Accent
    Accent      = Color3.fromRGB(108, 73,  255),
    AccentLight = Color3.fromRGB(138, 103, 255),
    AccentGlow  = Color3.fromRGB(80,  50,  200),

    -- Text
    Text        = Color3.fromRGB(235, 235, 245),
    TextSub     = Color3.fromRGB(130, 130, 155),
    TextMuted   = Color3.fromRGB(70,  70,  90),

    -- Border
    Border      = Color3.fromRGB(38,  38,  58),
    BorderLight = Color3.fromRGB(55,  55,  80),

    -- States
    Success     = Color3.fromRGB(72,  199, 116),
    Warning     = Color3.fromRGB(245, 166, 35),
    Danger      = Color3.fromRGB(229, 62,  62),
    Info        = Color3.fromRGB(66,  153, 225),
}

-- ============================================================
--  ROOT GUI
-- ============================================================
pcall(function()
    if CoreGui:FindFirstChild("NonoLib_v2") then
        CoreGui:FindFirstChild("NonoLib_v2"):Destroy()
    end
end)

local Root = New("ScreenGui", {
    Name           = "NonoLib_v2",
    ResetOnSpawn   = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder   = 999,
    IgnoreGuiInset = true,
})
pcall(function() Root.Parent = CoreGui end)
if not Root.Parent then Root.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ============================================================
--  NOTIFICATION SYSTEM
-- ============================================================
local NotifContainer = New("Frame", {
    Size                   = UDim2.new(0, 320, 1, -20),
    Position               = UDim2.new(1, -330, 0, 10),
    BackgroundTransparency = 1,
    ZIndex                 = 100,
}, Root)

New("UIListLayout", {
    SortOrder         = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding           = UDim.new(0, 6),
}, NotifContainer)

function NonoLib:Notify(opts)
    opts = opts or {}
    local title    = opts.Title       or "NonoLib"
    local desc     = opts.Description or ""
    local ntype    = opts.Type        or "info"
    local duration = opts.Duration    or 4

    local accentCol = T.Info
    if ntype == "success" then accentCol = T.Success
    elseif ntype == "warning" then accentCol = T.Warning
    elseif ntype == "danger"  then accentCol = T.Danger end

    -- Outer frame
    local N = New("Frame", {
        Size                   = UDim2.new(1, 0, 0, 72),
        BackgroundColor3       = T.BG2,
        BackgroundTransparency = 0,
        BorderSizePixel        = 0,
        ClipsDescendants       = true,
        ZIndex                 = 101,
    }, NotifContainer)
    New("UICorner",  { CornerRadius = UDim.new(0, 12) }, N)
    New("UIStroke",  { Color = T.Border, Thickness = 1, Transparency = 0 }, N)

    -- Glow line top
    local glow = New("Frame", {
        Size             = UDim2.new(0, 0, 0, 2),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = accentCol,
        BorderSizePixel  = 0,
        ZIndex           = 102,
    }, N)
    New("UICorner", { CornerRadius = UDim.new(0, 2) }, glow)
    Tween(glow, { Size = UDim2.new(1, 0, 0, 2) }, 0.4, Enum.EasingStyle.Expo)

    -- Icon circle
    local iconBg = New("Frame", {
        Size             = UDim2.new(0, 36, 0, 36),
        Position         = UDim2.new(0, 14, 0.5, -18),
        BackgroundColor3 = accentCol,
        BackgroundTransparency = 0.8,
        BorderSizePixel  = 0,
        ZIndex           = 102,
    }, N)
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, iconBg)

    local icons = { success = "✓", warning = "!", danger = "✕", info = "i" }
    New("TextLabel", {
        Text              = icons[ntype] or "i",
        Font              = Enum.Font.GothamBold,
        TextSize          = 16,
        TextColor3        = accentCol,
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, 0, 1, 0),
        TextXAlignment    = Enum.TextXAlignment.Center,
        ZIndex            = 103,
    }, iconBg)

    -- Title
    New("TextLabel", {
        Text              = title,
        Font              = Enum.Font.GothamBold,
        TextSize          = 14,
        TextColor3        = T.Text,
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, -70, 0, 22),
        Position          = UDim2.new(0, 60, 0, 12),
        TextXAlignment    = Enum.TextXAlignment.Left,
        ZIndex            = 102,
    }, N)

    -- Description
    New("TextLabel", {
        Text              = desc,
        Font              = Enum.Font.Gotham,
        TextSize          = 12,
        TextColor3        = T.TextSub,
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, -70, 0, 28),
        Position          = UDim2.new(0, 60, 0, 34),
        TextXAlignment    = Enum.TextXAlignment.Left,
        TextWrapped       = true,
        ZIndex            = 102,
    }, N)

    -- Progress bar
    local pb = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = accentCol,
        BackgroundTransparency = 0.4,
        BorderSizePixel  = 0,
        ZIndex           = 102,
    }, N)
    New("UICorner", { CornerRadius = UDim.new(0, 2) }, pb)

    -- Animate in
    N.Position = UDim2.new(1, 20, 0, 0)
    Tween(N, { Position = UDim2.new(0, 0, 0, 0) }, 0.4, Enum.EasingStyle.Expo)
    Tween(pb, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

    task.delay(duration, function()
        Tween(N, { Position = UDim2.new(1, 20, 0, 0) }, 0.3, Enum.EasingStyle.Expo, Enum.EasingDirection.In)
        task.wait(0.35)
        N:Destroy()
    end)
end

-- ============================================================
--  MOBILE BUTTON
-- ============================================================
local MobileBtn
if isMobile then
    MobileBtn = New("TextButton", {
        Text             = "❖",
        Font             = Enum.Font.GothamBold,
        TextSize         = 22,
        TextColor3       = T.Text,
        Size             = UDim2.new(0, 52, 0, 52),
        Position         = UDim2.new(0, 12, 0.5, -26),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 200,
    }, Root)
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, MobileBtn)
    New("UIGradient", {
        Color    = ColorSequence.new({
            ColorSequenceKeypoint.new(0, T.AccentLight),
            ColorSequenceKeypoint.new(1, T.AccentGlow),
        }),
        Rotation = 135,
    }, MobileBtn)
    MakeDraggable(MobileBtn)
end

-- ============================================================
--  CREATE WINDOW
-- ============================================================
function NonoLib:CreateWindow(opts)
    opts = opts or {}
    local WinTitle    = opts.Title    or "NonoLib"
    local WinSub      = opts.Subtitle or "v2.0"
    local WinSize     = opts.Size     or UDim2.new(0, 620, 0, 440)

    -- ── BACKDROP ──────────────────────────────────────────
    local Backdrop = New("Frame", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundColor3       = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.6,
        ZIndex                 = 10,
        Visible                = false,
    }, Root)

    -- ── MAIN WINDOW ───────────────────────────────────────
    local Win = New("Frame", {
        Size                   = WinSize,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundColor3       = T.BG,
        BorderSizePixel        = 0,
        ClipsDescendants       = false,
        ZIndex                 = 11,
        Visible                = not isMobile,
    }, Root)
    New("UICorner", { CornerRadius = UDim.new(0, 16) }, Win)

    -- Outer glow / shadow
    local Shadow = New("ImageLabel", {
        Size                   = UDim2.new(1, 60, 1, 60),
        Position               = UDim2.new(0, -30, 0, -30),
        BackgroundTransparency = 1,
        Image                  = "rbxassetid://6014261993",
        ImageColor3            = T.AccentGlow,
        ImageTransparency      = 0.82,
        ScaleType              = Enum.ScaleType.Slice,
        SliceCenter            = Rect.new(49, 49, 450, 450),
        ZIndex                 = 10,
    }, Win)

    -- Border stroke
    New("UIStroke", {
        Color        = T.Border,
        Thickness    = 1.2,
        Transparency = 0,
    }, Win)

    -- Inner clip frame (all content clips here)
    local Inner = New("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex           = 12,
    }, Win)

    -- ── TOPBAR ────────────────────────────────────────────
    local TopBar = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = T.BG2,
        BorderSizePixel  = 0,
        ZIndex           = 13,
    }, Inner)
    New("UICorner", { CornerRadius = UDim.new(0, 16) }, TopBar)

    -- Fix bottom corners of topbar
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 16),
        Position         = UDim2.new(0, 0, 1, -16),
        BackgroundColor3 = T.BG2,
        BorderSizePixel  = 0,
        ZIndex           = 13,
    }, TopBar)

    -- Topbar bottom border
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        ZIndex           = 13,
    }, TopBar)

    -- Logo / accent mark
    local LogoFrame = New("Frame", {
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(0, 14, 0.5, -14),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 14,
    }, TopBar)
    New("UICorner", { CornerRadius = UDim.new(0, 8) }, LogoFrame)
    New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, T.AccentLight),
            ColorSequenceKeypoint.new(1, T.AccentGlow),
        }),
        Rotation = 135,
    }, LogoFrame)
    New("TextLabel", {
        Text              = "N",
        Font              = Enum.Font.GothamBold,
        TextSize          = 16,
        TextColor3        = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, 0, 1, 0),
        TextXAlignment    = Enum.TextXAlignment.Center,
        ZIndex            = 15,
    }, LogoFrame)

    -- Title
    New("TextLabel", {
        Text              = WinTitle,
        Font              = Enum.Font.GothamBold,
        TextSize          = 15,
        TextColor3        = T.Text,
        BackgroundTransparency = 1,
        Size              = UDim2.new(0, 200, 0, 20),
        Position          = UDim2.new(0, 52, 0, 8),
        TextXAlignment    = Enum.TextXAlignment.Left,
        ZIndex            = 14,
    }, TopBar)

    -- Subtitle
    New("TextLabel", {
        Text              = WinSub,
        Font              = Enum.Font.Gotham,
        TextSize          = 11,
        TextColor3        = T.TextSub,
        BackgroundTransparency = 1,
        Size              = UDim2.new(0, 200, 0, 16),
        Position          = UDim2.new(0, 52, 0, 27),
        TextXAlignment    = Enum.TextXAlignment.Left,
        ZIndex            = 14,
    }, TopBar)

    -- Window buttons
    local function WinBtn(symbol, col, xOff)
        local b = New("TextButton", {
            Text             = symbol,
            Font             = Enum.Font.GothamBold,
            TextSize         = 11,
            TextColor3       = col,
            Size             = UDim2.new(0, 26, 0, 26),
            Position         = UDim2.new(1, xOff, 0.5, -13),
            BackgroundColor3 = T.BG4,
            BorderSizePixel  = 0,
            ZIndex           = 15,
        }, TopBar)
        New("UICorner", { CornerRadius = UDim.new(1, 0) }, b)
        b.MouseEnter:Connect(function()
            Tween(b, { BackgroundColor3 = col, TextColor3 = T.Text }, 0.15)
        end)
        b.MouseLeave:Connect(function()
            Tween(b, { BackgroundColor3 = T.BG4, TextColor3 = col }, 0.15)
        end)
        return b
    end

    local CloseBtn = WinBtn("✕", T.Danger,  -14)
    local MinBtn   = WinBtn("–", T.Warning, -46)

    MakeDraggable(Win, TopBar)

    -- ── SIDEBAR ───────────────────────────────────────────
    local SidebarW = 155
    local Sidebar = New("Frame", {
        Size             = UDim2.new(0, SidebarW, 1, -50),
        Position         = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = T.BG2,
        BorderSizePixel  = 0,
        ZIndex           = 12,
    }, Inner)

    -- Right border of sidebar
    New("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        ZIndex           = 13,
    }, Sidebar)

    local SideList = New("Frame", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex                 = 13,
    }, Sidebar)
    New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 2),
    }, SideList)
    New("UIPadding", {
        PaddingTop   = UDim.new(0, 10),
        PaddingLeft  = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, SideList)

    -- Sidebar label
    New("TextLabel", {
        Text              = "MENU",
        Font              = Enum.Font.GothamBold,
        TextSize          = 10,
        TextColor3        = T.TextMuted,
        BackgroundTransparency = 1,
        Size              = UDim2.new(1, 0, 0, 24),
        TextXAlignment    = Enum.TextXAlignment.Left,
        ZIndex            = 14,
        LayoutOrder       = 0,
    }, SideList)

    -- ── CONTENT ───────────────────────────────────────────
    local Content = New("Frame", {
        Size             = UDim2.new(1, -SidebarW, 1, -50),
        Position         = UDim2.new(0, SidebarW, 0, 50),
        BackgroundColor3 = T.BG,
        BorderSizePixel  = 0,
        ZIndex           = 12,
    }, Inner)

    -- ── WINDOW LOGIC ──────────────────────────────────────
    local minimized = false

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Win, {
            Size     = UDim2.new(0, WinSize.X.Offset, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, WinSize.Y.Offset / 2),
        }, 0.3, Enum.EasingStyle.Expo, Enum.EasingDirection.In)
        task.wait(0.32)
        Win.Visible = false
        Backdrop.Visible = false
    end)

    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Win, { Size = UDim2.new(0, WinSize.X.Offset, 0, 50) }, 0.3, Enum.EasingStyle.Expo)
        else
            Tween(Win, { Size = WinSize }, 0.3, Enum.EasingStyle.Expo)
        end
    end)

    if isMobile and MobileBtn then
        MobileBtn.MouseButton1Click:Connect(function()
            Win.Visible = not Win.Visible
            Backdrop.Visible = Win.Visible
            if Win.Visible then
                Win.Size = UDim2.new(0, WinSize.X.Offset, 0, 0)
                Tween(Win, { Size = WinSize }, 0.4, Enum.EasingStyle.Expo)
            end
        end)
    end

    -- ── WINDOW API ────────────────────────────────────────
    local Window   = {}
    local TabList  = {}
    local ActiveTab = nil

    local function ActivateTab(t)
        for _, x in pairs(TabList) do
            -- deactivate
            Tween(x.Btn, { BackgroundColor3 = Color3.fromRGB(0,0,0) }, 0.2)
            x.Btn.BackgroundTransparency = 1
            x.BtnText.TextColor3 = T.TextSub
            x.BtnDot.BackgroundTransparency = 1
            x.Page.Visible = false
        end
        -- activate
        Tween(t.Btn, { BackgroundColor3 = T.BG3 }, 0.2)
        t.Btn.BackgroundTransparency = 0
        t.BtnText.TextColor3 = T.Text
        Tween(t.BtnDot, { BackgroundTransparency = 0 }, 0.2)
        t.Page.Visible = true
        ActiveTab = t
    end

    -- ── CREATE TAB ────────────────────────────────────────
    function Window:CreateTab(o)
        o = o or {}
        local name = o.Name or "Tab"
        local icon = o.Icon or ""
        local order = #TabList + 1

        -- Sidebar button
        local Btn = New("Frame", {
            Size             = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = T.BG3,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ZIndex           = 14,
            LayoutOrder      = order,
        }, SideList)
        New("UICorner", { CornerRadius = UDim.new(0, 10) }, Btn)

        -- Active dot
        local BtnDot = New("Frame", {
            Size             = UDim2.new(0, 3, 0, 20),
            Position         = UDim2.new(0, 0, 0.5, -10),
            BackgroundColor3 = T.Accent,
            BorderSizePixel  = 0,
            BackgroundTransparency = 1,
            ZIndex           = 15,
        }, Btn)
        New("UICorner", { CornerRadius = UDim.new(0, 4) }, BtnDot)

        -- Icon
        if icon ~= "" then
            New("TextLabel", {
                Text              = icon,
                Font              = Enum.Font.GothamBold,
                TextSize          = 16,
                TextColor3        = T.TextSub,
                BackgroundTransparency = 1,
                Size              = UDim2.new(0, 28, 1, 0),
                Position          = UDim2.new(0, 10, 0, 0),
                TextXAlignment    = Enum.TextXAlignment.Center,
                ZIndex            = 15,
            }, Btn)
        end

        local BtnText = New("TextLabel", {
            Text              = name,
            Font              = Enum.Font.GothamSemibold,
            TextSize          = 13,
            TextColor3        = T.TextSub,
            BackgroundTransparency = 1,
            Size              = UDim2.new(1, -(icon~="" and 42 or 14), 1, 0),
            Position          = UDim2.new(0, icon~="" and 40 or 12, 0, 0),
            TextXAlignment    = Enum.TextXAlignment.Left,
            ZIndex            = 15,
        }, Btn)

        -- Clickable overlay
        local BtnClick = New("TextButton", {
            Text                   = "",
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ZIndex                 = 16,
        }, Btn)

        -- Tab page (scroll)
        local Page = New("ScrollingFrame", {
            Size                  = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel       = 0,
            ScrollBarThickness    = 2,
            ScrollBarImageColor3  = T.Accent,
            ScrollBarImageTransparency = 0.5,
            CanvasSize            = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize   = Enum.AutomaticSize.Y,
            Visible               = false,
            ZIndex                = 13,
        }, Content)

        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 6),
        }, Page)
        New("UIPadding", {
            PaddingTop    = UDim.new(0, 14),
            PaddingBottom = UDim.new(0, 14),
            PaddingLeft   = UDim.new(0, 14),
            PaddingRight  = UDim.new(0, 14),
        }, Page)

        local tabObj = { Btn = Btn, BtnText = BtnText, BtnDot = BtnDot, Page = Page }
        table.insert(TabList, tabObj)
        if #TabList == 1 then ActivateTab(tabObj) end

        BtnClick.MouseButton1Click:Connect(function() ActivateTab(tabObj) end)
        BtnClick.MouseEnter:Connect(function()
            if ActiveTab ~= tabObj then
                Tween(Btn, { BackgroundColor3 = T.BG4, BackgroundTransparency = 0 }, 0.15)
            end
        end)
        BtnClick.MouseLeave:Connect(function()
            if ActiveTab ~= tabObj then
                Tween(Btn, { BackgroundTransparency = 1 }, 0.15)
            end
        end)

        -- ── TAB API ───────────────────────────────────────
        local Tab = {}

        -- SECTION
        function Tab:Section(name2)
            local S = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                ZIndex           = 14,
            }, Page)
            New("TextLabel", {
                Text              = string.upper(name2 or ""),
                Font              = Enum.Font.GothamBold,
                TextSize          = 10,
                TextColor3        = T.Accent,
                BackgroundTransparency = 1,
                Size              = UDim2.new(1, -20, 1, 0),
                Position          = UDim2.new(0, 0, 0, 0),
                TextXAlignment    = Enum.TextXAlignment.Left,
                ZIndex            = 15,
            }, S)
            -- line
            New("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = T.Border,
                BorderSizePixel  = 0,
                ZIndex           = 15,
            }, S)
        end

        -- BUTTON
        function Tab:Button(b)
            b = b or {}
            local H = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = T.BG2,
                BorderSizePixel  = 0,
                ZIndex           = 14,
                ClipsDescendants = true,
            }, Page)
            New("UICorner",  { CornerRadius = UDim.new(0, 12) }, H)
            New("UIStroke",  { Color = T.Border, Thickness = 1, Transparency = 0 }, H)

            New("TextLabel", {
                Text              = b.Name or "Button",
                Font              = Enum.Font.GothamSemibold,
                TextSize          = 14,
                TextColor3        = T.Text,
                BackgroundTransparency = 1,
                Size              = UDim2.new(1, -100, 0, 22),
                Position          = UDim2.new(0, 14, 0, (b.Description and b.Description~="") and 7 or 15),
                TextXAlignment    = Enum.TextXAlignment.Left,
                ZIndex            = 15,
            }, H)

            if b.Description and b.Description ~= "" then
                New("TextLabel", {
                    Text              = b.Description,
                    Font              = Enum.Font.Gotham,
                    TextSize          = 11,
                    TextColor3        = T.TextSub,
                    BackgroundTransparency = 1,
                    Size              = UDim2.new(1, -100, 0, 18),
                    Position          = UDim2.new(0, 14, 0, 29),
                    TextXAlignment    = Enum.TextXAlignment.Left,
                    ZIndex            = 15,
                }, H)
            end

            -- Run button
            local RunBtn = New("TextButton", {
                Text             = "Run",
                Font             = Enum.Font.GothamBold,
                TextSize         = 12,
                TextColor3       = T.Text,
                Size             = UDim2.new(0, 68, 0, 30),
                Position         = UDim2.new(1, -80, 0.5, -15),
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                ZIndex           = 15,
                ClipsDescendants = true,
            }, H)
            New("UICorner",   { CornerRadius = UDim.new(0, 8) }, RunBtn)
            New("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, T.AccentLight),
                    ColorSequenceKeypoint.new(1, T.Accent),
                }),
                Rotation = 90,
            }, RunBtn)

            RunBtn.MouseButton1Click:Connect(function()
                Ripple(RunBtn, RunBtn.AbsolutePosition.X + RunBtn.AbsoluteSize.X/2,
                              RunBtn.AbsolutePosition.Y + RunBtn.AbsoluteSize.Y/2)
                Tween(RunBtn, { BackgroundColor3 = T.AccentLight }, 0.1)
                task.wait(0.15)
                Tween(RunBtn, { BackgroundColor3 = T.Accent }, 0.2)
                pcall(b.Callback or function() end)
            end)
        end

        -- TOGGLE
        function Tab:Toggle(t2)
            t2 = t2 or {}
            local state = t2.Default or false

            local H = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = T.BG2,
                BorderSizePixel  = 0,
                ZIndex           = 14,
                ClipsDescendants = false,
            }, Page)
            New("UICorner", { CornerRadius = UDim.new(0, 12) }, H)
            New("UIStroke", { Color = T.Border, Thickness = 1 }, H)

            New("TextLabel", {
                Text              = t2.Name or "Toggle",
                Font              = Enum.Font.GothamSemibold,
                TextSize          = 14,
                TextColor3        = T.Text,
                BackgroundTransparency = 1,
                Size              = UDim2.new(1, -80, 0, 22),
                Position          = UDim2.new(0, 14, 0, (t2.Description and t2.Description~="") and 7 or 15),
                TextXAlignment    = Enum.TextXAlignment.Left,
                ZIndex            = 15,
            }, H)

            if t2.Description and t2.Description ~= "" then
                New("TextLabel", {
                    Text              = t2.Description,
                    Font              = Enum.Font.Gotham,
                    TextSize          = 11,
                    TextColor3        = T.TextSub,
                    BackgroundTransparency = 1,
                    Size              = UDim2.new(1, -80, 0, 18),
                    Position          = UDim2.new(0, 14, 0, 29),
                    TextXAlignment    = Enum.TextXAlignment.Left,
                    ZIndex            = 15,
                }, H)
            end

            -- Track
            local Track = New("Frame", {
                Size             = UDim2.new(0, 46, 0, 26),
                Position         = UDim2.new(1, -60, 0.5, -13),
                BackgroundColor3 = state and T.Accent or T.BG4,
                BorderSizePixel  = 0,
                ZIndex           = 15,
            }, H)
            New("UICorner", { CornerRadius = UDim.new(1, 0) }, Track)
            New("UIStroke", {
                Color       = state and T.Accent or T.Border,
                Thickness   = 1,
                Transparency = 0,
            }, Track)

            -- Thumb with shadow
            local Thumb = New("Frame", {
                Size             = UDim2.new(0, 20, 0, 20),
                Position         = state
                    and UDim2.new(0, 23, 0.5, -10)
                    or  UDim2.new(0, 3,  0.5, -10),
                BackgroundColor3 = T.Text,
                BorderSizePixel  = 0,
                ZIndex           = 16,
            }, Track)
            New("UICorner", { CornerRadius = UDim.new(1, 0) }, Thumb)

            local CA = New("TextButton", {
                Text                   = "",
                Size                   = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex                 = 17,
            }, H)

            local stroke = Track:FindFirstChildOfClass("UIStroke")
            CA.MouseButton1Click:Connect(function()
                state = not state
                Tween(Track, { BackgroundColor3 = state and T.Accent or T.BG4 }, 0.2)
                if stroke then
                    Tween(stroke, { Color = state and T.Accent or T.Border }, 0.2)
                end
                Tween(Thumb, {
                    Position = state
                        and UDim2.new(0, 23, 0.5, -10)
                        or  UDim2.new(0, 3,  0.5, -10)
                }, 0.2, Enum.EasingStyle.Back)
                pcall(t2.Callback or function() end, state)
            end)

            local Obj = {}
            function Obj:Set(v)
                state = v
                Tween(Track, { BackgroundColor3 = v and T.Accent or T.BG4 }, 0.2)
                if stroke then Tween(stroke, { Color = v and T.Accent or T.Border }, 0.2) end
                Tween(Thumb, { Position = v and UDim2.new(0,23,0.5,-10) or UDim2.new(0,3,0.5,-10) }, 0.2, Enum.EasingStyle.Back)
                pcall(t2.Callback or function() end, v)
            end
            return Obj
        end

        -- SLIDER
        function Tab:Slider(s)
            s = s or {}
            local min  = s.Min     or 0
            local max  = s.Max     or 100
            local val  = s.Default or min
            local step = s.Step    or 1

            local H = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 62),
                BackgroundColor3 = T.BG2,
                BorderSizePixel  = 0,
                ZIndex           = 14,
            }, Page)
            New("UICorner", { CornerRadius = UDim.new(0, 12) }, H)
            New("UIStroke", { Color = T.Border, Thickness = 1 }, H)

            New("TextLabel", {
                Text              = s.Name or "Slider",
                Font              = Enum.Font.GothamSemibold,
                TextSize          = 14,
                TextColor3        = T.Text,
                BackgroundTransparency = 1,
                Size              = UDim2.new(1, -80, 0, 20),
                Position          = UDim2.new(0, 14, 0, 10),
                TextXAlignment    = Enum.TextXAlignment.Left,
                ZIndex            = 15,
            }, H)

            local ValBox = New("TextLabel", {
                Text              = tostring(val),
                Font              = Enum.Font.GothamBold,
                TextSize          = 13,
                TextColor3        = T.Accent,
                BackgroundTransparency = 1,
                Size              = UDim2.new(0, 60, 0, 20),
                Position          = UDim2.new(1, -74, 0, 10),
                TextXAlignment    = Enum.TextXAlignment.Right,
                ZIndex            = 15,
            }, H)

            -- Track bg
            local TrackBg = New("Frame", {
                Size             = UDim2.new(1, -28, 0, 5),
                Position         = UDim2.new(0, 14, 0, 44),
                BackgroundColor3 = T.BG4,
                BorderSizePixel  = 0,
                ZIndex           = 15,
                ClipsDescendants = false,
            }, H)
            New("UICorner", { CornerRadius = UDim.new(1, 0) }, TrackBg)

            local pct = (val - min) / (max - min)

            -- Fill
            local Fill = New("Frame", {
                Size             = UDim2.new(pct, 0, 1, 0),
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                ZIndex           = 16,
            }, TrackBg)
            New("UICorner", { CornerRadius = UDim.new(1, 0) }, Fill)
            New("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, T.AccentLight),
                    ColorSequenceKeypoint.new(1, T.Accent),
                }),
            }, Fill)

            -- Knob
            local Knob = New("Frame", {
                Size             = UDim2.new(0, 16, 0, 16),
                Position         = UDim2.new(pct, -8, 0.5, -8),
                BackgroundColor3 = T.Text,
                BorderSizePixel  = 0,
                ZIndex           = 17,
            }, TrackBg)
            New("UICorner", { CornerRadius = UDim.new(1, 0) }, Knob)
            New("UIStroke", { Color = T.Accent, Thickness = 2 }, Knob)

            local sliding = false
            local InputArea = New("TextButton", {
                Text                   = "",
                Size                   = UDim2.new(1, 0, 0, 30),
                Position               = UDim2.new(0, 0, 0.5, -15),
                BackgroundTransparency = 1,
                ZIndex                 = 18,
            }, TrackBg)

            local function UpdateSlider(posX)
                local rel = math.clamp((posX - TrackBg.AbsolutePosition.X) / TrackBg.AbsoluteSize.X, 0, 1)
                local raw = min + rel * (max - min)
                val = math.floor(raw / step + 0.5) * step
                val = math.clamp(val, min, max)
                local newPct = (val - min) / (max - min)
                ValBox.Text   = tostring(val)
                Fill.Size     = UDim2.new(newPct, 0, 1, 0)
                Knob.Position = UDim2.new(newPct, -8, 0.5, -8)
                pcall(s.Callback or function() end, val)
            end

            InputArea.MouseButton1Down:Connect(function(x, y)
                sliding = true
                UpdateSlider(x)
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement
                    or i.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(i.Position.X)
                end
            end)
        end

        -- DROPDOWN
        function Tab:Dropdown(d)
            d = d or {}
            local options  = d.Options or {}
            local selected = options[1] or "Sélectionner"
            local isOpen   = false

            local H = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = T.BG2,
                BorderSizePixel  = 0,
                ZIndex           = 14,
                ClipsDescendants = false,
            }, Page)
            New("UICorner", { CornerRadius = UDim.new(0, 12) }, H)
            New("UIStroke", { Color = T.Border, Thickness = 1 }, H)

            New("TextLabel", {
                Text              = d.Name or "Dropdown",
                Font              = Enum.Font.GothamSemibold,
                TextSize          = 14,
                TextColor3        = T.Text,
                BackgroundTransparency = 1,
                Size              = UDim2.new(0.5, 0, 1, 0),
                Position          = UDim2.new(0, 14, 0, 0),
                TextXAlignment    = Enum.TextXAlignment.Left,
                ZIndex            = 15,
            }, H)

            -- Select box
            local SelFrame = New("Frame", {
                Size             = UDim2.new(0, 140, 0, 30),
                Position         = UDim2.new(1, -152, 0.5, -15),
                BackgroundColor3 = T.BG4,
                BorderSizePixel  = 0,
                ZIndex           = 15,
            }, H)
            New("UICorner", { CornerRadius = UDim.new(0, 8) }, SelFrame)
            New("UIStroke", { Color = T.Border, Thickness = 1 }, SelFrame)

            local SelText = New("TextLabel", {
                Text              = selected,
                Font              = Enum.Font.Gotham,
                TextSize          = 12,
                TextColor3        = T.Text,
                BackgroundTransparency = 1,
                Size              = UDim2.new(1, -30, 1, 0),
                Position          = UDim2.new(0, 10, 0, 0),
                TextXAlignment    = Enum.TextXAlignment.Left,
                ZIndex            = 16,
            }, SelFrame)

            -- Arrow
            local Arrow = New("TextLabel", {
                Text              = "⌄",
                Font              = Enum.Font.GothamBold,
                TextSize          = 14,
                TextColor3        = T.TextSub,
                BackgroundTransparency = 1,
                Size              = UDim2.new(0, 24, 1, 0),
                Position          = UDim2.new(1, -26, 0, 0),
                TextXAlignment    = Enum.TextXAlignment.Center,
                ZIndex            = 16,
            }, SelFrame)

            -- Dropdown list
            local listH = math.min(#options, 5) * 34 + 8
            local DDList = New("Frame", {
                Size             = UDim2.new(0, 140, 0, listH),
                Position         = UDim2.new(1, -152, 1, 6),
                BackgroundColor3 = T.BG3,
                BorderSizePixel  = 0,
                Visible          = false,
                ZIndex           = 50,
                ClipsDescendants = true,
            }, H)
            New("UICorner", { CornerRadius = UDim.new(0, 10) }, DDList)
            New("UIStroke", { Color = T.BorderLight, Thickness = 1 }, DDList)

            local DDScroll = New("ScrollingFrame", {
                Size                  = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel       = 0,
                ScrollBarThickness    = 2,
                ScrollBarImageColor3  = T.Accent,
                CanvasSize            = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize   = Enum.AutomaticSize.Y,
                ZIndex                = 51,
            }, DDList)
            New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, DDScroll)
            New("UIPadding", { PaddingTop = UDim.new(0,4), PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4) }, DDScroll)

            for _, opt in ipairs(options) do
                local OB = New("TextButton", {
                    Text              = opt,
                    Font              = Enum.Font.Gotham,
                    TextSize          = 12,
                    TextColor3        = T.TextSub,
                    Size              = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3  = T.BG4,
                    BackgroundTransparency = 1,
                    BorderSizePixel   = 0,
                    ZIndex            = 52,
                    TextXAlignment    = Enum.TextXAlignment.Left,
                }, DDScroll)
                New("UICorner",  { CornerRadius = UDim.new(0, 7) }, OB)
                New("UIPadding", { PaddingLeft = UDim.new(0, 8) }, OB)

                OB.MouseEnter:Connect(function()
                    Tween(OB, { BackgroundTransparency = 0, TextColor3 = T.Text }, 0.15)
                end)
                OB.MouseLeave:Connect(function()
                    Tween(OB, { BackgroundTransparency = 1, TextColor3 = T.TextSub }, 0.15)
                end)
                OB.MouseButton1Click:Connect(function()
                    selected      = opt
                    SelText.Text  = opt
                    isOpen        = false
                    DDList.Visible = false
                    Tween(Arrow, { Rotation = 0 }, 0.2)
                    pcall(d.Callback or function() end, opt)
                end)
            end

            local SelClick = New("TextButton", {
                Text                   = "",
                Size                   = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex                 = 17,
            }, SelFrame)
            SelClick.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                DDList.Visible = isOpen
                Tween(Arrow, { Rotation = isOpen and 180 or 0 }, 0.2)
            end)
        end

        -- INPUT
        function Tab:Input(inp)
            inp = inp or {}
            local H = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 56),
                BackgroundColor3 = T.BG2,
                BorderSizePixel  = 0,
                ZIndex           = 14,
            }, Page)
            New("UICorner", { CornerRadius = UDim.new(0, 12) }, H)
            New("UIStroke", { Color = T.Border, Thickness = 1 }, H)

            New("TextLabel", {
                Text              = inp.Name or "Input",
                Font              = Enum.Font.GothamSemibold,
                TextSize          = 12,
                TextColor3        = T.TextSub,
                BackgroundTransparency = 1,
                Size              = UDim2.new(1, -28, 0, 16),
                Position          = UDim2.new(0, 14, 0, 8),
                TextXAlignment    = Enum.TextXAlignment.Left,
                ZIndex            = 15,
            }, H)

            local BoxFrame = New("Frame", {
                Size             = UDim2.new(1, -28, 0, 26),
                Position         = UDim2.new(0, 14, 0, 24),
                BackgroundColor3 = T.BG3,
                BorderSizePixel  = 0,
                ZIndex           = 15,
            }, H)
            New("UICorner", { CornerRadius = UDim.new(0, 7) }, BoxFrame)
            local stroke2 = New("UIStroke", { Color = T.Border, Thickness = 1 }, BoxFrame)

            local Box = New("TextBox", {
                PlaceholderText   = inp.Placeholder or "Type here...",
                Text              = "",
                Font              = Enum.Font.Gotham,
                TextSize          = 12,
                TextColor3        = T.Text,
                PlaceholderColor3 = T.TextMuted,
                BackgroundTransparency = 1,
                Size              = UDim2.new(1, -16, 1, 0),
                Position          = UDim2.new(0, 8, 0, 0),
                ClearTextOnFocus  = false,
                ZIndex            = 16,
                TextXAlignment    = Enum.TextXAlignment.Left,
            }, BoxFrame)

            Box.Focused:Connect(function()
                Tween(stroke2, { Color = T.Accent }, 0.2)
            end)
            Box.FocusLost:Connect(function(enter)
                Tween(stroke2, { Color = T.Border }, 0.2)
                if enter then pcall(inp.Callback or function() end, Box.Text) end
            end)
        end

        -- LABEL
        function Tab:Label(text)
            New("TextLabel", {
                Text              = text or "",
                Font              = Enum.Font.Gotham,
                TextSize          = 12,
                TextColor3        = T.TextSub,
                BackgroundTransparency = 1,
                Size              = UDim2.new(1, 0, 0, 22),
                TextXAlignment    = Enum.TextXAlignment.Left,
                ZIndex            = 14,
            }, Page)
        end

        return Tab
    end

    return Window
end

-- ============================================================
--  STARTUP NOTIFY
-- ============================================================
task.delay(0.6, function()
    NonoLib:Notify({
        Title       = isMobile and "📱 Mobile détecté" or "💻 NonoLib v2.0",
        Description = isMobile
            and "Bouton flottant — tap pour ouvrir"
            or  "Interface chargée avec succès",
        Type     = "success",
        Duration = 4,
    })
end)

return NonoLib
