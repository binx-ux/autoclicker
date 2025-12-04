-- Bin Hub X - Simple Stable Hub w/ Sidebar + Autoclicker
-- RCTRL = Show/Hide hub

---------------------------------------------------------------------//
-- SERVICES / SCREEN GUI
---------------------------------------------------------------------//
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

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
-- ROOT WINDOW
---------------------------------------------------------------------//
local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.new(0, 720, 0, 380)
root.Position = UDim2.new(0.5, -360, 0.5, -190)
root.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
root.BorderSizePixel = 0
root.Active = true
root.Draggable = true
root.Parent = gui

local rootCorner = Instance.new("UICorner")
rootCorner.CornerRadius = UDim.new(0, 18)
rootCorner.Parent = root

local rootStroke = Instance.new("UIStroke")
rootStroke.Thickness = 1
rootStroke.Color = Color3.fromRGB(60, 60, 60)
rootStroke.Parent = root

---------------------------------------------------------------------//
-- SIDEBAR (VERY SIMPLE & HARD-CODED)
---------------------------------------------------------------------//
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 220, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
sidebar.BorderSizePixel = 0
sidebar.Parent = root

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 18)
sidebarCorner.Parent = sidebar

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Thickness = 1
sidebarStroke.Color = Color3.fromRGB(40, 40, 45)
sidebarStroke.Parent = sidebar

-- title
local titleBar = Instance.new("TextLabel")
titleBar.Name = "Title"
titleBar.Size = UDim2.new(1, -20, 0, 30)
titleBar.Position = UDim2.new(0, 10, 0, 10)
titleBar.BackgroundTransparency = 1
titleBar.Font = Enum.Font.GothamBlack
titleBar.TextSize = 20
titleBar.Text = "Bin Hub X"
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Parent = sidebar

-- version pill
local versionPill = Instance.new("TextLabel")
versionPill.Size = UDim2.new(0, 60, 0, 22)
versionPill.Position = UDim2.new(1, -70, 0, 12)
versionPill.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
versionPill.BorderSizePixel = 0
versionPill.Font = Enum.Font.GothamBold
versionPill.Text = "v1.0"
versionPill.TextSize = 14
versionPill.TextColor3 = Color3.fromRGB(255, 255, 255)
versionPill.Parent = sidebar

local versionCorner = Instance.new("UICorner")
versionCorner.CornerRadius = UDim.new(1, 0)
versionCorner.Parent = versionPill

-- simple search bar
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 50)
searchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "Search"
searchBox.Text = ""
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
searchBox.Parent = sidebar

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = searchBox

-- nav holder
local navHolder = Instance.new("Frame")
navHolder.Size = UDim2.new(1, -20, 1, -140)
navHolder.Position = UDim2.new(0, 10, 0, 90)
navHolder.BackgroundTransparency = 1
navHolder.Parent = sidebar

local navLayout = Instance.new("UIListLayout")
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Padding = UDim.new(0, 4)
navLayout.Parent = navHolder

local pages = {}
local navButtons = {}
local currentPage = nil

local function setActivePage(name)
    for k, v in pairs(pages) do
        v.Visible = (k == name)
    end
    for k, v in pairs(navButtons) do
        if k == name then
            v.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
        else
            v.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        end
    end
    currentPage = name
end

local function createSectionLabel(txt)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(150, 150, 160)
    lbl.Text = txt
    lbl.Parent = navHolder
    return lbl
end

local function createNavButton(name, txt)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextColor3 = Color3.fromRGB(230, 230, 235)
    btn.Text = txt
    btn.Parent = navHolder

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        setActivePage(name)
    end)

    navButtons[name] = btn
    return btn
end

-- sections + buttons
createSectionLabel("Home")
createNavButton("Home", ".Home")

createSectionLabel("Main")
createNavButton("Main", "Main")
createNavButton("Blatant", "Blatant")
createNavButton("Others", "Others")

createSectionLabel("Settings")
createNavButton("Settings", "Settings")

-- profile bottom
local profileFrame = Instance.new("Frame")
profileFrame.Size = UDim2.new(1, -20, 0, 60)
profileFrame.Position = UDim2.new(0, 10, 1, -70)
profileFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
profileFrame.BorderSizePixel = 0
profileFrame.Parent = sidebar

local pfCorner = Instance.new("UICorner")
pfCorner.CornerRadius = UDim.new(0, 12)
pfCorner.Parent = profileFrame

local pfName = Instance.new("TextLabel")
pfName.Size = UDim2.new(1, -10, 0, 22)
pfName.Position = UDim2.new(0, 10, 0, 8)
pfName.BackgroundTransparency = 1
pfName.Font = Enum.Font.GothamBold
pfName.TextSize = 14
pfName.TextColor3 = Color3.fromRGB(255, 255, 255)
pfName.TextXAlignment = Enum.TextXAlignment.Left
pfName.Text = "Bin"
pfName.Parent = profileFrame

local pfTag = Instance.new("TextLabel")
pfTag.Size = UDim2.new(1, -10, 0, 18)
pfTag.Position = UDim2.new(0, 10, 0, 30)
pfTag.BackgroundTransparency = 1
pfTag.Font = Enum.Font.Gotham
pfTag.TextSize = 12
pfTag.TextColor3 = Color3.fromRGB(170, 170, 180)
pfTag.TextXAlignment = Enum.TextXAlignment.Left
pfTag.Text = "@TheReal_binxix"
pfTag.Parent = profileFrame

---------------------------------------------------------------------//
-- TOP BAR + CONTENT HOLDER
---------------------------------------------------------------------//
local contentTop = Instance.new("Frame")
contentTop.Size = UDim2.new(1, -220, 0, 32)
contentTop.Position = UDim2.new(0, 220, 0, 0)
contentTop.BackgroundTransparency = 1
contentTop.Parent = root

local topTitle = Instance.new("TextLabel")
topTitle.Size = UDim2.new(1, -60, 1, 0)
topTitle.Position = UDim2.new(0, 10, 0, 0)
topTitle.BackgroundTransparency = 1
topTitle.Font = Enum.Font.GothamBold
topTitle.TextSize = 18
topTitle.TextXAlignment = Enum.TextXAlignment.Left
topTitle.TextColor3 = Color3.fromRGB(235, 235, 240)
topTitle.Text = "AutoClicker Hub"
topTitle.Parent = contentTop

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -30, 0.5, -13)
closeBtn.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "X"
closeBtn.Parent = contentTop

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    guiVisible = false
    gui.Enabled = false
end)

local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -220, 1, -32)
contentHolder.Position = UDim2.new(0, 220, 0, 32)
contentHolder.BackgroundTransparency = 1
contentHolder.Parent = root

local function createPage(name)
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    page.BorderSizePixel = 0
    page.Visible = false
    page.Parent = contentHolder

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 14)
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
local homePage = createPage("Home")
local blatantPage = createPage("Blatant")
local othersPage = createPage("Others")
local settingsPage = createPage("Settings")
local mainPage = createPage("Main")

-- home text
do
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -40, 0, 40)
    t.Position = UDim2.new(0, 20, 0, 20)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBlack
    t.TextSize = 24
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Top
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.Text = "Hello, Bin"
    t.Parent = homePage

    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1, -40, 0, 80)
    d.Position = UDim2.new(0, 20, 0, 60)
    d.BackgroundTransparency = 1
    d.Font = Enum.Font.Gotham
    d.TextSize = 14
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextYAlignment = Enum.TextYAlignment.Top
    d.TextWrapped = true
    d.TextColor3 = Color3.fromRGB(210, 210, 220)
    d.Text = "Welcome to Bin Hub X. Use the 'Main' tab on the left to control your autoclicker with CPS, keybinds and Toggle/Hold modes."
    d.Parent = homePage
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
    l.Parent = parent
end

simpleLabel(blatantPage, "Blatant tab placeholder.\nYou can add more aggressive scripts here later.")
simpleLabel(othersPage, "Others tab placeholder.\nDrop utilities and extra tools here later.")
simpleLabel(settingsPage, "Settings tab.\n\n• RightCtrl = Show/Hide hub\n• Close button = hide hub\n\nMore settings can be added here later.")

---------------------------------------------------------------------//
-- MAIN PAGE (AUTOCLICKER UI)
---------------------------------------------------------------------//
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 24)
status.Position = UDim2.new(0, 20, 0, 20)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 16
status.TextXAlignment = Enum.TextXAlignment.Left
status.Text = "Status: OFF (Toggle)"
status.TextColor3 = Color3.fromRGB(255, 80, 80)
status.Parent = mainPage

local cpsLabel = Instance.new("TextLabel")
cpsLabel.Size = UDim2.new(0, 80, 0, 20)
cpsLabel.Position = UDim2.new(0, 20, 0, 60)
cpsLabel.BackgroundTransparency = 1
cpsLabel.Font = Enum.Font.Gotham
cpsLabel.TextSize = 14
cpsLabel.TextXAlignment = Enum.TextXAlignment.Left
cpsLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
cpsLabel.Text = "CPS:"
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
cpsBox.Parent = mainPage

local cpsCorner = Instance.new("UICorner")
cpsCorner.CornerRadius = UDim.new(0, 8)
cpsCorner.Parent = cpsBox

local keyLabel = cpsLabel:Clone()
keyLabel.Text = "Keybind:"
keyLabel.Position = UDim2.new(0, 20, 0, 96)
keyLabel.Parent = mainPage

local keyButton = Instance.new("TextButton")
keyButton.Size = UDim2.new(0, 70, 0, 24)
keyButton.Position = UDim2.new(0, 90, 0, 94)
keyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
keyButton.BorderSizePixel = 0
keyButton.Font = Enum.Font.GothamBold
keyButton.TextSize = 14
keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
keyButton.Text = "F"
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
modeButton.Parent = mainPage

local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0, 8)
modeCorner.Parent = modeButton

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -40, 0, 40)
infoLabel.Position = UDim2.new(0, 20, 0, 164)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
infoLabel.Text = "Click keybind button, then press a key. RightCtrl is reserved for hub toggle. Use mode to switch between Toggle / Hold."
infoLabel.Parent = mainPage

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 220, 0, 34)
toggleBtn.Position = UDim2.new(0, 20, 0, 216)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
toggleBtn.BorderSizePixel = 0
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "Start"
toggleBtn.Parent = mainPage

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleBtn

---------------------------------------------------------------------//
-- AUTOCLICKER LOGIC
---------------------------------------------------------------------//
local clicking = false
local cps = 10
local toggleKey = Enum.KeyCode.F
local listeningForKey = false
local mode = "Toggle" -- Toggle / Hold

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

local function updateUI()
    if clicking then
        toggleBtn.Text = "Stop"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 70)
        status.Text = ("Status: ON (%d CPS, %s)"):format(cps, mode)
        status.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        toggleBtn.Text = "Start"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        status.Text = ("Status: OFF (%s)"):format(mode)
        status.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

local function toggleClicker()
    clicking = not clicking
    cps = getCPS()
    updateUI()
end

toggleBtn.MouseButton1Click:Connect(toggleClicker)

cpsBox.FocusLost:Connect(function()
    cps = getCPS()
    if clicking then updateUI() end
end)

modeButton.MouseButton1Click:Connect(function()
    if mode == "Toggle" then
        mode = "Hold"
        modeButton.Text = "Hold"
    else
        mode = "Toggle"
        modeButton.Text = "Toggle"
    end
    updateUI()
end)

keyButton.MouseButton1Click:Connect(function()
    if listeningForKey then return end
    listeningForKey = true
    infoLabel.Text = "Press a key for autoclicker (RightCtrl is hub)."
end)

UIS.InputBegan:Connect(function(input, gp)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    -- hub toggle
    if input.KeyCode == Enum.KeyCode.RightControl and not listeningForKey then
        guiVisible = not guiVisible
        gui.Enabled = guiVisible
        return
    end

    -- rebinding
    if listeningForKey then
        if input.KeyCode == Enum.KeyCode.RightControl then
            infoLabel.Text = "RightCtrl is reserved for hub toggle."
        else
            toggleKey = input.KeyCode
            keyButton.Text = keyToString(toggleKey)
            infoLabel.Text = "Keybind set to: " .. keyButton.Text
            listeningForKey = false
        end
        return
    end

    if gp then return end

    if input.KeyCode == toggleKey then
        if mode == "Toggle" then
            toggleClicker()
        elseif mode == "Hold" then
            clicking = true
            cps = getCPS()
            updateUI()
        end
    end
end)

UIS.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if input.KeyCode == toggleKey and mode == "Hold" then
        clicking = false
        updateUI()
    end
end)

task.spawn(function()
    while true do
        if clicking then
            pcall(function()
                mouse1click()
            end)
            cps = getCPS()
            local d = 1 / cps
            if d < 0.001 then d = 0.001 end
            task.wait(d)
        else
            task.wait(0.05)
        end
    end
end)

---------------------------------------------------------------------//
-- START ON HOME
---------------------------------------------------------------------//
setActivePage("Home")

