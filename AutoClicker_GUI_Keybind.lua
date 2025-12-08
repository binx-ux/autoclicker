-- Bin Hub X - Argon-style Hub v3.4.1
-- RightCtrl = Show/Hide hub

---------------------------------------------------------------------//
-- SERVICES / SETUP
---------------------------------------------------------------------//
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local CoreGui      = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local HttpService  = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalizationService = game:GetService("LocalizationService")

local VIM
pcall(function()
    VIM = game:GetService("VirtualInputManager")
end)

local Lighting    = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local displayName = (LocalPlayer and LocalPlayer.DisplayName) or "Player"
local userName    = (LocalPlayer and LocalPlayer.Name)        or "Unknown"

local TIKTOK_HANDLE = "@binxix"

---------------------------------------------------------------------//
-- UNIVERSAL WEBHOOK (HWID + EXECUTION COUNTER + FPS/PING/REGION)
---------------------------------------------------------------------//

local WEBHOOK_URL = "https://discord.com/api/webhooks/1446656470287651050/ayflCl7nEQ3388YhXAZT7r3j5kTC40EP3WV9yO1BehR2vzHbtoDArV-YejWn_E_F6eUk"

-- Universal Request
local function GetRequest()
    return (syn and syn.request)
        or (fluxus and fluxus.request)
        or (krnl and krnl.request)
        or request
        or http_request
        or (http and http.request)
        or nil
end

local function Debug(msg)
    print("[BinHubX Webhook] " .. tostring(msg))
end

-- Executor + Version
local function GetExecutorInfo()
    local name, ver = "Unknown", "Unknown"

    pcall(function()
        if identifyexecutor then
            local n, v = identifyexecutor()
            name = tostring(n)
            ver = tostring(v or "Unknown")
        end
    end)

    pcall(function()
        if getexecutorname then
            name = tostring(getexecutorname())
        end
    end)

    return name, ver
end

-- HWID
local function GetHWID()
    local hwid = "Unknown"

    pcall(function()
        if syn and syn.get_hwid then hwid = syn.get_hwid() end
    end)
    pcall(function()
        if fluxus and fluxus.get_hwid then hwid = fluxus.get_hwid() end
    end)
    pcall(function()
        if gethwid then hwid = gethwid() end
    end)
    pcall(function()
        if krnl and krnl.get_hwid then hwid = krnl.get_hwid() end
    end)

    return tostring(hwid)
end

---------------------------------------------------------------------//
-- EXECUTION COUNTER
---------------------------------------------------------------------//

local EXEC_FILE = "binhub_exec_count.txt"
local execCount = 0

pcall(function()
    if readfile and isfile and isfile(EXEC_FILE) then
        execCount = tonumber(readfile(EXEC_FILE)) or 0
    end
end)

execCount = execCount + 1

pcall(function()
    if writefile then writefile(EXEC_FILE, tostring(execCount)) end
end)

---------------------------------------------------------------------//
-- SYSTEM DATA (FPS, Ping, Region, etc.)
---------------------------------------------------------------------//

local lastFPS = 0
RunService.RenderStepped:Connect(function(dt)
    if dt > 0 then lastFPS = math.floor(1/dt + 0.5) end
end)

local function GetPing()
    local Stats = game:GetService("Stats")

    local ok, ping = pcall(function()
        if LocalPlayer.GetNetworkPing then return LocalPlayer:GetNetworkPing()*1000 end
    end)
    if ok and ping then return math.floor(ping + 0.5) end

    local ok2, fallback = pcall(function()
        local net = Stats.Network.ServerStatsItem
        if net then
            local dp = net["Data Ping"] or net["Ping"]
            if dp then
                local s = dp:GetValueString()
                return tonumber(s:match("(%d+)"))
            end
        end
    end)

    return fallback or -1
end

local cachedRegion = nil
local function GetRegion()
    if cachedRegion then return cachedRegion end

    local ok, data = pcall(function()
        return LocalPlayer:GetJoinData()
    end)

    if ok and data then
        if data.Region then cachedRegion = tostring(data.Region) return cachedRegion end
        if data.matchmakingContext then cachedRegion = tostring(data.matchmakingContext) return cachedRegion end
    end

    local ok2, loc = pcall(function()
        return LocalizationService.RobloxLocaleId
    end)

    cachedRegion = ok2 and loc or "Unknown"
    return cachedRegion
end

---------------------------------------------------------------------//
-- WEBHOOK PAYLOAD BUILDER
---------------------------------------------------------------------//

local function BuildPayload(mode, action)
    local execName, execVer = GetExecutorInfo()
    local hwid = GetHWID()
    local now = os.date("%Y-%m-%d %H:%M:%S")

    local scriptInfo = [[
Hub: Bin Hub X - Argon-style Hub v3.4.1

Main Hub:
 • Toggle Key: E (LOCKED)
 • Mode: ]] .. tostring(mode) .. [[
 • Action: ]] .. tostring(action) .. [[

Extra Info:
 • HWID Logging: ENABLED
 • FPS/Ping Logging: ENABLED
 • Region Logging: ENABLED
]]

    return {
        embeds = {{
            title = "Bin Hub X - Script Executed",
            color = 0x5865F2,
            fields = {
                {
                    name = "Player",
                    value = "Display: **"..displayName.."**\nUsername: `" .. userName .."`"
                },
                {
                    name = "Game",
                    value = "**"..(MarketplaceService:GetProductInfo(game.PlaceId).Name).."**\nPlaceId: `"..game.PlaceId.."`\nJobId: `"..game.JobId.."`"
                },
                {
                    name = "Executor",
                    value = "Name: `" .. execName .. "`\nVersion: `" .. execVer .. "`"
                },
                {
                    name = "Hardware ID",
                    value = "```"..hwid.."```"
                },
                {
                    name = "Performance",
                    value = "FPS: **"..lastFPS.."**\nPing: **"..GetPing().."ms**\nRegion: **"..GetRegion().."**"
                },
                {
                    name = "Execution Count",
                    value = "This script has been executed **"..execCount.."** times."
                },
                {
                    name = "Script Info",
                    value = "```"..scriptInfo.."```"
                },
                {
                    name = "Time",
                    value = "```"..now.."```"
                }
            }
        }}
    }
end

---------------------------------------------------------------------//
-- SEND WEBHOOK
---------------------------------------------------------------------//

function sendWebhookLog(mode, action)
    local req = GetRequest()
    if not req then return Debug("❌ No request function available") end

    local payload = BuildPayload(mode, action)
    local encoded = HttpService:JSONEncode(payload)

    local ok, res = pcall(function()
        return req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = encoded
        })
    end)

    if ok then Debug("✅ Webhook Sent") else Debug("❌ Webhook Failed: "..tostring(res)) end
end

-- INITIAL EXECUTION LOG
task.spawn(function()
    sendWebhookLog("Toggle/Hold?", "Click/Parry?")
end)

---------------------------------------------------------------------//
-- CONTINUE SCRIPT BELOW THIS LINE
---------------------------------------------------------------------//
---------------------------------------------------------------------//
-- GUI ROOT SETUP
---------------------------------------------------------------------//

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
-- MAIN ROOT WINDOW
---------------------------------------------------------------------//

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
        TweenService:Create(dot, TweenInfo.new(math.random(10,20), Enum.EasingStyle.Linear), {
            Position = UDim2.new(math.random(),0,math.random(),0)
        }):Play()
    end

    tweenDot()
end

for i=1,40 do createDot() end

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

local versionPill = Instance.new("TextLabel")
versionPill.Size = UDim2.new(0,60,0,22)
versionPill.Position = UDim2.new(1,-72,0,14)
versionPill.BackgroundColor3 = Color3.fromRGB(220,60,60)
versionPill.BorderSizePixel = 0
versionPill.Font = Enum.Font.GothamBold
versionPill.TextSize = 14
versionPill.TextColor3 = Color3.fromRGB(255,255,255)
versionPill.Text = "v3.4.1"
versionPill.ZIndex = 3
versionPill.Parent = sidebar

local vCorner = Instance.new("UICorner")
vCorner.CornerRadius = UDim.new(1,0)
vCorner.Parent = versionPill

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

local pages      = {}
local navButtons = {}
local currentPage

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
-- NAVIGATION BUTTONS
---------------------------------------------------------------------//

local function setActivePage(name)
    for n,f in pairs(pages) do
        f.Visible = (n == name)
    end
    for n,b in pairs(navButtons) do
        b.BackgroundColor3 = (n == name) and Color3.fromRGB(55,55,65) or Color3.fromRGB(25,25,32)
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
-- PAGE CONTAINER
---------------------------------------------------------------------//

local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1,-230,1,-40)
contentHolder.Position = UDim2.new(0,230,0,40)
contentHolder.BackgroundTransparency = 1
contentHolder.ZIndex = 1
contentHolder.Parent = root

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

local homePage     = createPage("Home")
local mainPage     = createPage("Main")
local blatantPage  = createPage("Blatant")
local othersPage   = createPage("Others")
local settingsPage = createPage("Settings")
---------------------------------------------------------------------//
-- HOME PAGE CONTENT
---------------------------------------------------------------------//

local homeTitle = Instance.new("TextLabel")
homeTitle.Size = UDim2.new(1, -20, 0, 32)
homeTitle.Position = UDim2.new(0, 10, 0, 10)
homeTitle.BackgroundTransparency = 1
homeTitle.Font = Enum.Font.GothamBlack
homeTitle.TextSize = 24
homeTitle.TextColor3 = Color3.fromRGB(255,255,255)
homeTitle.TextXAlignment = Enum.TextXAlignment.Left
homeTitle.Text = "Welcome, "..displayName
homeTitle.ZIndex = 3
homeTitle.Parent = homePage

local homeDesc = Instance.new("TextLabel")
homeDesc.Size = UDim2.new(1, -20, 0, 20)
homeDesc.Position = UDim2.new(0, 10, 0, 45)
homeDesc.BackgroundTransparency = 1
homeDesc.Font = Enum.Font.Gotham
homeDesc.TextSize = 14
homeDesc.TextColor3 = Color3.fromRGB(180,180,190)
homeDesc.TextXAlignment = Enum.TextXAlignment.Left
homeDesc.TextWrapped = true
homeDesc.Text = "Argon-Bin Hub X | Custom build by Binxix — v3.4.1"
homeDesc.ZIndex = 3
homeDesc.Parent = homePage

---------------------------------------------------------------------//
-- MAIN PAGE CONTENT
---------------------------------------------------------------------//

local function createSection(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 24)
    lbl.Position = UDim2.new(0, 10, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 18
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 3
    lbl.Parent = parent
end

createSection(mainPage, "Main Hub")

---------------------------------------------------------------------//
-- TOGGLE FUNCTION
---------------------------------------------------------------------//

local toggles = {}

local function createToggle(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 38)
    frame.Position = UDim2.new(0, 10, 0, (#parent:GetChildren() * 42) + 34)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
    frame.BorderSizePixel = 0
    frame.ZIndex = 3
    frame.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,10)
    c.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.TextColor3 = Color3.fromRGB(240,240,245)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 4
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 26)
    btn.Position = UDim2.new(1,-60,0.5,-13)
    btn.BackgroundColor3 = Color3.fromRGB(140,40,40)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = "OFF"
    btn.ZIndex = 5
    btn.Parent = frame

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0,10)
    bCorner.Parent = btn

    local state = false

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(60,180,70) or Color3.fromRGB(140,40,40)
        callback(state)
    end)

    return function()
        return state
    end
end

---------------------------------------------------------------------//
-- MODE TOGGLE (HOLD / TOGGLE)
---------------------------------------------------------------------//

local ModeType = "Toggle"
toggles.modeToggle = createToggle(mainPage, "Mode Type (Hold/Toggle)", function(state)
    ModeType = state and "Hold" or "Toggle"
end)

---------------------------------------------------------------------//
-- ACTION TOGGLE (PARRY / CLICK)
---------------------------------------------------------------------//

local ActionType = "Click"
toggles.actionToggle = createToggle(mainPage, "Action Type (Click/Parry)", function(state)
    ActionType = state and "Parry" or "Click"
end)

---------------------------------------------------------------------//
-- RAPID FIRE TOGGLE (HOLD FIRE ONLY)
---------------------------------------------------------------------//

local RapidFireEnabled = false
toggles.rapidFire = createToggle(mainPage, "Rapid Fire (Hold-Only)", function(state)
    RapidFireEnabled = state
end)

---------------------------------------------------------------------//
-- AUTO-JUMP TOGGLE
---------------------------------------------------------------------//

local AutoJump = false
toggles.autoJump = createToggle(mainPage, "Auto Jump", function(state)
    AutoJump = state
end)

---------------------------------------------------------------------//
-- AUTO-FIRE TOGGLE
---------------------------------------------------------------------//

local AutoFire = false
toggles.autoFire = createToggle(mainPage, "Auto Fire", function(state)
    AutoFire = state
end)

---------------------------------------------------------------------//
-- CONTINUE BELOW
---------------------------------------------------------------------//
---------------------------------------------------------------------//
-- BLATANT PAGE CONTENT
---------------------------------------------------------------------//

local function createBlatantToggle(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 38)
    frame.Position = UDim2.new(0, 10, 0, (#parent:GetChildren() * 40) + 10)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
    frame.BorderSizePixel = 0
    frame.ZIndex = 3
    frame.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,10)
    c.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 15
    lbl.TextColor3 = Color3.fromRGB(240,240,245)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 4
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 26)
    btn.Position = UDim2.new(1,-60,0.5,-13)
    btn.BackgroundColor3 = Color3.fromRGB(140,40,40)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = "OFF"
    btn.ZIndex = 5
    btn.Parent = frame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0,10)
    bc.Parent = btn

    local state = false

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(60,180,70) or Color3.fromRGB(140,40,40)
        callback(state)
    end)

    return function()
        return state
    end
end

---------------------------------------------------------------------//
-- SPEED + JUMP TOGGLES
---------------------------------------------------------------------//

local WalkSpeedBoost = false
local JumpPowerBoost = false

createBlatantToggle(blatantPage, "Speed Boost", function(state)
    WalkSpeedBoost = state
    if LocalPlayer.Character then
        LocalPlayer.Character.Humanoid.WalkSpeed = state and 28 or 16
    end
end)

createBlatantToggle(blatantPage, "Jump Power Boost", function(state)
    JumpPowerBoost = state
    if LocalPlayer.Character then
        LocalPlayer.Character.Humanoid.JumpPower = state and 70 or 50
    end
end)

---------------------------------------------------------------------//
-- FPS BOOST
---------------------------------------------------------------------//

local FPSBoost = false

createBlatantToggle(blatantPage, "FPS Boost (Lighting)", function(state)
    FPSBoost = state
    if state then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e10
        for _,v in pairs(game.Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = false
            end
        end
    else
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 1000
        for _,v in pairs(game.Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = true
            end
        end
    end
end)

---------------------------------------------------------------------//
-- REMOVE MAP DECALS / PARTICLES (ANTI-LAG)
---------------------------------------------------------------------//

local AntiLag = false

createBlatantToggle(blatantPage, "Anti-Lag (Remove Details)", function(state)
    AntiLag = state
    if state then
        for _,obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") then obj.Transparency = 1 end
            if obj:IsA("ParticleEmitter") then obj.Enabled = false end
            if obj:IsA("Trail") then obj.Enabled = false end
        end
    else
        for _,obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") then obj.Transparency = 0 end
            if obj:IsA("ParticleEmitter") then obj.Enabled = true end
            if obj:IsA("Trail") then obj.Enabled = true end
        end
    end
end)

---------------------------------------------------------------------//
-- OTHERS PAGE
---------------------------------------------------------------------//

local othersTitle = Instance.new("TextLabel")
othersTitle.Size = UDim2.new(1, -20, 0, 32)
othersTitle.Position = UDim2.new(0, 10, 0, 10)
othersTitle.BackgroundTransparency = 1
othersTitle.Font = Enum.Font.GothamBlack
othersTitle.TextSize = 22
othersTitle.TextColor3 = Color3.fromRGB(255,255,255)
othersTitle.TextXAlignment = Enum.TextXAlignment.Left
othersTitle.Text = "Other Options"
othersTitle.ZIndex = 3
othersTitle.Parent = othersPage

local function createOption(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, (#parent:GetChildren() * 26) + 40)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(200,200,210)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 3
    lbl.Parent = parent
end

createOption(othersPage, "• Script optimized for performance")
createOption(othersPage, "• No keybind changes allowed")
createOption(othersPage, "• Auto update disabled for safety")
createOption(othersPage, "• Includes HWID + Exec Counter Webhook Logs")
createOption(othersPage, "• Ping/FPS/Region tracking enabled")

---------------------------------------------------------------------//
-- SETTINGS PAGE
---------------------------------------------------------------------//

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, -20, 0, 32)
settingsTitle.Position = UDim2.new(0, 10, 0, 10)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Font = Enum.Font.GothamBlack
settingsTitle.TextSize = 24
settingsTitle.TextColor3 = Color3.fromRGB(255,255,255)
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.Text = "Settings"
settingsTitle.ZIndex = 3
settingsTitle.Parent = settingsPage

local settingsDesc = Instance.new("TextLabel")
settingsDesc.Size = UDim2.new(1, -20, 0, 20)
settingsDesc.Position = UDim2.new(0, 10, 0, 42)
settingsDesc.BackgroundTransparency = 1
settingsDesc.Font = Enum.Font.Gotham
settingsDesc.TextSize = 14
settingsDesc.TextColor3 = Color3.fromRGB(180,180,190)
settingsDesc.TextXAlignment = Enum.TextXAlignment.Left
settingsDesc.Text = "Customize your UI experience."
settingsDesc.ZIndex = 3
settingsDesc.Parent = settingsPage

---------------------------------------------------------------------//
-- GUI TOGGLE KEY (RIGHT CTRL)
---------------------------------------------------------------------//

UIS.InputBegan:Connect(function(key, gpe)
    if gpe then return end
    if key.KeyCode == Enum.KeyCode.RightControl then
        guiVisible = not guiVisible
        gui.Enabled = guiVisible
    end
end)

---------------------------------------------------------------------//
--  FINAL BIN HUB SYSTEMS  
--  AutoClicker | AutoParry | ManualSpam | TriggerBot | HWID Logs
---------------------------------------------------------------------//

-- set default
local clicking = false
local manualSpam = false
local triggerBot = false

local CPS = 10

local function safeKeyPress(k)
    if not VIM then return end
    pcall(function()
        VIM:SendKeyEvent(true, k, false, game)
        task.wait(0.01)
        VIM:SendKeyEvent(false, k, false, game)
    end)
end

---------------------------------------------------------------------//
--  MODE + ACTION SWITCHING
---------------------------------------------------------------------//

modeButton.MouseButton1Click:Connect(function()
    mode = (mode == "Toggle") and "Hold" or "Toggle"
    modeButton.Text = mode
end)

actionButton.MouseButton1Click:Connect(function()
    actionMode = (actionMode == "Click") and "Parry" or "Click"
    actionButton.Text = actionMode
end)

---------------------------------------------------------------------//
--  MAIN START / STOP BUTTON
---------------------------------------------------------------------//

toggleBtn.MouseButton1Click:Connect(function()
    clicking = not clicking
    toggleBtn.Text = clicking and "Stop" or "Start"
    toggleBtn.BackgroundColor3 = clicking and Color3.fromRGB(60,200,80) or Color3.fromRGB(60,60,70)
end)

---------------------------------------------------------------------//
--  KEY HANDLING
---------------------------------------------------------------------//

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    if input.KeyCode == manualKey then
        manualSpam = true
    end

    if input.KeyCode == toggleKey then
        if mode == "Toggle" then
            clicking = not clicking
        else
            clicking = true
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == manualKey then
        manualSpam = false
    end
    if input.KeyCode == toggleKey and mode == "Hold" then
        clicking = false
    end
end)

---------------------------------------------------------------------//
--  MAIN AUTO LOOP (Click / Parry / Manual Spam)
---------------------------------------------------------------------//

task.spawn(function()
    while true do
        local cpsDelay = 1 / math.clamp(tonumber(cpsBox.Text) or 10, 1, 100)

        -- Auto Click / Parry
        if clicking then
            if actionMode == "Click" then
                pcall(function() mouse1click() end)
            else
                safeKeyPress(parryKey)
            end
        end

        -- TriggerBot (constant parry)
        if triggerbotOn then
            safeKeyPress(parryKey)
        end

        -- Manual Spam Key
        if manualSpam then
            safeKeyPress(manualKey)
        end

        task.wait(cpsDelay)
    end
end)

---------------------------------------------------------------------//
--  SPEED + JUMP RE-APPLY (When Character Respawns)
---------------------------------------------------------------------//

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:WaitForChild("Humanoid")

    if WalkSpeedBoost then
        hum.WalkSpeed = 28
    end

    if JumpPowerBoost then
        hum.JumpPower = 70
    end
end)

---------------------------------------------------------------------//
--  EXECUTION COUNTER (INCREASE EVERY TIME SCRIPT RUNS)
---------------------------------------------------------------------//

local currentExecs = tonumber(execCounterStore["count"] or 0)
currentExecs = currentExecs + 1
execCounterStore["count"] = currentExecs
writefile(execCounterPath, HttpService:JSONEncode(execCounterStore))

---------------------------------------------------------------------//
--  AUTO SEND EXECUTION LOG (FPS + Ping + Region + Mode + Action + HWID)
---------------------------------------------------------------------//

task.delay(0.75, function()
    sendWebhookLog(currentExecs)
end)

---------------------------------------------------------------------//
--  FINAL STARTUP SETTINGS
---------------------------------------------------------------------//

setActivePage("Home")
updateStatus()
gui.Enabled = true
guiVisible = true

