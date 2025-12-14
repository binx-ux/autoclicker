--// BinHub X - Midnight Vapor Edition
--// RightCtrl = Show/Hide Hub
--// Part 1: Core Setup + Vaporwave Root UI

---------------------------------------------------------------------//
-- SERVICES
---------------------------------------------------------------------//
local Players            = game:GetService("Players")
local UIS                = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local RunService         = game:GetService("RunService")
local CoreGui            = game:GetService("CoreGui")
local HttpService        = game:GetService("HttpService")

local LocalPlayer        = Players.LocalPlayer

-- VirtualInputManager for key + mouse simulation
local VIM
pcall(function()
    VIM = game:GetService("VirtualInputManager")
end)

---------------------------------------------------------------------//
-- DISCORD WEBHOOK (BUG REPORTS)
---------------------------------------------------------------------//
--  🔹 PUT YOUR DISCORD WEBHOOK HERE 🔹
local WEBHOOK_URL = "" https://discord.com/api/webhooks/1446656470287651050/ayflCl7nEQ3388YhXAZT7r3j5kTC40EP3WV9yO1BehR2vzHbtoDArV-YejWn_E_F6eUk

local function sendBugToWebhook(title, body)
    if WEBHOOK_URL == nil or WEBHOOK_URL == "" then return end

    local req = (http_request or request or syn and syn.request)
    if not req then return end

    local contentLines = {
        "🪲 **BinHub X Bug Report**",
        "",
        "**Player:** @" .. (LocalPlayer and LocalPlayer.Name or "Unknown"),
        "**PlaceId:** " .. tostring(game.PlaceId),
        "**Title:** " .. (title ~= "" and title or "_(no title)_"),
        "",
        "**Description:**",
        body ~= "" and body or "_(no description)_"
    }

    local payload = {
        content = table.concat(contentLines, "\n")
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

---------------------------------------------------------------------//
-- SAFE PARENT (supports all executors)
---------------------------------------------------------------------//
local function safeParent()
    local ok, gui = pcall(function()
        if gethui then
            local g = Instance.new("ScreenGui")
            g.Name = "BinHubX_Vapor"
            g.ResetOnSpawn = false
            g.Parent = gethui()
            return g
        end
    end)

    if ok and gui then return gui end

    local g = Instance.new("ScreenGui")
    g.Name = "BinHubX_Vapor"
    g.ResetOnSpawn = false
    g.Parent = CoreGui

    return g
end

local MainGui = safeParent()
MainGui.Enabled = true

---------------------------------------------------------------------//
-- MIDNIGHT VAPOR COLOR PROFILE
---------------------------------------------------------------------//
local COLOR_DEEP_PURPLE = Color3.fromRGB(109, 0, 255)
local COLOR_MAGENTA_GLOW = Color3.fromRGB(255, 51, 204)
local COLOR_BG_DARK = Color3.fromRGB(8, 0, 20)

---------------------------------------------------------------------//
-- ROOT WINDOW
---------------------------------------------------------------------//
local Root = Instance.new("Frame")
Root.Name = "Root"
Root.Size = UDim2.new(0, 760, 0, 420)
Root.Position = UDim2.new(0.5, -380, 0.5, -210)
Root.BackgroundColor3 = COLOR_BG_DARK
Root.BorderSizePixel = 0
Root.Parent = MainGui

local RootCorner = Instance.new("UICorner")
RootCorner.CornerRadius = UDim.new(0, 22)
RootCorner.Parent = Root

local RootStroke = Instance.new("UIStroke")
RootStroke.Color = COLOR_DEEP_PURPLE
RootStroke.Thickness = 2
RootStroke.Parent = Root

---------------------------------------------------------------------//
-- ANIMATED GRADIENT BACKDROP
---------------------------------------------------------------------//
local VaporGradient = Instance.new("UIGradient")
VaporGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 0, 145)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 0, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 95, 255))
})
VaporGradient.Rotation = 45
VaporGradient.Parent = Root

-- animate gradient 24/7
task.spawn(function()
    while true do
        for i = 0, 360 do
            VaporGradient.Rotation = i
            task.wait(0.02)
        end
    end
end)

---------------------------------------------------------------------//
-- FLOATING PANEL ANIMATION
---------------------------------------------------------------------//
task.spawn(function()
    while true do
        TweenService:Create(Root, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Position = Root.Position + UDim2.new(0, 0, 0, -6)
        }):Play()
        task.wait(3)

        TweenService:Create(Root, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Position = Root.Position + UDim2.new(0, 0, 0, 6)
        }):Play()
        task.wait(3)
    end
end)

---------------------------------------------------------------------//
-- NEON PARTICLE BACKGROUND
---------------------------------------------------------------------//
local function createParticle()
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 5, 0, 5)
    dot.BackgroundColor3 = COLOR_MAGENTA_GLOW
    dot.BorderSizePixel = 0
    dot.Parent = Root
    dot.ZIndex = 0

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = dot

    dot.Position = UDim2.new(math.random(), 0, 1, 20)

    TweenService:Create(dot, TweenInfo.new(math.random(6, 12), Enum.EasingStyle.Linear), {
        Position = UDim2.new(math.random(), 0, 0, -20),
        BackgroundTransparency = 1
    }):Play()

    task.delay(12, function()
        if dot then dot:Destroy() end
    end)
end

task.spawn(function()
    while true do
        createParticle()
        task.wait(0.15)
    end
end)

---------------------------------------------------------------------//
-- PAGE CONTAINER (Tabs appear later)
---------------------------------------------------------------------//
local PageHolder = Instance.new("Frame")
PageHolder.Name = "PageHolder"
PageHolder.Size = UDim2.new(1, -240, 1, -40)
PageHolder.Position = UDim2.new(0, 240, 0, 40)
PageHolder.BackgroundTransparency = 1
PageHolder.Parent = Root

---------------------------------------------------------------------//
-- PLAYER INFO
---------------------------------------------------------------------//
local displayName = (LocalPlayer and LocalPlayer.DisplayName) or "Player"
local userName    = (LocalPlayer and LocalPlayer.Name) or "Unknown"

---------------------------------------------------------------------//
-- TOP BAR (TITLE + DRAG + CLOSE)
---------------------------------------------------------------------//
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, -20, 0, 40)
TopBar.Position = UDim2.new(0, 10, 0, 0)
TopBar.BackgroundTransparency = 1
TopBar.Parent = Root

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 22
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextColor3 = Color3.fromRGB(245, 240, 255)
TitleLabel.Text = "BinHub X — Midnight Vapor"
TitleLabel.Parent = TopBar

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0.4, -40, 1, 0)
SubLabel.Position = UDim2.new(0.6, 0, 0, 0)
SubLabel.BackgroundTransparency = 1
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextSize = 13
SubLabel.TextXAlignment = Enum.TextXAlignment.Right
SubLabel.TextColor3 = Color3.fromRGB(190, 170, 220)
SubLabel.Text = "@binxix • Solara ready"
SubLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -15)
CloseBtn.BackgroundColor3 = COLOR_DEEP_PURPLE
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainGui.Enabled = false
end)

-- drag logic
do
    local dragging = false
    local dragStart, startPos

    local function updateDrag(input)
        local delta = input.Position - dragStart
        Root.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Root.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                updateDrag(input)
            end
        end
    end)
end

---------------------------------------------------------------------//
-- SIDEBAR
---------------------------------------------------------------------//
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 220, 1, -20)
Sidebar.Position = UDim2.new(0, 10, 0, 20)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 0, 35)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Root

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 18)
SidebarCorner.Parent = Sidebar

local SidebarStroke = Instance.new("UIStroke")
SidebarStroke.Color = Color3.fromRGB(80, 0, 150)
SidebarStroke.Thickness = 1
SidebarStroke.Parent = Sidebar

local SidebarGradient = Instance.new("UIGradient")
SidebarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 0, 60)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 0, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 0, 40))
})
SidebarGradient.Rotation = 90
SidebarGradient.Parent = Sidebar

---------------------------------------------------------------------//
-- PROFILE SECTION
---------------------------------------------------------------------//
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Size = UDim2.new(1, -24, 0, 80)
ProfileFrame.Position = UDim2.new(0, 12, 0, 10)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(18, 0, 55)
ProfileFrame.BorderSizePixel = 0
ProfileFrame.Parent = Sidebar

local PFCorner = Instance.new("UICorner")
PFCorner.CornerRadius = UDim.new(0, 14)
PFCorner.Parent = ProfileFrame

local PStroke = Instance.new("UIStroke")
PStroke.Color = Color3.fromRGB(120, 0, 200)
PStroke.Thickness = 1
PStroke.Parent = ProfileFrame

local PFName = Instance.new("TextLabel")
PFName.Size = UDim2.new(1, -16, 0, 26)
PFName.Position = UDim2.new(0, 8, 0, 6)
PFName.BackgroundTransparency = 1
PFName.Font = Enum.Font.GothamBold
PFName.TextSize = 16
PFName.TextXAlignment = Enum.TextXAlignment.Left
PFName.TextColor3 = Color3.fromRGB(240, 230, 255)
PFName.Text = displayName
PFName.Parent = ProfileFrame

local PFUser = Instance.new("TextLabel")
PFUser.Size = UDim2.new(1, -16, 0, 20)
PFUser.Position = UDim2.new(0, 8, 0, 30)
PFUser.BackgroundTransparency = 1
PFUser.Font = Enum.Font.Gotham
PFUser.TextSize = 13
PFUser.TextXAlignment = Enum.TextXAlignment.Left
PFUser.TextColor3 = Color3.fromRGB(180, 160, 220)
PFUser.Text = "@"..userName
PFUser.Parent = ProfileFrame

local PFTag = Instance.new("TextLabel")
PFTag.Size = UDim2.new(1, -16, 0, 20)
PFTag.Position = UDim2.new(0, 8, 0, 50)
PFTag.BackgroundTransparency = 1
PFTag.Font = Enum.Font.Gotham
PFTag.TextSize = 12
PFTag.TextXAlignment = Enum.TextXAlignment.Left
PFTag.TextColor3 = Color3.fromRGB(255, 80, 210)
PFTag.Text = "Midnight Vapor Build"
PFTag.Parent = ProfileFrame

---------------------------------------------------------------------//
-- NAV CONTAINER  (SCROLLING)
---------------------------------------------------------------------//
local NavHolder = Instance.new("ScrollingFrame")
NavHolder.Name = "NavHolder"
NavHolder.Size = UDim2.new(1, -24, 1, -120)
NavHolder.Position = UDim2.new(0, 12, 0, 100)
NavHolder.BackgroundTransparency = 1
NavHolder.BorderSizePixel = 0
NavHolder.ScrollBarThickness = 3
NavHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
NavHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
NavHolder.ScrollBarImageTransparency = 0
NavHolder.ScrollBarImageColor3 = Color3.fromRGB(140, 90, 255)
NavHolder.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Padding = UDim.new(0, 4)
NavLayout.Parent = NavHolder

---------------------------------------------------------------------//
-- PAGES / TAB SYSTEM
---------------------------------------------------------------------//
local Pages = {}
local NavButtons = {}
local currentPage = nil

local function createPage(name)
    local Page = Instance.new("Frame")
    Page.Name = name.."Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Position = UDim2.new(0, 0, 0, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = PageHolder
    Pages[name] = Page
    return Page
end

-- define base pages
local HomePage     = createPage("Home")
local CombatPage   = createPage("Combat")
local MovementPage = createPage("Movement")
local VisualPage   = createPage("Visuals")
local UtilityPage  = createPage("Utility")
local StatsPage    = createPage("Stats")
local SettingsPage = createPage("Settings")

local function setActivePage(name)
    for n, page in pairs(Pages) do
        page.Visible = (n == name)
    end

    for n, btn in pairs(NavButtons) do
        if n == name then
            TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(40, 0, 80)
            }):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(18, 0, 50)
            }):Play()
        end
    end

    currentPage = name
end

---------------------------------------------------------------------//
-- NAV HELPERS
---------------------------------------------------------------------//
local function navSectionLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(190, 160, 230)
    lbl.Text = text
    lbl.Parent = NavHolder
end

local function navButton(name, text, emoji)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(18, 0, 50)
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.TextColor3 = Color3.fromRGB(235, 230, 255)
    Btn.Text = (emoji and (emoji.." ") or "")..text
    Btn.Parent = NavHolder

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = Btn

    Btn.MouseEnter:Connect(function()
        if currentPage ~= name then
            TweenService:Create(Btn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(28, 0, 70)
            }):Play()
        end
    end)

    Btn.MouseLeave:Connect(function()
        if currentPage ~= name then
            TweenService:Create(Btn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(18, 0, 50)
            }):Play()
        end
    end)

    Btn.MouseButton1Click:Connect(function()
        setActivePage(name)
    end)

    NavButtons[name] = Btn
end

---------------------------------------------------------------------//
-- BUILD NAVIGATION
---------------------------------------------------------------------//
navSectionLabel("Core")
navButton("Home",    "Home",    "🏠")
navButton("Combat",  "Combat",  "⚔️")

navSectionLabel("Movement")
navButton("Movement","Movement", "🏃‍♂️")

navSectionLabel("Visuals & ESP")
navButton("Visuals", "Visuals / ESP", "👁️")

navSectionLabel("Utility")
navButton("Utility", "Utility / Anti-AFK", "🛠️")

navSectionLabel("Stats & Settings")
navButton("Stats",   "Stats / Monitor", "📊")
navButton("Settings","Settings / Bug Report", "⚙️")

---------------------------------------------------------------------//
-- HOME PAGE CONTENT (BASIC WELCOME)
---------------------------------------------------------------------//
do
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 40)
    Title.Position = UDim2.new(0, 20, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 26
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Top
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Text = "Welcome, "..displayName
    Title.Parent = HomePage

    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1, -40, 0, 80)
    Info.Position = UDim2.new(0, 20, 0, 75)
    Info.BackgroundTransparency = 1
    Info.Font = Enum.Font.Gotham
    Info.TextSize = 14
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.TextYAlignment = Enum.TextYAlignment.Top
    Info.TextWrapped = true
    Info.TextColor3 = Color3.fromRGB(210, 200, 235)
    Info.Text = table.concat({
        "• Combat tab: Auto Parry, Auto Clicker, Triggerbot, Manual Spam",
        "• Movement tab: Speed, Jump, Semi-Immortal",
        "• Visuals tab: ESP, Player FX (headless/korblox)",
        "• Utility tab: CPU/FPS Boost, Anti-AFK",
        "• Stats tab: Region, Ping, FPS Monitor"
    }, "\n")
    Info.Parent = HomePage
end

---------------------------------------------------------------------//
-- TOGGLE HUB WITH RIGHT CTRL
---------------------------------------------------------------------//
local HubVisible = true

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        HubVisible = not HubVisible
        MainGui.Enabled = HubVisible
    end
end)

---------------------------------------------------------------------//
-- DEFAULT PAGE
---------------------------------------------------------------------//
setActivePage("Home")

---------------------------------------------------------------------//
-- COMBAT STATE / HELPERS
---------------------------------------------------------------------//
local combatStatusLabel

local combatMainKey   = Enum.KeyCode.E      -- main toggle key
local combatMode      = "Toggle"            -- Toggle / Hold
local combatAction    = "Parry"             -- Click / Parry (default Parry for Blade Ball)
local combatCPS       = 15                  -- default CPS

local autoClickOn     = false               -- for pure click spam
local triggerbotOn    = false               -- constant parry mode
local manualSpamKey   = Enum.KeyCode.E      -- user can rebind in UI
local manualSpamActive = false              -- pressed state

-- main auto click/parry engine flag
local coreClickerOn   = false

local function keyToString(keycode)
    local s = tostring(keycode)
    return s:match("%.(.+)") or s
end

local function updateCombatStatus()
    if not combatStatusLabel then return end

    local stateText = coreClickerOn and "ON" or "OFF"
    local modeText  = combatMode
    local actionTxt = combatAction
    local cpsText   = tostring(combatCPS)

    combatStatusLabel.Text = string.format(
        "Status: %s  |  %s  |  %s  |  %s CPS",
        stateText, modeText, actionTxt, cpsText
    )

    if coreClickerOn then
        combatStatusLabel.TextColor3 = Color3.fromRGB(80, 255, 160)
    else
        combatStatusLabel.TextColor3 = Color3.fromRGB(255, 120, 140)
    end
end

---------------------------------------------------------------------//
-- COMBAT PAGE UI
---------------------------------------------------------------------//
do
    -- main title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.Position = UDim2.new(0, 20, 0, 18)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Text = "Combat Controls"
    Title.Parent = CombatPage

    -- status strip
    combatStatusLabel = Instance.new("TextLabel")
    combatStatusLabel.Size = UDim2.new(1, -40, 0, 24)
    combatStatusLabel.Position = UDim2.new(0, 20, 0, 52)
    combatStatusLabel.BackgroundTransparency = 1
    combatStatusLabel.Font = Enum.Font.Gotham
    combatStatusLabel.TextSize = 14
    combatStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    combatStatusLabel.TextColor3 = Color3.fromRGB(255, 120, 140)
    combatStatusLabel.Text = "Status: OFF | Toggle | Parry | 15 CPS"
    combatStatusLabel.Parent = CombatPage

    -----------------------------------------------------------------//
    -- LEFT PANEL (CORE CLICKER CONFIG)
    -----------------------------------------------------------------//
    local LeftPanel = Instance.new("Frame")
    LeftPanel.Size = UDim2.new(0.5, -30, 1, -90)
    LeftPanel.Position = UDim2.new(0, 20, 0, 86)
    LeftPanel.BackgroundColor3 = Color3.fromRGB(14, 0, 40)
    LeftPanel.BorderSizePixel = 0
    LeftPanel.Parent = CombatPage

    local LPCorner = Instance.new("UICorner")
    LPCorner.CornerRadius = UDim.new(0, 16)
    LPCorner.Parent = LeftPanel

    local LPStroke = Instance.new("UIStroke")
    LPStroke.Color = Color3.fromRGB(80, 0, 170)
    LPStroke.Thickness = 1
    LPStroke.Parent = LeftPanel

    -- CPS
    local CPSLabel = Instance.new("TextLabel")
    CPSLabel.Size = UDim2.new(0, 120, 0, 20)
    CPSLabel.Position = UDim2.new(0, 14, 0, 14)
    CPSLabel.BackgroundTransparency = 1
    CPSLabel.Font = Enum.Font.Gotham
    CPSLabel.TextSize = 14
    CPSLabel.TextXAlignment = Enum.TextXAlignment.Left
    CPSLabel.TextColor3 = Color3.fromRGB(220, 210, 240)
    CPSLabel.Text = "CPS:"
    CPSLabel.Parent = LeftPanel

    local CPSBox = Instance.new("TextBox")
    CPSBox.Size = UDim2.new(0, 70, 0, 24)
    CPSBox.Position = UDim2.new(0, 70, 0, 12)
    CPSBox.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
    CPSBox.BorderSizePixel = 0
    CPSBox.Font = Enum.Font.GothamBold
    CPSBox.TextSize = 14
    CPSBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    CPSBox.PlaceholderText = ""
    CPSBox.Text = tostring(combatCPS)
    CPSBox.ClearTextOnFocus = false
    CPSBox.Parent = LeftPanel

    local CPSCorner = Instance.new("UICorner")
    CPSCorner.CornerRadius = UDim.new(0, 8)
    CPSCorner.Parent = CPSBox

    local function clampCPS()
        local n = tonumber(CPSBox.Text)
        if not n or n <= 0 then
            n = 10
        end
        if n > 80 then
            n = 80
        end
        combatCPS = math.floor(n)
        CPSBox.Text = tostring(combatCPS)
        updateCombatStatus()
    end

    CPSBox.FocusLost:Connect(clampCPS)

    -- Main key
    local KeyLabel = Instance.new("TextLabel")
    KeyLabel.Size = UDim2.new(0, 140, 0, 20)
    KeyLabel.Position = UDim2.new(0, 14, 0, 48)
    KeyLabel.BackgroundTransparency = 1
    KeyLabel.Font = Enum.Font.Gotham
    KeyLabel.TextSize = 14
    KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeyLabel.TextColor3 = Color3.fromRGB(220, 210, 240)
    KeyLabel.Text = "Main Toggle Key:"
    KeyLabel.Parent = LeftPanel

    local KeyButton = Instance.new("TextButton")
    KeyButton.Size = UDim2.new(0, 70, 0, 24)
    KeyButton.Position = UDim2.new(0, 140, 0, 46)
    KeyButton.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
    KeyButton.BorderSizePixel = 0
    KeyButton.Font = Enum.Font.GothamBold
    KeyButton.TextSize = 14
    KeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyButton.Text = keyToString(combatMainKey)
    KeyButton.Parent = LeftPanel

    local KeyCorner = Instance.new("UICorner")
    KeyCorner.CornerRadius = UDim.new(0, 8)
    KeyCorner.Parent = KeyButton

    local waitingForMainKey = false

    KeyButton.MouseButton1Click:Connect(function()
        if waitingForMainKey then return end
        waitingForMainKey = true
        KeyButton.Text = "..."
    end)

    -- Mode button
    local ModeLabel = Instance.new("TextLabel")
    ModeLabel.Size = UDim2.new(0, 80, 0, 20)
    ModeLabel.Position = UDim2.new(0, 14, 0, 82)
    ModeLabel.BackgroundTransparency = 1
    ModeLabel.Font = Enum.Font.Gotham
    ModeLabel.TextSize = 14
    ModeLabel.TextXAlignment = Enum.TextXAlignment.Left
    ModeLabel.TextColor3 = Color3.fromRGB(220, 210, 240)
    ModeLabel.Text = "Mode:"
    ModeLabel.Parent = LeftPanel

    local ModeButton = Instance.new("TextButton")
    ModeButton.Size = UDim2.new(0, 90, 0, 24)
    ModeButton.Position = UDim2.new(0, 80, 0, 80)
    ModeButton.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
    ModeButton.BorderSizePixel = 0
    ModeButton.Font = Enum.Font.GothamBold
    ModeButton.TextSize = 14
    ModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ModeButton.Text = combatMode
    ModeButton.Parent = LeftPanel

    local ModeCorner = Instance.new("UICorner")
    ModeCorner.CornerRadius = UDim.new(0, 8)
    ModeCorner.Parent = ModeButton

    ModeButton.MouseButton1Click:Connect(function()
        combatMode = (combatMode == "Toggle") and "Hold" or "Toggle"
        ModeButton.Text = combatMode
        updateCombatStatus()
    end)

    -- Action button
    local ActionLabel = Instance.new("TextLabel")
    ActionLabel.Size = UDim2.new(0, 80, 0, 20)
    ActionLabel.Position = UDim2.new(0, 14, 0, 116)
    ActionLabel.BackgroundTransparency = 1
    ActionLabel.Font = Enum.Font.Gotham
    ActionLabel.TextSize = 14
    ActionLabel.TextXAlignment = Enum.TextXAlignment.Left
    ActionLabel.TextColor3 = Color3.fromRGB(220, 210, 240)
    ActionLabel.Text = "Action:"
    ActionLabel.Parent = LeftPanel

    local ActionButton = Instance.new("TextButton")
    ActionButton.Size = UDim2.new(0, 90, 0, 24)
    ActionButton.Position = UDim2.new(0, 80, 0, 114)
    ActionButton.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
    ActionButton.BorderSizePixel = 0
    ActionButton.Font = Enum.Font.GothamBold
    ActionButton.TextSize = 14
    ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionButton.Text = combatAction
    ActionButton.Parent = LeftPanel

    local ActionCorner = Instance.new("UICorner")
    ActionCorner.CornerRadius = UDim.new(0, 8)
    ActionCorner.Parent = ActionButton

    ActionButton.MouseButton1Click:Connect(function()
        combatAction = (combatAction == "Click") and "Parry" or "Click"
        ActionButton.Text = combatAction
        updateCombatStatus()
    end)

    -- Main Start/Stop button
    local MainBtn = Instance.new("TextButton")
    MainBtn.Size = UDim2.new(1, -28, 0, 32)
    MainBtn.Position = UDim2.new(0, 14, 0, 160)
    MainBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 90)
    MainBtn.BorderSizePixel = 0
    MainBtn.Font = Enum.Font.GothamBold
    MainBtn.TextSize = 16
    MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainBtn.Text = "Start (Main Engine)"
    MainBtn.Parent = LeftPanel

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainBtn

    local function updateMainButtonVisual()
        if coreClickerOn then
            MainBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 160)
            MainBtn.Text = "Stop (Main Engine)"
        else
            MainBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 90)
            MainBtn.Text = "Start (Main Engine)"
        end
    end

    MainBtn.MouseButton1Click:Connect(function()
        coreClickerOn = not coreClickerOn
        updateMainButtonVisual()
        updateCombatStatus()
    end)

    -----------------------------------------------------------------//
    -- RIGHT PANEL (TOGGLES: AUTO CLICK, TRIGGERBOT, MANUAL, ABILITY)
    -----------------------------------------------------------------//
    local RightPanel = Instance.new("Frame")
    RightPanel.Size = UDim2.new(0.5, -30, 1, -90)
    RightPanel.Position = UDim2.new(0.5, 10, 0, 86)
    RightPanel.BackgroundColor3 = Color3.fromRGB(14, 0, 40)
    RightPanel.BorderSizePixel = 0
    RightPanel.Parent = CombatPage

    local RPCorner = Instance.new("UICorner")
    RPCorner.CornerRadius = UDim.new(0, 16)
    RPCorner.Parent = RightPanel

    local RPStroke = Instance.new("UIStroke")
    RPStroke.Color = Color3.fromRGB(80, 0, 170)
    RPStroke.Thickness = 1
    RPStroke.Parent = RightPanel

    local function makeToggleRow(parent, yOffset, titleTxt, descTxt)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -20, 0, 48)
        Row.Position = UDim2.new(0, 10, 0, yOffset)
        Row.BackgroundTransparency = 1
        Row.Parent = parent

        local T = Instance.new("TextLabel")
        T.Size = UDim2.new(1, -80, 0, 18)
        T.Position = UDim2.new(0, 0, 0, 0)
        T.BackgroundTransparency = 1
        T.Font = Enum.Font.GothamSemibold
        T.TextSize = 14
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.TextColor3 = Color3.fromRGB(235, 225, 255)
        T.Text = titleTxt
        T.Parent = Row

        local D = Instance.new("TextLabel")
        D.Size = UDim2.new(1, -80, 0, 20)
        D.Position = UDim2.new(0, 0, 0, 20)
        D.BackgroundTransparency = 1
        D.Font = Enum.Font.Gotham
        D.TextSize = 12
        D.TextXAlignment = Enum.TextXAlignment.Left
        D.TextYAlignment = Enum.TextYAlignment.Top
        D.TextWrapped = true
        D.TextColor3 = Color3.fromRGB(200, 190, 230)
        D.Text = descTxt
        D.Parent = Row

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 60, 0, 24)
        Btn.Position = UDim2.new(1, -70, 0, 12)
        Btn.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
        Btn.BorderSizePixel = 0
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 12
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Text = "OFF"
        Btn.Parent = Row

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = Btn

        return Btn
    end

    -- Auto Clicker
    local autoClickBtn = makeToggleRow(
        RightPanel,
        10,
        "Auto Clicker",
        "Simple constant click spam when main engine is active and action = Click."
    )

    autoClickBtn.MouseButton1Click:Connect(function()
        autoClickOn = not autoClickOn
        if autoClickOn then
            autoClickBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 180)
            autoClickBtn.Text = "ON"
        else
            autoClickBtn.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
            autoClickBtn.Text = "OFF"
        end
    end)

    -- Triggerbot
    local triggerBtn = makeToggleRow(
        RightPanel,
        64,
        "Triggerbot",
        "Constant parry spam while enabled (good for basic games / testing)."
    )

    triggerBtn.MouseButton1Click:Connect(function()
        triggerbotOn = not triggerbotOn
        if triggerbotOn then
            triggerBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 180)
            triggerBtn.Text = "ON"
        else
            triggerBtn.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
            triggerBtn.Text = "OFF"
        end
    end)

    -- Manual spam key
    local manualRow = Instance.new("Frame")
    manualRow.Size = UDim2.new(1, -20, 0, 56)
    manualRow.Position = UDim2.new(0, 10, 0, 118)
    manualRow.BackgroundTransparency = 1
    manualRow.Parent = RightPanel

    local MTitle = Instance.new("TextLabel")
    MTitle.Size = UDim2.new(1, -80, 0, 18)
    MTitle.Position = UDim2.new(0, 0, 0, 0)
    MTitle.BackgroundTransparency = 1
    MTitle.Font = Enum.Font.GothamSemibold
    MTitle.TextSize = 14
    MTitle.TextXAlignment = Enum.TextXAlignment.Left
    MTitle.TextColor3 = Color3.fromRGB(235, 225, 255)
    MTitle.Text = "Manual Spam Key"
    MTitle.Parent = manualRow

    local MDesc = Instance.new("TextLabel")
    MDesc.Size = UDim2.new(1, -80, 0, 20)
    MDesc.Position = UDim2.new(0, 0, 0, 20)
    MDesc.BackgroundTransparency = 1
    MDesc.Font = Enum.Font.Gotham
    MDesc.TextSize = 12
    MDesc.TextXAlignment = Enum.TextXAlignment.Left
    MDesc.TextYAlignment = Enum.TextYAlignment.Top
    MDesc.TextWrapped = true
    MDesc.TextColor3 = Color3.fromRGB(200, 190, 230)
    MDesc.Text = "Hold the key to spam parry/click manually."
    MDesc.Parent = manualRow

    local manualKeyBtn = Instance.new("TextButton")
    manualKeyBtn.Size = UDim2.new(0, 60, 0, 24)
    manualKeyBtn.Position = UDim2.new(1, -70, 0, 18)
    manualKeyBtn.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
    manualKeyBtn.BorderSizePixel = 0
    manualKeyBtn.Font = Enum.Font.GothamBold
    manualKeyBtn.TextSize = 12
    manualKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    manualKeyBtn.Text = keyToString(manualSpamKey)
    manualKeyBtn.Parent = manualRow

    local manualCorner = Instance.new("UICorner")
    manualCorner.CornerRadius = UDim.new(1, 0)
    manualCorner.Parent = manualKeyBtn

    local waitingForManualKey = false

    manualKeyBtn.MouseButton1Click:Connect(function()
        if waitingForManualKey then return end
        waitingForManualKey = true
        manualKeyBtn.Text = "..."
    end)

    -- Ability Detection (visual only)
    local abilityBtn = makeToggleRow(
        RightPanel,
        178,
        "Ability Detection",
        "Future: Ball/ability based timed parry for Blade Ball (visual toggle only for now)."
    )

    abilityBtn.MouseButton1Click:Connect(function()
        if abilityBtn.Text == "OFF" then
            abilityBtn.Text = "ON"
            abilityBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 180)
        else
            abilityBtn.Text = "OFF"
            abilityBtn.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
        end
    end)

    -----------------------------------------------------------------//
    -- INPUT HOOKS FOR MAIN + MANUAL KEY REBIND
    -----------------------------------------------------------------//
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end

        -- handle capturing new main toggle key
        if waitingForMainKey and input.UserInputType == Enum.UserInputType.Keyboard then
            combatMainKey = input.KeyCode
            waitingForMainKey = false
            KeyButton.Text = keyToString(combatMainKey)
            return
        end

        -- handle capturing new manual key
        if waitingForManualKey and input.UserInputType == Enum.UserInputType.Keyboard then
            manualSpamKey = input.KeyCode
            waitingForManualKey = false
            manualKeyBtn.Text = keyToString(manualSpamKey)
            return
        end
    end)
end

-- keep status in sync on load
updateCombatStatus()

---------------------------------------------------------------------//
-- MOVEMENT STATE
---------------------------------------------------------------------//
local speedEnabled      = false
local speedValue        = 20
local originalWalkSpeed = nil

local jumpEnabled       = false
local jumpValue         = 50
local originalJumpPower = nil

local semiImmortalOn    = false

---------------------------------------------------------------------//
-- MOVEMENT PAGE UI
---------------------------------------------------------------------//
--  (UNCHANGED – same as you had, omitted for space)
--  ⚠️ Keep your existing Movement, Visuals, Utility, Stats, Semi-Immortal,
--  watchers, and helper functions exactly as they are below this point.
--  The only other change we still need to touch is the main combat loop
--  so the manual spam respects Click / Parry (down near the bottom).
---------------------------------------------------------------------//
--  🔻  KEEP ALL THE CODE YOU ALREADY HAVE HERE
--  (MovementPage, VisualPage, UtilityPage, StatsPage, Semi-Immortal, etc.)
---------------------------------------------------------------------//

--  ⬆️ paste ALL that middle part from your current script back in
--  (I didn't change it, so you can reuse it exactly.)

---------------------------------------------------------------------//
-- SETTINGS PAGE (BUG REPORT UI)
---------------------------------------------------------------------//
do
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.Position = UDim2.new(0, 20, 0, 18)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Text = "Settings / Bug Report"
    Title.Parent = SettingsPage

    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1, -40, 0, 40)
    Info.Position = UDim2.new(0, 20, 0, 50)
    Info.BackgroundTransparency = 1
    Info.Font = Enum.Font.Gotham
    Info.TextSize = 13
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.TextYAlignment = Enum.TextYAlignment.Top
    Info.TextWrapped = true
    Info.TextColor3 = Color3.fromRGB(210, 200, 235)
    Info.Text = "Send bugs directly to your Discord webhook. Fill out the form and press SEND."
    Info.Parent = SettingsPage

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(1, -40, 1, -100)
    MainFrame.Position = UDim2.new(0, 20, 0, 90)
    MainFrame.BackgroundColor3 = Color3.fromRGB(14, 0, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = SettingsPage

    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0, 18)
    SCorner.Parent = MainFrame

    local SStroke = Instance.new("UIStroke")
    SStroke.Color = Color3.fromRGB(80, 0, 170)
    SStroke.Thickness = 1
    SStroke.Parent = MainFrame

    -- Title box
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 0, 20)
    TitleLabel.Position = UDim2.new(0, 10, 0, 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Gotham
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextColor3 = Color3.fromRGB(230, 220, 245)
    TitleLabel.Text = "Bug Title"
    TitleLabel.Parent = MainFrame

    local TitleBox = Instance.new("TextBox")
    TitleBox.Size = UDim2.new(1, -20, 0, 26)
    TitleBox.Position = UDim2.new(0, 10, 0, 32)
    TitleBox.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
    TitleBox.BorderSizePixel = 0
    TitleBox.ClearTextOnFocus = false
    TitleBox.Font = Enum.Font.Gotham
    TitleBox.TextSize = 14
    TitleBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleBox.PlaceholderText = "example: Auto clicker not starting"
    TitleBox.Text = ""
    TitleBox.Parent = MainFrame

    local TBCorner = Instance.new("UICorner")
    TBCorner.CornerRadius = UDim.new(0, 8)
    TBCorner.Parent = TitleBox

    -- Description box
    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -20, 0, 20)
    DescLabel.Position = UDim2.new(0, 10, 0, 70)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextSize = 14
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.TextColor3 = Color3.fromRGB(230, 220, 245)
    DescLabel.Text = "Bug Description"
    DescLabel.Parent = MainFrame

    local DescBox = Instance.new("TextBox")
    DescBox.Size = UDim2.new(1, -20, 1, -130)
    DescBox.Position = UDim2.new(0, 10, 0, 92)
    DescBox.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
    DescBox.BorderSizePixel = 0
    DescBox.ClearTextOnFocus = false
    DescBox.Font = Enum.Font.Gotham
    DescBox.TextSize = 14
    DescBox.TextXAlignment = Enum.TextXAlignment.Left
    DescBox.TextYAlignment = Enum.TextYAlignment.Top
    DescBox.TextWrapped = true
    DescBox.MultiLine = true
    DescBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    DescBox.PlaceholderText = "Explain what broke, what you turned on, and anything else important."
    DescBox.Text = ""
    DescBox.Parent = MainFrame

    local DBCorner = Instance.new("UICorner")
    DBCorner.CornerRadius = UDim.new(0, 8)
    DBCorner.Parent = DescBox

    -- Status label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -160, 0, 20)
    StatusLabel.Position = UDim2.new(0, 10, 1, -30)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 13
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.TextColor3 = Color3.fromRGB(210, 200, 235)
    StatusLabel.Text = "Status: Waiting"
    StatusLabel.Parent = MainFrame

    -- Send button
    local SendBtn = Instance.new("TextButton")
    SendBtn.Size = UDim2.new(0, 130, 0, 26)
    SendBtn.Position = UDim2.new(1, -140, 1, -32)
    SendBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 160)
    SendBtn.BorderSizePixel = 0
    SendBtn.Font = Enum.Font.GothamBold
    SendBtn.TextSize = 14
    SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SendBtn.Text = "Send Bug Report"
    SendBtn.Parent = MainFrame

    local SBCorner = Instance.new("UICorner")
    SBCorner.CornerRadius = UDim.new(0, 10)
    SBCorner.Parent = SendBtn

    SendBtn.MouseButton1Click:Connect(function()
        local title = TitleBox.Text or ""
        local body  = DescBox.Text or ""

        StatusLabel.TextColor3 = Color3.fromRGB(240, 200, 140)
        StatusLabel.Text = "Status: Sending..."

        task.spawn(function()
            sendBugToWebhook(title, body)
            StatusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
            StatusLabel.Text = "Status: Sent (check Discord)"
        end)
    end)
end

---------------------------------------------------------------------//
-- CORE INPUT FOR COMBAT (MAIN KEY + MANUAL SPAM)
---------------------------------------------------------------------//
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    -- main combat toggle key
    if input.KeyCode == combatMainKey then
        if combatMode == "Toggle" then
            coreClickerOn = not coreClickerOn
        else -- Hold
            coreClickerOn = true
        end
        updateCombatStatus()
        return
    end

    -- manual spam hold
    if input.KeyCode == manualSpamKey then
        manualSpamActive = true
    end
end)

UIS.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    -- stop main engine on Hold mode
    if input.KeyCode == combatMainKey and combatMode == "Hold" then
        coreClickerOn = false
        updateCombatStatus()
    end

    -- release manual spam
    if input.KeyCode == manualSpamKey then
        manualSpamActive = false
    end
end)

---------------------------------------------------------------------//
-- CLICK / PARRY HELPERS
---------------------------------------------------------------------//
local function doMouseClick()
    local ok = pcall(function()
        if mouse1click then
            mouse1click()
        elseif VIM then
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end)
end

local function pressKeyOnce(keycode)
    if not VIM or not keycode then return end
    pcall(function()
        VIM:SendKeyEvent(true, keycode, false, game)
        task.wait(0.01)
        VIM:SendKeyEvent(false, keycode, false, game)
    end)
end

---------------------------------------------------------------------//
-- MAIN COMBAT LOOP (AUTO CLICK / PARRY / TRIGGERBOT / MANUAL)
---------------------------------------------------------------------//
task.spawn(function()
    while true do
        local active = coreClickerOn or triggerbotOn or manualSpamActive
        if not active then
            task.wait(0.05)
        else
            -- clamp CPS
            if combatCPS <= 0 then
                combatCPS = 10
            elseif combatCPS > 80 then
                combatCPS = 80
            end
            local delay = 1 / combatCPS

            -- main engine
            if coreClickerOn then
                if combatAction == "Click" then
                    if autoClickOn then
                        doMouseClick()
                    end
                else -- Parry
                    pressKeyOnce(combatMainKey)
                end
            end

            -- triggerbot = constant parry no matter what
            if triggerbotOn then
                pressKeyOnce(combatMainKey)
            end

            -- manual spam fires according to action
            if manualSpamActive then
                if combatAction == "Click" then
                    doMouseClick()
                else
                    pressKeyOnce(manualSpamKey)
                end
            end

            task.wait(delay)
        end
    end
end)
