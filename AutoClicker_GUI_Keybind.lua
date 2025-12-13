-- BinHub X v3.6
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

local LocalPlayer        = Players.LocalPlayer
local displayName        = (LocalPlayer and LocalPlayer.DisplayName) or "Player"
local userName           = (LocalPlayer and LocalPlayer.Name)        or "Unknown"

local VIM
pcall(function()
    VIM = game:GetService("VirtualInputManager")
end)

local TIKTOK_HANDLE      = "@binxix"
local CURRENT_VERSION    = "3.6"

---------------------------------------------------------------------//
-- GLOBAL EXEC COUNTER / HWID
---------------------------------------------------------------------//
getgenv().BinHub_RunCount = (getgenv().BinHub_RunCount or 0) + 1
local execCount = getgenv().BinHub_RunCount

local function getHWID()
    local hwidFuncs = {
        function() return gethwid and gethwid() end,
        function()
            return (identifyexecutor and ({identifyexecutor()})[2])
        end,
        function()
            return (syn and syn.gethwid and syn.gethwid())
        end,
    }
    for _,fn in ipairs(hwidFuncs) do
        local ok,res = pcall(fn)
        if ok and res then
            return tostring(res)
        end
    end
    return "Unknown"
end

local hardwareId = getHWID()

---------------------------------------------------------------------//
-- WEBHOOK
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

local function getExecutorInfo()
    local execName   = "Unknown"
    local exploitType = "Unknown"

    if typeof(getexecutorname) == "function" then
        local ok, res = pcall(getexecutorname)
        if ok and res then execName = tostring(res) end
    elseif typeof(identifyexecutor) == "function" then
        local ok, a,b = pcall(identifyexecutor)
        if ok then
            if b then
                execName = tostring(a).." "..tostring(b)
            elseif a then
                execName = tostring(a)
            end
        end
    end

    if syn then
        exploitType = "Synapse Environment"
    elseif KRNL_LOADED or iskrnlclosure then
        exploitType = "KRNL Environment"
    elseif fluxus or isfluxusclosure then
        exploitType = "Fluxus Environment"
    elseif sentinel then
        exploitType = "Sentinel Environment"
    elseif execName ~= "Unknown" then
        exploitType = execName.." Environment"
    end

    return execName, exploitType
end

local function getBasicEmbedFields()
    local gameName  = getGameName()
    local placeId   = tostring(game.PlaceId)
    local jobId     = tostring(game.JobId)
    local username  = userName
    local dName     = displayName
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local execName, exploitType = getExecutorInfo()

    return {
        username    = username,
        displayName = dName,
        gameName    = gameName,
        placeId     = placeId,
        jobId       = jobId,
        timestamp   = timestamp,
        executor    = execName,
        exploitType = exploitType,
        hwid        = hardwareId,
        execCount   = execCount,
    }
end

local function getScriptInfoBlock()
    local lines = {
        "Hub: BinHub X v"..CURRENT_VERSION,
        "",
        "Main:",
        "  • Mode Key: E (locked)",
        "  • Mode Type: Hold / Toggle",
        "  • Action: Click / Parry",
        "",
        "Misc:",
        "  • Manual Spam Key: R",
        "  • Anti AFK: toggle in Others tab",
        "  • Speed / Jump Boosts: in Blatant tab",
        "",
        "Notes:",
        "  • RightCtrl = show / hide UI",
        "  • Includes HWID + Exec Counter logging",
    }
    return table.concat(lines,"\n")
end

local function sendWebhookLog()
    if not WEBHOOK_URL or WEBHOOK_URL == "" then return end
    local req = getRequestFunction()
    if not req then return end

    local meta       = getBasicEmbedFields()
    local scriptInfo = getScriptInfoBlock()

    local payload = {
        username = "BinHub X Logger",
        embeds = {{
            title = "BinHub X Executed",
            color = 0xF1C40F,
            fields = {
                {
                    name  = "Player",
                    value = string.format(
                        "Display: **%s**\nUsername: `%s`",
                        meta.displayName, meta.username
                    ),
                    inline = false
                },
                {
                    name  = "Game",
                    value = string.format(
                        "**%s**\nPlaceId: `%s`\nJobId: `%s`",
                        meta.gameName, meta.placeId, meta.jobId
                    ),
                    inline = false
                },
                {
                    name  = "Executor",
                    value = string.format(
                        "Name: `%s`\nType: `%s`",
                        meta.executor, meta.exploitType
                    ),
                    inline = false
                },
                {
                    name  = "HWID / Exec Count",
                    value = string.format(
                        "HWID: `%s`\nExec Count: `%s`",
                        meta.hwid, tostring(meta.execCount)
                    ),
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
                }
            }
        }}
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

local function sendBugReport(text)
    if not WEBHOOK_URL or WEBHOOK_URL == "" then
        return false,"No webhook"
    end
    local req = getRequestFunction()
    if not req then
        return false,"No request func"
    end
    text = text or ""
    if text:gsub("%s+","") == "" then
        return false,"Empty"
    end

    local meta = getBasicEmbedFields()
    if #text > 900 then
        text = text:sub(1,900).."..."
    end

    local payload = {
        username = "BinHub X Bug Report",
        embeds = {{
            title = "Bug Report",
            color = 0xE74C3C,
            fields = {
                {
                    name  = "Player",
                    value = string.format(
                        "Display: **%s**\nUsername: `%s`",
                        meta.displayName, meta.username
                    ),
                    inline = false
                },
                {
                    name  = "Game",
                    value = string.format(
                        "**%s**\nPlaceId: `%s`\nJobId: `%s`",
                        meta.gameName, meta.placeId, meta.jobId
                    ),
                    inline = false
                },
                {
                    name  = "Executor / HWID",
                    value = string.format(
                        "Exec: `%s`\nType: `%s`\nHWID: `%s`",
                        meta.executor, meta.exploitType, meta.hwid
                    ),
                    inline = false
                },
                {
                    name  = "Exec Count / Time",
                    value = string.format(
                        "Exec Count: `%s`\nTime: `%s`",
                        tostring(meta.execCount), meta.timestamp
                    ),
                    inline = false
                },
                {
                    name  = "Report",
                    value = "```"..text.."```",
                    inline = false
                }
            }
        }}
    }

    local json = HttpService:JSONEncode(payload)
    local ok,err = pcall(function()
        req({
            Url     = WEBHOOK_URL,
            Method  = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body    = json
        })
    end)
    return ok, err
end

---------------------------------------------------------------------//
-- SMALL HELPERS
---------------------------------------------------------------------//
local function tween(obj, props, time)
    local ti = TweenInfo.new(
        time or 0.15,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    TweenService:Create(obj,ti,props):Play()
end

local function getHumanoid()
    if not LocalPlayer then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

---------------------------------------------------------------------//
-- GUI ROOT / PARENT
---------------------------------------------------------------------//
local function safeParent()
    local ok, guiObj = pcall(function()
        if gethui then
            local g = Instance.new("ScreenGui")
            g.Name = "BinHubX"
            g.ResetOnSpawn = false
            g.Parent = gethui()
            return g
        end
    end)
    if ok and guiObj then return guiObj end

    ok, guiObj = pcall(function()
        if syn and syn.protect_gui then
            local g = Instance.new("ScreenGui")
            g.Name = "BinHubX"
            g.ResetOnSpawn = false
            syn.protect_gui(g)
            g.Parent = CoreGui
            return g
        end
    end)
    if ok and guiObj then return guiObj end

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
-- MAIN FRAME + TOP BAR
---------------------------------------------------------------------//
local root = Instance.new("Frame")
root.Size = UDim2.new(0,900,0,430)
root.Position = UDim2.new(0.5,-450,0.5,-215)
root.BackgroundColor3 = Color3.fromRGB(8,8,12)
root.BorderSizePixel = 0
root.Parent = gui

local rootCorner = Instance.new("UICorner")
rootCorner.CornerRadius = UDim.new(0,18)
rootCorner.Parent = root

local rootStroke = Instance.new("UIStroke")
rootStroke.Thickness = 1
rootStroke.Color = Color3.fromRGB(50,50,60)
rootStroke.Parent = root

-- subtle dots
for i = 1,30 do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,4,0,4)
    dot.Position = UDim2.new(math.random(),0,math.random(),0)
    dot.BackgroundColor3 = Color3.fromRGB(
        math.random(160,255),
        math.random(140,255),
        math.random(80,200)
    )
    dot.BorderSizePixel = 0
    dot.ZIndex = 0
    dot.Parent = root

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1,0)
    c.Parent = dot

    local ti = TweenInfo.new(
        math.random(8,16),
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut,
        -1,
        true
    )
    TweenService:Create(
        dot,
        ti,
        {Position = UDim2.new(math.random(),0,math.random(),0)}
    ):Play()
end

-- Top bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1,0,0,40)
topBar.BackgroundTransparency = 1
topBar.Parent = root

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0,260,1,0)
titleLabel.Position = UDim2.new(0,22,0,0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 22
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.Text = "BinHub X v"..CURRENT_VERSION
titleLabel.Parent = topBar

local buildPill = Instance.new("TextLabel")
buildPill.Size = UDim2.new(0,120,0,28)
buildPill.Position = UDim2.new(1,-130,0.5,-14)
buildPill.BackgroundColor3 = Color3.fromRGB(241,196,15)
buildPill.BorderSizePixel = 0
buildPill.Font = Enum.Font.GothamBold
buildPill.TextSize = 14
buildPill.TextColor3 = Color3.fromRGB(20,20,25)
buildPill.Text = "Build "..CURRENT_VERSION
buildPill.Parent = topBar

local bpCorner = Instance.new("UICorner")
bpCorner.CornerRadius = UDim.new(1,0)
bpCorner.Parent = buildPill

-- drag window
local dragging, dragStart, startPos
topBar.InputBegan:Connect(function(input)
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

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        root.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

---------------------------------------------------------------------//
-- SIDEBAR + NAV
---------------------------------------------------------------------//
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0,190,1,-40)
sidebar.Position = UDim2.new(0,0,0,40)
sidebar.BackgroundColor3 = Color3.fromRGB(10,10,16)
sidebar.BorderSizePixel = 0
sidebar.Parent = root

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0,18)
sbCorner.Parent = sidebar

local sbStroke = Instance.new("UIStroke")
sbStroke.Thickness = 1
sbStroke.Color = Color3.fromRGB(40,40,50)
sbStroke.Parent = sidebar

local sbTitle = Instance.new("TextLabel")
sbTitle.Size = UDim2.new(1,-20,0,26)
sbTitle.Position = UDim2.new(0,10,0,10)
sbTitle.BackgroundTransparency = 1
sbTitle.Font = Enum.Font.GothamBlack
sbTitle.TextSize = 18
sbTitle.TextXAlignment = Enum.TextXAlignment.Left
sbTitle.TextColor3 = Color3.fromRGB(255,255,255)
sbTitle.Text = "BinHub X"
sbTitle.Parent = sidebar

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1,-20,0,28)
searchBox.Position = UDim2.new(0,10,0,40)
searchBox.BackgroundColor3 = Color3.fromRGB(22,22,30)
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "Search (visual only)"
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 13
searchBox.TextColor3 = Color3.fromRGB(255,255,255)
searchBox.PlaceholderColor3 = Color3.fromRGB(150,150,165)
searchBox.Parent = sidebar

local sbSearchCorner = Instance.new("UICorner")
sbSearchCorner.CornerRadius = UDim.new(0,8)
sbSearchCorner.Parent = searchBox

local navHolder = Instance.new("Frame")
navHolder.Size = UDim2.new(1,-20,1,-130)
navHolder.Position = UDim2.new(0,10,0,76)
navHolder.BackgroundTransparency = 1
navHolder.Parent = sidebar

local navLayout = Instance.new("UIListLayout")
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Padding = UDim.new(0,6)
navLayout.Parent = navHolder

local pages = {}
local navButtons = {}
local currentPage

local function navButton(name, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,28)
    btn.BackgroundColor3 = Color3.fromRGB(22,22,30)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(220,220,230)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = "  "..text
    btn.Parent = navHolder

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,8)
    c.Parent = btn

    navButtons[name] = btn
    return btn
end

local profileCard = Instance.new("Frame")
profileCard.Size = UDim2.new(1,-20,0,64)
profileCard.Position = UDim2.new(0,10,1,-70)
profileCard.BackgroundColor3 = Color3.fromRGB(16,16,24)
profileCard.BorderSizePixel = 0
profileCard.Parent = sidebar

local pfCorner = Instance.new("UICorner")
pfCorner.CornerRadius = UDim.new(0,12)
pfCorner.Parent = profileCard

local pfName = Instance.new("TextLabel")
pfName.Size = UDim2.new(1,-14,0,22)
pfName.Position = UDim2.new(0,8,0,6)
pfName.BackgroundTransparency = 1
pfName.Font = Enum.Font.GothamSemibold
pfName.TextSize = 14
pfName.TextColor3 = Color3.fromRGB(255,255,255)
pfName.TextXAlignment = Enum.TextXAlignment.Left
pfName.Text = displayName
pfName.Parent = profileCard

local pfUser = Instance.new("TextLabel")
pfUser.Size = UDim2.new(1,-14,0,18)
pfUser.Position = UDim2.new(0,8,0,26)
pfUser.BackgroundTransparency = 1
pfUser.Font = Enum.Font.Gotham
pfUser.TextSize = 12
pfUser.TextColor3 = Color3.fromRGB(180,180,195)
pfUser.TextXAlignment = Enum.TextXAlignment.Left
pfUser.Text = "@"..userName
pfUser.Parent = profileCard

local pfTik = Instance.new("TextLabel")
pfTik.Size = UDim2.new(1,-14,0,16)
pfTik.Position = UDim2.new(0,8,0,44)
pfTik.BackgroundTransparency = 1
pfTik.Font = Enum.Font.Gotham
pfTik.TextSize = 11
pfTik.TextColor3 = Color3.fromRGB(255,190,80)
pfTik.TextXAlignment = Enum.TextXAlignment.Left
pfTik.Text = "TikTok: "..TIKTOK_HANDLE
pfTik.Parent = profileCard

---------------------------------------------------------------------//
-- CONTENT HOLDER / PAGES
---------------------------------------------------------------------//
local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1,-210,1,-40)
contentHolder.Position = UDim2.new(0,200,0,40)
contentHolder.BackgroundTransparency = 1
contentHolder.Parent = root

local function createPage(name)
    local f = Instance.new("Frame")
    f.Name = name.."Page"
    f.Size = UDim2.new(1,-10,1,-10)
    f.Position = UDim2.new(0,5,0,5)
    f.BackgroundColor3 = Color3.fromRGB(14,14,22)
    f.BorderSizePixel = 0
    f.Visible = false
    f.Parent = contentHolder

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,16)
    c.Parent = f

    local s = Instance.new("UIStroke")
    s.Thickness = 1
    s.Color = Color3.fromRGB(55,55,70)
    s.Parent = f

    pages[name] = f
    return f
end

local homePage     = createPage("Home")
local mainPage     = createPage("Main")
local blatantPage  = createPage("Blatant")
local othersPage   = createPage("Others")
local settingsPage = createPage("Settings")

local function setActivePage(name)
    for n,f in pairs(pages) do
        f.Visible = (n == name)
    end
    for n,b in pairs(navButtons) do
        b.BackgroundColor3 =
            (n == name) and Color3.fromRGB(40,40,55)
            or Color3.fromRGB(22,22,30)
    end
    currentPage = name
end

-- create nav buttons
navButton("Home","Home").MouseButton1Click:Connect(function()
    setActivePage("Home")
end)
navButton("Main","Main").MouseButton1Click:Connect(function()
    setActivePage("Main")
end)
navButton("Blatant","Blatant").MouseButton1Click:Connect(function()
    setActivePage("Blatant")
end)
navButton("Others","Others").MouseButton1Click:Connect(function()
    setActivePage("Others")
end)
navButton("Settings","Settings").MouseButton1Click:Connect(function()
    setActivePage("Settings")
end)

---------------------------------------------------------------------//
-- THEMES
---------------------------------------------------------------------//
local ThemeConfig = {
    Default = {
        Accent       = Color3.fromRGB(241,196,15),
        AccentOn     = Color3.fromRGB(88,214,141),
        AccentText   = Color3.fromRGB(241,196,15),
        RootTop      = Color3.fromRGB(25,25,35),
        RootBottom   = Color3.fromRGB(5,5,10),
    },
    Purple = {
        Accent       = Color3.fromRGB(187,85,255),
        AccentOn     = Color3.fromRGB(155,110,255),
        AccentText   = Color3.fromRGB(187,85,255),
        RootTop      = Color3.fromRGB(35,20,60),
        RootBottom   = Color3.fromRGB(10,0,20),
    },
    Aqua = {
        Accent       = Color3.fromRGB(52,183,235),
        AccentOn     = Color3.fromRGB(46,204,155),
        AccentText   = Color3.fromRGB(52,183,235),
        RootTop      = Color3.fromRGB(12,28,40),
        RootBottom   = Color3.fromRGB(0,8,16),
    },
    Custom = {
        Accent       = Color3.fromRGB(255,140,0),
        AccentOn     = Color3.fromRGB(255,180,60),
        AccentText   = Color3.fromRGB(255,200,120),
        RootTop      = Color3.fromRGB(25,25,35),
        RootBottom   = Color3.fromRGB(5,5,10),
    }
}

local currentTheme  = "Default"
local ThemeAccentOn = ThemeConfig.Default.AccentOn
CustomAccent = CustomAccent or ThemeConfig.Custom.Accent

local function applyTheme(name)
    if name == "Custom" then
        ThemeConfig.Custom.Accent     = CustomAccent
        ThemeConfig.Custom.AccentOn   = CustomAccent
        ThemeConfig.Custom.AccentText = CustomAccent
    end

    local th = ThemeConfig[name] or ThemeConfig.Default
    currentTheme  = name
    ThemeAccentOn = th.AccentOn

    buildPill.BackgroundColor3 = th.Accent
end

applyTheme("Default")

---------------------------------------------------------------------//
-- HOME PAGE
---------------------------------------------------------------------//
do
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-40,0,32)
    title.Position = UDim2.new(0,20,0,20)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "Welcome, "..displayName
    title.Parent = homePage

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1,-40,0,56)
    info.Position = UDim2.new(0,20,0,60)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 14
    info.TextWrapped = true
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.TextColor3 = Color3.fromRGB(210,210,220)
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Text = "Account: @"..userName..
        "\nUse the tabs to control your auto fire, parry, boosts and tools."
    info.Parent = homePage
end

---------------------------------------------------------------------//
-- LIVE STATUS PANEL (used on Main)
---------------------------------------------------------------------//
local fpsLabel, pingLabel, wsLabel, jpLabel, regionLabel
local liveStatusPanel

do
    local panel = Instance.new("Frame")
    liveStatusPanel = panel

    panel.Size = UDim2.new(0,230,0,110)
    panel.AnchorPoint = Vector2.new(1,0)
    panel.Position = UDim2.new(1,-20,0,20)
    panel.BackgroundColor3 = Color3.fromRGB(18,18,28)
    panel.BorderSizePixel = 0
    panel.ZIndex = 10
    panel.Parent = mainPage

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,12)
    c.ZIndex = 10
    c.Parent = panel

    local s = Instance.new("UIStroke")
    s.Thickness = 1
    s.Color = Color3.fromRGB(45,45,60)
    s.ZIndex = 10
    s.Parent = panel

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,-10,0,20)
    t.Position = UDim2.new(0,8,0,6)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamSemibold
    t.TextSize = 14
    t.TextColor3 = Color3.fromRGB(255,255,255)
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Text = "Live Status"
    t.ZIndex = 11
    t.Parent = panel

    local function mk(y, text)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,-16,0,16)
        l.Position = UDim2.new(0,8,0,y)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.Gotham
        l.TextSize = 12
        l.TextColor3 = Color3.fromRGB(210,210,220)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Text = text
        l.ZIndex = 11
        l.Parent = panel
        return l
    end

    fpsLabel    = mk(28,"FPS: --")
    pingLabel   = mk(44,"Ping: -- ms")
    wsLabel     = mk(60,"WalkSpeed: --")
    jpLabel     = mk(76,"JumpPower: --")
    regionLabel = mk(92,"Region: --")
end

local lastFps = 0
RunService.RenderStepped:Connect(function(dt)
    if dt > 0 then
        lastFps = math.floor(1/dt + 0.5)
    end
end)

local function getPingMs()
    local ok, ping = pcall(function()
        if LocalPlayer and LocalPlayer.GetNetworkPing then
            return LocalPlayer:GetNetworkPing()
        end
    end)
    if ok and ping then
        return math.floor(ping * 1000 + 0.5)
    end

    local Stats = game:FindService("Stats") or game:GetService("Stats")
    local success, ms = pcall(function()
        local net = Stats.Network
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
    if success and ms then return ms end
    return nil
end

local cachedRegion
local function getServerRegion()
    if cachedRegion ~= nil then return cachedRegion end

    local ok, joinData = pcall(function()
        return LocalPlayer and LocalPlayer:GetJoinData()
    end)
    if ok and joinData then
        if joinData.Region then
            cachedRegion = tostring(joinData.Region)
            return cachedRegion
        elseif joinData.matchmakingContext then
            cachedRegion = tostring(joinData.matchmakingContext)
            return cachedRegion
        end
    end

    local ok2, loc = pcall(function()
        return LocalizationService.RobloxLocaleId
            or LocalizationService.SystemLocaleId
    end)
    if ok2 and loc then
        cachedRegion = tostring(loc)
        return cachedRegion
    end

    cachedRegion = "Unknown"
    return cachedRegion
end

task.spawn(function()
    while true do
        local hum = getHumanoid()
        local ws,jp = 0,0
        if hum then
            ws = hum.WalkSpeed or 0
            if hum.UseJumpPower ~= nil then
                jp = hum.JumpPower or 0
            end
        end

        local pingMs = getPingMs()
        local region = getServerRegion()

        if fpsLabel then fpsLabel.Text = "FPS: "..tostring(lastFps) end
        if pingLabel then
            pingLabel.Text = pingMs and ("Ping: "..pingMs.." ms")
                or "Ping: N/A"
        end
        if wsLabel then wsLabel.Text = string.format("WalkSpeed: %.1f", ws) end
        if jpLabel then jpLabel.Text = string.format("JumpPower: %.1f", jp) end
        if regionLabel then regionLabel.Text = "Region: "..tostring(region) end

        task.wait(0.1)
    end
end)
---------------------------------------------------------------------//
-- CLICKER STATE + ROW HELPER (NEW – fixes blank tabs)
---------------------------------------------------------------------//
local clicking         = false
local cpsValue         = 10
local modeType         = "Toggle"   -- Hold / Toggle
local actionType       = "Click"    -- Click / Parry
local toggleKey        = Enum.KeyCode.E
local parryKey         = Enum.KeyCode.E
local manualKey        = Enum.KeyCode.R
local manualSpamActive = false
local triggerbotOn     = false
local antiAfkOn        = false

-- generic row builder for Main page
local function makeRow(parent, y, labelText)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-40,0,34)
    row.Position = UDim2.new(0,20,0,y)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-160,1,0)
    lbl.Position = UDim2.new(0,0,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(220,220,230)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = labelText
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,90,0,26)
    btn.Position = UDim2.new(1,-100,0.5,-13)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,50)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = "..."
    btn.Parent = row

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,8)
    c.Parent = btn

    return row, lbl, btn
end

---------------------------------------------------------------------//
-- MAIN PAGE (CLICKER / MODES)
---------------------------------------------------------------------//
do
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1,-40,0,26)
    header.Position = UDim2.new(0,20,0,16)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.GothamBlack
    header.TextSize = 20
    header.TextColor3 = Color3.fromRGB(255,255,255)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Text = "Main Hub"
    header.Parent = mainPage

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1,-40,0,20)
    status.Position = UDim2.new(0,20,0,44)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = 13
    status.TextColor3 = Color3.fromRGB(255,80,80)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Text = "Status: OFF (10 CPS, Toggle, Click)"
    status.Parent = mainPage

    local function updateStatus()
        local onOff = clicking and "ON" or "OFF"
        status.TextColor3 = clicking
            and Color3.fromRGB(80,255,120)
            or  Color3.fromRGB(255,80,80)
        status.Text = string.format(
            "Status: %s (%d CPS, %s, %s)",
            onOff, cpsValue, modeType, actionType
        )
    end

    local function shrinkRow(row)
        row.Size = UDim2.new(0,380,0,34)
    end

    local row1,_, modeBtn    = makeRow(mainPage,  80, "Mode Type (Hold/Toggle)")
    shrinkRow(row1)
    local row2,_, actionBtn  = makeRow(mainPage, 120, "Action Type (Click/Parry)")
    shrinkRow(row2)
    local row3,_, rapidBtn   = makeRow(mainPage, 160, "Rapid Fire (Hold-Only)")
    shrinkRow(row3)
    local row4,_, triggerBtn = makeRow(mainPage, 200, "Triggerbot (Parry Spam)")
    shrinkRow(row4)
    local row5,_, manualBtn  = makeRow(mainPage, 240, "Manual Spam Key (press to spam)")
    shrinkRow(row5)

    modeBtn.Text = modeType
    modeBtn.BackgroundColor3 = Color3.fromRGB(70,70,90)

    actionBtn.Text = actionType
    actionBtn.BackgroundColor3 = Color3.fromRGB(70,70,90)

    modeBtn.MouseButton1Click:Connect(function()
        modeType = (modeType == "Toggle") and "Hold" or "Toggle"
        modeBtn.Text = modeType
        updateStatus()
    end)

    actionBtn.MouseButton1Click:Connect(function()
        actionType = (actionType == "Click") and "Parry" or "Click"
        actionBtn.Text = actionType
        updateStatus()
    end)

    local function setToggleVisual(btn, on)
        btn.Text = on and "ON" or "OFF"
        btn.BackgroundColor3 = on and ThemeAccentOn
            or Color3.fromRGB(120,40,40)
    end

    local rapidOn = false
    setToggleVisual(rapidBtn,false)
    setToggleVisual(triggerBtn,false)

    rapidBtn.MouseButton1Click:Connect(function()
        rapidOn = not rapidOn
        setToggleVisual(rapidBtn, rapidOn)
    end)

    triggerBtn.MouseButton1Click:Connect(function()
        triggerbotOn = not triggerbotOn
        setToggleVisual(triggerBtn, triggerbotOn)
    end)

    manualBtn.Text = "Key: R"
    manualBtn.BackgroundColor3 = Color3.fromRGB(70,70,90)

    manualBtn.MouseButton1Click:Connect(function()
        manualBtn.Text = "Press..."
        local listening = true

        local conn; conn = UIS.InputBegan:Connect(function(inp,gp)
            if not listening or gp then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                manualKey = inp.KeyCode
                local name = tostring(manualKey):match("%.(.+)")
                    or tostring(manualKey)
                manualBtn.Text = "Key: "..name
                listening = false
                conn:Disconnect()
            end
        end)
    end)

    local cpsLabel = Instance.new("TextLabel")
    cpsLabel.Size = UDim2.new(0,60,0,18)
    cpsLabel.Position = UDim2.new(0,20,0,284)
    cpsLabel.BackgroundTransparency = 1
    cpsLabel.Font = Enum.Font.Gotham
    cpsLabel.TextSize = 13
    cpsLabel.TextColor3 = Color3.fromRGB(220,220,230)
    cpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    cpsLabel.Text = "CPS:"
    cpsLabel.Parent = mainPage

    local cpsBox = Instance.new("TextBox")
    cpsBox.Size = UDim2.new(0,60,0,22)
    cpsBox.Position = UDim2.new(0,60,0,282)
    cpsBox.BackgroundColor3 = Color3.fromRGB(26,26,34)
    cpsBox.BorderSizePixel = 0
    cpsBox.Font = Enum.Font.Gotham
    cpsBox.TextSize = 13
    cpsBox.TextColor3 = Color3.fromRGB(255,255,255)
    cpsBox.Text = tostring(cpsValue)
    cpsBox.ClearTextOnFocus = false
    cpsBox.Parent = mainPage

    local cpsCorner = Instance.new("UICorner")
    cpsCorner.CornerRadius = UDim.new(0,6)
    cpsCorner.Parent = cpsBox

    cpsBox.FocusLost:Connect(function()
        local n = tonumber(cpsBox.Text)
        if not n or n <= 0 then n = 10 end
        if n > 100 then n = 100 end
        cpsValue = n
        cpsBox.Text = tostring(n)
        updateStatus()
    end)

    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(0,200,0,32)
    startBtn.Position = UDim2.new(0,20,0,314)
    startBtn.BackgroundColor3 = Color3.fromRGB(80,80,100)
    startBtn.BorderSizePixel = 0
    startBtn.Font = Enum.Font.GothamBold
    startBtn.TextSize = 18
    startBtn.TextColor3 = Color3.fromRGB(255,255,255)
    startBtn.Text = "Start"
    startBtn.Parent = mainPage

    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(0,10)
    sbCorner.Parent = startBtn

    local function toggleClicker()
        clicking = not clicking
        if clicking then
            startBtn.Text = "Stop"
            startBtn.BackgroundColor3 = ThemeAccentOn
        else
            startBtn.Text = "Start"
            startBtn.BackgroundColor3 = Color3.fromRGB(80,80,100)
        end
        updateStatus()
    end

    startBtn.MouseButton1Click:Connect(toggleClicker)

    updateStatus()
end

---------------------------------------------------------------------//
-- BLATANT PAGE (SPEED & JUMP BOOSTS)
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

local function addTitleDesc(parent,title,desc)
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
end

local function makeToggleSmall(parent,x,y)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,42,0,20)
    frame.Position = UDim2.new(0,x,0,y)
    frame.BackgroundColor3 = Color3.fromRGB(40,40,50)
    frame.BorderSizePixel = 0
    frame.ZIndex = 3
    frame.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1,0); c.Parent = frame

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0,16,0,16)
    thumb.Position = UDim2.new(0,2,0.5,-8)
    thumb.BackgroundColor3 = Color3.fromRGB(80,80,90)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 4
    thumb.Parent = frame

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1,0); tc.Parent = thumb

    return frame, thumb
end

local function makeSlider(parent,y,minVal,maxVal,initial,cb)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-40,0,6)
    bar.Position = UDim2.new(0,10,0,y)
    bar.BackgroundColor3 = Color3.fromRGB(35,35,44)
    bar.BorderSizePixel = 0
    bar.ZIndex = 3
    bar.Parent = parent

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0,6); bc.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = ThemeAccentOn
    fill.BorderSizePixel = 0
    fill.ZIndex = 4
    fill.Parent = bar

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0,6); fc.Parent = fill

    local dragging = false

    local function setFromX(x)
        local rel = math.clamp(
            (x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,
            0,1
        )
        local v = minVal + (maxVal-minVal)*rel
        v = math.floor(v+0.5)
        tween(fill,{Size = UDim2.new(rel,0,1,0)},0.08)
        if cb then cb(v) end
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

    local rel = (initial-minVal)/(maxVal-minVal)
    fill.Size = UDim2.new(math.clamp(rel,0,1),0,1,0)
end

-- SPEED CARD
local speedCard = createBlatantCard(120)
addTitleDesc(
    speedCard,
    "Speed Boost",
    "Boost your WalkSpeed. Only affects you when toggle is ON. OFF = game default."
)

local speedValLabel = Instance.new("TextLabel")
speedValLabel.Size = UDim2.new(0,60,0,18)
speedValLabel.Position = UDim2.new(1,-70,0,10)
speedValLabel.BackgroundTransparency = 1
speedValLabel.Font = Enum.Font.Gotham
speedValLabel.TextSize = 12
speedValLabel.TextColor3 = Color3.fromRGB(220,220,230)
speedValLabel.TextXAlignment = Enum.TextXAlignment.Right
speedValLabel.Text = tostring(speedValue)
speedValLabel.ZIndex = 3
speedValLabel.Parent = speedCard

local speedToggle, speedThumb =
    makeToggleSmall(speedCard, speedCard.AbsoluteSize.X-60,10)
speedCard:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    speedToggle.Position = UDim2.new(1,-54,0,10)
end)

local function updateSpeedVisual()
    if speedEnabled then
        tween(speedToggle,{BackgroundColor3 = ThemeAccentOn},0.12)
        tween(speedThumb,{Position = UDim2.new(1,-18,0.5,-8)},0.12)
    else
        tween(speedToggle,{BackgroundColor3 = Color3.fromRGB(40,40,50)},0.12)
        tween(speedThumb,{Position = UDim2.new(0,2,0.5,-8)},0.12)
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

makeSlider(speedCard,68,10,100,speedValue,function(v)
    speedValue = v
    speedValLabel.Text = tostring(v)
    if speedEnabled then applySpeed() end
end)

speedToggle.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        speedEnabled = not speedEnabled
        updateSpeedVisual()
        if speedEnabled then applySpeed() else resetSpeed() end
    end
end)
updateSpeedVisual()

-- JUMP CARD
local jumpCard = createBlatantCard(120)
addTitleDesc(
    jumpCard,
    "Jump Boost",
    "Boost your JumpPower. Only affects you when toggle is ON. OFF = game default."
)

local jumpValLabel = Instance.new("TextLabel")
jumpValLabel.Size = UDim2.new(0,60,0,18)
jumpValLabel.Position = UDim2.new(1,-70,0,10)
jumpValLabel.BackgroundTransparency = 1
jumpValLabel.Font = Enum.Font.Gotham
jumpValLabel.TextSize = 12
jumpValLabel.TextColor3 = Color3.fromRGB(220,220,230)
jumpValLabel.TextXAlignment = Enum.TextXAlignment.Right
jumpValLabel.Text = tostring(jumpValue)
jumpValLabel.ZIndex = 3
jumpValLabel.Parent = jumpCard

local jumpToggle, jumpThumb =
    makeToggleSmall(jumpCard,jumpCard.AbsoluteSize.X-60,10)
jumpCard:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    jumpToggle.Position = UDim2.new(1,-54,0,10)
end)

local function updateJumpVisual()
    if jumpEnabled then
        tween(jumpToggle,{BackgroundColor3 = ThemeAccentOn},0.12)
        tween(jumpThumb,{Position = UDim2.new(1,-18,0.5,-8)},0.12)
    else
        tween(jumpToggle,{BackgroundColor3 = Color3.fromRGB(40,40,50)},0.12)
        tween(jumpThumb,{Position = UDim2.new(0,2,0.5,-8)},0.12)
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

makeSlider(jumpCard,68,25,150,jumpValue,function(v)
    jumpValue = v
    jumpValLabel.Text = tostring(v)
    if jumpEnabled then applyJump() end
end)

jumpToggle.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        jumpEnabled = not jumpEnabled
        updateJumpVisual()
        if jumpEnabled then applyJump() else resetJump() end
    end
end)
updateJumpVisual()

LocalPlayer.CharacterAdded:Connect(function()
    originalWalkSpeed = nil
    originalJumpPower = nil
    task.delay(1.5,function()
        if speedEnabled then applySpeed() end
        if jumpEnabled  then applyJump()  end
    end)
end)

---------------------------------------------------------------------//
-- OTHERS PAGE (BUG REPORT + ANTI AFK + SIMPLE UPDATER UI)
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
    c.CornerRadius = UDim.new(0,12); c.Parent = f

    local s = Instance.new("UIStroke")
    s.Thickness = 1; s.Color = Color3.fromRGB(55,55,65); s.Parent = f
    return f
end

-- Bug report card
local bugCard = createOthersCard(190)
addTitleDesc(
    bugCard,
    "Bug Report",
    "Found something broken? send a report with your executor name."
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
bugBox.PlaceholderText = "Explain what happened, what you were doing, errors, etc..."
bugBox.ZIndex = 3
bugBox.Parent = bugCard

local bugCorner = Instance.new("UICorner")
bugCorner.CornerRadius = UDim.new(0,8); bugCorner.Parent = bugBox

local sendBugBtn = Instance.new("TextButton")
sendBugBtn.Size = UDim2.new(0,120,0,28)
sendBugBtn.Position = UDim2.new(0,10,0,160)
sendBugBtn.BackgroundColor3 = ThemeAccentOn
sendBugBtn.BorderSizePixel = 0
sendBugBtn.Font = Enum.Font.GothamBold
sendBugBtn.TextSize = 14
sendBugBtn.TextColor3 = Color3.fromRGB(255,255,255)
sendBugBtn.Text = "Send Report"
sendBugBtn.ZIndex = 3
sendBugBtn.Parent = bugCard

local sbc = Instance.new("UICorner")
sbc.CornerRadius = UDim.new(0,8); sbc.Parent = sendBugBtn

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
        local ok,err = sendBugReport(txt)
        if ok then
            bugBox.Text = ""
            bugStatus.TextColor3 = Color3.fromRGB(120,220,120)
            bugStatus.Text = "Bug sent!"
        else
            bugStatus.TextColor3 = Color3.fromRGB(255,120,120)
            bugStatus.Text = "Failed ("..tostring(err or "error")..")"
        end
    end)
end)

-- System tools card
local sysCard = createOthersCard(150)
addTitleDesc(sysCard,"System Tools","Anti-AFK + simple updater info.")

local antiLabel = Instance.new("TextLabel")
antiLabel.Size = UDim2.new(0,100,0,20)
antiLabel.Position = UDim2.new(0,10,0,60)
antiLabel.BackgroundTransparency = 1
antiLabel.Font = Enum.Font.Gotham
antiLabel.TextSize = 13
antiLabel.TextColor3 = Color3.fromRGB(220,220,230)
antiLabel.TextXAlignment = Enum.TextXAlignment.Left
antiLabel.Text = "Anti-AFK:"
antiLabel.ZIndex = 3
antiLabel.Parent = sysCard

local antiToggle, antiThumb = makeToggleSmall(sysCard, 90,60)
local function updateAntiVisual()
    if antiAfkOn then
        tween(antiToggle,{BackgroundColor3 = ThemeAccentOn},0.12)
        tween(antiThumb,{Position = UDim2.new(1,-18,0.5,-8)},0.12)
    else
        tween(antiToggle,{BackgroundColor3 = Color3.fromRGB(40,40,50)},0.12)
        tween(antiThumb,{Position = UDim2.new(0,2,0.5,-8)},0.12)
    end
end
antiToggle.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        antiAfkOn = not antiAfkOn
        updateAntiVisual()
    end
end)
updateAntiVisual()

local updLabel = Instance.new("TextLabel")
updLabel.Size = UDim2.new(1,-20,0,20)
updLabel.Position = UDim2.new(0,10,0,96)
updLabel.BackgroundTransparency = 1
updLabel.Font = Enum.Font.Gotham
updLabel.TextSize = 12
updLabel.TextColor3 = Color3.fromRGB(200,200,210)
updLabel.TextXAlignment = Enum.TextXAlignment.Left
updLabel.Text = "Updater: manual for now (Build "..CURRENT_VERSION..")"
updLabel.ZIndex = 3
updLabel.Parent = sysCard

---------------------------------------------------------------------//
-- SETTINGS PAGE (THEMES + CUSTOM ACCENT)
---------------------------------------------------------------------//
local settingsScroll = Instance.new("ScrollingFrame")
settingsScroll.Size = UDim2.new(1,0,1,0)
settingsScroll.CanvasSize = UDim2.new(0,0,0,220)
settingsScroll.BackgroundTransparency = 1
settingsScroll.BorderSizePixel = 0
settingsScroll.ScrollBarThickness = 4
settingsScroll.Parent = settingsPage

local sLayout = Instance.new("UIListLayout")
sLayout.SortOrder = Enum.SortOrder.LayoutOrder
sLayout.Padding   = UDim.new(0,16)
sLayout.Parent    = settingsScroll

local function createSettingsCard(height)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-40,0,height)
    f.BackgroundColor3 = Color3.fromRGB(20,20,28)
    f.BorderSizePixel = 0
    f.ZIndex = 2
    f.Parent = settingsScroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,12); c.Parent = f

    local s = Instance.new("UIStroke")
    s.Thickness = 1; s.Color = Color3.fromRGB(55,55,65); s.Parent = f
    return f
end

local function addSettingsTitle(parent,text)
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
end

local function addSettingsDesc(parent,y,text)
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
end

local themeCard = createSettingsCard(170)
addSettingsTitle(themeCard,"Theme & Appearance")
addSettingsDesc(
    themeCard,
    32,
    "Pick a preset or use your own accent color. Custom accent updates the whole hub."
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

local function makePresetButton(txt,x,themeName)
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
    c.CornerRadius = UDim.new(0,8); c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        applyTheme(themeName)
    end)
end

makePresetButton("Default",10,"Default")
makePresetButton("Purple",90,"Purple")
makePresetButton("Aqua",170,"Aqua")
makePresetButton("Custom",250,"Custom")

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

local function makeRGBBox(x,placeholder)
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
    c.CornerRadius = UDim.new(0,6); c.Parent = box

    return box
end

local rBox = makeRGBBox(10,"R")
local gBox = makeRGBBox(62,"G")
local bBox = makeRGBBox(114,"B")

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
rgbCorner.CornerRadius = UDim.new(0,6); rgbCorner.Parent = applyRGBBtn

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

    r = math.clamp(math.floor(r+0.5),0,255)
    g = math.clamp(math.floor(g+0.5),0,255)
    b = math.clamp(math.floor(b+0.5),0,255)

    CustomAccent = Color3.fromRGB(r,g,b)
    rgbStatus.TextColor3 = Color3.fromRGB(120,220,120)
    rgbStatus.Text = "Applied."
    applyTheme("Custom")
end

applyRGBBtn.MouseButton1Click:Connect(applyCustomRGB)

local infoCard = createSettingsCard(90)
addSettingsTitle(infoCard,"Info")
addSettingsDesc(
    infoCard,
    32,
    "RightCtrl = show / hide hub.\nTikTok: "..TIKTOK_HANDLE
)
---------------------------------------------------------------------//
-- INPUT HANDLING (TOGGLES / CLICKER / MANUAL)
---------------------------------------------------------------------//
UIS.InputBegan:Connect(function(input,gp)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.RightControl then
            guiVisible = not guiVisible
            gui.Enabled = guiVisible
            return
        end

        if gp then return end

        if input.KeyCode == toggleKey then
            if modeType == "Toggle" then
                clicking = not clicking
            else
                clicking = true
            end
        end

        if input.KeyCode == manualKey then
            manualSpamActive = true
        end
    end
end)

UIS.InputEnded:Connect(function(input,gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == toggleKey and modeType == "Hold" then
            clicking = false
        end
        if input.KeyCode == manualKey then
            manualSpamActive = false
        end
    end
end)

---------------------------------------------------------------------//
-- ANTI AFK LOOP
---------------------------------------------------------------------//
if not getgenv().__BinHub_AntiAfkHooked then
    getgenv().__BinHub_AntiAfkHooked = true
    task.spawn(function()
        local vu
        pcall(function() vu = game:GetService("VirtualUser") end)
        if LocalPlayer then
            LocalPlayer.Idled:Connect(function()
                if not antiAfkOn then return end
                if vu then
                    pcall(function()
                        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                        task.wait(0.1)
                        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    end)
                end
            end)
        end
    end)
end

---------------------------------------------------------------------//
-- MAIN SPAM LOOP
---------------------------------------------------------------------//
task.spawn(function()
    while true do
        if clicking or triggerbotOn or manualSpamActive then
            local delay = 1 / math.max(cpsValue,1)
            if actionType == "Click" then
                if clicking or manualSpamActive then
                    pcall(function() mouse1click() end)
                end
            else
                if (clicking or manualSpamActive or triggerbotOn)
                    and VIM and parryKey then
                    pcall(function()
                        VIM:SendKeyEvent(true, parryKey, false, game)
                        task.wait(0.01)
                        VIM:SendKeyEvent(false, parryKey, false, game)
                    end)
                end
            end
            task.wait(delay)
        else
            task.wait(0.05)
        end
    end
end)

---------------------------------------------------------------------//
-- BOTTOM-RIGHT TOAST NOTIFICATIONS (NEW)
---------------------------------------------------------------------//
local function showToast(message, order)
    order = order or 1
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(0,260,0,36)
    toast.AnchorPoint = Vector2.new(1,1)
    toast.Position = UDim2.new(1,-20,1,-20 - (order-1)*40)
    toast.BackgroundColor3 = Color3.fromRGB(18,18,26)
    toast.BorderSizePixel = 0
    toast.BackgroundTransparency = 1
    toast.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,10)
    corner.Parent = toast

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(60,60,80)
    stroke.Parent = toast

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-16,1,-8)
    lbl.Position = UDim2.new(0,8,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = message
    lbl.TextTransparency = 1
    lbl.Parent = toast

    tween(toast,{BackgroundTransparency = 0},0.2)
    tween(lbl,{TextTransparency = 0},0.2)

    task.delay(3,function()
        tween(toast,{BackgroundTransparency = 1},0.3)
        tween(lbl,{TextTransparency = 1},0.3)
        task.delay(0.35,function()
            if toast then toast:Destroy() end
        end)
    end)
end

---------------------------------------------------------------------//
-- FINAL INIT
---------------------------------------------------------------------//
setActivePage("Home")

task.spawn(function()
    task.wait(1)
    local ok,err = pcall(sendWebhookLog)
    if not ok then
        warn("[BinHubX] Failed to send execution log: "..tostring(err))
    end
end)

-- show the two notifications at bottom-right
task.spawn(function()
    task.wait(1.2)
    showToast("Anticheat bypass loaded.", 1)
    task.wait(0.6)
    showToast("Script made by Binxix.", 2)
end)
