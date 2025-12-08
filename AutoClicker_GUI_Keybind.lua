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
local StatsService         = game:GetService("Stats")
local AnalyticsService     = game:GetService("RbxAnalyticsService")

local LocalPlayer = Players.LocalPlayer
local displayName = (LocalPlayer and LocalPlayer.DisplayName) or "Player"
local userName    = (LocalPlayer and LocalPlayer.Name)        or "Unknown"

local TIKTOK_HANDLE = "@binxix"

local VIM
pcall(function()
    VIM = game:GetService("VirtualInputManager")
end)

---------------------------------------------------------------------//
-- WEBHOOK CONFIG + EXEC COUNTER + HWID
---------------------------------------------------------------------//
local WEBHOOK_URL = "https://discord.com/api/webhooks/1446656470287651050/ayflCl7nEQ3388YhXAZT7r3j5kTC40EP3WV9yO1BehR2vzHbtoDArV-YejWn_E_F6eUk"

-- persistent execution counter
getgenv().BinHub_ExecCount = (getgenv().BinHub_ExecCount or 0) + 1
local EXEC_COUNT = getgenv().BinHub_ExecCount

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

-- very simple, stable hash for strings
local function simpleHash(str)
    local h = 0
    for i = 1, #str do
        h = (h * 131 + string.byte(str, i)) % 2^31
    end
    return string.format("%08X", h)
end

local function getHWID()
    local raw = "Unknown"

    if typeof(gethwid) == "function" then
        local ok, res = pcall(gethwid)
        if ok and res then
            raw = tostring(res)
        end
    end

    if raw == "Unknown" then
        local ok, id = pcall(function()
            return AnalyticsService:GetClientId()
        end)
        if ok and id then
            raw = tostring(id)
        end
    end

    local hashed = simpleHash(raw)
    return raw, hashed
end

-- detect executor / exploit type
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
    local gameName   = getGameName()
    local placeId    = tostring(game.PlaceId)
    local jobId      = tostring(game.JobId)
    local username   = userName
    local dName      = displayName
    local timestamp  = os.date("%Y-%m-%d %H:%M:%S")
    local execName, exploitType = getExecutorInfo()
    local hwidRaw, hwidHash = getHWID()

    return {
        username    = username,
        displayName = dName,
        gameName    = gameName,
        placeId     = placeId,
        jobId       = jobId,
        timestamp   = timestamp,
        executor    = execName,
        exploitType = exploitType,
        hwid        = hwidRaw,
        hwidHash    = hwidHash,
        execCount   = EXEC_COUNT,
    }
end

local function getScriptInfoBlock()
    local lines = {
        "Hub: BinHub X - Argon-style Hub v3.6",
        "",
        "Main Hub:",
        "  • Main Toggle Key: E (LOCKED)",
        "  • Mode: Toggle / Hold (UI controlled)",
        "  • Action: Click / Parry (UI controlled)",
        "",
        "Keybinds:",
        "  • Parry Key: E (locked)",
        "  • Manual Spam Key: R (default, rebindable in UI)",
        "",
        "Player Options:",
        "  • Speed Boost: slider 10–100 (toggle required, resets to game default when OFF)",
        "  • Jump Boost: slider 25–150 (toggle required, resets to game default when OFF)",
        "",
        "Tracking:",
        "  • Exec Counter (per client) = "..EXEC_COUNT,
        "  • HWID Hash = "..(getBasicEmbedFields().hwidHash),
        "",
        "Notes:",
        "  • RightCtrl = Show/Hide hub",
        "  • Bug reports (Others tab) go to the same webhook.",
    }
    return table.concat(lines, "\n")
end

local function sendExecWebhook()
    if not WEBHOOK_URL or WEBHOOK_URL == "" then return end
    local req = getRequestFunction()
    if not req then return end

    local meta       = getBasicEmbedFields()
    local scriptInfo = getScriptInfoBlock()

    local payload = {
        embeds = {
            {
                title = "BinHub X - Script Executed",
                color = 0xFFD700, -- gold
                fields = {
                    {
                        name  = "Player",
                        value = string.format("Display: **%s**\nUsername: `%s`", meta.displayName, meta.username),
                        inline = false
                    },
                    {
                        name  = "Game",
                        value = string.format("**%s**\nPlaceId: `%s`\nJobId: `%s`", meta.gameName, meta.placeId, meta.jobId),
                        inline = false
                    },
                    {
                        name  = "Executor / Exploit",
                        value = string.format("Executor: `%s`\nType: `%s`", meta.executor, meta.exploitType),
                        inline = false
                    },
                    {
                        name  = "HWID",
                        value = string.format("Raw: `%s`\nHash: `%s`", meta.hwid, meta.hwidHash),
                        inline = false
                    },
                    {
                        name  = "Execution Counter",
                        value = string.format("This client has executed BinHub X **%d** time(s).", meta.execCount),
                        inline = false
                    },
                    {
                        name  = "Script Info",
                        value = "```"..scriptInfo.."```",
                        inline = false
                    },
                    {
                        name  = "Time",
                        value = "```"..meta.timestamp.."```",
                        inline = false
                    },
                }
            }
        }
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
        return false, "No request function"
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
                        name  = "Player",
                        value = string.format("Display: **%s**\nUsername: `%s`", meta.displayName, meta.username),
                        inline = false
                    },
                    {
                        name  = "Game",
                        value = string.format("**%s**\nPlaceId: `%s`\nJobId: `%s`", meta.gameName, meta.placeId, meta.jobId),
                        inline = false
                    },
                    {
                        name  = "Executor / Exploit",
                        value = string.format("Executor: `%s`\nType: `%s`", meta.executor, meta.exploitType),
                        inline = false
                    },
                    {
                        name  = "Exec Count / HWID",
                        value = string.format("Execs: **%d**\nHWID Hash: `%s`", meta.execCount, meta.hwidHash),
                        inline = false
                    },
                    {
                        name  = "Time",
                        value = "```"..meta.timestamp.."```",
                        inline = false
                    },
                    {
                        name  = "Bug Report",
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
-- GUI ROOT
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
-- GLOBAL STATES
---------------------------------------------------------------------//
local clicking         = false
local cps              = 10
local mode             = "Toggle"  -- Toggle / Hold
local actionMode       = "Click"   -- Click / Parry

local toggleKey        = Enum.KeyCode.E
local parryKey         = Enum.KeyCode.E
local manualKey        = Enum.KeyCode.R
local manualSpamActive = false
local triggerbotOn     = false

-- speed / jump states
local speedEnabled      = false
local jumpEnabled       = false
local speedValue        = 20
local jumpValue         = 50
local defaultWalkSpeed  = 16
local defaultJumpPower  = 50

local function getHumanoid()
    if not LocalPlayer then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

local function captureDefaults()
    local hum = getHumanoid()
    if hum then
        defaultWalkSpeed = hum.WalkSpeed
        if hum.UseJumpPower ~= nil then
            hum.UseJumpPower = true
        end
        defaultJumpPower = hum.JumpPower
    end
end

captureDefaults()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    captureDefaults()
    -- on respawn, reapply active toggles
    if speedEnabled then
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = speedValue end
    end
    if jumpEnabled then
        local hum = getHumanoid()
        if hum then hum.JumpPower = jumpValue end
    end
end)

---------------------------------------------------------------------//
-- ROOT FRAME
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

---------------------------------------------------------------------//
-- SIDEBAR + NAV
---------------------------------------------------------------------//
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0,230,1,0)
sidebar.BackgroundColor3 = Color3.fromRGB(15,15,18)
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 2
sidebar.Parent = root

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0,18)
sideCorner.Parent = sidebar

local sideStroke = Instance.new("UIStroke")
sideStroke.Thickness = 1
sideStroke.Color = Color3.fromRGB(40,40,45)
sideStroke.Parent = sidebar

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
versionPill.Text = "v3.6"
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
searchBox.PlaceholderText = "Search (visual only)"
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
-- TOP BAR (DRAG)
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

local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    root.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

contentTop.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos  = root.Position
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
-- PAGES CONTAINER
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

---------------------------------------------------------------------//
-- NAV HELPERS
---------------------------------------------------------------------//
local function setActivePage(name)
    for n,f in pairs(pages) do
        f.Visible = (n == name)
    end
    for n,b in pairs(navButtons) do
        b.BackgroundColor3 = (n == name) and Color3.fromRGB(55,55,65) or Color3.fromRGB(25,25,32)
    end
    currentPage = name
    topTitle.Text = (name == "Home" and "Dashboard")
        or (name == "Main" and "Main Hub")
        or (name == "Blatant" and "Blatant / Player Mods")
        or (name == "Others" and "Other Options")
        or "BinHub X"
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

sectionLabel("Others")
navButton("Others","Others")

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
    t.Text = "Welcome, "..displayName
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
    d.Text = "Account: @"..userName.."\nUse the tabs on the left to control your auto clicker, auto parry and blatant settings."
    d.ZIndex = 3
    d.Parent = homePage

    local tk = Instance.new("TextLabel")
    tk.Size = UDim2.new(1,-40,0,24)
    tk.Position = UDim2.new(0,20,0,140)
    tk.BackgroundTransparency = 1
    tk.Font = Enum.Font.GothamSemibold
    tk.TextSize = 14
    tk.TextColor3 = Color3.fromRGB(255,230,120)
    tk.TextXAlignment = Enum.TextXAlignment.Left
    tk.Text = "TikTok: "..TIKTOK_HANDLE
    tk.ZIndex = 3
    tk.Parent = homePage
end

---------------------------------------------------------------------//
-- MAIN PAGE (STATUS + MODES + CPS + LIVE PANEL)
---------------------------------------------------------------------//
local function keyToString(keycode)
    local s = tostring(keycode)
    return s:match("%.(.+)") or s
end

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-40,0,24)
status.Position = UDim2.new(0,20,0,20)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 16
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextColor3 = Color3.fromRGB(255,80,80)
status.Text = "Status: OFF (10 CPS, Toggle, Click)"
status.ZIndex = 3
status.Parent = mainPage

local function mkLabel(parent,txt,x,y)
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
    l.Parent = parent
    return l
end

mkLabel(mainPage,"CPS:",20,60)
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

mkLabel(mainPage,"Mode:",20,96)
local modeButton = Instance.new("TextButton")
modeButton.Size = UDim2.new(0,90,0,24)
modeButton.Position = UDim2.new(0,80,0,94)
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

mkLabel(mainPage,"Action:",20,132)
local actionButton = Instance.new("TextButton")
actionButton.Size = UDim2.new(0,90,0,24)
actionButton.Position = UDim2.new(0,80,0,130)
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

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1,-40,0,40)
infoLabel.Position = UDim2.new(0,20,0,170)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.TextColor3 = Color3.fromRGB(180,180,190)
infoLabel.Text = "RightCtrl = show/hide hub. Mode = Toggle/Hold. Action = Click/Parry."
infoLabel.ZIndex = 3
infoLabel.Parent = mainPage

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,220,0,34)
toggleBtn.Position = UDim2.new(0,20,0,220)
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

-- manual spam
mkLabel(mainPage,"Manual Spam Key:",20,272)
local manualKeyButton = Instance.new("TextButton")
manualKeyButton.Size = UDim2.new(0,60,0,24)
manualKeyButton.Position = UDim2.new(0,150,0,270)
manualKeyButton.BackgroundColor3 = Color3.fromRGB(30,30,35)
manualKeyButton.BorderSizePixel = 0
manualKeyButton.Font = Enum.Font.GothamBold
manualKeyButton.TextSize = 14
manualKeyButton.TextColor3 = Color3.fromRGB(255,255,255)
manualKeyButton.Text = keyToString(manualKey)
manualKeyButton.ZIndex = 3
manualKeyButton.Parent = mainPage

local mkCorner = Instance.new("UICorner")
mkCorner.CornerRadius = UDim.new(0,8)
mkCorner.Parent = manualKeyButton

local listeningForManual = false

manualKeyButton.MouseButton1Click:Connect(function()
    if listeningForManual then return end
    listeningForManual = true
    infoLabel.Text = "Press a key to set Manual Spam."
end)

---------------------------------------------------------------------//
-- LIVE STATUS PANEL (FPS / PING / WALKSPEED / JUMPPOWER)
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

local pingLabel = fpsLabel:Clone()
pingLabel.Position = UDim2.new(0,8,0,44)
pingLabel.Text = "Ping: -- ms"
pingLabel.Parent = livePanel

local wsLabel = fpsLabel:Clone()
wsLabel.Position = UDim2.new(0,8,0,60)
wsLabel.Text = "WalkSpeed: --"
wsLabel.Parent = livePanel

local jpLabel = fpsLabel:Clone()
jpLabel.Position = UDim2.new(0,8,0,76)
jpLabel.Text = "JumpPower: --"
jpLabel.Parent = livePanel

local regionLabel = fpsLabel:Clone()
regionLabel.Position = UDim2.new(0,8,0,92)
regionLabel.Text = "Region: --"
regionLabel.Parent = livePanel

local lastFps = 0
RunService.RenderStepped:Connect(function(dt)
    if dt > 0 then
        lastFps = math.floor(1/dt + 0.5)
    end
end)

local cachedRegion = nil
local function getRegion()
    if cachedRegion ~= nil then return cachedRegion end

    local ok, joinData = pcall(function()
        if LocalPlayer and LocalPlayer.GetJoinData then
            return LocalPlayer:GetJoinData()
        end
    end)
    if ok and joinData then
        if joinData.Region then
            cachedRegion = tostring(joinData.Region)
            return cachedRegion
        end
        if joinData.matchmakingContext then
            cachedRegion = tostring(joinData.matchmakingContext)
            return cachedRegion
        end
    end

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

local function getPingMs()
    local ok, ping = pcall(function()
        if LocalPlayer and LocalPlayer.GetNetworkPing then
            return LocalPlayer:GetNetworkPing()
        end
    end)
    if ok and ping then
        return math.floor(ping * 1000 + 0.5)
    end

    local ok2, ms = pcall(function()
        local net = StatsService.Network
        local si  = net:FindFirstChild("ServerStatsItem")
        if si then
            local dp = si:FindFirstChild("Data Ping") or si:FindFirstChild("Ping")
            if dp then
                local str = dp:GetValueString()
                local n = tonumber(str:match("(%d+)%s*ms"))
                return n
            end
        end
    end)

    if ok2 and ms then return ms end
    return nil
end

task.spawn(function()
    while true do
        local hum = getHumanoid()
        local ws = defaultWalkSpeed
        local jp = defaultJumpPower

        if hum then
            ws = hum.WalkSpeed or ws
            if hum.UseJumpPower ~= nil then
                jp = hum.JumpPower or jp
            end
        end

        local pingMs = getPingMs()
        local region = getRegion()

        fpsLabel.Text = "FPS: "..tostring(lastFps)
        pingLabel.Text = pingMs and ("Ping: "..pingMs.." ms") or "Ping: N/A"
        wsLabel.Text = string.format("WalkSpeed: %.1f", ws)
        jpLabel.Text = string.format("JumpPower: %.1f", jp)
        regionLabel.Text = "Region: "..tostring(region)

        task.wait(0.1)
    end
end)

---------------------------------------------------------------------//
-- BLATANT PAGE (SPEED / JUMP SLIDERS + TOGGLES)
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
    blatantScroll.CanvasSize = UDim2.new(0,0,0,bLayout.AbsoluteContentSize.Y + 10)
end)

local function createCard(height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,height)
    card.BackgroundColor3 = Color3.fromRGB(20,20,26)
    card.BorderSizePixel = 0
    card.ZIndex = 3
    card.Parent = blatantScroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,12)
    c.Parent = card

    return card
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
    d.Size = UDim2.new(1,-60,0,16)
    d.Position = UDim2.new(0,10,0,28)
    d.BackgroundTransparency = 1
    d.Font = Enum.Font.Gotham
    d.TextSize = 12
    d.TextColor3 = Color3.fromRGB(200,200,210)
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.ZIndex = 4
    d.Text = txt
    d.Parent = parent
    return d
end

-- SPEED CARD
local speedCard = createCard(64)
makeTitle(speedCard,"Speed Boost")
makeDesc(speedCard,"Only applies while toggle is ON. Restores game default when OFF.")

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

local speedToggle = Instance.new("Frame")
speedToggle.Size = UDim2.new(0,40,0,20)
speedToggle.Position = UDim2.new(1,-50,0,8)
speedToggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
speedToggle.BorderSizePixel = 0
speedToggle.ZIndex = 4
speedToggle.Parent = speedCard

local speedToggleCorner = Instance.new("UICorner")
speedToggleCorner.CornerRadius = UDim.new(1,0)
speedToggleCorner.Parent = speedToggle

local speedThumb = Instance.new("Frame")
speedThumb.Size = UDim2.new(0,16,0,16)
speedThumb.Position = UDim2.new(0,2,0.5,-8)
speedThumb.BackgroundColor3 = Color3.fromRGB(80,80,80)
speedThumb.BorderSizePixel = 0
speedThumb.ZIndex = 5
speedThumb.Parent = speedToggle

local speedThumbCorner = Instance.new("UICorner")
speedThumbCorner.CornerRadius = UDim.new(1,0)
speedThumbCorner.Parent = speedThumb

local function updateSpeedToggleVisual()
    if speedEnabled then
        speedToggle.BackgroundColor3 = Color3.fromRGB(80,200,120)
        speedThumb.Position = UDim2.new(1,-18,0.5,-8)
    else
        speedToggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
        speedThumb.Position = UDim2.new(0,2,0.5,-8)
    end
end
updateSpeedToggleVisual()

local speedBar = Instance.new("Frame")
speedBar.Size = UDim2.new(1,-40,0,6)
speedBar.Position = UDim2.new(0,10,0,40)
speedBar.BackgroundColor3 = Color3.fromRGB(35,35,42)
speedBar.BorderSizePixel = 0
speedBar.ZIndex = 4
speedBar.Parent = speedCard

local speedBarCorner = Instance.new("UICorner")
speedBarCorner.CornerRadius = UDim.new(0,6)
speedBarCorner.Parent = speedBar

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new((speedValue-10)/(100-10),0,1,0)
speedFill.BackgroundColor3 = Color3.fromRGB(140,200,255)
speedFill.BorderSizePixel = 0
speedFill.ZIndex = 5
speedFill.Parent = speedBar

local speedFillCorner = Instance.new("UICorner")
speedFillCorner.CornerRadius = UDim.new(0,6)
speedFillCorner.Parent = speedFill

local speedDragging = false
local function applySpeed()
    local hum = getHumanoid()
    if not hum then return end
    if speedEnabled then
        hum.WalkSpeed = speedValue
    else
        hum.WalkSpeed = defaultWalkSpeed
    end
end

local function setSpeedFromX(x)
    local rel = math.clamp((x - speedBar.AbsolutePosition.X)/speedBar.AbsoluteSize.X,0,1)
    local val = math.floor(10 + (100-10)*rel + 0.5)
    speedValue = val
    speedValueLabel.Text = tostring(val)
    speedFill.Size = UDim2.new(rel,0,1,0)
    if speedEnabled then
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

speedToggle.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        speedEnabled = not speedEnabled
        updateSpeedToggleVisual()
        applySpeed()
    end
end)

-- JUMP CARD
local jumpCard = createCard(64)
makeTitle(jumpCard,"Jump Power Boost")
makeDesc(jumpCard,"Only applies while toggle is ON. Restores game default when OFF.")

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

local jumpToggle = Instance.new("Frame")
jumpToggle.Size = UDim2.new(0,40,0,20)
jumpToggle.Position = UDim2.new(1,-50,0,8)
jumpToggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
jumpToggle.BorderSizePixel = 0
jumpToggle.ZIndex = 4
jumpToggle.Parent = jumpCard

local jumpToggleCorner = Instance.new("UICorner")
jumpToggleCorner.CornerRadius = UDim.new(1,0)
jumpToggleCorner.Parent = jumpToggle

local jumpThumb = Instance.new("Frame")
jumpThumb.Size = UDim2.new(0,16,0,16)
jumpThumb.Position = UDim2.new(0,2,0.5,-8)
jumpThumb.BackgroundColor3 = Color3.fromRGB(80,80,80)
jumpThumb.BorderSizePixel = 0
jumpThumb.ZIndex = 5
jumpThumb.Parent = jumpToggle

local jumpThumbCorner = Instance.new("UICorner")
jumpThumbCorner.CornerRadius = UDim.new(1,0)
jumpThumbCorner.Parent = jumpThumb

local function updateJumpToggleVisual()
    if jumpEnabled then
        jumpToggle.BackgroundColor3 = Color3.fromRGB(80,200,120)
        jumpThumb.Position = UDim2.new(1,-18,0.5,-8)
    else
        jumpToggle.BackgroundColor3 = Color3.fromRGB(40,40,48)
        jumpThumb.Position = UDim2.new(0,2,0.5,-8)
    end
end
updateJumpToggleVisual()

local jumpBar = Instance.new("Frame")
jumpBar.Size = UDim2.new(1,-40,0,6)
jumpBar.Position = UDim2.new(0,10,0,40)
jumpBar.BackgroundColor3 = Color3.fromRGB(35,35,42)
jumpBar.BorderSizePixel = 0
jumpBar.ZIndex = 4
jumpBar.Parent = jumpCard

local jumpBarCorner = Instance.new("UICorner")
jumpBarCorner.CornerRadius = UDim.new(0,6)
jumpBarCorner.Parent = jumpBar

local jumpFill = Instance.new("Frame")
jumpFill.Size = UDim2.new((jumpValue-25)/(150-25),0,1,0)
jumpFill.BackgroundColor3 = Color3.fromRGB(140,200,255)
jumpFill.BorderSizePixel = 0
jumpFill.ZIndex = 5
jumpFill.Parent = jumpBar

local jumpFillCorner = Instance.new("UICorner")
jumpFillCorner.CornerRadius = UDim.new(0,6)
jumpFillCorner.Parent = jumpFill

local jumpDragging = false
local function applyJump()
    local hum = getHumanoid()
    if not hum then return end
    if hum.UseJumpPower ~= nil then hum.UseJumpPower = true end
    if jumpEnabled then
        hum.JumpPower = jumpValue
    else
        hum.JumpPower = defaultJumpPower
    end
end

local function setJumpFromX(x)
    local rel = math.clamp((x - jumpBar.AbsolutePosition.X)/jumpBar.AbsoluteSize.X,0,1)
    local val = math.floor(25 + (150-25)*rel + 0.5)
    jumpValue = val
    jumpValueLabel.Text = tostring(val)
    jumpFill.Size = UDim2.new(rel,0,1,0)
    if jumpEnabled then
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

jumpToggle.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        jumpEnabled = not jumpEnabled
        updateJumpToggleVisual()
        applyJump()
    end
end)

---------------------------------------------------------------------//
-- OTHERS PAGE (BUG REPORT + INFO)
---------------------------------------------------------------------//
do
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-40,0,28)
    title.Position = UDim2.new(0,20,0,20)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "Other Options"
    title.ZIndex = 3
    title.Parent = othersPage

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1,-40,0,70)
    info.Position = UDim2.new(0,20,0,52)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 13
    info.TextColor3 = Color3.fromRGB(200,200,210)
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.Text =
        "• Script optimized for performance\n"..
        "• Keybind changes disabled for safety\n"..
        "• Includes HWID + Exec Counter Webhook Logs\n"..
        "• Ping/FPS/Region tracking enabled"
    info.ZIndex = 3
    info.Parent = othersPage

    local bugLabel = Instance.new("TextLabel")
    bugLabel.Size = UDim2.new(1,-40,0,20)
    bugLabel.Position = UDim2.new(0,20,0,130)
    bugLabel.BackgroundTransparency = 1
    bugLabel.Font = Enum.Font.GothamSemibold
    bugLabel.TextSize = 14
    bugLabel.TextColor3 = Color3.fromRGB(230,230,235)
    bugLabel.TextXAlignment = Enum.TextXAlignment.Left
    bugLabel.Text = "Bug Report:"
    bugLabel.ZIndex = 3
    bugLabel.Parent = othersPage

    local bugBox = Instance.new("TextBox")
    bugBox.Size = UDim2.new(1,-40,0,120)
    bugBox.Position = UDim2.new(0,20,0,154)
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
    bugBox.Parent = othersPage

    local bugCorner = Instance.new("UICorner")
    bugCorner.CornerRadius = UDim.new(0,10)
    bugCorner.Parent = bugBox

    local bugButton = Instance.new("TextButton")
    bugButton.Size = UDim2.new(0,160,0,30)
    bugButton.Position = UDim2.new(0,20,0,284)
    bugButton.BackgroundColor3 = Color3.fromRGB(80,200,120)
    bugButton.BorderSizePixel = 0
    bugButton.Font = Enum.Font.GothamBold
    bugButton.TextSize = 14
    bugButton.TextColor3 = Color3.fromRGB(0,0,0)
    bugButton.Text = "Send Bug Report"
    bugButton.ZIndex = 3
    bugButton.Parent = othersPage

    local bugBtnCorner = Instance.new("UICorner")
    bugBtnCorner.CornerRadius = UDim.new(0,10)
    bugBtnCorner.Parent = bugButton

    local bugStatusLabel = Instance.new("TextLabel")
    bugStatusLabel.Size = UDim2.new(1,-200,0,20)
    bugStatusLabel.Position = UDim2.new(0,190,0,288)
    bugStatusLabel.BackgroundTransparency = 1
    bugStatusLabel.Font = Enum.Font.Gotham
    bugStatusLabel.TextSize = 12
    bugStatusLabel.TextColor3 = Color3.fromRGB(180,180,190)
    bugStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    bugStatusLabel.Text = ""
    bugStatusLabel.ZIndex = 3
    bugStatusLabel.Parent = othersPage

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
            local ok,err = sendBugReport(text)
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
end

---------------------------------------------------------------------//
-- MAIN PAGE LOGIC
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
    return n
end

local function updateStatus()
    cps = getCPS()
    local onOff = clicking and "ON" or "OFF"
    local color = clicking and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,80,80)
    status.Text = string.format("Status: %s (%d CPS, %s, %s)",onOff,cps,mode,actionMode)
    status.TextColor3 = color
end

local function toggleClicker()
    clicking = not clicking
    updateStatus()
    if clicking then
        toggleBtn.Text = "Stop"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(80,200,120)
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
-- INPUT HANDLING
---------------------------------------------------------------------//
UIS.InputBegan:Connect(function(input,gp)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    if input.KeyCode == Enum.KeyCode.RightControl
        and not listeningForManual then
        guiVisible = not guiVisible
        gui.Enabled = guiVisible
        return
    end

    if listeningForManual then
        manualKey = input.KeyCode
        manualKeyButton.Text = keyToString(manualKey)
        infoLabel.Text = "Manual spam key set to: "..manualKeyButton.Text
        listeningForManual = false
        return
    end

    if gp then return end

    if input.KeyCode == toggleKey then
        if mode == "Toggle" then
            toggleClicker()
        else
            clicking = true
            updateStatus()
        end
        return
    end

    if input.KeyCode == manualKey then
        manualSpamActive = true
    end
end)

UIS.InputEnded:Connect(function(input,gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    if input.KeyCode == toggleKey and mode == "Hold" then
        clicking = false
        updateStatus()
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

            if clicking then
                if actionMode == "Click" then
                    pcall(function() mouse1click() end)
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
-- START ON HOME + STATUS + WEBHOOK
---------------------------------------------------------------------//
setActivePage("Home")
updateStatus()
sendExecWebhook()
print("[BinHub X v3.6] Loaded.")

