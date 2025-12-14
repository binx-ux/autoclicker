-- Bin Hub X - Argon-style Hub v3.4.3
-- RightCtrl = Show/Hide hub

---------------------------------------------------------------------//
-- SERVICES / SETUP
---------------------------------------------------------------------//
local Players            = game:GetService("Players")
local UIS                = game:GetService("UserInputService")
local CoreGui            = game:GetService("CoreGui")
local TweenService       = game:GetService("TweenService")
local RunService         = game:GetService("RunService")
local HttpService        = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalizationService= game:GetService("LocalizationService")
local Lighting           = game:GetService("Lighting")

local LocalPlayer        = Players.LocalPlayer
local displayName        = (LocalPlayer and LocalPlayer.DisplayName) or "Player"
local userName           = (LocalPlayer and LocalPlayer.Name)        or "Unknown"

-- Virtual Input Manager
local VIM
pcall(function()
    VIM = game:GetService("VirtualInputManager")
end)

local TIKTOK_HANDLE      = "@binxix"
local CURRENT_VERSION    = "3.4.3"

---------------------------------------------------------------------//
-- GLOBAL VARIABLES + STATES
---------------------------------------------------------------------//
getgenv().BinHub_RunCount = (getgenv().BinHub_RunCount or 0) + 1

local clicking = false
local mode = "Toggle"       -- Toggle / Hold
local actionMode = "Click"   -- Click / Parry
local cps = 10

-- Toggles
local fpsBoostOn = false
local playerEffectsOn = false
local speedEnabled = false
local jumpEnabled = false
local semiImmortalOn = false
local triggerbotOn = false

-- Player values
local speedValue = 20
local jumpValue = 50
local originalWalkSpeed = nil
local originalJumpPower = nil

-- Keybinds
local toggleKey = Enum.KeyCode.E -- locked
local parryKey = Enum.KeyCode.E  -- locked
local manualKey = Enum.KeyCode.R
local manualSpamActive = false

-- GUI visibility
local guiVisible = true

---------------------------------------------------------------------//
-- SAFE GUI PARENT
---------------------------------------------------------------------//
local function safeParent()
    -- UI protection for different executors
    local ok, res = pcall(function()
        if gethui then
            local g = Instance.new("ScreenGui")
            g.Name = "BinHubX"
            g.ResetOnSpawn = false
            g.Parent = gethui()
            return g
        end
    end)
    if ok and res then return res end

    ok, res = pcall(function()
        if syn and syn.protect_gui then
            local g = Instance.new("ScreenGui")
            g.Name = "BinHubX"
            g.ResetOnSpawn = false
            syn.protect_gui(g)
            g.Parent = CoreGui
            return g
        end
    end)
    if ok and res then return res end

    -- fallback
    local g = Instance.new("ScreenGui")
    g.Name = "BinHubX"
    g.ResetOnSpawn = false
    g.Parent = CoreGui
    return g
end

---------------------------------------------------------------------//
-- GUI ROOT
---------------------------------------------------------------------//
local gui = safeParent()
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main window
local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.new(0, 720, 0, 380)
root.Position = UDim2.new(0.5, -360, 0.5, -190)
root.BackgroundColor3 = Color3.fromRGB(10,10,10)
root.BorderSizePixel = 0
root.Parent = gui

local rootCorner = Instance.new("UICorner")
rootCorner.CornerRadius = UDim.new(0,18)
rootCorner.Parent = root

local rootStroke = Instance.new("UIStroke")
rootStroke.Thickness = 1
rootStroke.Color = Color3.fromRGB(60,60,60)
rootStroke.Parent = root

local rootGrad = Instance.new("UIGradient")
rootGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,26)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5,5,10))
}
rootGrad.Rotation = 45
rootGrad.Parent = root

---------------------------------------------------------------------//
-- BACKGROUND PARTICLES
---------------------------------------------------------------------//
local function createDot()
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,4,0,4)
    dot.BackgroundColor3 = Color3.fromRGB(
        math.random(140,255),
        math.random(80,255),
        math.random(80,255)
    )
    dot.BorderSizePixel = 0
    dot.ZIndex = 0
    dot.Parent = root

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1,0)
    c.Parent = dot

    local function tweenDot()
        dot.Position = UDim2.new(math.random(),0,math.random(),0)
        local goal = {Position = UDim2.new(math.random(),0,math.random(),0)}
        local ti = TweenInfo.new(math.random(10,20), Enum.EasingStyle.Linear)
        TweenService:Create(dot,ti,goal):Play()
    end

    tweenDot()
end

for i=1,40 do
    createDot()
end
---------------------------------------------------------------------//
-- SIDEBAR
---------------------------------------------------------------------//
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0,230,1,0)
sidebar.BackgroundColor3 = Color3.fromRGB(10,10,12)
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 2
sidebar.Parent = root

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0,18)
sidebarCorner.Parent = sidebar

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Thickness = 1
sidebarStroke.Color = Color3.fromRGB(40,40,45)
sidebarStroke.Parent = sidebar

-- Title
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1,-80,0,30)
titleBar.Position = UDim2.new(0,18,0,14)
titleBar.BackgroundTransparency = 1
titleBar.Font = Enum.Font.GothamBlack
titleBar.TextSize = 20
titleBar.TextColor3 = Color3.fromRGB(255,255,255)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Text = "Argon-Bin Hub"
titleBar.ZIndex = 3
titleBar.Parent = sidebar

-- Version pill
local versionPill = Instance.new("TextLabel")
versionPill.Size = UDim2.new(0,60,0,22)
versionPill.Position = UDim2.new(1,-72,0,14)
versionPill.BackgroundColor3 = Color3.fromRGB(220,60,60)
versionPill.BorderSizePixel = 0
versionPill.Font = Enum.Font.GothamBold
versionPill.TextSize = 14
versionPill.TextColor3 = Color3.fromRGB(255,255,255)
versionPill.Text = CURRENT_VERSION
versionPill.ZIndex = 3
versionPill.Parent = sidebar

local vCorner = Instance.new("UICorner")
vCorner.CornerRadius = UDim.new(1,0)
vCorner.Parent = versionPill

-- Search
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1,-36,0,32)
searchBox.Position = UDim2.new(0,18,0,54)
searchBox.BackgroundColor3 = Color3.fromRGB(25,25,30)
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "Search"
searchBox.Text = ""
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.TextColor3 = Color3.fromRGB(255,255,255)
searchBox.PlaceholderColor3 = Color3.fromRGB(140,140,150)
searchBox.ZIndex = 3
searchBox.Parent = sidebar

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0,10)
searchCorner.Parent = searchBox

-- Nav holder
local navHolder = Instance.new("Frame")
navHolder.Size = UDim2.new(1,-36,1,-150)
navHolder.Position = UDim2.new(0,18,0,96)
navHolder.BackgroundTransparency = 1
navHolder.ZIndex = 3
navHolder.Parent = sidebar

local navLayout = Instance.new("UIListLayout")
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Padding = UDim.new(0,4)
navLayout.Parent = navHolder

-- Profile
local profileFrame = Instance.new("Frame")
profileFrame.Size = UDim2.new(1,-36,0,76)
profileFrame.Position = UDim2.new(0,18,1,-86)
profileFrame.BackgroundColor3 = Color3.fromRGB(20,20,26)
profileFrame.BorderSizePixel = 0
profileFrame.ZIndex = 3
profileFrame.Parent = sidebar

local pfCorner = Instance.new("UICorner")
pfCorner.CornerRadius = UDim.new(0,14)
pfCorner.Parent = profileFrame

local pfName = Instance.new("TextLabel")
pfName.Size = UDim2.new(1,-10,0,22)
pfName.Position = UDim2.new(0,10,0,6)
pfName.BackgroundTransparency = 1
pfName.Font = Enum.Font.GothamBold
pfName.TextSize = 14
pfName.TextColor3 = Color3.fromRGB(255,255,255)
pfName.TextXAlignment = Enum.TextXAlignment.Left
pfName.Text = displayName
pfName.ZIndex = 4
pfName.Parent = profileFrame

local pfTag = Instance.new("TextLabel")
pfTag.Size = UDim2.new(1,-10,0,18)
pfTag.Position = UDim2.new(0,10,0,26)
pfTag.BackgroundTransparency = 1
pfTag.Font = Enum.Font.Gotham
pfTag.TextSize = 12
pfTag.TextColor3 = Color3.fromRGB(170,170,185)
pfTag.TextXAlignment = Enum.TextXAlignment.Left
pfTag.Text = "@"..userName
pfTag.ZIndex = 4
pfTag.Parent = profileFrame

local pfTikTok = Instance.new("TextLabel")
pfTikTok.Size = UDim2.new(1,-10,0,18)
pfTikTok.Position = UDim2.new(0,10,0,46)
pfTikTok.BackgroundTransparency = 1
pfTikTok.Font = Enum.Font.Gotham
pfTikTok.TextSize = 12
pfTikTok.TextColor3 = Color3.fromRGB(200,120,220)
pfTikTok.TextXAlignment = Enum.TextXAlignment.Left
pfTikTok.Text = "TikTok: "..TIKTOK_HANDLE
pfTikTok.ZIndex = 4
pfTikTok.Parent = profileFrame

---------------------------------------------------------------------//
-- TOP BAR (DRAG + CLOSE)
---------------------------------------------------------------------//
local contentTop = Instance.new("Frame")
contentTop.Size = UDim2.new(1,-230,0,36)
contentTop.Position = UDim2.new(0,230,0,0)
contentTop.BackgroundTransparency = 1
contentTop.ZIndex = 2
contentTop.Parent = root

local topTitle = Instance.new("TextLabel")
topTitle.Size = UDim2.new(1,-80,1,0)
topTitle.Position = UDim2.new(0,10,0,0)
topTitle.BackgroundTransparency = 1
topTitle.Font = Enum.Font.GothamBold
topTitle.TextSize = 18
topTitle.TextXAlignment = Enum.TextXAlignment.Left
topTitle.TextColor3 = Color3.fromRGB(235,235,240)
topTitle.Text = "AutoClicker + Parry Hub"
topTitle.ZIndex = 2
topTitle.Parent = contentTop

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,28,0,28)
closeBtn.Position = UDim2.new(1,-32,0.5,-14)
closeBtn.BackgroundColor3 = Color3.fromRGB(70,30,30)
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Text = "X"
closeBtn.ZIndex = 2
closeBtn.Parent = contentTop

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1,0)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    guiVisible = false
    gui.Enabled = false
end)

-- Dragging
local dragging, dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    root.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

contentTop.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = root.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

contentTop.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

---------------------------------------------------------------------//
-- THEMES
---------------------------------------------------------------------//
local ThemeConfig = {
    Default = {
        Accent     = Color3.fromRGB(220,60,60),
        AccentOn   = Color3.fromRGB(80,200,120),
        AccentText = Color3.fromRGB(200,120,220),
        RootTop    = Color3.fromRGB(20,20,26),
        RootBottom = Color3.fromRGB(5,5,10),
        Sidebar    = Color3.fromRGB(10,10,12),
        TopTitle   = Color3.fromRGB(235,235,240),
    },
    Purple = {
        Accent     = Color3.fromRGB(180,80,255),
        AccentOn   = Color3.fromRGB(160,120,255),
        AccentText = Color3.fromRGB(210,170,255),
        RootTop    = Color3.fromRGB(30,10,40),
        RootBottom = Color3.fromRGB(8,0,18),
        Sidebar    = Color3.fromRGB(12,8,24),
        TopTitle   = Color3.fromRGB(235,220,255),
    },
    Aqua = {
        Accent     = Color3.fromRGB(40,180,220),
        AccentOn   = Color3.fromRGB(80,210,230),
        AccentText = Color3.fromRGB(140,220,255),
        RootTop    = Color3.fromRGB(10,25,30),
        RootBottom = Color3.fromRGB(2,8,12),
        Sidebar    = Color3.fromRGB(8,16,20),
        TopTitle   = Color3.fromRGB(220,240,245),
    },
}

local currentTheme = "Default"
local ThemeAccentOn = ThemeConfig[currentTheme].AccentOn

local function applyTheme(name)
    local th = ThemeConfig[name] or ThemeConfig["Default"]
    currentTheme = name
    ThemeAccentOn = th.AccentOn

    rootGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, th.RootTop),
        ColorSequenceKeypoint.new(1, th.RootBottom)
    }

    sidebar.BackgroundColor3 = th.Sidebar
    versionPill.BackgroundColor3 = th.Accent
    pfTikTok.TextColor3 = th.AccentText
    topTitle.TextColor3 = th.TopTitle
end

applyTheme("Default")

---------------------------------------------------------------------//
-- PAGES CONTAINER + NAV HELPERS
---------------------------------------------------------------------//
local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1,-230,1,-40)
contentHolder.Position = UDim2.new(0,230,0,40)
contentHolder.BackgroundTransparency = 1
contentHolder.ZIndex = 1
contentHolder.Parent = root

local pages = {}
local navButtons = {}
local currentPage

local function createPage(name)
    local page = Instance.new("Frame")
    page.Name = name.."Page"
    page.Size = UDim2.new(1,-20,1,-20)
    page.Position = UDim2.new(0,10,0,10)
    page.BackgroundColor3 = Color3.fromRGB(15,15,18)
    page.BorderSizePixel = 0
    page.Visible = false
    page.ZIndex = 2
    page.Parent = contentHolder

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,16)
    c.Parent = page

    local s = Instance.new("UIStroke")
    s.Thickness = 1
    s.Color = Color3.fromRGB(40,40,45)
    s.Parent = page

    pages[name] = page
    return page
end

local homePage    = createPage("Home")
local mainPage    = createPage("Main")
local blatantPage = createPage("Blatant")
local othersPage  = createPage("Others")
local settingsPage= createPage("Settings")

local function setActivePage(name)
    for n,frame in pairs(pages) do
        frame.Visible = (n == name)
    end
    for n,btn in pairs(navButtons) do
        btn.BackgroundColor3 = (n == name)
            and Color3.fromRGB(55,55,65)
            or  Color3.fromRGB(25,25,32)
    end
    currentPage = name
end

local function sectionLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,18)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(150,150,165)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 3
    lbl.Parent = navHolder
end

local function navButton(name,text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,30)
    btn.BackgroundColor3 = Color3.fromRGB(25,25,32)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(235,235,240)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = text
    btn.ZIndex = 3
    btn.Parent = navHolder

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,10)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        setActivePage(name)
    end)

    navButtons[name] = btn
end

sectionLabel("Home")
navButton("Home",".Home")

sectionLabel("Main")
navButton("Main","Main")
navButton("Blatant","Blatant")
navButton("Others","Others")

sectionLabel("Settings")
navButton("Settings","Settings")
---------------------------------------------------------------------//
-- HOME PAGE
---------------------------------------------------------------------//
do
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,-40,0,40)
    t.Position = UDim2.new(0,20,0,20)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBlack
    t.TextSize = 26
    t.TextColor3 = Color3.fromRGB(255,255,255)
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Top
    t.Text = "Hello, "..displayName
    t.ZIndex = 3
    t.Parent = homePage

    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1,-40,0,70)
    d.Position = UDim2.new(0,20,0,60)
    d.BackgroundTransparency = 1
    d.Font = Enum.Font.Gotham
    d.TextSize = 14
    d.TextColor3 = Color3.fromRGB(210,210,220)
    d.TextWrapped = true
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextYAlignment = Enum.TextYAlignment.Top
    d.Text = "Account: @"..userName..
        "\nUse the tabs on the left to control your auto clicker, parry, blatant and other settings."
    d.ZIndex = 3
    d.Parent = homePage

    local tk = Instance.new("TextLabel")
    tk.Size = UDim2.new(1,-40,0,24)
    tk.Position = UDim2.new(0,20,0,140)
    tk.BackgroundTransparency = 1
    tk.Font = Enum.Font.GothamSemibold
    tk.TextSize = 14
    tk.TextColor3 = ThemeConfig[currentTheme].AccentText
    tk.TextXAlignment = Enum.TextXAlignment.Left
    tk.Text = "TikTok: "..TIKTOK_HANDLE
    tk.ZIndex = 3
    tk.Parent = homePage
end

---------------------------------------------------------------------//
-- WEBHOOK HELPERS
---------------------------------------------------------------------//
local WEBHOOK_URL = "https://discord.com/api/webhooks/1446656470287651050/ayflCl7nEQ3388YhXAZT7r3j5kTC40EP3WV9yO1BehR2vzHbtoDArV-YejWn_E_F6eUk"

local function getRequestFunction()
    return (syn and syn.request)
        or (http and http.request)
        or http_request
        or request
        or nil
end

local function getGameName()
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if ok and info and info.Name then
        return info.Name
    end
    return "Unknown Game"
end

-- executor info
local function getExecutorInfo()
    local execName = "Unknown"
    local exploitType = "Unknown"

    local function tryCall(fn)
        local ok, res = pcall(fn)
        if ok and res ~= nil then
            return tostring(res)
        end
    end

    if typeof(getexecutorname) == "function" then
        execName = tryCall(getexecutorname) or execName
    elseif typeof(identifyexecutor) == "function" then
        local ok, n1, n2 = pcall(identifyexecutor)
        if ok then
            if n2 ~= nil then
                execName = tostring(n1) .. " " .. tostring(n2)
            elseif n1 ~= nil then
                execName = tostring(n1)
            end
        end
    end

    if syn ~= nil then
        exploitType = "Synapse Environment"
    elseif KRNL_LOADED or iskrnlclosure then
        exploitType = "KRNL Environment"
    elseif fluxus or isfluxusclosure then
        exploitType = "Fluxus Environment"
    elseif sentinel then
        exploitType = "Sentinel Environment"
    else
        if execName ~= "Unknown" then
            exploitType = execName .. " Environment"
        end
    end

    return execName, exploitType
end

local function getBasicEmbedFields()
    local gameName = getGameName()
    local placeId  = tostring(game.PlaceId)
    local jobId    = tostring(game.JobId)
    local username = userName
    local dName    = displayName
    local timestamp= os.date("%Y-%m-%d %H:%M:%S")
    local execName, exploitType = getExecutorInfo()

    return {
        username   = username,
        displayName= dName,
        gameName   = gameName,
        placeId    = placeId,
        jobId      = jobId,
        timestamp  = timestamp,
        executor   = execName,
        exploitType= exploitType,
    }
end

local function getScriptInfoBlock()
    local lines = {
        "Hub: Bin Hub X - Argon-style Hub v"..CURRENT_VERSION,
        "",
        "Main Hub:",
        " • Main Toggle Key: E (LOCKED)",
        " • Mode: Toggle / Hold (UI controlled)",
        " • Action: Click / Parry (UI controlled)",
        "",
        "Keybinds:",
        " • Parry Key: E (locked)",
        " • Manual Spam Key: R (rebindable in UI)",
        "",
        "Visuals / Extras:",
        " • FPS Booster toggle (Others tab)",
        " • Player Effects (Korblox + Headless) (Others tab)",
        " • Semi Immortal: full body desync stutter (Blatant tab)",
        "",
        "Player Options:",
        " • Speed: slider 10–100 (toggle required to apply, restores original on off)",
        " • Jump Power: slider 25–150 (toggle required to apply, restores original on off)",
        "",
        "Notes:",
        " • RightCtrl = Show/Hide hub",
        " • Bug reports from Settings tab go to this same webhook.",
    }
    return table.concat(lines, "\n")
end

local function sendWebhookLog()
    if not WEBHOOK_URL or WEBHOOK_URL == "" then return end
    local req = getRequestFunction()
    if not req then return end

    local meta = getBasicEmbedFields()
    local scriptInfo = getScriptInfoBlock()

    local payload = {
        embeds = {{
            title = "Bin Hub X - Script Executed (Full Log)",
            color = 0x5865F2,
            fields = {
                {
                    name = "Player",
                    value = string.format("Display: **%s**\nUsername: %s", meta.displayName, meta.username),
                    inline = false
                },
                {
                    name = "Game",
                    value = string.format("**%s**\nPlaceId: %s\nJobId: %s", meta.gameName, meta.placeId, meta.jobId),
                    inline = false
                },
                {
                    name = "Executor / Exploit",
                    value = string.format("Executor: %s\nType: %s", meta.executor, meta.exploitType),
                    inline = false
                },
                {
                    name = "Script / Hub Info",
                    value = "```"..scriptInfo.."```",
                    inline = false
                },
                {
                    name = "Time",
                    value = "```"..meta.timestamp.."```",
                    inline = false
                },
            }
        }}
    }

    local json = HttpService:JSONEncode(payload)
    pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    end)
end

local function sendBugReport(messageText)
    if not WEBHOOK_URL or WEBHOOK_URL == "" then
        return false, "No webhook"
    end

    local req = getRequestFunction()
    if not req then
        return false, "No request func"
    end

    if not messageText or messageText:gsub("%s+","") == "" then
        return false, "Empty"
    end

    local meta = getBasicEmbedFields()
    local trimmed = messageText
    if #trimmed > 1000 then
        trimmed = trimmed:sub(1,1000).."..."
    end

    local payload = {
        embeds = {{
            title = "Bin Hub X - Bug Report",
            color = 0xFF0000,
            fields = {
                {
                    name = "Player",
                    value = string.format("Display: **%s**\nUsername: %s", meta.displayName, meta.username),
                    inline = false
                },
                {
                    name = "Game",
                    value = string.format("**%s**\nPlaceId: %s\nJobId: %s", meta.gameName, meta.placeId, meta.jobId),
                    inline = false
                },
                {
                    name = "Executor / Exploit",
                    value = string.format("Executor: %s\nType: %s", meta.executor, meta.exploitType),
                    inline = false
                },
                {
                    name = "Time",
                    value = "```"..meta.timestamp.."```",
                    inline = false
                },
                {
                    name = "Bug Report",
                    value = "```"..trimmed.."```",
                    inline = false
                },
            }
        }}
    }

    local json = HttpService:JSONEncode(payload)
    local ok, err = pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    end)

    if not ok then
        return false, tostring(err)
    end
    return true
end

---------------------------------------------------------------------//
-- SETTINGS PAGE (BUG REPORT + THEMES)
---------------------------------------------------------------------//
local bugStatusLabel

do
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-40,0,28)
    title.Position = UDim2.new(0,20,0,20)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "Settings & Bug Reports"
    title.ZIndex = 3
    title.Parent = settingsPage

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1,-40,0,50)
    info.Position = UDim2.new(0,20,0,52)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 13
    info.TextColor3 = Color3.fromRGB(200,200,210)
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.Text = "• RightCtrl = Show/Hide hub\n• Main click key is locked to E\n• Use the box below to send bug reports straight to the dev webhook."
    info.ZIndex = 3
    info.Parent = settingsPage

    local bugLabel = Instance.new("TextLabel")
    bugLabel.Size = UDim2.new(1,-40,0,20)
    bugLabel.Position = UDim2.new(0,20,0,110)
    bugLabel.BackgroundTransparency = 1
    bugLabel.Font = Enum.Font.GothamSemibold
    bugLabel.TextSize = 14
    bugLabel.TextColor3 = Color3.fromRGB(230,230,235)
    bugLabel.TextXAlignment = Enum.TextXAlignment.Left
    bugLabel.Text = "Bug Report:"
    bugLabel.ZIndex = 3
    bugLabel.Parent = settingsPage

    local bugBox = Instance.new("TextBox")
    bugBox.Size = UDim2.new(1,-40,0,130)
    bugBox.Position = UDim2.new(0,20,0,134)
    bugBox.BackgroundColor3 = Color3.fromRGB(25,25,32)
    bugBox.BorderSizePixel = 0
    bugBox.Font = Enum.Font.Gotham
    bugBox.TextSize = 14
    bugBox.TextColor3 = Color3.fromRGB(255,255,255)
    bugBox.PlaceholderText = "Describe the bug, what happened, and what you were doing..."
    bugBox.TextWrapped = true
    bugBox.MultiLine = true
    bugBox.ClearTextOnFocus = false
    bugBox.ZIndex = 3
    bugBox.Parent = settingsPage

    local bugCorner = Instance.new("UICorner")
    bugCorner.CornerRadius = UDim.new(0,10)
    bugCorner.Parent = bugBox

    local bugButton = Instance.new("TextButton")
    bugButton.Size = UDim2.new(0,160,0,30)
    bugButton.Position = UDim2.new(0,20,0,274)
    bugButton.BackgroundColor3 = ThemeAccentOn
    bugButton.BorderSizePixel = 0
    bugButton.Font = Enum.Font.GothamBold
    bugButton.TextSize = 14
    bugButton.TextColor3 = Color3.fromRGB(255,255,255)
    bugButton.Text = "Send Bug Report"
    bugButton.ZIndex = 3
    bugButton.Parent = settingsPage

    local bugBtnCorner = Instance.new("UICorner")
    bugBtnCorner.CornerRadius = UDim.new(0,10)
    bugBtnCorner.Parent = bugButton

    bugStatusLabel = Instance.new("TextLabel")
    bugStatusLabel.Size = UDim2.new(1,-200,0,20)
    bugStatusLabel.Position = UDim2.new(0,190,0,278)
    bugStatusLabel.BackgroundTransparency = 1
    bugStatusLabel.Font = Enum.Font.Gotham
    bugStatusLabel.TextSize = 12
    bugStatusLabel.TextColor3 = Color3.fromRGB(180,180,190)
    bugStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    bugStatusLabel.Text = ""
    bugStatusLabel.ZIndex = 3
    bugStatusLabel.Parent = settingsPage

    bugButton.MouseButton1Click:Connect(function()
        local text = bugBox.Text or ""
        if text:gsub("%s+","") == "" then
            bugStatusLabel.TextColor3 = Color3.fromRGB(255,120,120)
            bugStatusLabel.Text = "Type something first."
            return
        end

        bugStatusLabel.TextColor3 = Color3.fromRGB(200,200,210)
        bugStatusLabel.Text = "Sending..."

        task.spawn(function()
            local ok, err = sendBugReport(text)
            if ok then
                bugBox.Text = ""
                bugStatusLabel.TextColor3 = Color3.fromRGB(120,220,120)
                bugStatusLabel.Text = "Bug sent!"
            else
                bugStatusLabel.TextColor3 = Color3.fromRGB(255,120,120)
                bugStatusLabel.Text = "Failed to send ("..tostring(err or "unknown")..")"
            end
        end)
    end)

    -- Theme selector
    local themeLabel = Instance.new("TextLabel")
    themeLabel.Size = UDim2.new(1,-40,0,20)
    themeLabel.Position = UDim2.new(0,20,0,310)
    themeLabel.BackgroundTransparency = 1
    themeLabel.Font = Enum.Font.GothamSemibold
    themeLabel.TextSize = 14
    themeLabel.TextColor3 = Color3.fromRGB(230,230,235)
    themeLabel.TextXAlignment = Enum.TextXAlignment.Left
    themeLabel.Text = "Theme:"
    themeLabel.ZIndex = 3
    themeLabel.Parent = settingsPage

    local function makeThemeButton(txt, xOffset, themeName)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,80,0,24)
        btn.Position = UDim2.new(0,xOffset,0,336)
        btn.BackgroundColor3 = Color3.fromRGB(30,30,40)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.TextColor3 = Color3.fromRGB(220,220,230)
        btn.Text = txt
        btn.ZIndex = 3
        btn.Parent = settingsPage

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0,10)
        c.Parent = btn

        btn.MouseButton1Click:Connect(function()
            applyTheme(themeName)
            bugButton.BackgroundColor3 = ThemeAccentOn
        end)
    end

    makeThemeButton("Default", 20, "Default")
    makeThemeButton("Purple", 110, "Purple")
    makeThemeButton("Aqua",   200, "Aqua")
end
---------------------------------------------------------------------//
-- OTHERS PAGE (Discord + FPS + Player FX + ESP placeholder)
---------------------------------------------------------------------//
-- Scroll container so nothing leaks out
local othersScroll = Instance.new("ScrollingFrame")
othersScroll.Size = UDim2.new(1,-20,1,-20)
othersScroll.Position = UDim2.new(0,10,0,10)
othersScroll.BackgroundTransparency = 1
othersScroll.BorderSizePixel = 0
othersScroll.ScrollBarThickness = 4
othersScroll.CanvasSize = UDim2.new(0,0,0,0)
othersScroll.ZIndex = 3
othersScroll.Parent = othersPage

local othersLayout = Instance.new("UIListLayout")
othersLayout.SortOrder = Enum.SortOrder.LayoutOrder
othersLayout.Padding = UDim.new(0,10)
othersLayout.Parent = othersScroll

othersLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    othersScroll.CanvasSize = UDim2.new(0,0,0, othersLayout.AbsoluteContentSize.Y + 10)
end)

local function makeOthersCard(height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,height)
    card.BackgroundColor3 = Color3.fromRGB(20,20,26)
    card.BorderSizePixel = 0
    card.ZIndex = 3
    card.Parent = othersScroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,12)
    c.Parent = card

    return card
end

local function makeCardTitle(parent, txt)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,-60,0,20)
    t.Position = UDim2.new(0,10,0,6)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamSemibold
    t.TextSize = 14
    t.TextColor3 = Color3.fromRGB(255,255,255)
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Text = txt
    t.ZIndex = 4
    t.Parent = parent
    return t
end

local function makeCardDesc(parent, txt)
    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1,-20,0,24)
    d.Position = UDim2.new(0,10,0,26)
    d.BackgroundTransparency = 1
    d.Font = Enum.Font.Gotham
    d.TextSize = 12
    d.TextColor3 = Color3.fromRGB(200,200,210)
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextYAlignment = Enum.TextYAlignment.Top
    d.TextWrapped = true
    d.Text = txt
    d.ZIndex = 4
    d.Parent = parent
    return d
end

do
    -- Header
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-40,0,28)
    title.Position = UDim2.new(0,20,0,0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "Others"
    title.ZIndex = 3
    title.Parent = othersScroll

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1,-40,0,40)
    info.Position = UDim2.new(0,20,0,30)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 13
    info.TextColor3 = Color3.fromRGB(200,200,210)
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.Text = "Extra stuff: Discord invite, FPS booster, player effects. Ability ESP is temporarily unavailable."
    info.ZIndex = 3
    info.Parent = othersScroll

    -- Spacer
    local spacer = Instance.new("Frame")
    spacer.Size = UDim2.new(1,0,0,10)
    spacer.BackgroundTransparency = 1
    spacer.BorderSizePixel = 0
    spacer.ZIndex = 3
    spacer.Parent = othersScroll

    -----------------------------------------------------------------//
    -- Discord Card
    -----------------------------------------------------------------//
    local discordCard = makeOthersCard(70)
    makeCardTitle(discordCard, "Discord")
    local dDesc = makeCardDesc(discordCard, "Join: discord.gg/S4nPV2Rx7F")

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0,120,0,24)
    copyBtn.Position = UDim2.new(1,-130,0,32)
    copyBtn.BackgroundColor3 = Color3.fromRGB(60,70,140)
    copyBtn.BorderSizePixel = 0
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 13
    copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
    copyBtn.Text = "Copy Invite"
    copyBtn.ZIndex = 4
    copyBtn.Parent = discordCard

    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0,10)
    copyCorner.Parent = copyBtn

    copyBtn.MouseButton1Click:Connect(function()
        local invite = "https://discord.gg/S4nPV2Rx7F"
        if setclipboard then
            setclipboard(invite)
            dDesc.Text = "Join: discord.gg/S4nPV2Rx7F (Copied!)"
        else
            dDesc.Text = "Join: discord.gg/S4nPV2Rx7F (Clipboard not supported.)"
        end
    end)

    -----------------------------------------------------------------//
    -- FPS BOOSTER Card (WORKING TOGGLE)
    -----------------------------------------------------------------//
    local fpsCard = makeOthersCard(70)
    makeCardTitle(fpsCard, "FPS Booster")
    local fDesc = makeCardDesc(fpsCard, "Turn graphics low + remove some effects to help FPS (client-side).")

    local fpsToggle = Instance.new("TextButton")
    fpsToggle.Size = UDim2.new(0,50,0,22)
    fpsToggle.Position = UDim2.new(1,-60,0,24)
    fpsToggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
    fpsToggle.BorderSizePixel = 0
    fpsToggle.Font = Enum.Font.GothamBold
    fpsToggle.TextSize = 12
    fpsToggle.TextColor3 = Color3.fromRGB(230,230,235)
    fpsToggle.Text = "OFF"
    fpsToggle.ZIndex = 4
    fpsToggle.Parent = fpsCard

    local fpsToggleCorner = Instance.new("UICorner")
    fpsToggleCorner.CornerRadius = UDim.new(1,0)
    fpsToggleCorner.Parent = fpsToggle

    local fpsThumb = Instance.new("Frame")
    fpsThumb.Size = UDim2.new(0,16,0,16)
    fpsThumb.Position = UDim2.new(0,3,0.5,-8)
    fpsThumb.BackgroundColor3 = Color3.fromRGB(80,80,80)
    fpsThumb.BorderSizePixel = 0
    fpsThumb.ZIndex = 5
    fpsThumb.Parent = fpsToggle

    local fpsThumbCorner = Instance.new("UICorner")
    fpsThumbCorner.CornerRadius = UDim.new(1,0)
    fpsThumbCorner.Parent = fpsThumb

    local function updateFpsToggleVisual()
        if fpsBoostOn then
            fpsToggle.BackgroundColor3 = ThemeAccentOn
            fpsToggle.Text = "ON"
            fpsThumb.Position = UDim2.new(1,-19,0.5,-8)
        else
            fpsToggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
            fpsToggle.Text = "OFF"
            fpsThumb.Position = UDim2.new(0,3,0.5,-8)
        end
    end

    updateFpsToggleVisual()

    fpsToggle.MouseButton1Click:Connect(function()
        fpsBoostOn = not fpsBoostOn
        updateFpsToggleVisual()
        if typeof(applyFpsBoost) == "function" then
            applyFpsBoost(fpsBoostOn)
        end
    end)

    -----------------------------------------------------------------//
    -- PLAYER EFFECTS Card (Korblox + Headless local FX)
    -----------------------------------------------------------------//
    local peCard = makeOthersCard(70)
    makeCardTitle(peCard, "Player Effects")
    local peDesc = makeCardDesc(peCard, "Activates korblox/headless-style local visuals (client-side only).")

    local peToggle = Instance.new("TextButton")
    peToggle.Size = UDim2.new(0,50,0,22)
    peToggle.Position = UDim2.new(1,-60,0,24)
    peToggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
    peToggle.BorderSizePixel = 0
    peToggle.Font = Enum.Font.GothamBold
    peToggle.TextSize = 12
    peToggle.TextColor3 = Color3.fromRGB(230,230,235)
    peToggle.Text = "OFF"
    peToggle.ZIndex = 4
    peToggle.Parent = peCard

    local peToggleCorner = Instance.new("UICorner")
    peToggleCorner.CornerRadius = UDim.new(1,0)
    peToggleCorner.Parent = peToggle

    local peThumb = Instance.new("Frame")
    peThumb.Size = UDim2.new(0,16,0,16)
    peThumb.Position = UDim2.new(0,3,0.5,-8)
    peThumb.BackgroundColor3 = Color3.fromRGB(80,80,80)
    peThumb.BorderSizePixel = 0
    peThumb.ZIndex = 5
    peThumb.Parent = peToggle

    local peThumbCorner = Instance.new("UICorner")
    peThumbCorner.CornerRadius = UDim.new(1,0)
    peThumbCorner.Parent = peThumb

    local function updatePeToggleVisual()
        if playerEffectsOn then
            peToggle.BackgroundColor3 = ThemeAccentOn
            peToggle.Text = "ON"
            peThumb.Position = UDim2.new(1,-19,0.5,-8)
        else
            peToggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
            peToggle.Text = "OFF"
            peThumb.Position = UDim2.new(0,3,0.5,-8)
        end
    end

    updatePeToggleVisual()

    peToggle.MouseButton1Click:Connect(function()
        playerEffectsOn = not playerEffectsOn
        updatePeToggleVisual()
        if typeof(applyPlayerEffects) == "function" then
            applyPlayerEffects(playerEffectsOn)
        end
    end)

    -----------------------------------------------------------------//
    -- Ability ESP Card (UNAVAILABLE)
    -----------------------------------------------------------------//
    local espCard = makeOthersCard(70)
    makeCardTitle(espCard, "Ability ESP (Unavailable)")
    makeCardDesc(espCard, "Temporarily unavailable in this build.")

    local espToggle = Instance.new("TextButton")
    espToggle.Size = UDim2.new(0,70,0,22)
    espToggle.Position = UDim2.new(1,-80,0,24)
    espToggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
    espToggle.BorderSizePixel = 0
    espToggle.Font = Enum.Font.GothamBold
    espToggle.TextSize = 12
    espToggle.TextColor3 = Color3.fromRGB(180,180,190)
    espToggle.Text = "LOCKED"
    espToggle.ZIndex = 4
    espToggle.AutoButtonColor = false
    espToggle.Parent = espCard

    local espCorner = Instance.new("UICorner")
    espCorner.CornerRadius = UDim.new(1,0)
    espCorner.Parent = espToggle
end
---------------------------------------------------------------------//
-- HELPER: GET HUMANOID
---------------------------------------------------------------------//
local function getHumanoid()
    if not LocalPlayer then return nil end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

---------------------------------------------------------------------//
-- MAIN PAGE (Auto Click / Parry + Status + Controls)
---------------------------------------------------------------------//
local function keyToString(keycode)
    local s = tostring(keycode)
    return s:match("%.(.+)") or s
end

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,-40,0,24)
statusLabel.Position = UDim2.new(0,20,0,20)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 16
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextColor3 = Color3.fromRGB(255,80,80)
statusLabel.Text = "Status: OFF (10 CPS, "..mode..", "..actionMode..")"
statusLabel.ZIndex = 3
statusLabel.Parent = mainPage

-- Label helper
local function mkLabel(txt,x,y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0,140,0,20)
    l.Position = UDim2.new(0,x,0,y)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham
    l.TextSize = 14
    l.TextColor3 = Color3.fromRGB(230,230,235)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = txt
    l.ZIndex = 3
    l.Parent = mainPage
    return l
end

-- CPS
mkLabel("CPS:",20,60)

local cpsBox = Instance.new("TextBox")
cpsBox.Size = UDim2.new(0,70,0,24)
cpsBox.Position = UDim2.new(0,70,0,58)
cpsBox.BackgroundColor3 = Color3.fromRGB(30,30,35)
cpsBox.BorderSizePixel = 0
cpsBox.Font = Enum.Font.Gotham
cpsBox.TextSize = 14
cpsBox.TextColor3 = Color3.fromRGB(255,255,255)
cpsBox.Text = "10"
cpsBox.ClearTextOnFocus = false
cpsBox.ZIndex = 3
cpsBox.Parent = mainPage

local cpsCorner = Instance.new("UICorner")
cpsCorner.CornerRadius = UDim.new(0,8)
cpsCorner.Parent = cpsBox

-- Click key (locked display)
mkLabel("Click Keybind:",20,96)

local keyButton = Instance.new("TextButton")
keyButton.Size = UDim2.new(0,70,0,24)
keyButton.Position = UDim2.new(0,130,0,94)
keyButton.BackgroundColor3 = Color3.fromRGB(30,30,35)
keyButton.BorderSizePixel = 0
keyButton.Font = Enum.Font.GothamBold
keyButton.TextSize = 14
keyButton.TextColor3 = Color3.fromRGB(255,255,255)
keyButton.Text = keyToString(toggleKey) .. " (Lock)"
keyButton.ZIndex = 3
keyButton.AutoButtonColor = false
keyButton.Parent = mainPage

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0,8)
keyCorner.Parent = keyButton

-- Mode button
mkLabel("Mode:",20,132)

local modeButton = Instance.new("TextButton")
modeButton.Size = UDim2.new(0,90,0,24)
modeButton.Position = UDim2.new(0,80,0,130)
modeButton.BackgroundColor3 = Color3.fromRGB(30,30,35)
modeButton.BorderSizePixel = 0
modeButton.Font = Enum.Font.GothamBold
modeButton.TextSize = 14
modeButton.TextColor3 = Color3.fromRGB(255,255,255)
modeButton.Text = mode
modeButton.ZIndex = 3
modeButton.Parent = mainPage

local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0,8)
modeCorner.Parent = modeButton

-- Action button
mkLabel("Action:",20,168)

local actionButton = Instance.new("TextButton")
actionButton.Size = UDim2.new(0,90,0,24)
actionButton.Position = UDim2.new(0,80,0,166)
actionButton.BackgroundColor3 = Color3.fromRGB(30,30,35)
actionButton.BorderSizePixel = 0
actionButton.Font = Enum.Font.GothamBold
actionButton.TextSize = 14
actionButton.TextColor3 = Color3.fromRGB(255,255,255)
actionButton.Text = actionMode
actionButton.ZIndex = 3
actionButton.Parent = mainPage

local actionCorner = Instance.new("UICorner")
actionCorner.CornerRadius = UDim.new(0,8)
actionCorner.Parent = actionButton

-- Info text
local lockedLabel = Instance.new("TextLabel")
lockedLabel.Size = UDim2.new(1,-40,0,20)
lockedLabel.Position = UDim2.new(0,20,0,204)
lockedLabel.BackgroundTransparency = 1
lockedLabel.Font = Enum.Font.Gotham
lockedLabel.TextSize = 13
lockedLabel.TextColor3 = Color3.fromRGB(200,200,210)
lockedLabel.TextXAlignment = Enum.TextXAlignment.Left
lockedLabel.Text = "Parry Key: E (locked) | Main click key: E (locked)"
lockedLabel.ZIndex = 3
lockedLabel.Parent = mainPage

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1,-40,0,40)
infoLabel.Position = UDim2.new(0,20,0,230)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.TextColor3 = Color3.fromRGB(180,180,190)
infoLabel.Text = "RightCtrl = show/hide hub. Mode = Toggle/Hold. Action = Click/Parry. Speed & Jump are in Blatant > Player Options."
infoLabel.ZIndex = 3
infoLabel.Parent = mainPage

-- Start / Stop button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,220,0,34)
toggleBtn.Position = UDim2.new(0,20,0,280)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
toggleBtn.BorderSizePixel = 0
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Text = "Start"
toggleBtn.ZIndex = 3
toggleBtn.Parent = mainPage

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0,10)
toggleCorner.Parent = toggleBtn

---------------------------------------------------------------------//
-- LIVE STATUS PANEL (FPS / PING / WS / JP / REGION)
---------------------------------------------------------------------//
local livePanel = Instance.new("Frame")
livePanel.Size = UDim2.new(0,220,0,112)
livePanel.Position = UDim2.new(1,-240,0,20)
livePanel.BackgroundColor3 = Color3.fromRGB(20,20,26)
livePanel.BorderSizePixel = 0
livePanel.ZIndex = 3
livePanel.Parent = mainPage

local lpCorner = Instance.new("UICorner")
lpCorner.CornerRadius = UDim.new(0,12)
lpCorner.Parent = livePanel

local lpStroke = Instance.new("UIStroke")
lpStroke.Thickness = 1
lpStroke.Color = Color3.fromRGB(40,40,50)
lpStroke.Parent = livePanel

local lpTitle = Instance.new("TextLabel")
lpTitle.Size = UDim2.new(1,-10,0,20)
lpTitle.Position = UDim2.new(0,8,0,6)
lpTitle.BackgroundTransparency = 1
lpTitle.Font = Enum.Font.GothamSemibold
lpTitle.TextSize = 14
lpTitle.TextColor3 = Color3.fromRGB(255,255,255)
lpTitle.TextXAlignment = Enum.TextXAlignment.Left
lpTitle.Text = "📊 Live Status"
lpTitle.ZIndex = 4
lpTitle.Parent = livePanel

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1,-16,0,16)
fpsLabel.Position = UDim2.new(0,8,0,28)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.TextSize = 12
fpsLabel.TextColor3 = Color3.fromRGB(210,210,220)
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Text = "FPS: --"
fpsLabel.ZIndex = 4
fpsLabel.Parent = livePanel

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(1,-16,0,16)
pingLabel.Position = UDim2.new(0,8,0,44)
pingLabel.BackgroundTransparency = 1
pingLabel.Font = Enum.Font.Gotham
pingLabel.TextSize = 12
pingLabel.TextColor3 = Color3.fromRGB(210,210,220)
pingLabel.TextXAlignment = Enum.TextXAlignment.Left
pingLabel.Text = "Ping: -- ms"
pingLabel.ZIndex = 4
pingLabel.Parent = livePanel

local wsLabel = Instance.new("TextLabel")
wsLabel.Size = UDim2.new(1,-16,0,16)
wsLabel.Position = UDim2.new(0,8,0,60)
wsLabel.BackgroundTransparency = 1
wsLabel.Font = Enum.Font.Gotham
wsLabel.TextSize = 12
wsLabel.TextColor3 = Color3.fromRGB(210,210,220)
wsLabel.TextXAlignment = Enum.TextXAlignment.Left
wsLabel.Text = "WalkSpeed: --"
wsLabel.ZIndex = 4
wsLabel.Parent = livePanel

local jpLabel = Instance.new("TextLabel")
jpLabel.Size = UDim2.new(1,-16,0,16)
jpLabel.Position = UDim2.new(0,8,0,76)
jpLabel.BackgroundTransparency = 1
jpLabel.Font = Enum.Font.Gotham
jpLabel.TextSize = 12
jpLabel.TextColor3 = Color3.fromRGB(210,210,220)
jpLabel.TextXAlignment = Enum.TextXAlignment.Left
jpLabel.Text = "JumpPower: --"
jpLabel.ZIndex = 4
jpLabel.Parent = livePanel

local regionLabel = Instance.new("TextLabel")
regionLabel.Size = UDim2.new(1,-16,0,16)
regionLabel.Position = UDim2.new(0,8,0,92)
regionLabel.BackgroundTransparency = 1
regionLabel.Font = Enum.Font.Gotham
regionLabel.TextSize = 12
regionLabel.TextColor3 = Color3.fromRGB(210,210,220)
regionLabel.TextXAlignment = Enum.TextXAlignment.Left
regionLabel.Text = "Region: --"
regionLabel.ZIndex = 4
regionLabel.Parent = livePanel

-- FPS tracking
local lastFps = 0
RunService.RenderStepped:Connect(function(dt)
    if dt > 0 then
        lastFps = math.floor(1/dt + 0.5)
    end
end)

local function getPingMs()
    -- Prefer LocalPlayer:GetNetworkPing
    local ok, ping = pcall(function()
        if LocalPlayer and LocalPlayer.GetNetworkPing then
            return LocalPlayer:GetNetworkPing()
        end
    end)
    if ok and ping then
        return math.floor(ping * 1000 + 0.5)
    end

    -- Fallback Stats
    local Stats = game:FindService("Stats") or game:GetService("Stats")
    local success, ms = pcall(function()
        local net = Stats.Network
        local si = net:FindFirstChild("ServerStatsItem")
        if si then
            local dp = si:FindFirstChild("Data Ping") or si:FindFirstChild("Ping")
            if dp then
                local str = dp:GetValueString()
                local n = tonumber(str:match("(%d+)%s*ms"))
                return n
            end
        end
    end)

    if success and ms then
        return ms
    end

    return nil
end

local cachedRegion = nil
local function getServerRegion()
    if cachedRegion ~= nil then
        return cachedRegion
    end

    -- Try join data
    local ok, joinData = pcall(function()
        if LocalPlayer and LocalPlayer.GetJoinData then
            return LocalPlayer:GetJoinData()
        end
    end)

    if ok and joinData then
        if joinData.Region ~= nil then
            cachedRegion = tostring(joinData.Region)
            return cachedRegion
        end
        if joinData.matchmakingContext ~= nil then
            cachedRegion = tostring(joinData.matchmakingContext)
            return cachedRegion
        end
    end

    -- Fallback: Roblox locale
    local ok2, loc = pcall(function()
        return LocalizationService.RobloxLocaleId or LocalizationService.SystemLocaleId
    end)
    if ok2 and loc then
        cachedRegion = tostring(loc)
        return cachedRegion
    end

    cachedRegion = "Unknown"
    return cachedRegion
end

-- Update loop
task.spawn(function()
    while true do
        local hum = getHumanoid()
        local ws, jp = 0, 0
        if hum then
            ws = hum.WalkSpeed or 0
            if hum.UseJumpPower ~= nil then
                jp = hum.JumpPower or 0
            end
        end

        local pingMs = getPingMs()
        local region = getServerRegion() or "Unknown"

        fpsLabel.Text = "FPS: "..tostring(lastFps)
        if pingMs then
            pingLabel.Text = "Ping: "..pingMs.." ms"
        else
            pingLabel.Text = "Ping: N/A"
        end

        wsLabel.Text = string.format("WalkSpeed: %.1f", ws)
        jpLabel.Text = string.format("JumpPower: %.1f", jp)
        regionLabel.Text = "Region: "..tostring(region)

        task.wait(0.1)
    end
end)

---------------------------------------------------------------------//
-- STATUS HELPERS
---------------------------------------------------------------------//
local function getCPS()
    local n = tonumber(cpsBox.Text)
    if not n or n <= 0 then
        n = 10
        cpsBox.Text = "10"
    end
    if n > 100 then
        n = 100
        cpsBox.Text = "100"
    end
    cps = n
    return n
end

local function updateStatus()
    local curCps = getCPS()
    local onOff = clicking and "ON" or "OFF"
    local color = clicking and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,80,80)
    statusLabel.Text = string.format("Status: %s (%d CPS, %s, %s)", onOff, curCps, mode, actionMode)
    statusLabel.TextColor3 = color
end

local function toggleClicker()
    clicking = not clicking
    updateStatus()
    if clicking then
        toggleBtn.Text = "Stop"
        toggleBtn.BackgroundColor3 = ThemeAccentOn
    else
        toggleBtn.Text = "Start"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
    end
end

toggleBtn.MouseButton1Click:Connect(toggleClicker)
cpsBox.FocusLost:Connect(updateStatus)

modeButton.MouseButton1Click:Connect(function()
    mode = (mode == "Toggle") and "Hold" or "Toggle"
    modeButton.Text = mode
    updateStatus()
end)

actionButton.MouseButton1Click:Connect(function()
    actionMode = (actionMode == "Click") and "Parry" or "Click"
    actionButton.Text = actionMode
    updateStatus()
end)
---------------------------------------------------------------------//
-- FORWARD-DECLARED FUNCTIONS (IMPLEMENTED LATER)
---------------------------------------------------------------------//
local setSemiImmortal -- will be assigned in Part 7 (desync engine)

---------------------------------------------------------------------//
-- BLATANT PAGE (Scroll + Semi Immortal + Player Options)
---------------------------------------------------------------------//
local blatantScroll = Instance.new("ScrollingFrame")
blatantScroll.Size = UDim2.new(1,-20,1,-20)
blatantScroll.Position = UDim2.new(0,10,0,10)
blatantScroll.BackgroundTransparency = 1
blatantScroll.BorderSizePixel = 0
blatantScroll.ScrollBarThickness = 4
blatantScroll.CanvasSize = UDim2.new(0,0,0,0)
blatantScroll.ZIndex = 3
blatantScroll.Parent = blatantPage

local bLayout = Instance.new("UIListLayout")
bLayout.SortOrder = Enum.SortOrder.LayoutOrder
bLayout.Padding = UDim.new(0,10)
bLayout.Parent = blatantScroll

bLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    blatantScroll.CanvasSize = UDim2.new(0,0,0, bLayout.AbsoluteContentSize.Y + 10)
end)

local function createBlatantCard(height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,height)
    card.BackgroundColor3 = Color3.fromRGB(20,20,26)
    card.BorderSizePixel = 0
    card.ZIndex = 3
    card.Parent = blatantScroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim2.new(0,12)
    c.Parent = card

    return card
end

local function blatantHeader(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,22)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(230,230,235)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 3
    lbl.Parent = blatantScroll
end

local function makeTitle(parent,txt)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,-60,0,20)
    t.Position = UDim2.new(0,10,0,6)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamSemibold
    t.TextSize = 14
    t.TextColor3 = Color3.fromRGB(255,255,255)
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Text = txt
    t.ZIndex = 4
    t.Parent = parent
    return t
end

local function makeDesc(parent,txt)
    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1,-20,0,32)
    d.Position = UDim2.new(0,10,0,26)
    d.BackgroundTransparency = 1
    d.Font = Enum.Font.Gotham
    d.TextSize = 12
    d.TextColor3 = Color3.fromRGB(200,200,210)
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextYAlignment = Enum.TextYAlignment.Top
    d.TextWrapped = true
    d.Text = txt
    d.ZIndex = 4
    d.Parent = parent
    return d
end

---------------------------------------------------------------------//
-- SEMI IMMORTAL (FULL BODY STUTTER DESYNC) - UI PART
---------------------------------------------------------------------//
blatantHeader("Semi Immortal")

local semiCard = createBlatantCard(70)
makeTitle(semiCard, "Semi Immortal")
makeDesc(semiCard, "Full body micro-teleport stutter around your real position. You stay visually still, server sees you jittering.")

local semiToggle = Instance.new("TextButton")
semiToggle.Size = UDim2.new(0,60,0,24)
semiToggle.Position = UDim2.new(1,-70,0,24)
semiToggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
semiToggle.BorderSizePixel = 0
semiToggle.Font = Enum.Font.GothamBold
semiToggle.TextSize = 12
semiToggle.TextColor3 = Color3.fromRGB(230,230,235)
semiToggle.Text = "OFF"
semiToggle.ZIndex = 4
semiToggle.Parent = semiCard

local semiCorner = Instance.new("UICorner")
semiCorner.CornerRadius = UDim2.new(1,0)
semiCorner.Parent = semiToggle

local function updateSemiImmortalVisual()
    if semiImmortalOn then
        semiToggle.BackgroundColor3 = ThemeAccentOn
        semiToggle.Text = "ON"
    else
        semiToggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
        semiToggle.Text = "OFF"
    end
end

updateSemiImmortalVisual()

semiToggle.MouseButton1Click:Connect(function()
    semiImmortalOn = not semiImmortalOn
    updateSemiImmortalVisual()
    if setSemiImmortal then
        setSemiImmortal(semiImmortalOn)
    end
    if semiImmortalOn then
        infoLabel.Text = "Semi Immortal: FULL BODY STUTTER enabled (server-side desync)."
    else
        infoLabel.Text = "Semi Immortal disabled."
    end
end)

---------------------------------------------------------------------//
-- DETECTIONS (LOCKED PLACEHOLDERS)
---------------------------------------------------------------------//
blatantHeader("Detections")

local function createDisabledDetection(title,desc)
    local card = createBlatantCard(52)
    makeTitle(card,title)
    makeDesc(card,(desc or "").." Temporarily unavailable.")

    local lockBtn = Instance.new("TextButton")
    lockBtn.Size = UDim2.new(0,70,0,22)
    lockBtn.Position = UDim2.new(1,-80,0,16)
    lockBtn.BackgroundColor3 = Color3.fromRGB(40,40,48)
    lockBtn.BorderSizePixel = 0
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.TextSize = 12
    lockBtn.TextColor3 = Color3.fromRGB(180,180,190)
    lockBtn.Text = "LOCKED"
    lockBtn.ZIndex = 4
    lockBtn.AutoButtonColor = false
    lockBtn.Parent = card

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim2.new(1,0)
    c.Parent = lockBtn

    return card
end

createDisabledDetection("Infinity Detection","Avoid accidental crashes by having the skill.")
createDisabledDetection("Death Slash Detection","Generates the shot when activating the ability.")
createDisabledDetection("Time Hole Detection","Avoid failing when someone has that skill.")
createDisabledDetection("Slash of Fury Detection","Will auto-react when Slash of Fury is used (disabled for now).")

---------------------------------------------------------------------//
-- PLAYER OPTIONS (SPEED + JUMP)
---------------------------------------------------------------------//
blatantHeader("Player Options")

-- SPEED CARD
local speedCard = createBlatantCard(70)
makeTitle(speedCard,"Speed")
makeDesc(speedCard,"Choose walk speed 10–100. Toggle must be ON to apply. Restores original when turned off.")

local speedValueLabel = Instance.new("TextLabel")
speedValueLabel.Size = UDim2.new(0,40,0,16)
speedValueLabel.Position = UDim2.new(1,-90,0,8)
speedValueLabel.BackgroundTransparency = 1
speedValueLabel.Font = Enum.Font.Gotham
speedValueLabel.TextSize = 12
speedValueLabel.TextColor3 = Color3.fromRGB(220,220,230)
speedValueLabel.Text = tostring(speedValue)
speedValueLabel.ZIndex = 4
speedValueLabel.Parent = speedCard

local speedToggleBtn = Instance.new("TextButton")
speedToggleBtn.Size = UDim2.new(0,50,0,22)
speedToggleBtn.Position = UDim2.new(1,-60,0,8)
speedToggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,48)
speedToggleBtn.BorderSizePixel = 0
speedToggleBtn.Font = Enum.Font.GothamBold
speedToggleBtn.TextSize = 12
speedToggleBtn.TextColor3 = Color3.fromRGB(230,230,235)
speedToggleBtn.Text = "OFF"
speedToggleBtn.ZIndex = 4
speedToggleBtn.Parent = speedCard

local speedToggleCorner = Instance.new("UICorner")
speedToggleCorner.CornerRadius = UDim2.new(1,0)
speedToggleCorner.Parent = speedToggleBtn

local speedBar = Instance.new("Frame")
speedBar.Size = UDim2.new(1,-40,0,6)
speedBar.Position = UDim2.new(0,10,0,42)
speedBar.BackgroundColor3 = Color3.fromRGB(35,35,42)
speedBar.BorderSizePixel = 0
speedBar.ZIndex = 4
speedBar.Parent = speedCard

local speedBarCorner = Instance.new("UICorner")
speedBarCorner.CornerRadius = UDim2.new(0,6)
speedBarCorner.Parent = speedBar

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new((speedValue-10)/(100-10),0,1,0)
speedFill.BackgroundColor3 = Color3.fromRGB(140,200,255)
speedFill.BorderSizePixel = 0
speedFill.ZIndex = 5
speedFill.Parent = speedBar

local speedFillCorner = Instance.new("UICorner")
speedFillCorner.CornerRadius = UDim2.new(0,6)
speedFillCorner.Parent = speedFill

local speedDragging = false

local function updateSpeedToggleVisual()
    if speedEnabled then
        speedToggleBtn.BackgroundColor3 = ThemeAccentOn
        speedToggleBtn.Text = "ON"
    else
        speedToggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,48)
        speedToggleBtn.Text = "OFF"
    end
end

updateSpeedToggleVisual()

local function setSpeedFromX(x)
    local rel = 0
    if speedBar.AbsoluteSize.X > 0 then
        rel = math.clamp((x - speedBar.AbsolutePosition.X)/speedBar.AbsoluteSize.X,0,1)
    end
    local val = math.floor(10 + (100-10)*rel + 0.5)
    speedValue = val
    speedValueLabel.Text = tostring(val)
    speedFill.Size = UDim2.new(rel,0,1,0)

    if speedEnabled and typeof(applySpeed) == "function" then
        applySpeed()
    end
end

speedBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        speedDragging = true
        setSpeedFromX(inp.Position.X)
    end
end)

UIS.InputChanged:Connect(function(inp)
    if speedDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        setSpeedFromX(inp.Position.X)
    end
end)

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        speedDragging = false
    end
end)

speedToggleBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    updateSpeedToggleVisual()
    local hum = getHumanoid()
    if not hum then return end

    if speedEnabled then
        if originalWalkSpeed == nil then
            originalWalkSpeed = hum.WalkSpeed
        end
        if typeof(applySpeed) == "function" then
            applySpeed()
        else
            hum.WalkSpeed = speedValue
        end
    else
        if originalWalkSpeed ~= nil then
            hum.WalkSpeed = originalWalkSpeed
        end
    end
end)

-- JUMP CARD
local jumpCard = createBlatantCard(70)
makeTitle(jumpCard,"Jump Power")
makeDesc(jumpCard,"Choose jump power 25–150. Toggle must be ON to apply. Restores original when turned off.")

local jumpValueLabel = Instance.new("TextLabel")
jumpValueLabel.Size = UDim2.new(0,40,0,16)
jumpValueLabel.Position = UDim2.new(1,-90,0,8)
jumpValueLabel.BackgroundTransparency = 1
jumpValueLabel.Font = Enum.Font.Gotham
jumpValueLabel.TextSize = 12
jumpValueLabel.TextColor3 = Color3.fromRGB(220,220,230)
jumpValueLabel.Text = tostring(jumpValue)
jumpValueLabel.ZIndex = 4
jumpValueLabel.Parent = jumpCard

local jumpToggleBtn = Instance.new("TextButton")
jumpToggleBtn.Size = UDim2.new(0,50,0,22)
jumpToggleBtn.Position = UDim2.new(1,-60,0,8)
jumpToggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,48)
jumpToggleBtn.BorderSizePixel = 0
jumpToggleBtn.Font = Enum.Font.GothamBold
jumpToggleBtn.TextSize = 12
jumpToggleBtn.TextColor3 = Color3.fromRGB(230,230,235)
jumpToggleBtn.Text = "OFF"
jumpToggleBtn.ZIndex = 4
jumpToggleBtn.Parent = jumpCard

local jumpToggleCorner = Instance.new("UICorner")
jumpToggleCorner.CornerRadius = UDim2.new(1,0)
jumpToggleCorner.Parent = jumpToggleBtn

local jumpBar = Instance.new("Frame")
jumpBar.Size = UDim2.new(1,-40,0,6)
jumpBar.Position = UDim2.new(0,10,0,42)
jumpBar.BackgroundColor3 = Color3.fromRGB(35,35,42)
jumpBar.BorderSizePixel = 0
jumpBar.ZIndex = 4
jumpBar.Parent = jumpCard

local jumpBarCorner = Instance.new("UICorner")
jumpBarCorner.CornerRadius = UDim2.new(0,6)
jumpBarCorner.Parent = jumpBar

local jumpFill = Instance.new("Frame")
jumpFill.Size = UDim2.new((jumpValue-25)/(150-25),0,1,0)
jumpFill.BackgroundColor3 = Color3.fromRGB(140,200,255)
jumpFill.BorderSizePixel = 0
jumpFill.ZIndex = 5
jumpFill.Parent = jumpBar

local jumpFillCorner = Instance.new("UICorner")
jumpFillCorner.CornerRadius = UDim2.new(0,6)
jumpFillCorner.Parent = jumpFill

local jumpDragging = false

local function updateJumpToggleVisual()
    if jumpEnabled then
        jumpToggleBtn.BackgroundColor3 = ThemeAccentOn
        jumpToggleBtn.Text = "ON"
    else
        jumpToggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,48)
        jumpToggleBtn.Text = "OFF"
    end
end

updateJumpToggleVisual()

local function setJumpFromX(x)
    local rel = 0
    if jumpBar.AbsoluteSize.X > 0 then
        rel = math.clamp((x - jumpBar.AbsolutePosition.X)/jumpBar.AbsoluteSize.X,0,1)
    end
    local val = math.floor(25 + (150-25)*rel + 0.5)
    jumpValue = val
    jumpValueLabel.Text = tostring(val)
    jumpFill.Size = UDim2.new(rel,0,1,0)

    if jumpEnabled and typeof(applyJump) == "function" then
        applyJump()
    end
end

jumpBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        jumpDragging = true
        setJumpFromX(inp.Position.X)
    end
end)

UIS.InputChanged:Connect(function(inp)
    if jumpDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        setJumpFromX(inp.Position.X)
    end
end)

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        jumpDragging = false
    end
end)

jumpToggleBtn.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    updateJumpToggleVisual()
    local hum = getHumanoid()
    if not hum then return end

    if jumpEnabled then
        if originalJumpPower == nil then
            originalJumpPower = hum.JumpPower
        end
        if typeof(applyJump) == "function" then
            applyJump()
        else
            if hum.UseJumpPower ~= nil then
                hum.UseJumpPower = true
            end
            hum.JumpPower = jumpValue
        end
    else
        if originalJumpPower ~= nil then
            hum.JumpPower = originalJumpPower
        end
    end
end)

---------------------------------------------------------------------//
-- MANUAL SPAM + TRIGGERBOT
---------------------------------------------------------------------//
blatantHeader("Combat Helpers")

local listeningForManual = false

-- Manual spam card
local manualCard = createBlatantCard(52)
makeTitle(manualCard,"Manual Spam")
makeDesc(manualCard,"Spam key on press. Click to set the key.")

local manualKeyButton = Instance.new("TextButton")
manualKeyButton.Size = UDim2.new(0,70,0,24)
manualKeyButton.Position = UDim2.new(1,-80,0,14)
manualKeyButton.BackgroundColor3 = Color3.fromRGB(30,30,38)
manualKeyButton.BorderSizePixel = 0
manualKeyButton.Font = Enum.Font.GothamBold
manualKeyButton.TextSize = 14
manualKeyButton.TextColor3 = Color3.fromRGB(255,255,255)
manualKeyButton.Text = keyToString(manualKey)
manualKeyButton.ZIndex = 4
manualKeyButton.Parent = manualCard

local manualKeyCorner = Instance.new("UICorner")
manualKeyCorner.CornerRadius = UDim2.new(0,10)
manualKeyCorner.Parent = manualKeyButton

manualKeyButton.MouseButton1Click:Connect(function()
    if listeningForManual then return end
    listeningForManual = true
    infoLabel.Text = "Press a key for Manual Spam..."
end)

-- Triggerbot card
local triggerCard = createBlatantCard(52)
makeTitle(triggerCard,"Triggerbot")
makeDesc(triggerCard,"Constant parry spam when enabled (good for simple games / testing).")

local trigToggle = Instance.new("TextButton")
trigToggle.Size = UDim2.new(0,60,0,24)
trigToggle.Position = UDim2.new(1,-70,0,14)
trigToggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
trigToggle.BorderSizePixel = 0
trigToggle.Font = Enum.Font.GothamBold
trigToggle.TextSize = 12
trigToggle.TextColor3 = Color3.fromRGB(230,230,235)
trigToggle.Text = "OFF"
trigToggle.ZIndex = 4
trigToggle.Parent = triggerCard

local trigCorner = Instance.new("UICorner")
trigCorner.CornerRadius = UDim2.new(1,0)
trigCorner.Parent = trigToggle

local function updateTriggerVisual()
    if triggerbotOn then
        trigToggle.BackgroundColor3 = ThemeAccentOn
        trigToggle.Text = "ON"
    else
        trigToggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
        trigToggle.Text = "OFF"
    end
end

updateTriggerVisual()

trigToggle.MouseButton1Click:Connect(function()
    triggerbotOn = not triggerbotOn
    updateTriggerVisual()
end)
---------------------------------------------------------------------//
-- SEMI IMMORTAL ENGINE (FULL BODY STUTTER DESYNC)
---------------------------------------------------------------------//
do
    local semiConn
    local lastOffsetY = 0

    setSemiImmortal = function(on)
        semiImmortalOn = on

        if semiConn then
            semiConn:Disconnect()
            semiConn = nil
        end

        if not on then
            lastOffsetY = 0
            return
        end

        semiConn = RunService.Heartbeat:Connect(function(dt)
            local lp = LocalPlayer
            if not lp then return end

            local char = lp.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            local cam = workspace.CurrentCamera
            if not (hrp and cam) then return end

            -- fast up/down wave
            local t = tick() * 18 -- speed
            local newY = math.sin(t) * 2.2 -- amplitude (small so you don't get kicked)
            local dy = newY - lastOffsetY
            lastOffsetY = newY

            -- move server hitbox but keep your view stable
            local cf = hrp.CFrame
            hrp.CFrame = cf * CFrame.new(0, dy, 0)

            -- cancel out visually for your camera
            cam.CFrame = cam.CFrame * CFrame.new(0, -dy, 0)
        end)
    end
end

---------------------------------------------------------------------//
-- FX HELPERS (FPS BOOST, PLAYER EFFECTS, ABILITY ESP, SPEED, JUMP)
---------------------------------------------------------------------//
function applyFpsBoost(on)
    fpsBoostOn = on
    if on then
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
        end)
    else
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end)
    end
end

function applyPlayerEffects(on)
    playerEffectsOn = on
    local lp = LocalPlayer
    if not lp then return end

    local char = lp.Character or lp.CharacterAdded:Wait()
    if not char then return end

    local function setPart(name, alpha)
        local p = char:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            p.Transparency = alpha
            for _, d in ipairs(p:GetDescendants()) do
                if d:IsA("Decal") or d:IsA("Texture") then
                    d.Transparency = alpha
                end
            end
        end
    end

    -- Headless effect
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = on and 1 or 0
        for _, d in ipairs(head:GetDescendants()) do
            if d:IsA("Decal") or d:IsA("Texture") then
                d.Transparency = on and 1 or 0
            end
        end
    end

    -- Korblox effect (right leg)
    for _, n in ipairs({"RightUpperLeg","RightLowerLeg","RightFoot"}) do
        setPart(n, on and 1 or 0)
    end
end

function applyAbilityEsp(on)
    -- intentionally locked / stubbed
    abilityEspOn = false
end

function applySpeed()
    if not speedEnabled then return end
    local hum = getHumanoid()
    if not hum then return end

    if originalWalkSpeed == nil then
        originalWalkSpeed = hum.WalkSpeed
    end

    hum.WalkSpeed = speedValue
end

function applyJump()
    if not jumpEnabled then return end
    local hum = getHumanoid()
    if not hum then return end

    if hum.UseJumpPower ~= nil then
        hum.UseJumpPower = true
    end

    if originalJumpPower == nil then
        originalJumpPower = hum.JumpPower
    end

    hum.JumpPower = jumpValue
end

---------------------------------------------------------------------//
-- INPUT HANDLING (GUI TOGGLE, MAIN TOGGLE, MANUAL KEY)
---------------------------------------------------------------------//
local function doMouseClick()
    if mouse1click then
        pcall(mouse1click)
    elseif mouse1press and mouse1release then
        mouse1press()
        task.wait(0.01)
        mouse1release()
    elseif VIM then
        pcall(function()
            VIM:SendMouseButtonEvent(0,0,0,true,game,0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0,0,0,false,game,0)
        end)
    end
end

UIS.InputBegan:Connect(function(input, gp)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    -- Show / hide hub
    if input.KeyCode == Enum.KeyCode.RightControl and not listeningForManual then
        guiVisible = not guiVisible
        gui.Enabled = guiVisible
        return
    end

    -- manual spam key rebind
    if listeningForManual then
        manualKey = input.KeyCode
        if manualKeyButton then
            manualKeyButton.Text = keyToString(manualKey)
        end
        infoLabel.Text = "Manual spam key set to: "..keyToString(manualKey)
        listeningForManual = false
        return
    end

    if gp then return end

    -- main toggle key (E, locked)
    if input.KeyCode == toggleKey then
        if mode == "Toggle" then
            toggleClicker()
        else
            clicking = true
            updateStatus()
        end
        return
    end

    -- manual spam hold
    if input.KeyCode == manualKey then
        manualSpamActive = true
        return
    end
end)

UIS.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    -- stop hold mode
    if input.KeyCode == toggleKey and mode == "Hold" then
        clicking = false
        updateStatus()
    end

    -- stop manual spam on release
    if input.KeyCode == manualKey then
        manualSpamActive = false
    end
end)

---------------------------------------------------------------------//
-- MAIN SPAM LOOP (AUTO CLICK / PARRY / TRIGGERBOT / MANUAL)
---------------------------------------------------------------------//
task.spawn(function()
    while true do
        if clicking or triggerbotOn or manualSpamActive then
            local delay = 1 / getCPS()
            if delay < 0.001 then
                delay = 0.001
            end

            -- main click / parry
            if clicking then
                if actionMode == "Click" then
                    doMouseClick()
                else
                    if VIM and parryKey then
                        pcall(function()
                            VIM:SendKeyEvent(true, parryKey, false, game)
                            task.wait(0.01)
                            VIM:SendKeyEvent(false, parryKey, false, game)
                        end)
                    end
                end
            end

            -- triggerbot (constant parry)
            if triggerbotOn and VIM and parryKey then
                pcall(function()
                    VIM:SendKeyEvent(true, parryKey, false, game)
                    task.wait(0.01)
                    VIM:SendKeyEvent(false, parryKey, false, game)
                end)
            end

            -- manual spam key
            if manualSpamActive and VIM and manualKey then
                pcall(function()
                    VIM:SendKeyEvent(true, manualKey, false, game)
                    task.wait(0.01)
                    VIM:SendKeyEvent(false, manualKey, false, game)
                end)
            end

            task.wait(delay)
        else
            task.wait(0.05)
        end
    end
end)

---------------------------------------------------------------------//
-- FINAL SETUP
---------------------------------------------------------------------//
setActivePage("Home")
updateStatus()
sendWebhookLog()
