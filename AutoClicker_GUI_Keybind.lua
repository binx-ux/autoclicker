--// Auto Clicker GUI w/ Changeable Keybind
--// Toggle by GUI button or your custom key

-- // Services
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- // Try to safely parent GUI
local parentGui

local function safeParent()
    local ok, res = pcall(function()
        if gethui then
            local g = Instance.new("ScreenGui")
            g.Name = "AutoClickerGUI"
            g.ResetOnSpawn = false
            g.Parent = gethui()
            return g
        end
    end)
    if ok and res then return res end

    ok, res = pcall(function()
        if syn and syn.protect_gui then
            local g = Instance.new("ScreenGui")
            g.Name = "AutoClickerGUI"
            g.ResetOnSpawn = false
            syn.protect_gui(g)
            g.Parent = CoreGui
            return g
        end
    end)
    if ok and res then return res end

    local g = Instance.new("ScreenGui")
    g.Name = "AutoClickerGUI"
    g.ResetOnSpawn = false
    g.Parent = CoreGui
    return g
end

parentGui = safeParent()

-- // Main frame
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 230, 0, 150)
main.Position = UDim2.new(0.5, -115, 0.5, -75)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = parentGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

-- // Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 24)
title.Position = UDim2.new(0, 5, 0, 2)
title.BackgroundTransparency = 1
title.Text = "Auto Clicker"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

-- // Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -10, 0, 18)
status.Position = UDim2.new(0, 5, 0, 26)
status.BackgroundTransparency = 1
status.Text = "Status: OFF"
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextColor3 = Color3.fromRGB(255, 70, 70)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

-- // CPS Label
local cpsLabel = Instance.new("TextLabel")
cpsLabel.Size = UDim2.new(0, 80, 0, 20)
cpsLabel.Position = UDim2.new(0, 5, 0, 50)
cpsLabel.BackgroundTransparency = 1
cpsLabel.Text = "CPS:"
cpsLabel.Font = Enum.Font.Gotham
cpsLabel.TextSize = 14
cpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
cpsLabel.TextXAlignment = Enum.TextXAlignment.Left
cpsLabel.Parent = main

-- // CPS TextBox
local cpsBox = Instance.new("TextBox")
cpsBox.Size = UDim2.new(0, 60, 0, 22)
cpsBox.Position = UDim2.new(0, 50, 0, 48)
cpsBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
cpsBox.BorderSizePixel = 0
cpsBox.Text = "10"
cpsBox.Font = Enum.Font.Gotham
cpsBox.TextSize = 14
cpsBox.TextColor3 = Color3.fromRGB(255, 255, 255)
cpsBox.ClearTextOnFocus = false
cpsBox.Parent = main

local cpsCorner = Instance.new("UICorner")
cpsCorner.CornerRadius = UDim.new(0, 6)
cpsCorner.Parent = cpsBox

-- // Keybind label
local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(0, 80, 0, 20)
keyLabel.Position = UDim2.new(0, 5, 0, 76)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Keybind:"
keyLabel.Font = Enum.Font.Gotham
keyLabel.TextSize = 14
keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.Parent = main

-- // Keybind display button
local keyButton = Instance.new("TextButton")
keyButton.Size = UDim2.new(0, 60, 0, 22)
keyButton.Position = UDim2.new(0, 70, 0, 74)
keyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
keyButton.BorderSizePixel = 0
keyButton.Text = "F"
keyButton.Font = Enum.Font.GothamBold
keyButton.TextSize = 14
keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
keyButton.Parent = main

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 6)
keyCorner.Parent = keyButton

-- // Info label under keybind
local keyInfo = Instance.new("TextLabel")
keyInfo.Size = UDim2.new(1, -10, 0, 18)
keyInfo.Position = UDim2.new(0, 5, 0, 100)
keyInfo.BackgroundTransparency = 1
keyInfo.Text = "Click button, then press a key"
keyInfo.Font = Enum.Font.Gotham
keyInfo.TextSize = 12
keyInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
keyInfo.TextXAlignment = Enum.TextXAlignment.Left
keyInfo.Parent = main

-- // Toggle button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 210, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 120)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "Start"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Parent = main

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleBtn

-- // Logic vars
local clicking = false
local cps = 10
local toggleKey = Enum.KeyCode.F
local listeningForKey = false

-- // Small helper to make key name pretty
local function keyToString(keycode)
    local s = tostring(keycode) -- "Enum.KeyCode.F"
    return s:match("%.(.+)") or s
end

-- // Parse CPS
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

-- // Update UI visuals based on clicking state
local function updateUI()
    if clicking then
        toggleBtn.Text = "Stop"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 70)
        status.Text = ("Status: ON (%d CPS)"):format(cps)
        status.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        toggleBtn.Text = "Start"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        status.Text = "Status: OFF"
        status.TextColor3 = Color3.fromRGB(255, 70, 70)
    end
end

-- // Toggle function
local function toggleClicker()
    clicking = not clicking
    cps = getCPS()
    updateUI()
end

-- // GUI button: start/stop
toggleBtn.MouseButton1Click:Connect(function()
    toggleClicker()
end)

-- // CPS box changed
cpsBox.FocusLost:Connect(function()
    cps = getCPS()
    if clicking then
        updateUI()
    end
end)

-- // Keybind change flow
keyButton.MouseButton1Click:Connect(function()
    if listeningForKey then return end
    listeningForKey = true
    keyInfo.Text = "Press a key..."
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    -- If we're rebinding key
    if listeningForKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            toggleKey = input.KeyCode
            keyButton.Text = keyToString(toggleKey)
            keyInfo.Text = "Keybind set to: " .. keyButton.Text
            listeningForKey = false
        end
        return
    end

    -- Normal toggle with keybind
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == toggleKey then
            toggleClicker()
        end
    end
end)

-- // Click loop
task.spawn(function()
    while true do
        if clicking then
            pcall(function()
                mouse1click()
            end)

            cps = getCPS()
            local delay = 1 / cps
            if delay < 0.001 then
                delay = 0.001
            end
            task.wait(delay)
        else
            task.wait(0.05)
        end
    end
end)

