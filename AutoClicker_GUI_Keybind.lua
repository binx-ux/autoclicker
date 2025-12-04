--// Auto Clicker GUI w/ Changeable Keybind + Hold/Toggle Mode + RCTRL Show/Hide
--// Made for Anthony (binx-ux)

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
            syn.protect_gui(g)
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
main.Size = UDim2.new(0, 240, 0, 170)
main.Position = UDim2.new(0.5, -120, 0.5, -85)
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

-- // Mode label (Toggle / Hold)
local modeLabel = Instance.new("TextLabel")
modeLabel.Size = UDim2.new(0, 80, 0, 20)
modeLabel.Position = UDim2.new(0, 5, 0, 102)
modeLabel.BackgroundTransparency = 1
modeLabel.Text = "Mode:"
modeLabel.Font = Enum.Font.Gotham
modeLabel.TextSize = 14
modeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
modeLabel.TextXAlignment = Enum.TextXAlignment.Left
modeLabel.Parent = main

local modeButton = Instance.new("TextButton")
modeButton.Size = UDim2.new(0, 80, 0, 22)
modeButton.Position = UDim2.new(0, 70, 0, 100)
modeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
modeButton.BorderSizePixel = 0
modeButton.Text = "Toggle"
modeButton.Font = Enum.Font.GothamBold
modeButton.TextSize = 14
modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
modeButton.Parent = main

local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0, 6)
modeCorner.Parent = modeButton

-- // Info label
local keyInfo = Instance.new("TextLabel")
keyInfo.Size = UDim2.new(1, -10, 0, 18)
keyInfo.Position = UDim2.new(0, 5, 0, 126)
keyInfo.BackgroundTransparency = 1
keyInfo.Text = "Keybind + Mode | RCTRL = Show/Hide"
keyInfo.Font = Enum.Font.Gotham
keyInfo.TextSize = 11
keyInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
keyInfo.TextXAlignment = Enum.TextXAlignment.Left
keyInfo.Parent = main

-- // Toggle button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 220, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 138)
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
local mode = "Toggle" -- "Toggle" or "Hold"
local guiVisible = true

-- // helper: key name
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

-- // Update UI visuals
local function updateUI()
    if clicking then
        toggleBtn.Text = "Stop"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 70)
        status.Text = ("Status: ON (%d CPS, %s)"):format(cps, mode)
        status.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        toggleBtn.Text = "Start"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        status.Text = ("Status: OFF (%s)"):format(mode)
        status.TextColor3 = Color3.fromRGB(255, 70, 70)
    end
end

-- // Toggle function (for Toggle mode and GUI button)
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

-- // Mode button (Toggle <-> Hold)
modeButton.MouseButton1Click:Connect(function()
    if mode == "Toggle" then
        mode = "Hold"
        modeButton.Text = "Hold"
    else
        mode = "Toggle"
        modeButton.Text = "Toggle"
    end
    -- if we switch mode while on, just refresh text
    updateUI()
end)

-- // Keybind change flow
keyButton.MouseButton1Click:Connect(function()
    if listeningForKey then return end
    listeningForKey = true
    keyInfo.Text = "Press a key (RCTRL reserved)"
end)

-- // Input handling
UIS.InputBegan:Connect(function(input, gameProcessed)
    -- Global show/hide with Right Control
    if input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode == Enum.KeyCode.RightControl
        and not listeningForKey then

        guiVisible = not guiVisible
        parentGui.Enabled = guiVisible
        return
    end

    -- If we're rebinding key
    if listeningForKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.RightControl then
                -- Reserve RCTRL for GUI toggle
                keyInfo.Text = "RCTRL is GUI toggle only"
            else
                toggleKey = input.KeyCode
                keyButton.Text = keyToString(toggleKey)
                keyInfo.Text = "Keybind set to: " .. keyButton.Text
                listeningForKey = false
            end
        end
        return
    end

    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == toggleKey then
            if mode == "Toggle" then
                -- normal toggle behavior
                toggleClicker()
            elseif mode == "Hold" then
                -- start clicking while key is held
                clicking = true
                cps = getCPS()
                updateUI()
            end
        end
    end
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == toggleKey and mode == "Hold" then
            -- stop when key released in hold mode
            clicking = false
            updateUI()
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
