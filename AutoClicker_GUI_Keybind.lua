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

local LocalPlayer        = Players.LocalPlayer

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
-- ROOT DONE (more parts coming)
---------------------------------------------------------------------//

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
-- NAV CONTAINER
---------------------------------------------------------------------//
local NavHolder = Instance.new("Frame")
NavHolder.Size = UDim2.new(1, -24, 1, -120)
NavHolder.Position = UDim2.new(0, 12, 0, 100)
NavHolder.BackgroundTransparency = 1
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
navButton("Settings","Settings", "⚙️")

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

-- will be driven later by main loop (Part 5+)
local coreClickerOn   = false               -- main auto click/parry engine flag

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

    -- Ability Detection (UI only for now)
    local abilityBtn = makeToggleRow(
        RightPanel,
        178,
        "Ability Detection",
        "Future: Ball/ability based timed parry for Blade Ball (visual toggle only for now)."
    )

    abilityBtn.MouseButton1Click:Connect(function()
        -- stub toggle visual only for now
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
do
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.Position = UDim2.new(0, 20, 0, 18)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Text = "Movement Controls"
    Title.Parent = MovementPage

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
    Info.Text = "Adjust your WalkSpeed, JumpPower and Semi-Immortal mode. Semi-Immortal will be a desync-style effect later."
    Info.Parent = MovementPage

    -----------------------------------------------------------------//
    -- BASE FRAME
    -----------------------------------------------------------------//
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(1, -40, 1, -100)
    MainFrame.Position = UDim2.new(0, 20, 0, 90)
    MainFrame.BackgroundColor3 = Color3.fromRGB(14, 0, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = MovementPage

    local MCorner = Instance.new("UICorner")
    MCorner.CornerRadius = UDim.new(0, 18)
    MCorner.Parent = MainFrame

    local MStroke = Instance.new("UIStroke")
    MStroke.Color = Color3.fromRGB(80, 0, 170)
    MStroke.Thickness = 1
    MStroke.Parent = MainFrame

    -----------------------------------------------------------------//
    -- SLIDER HELPER
    -----------------------------------------------------------------//
    local function createSlider(parent, yOffset, labelText, minVal, maxVal, getVal, setVal)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -20, 0, 64)
        Row.Position = UDim2.new(0, 10, 0, yOffset)
        Row.BackgroundTransparency = 1
        Row.Parent = parent

        local L = Instance.new("TextLabel")
        L.Size = UDim2.new(0.6, 0, 0, 18)
        L.Position = UDim2.new(0, 0, 0, 0)
        L.BackgroundTransparency = 1
        L.Font = Enum.Font.GothamSemibold
        L.TextSize = 14
        L.TextXAlignment = Enum.TextXAlignment.Left
        L.TextColor3 = Color3.fromRGB(235, 225, 255)
        L.Text = labelText
        L.Parent = Row

        local ValLabel = Instance.new("TextLabel")
        ValLabel.Size = UDim2.new(0.4, -10, 0, 18)
        ValLabel.Position = UDim2.new(0.6, 10, 0, 0)
        ValLabel.BackgroundTransparency = 1
        ValLabel.Font = Enum.Font.Gotham
        ValLabel.TextSize = 13
        ValLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValLabel.TextColor3 = Color3.fromRGB(210, 200, 235)
        ValLabel.Text = tostring(getVal())
        ValLabel.Parent = Row

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(1, 0, 0, 6)
        Bar.Position = UDim2.new(0, 0, 0, 30)
        Bar.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
        Bar.BorderSizePixel = 0
        Bar.Parent = Row

        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(0, 6)
        BarCorner.Parent = Bar

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((getVal() - minVal) / (maxVal - minVal), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(120, 0, 220)
        Fill.BorderSizePixel = 0
        Fill.Parent = Bar

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 6)
        FillCorner.Parent = Fill

        local dragging = false

        local function setFromX(xPos)
            local barPos = Bar.AbsolutePosition.X
            local barSize = Bar.AbsoluteSize.X
            if barSize <= 0 then return end
            local rel = math.clamp((xPos - barPos) / barSize, 0, 1)
            local val = minVal + (maxVal - minVal) * rel
            val = math.floor(val + 0.5)
            setVal(val)
            ValLabel.Text = tostring(getVal())
            Fill.Size = UDim2.new((getVal() - minVal) / (maxVal - minVal), 0, 1, 0)
        end

        Bar.InputBegan:Connect(function(inp)
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

        return {
            Row = Row,
            ValueLabel = ValLabel,
            Bar = Bar,
            Fill = Fill
        }
    end

    -----------------------------------------------------------------//
    -- TOGGLE HELPER
    ---------------------------------------------------------------------//
    local function createToggle(parent, yOffset, labelText, descText, getState, setState)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -20, 0, 56)
        Row.Position = UDim2.new(0, 10, 0, yOffset)
        Row.BackgroundTransparency = 1
        Row.Parent = parent

        local L = Instance.new("TextLabel")
        L.Size = UDim2.new(1, -80, 0, 20)
        L.Position = UDim2.new(0, 0, 0, 0)
        L.BackgroundTransparency = 1
        L.Font = Enum.Font.GothamSemibold
        L.TextSize = 14
        L.TextXAlignment = Enum.TextXAlignment.Left
        L.TextColor3 = Color3.fromRGB(235, 225, 255)
        L.Text = labelText
        L.Parent = Row

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
        D.Text = descText
        D.Parent = Row

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 60, 0, 24)
        Btn.Position = UDim2.new(1, -70, 0, 16)
        Btn.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
        Btn.BorderSizePixel = 0
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 12
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Text = getState() and "ON" or "OFF"
        Btn.Parent = Row

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = Btn

        local function refresh()
            if getState() then
                Btn.Text = "ON"
                Btn.BackgroundColor3 = Color3.fromRGB(100, 0, 180)
            else
                Btn.Text = "OFF"
                Btn.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
            end
        end

        refresh()

        Btn.MouseButton1Click:Connect(function()
            setState(not getState())
            refresh()
        end)

        return Btn
    end

    -----------------------------------------------------------------//
    -- SPEED SLIDER + TOGGLE
    ---------------------------------------------------------------------//
    createSlider(
        MainFrame,
        12,
        "Speed Boost (WalkSpeed)",
        8,
        100,
        function() return speedValue end,
        function(v) speedValue = v end
    )

    createToggle(
        MainFrame,
        76,
        "Speed Enabled",
        "When ON, your WalkSpeed will use the slider value.",
        function() return speedEnabled end,
        function(v) speedEnabled = v end
    )

    -----------------------------------------------------------------//
    -- JUMP SLIDER + TOGGLE
    ---------------------------------------------------------------------//
    createSlider(
        MainFrame,
        140,
        "Jump Boost (JumpPower)",
        25,
        150,
        function() return jumpValue end,
        function(v) jumpValue = v end
    )

    createToggle(
        MainFrame,
        204,
        "Jump Enabled",
        "When ON, your JumpPower will use the slider value.",
        function() return jumpEnabled end,
        function(v) jumpEnabled = v end
    )

    -----------------------------------------------------------------//
    -- SEMI IMMORTAL TOGGLE
    ---------------------------------------------------------------------//
    createToggle(
        MainFrame,
        270,
        "Semi-Immortal",
        "Desync-style mode (server sees movement, your camera stays stable). Logic added later.",
        function() return semiImmortalOn end,
        function(v) semiImmortalOn = v end
    )
end
---------------------------------------------------------------------//
-- VISUAL / ESP STATE
---------------------------------------------------------------------//
local espEnabled       = false
local espMode          = "Players" -- "Players", "Ball", "Both"

local headlessEnabled  = false
local korbloxEnabled   = false

---------------------------------------------------------------------//
-- VISUALS PAGE UI
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
    Title.Text = "Visuals & ESP"
    Title.Parent = VisualPage

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
    Info.Text = "Toggle ESP modes and local-only player effects (headless, korblox). ESP logic will be added later – this sets up all toggles and states."
    Info.Parent = VisualPage

    -----------------------------------------------------------------//
    -- MAIN FRAME
    -----------------------------------------------------------------//
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(1, -40, 1, -100)
    MainFrame.Position = UDim2.new(0, 20, 0, 90)
    MainFrame.BackgroundColor3 = Color3.fromRGB(14, 0, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = VisualPage

    local VCorner = Instance.new("UICorner")
    VCorner.CornerRadius = UDim.new(0, 18)
    VCorner.Parent = MainFrame

    local VStroke = Instance.new("UIStroke")
    VStroke.Color = Color3.fromRGB(80, 0, 170)
    VStroke.Thickness = 1
    VStroke.Parent = MainFrame

    -----------------------------------------------------------------//
    -- TOGGLE HELPER (VISUALS)
    -----------------------------------------------------------------//
    local function createToggleRow(parent, yOffset, titleTxt, descTxt, getState, setState)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -20, 0, 60)
        Row.Position = UDim2.new(0, 10, 0, yOffset)
        Row.BackgroundTransparency = 1
        Row.Parent = parent

        local T = Instance.new("TextLabel")
        T.Size = UDim2.new(1, -80, 0, 20)
        T.Position = UDim2.new(0, 0, 0, 0)
        T.BackgroundTransparency = 1
        T.Font = Enum.Font.GothamSemibold
        T.TextSize = 14
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.TextColor3 = Color3.fromRGB(235, 225, 255)
        T.Text = titleTxt
        T.Parent = Row

        local D = Instance.new("TextLabel")
        D.Size = UDim2.new(1, -80, 0, 30)
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
        Btn.Position = UDim2.new(1, -70, 0, 18)
        Btn.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
        Btn.BorderSizePixel = 0
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 12
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Text = getState() and "ON" or "OFF"
        Btn.Parent = Row

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = Btn

        local function refresh()
            if getState() then
                Btn.Text = "ON"
                Btn.BackgroundColor3 = Color3.fromRGB(100, 0, 180)
            else
                Btn.Text = "OFF"
                Btn.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
            end
        end

        refresh()

        Btn.MouseButton1Click:Connect(function()
            setState(not getState())
            refresh()
        end)

        return Btn
    end

    -----------------------------------------------------------------//
    -- ESP MASTER TOGGLE + MODE
    -----------------------------------------------------------------//
    local ESPRow = Instance.new("Frame")
    ESPRow.Size = UDim2.new(1, -20, 0, 72)
    ESPRow.Position = UDim2.new(0, 10, 0, 12)
    ESPRow.BackgroundTransparency = 1
    ESPRow.Parent = MainFrame

    local ESPTitle = Instance.new("TextLabel")
    ESPTitle.Size = UDim2.new(1, -80, 0, 20)
    ESPTitle.Position = UDim2.new(0, 0, 0, 0)
    ESPTitle.BackgroundTransparency = 1
    ESPTitle.Font = Enum.Font.GothamSemibold
    ESPTitle.TextSize = 14
    ESPTitle.TextXAlignment = Enum.TextXAlignment.Left
    ESPTitle.TextColor3 = Color3.fromRGB(235, 225, 255)
    ESPTitle.Text = "ESP"
    ESPTitle.Parent = ESPRow

    local ESPDesc = Instance.new("TextLabel")
    ESPDesc.Size = UDim2.new(1, -80, 0, 32)
    ESPDesc.Position = UDim2.new(0, 0, 0, 20)
    ESPDesc.BackgroundTransparency = 1
    ESPDesc.Font = Enum.Font.Gotham
    ESPDesc.TextSize = 12
    ESPDesc.TextXAlignment = Enum.TextXAlignment.Left
    ESPDesc.TextYAlignment = Enum.TextYAlignment.Top
    ESPDesc.TextWrapped = true
    ESPDesc.TextColor3 = Color3.fromRGB(200, 190, 230)
    ESPDesc.Text = "Highlight players / ball depending on mode (visual only, no hitbox changes)."
    ESPDesc.Parent = ESPRow

    local ESPToggleBtn = Instance.new("TextButton")
    ESPToggleBtn.Size = UDim2.new(0, 60, 0, 24)
    ESPToggleBtn.Position = UDim2.new(1, -70, 0, 10)
    ESPToggleBtn.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
    ESPToggleBtn.BorderSizePixel = 0
    ESPToggleBtn.Font = Enum.Font.GothamBold
    ESPToggleBtn.TextSize = 12
    ESPToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ESPToggleBtn.Text = espEnabled and "ON" or "OFF"
    ESPToggleBtn.Parent = ESPRow

    local ESPCorner = Instance.new("UICorner")
    ESPCorner.CornerRadius = UDim.new(1, 0)
    ESPCorner.Parent = ESPToggleBtn

    local function refreshESPButton()
        if espEnabled then
            ESPToggleBtn.Text = "ON"
            ESPToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 180)
        else
            ESPToggleBtn.Text = "OFF"
            ESPToggleBtn.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
        end
    end

    ESPToggleBtn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        refreshESPButton()
    end)

    refreshESPButton()

    -- ESP Mode button
    local ESPModeBtn = Instance.new("TextButton")
    ESPModeBtn.Size = UDim2.new(0, 100, 0, 24)
    ESPModeBtn.Position = UDim2.new(0, 0, 0, 46)
    ESPModeBtn.BackgroundColor3 = Color3.fromRGB(26, 0, 80)
    ESPModeBtn.BorderSizePixel = 0
    ESPModeBtn.Font = Enum.Font.GothamBold
    ESPModeBtn.TextSize = 12
    ESPModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ESPModeBtn.Text = "Mode: "..espMode
    ESPModeBtn.Parent = ESPRow

    local ESPModeCorner = Instance.new("UICorner")
    ESPModeCorner.CornerRadius = UDim.new(0, 8)
    ESPModeCorner.Parent = ESPModeBtn

    local function cycleESPMode()
        if espMode == "Players" then
            espMode = "Ball"
        elseif espMode == "Ball" then
            espMode = "Both"
        else
            espMode = "Players"
        end
        ESPModeBtn.Text = "Mode: "..espMode
    end

    ESPModeBtn.MouseButton1Click:Connect(cycleESPMode)

    -----------------------------------------------------------------//
    -- PLAYER FX: HEADLESS
    -----------------------------------------------------------------//
    createToggleRow(
        MainFrame,
        96,
        "Headless Effect",
        "Locally hide your head + face (visual only).",
        function() return headlessEnabled end,
        function(v) headlessEnabled = v end
    )

    -----------------------------------------------------------------//
    -- PLAYER FX: KORBLOX
    -----------------------------------------------------------------//
    createToggleRow(
        MainFrame,
        162,
        "Korblox Right Leg",
        "Locally hide your right leg parts to mimic Korblox.",
        function() return korbloxEnabled end,
        function(v) korbloxEnabled = v end
    )
end
---------------------------------------------------------------------//
-- UTILITY STATE
---------------------------------------------------------------------//
local fpsBoostEnabled   = false
local antiAfkEnabled    = false
local antiAfkConnection = nil

local Lighting = game:GetService("Lighting")
local VirtualUser = nil
pcall(function()
    VirtualUser = game:GetService("VirtualUser")
end)

---------------------------------------------------------------------//
-- UTILITY LOGIC
---------------------------------------------------------------------//
local function applyFpsBoost(on)
    fpsBoostEnabled = on

    -- graphics + lighting tweaks
    pcall(function()
        if settings and settings().Rendering then
            settings().Rendering.QualityLevel = on and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
        end
    end)

    pcall(function()
        if Lighting then
            if on then
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
                Lighting.Brightness = 1.5
            else
                Lighting.GlobalShadows = true
                Lighting.FogEnd = 1000
            end
        end
    end)
end

local function applyAntiAfk(on)
    antiAfkEnabled = on

    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end

    if on and LocalPlayer and VirtualUser then
        antiAfkConnection = LocalPlayer.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
    end
end

---------------------------------------------------------------------//
-- UTILITY PAGE UI
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
    Title.Text = "Utility"
    Title.Parent = UtilityPage

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
    Info.Text = "FPS/CPU tweaks and Anti-AFK. Safe client-side changes only, nothing crazy."
    Info.Parent = UtilityPage

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(1, -40, 1, -100)
    MainFrame.Position = UDim2.new(0, 20, 0, 90)
    MainFrame.BackgroundColor3 = Color3.fromRGB(14, 0, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = UtilityPage

    local UCorner = Instance.new("UICorner")
    UCorner.CornerRadius = UDim.new(0, 18)
    UCorner.Parent = MainFrame

    local UStroke = Instance.new("UIStroke")
    UStroke.Color = Color3.fromRGB(80, 0, 170)
    UStroke.Thickness = 1
    UStroke.Parent = MainFrame

    -----------------------------------------------------------------//
    -- TOGGLE HELPER
    -----------------------------------------------------------------//
    local function createToggleRow(parent, yOffset, titleTxt, descTxt, getState, setState)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -20, 0, 64)
        Row.Position = UDim2.new(0, 10, 0, yOffset)
        Row.BackgroundTransparency = 1
        Row.Parent = parent

        local T = Instance.new("TextLabel")
        T.Size = UDim2.new(1, -80, 0, 20)
        T.Position = UDim2.new(0, 0, 0, 0)
        T.BackgroundTransparency = 1
        T.Font = Enum.Font.GothamSemibold
        T.TextSize = 14
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.TextColor3 = Color3.fromRGB(235, 225, 255)
        T.Text = titleTxt
        T.Parent = Row

        local D = Instance.new("TextLabel")
        D.Size = UDim2.new(1, -80, 0, 30)
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
        Btn.Position = UDim2.new(1, -70, 0, 20)
        Btn.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
        Btn.BorderSizePixel = 0
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 12
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Text = getState() and "ON" or "OFF"
        Btn.Parent = Row

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = Btn

        local function refresh()
            if getState() then
                Btn.Text = "ON"
                Btn.BackgroundColor3 = Color3.fromRGB(100, 0, 180)
            else
                Btn.Text = "OFF"
                Btn.BackgroundColor3 = Color3.fromRGB(26, 0, 60)
            end
        end

        refresh()

        Btn.MouseButton1Click:Connect(function()
            setState(not getState())
            refresh()
        end)

        return Btn
    end

    -----------------------------------------------------------------//
    -- FPS BOOST
    -----------------------------------------------------------------//
    createToggleRow(
        MainFrame,
        12,
        "FPS / CPU Boost",
        "Lower quality level, remove some shadows, extend fog. Good for low spec or laggy servers.",
        function() return fpsBoostEnabled end,
        function(v) applyFpsBoost(v) end
    )

    -----------------------------------------------------------------//
    -- ANTI-AFK
    -----------------------------------------------------------------//
    createToggleRow(
        MainFrame,
        88,
        "Anti-AFK",
        "Prevents Roblox from kicking you for being idle by doing tiny fake inputs.",
        function() return antiAfkEnabled end,
        function(v) applyAntiAfk(v) end
    )
end
---------------------------------------------------------------------//
-- STATS / MONITOR STATE
---------------------------------------------------------------------//
local LocalizationService = game:GetService("LocalizationService")
local StatsService = game:FindService("Stats") or game:GetService("Stats")

local lastFPS = 0

-- simple humanoid helper
local function getHumanoid()
    if not LocalPlayer then return nil end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

-- FPS tracker (RenderStepped)
RunService.RenderStepped:Connect(function(dt)
    if dt > 0 then
        lastFPS = math.floor(1 / dt + 0.5)
    end
end)

local function getPingMs()
    -- Roblox built-in ping string
    local ok, ms = pcall(function()
        local net = StatsService.Network
        local serverItem = net:FindFirstChild("ServerStatsItem")
        if not serverItem then return nil end

        local pingItem = serverItem:FindFirstChild("Data Ping") or serverItem:FindFirstChild("Ping")
        if not pingItem then return nil end

        local str = pingItem:GetValueString()
        local n = tonumber(str:match("(%d+)%s*ms"))
        return n
    end)

    if ok and ms then
        return ms
    end

    return nil
end

local cachedRegion = nil
local function getRegionText()
    if cachedRegion ~= nil then
        return cachedRegion
    end

    local ok, loc = pcall(function()
        return LocalizationService.RobloxLocaleId or LocalizationService.SystemLocaleId
    end)

    if ok and loc then
        cachedRegion = tostring(loc)
    else
        cachedRegion = "Unknown"
    end

    return cachedRegion
end

---------------------------------------------------------------------//
-- STATS PAGE UI
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
    Title.Text = "Stats / Monitor"
    Title.Parent = StatsPage

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
    Info.Text = "Live FPS, Ping, Region and your current WalkSpeed / JumpPower so you can see exactly how the hub is affecting you."
    Info.Parent = StatsPage

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(1, -40, 1, -100)
    MainFrame.Position = UDim2.new(0, 20, 0, 90)
    MainFrame.BackgroundColor3 = Color3.fromRGB(14, 0, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = StatsPage

    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0, 18)
    SCorner.Parent = MainFrame

    local SStroke = Instance.new("UIStroke")
    SStroke.Color = Color3.fromRGB(80, 0, 170)
    SStroke.Thickness = 1
    SStroke.Parent = MainFrame

    -----------------------------------------------------------------//
    -- BIG STATS CARD
    -----------------------------------------------------------------//
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -20, 0, 140)
    Card.Position = UDim2.new(0, 10, 0, 14)
    Card.BackgroundColor3 = Color3.fromRGB(18, 0, 55)
    Card.BorderSizePixel = 0
    Card.Parent = MainFrame

    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(0, 16)
    CCorner.Parent = Card

    local CStroke = Instance.new("UIStroke")
    CStroke.Color = Color3.fromRGB(120, 0, 220)
    CStroke.Thickness = 1
    CStroke.Parent = Card

    local CardTitle = Instance.new("TextLabel")
    CardTitle.Size = UDim2.new(1, -20, 0, 20)
    CardTitle.Position = UDim2.new(0, 10, 0, 8)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Font = Enum.Font.GothamSemibold
    CardTitle.TextSize = 15
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left
    CardTitle.TextColor3 = Color3.fromRGB(245, 235, 255)
    CardTitle.Text = "Live Performance"
    CardTitle.Parent = Card

    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.new(0.5, -20, 0, 20)
    FPSLabel.Position = UDim2.new(0, 10, 0, 40)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Font = Enum.Font.Gotham
    FPSLabel.TextSize = 14
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
    FPSLabel.TextColor3 = Color3.fromRGB(220, 210, 240)
    FPSLabel.Text = "FPS: --"
    FPSLabel.Parent = Card

    local PingLabel = Instance.new("TextLabel")
    PingLabel.Size = UDim2.new(0.5, -20, 0, 20)
    PingLabel.Position = UDim2.new(0.5, 10, 0, 40)
    PingLabel.BackgroundTransparency = 1
    PingLabel.Font = Enum.Font.Gotham
    PingLabel.TextSize = 14
    PingLabel.TextXAlignment = Enum.TextXAlignment.Left
    PingLabel.TextColor3 = Color3.fromRGB(220, 210, 240)
    PingLabel.Text = "Ping: -- ms"
    PingLabel.Parent = Card

    local RegionLabel = Instance.new("TextLabel")
    RegionLabel.Size = UDim2.new(1, -20, 0, 20)
    RegionLabel.Position = UDim2.new(0, 10, 0, 64)
    RegionLabel.BackgroundTransparency = 1
    RegionLabel.Font = Enum.Font.Gotham
    RegionLabel.TextSize = 14
    RegionLabel.TextXAlignment = Enum.TextXAlignment.Left
    RegionLabel.TextColor3 = Color3.fromRGB(220, 210, 240)
    RegionLabel.Text = "Region: --"
    RegionLabel.Parent = Card

    local WSLabel = Instance.new("TextLabel")
    WSLabel.Size = UDim2.new(0.5, -20, 0, 20)
    WSLabel.Position = UDim2.new(0, 10, 0, 90)
    WSLabel.BackgroundTransparency = 1
    WSLabel.Font = Enum.Font.Gotham
    WSLabel.TextSize = 14
    WSLabel.TextXAlignment = Enum.TextXAlignment.Left
    WSLabel.TextColor3 = Color3.fromRGB(220, 210, 240)
    WSLabel.Text = "WalkSpeed: --"
    WSLabel.Parent = Card

    local JPLabel = Instance.new("TextLabel")
    JPLabel.Size = UDim2.new(0.5, -20, 0, 20)
    JPLabel.Position = UDim2.new(0.5, 10, 0, 90)
    JPLabel.BackgroundTransparency = 1
    JPLabel.Font = Enum.Font.Gotham
    JPLabel.TextSize = 14
    JPLabel.TextXAlignment = Enum.TextXAlignment.Left
    JPLabel.TextColor3 = Color3.fromRGB(220, 210, 240)
    JPLabel.Text = "JumpPower: --"
    JPLabel.Parent = Card

    -----------------------------------------------------------------//
    -- LOOP: UPDATE LABELS
    -----------------------------------------------------------------//
    task.spawn(function()
        while true do
            local hum = getHumanoid()
            local ws, jp = "--", "--"

            if hum then
                ws = string.format("%.1f", hum.WalkSpeed or 0)
                if hum.UseJumpPower ~= nil then
                    jp = string.format("%.1f", hum.JumpPower or 0)
                else
                    jp = "N/A"
                end
            end

            local ping = getPingMs()
            local region = getRegionText()

            FPSLabel.Text = "FPS: "..tostring(lastFPS)
            if ping then
                PingLabel.Text = "Ping: "..tostring(ping).." ms"
            else
                PingLabel.Text = "Ping: N/A"
            end
            RegionLabel.Text = "Region: "..tostring(region)
            WSLabel.Text = "WalkSpeed: "..ws
            JPLabel.Text = "JumpPower: "..jp

            task.wait(0.25)
        end
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
    -- most exploits expose mouse1click()
    local ok = pcall(function()
        if mouse1click then
            mouse1click()
        elseif VIM then
            -- fallback spam, may not work in every exploit but safe to try
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
-- MOVEMENT HELPERS (SPEED / JUMP)
---------------------------------------------------------------------//
local function applySpeed()
    if not LocalPlayer then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if not originalWalkSpeed then
        originalWalkSpeed = hum.WalkSpeed
    end

    if speedEnabled then
        hum.WalkSpeed = speedValue
    else
        if originalWalkSpeed then
            hum.WalkSpeed = originalWalkSpeed
        end
    end
end

local function applyJump()
    if not LocalPlayer then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if hum.UseJumpPower ~= nil then
        hum.UseJumpPower = true
    end

    if not originalJumpPower then
        originalJumpPower = hum.JumpPower
    end

    if jumpEnabled then
        hum.JumpPower = jumpValue
    else
        if originalJumpPower then
            hum.JumpPower = originalJumpPower
        end
    end
end

---------------------------------------------------------------------//
-- VISUAL FX HELPERS (HEADLESS / KORBLOX)
---------------------------------------------------------------------//
local function setPartTransparency(part, alpha)
    if not part or not part:IsA("BasePart") then return end
    part.Transparency = alpha
    for _, d in ipairs(part:GetDescendants()) do
        if d:IsA("Decal") or d:IsA("Texture") then
            d.Transparency = alpha
        end
    end
end

local function applyHeadless(on)
    if not LocalPlayer then return end
    local char = LocalPlayer.Character
    if not char then return end

    local head = char:FindFirstChild("Head")
    if not head then return end

    if on then
        setPartTransparency(head, 1)
    else
        setPartTransparency(head, 0)
    end
end

local function applyKorblox(on)
    if not LocalPlayer then return end
    local char = LocalPlayer.Character
    if not char then return end

    local targets = {
        "RightUpperLeg",
        "RightLowerLeg",
        "RightFoot"
    }

    for _, name in ipairs(targets) do
        local p = char:FindFirstChild(name)
        if p then
            if on then
                setPartTransparency(p, 1)
            else
                setPartTransparency(p, 0)
            end
        end
    end
end

---------------------------------------------------------------------//
-- SEMI-IMMORTAL ENGINE (DESYNC STYLE)
---------------------------------------------------------------------//
local semiImmortalThread = nil

local function startSemiImmortalLoop()
    if semiImmortalThread ~= nil then return end
    semiImmortalThread = task.spawn(function()
        local cam = workspace.CurrentCamera
        if not LocalPlayer then semiImmortalThread = nil return end

        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        if not char then semiImmortalThread = nil return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp or not cam then
            semiImmortalThread = nil
            return
        end

        -- fake anchor the camera so your view doesn't follow the crazy movement
        local fakeRoot = Instance.new("Part")
        fakeRoot.Name = "Binxix_SemiImmortal_Cam"
        fakeRoot.Size = Vector3.new(1,1,1)
        fakeRoot.Anchored = true
        fakeRoot.CanCollide = false
        fakeRoot.Transparency = 1
        fakeRoot.Parent = workspace
        fakeRoot.CFrame = hrp.CFrame

        local oldSubject = cam.CameraSubject
        cam.CameraSubject = fakeRoot

        local baseY = hrp.Position.Y
        local t0 = tick()

        while semiImmortalOn do
            if not hrp or not hrp.Parent then break end
            local pos = hrp.Position
            -- fast up/down through the map (server side)
            local t = tick() - t0
            local offset = math.sin(t * 12) * 20 -- 20 studs amplitude

            -- move real root up/down (server sees this)
            pcall(function()
                hrp.CFrame = CFrame.new(pos.X, baseY + offset, pos.Z) * hrp.CFrame.Rotation
            end)

            -- keep camera fake root closer to a grounded Y so user view feels stable
            pcall(function()
                local camPos = Vector3.new(pos.X, baseY, pos.Z)
                fakeRoot.CFrame = CFrame.new(camPos) * hrp.CFrame.Rotation
            end)

            task.wait(0.05)
        end

        -- cleanup
        pcall(function()
            if cam and oldSubject and oldSubject.Parent then
                cam.CameraSubject = oldSubject
            elseif cam and hum then
                cam.CameraSubject = hum
            end
        end)

        if fakeRoot then
            fakeRoot:Destroy()
        end

        semiImmortalThread = nil
    end)
end

local function stopSemiImmortalLoop()
    semiImmortalOn = false
    -- loop will clean itself + camera when it exits
end

---------------------------------------------------------------------//
-- WATCHERS FOR TOGGLES (MOVEMENT / VISUAL / SEMI-IMMORTAL)
---------------------------------------------------------------------//
task.spawn(function()
    local lastHeadless, lastKorblox = nil, nil
    local lastSpeedEnabled, lastJumpEnabled = nil, nil
    local lastSemi = nil

    while true do
        -- movement
        if speedEnabled ~= lastSpeedEnabled then
            lastSpeedEnabled = speedEnabled
            applySpeed()
        end

        if jumpEnabled ~= lastJumpEnabled then
            lastJumpEnabled = jumpEnabled
            applyJump()
        end

        -- visuals
        if headlessEnabled ~= lastHeadless then
            lastHeadless = headlessEnabled
            applyHeadless(headlessEnabled)
        end

        if korbloxEnabled ~= lastKorblox then
            lastKorblox = korbloxEnabled
            applyKorblox(korbloxEnabled)
        end

        -- semi-immortal
        if semiImmortalOn ~= lastSemi then
            lastSemi = semiImmortalOn
            if semiImmortalOn then
                startSemiImmortalLoop()
            else
                stopSemiImmortalLoop()
            end
        end

        task.wait(0.15)
    end
end)

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

            -- manual spam fires current manual key
            if manualSpamActive then
                pressKeyOnce(manualSpamKey)
            end

            task.wait(delay)
        end
    end
end)
