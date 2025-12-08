---------------------------------------------------------------------
--  BIN HUB X - ARGON STYLE HUB v3.6 (CORE PART 1)
--  Author: BinXix • Custom Theme Edition
---------------------------------------------------------------------

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------
local Players              = game:GetService("Players")
local UIS                  = game:GetService("UserInputService")
local RunService           = game:GetService("RunService")
local HttpService          = game:GetService("HttpService")
local CoreGui              = game:GetService("CoreGui")
local TweenService         = game:GetService("TweenService")
local MarketplaceService   = game:GetService("MarketplaceService")
local LocalizationService  = game:GetService("LocalizationService")
local StatsService         = game:GetService("Stats")

local LocalPlayer          = Players.LocalPlayer
local Character            = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

---------------------------------------------------------------------
-- CUSTOM BINXIX THEME COLORS (BLACK • GOLD • WHITE)
---------------------------------------------------------------------
local BINXIX_THEME = {
    Accent       = Color3.fromRGB(255, 215, 0),     -- Gold
    AccentOn     = Color3.fromRGB(255, 170, 0),     -- Bright Gold
    TextPrimary  = Color3.fromRGB(255,255,255),     -- White
    TextDim      = Color3.fromRGB(200,200,200),
    Background1  = Color3.fromRGB(10,10,10),        -- Near-black
    Background2  = Color3.fromRGB(20,20,20),
    Panel        = Color3.fromRGB(15,15,15),
    Stroke       = Color3.fromRGB(50,50,50),
}

---------------------------------------------------------------------
-- EXECUTOR SAFE REQUEST FUNCTION
---------------------------------------------------------------------
local function SafeRequest()
    return request or http_request or (syn and syn.request) or (http and http.request) or nil
end

---------------------------------------------------------------------
-- HASH LIBRARY (for HWID hashing)
---------------------------------------------------------------------
local function md5(str)
    local f = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATrainz/HashLibrary/main/md5.lua"))()
    return f(str)
end

---------------------------------------------------------------------
-- GET HASHED HWID
---------------------------------------------------------------------
local function GetHashedHWID()
    local raw = "unknown_hwid"

    pcall(function()
        if gethwid then
            raw = gethwid()
        elseif identifyexecutor then
            raw = tostring(identifyexecutor()) .. (game:GetService("RbxAnalyticsService"):GetClientId() or "")
        elseif game:GetService("RbxAnalyticsService") then
            raw = game:GetService("RbxAnalyticsService"):GetClientId()
        end
    end)

    return md5(raw)
end

---------------------------------------------------------------------
-- EXECUTION COUNTER (PERSISTENT)
---------------------------------------------------------------------
if not isfile("BinHubX_execCount.txt") then
    writefile("BinHubX_execCount.txt", "0")
end

local execCount = tonumber(readfile("BinHubX_execCount.txt")) or 0
execCount += 1
writefile("BinHubX_execCount.txt", tostring(execCount))

---------------------------------------------------------------------
-- MAIN WEBHOOK + BUG REPORT WEBHOOK
---------------------------------------------------------------------
local MAIN_WEBHOOK = "https://discord.com/api/webhooks/1446656470287651050/ayflCl7nEQ3388YhXAZT7r3j5kTC40EP3WV9yO1BehR2vzHbtoDArV-YejWn_E_F6eUk"
local BUG_WEBHOOK  = MAIN_WEBHOOK -- your request: use same webhook

---------------------------------------------------------------------
-- GAME NAME FETCH
---------------------------------------------------------------------
local function GetGameName()
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if ok and info then
        return info.Name
    end
    return "Unknown Game"
end

---------------------------------------------------------------------
-- EXECUTOR DECTION
---------------------------------------------------------------------
local function DetectExecutor()
    local result = "Unknown"
    pcall(function()
        if identifyexecutor then
            local a,b = identifyexecutor()
            if b then result = tostring(a).." "..tostring(b)
            else result = tostring(a) end
        elseif getexecutorname then
            result = getexecutorname()
        end
    end)
    return result
end

---------------------------------------------------------------------
-- SEND EXECUTION LOG WEBHOOK
---------------------------------------------------------------------
local function SendExecutionLog()
    local req = SafeRequest()
    if not req then return end

    local data = {
        embeds = {{
            title = "🔥 Bin Hub X Loaded (v3.6)",
            color = 0xFFD700, -- Gold
            fields = {
                { name = "Player", value = "**"..LocalPlayer.DisplayName.."** (`"..LocalPlayer.Name.."`)", inline = false },
                { name = "Game", value = GetGameName() .. "\nPlaceId: `" .. game.PlaceId .. "`", inline = false },
                { name = "Executor", value = DetectExecutor(), inline = false },
                { name = "Hashed HWID", value = "```"..GetHashedHWID().."```", inline = false },
                { name = "Execution #", value = tostring(execCount), inline = false },
                { name = "Time", value = os.date("%Y-%m-%d %H:%M:%S"), inline = false },
            }
        }}
    }

    req({
        Url = MAIN_WEBHOOK,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })
end

---------------------------------------------------------------------
-- SEND BUG REPORT
---------------------------------------------------------------------
function SendBug_Report(msg)
    local req = SafeRequest()
    if not req then return false, "Executor blocked request" end
    if not msg or msg:gsub("%s+","") == "" then return false, "Empty" end
    
    local data = {
        embeds = {{
            title = "🐞 Bug Report - Bin Hub X",
            color = 0xFF4444,
            fields = {
                { name = "Player", value = LocalPlayer.Name, inline = false },
                { name = "Report", value = "```"..msg.."```", inline = false },
                { name = "Time", value = os.date("%Y-%m-%d %H:%M:%S"), inline = false }
            }
        }}
    }

    req({
        Url = BUG_WEBHOOK,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })

    return true
end

---------------------------------------------------------------------
-- AUTO UPDATER (checks GitHub for newer version)
---------------------------------------------------------------------
local VERSION = "3.6"

local function CheckUpdate()
    local success, online = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/ATrainz/BinHubX/main/version.txt")
    end)

    if success and online then
        if tostring(online) ~= VERSION then
            print("BinHubX: Update found! Online version:", online)
        end
    end
end

---------------------------------------------------------------------
-- GUI SAFE PARENT (gethui / syn.protect_gui)
---------------------------------------------------------------------
local function SafeParent()
    local g

    pcall(function()
        if gethui then
            g = Instance.new("ScreenGui")
            g.Name = "BinHubX"
            g.ResetOnSpawn = false
            g.Parent = gethui()
        end
    end)

    if not g then
        pcall(function()
            if syn and syn.protect_gui then
                g = Instance.new("ScreenGui")
                g.Name = "BinHubX"
                g.ResetOnSpawn = false
                syn.protect_gui(g)
                g.Parent = CoreGui
            end
        end)
    end

    if not g then
        g = Instance.new("ScreenGui")
        g.Name = "BinHubX"
        g.ResetOnSpawn = false
        g.Parent = CoreGui
    end

    return g
end

local GUI = SafeParent()

---------------------------------------------------------------------
-- FIRE WEBHOOK ON LOAD
---------------------------------------------------------------------
task.spawn(function()
    task.wait(1)
    SendExecutionLog()
    CheckUpdate()
end)
---------------------------------------------------------------------
-- PART 2 — ROOT UI + SIDEBAR + NAVIGATION + THEMES
---------------------------------------------------------------------

local Theme = BINXIX_THEME  -- from Part 1

---------------------------------------------------------------------
-- ROOT WINDOW
---------------------------------------------------------------------
local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.new(0, 720, 0, 380)
root.Position = UDim2.new(0.5, -360, 0.5, -190)
root.BackgroundColor3 = Theme.Background1
root.BorderSizePixel = 0
root.ZIndex = 1
root.Parent = GUI

local rootCorner = Instance.new("UICorner")
rootCorner.CornerRadius = UDim.new(0, 18)
rootCorner.Parent = root

local rootStroke = Instance.new("UIStroke")
rootStroke.Thickness = 1
rootStroke.Color = Theme.Stroke
rootStroke.Parent = root

-- Gold gradient overlay
local rootGradient = Instance.new("UIGradient")
rootGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25,20,0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10,10,10))
})
rootGradient.Rotation = 45
rootGradient.Parent = root

---------------------------------------------------------------------
-- SIDEBAR
---------------------------------------------------------------------
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 230, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = Theme.Background2
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 2
sidebar.Parent = root

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 18)
sideCorner.Parent = sidebar

local sideStroke = Instance.new("UIStroke")
sideStroke.Thickness = 1
sideStroke.Color = Theme.Stroke
sideStroke.Parent = sidebar

---------------------------------------------------------------------
-- SIDEBAR TITLE
---------------------------------------------------------------------
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 0, 34)
title.Position = UDim2.new(0, 18, 0, 14)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextColor3 = Theme.TextPrimary
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "BinXix Hub X"
title.ZIndex = 3
title.Parent = sidebar

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(0, 70, 0, 24)
versionLabel.Position = UDim2.new(1, -82, 0, 14)
versionLabel.BackgroundColor3 = Theme.Accent
versionLabel.BorderSizePixel = 0
versionLabel.Font = Enum.Font.GothamBold
versionLabel.TextSize = 14
versionLabel.TextColor3 = Color3.fromRGB(0,0,0)
versionLabel.Text = "v3.6"
versionLabel.ZIndex = 3
versionLabel.Parent = sidebar

local versionCorner = Instance.new("UICorner")
versionCorner.CornerRadius = UDim.new(1,0)
versionCorner.Parent = versionLabel

---------------------------------------------------------------------
-- SEARCH BOX (not functional yet, added for UI)
---------------------------------------------------------------------
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -36, 0, 32)
searchBox.Position = UDim2.new(0, 18, 0, 58)
searchBox.BackgroundColor3 = Theme.Panel
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "Search"
searchBox.Text = ""
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.TextColor3 = Theme.TextPrimary
searchBox.PlaceholderColor3 = Theme.TextDim
searchBox.ZIndex = 3
searchBox.Parent = sidebar

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 10)
searchCorner.Parent = searchBox

---------------------------------------------------------------------
-- NAVIGATION HOLDER
---------------------------------------------------------------------
local navHolder = Instance.new("Frame")
navHolder.Size = UDim2.new(1, -36, 1, -150)
navHolder.Position = UDim2.new(0, 18, 0, 100)
navHolder.BackgroundTransparency = 1
navHolder.ZIndex = 3
navHolder.Parent = sidebar

local navLayout = Instance.new("UIListLayout")
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Padding = UDim.new(0, 6)
navLayout.Parent = navHolder

local pages = {}
local navButtons = {}

---------------------------------------------------------------------
-- PAGE CREATOR
---------------------------------------------------------------------
local function CreatePage(name)
    local page = Instance.new("Frame")
    page.Name = name.."Page"
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0,10,0,10)
    page.BackgroundColor3 = Theme.Panel
    page.BorderSizePixel = 0
    page.Visible = false
    page.ZIndex = 2
    page.Parent = root

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,16)
    c.Parent = page

    pages[name] = page
    return page
end

---------------------------------------------------------------------
-- CREATE PAGES
---------------------------------------------------------------------
local homePage     = CreatePage("Home")
local mainPage     = CreatePage("Main")
local blatantPage  = CreatePage("Blatant")
local othersPage   = CreatePage("Others")
local settingsPage = CreatePage("Settings")

---------------------------------------------------------------------
-- NAV SECTION LABEL
---------------------------------------------------------------------
local function Section(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,18)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextColor3 = Theme.TextDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 3
    lbl.Parent = navHolder
end

---------------------------------------------------------------------
-- NAV BUTTON
---------------------------------------------------------------------
local function NavButton(name, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Theme.Panel
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Theme.TextPrimary
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = text
    btn.ZIndex = 3
    btn.Parent = navHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for pageName, page in pairs(pages) do
            page.Visible = (pageName == name)
        end
        for navName, button in pairs(navButtons) do
            button.BackgroundColor3 = (navName == name)
                and Theme.Accent
                or Theme.Panel
        end
    end)

    navButtons[name] = btn
end

---------------------------------------------------------------------
-- NAVIGATION BUILD
---------------------------------------------------------------------
Section(" Home")
NavButton("Home", ".Dashboard")

Section(" Main")
NavButton("Main", ".AutoClicker")
NavButton("Blatant", ".Player Mods")
NavButton("Others", ".Utilities")

Section(" Settings")
NavButton("Settings", ".Settings")

---------------------------------------------------------------------
-- DRAGGING SYSTEM
---------------------------------------------------------------------
local dragging = false
local dragStart
local startPos

root.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos  = root.Position
    end
end)

root.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        root.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

---------------------------------------------------------------------
-- DEFAULT PAGE
---------------------------------------------------------------------
homePage.Visible = true
navButtons["Home"].BackgroundColor3 = Theme.Accent
---------------------------------------------------------------------
-- PART 3 — HOME PAGE (WELCOME + PLAYER CARD + STATUS)
---------------------------------------------------------------------

local function NewText(parent, text, size, color, bold)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, size + 10)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    lbl.TextSize = size
    lbl.TextColor3 = color
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 3
    lbl.Parent = parent
    return lbl
end

---------------------------------------------------------------------
-- HOME TITLE
---------------------------------------------------------------------
local homeTitle = NewText(homePage, "Dashboard", 26, Theme.TextPrimary, true)
homeTitle.Position = UDim2.new(0, 14, 0, 14)

---------------------------------------------------------------------
-- MAIN CARD
---------------------------------------------------------------------
local dashCard = Instance.new("Frame")
dashCard.Size = UDim2.new(1, -28, 0, 320)
dashCard.Position = UDim2.new(0, 14, 0, 60)
dashCard.BackgroundColor3 = Theme.Background2
dashCard.BorderSizePixel = 0
dashCard.ZIndex = 2
dashCard.Parent = homePage

local dashCorner = Instance.new("UICorner")
dashCorner.CornerRadius = UDim.new(0, 16)
dashCorner.Parent = dashCard

local dashStroke = Instance.new("UIStroke")
dashStroke.Thickness = 1
dashStroke.Color = Theme.Stroke
dashStroke.Parent = dashCard

---------------------------------------------------------------------
-- TOP HEADER (gold bar)
---------------------------------------------------------------------
local goldBar = Instance.new("Frame")
goldBar.Size = UDim2.new(1, 0, 0, 40)
goldBar.BackgroundColor3 = Theme.Accent
goldBar.BorderSizePixel = 0
goldBar.ZIndex = 3
goldBar.Parent = dashCard

local goldCorner = Instance.new("UICorner")
goldCorner.CornerRadius = UDim.new(0,16)
goldCorner.Parent = goldBar

local goldText = Instance.new("TextLabel")
goldText.Size = UDim2.new(1, -20, 1, 0)
goldText.Position = UDim2.new(0, 10, 0, 0)
goldText.BackgroundTransparency = 1
goldText.Font = Enum.Font.GothamBold
goldText.TextSize = 18
goldText.TextColor3 = Color3.fromRGB(0,0,0)
goldText.TextXAlignment = Enum.TextXAlignment.Left
goldText.Text = "Welcome to BinHub X v3.6"
goldText.ZIndex = 4
goldText.Parent = goldBar

---------------------------------------------------------------------
-- PLAYER INFO SECTION
---------------------------------------------------------------------
local playerTitle = NewText(dashCard, "Player Information", 18, Theme.TextPrimary, true)
playerTitle.Position = UDim2.new(0, 14, 0, 55)

local playerUser = NewText(dashCard, "Username: " .. LocalPlayer.Name, 15, Theme.TextDim)
playerUser.Position = UDim2.new(0, 14, 0, 88)

local playerDisplay = NewText(dashCard, "Display Name: " .. LocalPlayer.DisplayName, 15, Theme.TextDim)
playerDisplay.Position = UDim2.new(0, 14, 0, 118)

---------------------------------------------------------------------
-- GAME INFO SECTION
---------------------------------------------------------------------
local gameTitle = NewText(dashCard, "Current Game", 18, Theme.TextPrimary, true)
gameTitle.Position = UDim2.new(0, 14, 0, 160)

local gameName = NewText(dashCard, "Name: " .. GetGameName(), 15, Theme.TextDim)
gameName.Position = UDim2.new(0, 14, 0, 190)

local gameId = NewText(dashCard, "PlaceId: " .. game.PlaceId, 15, Theme.TextDim)
gameId.Position = UDim2.new(0, 14, 0, 220)

---------------------------------------------------------------------
-- SYSTEM STATUS SECTION (FPS / Ping)
---------------------------------------------------------------------
local sysTitle = NewText(dashCard, "System Status", 18, Theme.TextPrimary, true)
sysTitle.Position = UDim2.new(0, 14, 0, 260)

local fpsLabel = NewText(dashCard, "FPS: ...", 15, Theme.TextDim)
fpsLabel.Position = UDim2.new(0, 14, 0, 291)

local pingLabel = NewText(dashCard, "Ping: ...", 15, Theme.TextDim)
pingLabel.Position = UDim2.new(0, 180, 0, 291)

---------------------------------------------------------------------
-- LIVE UPDATE THREAD FOR FPS + PING
---------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.2) do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        local ping = StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()

        fpsLabel.Text = "FPS: " .. tostring(fps)
        pingLabel.Text = "Ping: " .. tostring(math.floor(ping)) .. "ms"
    end
end)
---------------------------------------------------------------------
-- PART 4 — MAIN PAGE (AUTO CLICKER / MODES / SPEED / JUMP)
---------------------------------------------------------------------

---------------------------------------------------------------------
-- MAIN TITLE
---------------------------------------------------------------------
local mainTitle = Instance.new("TextLabel")
mainTitle.Size = UDim2.new(1, -20, 0, 32)
mainTitle.Position = UDim2.new(0, 14, 0, 14)
mainTitle.BackgroundTransparency = 1
mainTitle.Font = Enum.Font.GothamBlack
mainTitle.TextSize = 26
mainTitle.TextColor3 = Theme.TextPrimary
mainTitle.TextXAlignment = Enum.TextXAlignment.Left
mainTitle.Text = "Main Controls"
mainTitle.ZIndex = 3
mainTitle.Parent = mainPage

---------------------------------------------------------------------
-- SCROLL FRAME FOR CLEAN LAYOUT
---------------------------------------------------------------------
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -28, 1, -66)
scroll.Position = UDim2.new(0, 14, 0, 56)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0,0,0,800)
scroll.ScrollBarImageColor3 = Theme.Accent
scroll.ZIndex = 2
scroll.Parent = mainPage

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Padding = UDim.new(0, 12)
scrollLayout.Parent = scroll

---------------------------------------------------------------------
-- CARD CREATOR
---------------------------------------------------------------------
local function newCard(height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, height)
    card.BackgroundColor3 = Theme.Background2
    card.BorderSizePixel = 0
    card.ZIndex = 3

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Theme.Stroke
    stroke.Parent = card

    card.Parent = scroll
    return card
end

local function cardLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 24)
    lbl.Position = UDim2.new(0, 10, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.TextColor3 = Theme.TextPrimary
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 4
    lbl.Parent = parent
end

local function makeToggle(parent, default, callback)
    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(0, 70, 0, 26)
    tog.Position = UDim2.new(1, -90, 0, 8)
    tog.BackgroundColor3 = default and Theme.Accent or Theme.Panel
    tog.BorderSizePixel = 0
    tog.Font = Enum.Font.GothamBold
    tog.TextSize = 14
    tog.TextColor3 = Theme.TextPrimary
    tog.Text = default and "ON" or "OFF"
    tog.ZIndex = 4
    tog.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = tog

    local state = default

    tog.MouseButton1Click:Connect(function()
        state = not state
        tog.BackgroundColor3 = state and Theme.Accent or Theme.Panel
        tog.Text = state and "ON" or "OFF"
        callback(state)
    end)

    return tog
end

local function makeSlider(parent, min, max, start, callback)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -20, 0, 40)
    slider.Position = UDim2.new(0, 10, 0, 32)
    slider.BackgroundTransparency = 1
    slider.ZIndex = 4
    slider.Parent = parent

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,0,0,6)
    bar.Position = UDim2.new(0,0,0,18)
    bar.BackgroundColor3 = Theme.Stroke
    bar.BorderSizePixel = 0
    bar.ZIndex = 4
    bar.Parent = slider

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1,0)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((start-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 4
    fill.Parent = bar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1,0)
    fillCorner.Parent = fill

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0,60,0,20)
    val.Position = UDim2.new(1,-70,0,6)
    val.BackgroundTransparency = 1
    val.Font = Enum.Font.GothamBold
    val.TextColor3 = Theme.TextPrimary
    val.TextSize = 14
    val.Text = tostring(start)
    val.ZIndex = 4
    val.Parent = slider

    local dragging = false

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    bar.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(rel,0,1,0)
            local value = math.floor(min + (max-min)*rel)
            val.Text = tostring(value)
            callback(value)
        end
    end)
end

---------------------------------------------------------------------
-- STATE VARIABLES
---------------------------------------------------------------------
local ModeType = "Toggle"
local ActionType = "Click"

local AutoJump = false
local AutoFire = false
local RapidFire = false

local SpeedOn = false
local SpeedValue = 20
local OriginalSpeed = 20

local JumpOn = false
local JumpValue = 50
local OriginalJump = 50

local Humanoid = Character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.4)
    Humanoid = char:WaitForChild("Humanoid")

    if SpeedOn then Humanoid.WalkSpeed = SpeedValue else Humanoid.WalkSpeed = OriginalSpeed end
    if JumpOn then Humanoid.JumpPower = JumpValue else Humanoid.JumpPower = OriginalJump end
end)

---------------------------------------------------------------------
-- MODE TYPE CARD
---------------------------------------------------------------------
local card1 = newCard(70)
cardLabel(card1, "Mode Type (Hold / Toggle)")
makeToggle(card1, false, function(state)
    ModeType = state and "Hold" or "Toggle"
end)

---------------------------------------------------------------------
-- ACTION TYPE CARD
---------------------------------------------------------------------
local card2 = newCard(70)
cardLabel(card2, "Action Type (Click / Parry)")
makeToggle(card2, false, function(state)
    ActionType = state and "Parry" or "Click"
end)

---------------------------------------------------------------------
-- AUTO FIRE CARD
---------------------------------------------------------------------
local card3 = newCard(70)
cardLabel(card3, "Auto Fire")
makeToggle(card3, false, function(state)
    AutoFire = state
end)

---------------------------------------------------------------------
-- AUTO JUMP CARD
---------------------------------------------------------------------
local card4 = newCard(70)
cardLabel(card4, "Auto Jump")
makeToggle(card4, false, function(state)
    AutoJump = state
end)

---------------------------------------------------------------------
-- RAPID FIRE CARD
---------------------------------------------------------------------
local card5 = newCard(70)
cardLabel(card5, "Rapid Fire (Hold Only)")
makeToggle(card5, false, function(state)
    RapidFire = state
end)

---------------------------------------------------------------------
-- SPEED BOOST CARD
---------------------------------------------------------------------
local card6 = newCard(110)
cardLabel(card6, "Speed Boost")

makeToggle(card6, false, function(state)
    SpeedOn = state
    if Humanoid then
        if state then
            OriginalSpeed = Humanoid.WalkSpeed
            Humanoid.WalkSpeed = SpeedValue
        else
            Humanoid.WalkSpeed = OriginalSpeed
        end
    end
end)

makeSlider(card6, 20, 80, 20, function(v)
    SpeedValue = v
    if SpeedOn and Humanoid then
        Humanoid.WalkSpeed = SpeedValue
    end
end)

---------------------------------------------------------------------
-- JUMP BOOST CARD
---------------------------------------------------------------------
local card7 = newCard(110)
cardLabel(card7, "Jump Boost")

makeToggle(card7, false, function(state)
    JumpOn = state
    if Humanoid then
        if state then
            OriginalJump = Humanoid.JumpPower
            Humanoid.JumpPower = JumpValue
        else
            Humanoid.JumpPower = OriginalJump
        end
    end
end)

makeSlider(card7, 50, 120, 50, function(v)
    JumpValue = v
    if JumpOn and Humanoid then
        Humanoid.JumpPower = JumpValue
    end
end)
---------------------------------------------------------------------
-- PART 5 — BLATANT PAGE (FPS / SHADOWS / ANTI-LAG / ULTRA MODE)
---------------------------------------------------------------------

local function NewLabel(parent, text, size, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,size+10)
    lbl.Position = UDim2.new(0,10,0,yPos)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = size
    lbl.TextColor3 = Theme.TextPrimary
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 3
    lbl.Parent = parent
    return lbl
end

---------------------------------------------------------------------
-- BLATANT TITLE
---------------------------------------------------------------------
local blTitle = NewLabel(blatantPage, "Player Modifiers", 26, 14)

---------------------------------------------------------------------
-- SCROLL FRAME FOR CLEAN LAYOUT
---------------------------------------------------------------------
local blScroll = Instance.new("ScrollingFrame")
blScroll.Size = UDim2.new(1, -28, 1, -66)
blScroll.Position = UDim2.new(0, 14, 0, 56)
blScroll.BackgroundTransparency = 1
blScroll.BorderSizePixel = 0
blScroll.ScrollBarThickness = 4
blScroll.CanvasSize = UDim2.new(0,0,0,650)
blScroll.ScrollBarImageColor3 = Theme.Accent
blScroll.ZIndex = 2
blScroll.Parent = blatantPage

local blLayout = Instance.new("UIListLayout")
blLayout.SortOrder = Enum.SortOrder.LayoutOrder
blLayout.Padding = UDim.new(0,12)
blLayout.Parent = blScroll

---------------------------------------------------------------------
-- CARD CREATOR (Same style as Main Page)
---------------------------------------------------------------------
local function blCard(height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,height)
    card.BackgroundColor3 = Theme.Background2
    card.BorderSizePixel = 0
    card.ZIndex = 3
    card.Parent = blScroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,14)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Theme.Stroke
    stroke.Parent = card

    return card
end

local function blLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,24)
    lbl.Position = UDim2.new(0,10,0,6)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.TextColor3 = Theme.TextPrimary
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 4
    lbl.Parent = parent
end

local function blToggle(parent, default, callback)
    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(0,70,0,26)
    tog.Position = UDim2.new(1,-90,0,8)
    tog.BackgroundColor3 = default and Theme.Accent or Theme.Panel
    tog.BorderSizePixel = 0
    tog.Font = Enum.Font.GothamBold
    tog.TextSize = 14
    tog.TextColor3 = Theme.TextPrimary
    tog.Text = default and "ON" or "OFF"
    tog.ZIndex = 4
    tog.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = tog

    local state = default

    tog.MouseButton1Click:Connect(function()
        state = not state
        tog.BackgroundColor3 = state and Theme.Accent or Theme.Panel
        tog.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

---------------------------------------------------------------------
-- STATE VARS
---------------------------------------------------------------------
local FPSBoost = false
local AntiLag = false
local Shadows = false
local Ultra = false

---------------------------------------------------------------------
-- FPS BOOST CARD
---------------------------------------------------------------------
local c1 = blCard(70)
blLabel(c1, "FPS Boost")

blToggle(c1, false, function(state)
    FPSBoost = state

    if state then
        for _,v in pairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then
                v.Enabled = false
            end
        end
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = Shadows
    else
        Lighting.FogEnd = 1000
        Lighting.GlobalShadows = true
        for _,v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") then v.Enabled = true end
        end
    end
end)

---------------------------------------------------------------------
-- ANTI-LAG CARD
---------------------------------------------------------------------
local c2 = blCard(70)
blLabel(c2, "Anti-Lag (Remove Particles/Decals)")

blToggle(c2, false, function(state)
    AntiLag = state
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = not state
        end
        if obj:IsA("Decal") then
            obj.Transparency = state and 1 or 0
        end
    end
end)

---------------------------------------------------------------------
-- SHADOWS CARD
---------------------------------------------------------------------
local c3 = blCard(70)
blLabel(c3, "Shadows")

blToggle(c3, false, function(state)
    Shadows = state
    Lighting.GlobalShadows = state
end)

---------------------------------------------------------------------
-- ULTRA PERFORMANCE MODE CARD
---------------------------------------------------------------------
local c4 = blCard(90)
blLabel(c4, "Ultra Performance Mode")

blToggle(c4, false, function(state)
    Ultra = state

    if state then
        -- Turn off heavy stuff
        for _,v in pairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("SunRaysEffect") or v:IsA("Atmosphere") or v:IsA("DepthOfFieldEffect") then
                v.Enabled = false
            end
        end
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false

        -- Workspace cleanup
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then obj.Enabled = false end
            if obj:IsA("Decal") then obj.Transparency = 1 end
        end

    else
        Lighting.FogEnd = 1000
        Lighting.GlobalShadows = true

        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then obj.Enabled = true end
            if obj:IsA("Decal") then obj.Transparency = 0 end
        end
    end
end)
---------------------------------------------------------------------
-- PART 6 — OTHERS PAGE (Bug Report, Utilities)
---------------------------------------------------------------------

---------------------------------------------------------------------
-- TITLE
---------------------------------------------------------------------
local oTitle = Instance.new("TextLabel")
oTitle.Size = UDim2.new(1, -20, 0, 32)
oTitle.Position = UDim2.new(0, 14, 0, 14)
oTitle.BackgroundTransparency = 1
oTitle.Font = Enum.Font.GothamBlack
oTitle.TextSize = 26
oTitle.TextColor3 = Theme.TextPrimary
oTitle.TextXAlignment = Enum.TextXAlignment.Left
oTitle.Text = "Utilities"
oTitle.ZIndex = 3
oTitle.Parent = othersPage

---------------------------------------------------------------------
-- SCROLL AREA
---------------------------------------------------------------------
local oScroll = Instance.new("ScrollingFrame")
oScroll.Size = UDim2.new(1, -28, 1, -66)
oScroll.Position = UDim2.new(0, 14, 0, 56)
oScroll.BackgroundTransparency = 1
oScroll.BorderSizePixel = 0
oScroll.ScrollBarThickness = 4
oScroll.CanvasSize = UDim2.new(0,0,0,500)
oScroll.ScrollBarImageColor3 = Theme.Accent
oScroll.ZIndex = 2
oScroll.Parent = othersPage

local oLayout = Instance.new("UIListLayout")
oLayout.SortOrder = Enum.SortOrder.LayoutOrder
oLayout.Padding = UDim.new(0,12)
oLayout.Parent = oScroll

---------------------------------------------------------------------
-- SMALL CARD CREATOR
---------------------------------------------------------------------
local function utilCard(height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,height)
    card.BackgroundColor3 = Theme.Background2
    card.BorderSizePixel = 0
    card.ZIndex = 3
    card.Parent = oScroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,14)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Theme.Stroke
    stroke.Parent = card

    return card
end

local function utilLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,24)
    lbl.Position = UDim2.new(0,10,0,6)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.TextColor3 = Theme.TextPrimary
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 4
    lbl.Parent = parent
end

---------------------------------------------------------------------
-- DISCORD JOIN CARD
---------------------------------------------------------------------
local dCard = utilCard(80)
utilLabel(dCard, "Official Discord")

local joinBtn = Instance.new("TextButton")
joinBtn.Size = UDim2.new(0,160,0,30)
joinBtn.Position = UDim2.new(0, 10, 0, 40)
joinBtn.BackgroundColor3 = Theme.Accent
joinBtn.BorderSizePixel = 0
joinBtn.Font = Enum.Font.GothamBold
joinBtn.TextSize = 14
joinBtn.TextColor3 = Color3.new(0,0,0)
joinBtn.Text = "Join Discord"
joinBtn.ZIndex = 4
joinBtn.Parent = dCard

local joinCorner = Instance.new("UICorner")
joinCorner.CornerRadius = UDim.new(0,10)
joinCorner.Parent = joinBtn

joinBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/placeholder") 
end)

---------------------------------------------------------------------
-- BUG REPORT CARD
---------------------------------------------------------------------
local bCard = utilCard(180)
utilLabel(bCard, "Bug Report")

local bugBox = Instance.new("TextBox")
bugBox.Size = UDim2.new(1, -20, 0, 80)
bugBox.Position = UDim2.new(0, 10, 0, 40)
bugBox.BackgroundColor3 = Theme.Panel
bugBox.BorderSizePixel = 0
bugBox.Font = Enum.Font.Gotham
bugBox.TextSize = 14
bugBox.TextColor3 = Theme.TextPrimary
bugBox.PlaceholderText = "Describe the bug..."
bugBox.PlaceholderColor3 = Theme.TextDim
bugBox.TextWrapped = true
bugBox.ClearTextOnFocus = false
bugBox.MultiLine = true
bugBox.ZIndex = 4
bugBox.Parent = bCard

local bCorner = Instance.new("UICorner")
bCorner.CornerRadius = UDim.new(0,10)
bCorner.Parent = bugBox

local sendBtn = Instance.new("TextButton")
sendBtn.Size = UDim2.new(0,150,0,30)
sendBtn.Position = UDim2.new(0,10,0,132)
sendBtn.BackgroundColor3 = Theme.Accent
sendBtn.BorderSizePixel = 0
sendBtn.Font = Enum.Font.GothamBold
sendBtn.TextSize = 14
sendBtn.TextColor3 = Color3.new(0,0,0)
sendBtn.Text = "Submit Bug Report"
sendBtn.ZIndex = 4
sendBtn.Parent = bCard

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0,10)
sbCorner.Parent = sendBtn

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-180,0,30)
status.Position = UDim2.new(0,170,0,132)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextColor3 = Theme.TextDim
status.TextXAlignment = Enum.TextXAlignment.Left
status.Text = ""
status.ZIndex = 4
status.Parent = bCard

sendBtn.MouseButton1Click:Connect(function()
    local txt = bugBox.Text

    if txt:gsub("%s+","") == "" then
        status.TextColor3 = Color3.fromRGB(255,120,120)
        status.Text = "Enter something first!"
        return
    end

    status.TextColor3 = Theme.TextDim
    status.Text = "Sending..."

    task.spawn(function()
        local ok, err = SendBug_Report(txt)
        if ok then
            bugBox.Text = ""
            status.TextColor3 = Color3.fromRGB(120,255,120)
            status.Text = "Sent!"
        else
            status.TextColor3 = Color3.fromRGB(255,120,120)
            status.Text = "Failed (".. tostring(err) ..")"
        end
    end)
end)
---------------------------------------------------------------------
-- PART 7 — INPUT HANDLING + AUTO CLICK ENGINE + BOOST ENGINE
---------------------------------------------------------------------

---------------------------------------------------------------------
-- SAFE INPUT FUNCTIONS
---------------------------------------------------------------------
local function SafeKeyPress(key)
    pcall(function()
        keypress(key)
        task.wait(0.03)
        keyrelease(key)
    end)
end

local function SafeMouseClick()
    pcall(function()
        mouse1click()
    end)
end

---------------------------------------------------------------------
-- INPUT BINDS (LOCKED AS REQUESTED)
---------------------------------------------------------------------
local TOGGLE_KEY = Enum.KeyCode.E       -- Main click/parry key
local MANUAL_KEY = Enum.KeyCode.Q       -- Manual spam key

---------------------------------------------------------------------
-- CLICK/PARRY ACTION FUNCTION
---------------------------------------------------------------------
local function DoAction()
    if ActionType == "Click" then
        SafeMouseClick()
    else
        SafeKeyPress(TOGGLE_KEY)
    end
end

---------------------------------------------------------------------
-- MAIN STATE VARIABLES
---------------------------------------------------------------------
local Clicking     = false
local ManualSpam   = false

---------------------------------------------------------------------
-- INPUT HANDLING
---------------------------------------------------------------------
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == TOGGLE_KEY then
        if ModeType == "Toggle" then
            Clicking = not Clicking
        else
            Clicking = true
        end
    end

    if input.KeyCode == MANUAL_KEY then
        ManualSpam = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == TOGGLE_KEY then
        if ModeType == "Hold" then
            Clicking = false
        end
    end

    if input.KeyCode == MANUAL_KEY then
        ManualSpam = false
    end
end)

---------------------------------------------------------------------
-- AUTO JUMP ENGINE
---------------------------------------------------------------------
task.spawn(function()
    while true do
        if AutoJump and Humanoid then
            Humanoid.Jump = true
        end
        task.wait(0.18)
    end
end)

---------------------------------------------------------------------
-- AUTO FIRE ENGINE
---------------------------------------------------------------------
task.spawn(function()
    while true do
        if AutoFire then
            SafeMouseClick()
        end
        task.wait(0.12)
    end
end)

---------------------------------------------------------------------
-- RAPID FIRE ENGINE (Hold Only)
---------------------------------------------------------------------
task.spawn(function()
    while true do
        if RapidFire and UIS:IsKeyDown(TOGGLE_KEY) then
            SafeMouseClick()
        end
        task.wait(0.05)
    end
end)

---------------------------------------------------------------------
-- MAIN CLICK/PARRY LOOP
---------------------------------------------------------------------
task.spawn(function()
    while task.wait() do
        if Clicking then
            DoAction()
        end

        if ManualSpam then
            SafeKeyPress(MANUAL_KEY)
        end
    end
end)

---------------------------------------------------------------------
-- RIGHT CTRL — GUI TOGGLE
---------------------------------------------------------------------
UIS.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightControl then
        GUI.Enabled = not GUI.Enabled
    end
end)

---------------------------------------------------------------------
-- FINAL LOADED MESSAGE
---------------------------------------------------------------------
print("[BinHub X v3.6] Fully Loaded — Engine Running.")
