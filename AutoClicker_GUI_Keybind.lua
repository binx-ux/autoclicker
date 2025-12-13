-- Bin Hub X - Argon-style Hub v3.5 (Rebuild)
-- RightCtrl = Show/Hide Hub

---------------------------------------------------------------------//
-- SERVICES / SETUP
---------------------------------------------------------------------//
local Players            = game:GetService("Players")
local UIS                = game:GetService("UserInputService")
local CoreGui            = game:GetService("CoreGui")
local TweenService       = game:GetService("TweenService")
local RunService         = game:GetService("RunService")
local HttpService        = game:GetService("HttpService")
local Lighting           = game:GetService("Lighting")
local StatsService       = game:FindService("Stats") or game:GetService("Stats")

local LocalPlayer        = Players.LocalPlayer
local displayName        = (LocalPlayer and LocalPlayer.DisplayName) or "Player"
local userName           = (LocalPlayer and LocalPlayer.Name)        or "Unknown"

local TIKTOK_HANDLE      = "@binxix"
local CURRENT_VERSION    = "3.5"

---------------------------------------------------------------------//
-- SAFE GUI PARENT
---------------------------------------------------------------------//
local function safeParent(gui)
    local ok, _ = pcall(function()
        if gethui then
            gui.Parent = gethui()
        end
    end)
    if ok and gui.Parent then return gui end

    ok, _ = pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
            gui.Parent = CoreGui
        end
    end)
    if ok and gui.Parent then return gui end

    gui.Parent = CoreGui
    return gui
end

---------------------------------------------------------------------//
-- SCREEN GUI
---------------------------------------------------------------------//
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BinHubX_v3_5"
ScreenGui.ResetOnSpawn = false
safeParent(ScreenGui)

---------------------------------------------------------------------//
-- MAIN WINDOW
---------------------------------------------------------------------//
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 330)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner_Main = Instance.new("UICorner", MainFrame)
UICorner_Main.CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 1.2
MainStroke.Color = Color3.fromRGB(90, 90, 255)
MainStroke.Transparency = 0.25

---------------------------------------------------------------------//
-- TOP BAR
---------------------------------------------------------------------//
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local UICorner_Top = Instance.new("UICorner", TopBar)
UICorner_Top.CornerRadius = UDim.new(0, 12)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "BinHub X  v" .. CURRENT_VERSION .. "  |  " .. userName
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextColor3 = Color3.fromRGB(235, 235, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "Close"
CloseButton.Size = UDim2.new(0, 30, 0, 22)
CloseButton.Position = UDim2.new(1, -35, 0.5, -11)
CloseButton.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.TextColor3 = Color3.fromRGB(255, 150, 150)
CloseButton.Parent = TopBar

local UICorner_Close = Instance.new("UICorner", CloseButton)
UICorner_Close.CornerRadius = UDim.new(0, 6)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

---------------------------------------------------------------------//
-- SIDEBAR (TABS)
---------------------------------------------------------------------//
local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
SideBar.Size = UDim2.new(0, 130, 1, -36)
SideBar.Position = UDim2.new(0, 0, 0, 36)
SideBar.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local UICorner_Side = Instance.new("UICorner", SideBar)
UICorner_Side.CornerRadius = UDim.new(0, 12)

local TabList = Instance.new("UIListLayout", SideBar)
TabList.FillDirection = Enum.FillDirection.Vertical
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 4)

---------------------------------------------------------------------//
-- PAGE CONTAINER
---------------------------------------------------------------------//
local PageContainer = Instance.new("Frame")
PageContainer.Name = "PageContainer"
PageContainer.Size = UDim2.new(1, -145, 1, -40)
PageContainer.Position = UDim2.new(0, 140, 0, 38)
PageContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
PageContainer.BorderSizePixel = 0
PageContainer.Parent = MainFrame

local UICorner_Page = Instance.new("UICorner", PageContainer)
UICorner_Page.CornerRadius = UDim.new(0, 12)

---------------------------------------------------------------------//
-- TAB/PAGE REGISTRY
---------------------------------------------------------------------//
local Tabs = {}
local Pages = {}
local CurrentTab = nil

local function createPage(name)
    local page = Instance.new("Frame")
    page.Name = name .. "_Page"
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = PageContainer

    local scrolling = Instance.new("ScrollingFrame")
    scrolling.Name = "Scroll"
    scrolling.Size = UDim2.new(1, 0, 1, 0)
    scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrolling.ScrollBarThickness = 4
    scrolling.BackgroundTransparency = 1
    scrolling.BorderSizePixel = 0
    scrolling.Parent = page

    local layout = Instance.new("UIListLayout", scrolling)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)

    local padding = Instance.new("UIPadding", scrolling)
    padding.PaddingTop = UDim.new(0, 6)
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 6)

    return page, scrolling
end

local function setActiveTab(tabName)
    for name, btn in pairs(Tabs) do
        if name == tabName then
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
        else
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
        end
    end

    for name, page in pairs(Pages) do
        page.Visible = (name == tabName)
    end

    CurrentTab = tabName
end

local function createTab(tabName, order)
    local btn = Instance.new("TextButton")
    btn.Name = tabName .. "_Tab"
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(220, 220, 245)
    btn.LayoutOrder = order or 1
    btn.Parent = SideBar

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)

    Tabs[tabName] = btn

    local page, scroll = createPage(tabName)
    Pages[tabName] = page

    btn.MouseButton1Click:Connect(function()
        setActiveTab(tabName)
    end)

    return page, scroll
end

---------------------------------------------------------------------//
-- CREATE ALL TABS
---------------------------------------------------------------------//
local MainPage, MainScroll       = createTab("Main",   1)
local PlayerPage, PlayerScroll   = createTab("Player", 2)
local VisualPage, VisualScroll   = createTab("Visual", 3)
local MiscPage, MiscScroll       = createTab("Misc",   4)
local CreditsPage, CreditsScroll = createTab("Credits",5)

-- Default tab
setActiveTab("Main")
---------------------------------------------------------------------//
-- SMALL UI HELPERS
---------------------------------------------------------------------//
local function makeSection(parent, titleText)
    local section = Instance.new("Frame")
    section.Name = titleText .. "_Section"
    section.Size = UDim2.new(1, -4, 0, 30)
    section.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    section.BorderSizePixel = 0
    section.Parent = parent

    local corner = Instance.new("UICorner", section)
    corner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(235, 235, 255)
    label.Text = titleText
    label.Parent = section

    return section, label
end

local function makeToggle(parent, labelText, default)
    local frame = Instance.new("Frame")
    frame.Name = labelText .. "_Toggle"
    frame.Size = UDim2.new(1, -4, 0, 32)
    frame.BackgroundColor3 = Color3.fromRGB(16, 16, 26)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Text = labelText
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(0, 52, 0, 22)
    button.Position = UDim2.new(1, -60, 0.5, -11)
    button.BackgroundColor3 = default and Color3.fromRGB(60, 170, 90) or Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Text = default and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(240, 240, 255)
    button.Parent = frame

    local corner2 = Instance.new("UICorner", button)
    corner2.CornerRadius = UDim.new(0, 8)

    local state = default and true or false
    local function setState(v)
        state = v and true or false
        if state then
            button.BackgroundColor3 = Color3.fromRGB(60, 170, 90)
            button.Text = "ON"
        else
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            button.Text = "OFF"
        end
    end

    button.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    setState(default)

    return {
        Frame = frame,
        Label = label,
        Button = button,
        Get = function() return state end,
        Set = setState,
        OnClick = function(cb)
            button.MouseButton1Click:Connect(function()
                setState(not state)
                cb(state)
            end)
        end,
    }
end

local function makeButton(parent, labelText)
    local button = Instance.new("TextButton")
    button.Name = labelText .. "_Button"
    button.Size = UDim2.new(1, -4, 0, 32)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 13
    button.TextColor3 = Color3.fromRGB(230, 230, 255)
    button.Text = labelText
    button.Parent = parent

    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 8)

    return button
end

---------------------------------------------------------------------//
-- MAIN TAB CONTENT
---------------------------------------------------------------------//
do
    local secInfo = makeSection(MainScroll, "Player Info")
    secInfo.Size = UDim2.new(1, -4, 0, 60)

    local infoLabel = Instance.new("TextLabel")
    infoLabel.BackgroundTransparency = 1
    infoLabel.Size = UDim2.new(1, -10, 0, 40)
    infoLabel.Position = UDim2.new(0, 6, 0, 18)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 12
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.TextColor3 = Color3.fromRGB(210, 210, 235)
    infoLabel.TextWrapped = true
    infoLabel.Text = "Display: " .. displayName .. "\nUser: " .. userName
    infoLabel.Parent = secInfo

    local secStats = makeSection(MainScroll, "Live Stats")
    secStats.Size = UDim2.new(1, -4, 0, 70)

    local statsLabel = Instance.new("TextLabel")
    statsLabel.BackgroundTransparency = 1
    statsLabel.Size = UDim2.new(1, -10, 0, 50)
    statsLabel.Position = UDim2.new(0, 6, 0, 18)
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.TextSize = 12
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.TextYAlignment = Enum.TextYAlignment.Top
    statsLabel.TextColor3 = Color3.fromRGB(210, 210, 235)
    statsLabel.TextWrapped = true
    statsLabel.Text = "Game: " .. (game.PlaceId or 0) .. "\nFPS: ... | Ping: ..."
    statsLabel.Parent = secStats

    MainScroll.CanvasSize = UDim2.new(0, 0, 0, 150)

    -- store for later update loop
    ScreenGui:SetAttribute("StatsLabelRef", statsLabel)
end

---------------------------------------------------------------------//
-- PLAYER TAB CONTENT
---------------------------------------------------------------------//
local walkToggle, jumpToggle, bhopToggle
do
    local sec = makeSection(PlayerScroll, "Movement")
    sec.Size = UDim2.new(1, -4, 0, 30)

    walkToggle = makeToggle(PlayerScroll, "WalkSpeed Boost", false)
    jumpToggle = makeToggle(PlayerScroll, "JumpPower Boost", false)
    bhopToggle = makeToggle(PlayerScroll, "Auto Bunny Hop (Space)", false)

    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 140)
end

---------------------------------------------------------------------//
-- VISUAL TAB CONTENT
---------------------------------------------------------------------//
local fullBrightToggle, noFogToggle
do
    local sec = makeSection(VisualScroll, "World Visuals")
    sec.Size = UDim2.new(1, -4, 0, 30)

    fullBrightToggle = makeToggle(VisualScroll, "FullBright", false)
    noFogToggle      = makeToggle(VisualScroll, "No Fog",    false)

    VisualScroll.CanvasSize = UDim2.new(0, 0, 0, 120)
end

---------------------------------------------------------------------//
-- MISC TAB CONTENT
---------------------------------------------------------------------//
do
    local sec = makeSection(MiscScroll, "Utility")
    sec.Size = UDim2.new(1, -4, 0, 30)

    local rejoinBtn = makeButton(MiscScroll, "Rejoin Server")
    local hopBtn    = makeButton(MiscScroll, "Server Hop (Random)")

    rejoinBtn.MouseButton1Click:Connect(function()
        local ts = game:GetService("TeleportService")
        local pid = game.PlaceId
        local jobid = game.JobId
        ts:TeleportToPlaceInstance(pid, jobid, LocalPlayer)
    end)

    hopBtn.MouseButton1Click:Connect(function()
        local ts = game:GetService("TeleportService")
        local pid = game.PlaceId
        ts:Teleport(pid, LocalPlayer)
    end)

    MiscScroll.CanvasSize = UDim2.new(0, 0, 0, 120)
end

---------------------------------------------------------------------//
-- CREDITS TAB CONTENT
---------------------------------------------------------------------//
do
    local sec = makeSection(CreditsScroll, "Credits")
    sec.Size = UDim2.new(1, -4, 0, 30)

    local txt = Instance.new("TextLabel")
    txt.BackgroundTransparency = 1
    txt.Size = UDim2.new(1, -10, 0, 80)
    txt.Position = UDim2.new(0, 6, 0, 22)
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 12
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextYAlignment = Enum.TextYAlignment.Top
    txt.TextColor3 = Color3.fromRGB(210, 210, 235)
    txt.TextWrapped = true
    txt.Text = table.concat({
        "Script: BinHub X v" .. CURRENT_VERSION,
        "Made by: Binxix",
        "TikTok: " .. TIKTOK_HANDLE,
        "",
        "Use at your own risk. For testing & education."
    }, "\n")
    txt.Parent = CreditsScroll

    CreditsScroll.CanvasSize = UDim2.new(0, 0, 0, 140)
end

---------------------------------------------------------------------//
-- BOTTOM-RIGHT WATERMARK
---------------------------------------------------------------------//
local Watermark = Instance.new("TextLabel")
Watermark.Name = "Watermark"
Watermark.AnchorPoint = Vector2.new(1, 1)
Watermark.Position = UDim2.new(1, -8, 1, -6)
Watermark.Size = UDim2.new(0, 260, 0, 22)
Watermark.BackgroundTransparency = 0.3
Watermark.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Watermark.BorderSizePixel = 0
Watermark.Font = Enum.Font.GothamSemibold
Watermark.TextSize = 11
Watermark.TextXAlignment = Enum.TextXAlignment.Right
Watermark.TextColor3 = Color3.fromRGB(210, 210, 240)
Watermark.Text = "Anticheat Bypass (visual) | Script made by Binxix"
Watermark.Parent = MainFrame

local WMCorner = Instance.new("UICorner", Watermark)
WMCorner.CornerRadius = UDim.new(0, 8)
---------------------------------------------------------------------//
-- HUMANOID HELPERS
---------------------------------------------------------------------//
local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
end)

---------------------------------------------------------------------//
-- PLAYER MOVEMENT LOGIC
---------------------------------------------------------------------//
local defaultWalkspeed = 16
local defaultJumpPower = 50

local function applyMovementSettings()
    local hum = getHumanoid()
    if not hum then return end

    if walkToggle and walkToggle.Get() then
        hum.WalkSpeed = 24
    else
        hum.WalkSpeed = defaultWalkspeed
    end

    if jumpToggle and jumpToggle.Get() then
        hum.JumpPower = 70
    else
        hum.JumpPower = defaultJumpPower
    end
end

if walkToggle then
    walkToggle.OnClick(function()
        applyMovementSettings()
    end)
end

if jumpToggle then
    jumpToggle.OnClick(function()
        applyMovementSettings()
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applyMovementSettings()
end)

---------------------------------------------------------------------//
-- BHOP (AUTO JUMP ON SPACE)
---------------------------------------------------------------------//
local bhopEnabled = false

if bhopToggle then
    bhopToggle.OnClick(function(state)
        bhopEnabled = state
    end)
end

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Space and bhopEnabled then
        local hum = getHumanoid()
        if hum and hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

---------------------------------------------------------------------//
-- VISUALS: FULLBRIGHT + NO FOG
---------------------------------------------------------------------//
local savedLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    Ambient = Lighting.Ambient,
    ColorShift_Top = Lighting.ColorShift_Top,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
}

local function applyVisuals()
    if fullBrightToggle and fullBrightToggle.Get() then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
        Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = savedLighting.Brightness
        Lighting.ClockTime = savedLighting.ClockTime
        Lighting.Ambient = savedLighting.Ambient
        Lighting.ColorShift_Top = savedLighting.ColorShift_Top
        Lighting.ColorShift_Bottom = savedLighting.ColorShift_Bottom
    end

    if noFogToggle and noFogToggle.Get() then
        Lighting.FogEnd = 999999
    else
        Lighting.FogEnd = savedLighting.FogEnd
    end
end

if fullBrightToggle then
    fullBrightToggle.OnClick(function()
        applyVisuals()
    end)
end

if noFogToggle then
    noFogToggle.OnClick(function()
        applyVisuals()
    end)
end

applyVisuals()

---------------------------------------------------------------------//
-- LIVE STATS: FPS + PING
---------------------------------------------------------------------//
local statsLabel = ScreenGui:GetAttribute("StatsLabelRef")

local fps = 60
RunService.RenderStepped:Connect(function(dt)
    fps = 1 / math.max(dt, 0.0001)
end)

local function getPing()
    local pingValue = "..."
    local ok, result = pcall(function()
        local netStats = StatsService.Network
        local pingStat = netStats:FindFirstChild("ServerStatsItem") 
        if pingStat and pingStat:FindFirstChild("Data Ping") then
            return math.floor(pingStat["Data Ping"]:GetValue())
        end
        return nil
    end)
    if ok and result then
        pingValue = tostring(result)
    end
    return pingValue
end

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1)
        if typeof(statsLabel) == "Instance" and statsLabel:IsA("TextLabel") then
            local ping = getPing()
            statsLabel.Text = string.format(
                "Game: %s\nFPS: %d | Ping: %s ms",
                tostring(game.PlaceId),
                math.floor(fps + 0.5),
                tostring(ping)
            )
        end
    end
end)

---------------------------------------------------------------------//
-- TOGGLE HUB (RIGHT CTRL)
---------------------------------------------------------------------//
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

---------------------------------------------------------------------//
-- INITIAL APPLY
---------------------------------------------------------------------//
applyMovementSettings()
applyVisuals()
