-- Bin Hub X - Argon-style Hub v2.6 + Webhook + TikTok + Bug Reports
-- • Auto Click / Auto Parry (CPS, Toggle/Hold, keybinds)
-- • Blatant tab: (Semi Immortal shown but TEMPORARILY DISABLED), Settings, Speed/Jump sliders, Manual Spam, Triggerbot
-- • RightCtrl = Show/Hide hub
-- • Window only moves when dragging the top bar
-- • Home page + sidebar show the Roblox account + TikTok
-- • On execute: sends username, displayname, game, place, job, time to your Discord webhook
-- • Settings tab: Bug report box that sends to the same webhook

---------------------------------------------------------------------//
-- SERVICES / SETUP
---------------------------------------------------------------------//
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local CoreGui      = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")

local VIM
pcall(function()
    VIM = game:GetService("VirtualInputManager")
end)

local LocalPlayer = Players.LocalPlayer

-- TikTok handle (change this if you want a different @)
local TIKTOK_HANDLE = "@binxix"

---------------------------------------------------------------------//
-- WEBHOOK LOG (runs once when script is executed) + BUG REPORTS
---------------------------------------------------------------------//
local WEBHOOK_URL = "https://discord.com/api/webhooks/1446656470287651050/ayflCl7nEQ3388YhXAZT7r3j5kTC40EP3WV9yO1BehR2vzHbtoDArV-YejWn_E_F6eUk"

local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local function getGameName()
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if ok and info and info.Name then
        return info.Name
    end
    return "Unknown Game"
end

local function getRequestFunction()
    return (syn and syn.request)
        or (http and http.request)
        or http_request
        or request
        or nil
end

local function getBasicEmbedFields()
    local gameName = getGameName()
    local placeId  = tostring(game.PlaceId)
    local jobId    = tostring(game.JobId)

    local username     = LocalPlayer and LocalPlayer.Name or "UnknownUser"
    local displayName  = LocalPlayer and LocalPlayer.DisplayName or username

    local timestamp = os.date("%Y-%m-%d %H:%M:%S")

    return {
        username = username,
        displayName = displayName,
        gameName = gameName,
        placeId = placeId,
        jobId = jobId,
        timestamp = timestamp,
    }
end

local function sendWebhookLog()
    if not WEBHOOK_URL or WEBHOOK_URL == "" then
        return
    end

    local req = getRequestFunction()
    if not req then
        return
    end

    local meta = getBasicEmbedFields()

    local payload = {
        embeds = {
            {
                title = "Bin Hub X - Script Executed",
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
                        name = "Time",
                        value = "```" .. meta.timestamp .. "```",
                        inline = false
                    }
                }
            }
        }
    }

    local json = HttpService:JSONEncode(payload)

    pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
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

    if not messageText or messageText:gsub("%s+", "") == "" then
        return false, "Empty"
    end

    local meta = getBasicEmbedFields()
    local trimmed = messageText
    if #trimmed > 1000 then
        trimmed = trimmed:sub(1, 1000) .. "..."
    end

    local payload = {
        embeds = {
            {
                title = "Bin Hub X - Bug Report",
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
                        name = "Time",
                        value = "```" .. meta.timestamp .. "```",
                        inline = false
                    },
                    {
                        name = "Bug Report",
                        value = "```" .. trimmed .. "```",
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
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = json
        })
    end)

    if not ok then
        return false, tostring(err)
    end
    return true
end

---------------------------------------------------------------------//
-- HELPERS / GUI PARENT
---------------------------------------------------------------------//
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
-- ROOT WINDOW + PARTICLES
---------------------------------------------------------------------//
local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.new(0, 720, 0, 380)
root.Position = UDim2.new(0.5, -360, 0.5, -190)
root.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
root.BorderSizePixel = 0
root.Parent = gui

local rootCorner = Instance.new("UICorner")
rootCorner.CornerRadius = UDim.new(0, 18)
rootCorner.Parent = root

local rootStroke = Instance.new("UIStroke")
rootStroke.Thickness = 1
rootStroke.Color = Color3.fromRGB(60, 60, 60)
rootStroke.Parent = root

local rootGrad = Instance.new("UIGradient")
rootGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,26)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5,5,10))
}
rootGrad.Rotation = 45
rootGrad.Parent = root

local function createDot()
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 4, 0, 4)
    dot.BackgroundColor3 = Color3.fromRGB(
        math.random(140,255),
        math.random(80,255),
        math.random(80,255)
    )
    dot.BorderSizePixel = 0
    dot.ZIndex = 0
    dot.Parent = root

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = dot

    local function tweenDot()
        dot.Position = UDim2.new(math.random(),0,math.random(),0)
        local goal = {Position = UDim2.new(math.random(),0,math.random(),0)}
        local ti = TweenInfo.new(math.random(10,20), Enum.EasingStyle.Linear)
        TweenService:Create(dot, ti, goal):Play()
    end
    tweenDot()
end

for i = 1, 40 do
    createDot()
end

---------------------------------------------------------------------//
-- SIDEBAR
---------------------------------------------------------------------//
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 230, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 2
sidebar.Parent = root

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 18)
sidebarCorner.Parent = sidebar

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Thickness = 1
sidebarStroke.Color = Color3.fromRGB(40, 40, 45)
sidebarStroke.Parent = sidebar

local displayName = (LocalPlayer and LocalPlayer.DisplayName) or "Player"
local userName    = (LocalPlayer and LocalPlayer.Name)        or "Unknown"

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, -80, 0, 30)
titleBar.Position = UDim2.new(0, 18, 0, 14)
titleBar.BackgroundTransparency = 1
titleBar.Font = Enum.Font.GothamBlack
titleBar.TextSize = 20
titleBar.Text = "Argon-Bin Hub"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.ZIndex = 3
titleBar.Parent = sidebar

local versionPill = Instance.new("TextLabel")
versionPill.Size = UDim2.new(0, 60, 0, 22)
versionPill.Position = UDim2.new(1, -72, 0, 14)
versionPill.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
versionPill.BorderSizePixel = 0
versionPill.Font = Enum.Font.GothamBold
versionPill.Text = "v2.6"
versionPill.TextSize = 14
versionPill.TextColor3 = Color3.fromRGB(255, 255, 255)
versionPill.ZIndex = 3
versionPill.Parent = sidebar

local vCorner = Instance.new("UICorner")
vCorner.CornerRadius = UDim.new(1, 0)
vCorner.Parent = versionPill

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -36, 0, 32)
searchBox.Position = UDim2.new(0, 18, 0, 54)
searchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "Search"
searchBox.Text = ""
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
searchBox.ZIndex = 3
searchBox.Parent = sidebar

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 10)
searchCorner.Parent = searchBox

local navHolder = Instance.new("Frame")
navHolder.Size = UDim2.new(1, -36, 1, -150)
navHolder.Position = UDim2.new(0, 18, 0, 96)
navHolder.BackgroundTransparency = 1
navHolder.ZIndex = 3
navHolder.Parent = sidebar

local navLayout = Instance.new("UIListLayout")
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Padding = UDim.new(0, 4)
navLayout.Parent = navHolder

local pages      = {}
local navButtons = {}
local currentPage

local function setActivePage(name)
    for n, frame in pairs(pages) do
        frame.Visible = (n == name)
    end
    for n, btn in pairs(navButtons) do
        btn.BackgroundColor3 = (n == name) and Color3.fromRGB(55,55,65) or Color3.fromRGB(25,25,32)
    end
    currentPage = name
end

local function sectionLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(150, 150, 165)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 3
    lbl.Parent = navHolder
end

local function navButton(name, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(235, 235, 240)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = text
    btn.ZIndex = 3
    btn.Parent = navHolder

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        setActivePage(name)
    end)

    navButtons[name] = btn
end

sectionLabel("Home")
navButton("Home", ".Home")

sectionLabel("Main")
navButton("Main", "Main")
navButton("Blatant", "Blatant")
navButton("Others", "Others")

sectionLabel("Settings")
navButton("Settings", "Settings")

local profileFrame = Instance.new("Frame")
profileFrame.Size = UDim2.new(1, -36, 0, 76)
profileFrame.Position = UDim2.new(0, 18, 1, -86)
profileFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
profileFrame.BorderSizePixel = 0
profileFrame.ZIndex = 3
profileFrame.Parent = sidebar

local pfCorner = Instance.new("UICorner")
pfCorner.CornerRadius = UDim.new(0, 14)
pfCorner.Parent = profileFrame

local pfName = Instance.new("TextLabel")
pfName.Size = UDim2.new(1, -10, 0, 22)
pfName.Position = UDim2.new(0, 10, 0, 6)
pfName.BackgroundTransparency = 1
pfName.Font = Enum.Font.GothamBold
pfName.TextSize = 14
pfName.TextColor3 = Color3.fromRGB(255, 255, 255)
pfName.TextXAlignment = Enum.TextXAlignment.Left
pfName.Text = displayName
pfName.ZIndex = 4
pfName.Parent = profileFrame

local pfTag = Instance.new("TextLabel")
pfTag.Size = UDim2.new(1, -10, 0, 18)
pfTag.Position = UDim2.new(0, 10, 0, 26)
pfTag.BackgroundTransparency = 1
pfTag.Font = Enum.Font.Gotham
pfTag.TextSize = 12
pfTag.TextColor3 = Color3.fromRGB(170, 170, 185)
pfTag.TextXAlignment = Enum.TextXAlignment.Left
pfTag.Text = "@" .. userName
pfTag.ZIndex = 4
pfTag.Parent = profileFrame

local pfTikTok = Instance.new("TextLabel")
pfTikTok.Size = UDim2.new(1, -10, 0, 18)
pfTikTok.Position = UDim2.new(0, 10, 0, 46)
pfTikTok.BackgroundTransparency = 1
pfTikTok.Font = Enum.Font.Gotham
pfTikTok.TextSize = 12
pfTikTok.TextColor3 = Color3.fromRGB(200, 120, 220)
pfTikTok.TextXAlignment = Enum.TextXAlignment.Left
pfTikTok.Text = "TikTok: " .. TIKTOK_HANDLE
pfTikTok.ZIndex = 4
pfTikTok.Parent = profileFrame

---------------------------------------------------------------------//
-- TOP BAR + DRAGGING (ONLY TOP BAR MOVES HUB)
---------------------------------------------------------------------//
local contentTop = Instance.new("Frame")
contentTop.Size = UDim2.new(1, -230, 0, 36)
contentTop.Position = UDim2.new(0, 230, 0, 0)
contentTop.BackgroundTransparency = 1
contentTop.ZIndex = 2
contentTop.Parent = root

local topTitle = Instance.new("TextLabel")
topTitle.Size = UDim2.new(1, -80, 1, 0)
topTitle.Position = UDim2.new(0, 10, 0, 0)
topTitle.BackgroundTransparency = 1
topTitle.Font = Enum.Font.GothamBold
topTitle.TextSize = 18
topTitle.TextXAlignment = Enum.TextXAlignment.Left
topTitle.TextColor3 = Color3.fromRGB(235, 235, 240)
topTitle.Text = "AutoClicker + Parry Hub"
topTitle.ZIndex = 2
topTitle.Parent = contentTop

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -32, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "X"
closeBtn.ZIndex = 2
closeBtn.Parent = contentTop

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
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

local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -230, 1, -40)
contentHolder.Position = UDim2.new(0, 230, 0, 40)
contentHolder.BackgroundTransparency = 1
contentHolder.ZIndex = 1
contentHolder.Parent = root

local function createPage(name)
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    page.BorderSizePixel = 0
    page.Visible = false
    page.ZIndex = 2
    page.Parent = contentHolder

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 16)
    c.Parent = page

    local s = Instance.new("UIStroke")
    s.Thickness = 1
    s.Color = Color3.fromRGB(40, 40, 45)
    s.Parent = page

    pages[name] = page
    return page
end

---------------------------------------------------------------------//
-- PAGES
---------------------------------------------------------------------//
local homePage     = createPage("Home")
local mainPage     = createPage("Main")
local blatantPage  = createPage("Blatant")
local othersPage   = createPage("Others")
local settingsPage = createPage("Settings")

-- HOME PAGE
do
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -40, 0, 40)
    t.Position = UDim2.new(0, 20, 0, 20)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBlack
    t.TextSize = 26
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Top
    t.Text = "Hello, " .. displayName
    t.ZIndex = 3
    t.Parent = homePage

    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1, -40, 0, 70)
    d.Position = UDim2.new(0, 20, 0, 60)
    d.BackgroundTransparency = 1
    d.Font = Enum.Font.Gotham
    d.TextSize = 14
    d.TextColor3 = Color3.fromRGB(210, 210, 220)
    d.TextWrapped = true
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextYAlignment = Enum.TextYAlignment.Top
    d.Text = "Account: @" .. userName .. "\nThis hub controls your auto clicker, auto parry spam and player options for your game."
    d.ZIndex = 3
    d.Parent = homePage

    local tk = Instance.new("TextLabel")
    tk.Size = UDim2.new(1, -40, 0, 24)
    tk.Position = UDim2.new(0, 20, 0, 140)
    tk.BackgroundTransparency = 1
    tk.Font = Enum.Font.GothamSemibold
    tk.TextSize = 14
    tk.TextColor3 = Color3.fromRGB(200, 120, 220)
    tk.TextXAlignment = Enum.TextXAlignment.Left
    tk.TextYAlignment = Enum.TextYAlignment.Top
    tk.Text = "TikTok: " .. TIKTOK_HANDLE
    tk.ZIndex = 3
    tk.Parent = homePage
end

local function simpleLabel(parent, txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -40, 1, -40)
    l.Position = UDim2.new(0, 20, 0, 20)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham
    l.TextSize = 16
    l.TextWrapped = true
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Top
    l.TextColor3 = Color3.fromRGB(230, 230, 235)
    l.Text = txt
    l.ZIndex = 3
    l.Parent = parent
end

simpleLabel(othersPage,   "Others tab placeholder.\nAdd extra tools here later.")

-- SETTINGS PAGE (bug report)
local bugStatusLabel -- forward ref

do
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 28)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "Settings & Bug Reports"
    title.ZIndex = 3
    title.Parent = settingsPage

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -40, 0, 50)
    info.Position = UDim2.new(0, 20, 0, 52)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 13
    info.TextColor3 = Color3.fromRGB(200, 200, 210)
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.Text = "• RightCtrl = Show/Hide hub\n• Drag ONLY the top bar to move hub\n• Use the box below to send bug reports straight to the dev webhook."
    info.ZIndex = 3
    info.Parent = settingsPage

    local bugLabel = Instance.new("TextLabel")
    bugLabel.Size = UDim2.new(1, -40, 0, 20)
    bugLabel.Position = UDim2.new(0, 20, 0, 110)
    bugLabel.BackgroundTransparency = 1
    bugLabel.Font = Enum.Font.GothamSemibold
    bugLabel.TextSize = 14
    bugLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
    bugLabel.TextXAlignment = Enum.TextXAlignment.Left
    bugLabel.Text = "Bug Report:"
    bugLabel.ZIndex = 3
    bugLabel.Parent = settingsPage

    local bugBox = Instance.new("TextBox")
    bugBox.Size = UDim2.new(1, -40, 0, 130)
    bugBox.Position = UDim2.new(0, 20, 0, 134)
    bugBox.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    bugBox.BorderSizePixel = 0
    bugBox.Font = Enum.Font.Gotham
    bugBox.TextSize = 14
    bugBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    bugBox.PlaceholderText = "Describe the bug, what happened, and what you were doing..."
    bugBox.TextWrapped = true
    bugBox.MultiLine = true
    bugBox.ClearTextOnFocus = false
    bugBox.ZIndex = 3
    bugBox.Parent = settingsPage

    local bugCorner = Instance.new("UICorner")
    bugCorner.CornerRadius = UDim.new(0, 10)
    bugCorner.Parent = bugBox

    local bugButton = Instance.new("TextButton")
    bugButton.Size = UDim2.new(0, 160, 0, 30)
    bugButton.Position = UDim2.new(0, 20, 0, 274)
    bugButton.BackgroundColor3 = Color3.fromRGB(70, 90, 160)
    bugButton.BorderSizePixel = 0
    bugButton.Font = Enum.Font.GothamBold
    bugButton.TextSize = 14
    bugButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    bugButton.Text = "Send Bug Report"
    bugButton.ZIndex = 3
    bugButton.Parent = settingsPage

    local bugBtnCorner = Instance.new("UICorner")
    bugBtnCorner.CornerRadius = UDim.new(0, 10)
    bugBtnCorner.Parent = bugButton

    bugStatusLabel = Instance.new("TextLabel")
    bugStatusLabel.Size = UDim2.new(1, -200, 0, 20)
    bugStatusLabel.Position = UDim2.new(0, 190, 0, 278)
    bugStatusLabel.BackgroundTransparency = 1
    bugStatusLabel.Font = Enum.Font.Gotham
    bugStatusLabel.TextSize = 12
    bugStatusLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    bugStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    bugStatusLabel.Text = ""
    bugStatusLabel.ZIndex = 3
    bugStatusLabel.Parent = settingsPage

    bugButton.MouseButton1Click:Connect(function()
        local text = bugBox.Text or ""
        if text:gsub("%s+", "") == "" then
            bugStatusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
            bugStatusLabel.Text = "Type something first."
            return
        end

        bugStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
        bugStatusLabel.Text = "Sending..."

        task.spawn(function()
            local ok, err = sendBugReport(text)
            if ok then
                bugBox.Text = ""
                bugStatusLabel.TextColor3 = Color3.fromRGB(120, 220, 120)
                bugStatusLabel.Text = "Bug sent!"
            else
                bugStatusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
                bugStatusLabel.Text = "Failed to send (" .. tostring(err or "unknown") .. ")"
            end
        end)
    end)
end

---------------------------------------------------------------------//
-- MAIN PAGE: AutoClicker + Parry
---------------------------------------------------------------------//
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 24)
status.Position = UDim2.new(0, 20, 0, 20)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 16
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextColor3 = Color3.fromRGB(255, 80, 80)
status.Text = "Status: OFF (Toggle, Click)"
status.ZIndex = 3
status.Parent = mainPage

local cpsLabel = Instance.new("TextLabel")
cpsLabel.Size = UDim2.new(0, 80, 0, 20)
cpsLabel.Position = UDim2.new(0, 20, 0, 60)
cpsLabel.BackgroundTransparency = 1
cpsLabel.Font = Enum.Font.Gotham
cpsLabel.TextSize = 14
cpsLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
cpsLabel.TextXAlignment = Enum.TextXAlignment.Left
cpsLabel.Text = "CPS:"
cpsLabel.ZIndex = 3
cpsLabel.Parent = mainPage

local cpsBox = Instance.new("TextBox")
cpsBox.Size = UDim2.new(0, 70, 0, 24)
cpsBox.Position = UDim2.new(0, 70, 0, 58)
cpsBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
cpsBox.BorderSizePixel = 0
cpsBox.Font = Enum.Font.Gotham
cpsBox.TextSize = 14
cpsBox.TextColor3 = Color3.fromRGB(255, 255, 255)
cpsBox.Text = "10"
cpsBox.ClearTextOnFocus = false
cpsBox.ZIndex = 3
cpsBox.Parent = mainPage

local cpsCorner = Instance.new("UICorner")
cpsCorner.CornerRadius = UDim.new(0, 8)
cpsCorner.Parent = cpsBox

local keyLabel = cpsLabel:Clone()
keyLabel.Text = "Click Keybind:"
keyLabel.Position = UDim2.new(0, 20, 0, 96)
keyLabel.Parent = mainPage

local keyButton = Instance.new("TextButton")
keyButton.Size = UDim2.new(0, 70, 0, 24)
keyButton.Position = UDim2.new(0, 130, 0, 94)
keyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
keyButton.BorderSizePixel = 0
keyButton.Font = Enum.Font.GothamBold
keyButton.TextSize = 14
keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
keyButton.Text = "F"
keyButton.ZIndex = 3
keyButton.Parent = mainPage

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 8)
keyCorner.Parent = keyButton

local modeLabel = cpsLabel:Clone()
modeLabel.Text = "Mode:"
modeLabel.Position = UDim2.new(0, 20, 0, 132)
modeLabel.Parent = mainPage

local modeButton = Instance.new("TextButton")
modeButton.Size = UDim2.new(0, 90, 0, 24)
modeButton.Position = UDim2.new(0, 80, 0, 130)
modeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
modeButton.BorderSizePixel = 0
modeButton.Font = Enum.Font.GothamBold
modeButton.TextSize = 14
modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
modeButton.Text = "Toggle"
modeButton.ZIndex = 3
modeButton.Parent = mainPage

local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0, 8)
modeCorner.Parent = modeButton

local actionLabel = cpsLabel:Clone()
actionLabel.Text = "Action:"
actionLabel.Position = UDim2.new(0, 20, 0, 168)
actionLabel.Parent = mainPage

local actionButton = Instance.new("TextButton")
actionButton.Size = UDim2.new(0, 90, 0, 24)
actionButton.Position = UDim2.new(0, 80, 0, 166)
actionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
actionButton.BorderSizePixel = 0
actionButton.Font = Enum.Font.GothamBold
actionButton.TextSize = 14
actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
actionButton.Text = "Click"
actionButton.ZIndex = 3
actionButton.Parent = mainPage

local actionCorner = Instance.new("UICorner")
actionCorner.CornerRadius = UDim.new(0, 8)
actionCorner.Parent = actionButton

local parryKeyLabel = cpsLabel:Clone()
parryKeyLabel.Text = "Parry Key:"
parryKeyLabel.Position = UDim2.new(0, 20, 0, 204)
parryKeyLabel.Parent = mainPage

local parryKeyButton = Instance.new("TextButton")
parryKeyButton.Size = UDim2.new(0, 70, 0, 24)
parryKeyButton.Position = UDim2.new(0, 110, 0, 202)
parryKeyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
parryKeyButton.BorderSizePixel = 0
parryKeyButton.Font = Enum.Font.GothamBold
parryKeyButton.TextSize = 14
parryKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
parryKeyButton.Text = "Q"
parryKeyButton.ZIndex = 3
parryKeyButton.Parent = mainPage

local parryCorner = Instance.new("UICorner")
parryCorner.CornerRadius = UDim.new(0, 8)
parryCorner.Parent = parryKeyButton

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -40, 0, 40)
infoLabel.Position = UDim2.new(0, 20, 0, 236)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
infoLabel.Text = "RightCtrl = show/hide hub. Set CPS, Mode, Action (Click/Parry), keys, then use Start or keybind."
infoLabel.ZIndex = 3
infoLabel.Parent = mainPage

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 220, 0, 34)
toggleBtn.Position = UDim2.new(0, 20, 0, 280)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
toggleBtn.BorderSizePixel = 0
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "Start"
toggleBtn.ZIndex = 3
toggleBtn.Parent = mainPage

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleBtn

---------------------------------------------------------------------//
-- BLATANT PAGE: SCROLLING CONTENT
---------------------------------------------------------------------//
local blatantScroll = Instance.new("ScrollingFrame")
blatantScroll.Size = UDim2.new(1, -20, 1, -20)
blatantScroll.Position = UDim2.new(0, 10, 0, 10)
blatantScroll.BackgroundTransparency = 1
blatantScroll.BorderSizePixel = 0
blatantScroll.ScrollBarThickness = 4
blatantScroll.CanvasSize = UDim2.new(0,0,0,0)
blatantScroll.ZIndex = 3
blatantScroll.Parent = blatantPage

local bLayout = Instance.new("UIListLayout")
bLayout.SortOrder = Enum.SortOrder.LayoutOrder
bLayout.Padding = UDim.new(0, 10)
bLayout.Parent = blatantScroll

bLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    blatantScroll.CanvasSize = UDim2.new(0, 0, 0, bLayout.AbsoluteContentSize.Y + 10)
end)

local function createCard(height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, height)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    card.BorderSizePixel = 0
    card.ZIndex = 3
    card.Parent = blatantScroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = card

    return card
end

local function blatantHeader(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(230, 230, 235)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 3
    lbl.Parent = blatantScroll
end

local baseTitle = Instance.new("TextLabel")
baseTitle.Size = UDim2.new(1, -60, 0, 20)
baseTitle.Position = UDim2.new(0, 10, 0, 6)
baseTitle.BackgroundTransparency = 1
baseTitle.Font = Enum.Font.GothamSemibold
baseTitle.TextSize = 14
baseTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
baseTitle.TextXAlignment = Enum.TextXAlignment.Left
baseTitle.ZIndex = 4

local baseDesc = Instance.new("TextLabel")
baseDesc.Size = UDim2.new(1, -60, 0, 16)
baseDesc.Position = UDim2.new(0, 10, 0, 28)
baseDesc.BackgroundTransparency = 1
baseDesc.Font = Enum.Font.Gotham
baseDesc.TextSize = 12
baseDesc.TextColor3 = Color3.fromRGB(200, 200, 210)
baseDesc.TextXAlignment = Enum.TextXAlignment.Left
baseDesc.ZIndex = 4

---------------------------------------------------------------------//
-- SEMI IMMORTAL (TEMPORARILY DISABLED)
---------------------------------------------------------------------//
getgenv().BinHub_SemiImmortal = false
local semiImmortal = false

local semiCard = createCard(52)
local semiTitle = baseTitle:Clone()
semiTitle.Text = "Semi Immortal"
semiTitle.Parent = semiCard

local semiDesc = baseDesc:Clone()
semiDesc.Text = "Temporarily unavailable."
semiDesc.Parent = semiCard

local semiToggle = Instance.new("Frame")
semiToggle.Size = UDim2.new(0, 40, 0, 20)
semiToggle.Position = UDim2.new(1, -50, 0, 16)
semiToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
semiToggle.BorderSizePixel = 0
semiToggle.ZIndex = 4
semiToggle.Parent = semiCard

local semiToggleCorner = Instance.new("UICorner")
semiToggleCorner.CornerRadius = UDim.new(1, 0)
semiToggleCorner.Parent = semiToggle

local semiThumb = Instance.new("Frame")
semiThumb.Size = UDim2.new(0, 16, 0, 16)
semiThumb.Position = UDim2.new(0, 2, 0.5, -8)
semiThumb.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
semiThumb.BorderSizePixel = 0
semiThumb.ZIndex = 5
semiThumb.Parent = semiToggle

local semiThumbCorner = Instance.new("UICorner")
semiThumbCorner.CornerRadius = UDim.new(1, 0)
semiThumbCorner.Parent = semiThumb

semiToggle.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        infoLabel.Text = "Semi Immortal is temporarily disabled in this build."
    end
end)

---------------------------------------------------------------------//
-- SETTINGS CARD (COSMETIC FOR BLATANT)
---------------------------------------------------------------------//
local settingModes = {"Normal", "Safer", "Aggressive"}
local currentSettingIndex = 1

local setCard = createCard(52)
local setTitle = baseTitle:Clone()
setTitle.Text = "Settings"
setTitle.Parent = setCard

local setDesc = baseDesc:Clone()
setDesc.Text = "Semi-Immortal modes (currently disabled)."
setDesc.Parent = setCard

local setButton = Instance.new("TextButton")
setButton.Size = UDim2.new(0, 110, 0, 24)
setButton.Position = UDim2.new(1, -120, 0, 14)
setButton.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
setButton.BorderSizePixel = 0
setButton.Font = Enum.Font.Gotham
setButton.TextSize = 14
setButton.TextColor3 = Color3.fromRGB(150, 150, 160)
setButton.TextXAlignment = Enum.TextXAlignment.Center
setButton.Text = settingModes[currentSettingIndex]
setButton.ZIndex = 4
setButton.Parent = setCard

local setCorner = Instance.new("UICorner")
setCorner.CornerRadius = UDim.new(0, 10)
setCorner.Parent = setButton

setButton.AutoButtonColor = false
setButton.MouseButton1Click:Connect(function()
    infoLabel.Text = "Semi Immortal settings are disabled right now."
end)

---------------------------------------------------------------------//
-- PLAYER OPTIONS (Speed / Jump)
---------------------------------------------------------------------//
blatantHeader("Player Options")

local function createSlider(title, desc, min, max, default, callback)
    local card = createCard(64)
    local t = baseTitle:Clone()
    t.Text = title
    t.Parent = card

    local d = baseDesc:Clone()
    d.Text = desc
    d.Parent = card

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 40, 0, 16)
    valueLabel.Position = UDim2.new(1, -46, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 12
    valueLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
    valueLabel.Text = tostring(default)
    valueLabel.ZIndex = 4
    valueLabel.Parent = card

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -40, 0, 6)
    bar.Position = UDim2.new(0, 10, 0, 40)
    bar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    bar.BorderSizePixel = 0
    bar.ZIndex = 4
    bar.Parent = card

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 6)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min)/(max-min), 0, 1, 0)
    fill.Position = UDim2.new(0,0,0,0)
    fill.BackgroundColor3 = Color3.fromRGB(140, 200, 255)
    fill.BorderSizePixel = 0
    fill.ZIndex = 5
    fill.Parent = bar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = fill

    local dragging = false
    local function setFromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max-min)*rel + 0.5)
        valueLabel.Text = tostring(val)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        if callback then callback(val) end
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

    if callback then callback(default) end
end

createSlider("Speed", "Choose the speed of your character.", 10, 100, 20, function(val)
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = val end
end)

createSlider("Jump Power", "Choose the jump power of your character.", 25, 150, 50, function(val)
    local hum = getHumanoid()
    if hum then
        if hum.UseJumpPower ~= nil then hum.UseJumpPower = true end
        hum.JumpPower = val
    end
end)

---------------------------------------------------------------------//
-- MANUAL SPAM + TRIGGERBOT
---------------------------------------------------------------------//
local manualCard = createCard(48)
local manualTitle = baseTitle:Clone()
manualTitle.Text = "Manual Spam"
manualTitle.Parent = manualCard

local manualDesc = baseDesc:Clone()
manualDesc.Text = "Spam push on keypress."
manualDesc.Parent = manualCard

local manualKeyButton = Instance.new("TextButton")
manualKeyButton.Size = UDim2.new(0, 40, 0, 24)
manualKeyButton.Position = UDim2.new(1, -50, 0, 12)
manualKeyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
manualKeyButton.BorderSizePixel = 0
manualKeyButton.Font = Enum.Font.GothamBold
manualKeyButton.TextSize = 14
manualKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
manualKeyButton.Text = "E"
manualKeyButton.ZIndex = 4
manualKeyButton.Parent = manualCard

local manualKeyCorner = Instance.new("UICorner")
manualKeyCorner.CornerRadius = UDim.new(0, 10)
manualKeyCorner.Parent = manualKeyButton

local triggerCard = createCard(48)
local trigTitle = baseTitle:Clone()
trigTitle.Text = "Triggerbot"
trigTitle.Parent = triggerCard

local trigDesc = baseDesc:Clone()
trigDesc.Text = "Block instant when they target you. (Here: constant parry spam.)"
trigDesc.Parent = triggerCard

local trigToggle = semiToggle:Clone()
trigToggle.Parent = triggerCard
trigToggle.Position = UDim2.new(1, -50, 0, 14)
local trigThumb = trigToggle:FindFirstChildOfClass("Frame")

---------------------------------------------------------------------//
-- STATE / LOGIC
---------------------------------------------------------------------//
local clicking          = false
local cps               = 10
local toggleKey         = Enum.KeyCode.F
local parryKey          = Enum.KeyCode.Q
local manualKey         = Enum.KeyCode.E

local manualSpamActive  = false
local triggerbotOn      = false

local listeningForKey    = false
local listeningForParry  = false
local listeningForManual = false

local mode        = "Toggle" -- Toggle / Hold
local actionMode  = "Click"  -- Click / Parry

local function keyToString(keycode)
    local s = tostring(keycode)
    return s:match("%.(.+)") or s
end

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
    status.Text = string.format("Status: %s (%d CPS, %s, %s)", onOff, cps, mode, actionMode)
    status.TextColor3 = color
end

local function updateTriggerVisual()
    if not trigToggle or not trigThumb then return end
    if triggerbotOn then
        trigToggle.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        trigThumb.Position = UDim2.new(1, -18, 0.5, -8)
    else
        trigToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        trigThumb.Position = UDim2.new(0, 2, 0.5, -8)
    end
end

local function toggleClicker()
    clicking = not clicking
    updateStatus()
    if clicking then
        toggleBtn.Text = "Stop"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 70)
    else
        toggleBtn.Text = "Start"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
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

keyButton.MouseButton1Click:Connect(function()
    if listeningForKey or listeningForParry or listeningForManual then return end
    listeningForKey = true
    infoLabel.Text = "Press a key for main Toggle/Hold (RightCtrl reserved)."
end)

parryKeyButton.MouseButton1Click:Connect(function()
    if listeningForKey or listeningForParry or listeningForManual then return end
    listeningForParry = true
    infoLabel.Text = "Press a key for Parry."
end)

manualKeyButton.MouseButton1Click:Connect(function()
    if listeningForKey or listeningForParry or listeningForManual then return end
    listeningForManual = true
    infoLabel.Text = "Press a key for Manual Spam."
end)

trigToggle.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        triggerbotOn = not triggerbotOn
        updateTriggerVisual()
    end
end)

updateTriggerVisual()
updateStatus()

---------------------------------------------------------------------//
-- INPUT HANDLING
---------------------------------------------------------------------//
UIS.InputBegan:Connect(function(input, gp)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    if input.KeyCode == Enum.KeyCode.RightControl
        and not listeningForKey and not listeningForParry and not listeningForManual then
        guiVisible = not guiVisible
        gui.Enabled = guiVisible
        return
    end

    if listeningForKey then
        if input.KeyCode == Enum.KeyCode.RightControl then
            infoLabel.Text = "RightCtrl is hub toggle only."
        else
            toggleKey = input.KeyCode
            keyButton.Text = keyToString(toggleKey)
            infoLabel.Text = "Main keybind set to: " .. keyButton.Text
        end
        listeningForKey = false
        return
    end

    if listeningForParry then
        parryKey = input.KeyCode
        parryKeyButton.Text = keyToString(parryKey)
        infoLabel.Text = "Parry key set to: " .. parryKeyButton.Text
        listeningForParry = false
        return
    end

    if listeningForManual then
        manualKey = input.KeyCode
        manualKeyButton.Text = keyToString(manualKey)
        infoLabel.Text = "Manual spam key set to: " .. manualKeyButton.Text
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

UIS.InputEnded:Connect(function(input, gp)
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
        if clicking or triggerbotOn or manualSpamActive then
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

            if triggerbotOn and VIM and parryKey then
                pcall(function()
                    VIM:SendKeyEvent(true, parryKey, false, game)
                    task.wait(0.01)
                    VIM:SendKeyEvent(false, parryKey, false, game)
                end)
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
-- START ON HOME + SEND WEBHOOK
---------------------------------------------------------------------//
setActivePage("Home")
sendWebhookLog()
