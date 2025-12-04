-- Bin Hub X - AutoClicker Hub
-- Full sidebar hub style UI + autoclicker in "Main" tab
-- RCTRL = Show/Hide GUI

--// Services
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

--// Safe parent
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
local guiVisible = true

--// Root window
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

-- Fake blur overlay (soft gradient background)
local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15,15,20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5,5,8))
}
bgGradient.Rotation = 45
bgGradient.Parent = root

--// Particle Dots
local function createDot()
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 4, 0, 4)
    dot.BackgroundColor3 = Color3.fromRGB(
        math.random(150,255),
        math.random(80,255),
        math.random(80,255)
    )
    dot.BorderSizePixel = 0
    dot.ZIndex = 0
    dot.Parent = root

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = dot

    dot.Position = UDim2.new(math.random(), 0, math.random(), 0)

    local function tweenDot()
        local goal = {}
        goal.Position = UDim2.new(math.random(), 0, math.random(), 0)
        local t = TweenService:Create(dot, TweenInfo.new(math.random(10,20), Enum.EasingStyle.Linear), goal)
        t:Play()
        t.Completed:Connect(tweenDot)
    end
    tweenDot()
end

for i = 1, 35 do
    createDot()
end

--// Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 220, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
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

-- Top title
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, -20, 0, 30)
titleBar.Position = UDim2.new(0, 10, 0, 10)
titleBar.BackgroundTransparency = 1
titleBar.Text = "Bin Hub X"
titleBar.Font = Enum.Font.GothamBlack
titleBar.TextSize = 20
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Parent = sidebar

-- Version pill
local versionPill = Instance.new("TextLabel")
versionPill.Size = UDim2.new(0, 60, 0, 22)
versionPill.Position = UDim2.new(1, -70, 0, 10)
versionPill.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
versionPill.Text = "v1.0"
versionPill.Font = Enum.Font.GothamBold
versionPill.TextSize = 14
versionPill.TextColor3 = Color3.fromRGB(255, 255, 255)
versionPill.Parent = sidebar

local versionCorner = Instance.new("UICorner")
versionCorner.CornerRadius = UDim.new(1, 0)
versionCorner.Parent = versionPill

-- Search bar
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
searchBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
searchBox.Parent = sidebar

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 10)
searchCorner.Parent = searchBox

-- Nav list holder
local navHolder = Instance.new("Frame")
navHolder.Size = UDim2.new(1, -20, 1, -140)
navHolder.Position = UDim2.new(0, 10, 0, 90)
navHolder.BackgroundTransparency = 1
navHolder.Parent = sidebar

local navLayout = Instance.new("UIListLayout")
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Padding = UDim.new(0, 4)
navLayout.Parent = navHolder

-- Section label helper
local function createSectionLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(140, 140, 150)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = navHolder
    return lbl
end

-- Nav button helper
local pages = {}
local currentPage = nil
local navButtons = {}

local function setActivePage(name)
    for pageName, frame in pairs(pages) do
        frame.Visible = (pageName == name)
    end
    currentPage = name

    for btnName, btn in pairs(navButtons) do
        if btnName == name then
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
        else
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        end
    end
end

local function createNavButton(name, labelText)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.BorderSizePixel = 0
    btn.Text = labelText
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(220, 220, 230)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = navHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        setActivePage(name)
    end)

    navButtons[name] = btn
    return btn
end

-- Sections & buttons
createSectionLabel("Home")
createNavButton("Home", ".Home")

createSectionLabel("Main")
createNavButton("Main", "Main")
createNavButton("Blatant", "Blatant")
createNavButton("Others", "Others")

createSectionLabel("Settings")
createNavButton("Settings", "Settings")

-- Bottom profile
local profileFrame = Instance.new("Frame")
profileFrame.Size = UDim2.new(1, -20, 0, 60)
profileFrame.Position = UDim2.new(0, 10, 1, -70)
profileFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
profileFrame.BorderSizePixel = 0
profileFrame.Parent = sidebar

local profileCorner = Instance.new("UICorner")
profileCorner.CornerRadius = UDim.new(0, 14)
profileCorner.Parent = profileFrame

local pfName = Instance.new("TextLabel")
pfName.Size = UDim2.new(1, -10, 0, 22)
pfName.Position = UDim2.new(0, 10, 0, 8)
pfName.BackgroundTransparency = 1
pfName.Text = "Bin"
pfName.Font = Enum.Font.GothamBold
pfName.TextSize = 14
pfName.TextColor3 = Color3.fromRGB(255, 255, 255)
pfName.TextXAlignment = Enum.TextXAlignment.Left
pfName.Parent = profileFrame

local pfTag = Instance.new("TextLabel")
pfTag.Size = UDim2.new(1, -10, 0, 18)
pfTag.Position = UDim2.new(0, 10, 0, 30)
pfTag.BackgroundTransparency = 1
pfTag.Text = "@TheReal_binxix"
pfTag.Font = Enum.Font.Gotham
pfTag.TextSize = 12
pfTag.TextColor3 = Color3.fromRGB(160, 160, 170)
pfTag.TextXAlignment = Enum.TextXAlignment.Left
pfTag.Parent = profileFrame

--// Top bar for main content (window controls)
local contentTop = Instance.new("Frame")
contentTop.Size = UDim2.new(1, -230, 0, 36)
contentTop.Position = UDim2.new(0, 230, 0, 0)
contentTop.BackgroundTransparency = 1
contentTop.Parent = root

local topTitle = Instance.new("TextLabel")
topTitle.Size = UDim2.new(1, -80, 1, 0)
topTitle.Position = UDim2.new(0, 10, 0, 0)
topTitle.BackgroundTransparency = 1
topTitle.TextXAlignment = Enum.TextXAlignment.Left
topTitle.Text = "AutoClicker Hub"
topTitle.Font = Enum.Font.GothamBold
topTitle.TextSize = 18
topTitle.TextColor3 = Color3.fromRGB(235, 235, 240)
topTitle.Parent = contentTop

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -32, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 25, 25)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = contentTop

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    guiVisible = false
    gui.Enabled = false
end)

--// Main content container
local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -230, 1, -40)
contentHolder.Position = UDim2.new(0, 230, 0, 40)
contentHolder.BackgroundTransparency = 1
contentHolder.Parent = root

-- Helper to create page frame
local function createPage(name)
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    page.BorderSizePixel = 0
    page.Visible = false
    page.Parent = contentHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = page

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(40, 40, 45)
    stroke.Parent = page

    pages[name] = page
    return page
end

--// Home page
local homePage = createPage("Home")

local homeTitle = Instance.new("TextLabel")
homeTitle.Size = UDim2.new(1, -40, 0, 40)
homeTitle.Position = UDim2.new(0, 20, 0, 20)
homeTitle.BackgroundTransparency = 1
homeTitle.TextXAlignment = Enum.TextXAlignment.Left
homeTitle.TextYAlignment = Enum.TextYAlignment.Top
homeTitle.Text = "Hello, Bin"
homeTitle.Font = Enum.Font.GothamBlack
homeTitle.TextSize = 26
homeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
homeTitle.Parent = homePage

local homeDesc = Instance.new("TextLabel")
homeDesc.Size = UDim2.new(1, -40, 0, 80)
homeDesc.Position = UDim2.new(0, 20, 0, 60)
homeDesc.BackgroundTransparency = 1
homeDesc.TextXAlignment = Enum.TextXAlignment.Left
homeDesc.TextYAlignment = Enum.TextYAlignment.Top
homeDesc.TextWrapped = true
homeDesc.Text = "Welcome to Bin Hub X. This hub controls your custom autoclicker with keybinds, CPS, and hold/toggle modes. Switch to 'Main' on the left to start cooking."
homeDesc.Font = Enum.Font.Gotham
homeDesc.TextSize = 14
homeDesc.TextColor3 = Color3.fromRGB(210, 210, 220)
homeDesc.Parent = homePage

--// Blatant / Others / Settings placeholder pages
local blatantPage = createPage("Blatant")
local blatantLabel = Instance.new("TextLabel")
blatantLabel.Size = UDim2.new(1, -40, 1, -40)
blatantLabel.Position = UDim2.new(0, 20, 0, 20)
blatantLabel.BackgroundTransparency = 1
blatantLabel.TextWrapped = true
blatantLabel.TextXAlignment = Enum.TextXAlignment.Left
blatantLabel.TextYAlignment = Enum.TextYAlignment.Top
blatantLabel.Text = "Blatant tab placeholder.\nYou can add more scripts/features here later."
blatantLabel.Font = Enum.Font.Gotham
blatantLabel.TextSize = 16
blatantLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
blatantLabel.Parent = blatantPage

local othersPage = createPage("Others")
local othersLabel = blatantLabel:Clone()
othersLabel.Text = "Others tab placeholder.\nDrop utilities or fun stuff here later."
othersLabel.Parent = othersPage

local settingsPage = createPage("Settings")
local settingsLabel = blatantLabel:Clone()
settingsLabel.Text = "Settings tab.\n• RCTRL = Show/Hide Hub\n• Close button top-right hides hub\n\nMore settings can be added here."
settingsLabel.Parent = settingsPage

--// MAIN PAGE (AutoClicker UI)
local mainPage = createPage("Main")

-- Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 24)
status.Position = UDim2.new(0, 20, 0, 20)
status.BackgroundTransparency = 1
status.TextXAlignment = Enum.TextXAlignment.Left
status.Text = "Status: OFF (Toggle)"
status.Font = Enum.Font.Gotham
status.TextSize = 16
status.TextColor3 = Color3.fromRGB(255, 80, 80)
status.Parent = mainPage

-- CPS label
local cpsLabel = Instance.new("TextLabel")
cpsLabel.Size = UDim2.new(0, 80, 0, 20)
cpsLabel.Position = UDim2.new(0, 20, 0, 60)
cpsLabel.BackgroundTransparency = 1
cpsLabel.Text = "CPS:"
cpsLabel.Font = Enum.Font.Gotham
cpsLabel.TextSize = 14
cpsLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
cpsLabel.TextXAlignment = Enum.TextXAlignment.Left
cpsLabel.Parent = mainPage

local cpsBox = Instance.new("TextBox")
cpsBox.Size = UDim2.new(0, 70, 0, 24)
cpsBox.Position = UDim2.new(0, 70, 0, 58)
cpsBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
cpsBox.BorderSizePixel = 0
cpsBox.Text = "10"
cpsBox.Font = Enum.Font.Gotham
cpsBox.TextSize = 14
cpsBox.TextColor3 = Color3.fromRGB(255, 255, 255)
cpsBox.ClearTextOnFocus = false
cpsBox.Parent = mainPage

local cpsCorner = Instance.new("UICorner")
cpsCorner.CornerRadius = UDim.new(0, 8)
cpsCorner.Parent = cpsBox

-- Keybind
local keyLabel = cpsLabel:Clone()
keyLabel.Text = "Keybind:"
keyLabel.Position = UDim2.new(0, 20, 0, 96)
keyLabel.Parent = mainPage

local keyButton = Instance.new("TextButton")
keyButton.Size = UDim2.new(0, 70, 0, 24)
keyButton.Position = UDim2.new(0, 90, 0, 94)
keyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
keyButton.BorderSizePixel = 0
keyButton.Text = "F"
keyButton.Font = Enum.Font.GothamBold
keyButton.TextSize = 14
keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
keyButton.Parent = mainPage

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 8)
keyCorner.Parent = keyButton

-- Mode
local modeLabel = cpsLabel:Clone()
modeLabel.Text = "Mode:"
modeLabel.Position = UDim2.new(0, 20, 0, 132)
modeLabel.Parent = mainPage

local modeButton = Instance.new("TextButton")
modeButton.Size = UDim2.new(0, 90, 0, 24)
modeButton.Position = UDim2.new(0, 80, 0, 130)
modeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
modeButton.BorderSizePixel = 0
modeButton.Text = "Toggle"
modeButton.Font = Enum.Font.GothamBold
modeButton.TextSize = 14
modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
modeButton.Parent = mainPage

local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0, 8)
modeCorner.Parent = modeButton

-- Info
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -40, 0, 40)
infoLabel.Position = UDim2.new(0, 20, 0, 164)
infoLabel.BackgroundTransparency = 1
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Text = "Click keybind button, then press a key. RCTRL is reserved for hub toggle. Use mode to switch between Toggle / Hold."
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
infoLabel.Parent = mainPage

-- Start/Stop button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 220, 0, 34)
toggleBtn.Position = UDim2.new(0, 20, 0, 216)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "Start"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Parent = mainPage

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleBtn

--// AutoClicker Logic
local clicking = false
local cps = 10
local toggleKey = Enum.KeyCode.F
local listeningForKey = false
local mode = "Toggle" -- "Toggle" or "Hold"

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

toggleBtn.MouseButton1Click:Connect(function()
    toggleClicker()
end)

cpsBox.FocusLost:Connect(function()
    cps = getCPS()
    if clicking then
        updateUI()
    end
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
    infoLabel.Text = "Press a key for autoclicker (RCTRL is for hub)."
end)

UIS.InputBegan:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        -- RCTRL: show/hide GUI
        if input.KeyCode == Enum.KeyCode.RightControl and not listeningForKey then
            guiVisible = not guiVisible
            gui.Enabled = guiVisible
            return
        end

        -- Rebinding keybind
        if listeningForKey then
            if input.KeyCode == Enum.KeyCode.RightControl then
                infoLabel.Text = "RCTRL is reserved for hub toggle."
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
    end
end)

UIS.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == toggleKey and mode == "Hold" then
            clicking = false
            updateUI()
        end
    end
end)

task.spawn(function()
    while true do
        if clicking then
            pcall(function()
                mouse1click()
            end)
            cps = getCPS()
            local delay = 1 / cps
            if delay < 0.001 then delay = 0.001 end
            task.wait(delay)
        else
            task.wait(0.05)
        end
    end
end)

--// Start on Home page
setActivePage("Home")
