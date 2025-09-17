--[[
LiteField: a lightweight Roblox UI library inspired by Rayfield/gav.lua
Single-file ModuleScript – drop into ReplicatedStorage (or anywhere) and require it.

Features (v0.1):
- Window with draggable topbar, hide/show keybind, minimise/maximise
- Tab system with UIPageLayout
- Elements: Button, Toggle, Slider, Dropdown, Input (TextBox), Section, Divider
- Notifications with auto-dismiss
- Simple theming (Default, Light, Ocean) + custom theme table support
- Optional config save/load (readfile/writefile)
- No external HTTP, no executors required (persistence graceful if unavailable)

API:
local ui = LiteField.CreateWindow({
    Title = "My Tool", Keybind = Enum.KeyCode.K, Theme = "Default", ConfigName = "mytool" -- optional
})
local tab = ui:AddTab({Name = "Main", Icon = 0})
local btn = tab:AddButton({Name = "Do Thing", Callback = function() end})
local tgl = tab:AddToggle({Name = "Auto", Default = false, Callback = function(v) end})
local sld = tab:AddSlider({Name = "Speed", Min = 0, Max = 100, Default = 50, Step = 1, Callback=function(v) end})
local dd  = tab:AddDropdown({Name = "Mode", Options = {"A","B"}, Default = "A", Callback=function(v) end})
local inp = tab:AddInput({Name = "Text", Placeholder = "Type...", Default = "", Callback=function(text) end})
ui:Notify({Title="Hello", Content="LiteField ready!", Duration=4})
ui:SaveConfig() -- ui:LoadConfig() auto-called on build if possible

--]]

local LiteField = {}
LiteField.__index = LiteField

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Utility
local function tween(o, ti, props)
    return TweenService:Create(o, ti, props)
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local THEMES = {
    Default = {
        Text = Color3.fromRGB(240,240,240),
        Background = Color3.fromRGB(25,25,25),
        Topbar = Color3.fromRGB(34,34,34),
        Stroke = Color3.fromRGB(60,60,60),
        Elem = Color3.fromRGB(35,35,35),
        ElemHover = Color3.fromRGB(45,45,45),
        Accent = Color3.fromRGB(50,138,220),
        Muted = Color3.fromRGB(160,160,160)
    },
    Light = {
        Text = Color3.fromRGB(40,40,40),
        Background = Color3.fromRGB(245,245,245),
        Topbar = Color3.fromRGB(230,230,230),
        Stroke = Color3.fromRGB(200,200,200),
        Elem = Color3.fromRGB(235,235,235),
        ElemHover = Color3.fromRGB(225,225,225),
        Accent = Color3.fromRGB(100,150,220),
        Muted = Color3.fromRGB(120,120,120)
    },
    Ocean = {
        Text = Color3.fromRGB(230,240,240),
        Background = Color3.fromRGB(20,30,30),
        Topbar = Color3.fromRGB(25,40,40),
        Stroke = Color3.fromRGB(50,70,70),
        Elem = Color3.fromRGB(30,50,50),
        ElemHover = Color3.fromRGB(35,60,60),
        Accent = Color3.fromRGB(0,140,140),
        Muted = Color3.fromRGB(150,170,170)
    }
}

-- Persistence (optional)
local function canIO()
    return typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function"
end

-- Element base constructor
local function newElementFrame(theme)
    local e = Instance.new("Frame")
    e.Name = "Element"
    e.Size = UDim2.new(1, -12, 0, 42)
    e.BackgroundColor3 = theme.Elem
    e.BorderSizePixel = 0
    local uiC = Instance.new("UICorner", e) uiC.CornerRadius = UDim.new(0,8)
    local uiS = Instance.new("UIStroke", e) uiS.Thickness = 1 uiS.Color = theme.Stroke
    return e, uiS
end

-- Create Window
function LiteField.CreateWindow(opts)
    opts = opts or {}
    local self = setmetatable({}, LiteField)
    self.Title = opts.Title or "LiteField"
    self.Keybind = opts.Keybind or Enum.KeyCode.K
    self.ConfigName = opts.ConfigName
    self.Theme = typeof(opts.Theme) == "table" and opts.Theme or THEMES[opts.Theme or "Default"]
    self.Flags = {}

    -- Root GUI
    local screen = Instance.new("ScreenGui")
    screen.Name = "LiteField"
    screen.IgnoreGuiInset = true
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 100
    screen.Parent = (gethui and gethui()) or Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Main window
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 520, 0, 280)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.BackgroundColor3 = self.Theme.Background
    main.BorderSizePixel = 0
    main.Parent = screen

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0.5, -20, 0.5, -20)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5028857084"
    shadow.ImageTransparency = 0.6
    shadow.Parent = main

    local top = Instance.new("Frame")
    top.Name = "Topbar"
    top.Size = UDim2.new(1, 0, 0, 46)
    top.BackgroundColor3 = self.Theme.Topbar
    top.BorderSizePixel = 0
    top.Parent = main

    local topStroke = Instance.new("UIStroke", top)
    topStroke.Color = self.Theme.Stroke
    topStroke.Transparency = 0.5

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -140, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.Title
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = self.Theme.Text
    title.Parent = top

    local btnHide = Instance.new("TextButton")
    btnHide.Name = "Hide"
    btnHide.Size = UDim2.new(0, 60, 0, 28)
    btnHide.Position = UDim2.new(1, -68, 0.5, -14)
    btnHide.BackgroundColor3 = self.Theme.Elem
    btnHide.TextColor3 = self.Theme.Text
    btnHide.Text = "Hide"
    btnHide.Font = Enum.Font.Gotham
    btnHide.TextSize = 14
    btnHide.Parent = top
    Instance.new("UICorner", btnHide).CornerRadius = UDim.new(0,8)

    local btnMini = Instance.new("TextButton")
    btnMini.Name = "Mini"
    btnMini.Size = UDim2.new(0, 60, 0, 28)
    btnMini.Position = UDim2.new(1, -136, 0.5, -14)
    btnMini.BackgroundColor3 = self.Theme.Elem
    btnMini.TextColor3 = self.Theme.Text
    btnMini.Text = "Min"
    btnMini.Font = Enum.Font.Gotham
    btnMini.TextSize = 14
    btnMini.Parent = top
    Instance.new("UICorner", btnMini).CornerRadius = UDim.new(0,8)

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0,0,0,46)
    divider.BackgroundColor3 = self.Theme.Stroke
    divider.BorderSizePixel = 0
    divider.Parent = main

    -- Sidebar tabs
    local tabList = Instance.new("ScrollingFrame")
    tabList.Name = "TabList"
    tabList.AnchorPoint = Vector2.new(0,1)
    tabList.Size = UDim2.new(0, 150, 1, -56)
    tabList.Position = UDim2.new(0, 0, 1, -10)
    tabList.BackgroundTransparency = 1
    tabList.BorderSizePixel = 0
    tabList.ScrollBarThickness = 4
    tabList.CanvasSize = UDim2.new()
    tabList.Parent = main

    local tabLayout = Instance.new("UIListLayout", tabList)
    tabLayout.Padding = UDim.new(0,10)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local elements = Instance.new("Frame")
    elements.Name = "Elements"
    elements.Size = UDim2.new(1, -160, 1, -60)
    elements.Position = UDim2.new(0, 156, 0, 56)
    elements.BackgroundTransparency = 1
    elements.Parent = main

    local pages = Instance.new("UIPageLayout", elements)
    pages.FillDirection = Enum.FillDirection.Vertical
    pages.SortOrder = Enum.SortOrder.LayoutOrder
    pages.Padding = UDim.new(0, 0)
    pages.TweenTime = 0.3

    local notifRoot = Instance.new("Frame")
    notifRoot.Name = "Notifications"
    notifRoot.AnchorPoint = Vector2.new(1,1)
    notifRoot.Position = UDim2.new(1, -12, 1, -12)
    notifRoot.Size = UDim2.new(0, 260, 0, 0)
    notifRoot.BackgroundTransparency = 1
    notifRoot.Parent = screen

    local notifLayout = Instance.new("UIListLayout", notifRoot)
    notifLayout.Padding = UDim.new(0,8)
    notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

    self._screen = screen
    self._main = main
    self._top = top
    self._tabList = tabList
    self._elements = elements
    self._pages = pages
    self._notifRoot = notifRoot
    self._activePage = nil
    self._tabCount = 0

    -- Tabs API
    local TabMT = {}
    TabMT.__index = TabMT

    function TabMT:AddSection(text)
        local sec = Instance.new("TextLabel")
        sec.Size = UDim2.new(1, -12, 0, 26)
        sec.BackgroundTransparency = 1
        sec.TextXAlignment = Enum.TextXAlignment.Left
        sec.Text = text or "SECTION"
        sec.Font = Enum.Font.GothamBold
        sec.TextSize = 14
        sec.TextColor3 = self._theme.Text
        sec.Parent = self.Container
        return sec
    end

    function TabMT:AddDivider()
        local d = Instance.new("Frame")
        d.Size = UDim2.new(1, -12, 0, 1)
        d.BackgroundColor3 = self._theme.Stroke
        d.BorderSizePixel = 0
        d.Parent = self.Container
        d.LayoutOrder = 9999
        return d
    end

    function TabMT:AddButton(opts2)
        local e = newElementFrame(self._theme)
        e.Parent = self.Container
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -100, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.Text = opts2.Name or "Button"
        lbl.TextColor3 = self._theme.Text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.Parent = e
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 84, 0, 28)
        btn.Position = UDim2.new(1, -94, 0.5, -14)
        btn.Text = "Run"
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.TextColor3 = self._theme.Text
        btn.BackgroundColor3 = self._theme.ElemHover
        btn.Parent = e
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
        btn.MouseButton1Click:Connect(function()
            if typeof(opts2.Callback) == "function" then opts2.Callback() end
        end)
        return {SetText=function(t) lbl.Text=t end}
    end

    function TabMT:AddToggle(opts2)
        local e = newElementFrame(self._theme)
        e.Parent = self.Container
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -100, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.Text = opts2.Name or "Toggle"
        lbl.TextColor3 = self._theme.Text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.Parent = e
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 48, 0, 22)
        knob.Position = UDim2.new(1, -60, 0.5, -11)
        knob.BackgroundColor3 = self._theme.ElemHover
        knob.Parent = e
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
        local dot = Instance.new("Frame", knob)
        dot.Size = UDim2.new(0, 18, 0, 18)
        dot.Position = UDim2.new(0, 2, 0.5, -9)
        dot.BackgroundColor3 = self._theme.Muted
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

        local state = opts2.Default == true
        local function set(v)
            state = v and true or false
            tween(dot, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
            knob.BackgroundColor3 = state and self._theme.Accent or self._theme.ElemHover
            if typeof(opts2.Callback) == "function" then opts2.Callback(state) end
            if opts2.Flag then self._parent.Flags[opts2.Flag] = state end
        end
        set(state)
        knob.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then set(not state) end
        end)
        return {Set=set, Get=function() return state end}
    end

    function TabMT:AddSlider(opts2)
        local min, max = tonumber(opts2.Min) or 0, tonumber(opts2.Max) or 100
        local step = tonumber(opts2.Step) or 1
        local value = math.clamp(tonumber(opts2.Default) or min, min, max)
        local e = newElementFrame(self._theme)
        e.Parent = self.Container
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -12, 0, 18)
        lbl.Position = UDim2.new(0, 12, 0, 4)
        lbl.Text = string.format("%s: %s", opts2.Name or "Slider", tostring(value))
        lbl.TextColor3 = self._theme.Text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.Parent = e
        local bar = Instance.new("Frame", e)
        bar.Size = UDim2.new(1, -24, 0, 6)
        bar.Position = UDim2.new(0, 12, 0, 40)
        bar.BackgroundColor3 = self._theme.ElemHover
        bar.BorderSizePixel = 0
        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = self._theme.Accent
        fill.BorderSizePixel = 0
        local uiC1 = Instance.new("UICorner", bar) uiC1.CornerRadius = UDim.new(1,0)
        local uiC2 = Instance.new("UICorner", fill) uiC2.CornerRadius = UDim.new(1,0)

        local dragging = false
        local function set(v)
            v = math.clamp(math.round(v/step)*step, min, max)
            value = v
            local alpha = (value-min)/(max-min)
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            lbl.Text = string.format("%s: %s", opts2.Name or "Slider", tostring(value))
            if typeof(opts2.Callback) == "function" then opts2.Callback(value) end
            if opts2.Flag then self._parent.Flags[opts2.Flag] = value end
        end
        set(value)
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = (i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
                set(min + rel * (max-min))
            end
        end)
        return {Set=set, Get=function() return value end}
    end

    function TabMT:AddDropdown(opts2)
        local e = newElementFrame(self._theme)
        e.Parent = self.Container
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -12, 0, 18)
        lbl.Position = UDim2.new(0, 12, 0, 4)
        lbl.Text = opts2.Name or "Dropdown"
        lbl.TextColor3 = self._theme.Text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.Parent = e

        local box = Instance.new("TextButton")
        box.Size = UDim2.new(1, -24, 0, 24)
        box.Position = UDim2.new(0, 12, 0, 20)
        box.Text = tostring(opts2.Default or "Select")
        box.TextColor3 = self._theme.Text
        box.Font = Enum.Font.Gotham
        box.TextSize = 14
        box.BackgroundColor3 = self._theme.ElemHover
        box.Parent = e
        Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

        local list = Instance.new("Frame")
        list.Visible = false
        list.Size = UDim2.new(1, -24, 0, 120)
        list.Position = UDim2.new(0, 12, 0, 50)
        list.BackgroundColor3 = self._theme.Elem
        list.Parent = e
        Instance.new("UICorner", list)

        local sf = Instance.new("ScrollingFrame", list)
        sf.Size = UDim2.new(1, -6, 1, -6)
        sf.Position = UDim2.new(0, 3, 0, 3)
        sf.BackgroundTransparency = 1
        sf.ScrollBarThickness = 4

        local lay = Instance.new("UIListLayout", sf)
        lay.Padding = UDim.new(0,6)

        local value = opts2.Default
        local function set(v)
            value = v
            box.Text = tostring(v)
            if typeof(opts2.Callback) == "function" then opts2.Callback(v) end
            if opts2.Flag then self._parent.Flags[opts2.Flag] = v end
        end

        local function rebuild()
            sf.CanvasSize = UDim2.new()
            for _,c in ipairs(sf:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            for _,opt in ipairs(opts2.Options or {}) do
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1,0,0,24)
                b.Text = tostring(opt)
                b.Font = Enum.Font.Gotham
                b.TextSize = 14
                b.TextColor3 = self._theme.Text
                b.BackgroundColor3 = self._theme.ElemHover
                b.Parent = sf
                Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
                b.MouseButton1Click:Connect(function()
                    set(opt)
                    list.Visible = false
                end)
            end
            task.wait()
            sf.CanvasSize = UDim2.new(0,0,0, lay.AbsoluteContentSize.Y + 8)
        end

        rebuild()
        set(value or (opts2.Options and opts2.Options[1]))
        box.MouseButton1Click:Connect(function()
            list.Visible = not list.Visible
        end)
        return {Set=set, Get=function()return value end, SetOptions=function(o) opts2.Options=o rebuild() end}
    end

    function TabMT:AddInput(opts2)
        local e = newElementFrame(self._theme)
        e.Parent = self.Container
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -12, 0, 18)
        lbl.Position = UDim2.new(0, 12, 0, 4)
        lbl.Text = opts2.Name or "Input"
        lbl.TextColor3 = self._theme.Text
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.Parent = e
        local tb = Instance.new("TextBox")
        tb.Size = UDim2.new(1, -24, 0, 24)
        tb.Position = UDim2.new(0, 12, 0, 20)
        tb.PlaceholderText = opts2.Placeholder or ""
        tb.Text = tostring(opts2.Default or "")
        tb.TextColor3 = self._theme.Text
        tb.Font = Enum.Font.Gotham
        tb.TextSize = 14
        tb.BackgroundColor3 = self._theme.ElemHover
        tb.ClearTextOnFocus = false
        tb.Parent = e
        Instance.new("UICorner", tb).CornerRadius = UDim.new(0,6)

        local function set(v)
            tb.Text = tostring(v)
            if typeof(opts2.Callback) == "function" then opts2.Callback(tb.Text) end
            if opts2.Flag then self._parent.Flags[opts2.Flag] = tb.Text end
        end
        tb.FocusLost:Connect(function()
            set(tb.Text)
        end)
        if opts2.Default ~= nil then set(opts2.Default) end
        return {Set=set, Get=function() return tb.Text end}
    end

    function self:AddTab(opts2)
        local btn = Instance.new("Frame")
        btn.Name = (opts2.Name or "Tab") .. "Btn"
        btn.Size = UDim2.new(1, -12, 0, 36)
        btn.BackgroundColor3 = self.Theme.Elem
        btn.Parent = tabList
        local corner = Instance.new("UICorner", btn) corner.CornerRadius = UDim.new(0,8)
        if opts2.Icon then
            local img = Instance.new("ImageLabel", btn)
            img.Size = UDim2.new(0, 24, 0, 24)  -- Ukuran ikon
            img.Position = UDim2.new(0, 6, 0.5, -12)  -- Posisi ikon
            img.BackgroundTransparency = 1
            img.Image = "https://cdn3.iconfinder.com/data/icons/fluent-regular-24px-vol-4/24/ic_fluent_home_24_regular-256.png"  -- Gunakan rbxassetid atau URL gambar
        end

        -- TextLabel untuk nama tab
        local t = Instance.new("TextLabel", btn)
        t.Size = UDim2.new(1, -40, 1, 0)  -- Sisa ruang untuk teks (40px untuk ikon)
        t.Position = UDim2.new(0, 30, 0, 0)  -- Posisi nama di samping ikon
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.Gotham
        t.TextSize = 14
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextColor3 = self.Theme.Text
        t.Text = opts2.Name or "Tab"
        local uiS = Instance.new("UIStroke", btn) uiS.Color = self.Theme.Stroke uiS.Transparency = 0.6

        local page = Instance.new("ScrollingFrame")
        page.Name = opts2.Name or "Tab"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 6
        page.Parent = elements

        local lay = Instance.new("UIListLayout", page)
        lay.Padding = UDim.new(0, 8)
        lay.SortOrder = Enum.SortOrder.LayoutOrder

        page.Visible = false
        self._tabCount += 1

        local tabObj = setmetatable({
            Container = page,
            Button = btn,
            _theme = self.Theme,
            _parent = self
        }, TabMT)

        local clicker = Instance.new("TextButton")
        clicker.Size = UDim2.new(1, 0, 1, 0)
        clicker.BackgroundTransparency = 1
        clicker.Text = ""
        clicker.Parent = btn

        clicker.MouseButton1Click:Connect(function()
            self:_setActivePage(page)

            -- update style tab aktif
            for _, child in ipairs(tabList:GetChildren()) do
                if child:IsA("Frame") then
                    child.BackgroundTransparency = (child == btn) and 0 or 0.3
                end
            end
        end)

        if #elements:GetChildren() == 1 then
            page.Visible = true
            self:_setActivePage(page)
        end

        task.defer(function()
            tabList.CanvasSize = UDim2.new(0,0,0, tabLayout.AbsoluteContentSize.Y + 12)
        end)

        if not self._activePage then
            self._activePage = page
            page.Visible = true
            self._pages:JumpTo(page)
            btn.BackgroundTransparency = 0
        end

        return tabObj
    end

    function self:_setActivePage(targetPage)
        for _, child in ipairs(self._elements:GetChildren()) do
            if child:IsA("ScrollingFrame") then
                child.Visible = (child == targetPage)
            end
        end
        self._pages:JumpTo(targetPage)
        self._activePage = targetPage
    end    

    function self:Notify(data)
        data = data or {}
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 320, 0, 0)
        container.BackgroundColor3 = self.Theme.Elem
        container.BorderSizePixel = 0
        container.Parent = notifRoot
        Instance.new("UICorner", container).CornerRadius = UDim.new(0,10)
        local stroke = Instance.new("UIStroke", container) stroke.Color = self.Theme.Stroke stroke.Transparency=0.6
        local ttl = Instance.new("TextLabel", container)
        ttl.BackgroundTransparency = 1
        ttl.Text = data.Title or "Notification"
        ttl.TextColor3 = self.Theme.Text
        ttl.Font = Enum.Font.GothamBold
        ttl.TextSize = 14
        ttl.Size = UDim2.new(1, -16, 0, 22)
        ttl.Position = UDim2.new(0, 8, 0, 8)
        local desc = Instance.new("TextLabel", container)
        desc.BackgroundTransparency = 1
        desc.TextWrapped = true
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.Text = data.Content or ""
        desc.TextColor3 = self.Theme.Text
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 13
        desc.Position = UDim2.new(0, 8, 0, 32)
        desc.Size = UDim2.new(1, -16, 0, 0)

        task.wait()
        desc.Size = UDim2.new(1, -16, 0, math.max(20, desc.TextBounds.Y))
        container.Size = UDim2.new(0, 320, 0, desc.AbsoluteSize.Y + 46)
        container.BackgroundTransparency = 0
        stroke.Transparency = 1
        ttl.TextTransparency = 1
        desc.TextTransparency = 1
        tween(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.1}):Play()
        tween(stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Transparency = 0.6}):Play()
        tween(ttl, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
        tween(desc, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextTransparency = 0.2}):Play()

        task.delay(data.Duration or 4, function()
            tween(ttl, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            tween(desc, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            tween(container, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            tween(stroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
            task.wait(0.22)
            container:Destroy()
        end)
    end

    function self:SetTheme(theme)
        if typeof(theme) == "string" then
            self.Theme = THEMES[theme] or self.Theme
        elseif typeof(theme) == "table" then
            self.Theme = theme
        end
        -- For simplicity, theme changes affect new elements; full live-repaint omitted in v0.1
    end

    function self:SaveConfig()
        if not self.ConfigName or not canIO() then return end
        local data = {}
        for k,v in pairs(self.Flags) do data[k] = v end
        local ok, j = pcall(function() return game:GetService("HttpService"):JSONEncode(data) end)
        if ok then writefile(self.ConfigName..".litefield.json", j) end
    end

    function self:LoadConfig()
        if not self.ConfigName or not canIO() then return end
        local path = self.ConfigName..".litefield.json"
        if isfile(path) then
            local j = readfile(path)
            local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(j) end)
            if ok and typeof(data) == "table" then
                for k,v in pairs(data) do self.Flags[k] = v end
            end
        end
    end

    -- Behavior: keybind toggle visibility
    local hidden, minimized = false, false
    local function setHidden(v)
        hidden = v
        main.Visible = not v
    end
    local function setMinimized(v)
        minimized = v
        local target = v and UDim2.new(0,520,0,46) or UDim2.new(0,520,0,280)
        tween(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = target}):Play()

        main.Position = UDim2.new(0.5, 0, 0.5, -main.Size.Y.Offset / 2)
    end

    btnHide.MouseButton1Click:Connect(function() setHidden(true) end)
    btnMini.MouseButton1Click:Connect(function() setMinimized(not minimized) end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == self.Keybind then
            setHidden(not hidden)
        end
    end)

    makeDraggable(main, top)

    -- Scrolling padding
    local function updatePages()
        for _, p in ipairs(elements:GetChildren()) do
            if p:IsA("ScrollingFrame") then
                local lay = p:FindFirstChildOfClass("UIListLayout")
                if lay then p.CanvasSize = UDim2.new(0,0,0, lay.AbsoluteContentSize.Y + 12) end
            end
        end
    end
    elements.ChildAdded:Connect(updatePages)
    RunService.RenderStepped:Connect(updatePages)

    -- Auto-load config
    self:LoadConfig()

    return self
end

return LiteField
