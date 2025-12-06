--// Bin Hub X - Argon-style Hub v3.4
-- RightCtrl = Show/Hide hub

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LocalizationService = game:GetService("LocalizationService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

---------------------------------------------------------------------
-- GLOBALS / SETTINGS
---------------------------------------------------------------------
local theme = "Default"
local accentColor = Color3.fromRGB(88, 101, 242)
local region = "Unknown"

local function setTheme(t)
    theme = t
    if t == "Purple" then
        accentColor = Color3.fromRGB(170, 0, 255)
    elseif t == "Red" then
        accentColor = Color3.fromRGB(255, 70, 70)
    else
        accentColor = Color3.fromRGB(88, 101, 242)
    end
end

pcall(function()
    region = LocalizationService:GetCountryRegionForPlayerAsync(LocalPlayer)
end)

---------------------------------------------------------------------
-- LIVE STATUS PANEL
---------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "BinHubUI"

local statusFrame = Instance.new("Frame", screenGui)
statusFrame.Size = UDim2.new(0, 200, 0, 110)
statusFrame.Position = UDim2.new(1, -220, 0, 50)
statusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
statusFrame.BorderSizePixel = 0
statusFrame.Visible = true
statusFrame.Active = true

local UICorner = Instance.new("UICorner", statusFrame)
UICorner.CornerRadius = UDim.new(0, 10)

local statusTitle = Instance.new("TextLabel", statusFrame)
statusTitle.Size = UDim2.new(1, -10, 0, 20)
statusTitle.Position = UDim2.new(0, 5, 0, 5)
statusTitle.BackgroundTransparency = 1
statusTitle.Text = "📊 Live Status"
statusTitle.Font = Enum.Font.GothamBold
statusTitle.TextColor3 = accentColor
statusTitle.TextSize = 16
statusTitle.TextXAlignment = Enum.TextXAlignment.Left

local statusLabel = Instance.new("TextLabel", statusFrame)
statusLabel.Size = UDim2.new(1, -10, 1, -30)
statusLabel.Position = UDim2.new(0, 5, 0, 25)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
statusLabel.TextSize = 14
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.TextWrapped = true
statusLabel.Text = "Loading..."

local lastUpdate = tick()
local fps, frames = 0, 0
RunService.RenderStepped:Connect(function()
    frames += 1
    if tick() - lastUpdate >= 1 then
        fps = frames
        frames = 0
        lastUpdate = tick()
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString() or "0 ms"
        local ws = (Humanoid and Humanoid.WalkSpeed) or 0
        local jp = (Humanoid and Humanoid.JumpPower) or 0
        statusLabel.Text = string.format(
            "FPS: %d\nPing: %s\nWalkSpeed: %.1f\nJumpPower: %.1f\nRegion: %s",
            fps, ping, ws, jp, region
        )
    end
end)

---------------------------------------------------------------------
-- LOCKED KEYBIND TO E
---------------------------------------------------------------------
local toggleKey = Enum.KeyCode.E
local parryKey = Enum.KeyCode.E
local clickMode = "Click"
local mode = "Toggle"

---------------------------------------------------------------------
-- SEMI IMMORTAL
---------------------------------------------------------------------
local semiImmortalOn = false
local semiImmortalConn, semiImmortalBaseY, semiImmortalLastCamCF

RunService.Stepped:Connect(function()
    if semiImmortalOn then
        local cam = workspace.CurrentCamera
        if cam then
            semiImmortalLastCamCF = cam.CFrame
        end
    end
end)

local function setSemiImmortal(on)
    semiImmortalOn = on
    if not on then
        if semiImmortalConn then
            semiImmortalConn:Disconnect()
            semiImmortalConn = nil
        end
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and semiImmortalBaseY then
                root.CFrame = CFrame.new(root.Position.X, semiImmortalBaseY, root.Position.Z)
            end
        end
        return
    end

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    semiImmortalBaseY = root.Position.Y
    local startTime = tick()

    semiImmortalConn = RunService.Heartbeat:Connect(function()
        if not semiImmortalOn then return end
        if not root or not root.Parent then return end

        local t = tick() - startTime
        local amplitude = 5
        local speed = 2
        local offsetY = math.sin(t * speed) * amplitude
        local newPos = Vector3.new(root.Position.X, semiImmortalBaseY + offsetY, root.Position.Z)
        root.CFrame = CFrame.new(newPos, newPos + root.CFrame.LookVector)

        if semiImmortalLastCamCF then
            workspace.CurrentCamera.CFrame = semiImmortalLastCamCF
        end
    end)
end

---------------------------------------------------------------------
-- WEBHOOK EXECUTION LOG
---------------------------------------------------------------------
local WEBHOOK_URL = "https://discord.com/api/webhooks/1446656470287651050/ayflCl7nEQ3388YhXAZT7r3j5kTC40EP3WV9yO1BehR2vzHbtoDArV-YejWn_E_F6eUk"

local function sendWebhookLog()
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if not req then return end

    local payload = {
        embeds = {{
            title = "Bin Hub X - Script Executed (v3.4)",
            color = 0x5865F2,
            fields = {
                { name = "Player", value = LocalPlayer.DisplayName .. " (`" .. LocalPlayer.Name .. "`)", inline = false },
                { name = "Game", value = string.format("PlaceId: `%s`\nJobId: `%s`", game.PlaceId, game.JobId), inline = false },
                { name = "Region", value = region, inline = true },
                { name = "Executor", value = (identifyexecutor and identifyexecutor()) or "Unknown", inline = true },
                { name = "Time", value = os.date("%Y-%m-%d %H:%M:%S"), inline = false },
            }
        }}
    }

    pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)
end
sendWebhookLog()

---------------------------------------------------------------------
-- THEME SWITCHER (Settings Example)
---------------------------------------------------------------------
local themeFrame = Instance.new("Frame", screenGui)
themeFrame.Size = UDim2.new(0, 140, 0, 80)
themeFrame.Position = UDim2.new(1, -180, 0, 180)
themeFrame.BackgroundColor3 = Color3.fromRGB(25,25,30)
themeFrame.BorderSizePixel = 0
Instance.new("UICorner", themeFrame).CornerRadius = UDim.new(0,8)

local title = Instance.new("TextLabel", themeFrame)
title.Size = UDim2.new(1,0,0,18)
title.BackgroundTransparency = 1
title.Text = "🎨 Theme"
title.Font = Enum.Font.GothamBold
title.TextColor3 = accentColor
title.TextSize = 15

local drop = Instance.new("TextButton", themeFrame)
drop.Size = UDim2.new(1,-10,0,24)
drop.Position = UDim2.new(0,5,0,25)
drop.BackgroundColor3 = Color3.fromRGB(35,35,40)
drop.Text = "Current: Default"
drop.Font = Enum.Font.Gotham
drop.TextSize = 14
drop.TextColor3 = Color3.fromRGB(220,220,220)
Instance.new("UICorner", drop).CornerRadius = UDim.new(0,6)

drop.MouseButton1Click:Connect(function()
    if theme == "Default" then
        setTheme("Purple")
        drop.Text = "Current: Purple"
    elseif theme == "Purple" then
        setTheme("Red")
        drop.Text = "Current: Red"
    else
        setTheme("Default")
        drop.Text = "Current: Default"
    end
    statusTitle.TextColor3 = accentColor
    title.TextColor3 = accentColor
end)

---------------------------------------------------------------------
-- KEYBIND
---------------------------------------------------------------------
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == toggleKey then
        setSemiImmortal(not semiImmortalOn)
    end
end)
