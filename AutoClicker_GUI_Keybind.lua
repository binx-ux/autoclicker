-- BinHub X - Argon-style Hub v3.6
-- RightCtrl = Show/Hide hub

---------------------------------------------------------------------//
-- SERVICES / SETUP
---------------------------------------------------------------------//
local Players              = game:GetService("Players")
local UIS                  = game:GetService("UserInputService")
local CoreGui              = game:GetService("CoreGui")
local TweenService         = game:GetService("TweenService")
local RunService           = game:GetService("RunService")
local HttpService          = game:GetService("HttpService")
local MarketplaceService   = game:GetService("MarketplaceService")
local LocalizationService  = game:GetService("LocalizationService")
local Stats                = game:FindService("Stats") or game:GetService("Stats")
local RbxAnalyticsService  = game:GetService("RbxAnalyticsService")

local LocalPlayer          = Players.LocalPlayer
local displayName          = (LocalPlayer and LocalPlayer.DisplayName) or "Player"
local userName             = (LocalPlayer and LocalPlayer.Name) or "Unknown"

local TIKTOK_HANDLE        = "@binxix"
local CURRENT_VERSION      = "3.6"

---------------------------------------------------------------------//
-- EXEC ENV + REQUEST
---------------------------------------------------------------------//
local VIM
pcall(function()
    VIM = game:GetService("VirtualInputManager")
end)

local function getRequestFunction()
    return (syn and syn.request)
        or (http and http.request)
        or http_request
        or request
        or nil
end

local function httpGet(url)
    local req = getRequestFunction()
    if not req then return nil, "no_request" end

    local ok, res = pcall(function()
        return req({
            Url = url,
            Method = "GET"
        })
    end)

    if not ok or not res or not res.Body then
        return nil, "http_fail"
    end

    return res.Body, nil
end

---------------------------------------------------------------------//
-- EXEC / HWID INFO
---------------------------------------------------------------------//
local function getExecutorInfo()
    local execName   = "Unknown"
    local exploitEnv = "Unknown"

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
        exploitEnv = "Synapse Environment"
    elseif KRNL_LOADED or iskrnlclosure then
        exploitEnv = "KRNL Environment"
    elseif fluxus or isfluxusclosure then
        exploitEnv = "Fluxus Environment"
    elseif sentinel then
        exploitEnv = "Sentinel Environment"
    else
        if execName ~= "Unknown" then
            exploitEnv = execName .. " Environment"
        end
    end

    return execName, exploitEnv
end

local function getHWID()
    -- Roblox client ID is stable enough for HWID-style logging
    local ok, id = pcall(function()
        return RbxAnalyticsService:GetClientId()
    end)
    if ok and id then
        return tostring(id)
    end
    return "Unknown"
end

-- global exec counter
getgenv().BinHub_ExecCount = (getgenv().BinHub_ExecCount or 0) + 1

---------------------------------------------------------------------//
-- GAME INFO HELPERS
---------------------------------------------------------------------//
local function getGameName()
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if ok and info and info.Name then
        return info.Name
    end
    return "Unknown Game"
end

local function getBasicEmbedFields()
    local gameName   = getGameName()
    local placeId    = tostring(game.PlaceId)
    local jobId      = tostring(game.JobId)
    local username   = userName
    local dName      = displayName
    local timestamp  = os.date("%Y-%m-%d %H:%M:%S")

    local execName, exploitType = getExecutorInfo()
    local hwid      = getHWID()
    local execCount = getgenv().BinHub_ExecCount

    return {
        username   = username,
        displayName= dName,
        gameName   = gameName,
        placeId    = placeId,
        jobId      = jobId,
        timestamp  = timestamp,
        executor   = execName,
        exploitType= exploitType,
        hwid       = hwid,
        execCount  = execCount,
    }
end

---------------------------------------------------------------------//
-- WEBHOOK (EXECUTION + BUG REPORTS)
---------------------------------------------------------------------//
local WEBHOOK_URL = "https://discord.com/api/webhooks/1446656470287651050/ayflCl7nEQ3388YhXAZT7r3j5kTC40EP3WV9yO1BehR2vzHbtoDArV-YejWn_E_F6eUk"

local function getScriptInfoBlock()
    local lines = {
        "Hub: BinHub X - Argon-style Hub v"..CURRENT_VERSION,
        "",
        "Main Hub:",
        "  • Main Toggle Key: E (LOCKED)",
        "  • Mode: Toggle / Hold (UI controlled)",
        "  • Action: Click / Parry (UI controlled)",
        "",
        "Keybinds:",
        "  • Parry Key: E (locked)",
        "  • Manual Spam Key: R (default, rebindable)",
        "",
        "Player Options:",
        "  • Speed Boost: slider 10–100 (toggle)",
        "  • Jump Power Boost: slider 25–150 (toggle)",
        "",
        "System:",
        "  • FPS / Ping / Region panel",
        "  • Anti-AFK (optional toggle)",
        "",
        "Notes:",
        "  • RightCtrl = Show/Hide hub",
        "  • HWID + Exec Counter logged per execution.",
    }
    return table.concat(lines, "\n")
end

local function sendWebhookLog()
    if not WEBHOOK_URL or WEBHOOK_URL == "" then return end
    local req = getRequestFunction()
    if not req then return end

    local meta       = getBasicEmbedFields()
    local scriptInfo = getScriptInfoBlock()

    local payload = {
        embeds = {
            {
                title = "BinHub X - Script Executed",
                color = 0x5865F2,
                fields = {
                    {
                        name = "Player",
                        value = string.format("Display: **%s**\nUsername: `%s`", meta.displayName, meta.username),
                        inline = false
                    },
                    {
                        name = "Game",
                        value = string.format("**%s**\nPlaceId: `%s`\nJobId: `%s`", meta.gameName, meta.placeId, meta.jobId),
                        inline = false
                    },
                    {
                        name = "Executor / Exploit",
                        value = string.format("Executor: `%s`\nType: `%s`", meta.executor, meta.exploitType),
                        inline = false
                    },
                    {
                        name = "System",
                        value = string.format("HWID: `%s`\nExec Count: `%d`", meta.hwid, meta.execCount),
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
                    }
                }
            }
        }
    }

    local json = HttpService:JSONEncode(payload)
    pcall(function()
        req({
            Url     = WEBHOOK_URL,
            Method  = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body    = json
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
        trimmed = trimmed:sub(1,1000) .. "..."
    end

    local payload = {
        embeds = {
            {
                title = "BinHub X - Bug Report",
                color = 0xFF0000,
                fields = {
                    {
                        name = "Player",
                        value = string.format("Display: **%s**\nUsername: `%s`", meta.displayName, meta.username),
                        inline = false
                    },
                    {
                        name = "Game",
                        value = string.format("**%s**\nPlaceId: `%s`\nJobId: `%s`", meta.gameName, meta.placeId, meta.jobId),
                        inline = false
                    },
                    {
                        name = "Executor / Exploit",
                        value = string.format("Executor: `%s`\nType: `%s`", meta.executor, meta.exploitType),
                        inline = false
                    },
                    {
                        name = "System",
                        value = string.format("HWID: `%s`\nExec Count: `%d`", meta.hwid, meta.execCount),
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
                    }
                }
            }
        }
    }

    local json = HttpService:JSONEncode(payload)
    local ok, err = pcall(function()
        req({
            Url     = WEBHOOK_URL,
            Method  = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body    = json
        })
    end)

    if not ok then
        return false, tostring(err)
    end
    return true
end

---------------------------------------------------------------------//
-- AUTO UPDATER (SOFT CHECK)
---------------------------------------------------------------------//
-- change this to your own URL that returns plain text with latest version, e.g. "3.7"
local UPDATE_CHECK_URL = "https://example.com/binhub_version.txt"
local UPDATE_LOADSTRING = "loadstring(game:HttpGet('https://example.com/BinHubX.lua'))()"

local updateAvailable = false
local latestVersion   = CURRENT_VERSION

local function checkForUpdate()
    local body, err = httpGet(UPDATE_CHECK_URL)
    if not body then return end

    -- grab first non-empty line
    local version = tostring(body):gsub("\r",""):match("([^\n]+)")
    if version and version ~= "" then
        latestVersion = version
        if version ~= CURRENT_VERSION then
            updateAvailable = true
        end
    end
end

---------------------------------------------------------------------//
-- ANTI AFK
---------------------------------------------------------------------//
local antiAfkOn = false
local VirtualUser = nil
pcall(function()
    VirtualUser = game:GetService("VirtualUser")
end)

if LocalPlayer and VirtualUser then
    LocalPlayer.Idled:Connect(function()
        if antiAfkOn then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end)
end

---------------------------------------------------------------------//
-- SMALL HELPERS (HUMANOID, TWEEN, GUI PARENT)
---------------------------------------------------------------------//
local function tween(obj, props, t)
    local info = TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function getHumanoid()
    if not LocalPlayer then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

local function safeParent()
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

    local g = Instance.new("ScreenGui")
    g.Name = "BinHubX"
    g.ResetOnSpawn = false
    g.Parent = CoreGui
    return g
end

local gui = safeParent()
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local guiVisible = true
---------------------------------------------------------------------//
-- PART 2 — GUI ROOT + SIDEBAR + THEMES + PAGE SYSTEM
---------------------------------------------------------------------//

-- ROOT MAIN FRAME
local root = Instance.new("Frame")
root.Size = UDim2.new(0, 640, 0, 375)
root.Position = UDim2.new(0.5, -320, 0.5, -188)
root.BackgroundColor3 = Color3.fromRGB(10,10,15)
root.BorderSizePixel = 0
root.Visible = true
root.Parent = gui

local rootCorner = Instance.new("UICorner")
rootCorner.CornerRadius = UDim.new(0, 14)
rootCorner.Parent = root

-- TOP GRADIENT
local rootGrad = Instance.new("UIGradient")
rootGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5,5,10))
})
rootGrad.Rotation = 90
rootGrad.Parent = root

-- TITLE BAR
local topTitle = Instance.new("TextLabel")
topTitle.Size = UDim2.new(1, -20, 0, 34)
topTitle.Position = UDim2.new(0, 10, 0, 10)
topTitle.BackgroundTransparency = 1
topTitle.Font = Enum.Font.GothamBlack
topTitle.TextSize = 24
topTitle.TextColor3 = Color3.fromRGB(245,245,245)
topTitle.Text = "BinHub X v"..CURRENT_VERSION
topTitle.TextXAlignment = Enum.TextXAlignment.Left
topTitle.ZIndex = 3
topTitle.Parent = root

-- VERSION BADGE
local versionPill = Instance.new("Frame")
versionPill.Size = UDim2.new(0, 95, 0, 22)
versionPill.Position = UDim2.new(1, -110, 0, 14)
versionPill.BackgroundColor3 = Color3.fromRGB(85,170,255)
versionPill.BorderSizePixel = 0
versionPill.Parent = root

local versionCorner = Instance.new("UICorner")
versionCorner.CornerRadius = UDim.new(0, 10)
versionCorner.Parent = versionPill

local versionText = Instance.new("TextLabel")
versionText.Size = UDim2.new(1,0,1,0)
versionText.BackgroundTransparency = 1
versionText.Font = Enum.Font.GothamSemibold
versionText.TextColor3 = Color3.fromRGB(0,0,0)
versionText.TextSize = 13
versionText.Text = "Build "..CURRENT_VERSION
versionText.Parent = versionPill

---------------------------------------------------------------------//
-- SIDEBAR
---------------------------------------------------------------------//
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 120, 1, -55)
sidebar.Position = UDim2.new(0,0,0,55)
sidebar.BackgroundColor3 = Color3.fromRGB(10,10,12)
sidebar.BorderSizePixel = 0
sidebar.Parent = root

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0,16)
sideCorner.Parent = sidebar

local sideLayout = Instance.new("UIListLayout")
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Padding = UDim.new(0,10)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

---------------------------------------------------------------------//
-- PAGE SYSTEM
---------------------------------------------------------------------//
local pages = {}
local currentPage = nil

-- Page Container
local pageHolder = Instance.new("Frame")
pageHolder.Size = UDim2.new(1, -140, 1, -55)
pageHolder.Position = UDim2.new(0, 130, 0, 55)
pageHolder.BackgroundTransparency = 1
pageHolder.Parent = root

---------------------------------------------------------------------//
-- THEME ENGINE
---------------------------------------------------------------------//
ThemeConfig = {
    Default = {
        Accent       = Color3.fromRGB(255,165,0),
        AccentOn     = Color3.fromRGB(255,150,0),
        AccentText   = Color3.fromRGB(255,200,120),
        RootTop      = Color3.fromRGB(20,20,28),
        RootBottom   = Color3.fromRGB(6,6,12),
        Sidebar      = Color3.fromRGB(10,10,14),
        TopTitle     = Color3.fromRGB(240,240,240),
    },

    Purple = {
        Accent       = Color3.fromRGB(190,120,255),
        AccentOn     = Color3.fromRGB(170,90,255),
        AccentText   = Color3.fromRGB(220,180,255),
        RootTop      = Color3.fromRGB(25,18,40),
        RootBottom   = Color3.fromRGB(10,8,20),
        Sidebar      = Color3.fromRGB(18,14,28),
        TopTitle     = Color3.fromRGB(245,245,255),
    },

    Aqua = {
        Accent       = Color3.fromRGB(80,210,255),
        AccentOn     = Color3.fromRGB(60,200,255),
        AccentText   = Color3.fromRGB(160,240,255),
        RootTop      = Color3.fromRGB(15,25,35),
        RootBottom   = Color3.fromRGB(4,15,22),
        Sidebar      = Color3.fromRGB(10,18,26),
        TopTitle     = Color3.fromRGB(230,240,255),
    },

    Custom = {
        Accent       = CustomAccent,
        AccentOn     = CustomAccent,
        AccentText   = CustomAccent,
        RootTop      = Color3.fromRGB(20,20,26),
        RootBottom   = Color3.fromRGB(5,5,10),
        Sidebar      = Color3.fromRGB(10,10,12),
        TopTitle     = Color3.fromRGB(235,235,240),
    }
}

local currentTheme = "Default"

local function applyTheme(name)
    ThemeConfig.Custom.Accent     = CustomAccent
    ThemeConfig.Custom.AccentOn   = CustomAccent
    ThemeConfig.Custom.AccentText = CustomAccent

    local th = ThemeConfig[name] or ThemeConfig.Default
    currentTheme = name

    rootGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, th.RootTop),
        ColorSequenceKeypoint.new(1, th.RootBottom)
    }

    sidebar.BackgroundColor3      = th.Sidebar
    topTitle.TextColor3           = th.TopTitle
    versionPill.BackgroundColor3  = th.Accent
end

applyTheme("Default")

---------------------------------------------------------------------//
-- CREATE SIDEBAR BUTTON
---------------------------------------------------------------------//
local function createSideButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,100,0,32)
    btn.BackgroundColor3 = Color3.fromRGB(25,25,32)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.fromRGB(230,230,235)
    btn.TextSize = 14
    btn.Text = text
    btn.BorderSizePixel = 0
    btn.Parent = sidebar

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,10)
    c.Parent = btn

    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = ThemeConfig[currentTheme].AccentOn}, 0.14)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(25,25,32)}, 0.14)
    end)

    btn.MouseButton1Click:Connect(callback)
end

---------------------------------------------------------------------//
-- CREATE PAGE
---------------------------------------------------------------------//
local function createPage(name)
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = pageHolder

    pages[name] = page
    return page
end

local function switchPage(name)
    for n, p in pairs(pages) do
        p.Visible = false
    end

    if pages[name] then
        pages[name].Visible = true
        currentPage = name
    end
end

---------------------------------------------------------------------//
-- PAGE REGISTRATION
---------------------------------------------------------------------//
local homePage    = createPage("Home")
local mainPage    = createPage("Main")
local blatantPage = createPage("Blatant")
local othersPage  = createPage("Others")
local settingsPage= createPage("Settings")

createSideButton("Home",    function() switchPage("Home")    end)
createSideButton("Main",    function() switchPage("Main")    end)
createSideButton("Blatant", function() switchPage("Blatant") end)
createSideButton("Others",  function() switchPage("Others")  end)
createSideButton("Settings",function() switchPage("Settings")end)

switchPage("Home") -- default landing page

---------------------------------------------------------------------//
-- UI TOGGLE (RightCtrl)
---------------------------------------------------------------------//
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        guiVisible = not guiVisible
        root.Visible = guiVisible
    end
end)
---------------------------------------------------------------------//
-- PART 3 — HOME PAGE
---------------------------------------------------------------------//

local function makeCard(parent, height)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -40, 0, height)
    f.Position = UDim2.new(0,20,0,0)
    f.BackgroundColor3 = Color3.fromRGB(20,20,28)
    f.BorderSizePixel = 0
    f.ZIndex = 2
    f.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,12)
    corner.Parent = f

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(55,55,65)
    stroke.Parent = f

    return f
end

local function addHeader(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 24)
    lbl.Position = UDim2.new(0,10,0,10)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 18
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 3
    lbl.Parent = parent
end

local function addValue(parent, y, label, value)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,22)
    lbl.Position = UDim2.new(0,10,0,y)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(230,230,235)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = label..":  "..value
    lbl.ZIndex = 3
    lbl.Parent = parent
    return lbl
end

---------------------------------------------------------------------
-- LAYOUT
---------------------------------------------------------------------
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,0,1,0)
scroll.CanvasSize = UDim2.new(0,0,0,525)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.Parent = homePage

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,20)
layout.Parent = scroll

---------------------------------------------------------------------
-- UPDATE BANNER
---------------------------------------------------------------------
local updateBanner = makeCard(scroll, 58)
addHeader(updateBanner, "Version Status")

local updateLabel = addValue(updateBanner, 34, "Status", "Checking...")
updateBanner.Visible = true

task.spawn(function()
    task.wait(1)
    if updateAvailable then
        updateLabel.Text = "Status:  NEW v"..latestVersion.." available!"
    else
        updateLabel.Text = "Status:  Up to date"
    end
end)

---------------------------------------------------------------------
-- PLAYER CARD
---------------------------------------------------------------------
local playerCard = makeCard(scroll, 160)
addHeader(playerCard, "Player Info")

local hwDisplay = tostring(getHWID())
if #hwDisplay > 12 then
    hwDisplay = hwDisplay:sub(1,12) .. "..."
end

addValue(playerCard, 40, "Display Name", displayName)
addValue(playerCard, 64, "Username", userName)
addValue(playerCard, 88, "Exec Count", tostring(getgenv().BinHub_ExecCount))
addValue(playerCard, 112, "HWID", hwDisplay)

---------------------------------------------------------------------
-- SERVER CARD
---------------------------------------------------------------------
local serverCard = makeCard(scroll, 160)
addHeader(serverCard, "Server Info")

local fpsLabel  = addValue(serverCard, 40, "FPS", "Calculating...")
local pingLabel = addValue(serverCard, 64, "Ping", "Calculating...")
local regionLbl = addValue(serverCard, 88, "Region", "Loading...")

task.spawn(function()
    while task.wait(1) do
        -- FPS
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        fpsLabel.Text = "FPS:  "..fps

        -- Ping
        local avg = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        pingLabel.Text = "Ping:  "..math.floor(avg).."ms"
    end
end)

task.spawn(function()
    task.wait(2)
    local ok, region = pcall(function()
        return LocalizationService.RobloxLocaleId or "Unknown"
    end)
    regionLbl.Text = "Region:  "..tostring(region)
end)

---------------------------------------------------------------------
-- GAME CARD
---------------------------------------------------------------------
local gameCard = makeCard(scroll, 160)
addHeader(gameCard, "Game Info")

local gName = getGameName()
addValue(gameCard, 40, "Game", gName)
addValue(gameCard, 64, "PlaceId", tostring(game.PlaceId))
addValue(gameCard, 88, "JobId", tostring(game.JobId))
---------------------------------------------------------------------//
-- PART 4 — MAIN PAGE (AUTO CLICKER / PARRY)
---------------------------------------------------------------------//

-- STATE
local toggleKey        = Enum.KeyCode.E   -- locked main key
local parryKey         = Enum.KeyCode.E   -- locked parry key
local manualKey        = Enum.KeyCode.R   -- rebindable
local mode             = "Toggle"         -- "Toggle" or "Hold"
local actionMode       = "Click"          -- "Click" or "Parry"
local cps              = 10
local clicking         = false
local manualSpamActive = false
local listeningForManual = false

local function keyToString(keycode)
    local s = tostring(keycode)
    return s:match("%.(.+)") or s
end

---------------------------------------------------------------------//
-- MAIN PAGE UI
---------------------------------------------------------------------//
local mainCard = Instance.new("Frame")
mainCard.Size = UDim2.new(1, -40, 0, 220)
mainCard.Position = UDim2.new(0,20,0,20)
mainCard.BackgroundColor3 = Color3.fromRGB(20,20,28)
mainCard.BorderSizePixel = 0
mainCard.ZIndex = 2
mainCard.Parent = mainPage

local mcCorner = Instance.new("UICorner")
mcCorner.CornerRadius = UDim.new(0,12)
mcCorner.Parent = mainCard

local mcStroke = Instance.new("UIStroke")
mcStroke.Thickness = 1
mcStroke.Color = Color3.fromRGB(55,55,65)
mcStroke.Parent = mainCard

local mcTitle = Instance.new("TextLabel")
mcTitle.Size = UDim2.new(1,-20,0,24)
mcTitle.Position = UDim2.new(0,10,0,10)
mcTitle.BackgroundTransparency = 1
mcTitle.Font = Enum.Font.GothamBlack
mcTitle.TextSize = 18
mcTitle.TextColor3 = Color3.fromRGB(255,255,255)
mcTitle.TextXAlignment = Enum.TextXAlignment.Left
mcTitle.Text = "Main Control"
mcTitle.ZIndex = 3
mcTitle.Parent = mainCard

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,-20,0,22)
statusLabel.Position = UDim2.new(0,10,0,38)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextColor3 = Color3.fromRGB(255,90,90)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "Status: OFF (10 CPS, Toggle, Click, Key: E)"
statusLabel.ZIndex = 3
statusLabel.Parent = mainCard

-- CPS LABEL
local cpsLabel = Instance.new("TextLabel")
cpsLabel.Size = UDim2.new(0,60,0,22)
cpsLabel.Position = UDim2.new(0,10,0,72)
cpsLabel.BackgroundTransparency = 1
cpsLabel.Font = Enum.Font.Gotham
cpsLabel.TextSize = 14
cpsLabel.TextColor3 = Color3.fromRGB(230,230,235)
cpsLabel.TextXAlignment = Enum.TextXAlignment.Left
cpsLabel.Text = "CPS:"
cpsLabel.ZIndex = 3
cpsLabel.Parent = mainCard

local cpsBox = Instance.new("TextBox")
cpsBox.Size = UDim2.new(0,60,0,24)
cpsBox.Position = UDim2.new(0,65,0,72)
cpsBox.BackgroundColor3 = Color3.fromRGB(26,26,34)
cpsBox.BorderSizePixel = 0
cpsBox.Font = Enum.Font.Gotham
cpsBox.TextSize = 14
cpsBox.TextColor3 = Color3.fromRGB(255,255,255)
cpsBox.ClearTextOnFocus = false
cpsBox.Text = "10"
cpsBox.ZIndex = 3
cpsBox.Parent = mainCard

local cpsCorner = Instance.new("UICorner")
cpsCorner.CornerRadius = UDim.new(0,8)
cpsCorner.Parent = cpsBox

-- MODE BUTTON
local modeLabel = cpsLabel:Clone()
modeLabel.Position = UDim2.new(0,10,0,104)
modeLabel.Text = "Mode:"
modeLabel.Parent = mainCard

local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0,80,0,24)
modeBtn.Position = UDim2.new(0,65,0,104)
modeBtn.BackgroundColor3 = Color3.fromRGB(26,26,34)
modeBtn.BorderSizePixel = 0
modeBtn.Font = Enum.Font.GothamSemibold
modeBtn.TextSize = 14
modeBtn.TextColor3 = Color3.fromRGB(255,255,255)
modeBtn.Text = mode
modeBtn.ZIndex = 3
modeBtn.Parent = mainCard

local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0,8)
modeCorner.Parent = modeBtn

-- ACTION BUTTON
local actionLabel = cpsLabel:Clone()
actionLabel.Position = UDim2.new(0,10,0,136)
actionLabel.Text = "Action:"
actionLabel.Parent = mainCard

local actionBtn = Instance.new("TextButton")
actionBtn.Size = UDim2.new(0,80,0,24)
actionBtn.Position = UDim2.new(0,65,0,136)
actionBtn.BackgroundColor3 = Color3.fromRGB(26,26,34)
actionBtn.BorderSizePixel = 0
actionBtn.Font = Enum.Font.GothamSemibold
actionBtn.TextSize = 14
actionBtn.TextColor3 = Color3.fromRGB(255,255,255)
actionBtn.Text = actionMode
actionBtn.ZIndex = 3
actionBtn.Parent = mainCard

local actionCorner = Instance.new("UICorner")
actionCorner.CornerRadius = UDim.new(0,8)
actionCorner.Parent = actionBtn

-- MANUAL SPAM KEY
local manualLabel = cpsLabel:Clone()
manualLabel.Position = UDim2.new(0,180,0,72)
manualLabel.Text = "Manual:"
manualLabel.Parent = mainCard

local manualBtn = Instance.new("TextButton")
manualBtn.Size = UDim2.new(0,70,0,24)
manualBtn.Position = UDim2.new(0,245,0,72)
manualBtn.BackgroundColor3 = Color3.fromRGB(26,26,34)
manualBtn.BorderSizePixel = 0
manualBtn.Font = Enum.Font.GothamSemibold
manualBtn.TextSize = 14
manualBtn.TextColor3 = Color3.fromRGB(255,255,255)
manualBtn.Text = keyToString(manualKey)
manualBtn.ZIndex = 3
manualBtn.Parent = mainCard

local manualCorner = Instance.new("UICorner")
manualCorner.CornerRadius = UDim.new(0,8)
manualCorner.Parent = manualBtn

-- INFO LINE
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1,-20,0,22)
infoLabel.Position = UDim2.new(0,10,0,168)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.TextColor3 = Color3.fromRGB(190,190,200)
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Text = "E = main toggle key (locked). Manual key is rebindable."
infoLabel.ZIndex = 3
infoLabel.Parent = mainCard

-- START / STOP BUTTON
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0, 150, 0, 32)
startBtn.Position = UDim2.new(1, -160, 1, -42)
startBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
startBtn.BorderSizePixel = 0
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 16
startBtn.TextColor3 = Color3.fromRGB(255,255,255)
startBtn.Text = "Start"
startBtn.ZIndex = 3
startBtn.Parent = mainCard

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0,10)
sbCorner.Parent = startBtn

---------------------------------------------------------------------//
-- MAIN LOGIC HELPERS
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
    local n = getCPS()
    local onOff = clicking and "ON" or "OFF"
    local col = clicking and Color3.fromRGB(120,255,120) or Color3.fromRGB(255,90,90)

    statusLabel.Text = string.format(
        "Status: %s (%d CPS, %s, %s, Key: %s)",
        onOff,
        n,
        mode,
        actionMode,
        keyToString(toggleKey)
    )
    statusLabel.TextColor3 = col
end

local function setClicking(state)
    if state == clicking then return end
    clicking = state

    if clicking then
        startBtn.Text = "Stop"
        tween(startBtn, {BackgroundColor3 = ThemeConfig[currentTheme].AccentOn}, 0.16)
    else
        startBtn.Text = "Start"
        tween(startBtn, {BackgroundColor3 = Color3.fromRGB(60,60,70)}, 0.16)
    end

    updateStatus()
end

---------------------------------------------------------------------//
-- BUTTON CALLBACKS
---------------------------------------------------------------------//
startBtn.MouseButton1Click:Connect(function()
    setClicking(not clicking)
end)

cpsBox.FocusLost:Connect(function()
    updateStatus()
end)

modeBtn.MouseButton1Click:Connect(function()
    mode = (mode == "Toggle") and "Hold" or "Toggle"
    modeBtn.Text = mode
    updateStatus()
end)

actionBtn.MouseButton1Click:Connect(function()
    actionMode = (actionMode == "Click") and "Parry" or "Click"
    actionBtn.Text = actionMode
    updateStatus()
end)

manualBtn.MouseButton1Click:Connect(function()
    if listeningForManual then return end
    listeningForManual = true
    infoLabel.Text = "Press a key to set Manual Spam."
    tween(manualBtn, {BackgroundColor3 = Color3.fromRGB(90,90,110)}, 0.12)
end)

---------------------------------------------------------------------//
-- INPUT HANDLING
---------------------------------------------------------------------//
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    -- capture manual key
    if listeningForManual then
        listeningForManual = false
        manualKey = input.KeyCode
        manualBtn.Text = keyToString(manualKey)
        infoLabel.Text = "Manual spam key set to: "..manualBtn.Text
        tween(manualBtn, {BackgroundColor3 = Color3.fromRGB(26,26,34)}, 0.12)
        return
    end

    -- main toggle
    if input.KeyCode == toggleKey then
        if mode == "Toggle" then
            setClicking(not clicking)
        else
            setClicking(true)
        end
        return
    end

    -- manual spam
    if input.KeyCode == manualKey then
        manualSpamActive = true
    end
end)

UIS.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    if input.KeyCode == toggleKey and mode == "Hold" then
        setClicking(false)
    end

    if input.KeyCode == manualKey then
        manualSpamActive = false
    end
end)

---------------------------------------------------------------------//
-- MAIN SPAM LOOP
---------------------------------------------------------------------//
task.spawn(function()
    while true do
        if clicking or manualSpamActive then
            local delay = 1 / getCPS()
            if delay < 0.001 then delay = 0.001 end

            -- MAIN CLICKER (E key)
            if clicking then
                if actionMode == "Click" then
                    if VIM then
                        pcall(function()
                            VIM:SendMouseButtonEvent(0,0,0,true,game,0)
                            task.wait(0.01)
                            VIM:SendMouseButtonEvent(0,0,0,false,game,0)
                        end)
                    elseif mouse1click then
                        pcall(mouse1click)
                    end
                else
                    if VIM then
                        pcall(function()
                            VIM:SendKeyEvent(true, parryKey, false, game)
                            task.wait(0.01)
                            VIM:SendKeyEvent(false, parryKey, false, game)
                        end)
                    end
                end
            end

            -- MANUAL SPAM (custom key)
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

updateStatus()
---------------------------------------------------------------------//
-- PART 5 — BLATANT PAGE (SPEED & JUMP BOOSTS)
---------------------------------------------------------------------//

local speedEnabled      = false
local jumpEnabled       = false
local speedValue        = 20
local jumpValue         = 50
local originalWalkSpeed = nil
local originalJumpPower = nil

local blatantScroll = Instance.new("ScrollingFrame")
blatantScroll.Size = UDim2.new(1,0,1,0)
blatantScroll.CanvasSize = UDim2.new(0,0,0,260)
blatantScroll.BackgroundTransparency = 1
blatantScroll.BorderSizePixel = 0
blatantScroll.ScrollBarThickness = 4
blatantScroll.Parent = blatantPage

local bLayout = Instance.new("UIListLayout")
bLayout.SortOrder = Enum.SortOrder.LayoutOrder
bLayout.Padding = UDim.new(0,16)
bLayout.Parent = blatantScroll

local function createBlatantCard(height)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-40,0,height)
    f.BackgroundColor3 = Color3.fromRGB(20,20,28)
    f.BorderSizePixel = 0
    f.ZIndex = 2
    f.Parent = blatantScroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,12)
    c.Parent = f

    local s = Instance.new("UIStroke")
    s.Thickness = 1
    s.Color = Color3.fromRGB(55,55,65)
    s.Parent = f

    return f
end

local function addTitleDesc(parent, title, desc)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,-20,0,22)
    t.Position = UDim2.new(0,10,0,10)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamSemibold
    t.TextSize = 16
    t.TextColor3 = Color3.fromRGB(255,255,255)
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Text = title
    t.ZIndex = 3
    t.Parent = parent

    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1,-20,0,32)
    d.Position = UDim2.new(0,10,0,32)
    d.BackgroundTransparency = 1
    d.Font = Enum.Font.Gotham
    d.TextSize = 12
    d.TextWrapped = true
    d.TextYAlignment = Enum.TextYAlignment.Top
    d.TextColor3 = Color3.fromRGB(200,200,210)
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.Text = desc
    d.ZIndex = 3
    d.Parent = parent

    return t, d
end

local function makeToggle(parent, x, y)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,42,0,20)
    frame.Position = UDim2.new(0,x,0,y)
    frame.BackgroundColor3 = Color3.fromRGB(40,40,50)
    frame.BorderSizePixel = 0
    frame.ZIndex = 3
    frame.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1,0)
    c.Parent = frame

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0,16,0,16)
    thumb.Position = UDim2.new(0,2,0.5,-8)
    thumb.BackgroundColor3 = Color3.fromRGB(80,80,90)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 4
    thumb.Parent = frame

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1,0)
    tc.Parent = thumb

    return frame, thumb
end

local function makeSlider(parent, y, minVal, maxVal, initial, onChanged)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-40,0,6)
    bar.Position = UDim2.new(0,10,0,y)
    bar.BackgroundColor3 = Color3.fromRGB(35,35,44)
    bar.BorderSizePixel = 0
    bar.ZIndex = 3
    bar.Parent = parent

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0,6)
    bc.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = ThemeConfig[currentTheme].AccentOn
    fill.BorderSizePixel = 0
    fill.ZIndex = 4
    fill.Parent = bar

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0,6)
    fc.Parent = fill

    local dragging = false
    local value = initial or minVal

    local function setFromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = minVal + (maxVal - minVal) * rel
        v = math.floor(v + 0.5)
        value = v
        tween(fill, {Size = UDim2.new(rel,0,1,0)}, 0.08)
        if onChanged then
            onChanged(v)
        end
    end

    bar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setFromX(inp.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(inp.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- init pos
    local relInit = (initial - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(math.clamp(relInit,0,1),0,1,0)

    return {
        bar = bar,
        fill = fill,
        getValue = function() return value end,
    }
end

---------------------------------------------------------------------//
-- SPEED CARD
---------------------------------------------------------------------//
local speedCard = createBlatantCard(120)
local spTitle, spDesc = addTitleDesc(
    speedCard,
    "Speed Boost",
    "Boost your WalkSpeed (visual only on some games). Toggle must be ON to apply. When OFF, your speed resets to game default."
)

local speedValueLabel = Instance.new("TextLabel")
speedValueLabel.Size = UDim2.new(0,60,0,20)
speedValueLabel.Position = UDim2.new(1,-70,0,10)
speedValueLabel.BackgroundTransparency = 1
speedValueLabel.Font = Enum.Font.Gotham
speedValueLabel.TextSize = 12
speedValueLabel.TextColor3 = Color3.fromRGB(220,220,230)
speedValueLabel.TextXAlignment = Enum.TextXAlignment.Right
speedValueLabel.Text = tostring(speedValue)
speedValueLabel.ZIndex = 3
speedValueLabel.Parent = speedCard

local speedToggleFrame, speedThumb = makeToggle(speedCard, speedCard.AbsoluteSize.X - 60, 10)
-- We'll reposition properly once AbsoluteSize known:
speedCard:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    speedToggleFrame.Position = UDim2.new(1,-54,0,10)
end)

local function updateSpeedToggleVisual()
    if speedEnabled then
        tween(speedToggleFrame, {BackgroundColor3 = ThemeConfig[currentTheme].AccentOn}, 0.12)
        tween(speedThumb, {Position = UDim2.new(1,-18,0.5,-8)}, 0.12)
    else
        tween(speedToggleFrame, {BackgroundColor3 = Color3.fromRGB(40,40,50)}, 0.12)
        tween(speedThumb, {Position = UDim2.new(0,2,0.5,-8)}, 0.12)
    end
end

local function applySpeed()
    if not speedEnabled then return end
    local hum = getHumanoid()
    if not hum then return end

    if not originalWalkSpeed then
        originalWalkSpeed = hum.WalkSpeed
    end

    hum.WalkSpeed = speedValue
end

local function resetSpeed()
    local hum = getHumanoid()
    if hum and originalWalkSpeed ~= nil then
        hum.WalkSpeed = originalWalkSpeed
    end
end

local speedSlider = makeSlider(speedCard, 68, 10, 100, speedValue, function(v)
    speedValue = v
    speedValueLabel.Text = tostring(v)
    if speedEnabled then
        applySpeed()
    end
end)

speedToggleFrame.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        speedEnabled = not speedEnabled
        updateSpeedToggleVisual()
        if speedEnabled then
            applySpeed()
        else
            resetSpeed()
        end
    end
end)

updateSpeedToggleVisual()

---------------------------------------------------------------------//
-- JUMP CARD
---------------------------------------------------------------------//
local jumpCard = createBlatantCard(120)
local jpTitle, jpDesc = addTitleDesc(
    jumpCard,
    "Jump Boost",
    "Boost your JumpPower. Toggle must be ON to apply. When OFF, jump resets to game default."
)

local jumpValueLabel = Instance.new("TextLabel")
jumpValueLabel.Size = UDim2.new(0,60,0,20)
jumpValueLabel.Position = UDim2.new(1,-70,0,10)
jumpValueLabel.BackgroundTransparency = 1
jumpValueLabel.Font = Enum.Font.Gotham
jumpValueLabel.TextSize = 12
jumpValueLabel.TextColor3 = Color3.fromRGB(220,220,230)
jumpValueLabel.TextXAlignment = Enum.TextXAlignment.Right
jumpValueLabel.Text = tostring(jumpValue)
jumpValueLabel.ZIndex = 3
jumpValueLabel.Parent = jumpCard

local jumpToggleFrame, jumpThumb = makeToggle(jumpCard, jumpCard.AbsoluteSize.X - 60, 10)
jumpCard:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    jumpToggleFrame.Position = UDim2.new(1,-54,0,10)
end)

local function updateJumpToggleVisual()
    if jumpEnabled then
        tween(jumpToggleFrame, {BackgroundColor3 = ThemeConfig[currentTheme].AccentOn}, 0.12)
        tween(jumpThumb, {Position = UDim2.new(1,-18,0.5,-8)}, 0.12)
    else
        tween(jumpToggleFrame, {BackgroundColor3 = Color3.fromRGB(40,40,50)}, 0.12)
        tween(jumpThumb, {Position = UDim2.new(0,2,0.5,-8)}, 0.12)
    end
end

local function applyJump()
    if not jumpEnabled then return end
    local hum = getHumanoid()
    if not hum then return end

    if hum.UseJumpPower ~= nil then
        hum.UseJumpPower = true
    end

    if not originalJumpPower then
        originalJumpPower = hum.JumpPower
    end

    hum.JumpPower = jumpValue
end

local function resetJump()
    local hum = getHumanoid()
    if hum and originalJumpPower ~= nil then
        hum.JumpPower = originalJumpPower
    end
end

local jumpSlider = makeSlider(jumpCard, 68, 25, 150, jumpValue, function(v)
    jumpValue = v
    jumpValueLabel.Text = tostring(v)
    if jumpEnabled then
        applyJump()
    end
end)

jumpToggleFrame.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        jumpEnabled = not jumpEnabled
        updateJumpToggleVisual()
        if jumpEnabled then
            applyJump()
        else
            resetJump()
        end
    end
end)

updateJumpToggleVisual()

---------------------------------------------------------------------//
-- HANDLE RESPAWN (reapply or reset on new character)
---------------------------------------------------------------------//
LocalPlayer.CharacterAdded:Connect(function()
    originalWalkSpeed = nil
    originalJumpPower = nil

    -- reapply only if toggles ON
    task.delay(1.5, function()
        if speedEnabled then
            applySpeed()
        end
        if jumpEnabled then
            applyJump()
        end
    end)
end)
---------------------------------------------------------------------//
-- PART 6 — OTHERS PAGE (BUG REPORT + ANTI AFK + UPDATER UI)
---------------------------------------------------------------------//

local othersScroll = Instance.new("ScrollingFrame")
othersScroll.Size = UDim2.new(1,0,1,0)
othersScroll.CanvasSize = UDim2.new(0,0,0,260)
othersScroll.BackgroundTransparency = 1
othersScroll.BorderSizePixel = 0
othersScroll.ScrollBarThickness = 4
othersScroll.Parent = othersPage

local oLayout = Instance.new("UIListLayout")
oLayout.SortOrder = Enum.SortOrder.LayoutOrder
oLayout.Padding = UDim.new(0,16)
oLayout.Parent = othersScroll

local function createOthersCard(height)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-40,0,height)
    f.BackgroundColor3 = Color3.fromRGB(20,20,28)
    f.BorderSizePixel = 0
    f.ZIndex = 2
    f.Parent = othersScroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,12)
    c.Parent = f

    local s = Instance.new("UIStroke")
    s.Thickness = 1
    s.Color = Color3.fromRGB(55,55,65)
    s.Parent = f

    return f
end

local function addCardTitle(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,22)
    lbl.Position = UDim2.new(0,10,0,10)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 16
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 3
    lbl.Parent = parent
    return lbl
end

local function addCardDesc(parent, y, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,32)
    lbl.Position = UDim2.new(0,10,0,y)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextWrapped = true
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.TextColor3 = Color3.fromRGB(200,200,210)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 3
    lbl.Parent = parent
    return lbl
end

local function makeSmallToggle(parent, x, y)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,42,0,20)
    frame.Position = UDim2.new(0,x,0,y)
    frame.BackgroundColor3 = Color3.fromRGB(40,40,50)
    frame.BorderSizePixel = 0
    frame.ZIndex = 3
    frame.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1,0)
    c.Parent = frame

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0,16,0,16)
    thumb.Position = UDim2.new(0,2,0.5,-8)
    thumb.BackgroundColor3 = Color3.fromRGB(80,80,90)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 4
    thumb.Parent = frame

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1,0)
    tc.Parent = thumb

    return frame, thumb
end

---------------------------------------------------------------------//
-- BUG REPORT CARD
---------------------------------------------------------------------//
local bugCard = createOthersCard(190)
addCardTitle(bugCard, "Bug Report")

addCardDesc(
    bugCard,
    32,
    "Found something broken? Describe it below. This will be sent straight to the dev webhook with your player + exec info."
)

local bugBox = Instance.new("TextBox")
bugBox.Size = UDim2.new(1,-20,0,80)
bugBox.Position = UDim2.new(0,10,0,70)
bugBox.BackgroundColor3 = Color3.fromRGB(26,26,34)
bugBox.BorderSizePixel = 0
bugBox.Font = Enum.Font.Gotham
bugBox.TextSize = 14
bugBox.TextColor3 = Color3.fromRGB(255,255,255)
bugBox.TextWrapped = true
bugBox.TextYAlignment = Enum.TextYAlignment.Top
bugBox.ClearTextOnFocus = false
bugBox.MultiLine = true
bugBox.PlaceholderText = "Explain what happened, what you were doing, and any error messages..."
bugBox.ZIndex = 3
bugBox.Parent = bugCard

local bugCorner = Instance.new("UICorner")
bugCorner.CornerRadius = UDim.new(0,8)
bugCorner.Parent = bugBox

local sendBugBtn = Instance.new("TextButton")
sendBugBtn.Size = UDim2.new(0,120,0,28)
sendBugBtn.Position = UDim2.new(0,10,0,160)
sendBugBtn.BackgroundColor3 = ThemeConfig[currentTheme].AccentOn
sendBugBtn.BorderSizePixel = 0
sendBugBtn.Font = Enum.Font.GothamBold
sendBugBtn.TextSize = 14
sendBugBtn.TextColor3 = Color3.fromRGB(255,255,255)
sendBugBtn.Text = "Send Report"
sendBugBtn.ZIndex = 3
sendBugBtn.Parent = bugCard

local sbc = Instance.new("UICorner")
sbc.CornerRadius = UDim.new(0,8)
sbc.Parent = sendBugBtn

local bugStatus = Instance.new("TextLabel")
bugStatus.Size = UDim2.new(1,-140,0,22)
bugStatus.Position = UDim2.new(0,140,0,164)
bugStatus.BackgroundTransparency = 1
bugStatus.Font = Enum.Font.Gotham
bugStatus.TextSize = 12
bugStatus.TextColor3 = Color3.fromRGB(190,190,200)
bugStatus.TextXAlignment = Enum.TextXAlignment.Left
bugStatus.Text = ""
bugStatus.ZIndex = 3
bugStatus.Parent = bugCard

sendBugBtn.MouseButton1Click:Connect(function()
    local txt = bugBox.Text or ""
    if txt:gsub("%s+","") == "" then
        bugStatus.TextColor3 = Color3.fromRGB(255,120,120)
        bugStatus.Text = "Type something first."
        return
    end

    bugStatus.TextColor3 = Color3.fromRGB(200,200,210)
    bugStatus.Text = "Sending..."

    task.spawn(function()
        local ok, err = sendBugReport(txt)
        if ok then
            bugBox.Text = ""
            bugStatus.TextColor3 = Color3.fromRGB(120,220,120)
            bugStatus.Text = "Bug sent!"
        else
            bugStatus.TextColor3 = Color3.fromRGB(255,120,120)
            bugStatus.Text = "Failed to send ("..tostring(err or "unknown")..")"
        end
    end)
end)

---------------------------------------------------------------------//
-- SYSTEM CARD (ANTI AFK + AUTO UPDATER UI)
---------------------------------------------------------------------//
local sysCard = createOthersCard(150)
addCardTitle(sysCard, "System Tools")

local aaDesc = addCardDesc(
    sysCard,
    32,
    "Anti-AFK: prevents Roblox from kicking you for being idle. Only moves your camera slightly when needed."
)

local antiLabel = Instance.new("TextLabel")
antiLabel.Size = UDim2.new(0,100,0,20)
antiLabel.Position = UDim2.new(0,10,0,80)
antiLabel.BackgroundTransparency = 1
antiLabel.Font = Enum.Font.Gotham
antiLabel.TextSize = 13
antiLabel.TextColor3 = Color3.fromRGB(220,220,230)
antiLabel.TextXAlignment = Enum.TextXAlignment.Left
antiLabel.Text = "Anti-AFK:"
antiLabel.ZIndex = 3
antiLabel.Parent = sysCard

local antiToggleFrame, antiThumb = makeSmallToggle(sysCard, 90, 80)

local function updateAntiVisual()
    if antiAfkOn then
        tween(antiToggleFrame, {BackgroundColor3 = ThemeConfig[currentTheme].AccentOn}, 0.12)
        tween(antiThumb, {Position = UDim2.new(1,-18,0.5,-8)}, 0.12)
    else
        tween(antiToggleFrame, {BackgroundColor3 = Color3.fromRGB(40,40,50)}, 0.12)
        tween(antiThumb, {Position = UDim2.new(0,2,0.5,-8)}, 0.12)
    end
end

antiToggleFrame.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        antiAfkOn = not antiAfkOn
        updateAntiVisual()
    end
end)

updateAntiVisual()

-- AUTO UPDATER PART
local updLabel = Instance.new("TextLabel")
updLabel.Size = UDim2.new(1,-20,0,20)
updLabel.Position = UDim2.new(0,10,0,110)
updLabel.BackgroundTransparency = 1
updLabel.Font = Enum.Font.Gotham
updLabel.TextSize = 12
updLabel.TextColor3 = Color3.fromRGB(200,200,210)
updLabel.TextXAlignment = Enum.TextXAlignment.Left
updLabel.Text = "Updater: checking..."
updLabel.ZIndex = 3
updLabel.Parent = sysCard

local updBtn = Instance.new("TextButton")
updBtn.Size = UDim2.new(0,120,0,24)
updBtn.Position = UDim2.new(1,-130,0,108)
updBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
updBtn.BorderSizePixel = 0
updBtn.Font = Enum.Font.GothamBold
updBtn.TextSize = 13
updBtn.TextColor3 = Color3.fromRGB(255,255,255)
updBtn.Text = "Check Update"
updBtn.ZIndex = 3
updBtn.Parent = sysCard

local ubc = Instance.new("UICorner")
ubc.CornerRadius = UDim.new(0,8)
ubc.Parent = updBtn

-- make sure we actually check in background
task.spawn(function()
    -- soft call, safe if URL is placeholder
    pcall(checkForUpdate)
    task.wait(1.5)

    if updateAvailable then
        updLabel.Text = "Updater: NEW v"..latestVersion.." available."
        updBtn.Text = "Update Now"
        tween(updBtn, {BackgroundColor3 = ThemeConfig[currentTheme].AccentOn}, 0.14)
    else
        updLabel.Text = "Updater: You are on v"..CURRENT_VERSION.."."
    end
end)

updBtn.MouseButton1Click:Connect(function()
    if not updateAvailable then
        -- re-check manually
        updLabel.Text = "Updater: checking..."
        task.spawn(function()
            pcall(checkForUpdate)
            task.wait(1.5)
            if updateAvailable then
                updLabel.Text = "Updater: NEW v"..latestVersion.." available."
                updBtn.Text = "Update Now"
                tween(updBtn, {BackgroundColor3 = ThemeConfig[currentTheme].AccentOn}, 0.14)
            else
                updLabel.Text = "Updater: still on latest."
            end
        end)
        return
    end

    -- if available, try auto-run loadstring
    updLabel.Text = "Updater: loading new version..."
    task.spawn(function()
        local ok, err = pcall(function()
            loadstring(UPDATE_LOADSTRING)()
        end)
        if ok then
            updLabel.Text = "Updater: update executed."
        else
            updLabel.Text = "Updater: failed ("..tostring(err or "error")..")"
        end
    end)
end)
---------------------------------------------------------------------//
-- PART 7 — SETTINGS PAGE (THEMES + CUSTOM ACCENT)
---------------------------------------------------------------------//

-- fallback in case CustomAccent wasn't defined earlier
CustomAccent = CustomAccent or Color3.fromRGB(255,140,0)

local settingsScroll = Instance.new("ScrollingFrame")
settingsScroll.Size = UDim2.new(1,0,1,0)
settingsScroll.CanvasSize = UDim2.new(0,0,0,220)
settingsScroll.BackgroundTransparency = 1
settingsScroll.BorderSizePixel = 0
settingsScroll.ScrollBarThickness = 4
settingsScroll.Parent = settingsPage

local sLayout = Instance.new("UIListLayout")
sLayout.SortOrder = Enum.SortOrder.LayoutOrder
sLayout.Padding = UDim.new(0,16)
sLayout.Parent = settingsScroll

local function createSettingsCard(height)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-40,0,height)
    f.BackgroundColor3 = Color3.fromRGB(20,20,28)
    f.BorderSizePixel = 0
    f.ZIndex = 2
    f.Parent = settingsScroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,12)
    c.Parent = f

    local s = Instance.new("UIStroke")
    s.Thickness = 1
    s.Color = Color3.fromRGB(55,55,65)
    s.Parent = f

    return f
end

local function addSettingsTitle(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,22)
    lbl.Position = UDim2.new(0,10,0,10)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 16
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 3
    lbl.Parent = parent
    return lbl
end

local function addSettingsDesc(parent, y, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,32)
    lbl.Position = UDim2.new(0,10,0,y)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextWrapped = true
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.TextColor3 = Color3.fromRGB(200,200,210)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 3
    lbl.Parent = parent
    return lbl
end

---------------------------------------------------------------------//
-- THEME CARD
---------------------------------------------------------------------//
local themeCard = createSettingsCard(170)
addSettingsTitle(themeCard, "Theme & Appearance")

addSettingsDesc(
    themeCard,
    32,
    "Pick a preset or use your own accent color.\nCustom accent updates the whole hub."
)

local presetLabel = Instance.new("TextLabel")
presetLabel.Size = UDim2.new(1,-20,0,18)
presetLabel.Position = UDim2.new(0,10,0,68)
presetLabel.BackgroundTransparency = 1
presetLabel.Font = Enum.Font.Gotham
presetLabel.TextSize = 12
presetLabel.TextColor3 = Color3.fromRGB(210,210,220)
presetLabel.TextXAlignment = Enum.TextXAlignment.Left
presetLabel.Text = "Presets:"
presetLabel.ZIndex = 3
presetLabel.Parent = themeCard

local function makePresetButton(txt, x, themeName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,70,0,24)
    btn.Position = UDim2.new(0,x,0,90)
    btn.BackgroundColor3 = Color3.fromRGB(26,26,34)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(230,230,235)
    btn.Text = txt
    btn.ZIndex = 3
    btn.Parent = themeCard

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,8)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        applyTheme(themeName)
    end)
end

makePresetButton("Default", 10,  "Default")
makePresetButton("Purple",  90,  "Purple")
makePresetButton("Aqua",    170, "Aqua")
makePresetButton("Custom",  250, "Custom")

---------------------------------------------------------------------//
-- CUSTOM ACCENT RGB
---------------------------------------------------------------------//
local rgbLabel = Instance.new("TextLabel")
rgbLabel.Size = UDim2.new(1,-20,0,18)
rgbLabel.Position = UDim2.new(0,10,0,122)
rgbLabel.BackgroundTransparency = 1
rgbLabel.Font = Enum.Font.Gotham
rgbLabel.TextSize = 12
rgbLabel.TextColor3 = Color3.fromRGB(210,210,220)
rgbLabel.TextXAlignment = Enum.TextXAlignment.Left
rgbLabel.Text = "Custom Accent (RGB 0–255):"
rgbLabel.ZIndex = 3
rgbLabel.Parent = themeCard

local function makeRGBBox(x, placeholder)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0,46,0,22)
    box.Position = UDim2.new(0,x,0,142)
    box.BackgroundColor3 = Color3.fromRGB(26,26,34)
    box.BorderSizePixel = 0
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.PlaceholderText = placeholder
    box.ClearTextOnFocus = false
    box.ZIndex = 3
    box.Parent = themeCard

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,6)
    c.Parent = box

    return box
end

local rBox = makeRGBBox(10,  "R")
local gBox = makeRGBBox(62,  "G")
local bBox = makeRGBBox(114, "B")

local applyRGBBtn = Instance.new("TextButton")
applyRGBBtn.Size = UDim2.new(0,90,0,22)
applyRGBBtn.Position = UDim2.new(0,170,0,142)
applyRGBBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
applyRGBBtn.BorderSizePixel = 0
applyRGBBtn.Font = Enum.Font.GothamBold
applyRGBBtn.TextSize = 13
applyRGBBtn.TextColor3 = Color3.fromRGB(255,255,255)
applyRGBBtn.Text = "Apply"
applyRGBBtn.ZIndex = 3
applyRGBBtn.Parent = themeCard

local rgbCorner = Instance.new("UICorner")
rgbCorner.CornerRadius = UDim.new(0,6)
rgbCorner.Parent = applyRGBBtn

local rgbStatus = Instance.new("TextLabel")
rgbStatus.Size = UDim2.new(1,-270,0,20)
rgbStatus.Position = UDim2.new(0,270,0,142)
rgbStatus.BackgroundTransparency = 1
rgbStatus.Font = Enum.Font.Gotham
rgbStatus.TextSize = 11
rgbStatus.TextColor3 = Color3.fromRGB(190,190,200)
rgbStatus.TextXAlignment = Enum.TextXAlignment.Left
rgbStatus.Text = ""
rgbStatus.ZIndex = 3
rgbStatus.Parent = themeCard

local function applyCustomRGB()
    local r = tonumber(rBox.Text)
    local g = tonumber(gBox.Text)
    local b = tonumber(bBox.Text)

    if not r or not g or not b then
        rgbStatus.TextColor3 = Color3.fromRGB(255,120,120)
        rgbStatus.Text = "Enter numbers."
        return
    end

    r = math.clamp(math.floor(r + 0.5),0,255)
    g = math.clamp(math.floor(g + 0.5),0,255)
    b = math.clamp(math.floor(b + 0.5),0,255)

    CustomAccent = Color3.fromRGB(r,g,b)
    rgbStatus.TextColor3 = Color3.fromRGB(120,220,120)
    rgbStatus.Text = "Applied."

    -- refresh theme config + switch to Custom
    applyTheme("Custom")
end

applyRGBBtn.MouseButton1Click:Connect(applyCustomRGB)

---------------------------------------------------------------------//
-- INFO CARD (SMALL)
---------------------------------------------------------------------//
local infoCard = createSettingsCard(90)
addSettingsTitle(infoCard, "Info")

local infoLabel2 = addSettingsDesc(
    infoCard,
    32,
    "RightCtrl = show / hide hub.\nTikTok: "..tostring(TIKTOK_HANDLE)
)
---------------------------------------------------------------------//
-- PART 8 — ANTI-AFK LOOP + FINAL INIT
---------------------------------------------------------------------//

-- ANTI AFK LOOP (TIED TO antiAfkOn)
if not getgenv().__BinHub_AntiAfkHooked then
    getgenv().__BinHub_AntiAfkHooked = true

    task.spawn(function()
        local vu
        pcall(function()
            vu = game:GetService("VirtualUser")
        end)

        if LocalPlayer then
            LocalPlayer.Idled:Connect(function()
                if not antiAfkOn then return end
                pcall(function()
                    if vu then
                        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                        task.wait(0.1)
                        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    end
                end)
            end)
        end
    end)
end

---------------------------------------------------------------------//
-- EXECUTION LOG (WEBHOOK) ON SCRIPT RUN
---------------------------------------------------------------------//

task.spawn(function()
    -- tiny delay to let executor / services finish
    task.wait(1)

    local ok, err = pcall(function()
        sendWebhookLog()
    end)

    if not ok then
        warn("[BinHubX] Failed to send execution log: "..tostring(err))
    end
end)
