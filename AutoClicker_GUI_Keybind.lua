---------------------------------------------------------------------
-- Argon-Bin Hub X v3.5  
-- Clean Rebuild Edition (Binxix Custom)
-- RightCtrl = Show/Hide Hub
---------------------------------------------------------------------

---------------------------------------------------------------------
-- SERVICES / SETUP
---------------------------------------------------------------------
local Players              = game:GetService("Players")
local UIS                  = game:GetService("UserInputService")
local TweenService         = game:GetService("TweenService")
local RunService           = game:GetService("RunService")
local HttpService          = game:GetService("HttpService")
local MarketplaceService   = game:GetService("MarketplaceService")
local LocalizationService  = game:GetService("LocalizationService")
local CoreGui              = game:GetService("CoreGui")

local LocalPlayer          = Players.LocalPlayer
local PlayerGui            = LocalPlayer:WaitForChild("PlayerGui")

local VIM
pcall(function() VIM = game:GetService("VirtualInputManager") end)

---------------------------------------------------------------------
-- THEME (Cleaned + Smoothed v3.5 Style)
---------------------------------------------------------------------
local Theme = {
    BG_Dark        = Color3.fromRGB(12, 12, 16),
    BG_Frame       = Color3.fromRGB(20, 20, 26),
    BG_Card        = Color3.fromRGB(26, 26, 32),
    Text_White     = Color3.fromRGB(255, 255, 255),
    Text_Gray      = Color3.fromRGB(185, 185, 190),
    Accent_On      = Color3.fromRGB(255, 92, 92),
    Accent_Off     = Color3.fromRGB(70, 70, 80),
    Slider_Fill    = Color3.fromRGB(255, 92, 92),
    Slider_BG      = Color3.fromRGB(45, 45, 55),
}

---------------------------------------------------------------------
-- ROOT GUI (Smooth + Clean)
---------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArgonBinHubX"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Enabled = true
ScreenGui.Parent = PlayerGui

-- Main center frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 900, 0, 520)
MainFrame.Position = UDim2.new(0.5, -450, 0.5, -260)
MainFrame.BackgroundColor3 = Theme.BG_Dark
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MFCorner = Instance.new("UICorner")
MFCorner.CornerRadius = UDim.new(0,18)
MFCorner.Parent = MainFrame

-- Main drop-shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1,60,1,60)
Shadow.Position = UDim2.new(0,-30,0,-30)
Shadow.ZIndex = -1
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0,0,0)
Shadow.ImageTransparency = 0.45
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49,49,450,450)
Shadow.Parent = MainFrame

---------------------------------------------------------------------
-- SIDEBAR FRAME
---------------------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,260,1,0)
Sidebar.BackgroundColor3 = Theme.BG_Frame
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SBCorner = Instance.new("UICorner")
SBCorner.CornerRadius = UDim.new(0,18)
SBCorner.Parent = Sidebar

---------------------------------------------------------------------
-- CONTENT FRAME (Pages go here)
---------------------------------------------------------------------
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1,-280,1,-20)
ContentFrame.Position = UDim2.new(0,270,0,10)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

---------------------------------------------------------------------
-- PAGE CREATION FUNCTION (ScrollingFrame + Auto Layout)
---------------------------------------------------------------------
local function CreatePage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollBarThickness = 6
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = ContentFrame

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0,12)
    list.FillDirection = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Left
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0,18)
    pad.PaddingTop = UDim.new(0,20)
    pad.Parent = page

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y + 25)
    end)

    return page
end

-- Create the pages
local Page_Home     = CreatePage()
local Page_Main     = CreatePage()
local Page_Blatant  = CreatePage()
local Page_Others   = CreatePage()
local Page_Settings = CreatePage()

---------------------------------------------------------------------
-- AUTO UPDATER (v3.5+)
---------------------------------------------------------------------
local CURRENT_VERSION = "3.5"
local UPDATE_URL = "https://raw.githubusercontent.com/yourgithub/argon-binxix/main/hub.lua"

local function CheckUpdate()
    local req = (syn and syn.request) or request or http_request
    if not req then return false end

    local res = req({ Url = UPDATE_URL, Method = "GET" })
    if not res or not res.Body then return false end

    if res.Body:find('VERSION = "' .. CURRENT_VERSION .. '"') then
        return false -- up to date
    else
        return true -- update available
    end
end

local UpdateAvailable = CheckUpdate()

---------------------------------------------------------------------
-- EXECUTOR + HWID + LOGGING
---------------------------------------------------------------------
local function GetExec()
    local ex, ver = "Unknown", "Unknown"
    pcall(function()
        if identifyexecutor then
            local n,v = identifyexecutor()
            ex = tostring(n)
            ver = tostring(v)
        end
    end)
    return ex, ver
end

local function GetHWID()
    local hw = "Unknown"
    pcall(function()
        if syn and syn.get_hwid then hw = syn.get_hwid() end
    end)
    return hw
end

---------------------------------------------------------------------
-- EXECUTION COUNTER (Saved Locally)
---------------------------------------------------------------------
local execFile = "binhub_exec.txt"
local execCount = 0

pcall(function()
    if isfile and readfile and isfile(execFile) then
        execCount = tonumber(readfile(execFile)) or 0
    end
end)

execCount = execCount + 1

pcall(function()
    if writefile then
        writefile(execFile, tostring(execCount))
    end
end)

---------------------------------------------------------------------
-- WEBHOOK SENDER (Your Original Webhook)
---------------------------------------------------------------------
local WEBHOOK_URL = "https://discord.com/api/webhooks/1446656470287651050/ayflCl7nEQ3388YhXAZT7r3j5kTC40EP3WV9yO1BehR2vzHbtoDArV-YejWn_E_F6eUk"

local function SendWebhook(mode, action)
    local exec, ver = GetExec()
    local hwid = GetHWID()

    local data = {
        embeds = {{
            title = "Argon-Bin Hub v3.5 Executed",
            color = 0xFF5959,
            fields = {
                { name = "Player", value = "`"..LocalPlayer.Name.."`" },
                { name = "HWID", value = "`"..hwid.."`" },
                { name = "Executor", value = exec.." | "..ver },
                { name = "Mode", value = tostring(mode) },
                { name = "Action", value = tostring(action) },
                { name = "Exec Count", value = tostring(execCount) },
            }
        }}
    }

    local req = (syn and syn.request) or request or http_request
    if req then
        pcall(function()
            req({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end)
    end
end

-- Send first log
task.spawn(function()
    SendWebhook("N/A", "N/A")
end)
---------------------------------------------------------------------
-- PART 2 — SIDEBAR BUILD + PAGE SWITCHING
---------------------------------------------------------------------

---------------------------------------------------------------------
-- TEXT LABEL: Hub Title
---------------------------------------------------------------------
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 0, 36)
TitleLabel.Position = UDim2.new(0,10,0,10)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 26
TitleLabel.TextColor3 = Theme.Text_White
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "Argon-Bin Hub"
TitleLabel.Parent = Sidebar

local VersionBadge = Instance.new("TextLabel")
VersionBadge.Size = UDim2.new(0,60,0,22)
VersionBadge.Position = UDim2.new(0,150,0,12)
VersionBadge.BackgroundColor3 = Theme.Accent_On
VersionBadge.Font = Enum.Font.GothamBold
VersionBadge.Text = "v3.5"
VersionBadge.TextColor3 = Color3.fromRGB(255,255,255)
VersionBadge.TextSize = 12
VersionBadge.Parent = Sidebar

local VBcorner = Instance.new("UICorner")
VBcorner.CornerRadius = UDim.new(0,8)
VBcorner.Parent = VersionBadge

---------------------------------------------------------------------
-- SEARCH BOX
---------------------------------------------------------------------
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1,-20,0,32)
SearchBox.Position = UDim2.new(0,10,0,55)
SearchBox.PlaceholderText = "Search"
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 14
SearchBox.TextColor3 = Theme.Text_White
SearchBox.BackgroundColor3 = Theme.BG_Card
SearchBox.BorderSizePixel = 0
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = Sidebar

local SBCorner = Instance.new("UICorner")
SBCorner.CornerRadius = UDim.new(0,8)
SBCorner.Parent = SearchBox

---------------------------------------------------------------------
-- SIDEBAR BUTTON CREATOR
---------------------------------------------------------------------
local SidebarButtons = {}

local function CreateSidebarButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,32)
    btn.BackgroundColor3 = Theme.BG_Card
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextColor3 = Theme.Text_White
    btn.TextSize = 14
    btn.AnchorPoint = Vector2.new(0,0)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = btn

    return btn
end

---------------------------------------------------------------------
-- SIDEBAR LAYOUT
---------------------------------------------------------------------
local SideList = Instance.new("UIListLayout")
SideList.Parent = Sidebar
SideList.Padding = UDim.new(0,8)
SideList.FillDirection = Enum.FillDirection.Vertical
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideList.SortOrder = Enum.SortOrder.LayoutOrder
SideList.VerticalAlignment = Enum.VerticalAlignment.Top

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0,100)
SidePad.PaddingLeft = UDim.new(0,10)
SidePad.PaddingRight = UDim.new(0,10)
SidePad.Parent = Sidebar

---------------------------------------------------------------------
-- CREATE BUTTONS
---------------------------------------------------------------------
local Btn_Home     = CreateSidebarButton("Home")
local Btn_Main     = CreateSidebarButton("Main")
local Btn_Blatant  = CreateSidebarButton("Blatant")
local Btn_Others   = CreateSidebarButton("Others")
local Btn_Settings = CreateSidebarButton("Settings")

Btn_Home.Parent     = Sidebar
Btn_Main.Parent     = Sidebar
Btn_Blatant.Parent  = Sidebar
Btn_Others.Parent   = Sidebar
Btn_Settings.Parent = Sidebar

SidebarButtons = {
    Home     = Btn_Home,
    Main     = Btn_Main,
    Blatant  = Btn_Blatant,
    Others   = Btn_Others,
    Settings = Btn_Settings,
}

---------------------------------------------------------------------
-- PAGE TABLE
---------------------------------------------------------------------
local Pages = {
    Home     = Page_Home,
    Main     = Page_Main,
    Blatant  = Page_Blatant,
    Others   = Page_Others,
    Settings = Page_Settings,
}

---------------------------------------------------------------------
-- HIGHLIGHT ANIMATION
---------------------------------------------------------------------
local function AnimateButton(btn, active)
    if active then
        TweenService:Create(btn, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Theme.Accent_On,
            TextColor3 = Color3.fromRGB(255,255,255)
        }):Play()
    else
        TweenService:Create(btn, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Theme.BG_Card,
            TextColor3 = Theme.Text_White
        }):Play()
    end
end

---------------------------------------------------------------------
-- PAGE SWITCH FUNCTION
---------------------------------------------------------------------
local function ShowPage(name)
    -- hide all pages:
    for _, page in pairs(Pages) do
        page.Visible = false
    end
    
    -- show selected:
    Pages[name].Visible = true
    
    -- update buttons:
    for n,btn in pairs(SidebarButtons) do
        AnimateButton(btn, n == name)
    end
end

---------------------------------------------------------------------
-- BUTTON CONNECTIONS
---------------------------------------------------------------------
Btn_Home.MouseButton1Click:Connect(function() ShowPage("Home") end)
Btn_Main.MouseButton1Click:Connect(function() ShowPage("Main") end)
Btn_Blatant.MouseButton1Click:Connect(function() ShowPage("Blatant") end)
Btn_Others.MouseButton1Click:Connect(function() ShowPage("Others") end)
Btn_Settings.MouseButton1Click:Connect(function() ShowPage("Settings") end)

---------------------------------------------------------------------
-- START ON HOME PAGE
---------------------------------------------------------------------
ShowPage("Home")
---------------------------------------------------------------------
-- PART 3 — HOME PAGE + CARD CREATION FUNCTIONS
---------------------------------------------------------------------

---------------------------------------------------------------------
-- HOME PAGE CONTENT (Matches your screenshot exactly)
---------------------------------------------------------------------

local HomeTitle = Instance.new("TextLabel")
HomeTitle.Size = UDim2.new(1, -20, 0, 36)
HomeTitle.BackgroundTransparency = 1
HomeTitle.Font = Enum.Font.GothamBlack
HomeTitle.TextSize = 28
HomeTitle.TextColor3 = Theme.Text_White
HomeTitle.TextXAlignment = Enum.TextXAlignment.Left
HomeTitle.Text = "Welcome, " .. LocalPlayer.DisplayName
HomeTitle.Parent = Page_Home

local HomeSub = Instance.new("TextLabel")
HomeSub.Size = UDim2.new(1, -20, 0, 22)
HomeSub.BackgroundTransparency = 1
HomeSub.Font = Enum.Font.Gotham
HomeSub.TextSize = 15
HomeSub.TextColor3 = Theme.Text_Gray
HomeSub.TextXAlignment = Enum.TextXAlignment.Left
HomeSub.Text = "Argon-Bin Hub X | Custom build by Binxix — v3.5"
HomeSub.Parent = Page_Home

---------------------------------------------------------------------
-- CARD CREATOR (Used for every toggle/slider card)
---------------------------------------------------------------------
local function CreateCard(height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -30, 0, height)
    card.BackgroundColor3 = Theme.BG_Card
    card.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = card

    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.ZIndex = -1
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49,49,450,450)
    shadow.Parent = card

    return card
end

---------------------------------------------------------------------
-- LABEL INSIDE CARDS
---------------------------------------------------------------------
local function CreateCardLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 22)
    lbl.Position = UDim2.new(0,10,0,10)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 17
    lbl.TextColor3 = Theme.Text_White
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = parent
    return lbl
end

---------------------------------------------------------------------
-- CLEAN TOGGLE (OFF → ON) BUTTON
---------------------------------------------------------------------
local function CreateToggle(parent, defaultState, callback)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 56, 0, 26)
    toggle.Position = UDim2.new(1, -66, 0, 10)
    toggle.BackgroundColor3 = defaultState and Theme.Accent_On or Theme.Accent_Off
    toggle.Text = defaultState and "ON" or "OFF"
    toggle.TextColor3 = Theme.Text_White
    toggle.TextSize = 13
    toggle.Font = Enum.Font.GothamBold
    toggle.BorderSizePixel = 0
    toggle.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = toggle

    local state = defaultState

    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"

        TweenService:Create(toggle, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            BackgroundColor3 = state and Theme.Accent_On or Theme.Accent_Off
        }):Play()

        if callback then
            callback(state)
        end
    end)

    return toggle, function() return state end
end

---------------------------------------------------------------------
-- BASE SLIDER FUNCTION (Speed/Jump will use this in Part 4)
---------------------------------------------------------------------
local function CreateSlider(parent, min, max, defaultValue, callback)
    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, -30, 0, 8)
    SliderBG.Position = UDim2.new(0,10,0,40)
    SliderBG.BackgroundColor3 = Theme.Slider_BG
    SliderBG.BorderSizePixel = 0
    SliderBG.Parent = parent

    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0,5)
    SCorner.Parent = SliderBG

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(defaultValue / max, 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Slider_Fill
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBG

    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0,5)
    FCorner.Parent = Fill

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0, 60, 0, 18)
    ValLabel.Position = UDim2.new(1, -70, 0, 6)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Font = Enum.Font.GothamMedium
    ValLabel.TextSize = 13
    ValLabel.TextColor3 = Theme.Text_Gray
    ValLabel.Text = tostring(defaultValue)
    ValLabel.Parent = parent

    -- Slider drag behavior
    SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local moving = true
            
            local moveConn
            moveConn = UIS.InputChanged:Connect(function(changed)
                if changed.UserInputType == Enum.UserInputType.MouseMovement and moving then
                    local percent = math.clamp((changed.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * percent)

                    Fill.Size = UDim2.new(percent, 0, 1, 0)
                    ValLabel.Text = tostring(value)

                    if callback then
                        callback(value)
                    end
                end
            end)

            UIS.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    if moveConn then moveConn:Disconnect() end
                    moving = false
                end
            end)
        end
    end)
end

-- These functions will be used in Part 4 & 5
_G.CreateCard      = CreateCard
_G.CreateCardLabel = CreateCardLabel
_G.CreateToggle    = CreateToggle
_G.CreateSlider    = CreateSlider
---------------------------------------------------------------------
-- PART 4 — MAIN PAGE
---------------------------------------------------------------------

---------------------------------------------------------------------
-- DEFAULT VARIABLES
---------------------------------------------------------------------

local ModeType        = "Toggle"   -- Toggle or Hold
local ActionType      = "Click"    -- Click or Parry
local RapidFireOn     = false
local AutoJumpOn      = false
local AutoFireOn      = false

local SpeedEnabled    = false
local SpeedValue      = 16         -- Default WalkSpeed
local JumpEnabled     = false
local JumpValue       = 50         -- Default JumpPower

local Humanoid = nil
local function GetHumanoid()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChildWhichIsA("Humanoid")
    end
    return nil
end
Humanoid = GetHumanoid()

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.4)
    Humanoid = char:WaitForChild("Humanoid")

    if SpeedEnabled then Humanoid.WalkSpeed = SpeedValue end
    if JumpEnabled then Humanoid.JumpPower = JumpValue end
end)

---------------------------------------------------------------------
-- MAIN TITLE
---------------------------------------------------------------------
local mainTitle = Instance.new("TextLabel")
mainTitle.Size = UDim2.new(1, -20, 0, 32)
mainTitle.BackgroundTransparency = 1
mainTitle.Font = Enum.Font.GothamBlack
mainTitle.TextSize = 26
mainTitle.TextColor3 = Theme.Text_White
mainTitle.TextXAlignment = Enum.TextXAlignment.Left
mainTitle.Text = "Main Hub"
mainTitle.Parent = Page_Main

---------------------------------------------------------------------
-- MODE TYPE (Hold / Toggle)
---------------------------------------------------------------------
local cardMode = _G.CreateCard(68)
cardMode.Parent = Page_Main

_G.CreateCardLabel(cardMode, "Mode Type (Hold / Toggle)")

_G.CreateToggle(cardMode, false, function(state)
    ModeType = state and "Hold" or "Toggle"
end)

---------------------------------------------------------------------
-- ACTION TYPE (Click / Parry)
---------------------------------------------------------------------
local cardAction = _G.CreateCard(68)
cardAction.Parent = Page_Main

_G.CreateCardLabel(cardAction, "Action Type")

_G.CreateToggle(cardAction, false, function(state)
    ActionType = state and "Parry" or "Click"
end)

---------------------------------------------------------------------
-- RAPID FIRE (Hold-Only)
---------------------------------------------------------------------
local cardRapid = _G.CreateCard(68)
cardRapid.Parent = Page_Main

_G.CreateCardLabel(cardRapid, "Rapid Fire (Hold Only)")

_G.CreateToggle(cardRapid, false, function(state)
    RapidFireOn = state
end)

---------------------------------------------------------------------
-- AUTO JUMP
---------------------------------------------------------------------
local cardAutoJump = _G.CreateCard(68)
cardAutoJump.Parent = Page_Main

_G.CreateCardLabel(cardAutoJump, "Auto Jump")

_G.CreateToggle(cardAutoJump, false, function(state)
    AutoJumpOn = state
end)

---------------------------------------------------------------------
-- AUTO FIRE
---------------------------------------------------------------------
local cardAutoFire = _G.CreateCard(68)
cardAutoFire.Parent = Page_Main

_G.CreateCardLabel(cardAutoFire, "Auto Fire")

_G.CreateToggle(cardAutoFire, false, function(state)
    AutoFireOn = state
end)

---------------------------------------------------------------------
-- SPEED SLIDER (Slider + Toggle)
---------------------------------------------------------------------
local cardSpeed = _G.CreateCard(90)
cardSpeed.Parent = Page_Main

_G.CreateCardLabel(cardSpeed, "Speed Boost")

-- Toggle
_G.CreateToggle(cardSpeed, false, function(state)
    SpeedEnabled = state
    Humanoid = GetHumanoid()
    if Humanoid then
        if state then Humanoid.WalkSpeed = SpeedValue
        else Humanoid.WalkSpeed = 16 end
    end
end)

-- Slider
_G.CreateSlider(cardSpeed, 16, 80, 16, function(value)
    SpeedValue = value
    if SpeedEnabled and Humanoid then
        Humanoid.WalkSpeed = SpeedValue
    end
end)

---------------------------------------------------------------------
-- JUMP SLIDER (Slider + Toggle)
---------------------------------------------------------------------
local cardJump = _G.CreateCard(90)
cardJump.Parent = Page_Main

_G.CreateCardLabel(cardJump, "Jump Boost")

_G.CreateToggle(cardJump, false, function(state)
    JumpEnabled = state
    Humanoid = GetHumanoid()
    if Humanoid then
        if state then Humanoid.JumpPower = JumpValue
        else Humanoid.JumpPower = 50 end
    end
end)

_G.CreateSlider(cardJump, 50, 120, 50, function(value)
    JumpValue = value
    if JumpEnabled and Humanoid then
        Humanoid.JumpPower = JumpValue
    end
end)

---------------------------------------------------------------------
-- MAIN PAGE FINISHED
---------------------------------------------------------------------
---------------------------------------------------------------------
-- PART 5 — BLATANT PAGE
---------------------------------------------------------------------

---------------------------------------------------------------------
-- DEFAULT VARIABLES
---------------------------------------------------------------------
local FPSBoostOn    = false
local AntiLagOn     = false
local ShadowsOn     = false
local UltraBoostOn  = false

---------------------------------------------------------------------
-- BLATANT PAGE TITLE
---------------------------------------------------------------------
local blTitle = Instance.new("TextLabel")
blTitle.Size = UDim2.new(1, -20, 0, 32)
blTitle.BackgroundTransparency = 1
blTitle.Font = Enum.Font.GothamBlack
blTitle.TextSize = 26
blTitle.TextColor3 = Theme.Text_White
blTitle.TextXAlignment = Enum.TextXAlignment.Left
blTitle.Text = "Blatant"
blTitle.Parent = Page_Blatant

---------------------------------------------------------------------
-- FPS BOOST (Lighting)
---------------------------------------------------------------------
local cardFPS = _G.CreateCard(68)
cardFPS.Parent = Page_Blatant

_G.CreateCardLabel(cardFPS, "FPS Boost")

_G.CreateToggle(cardFPS, false, function(state)
    FPSBoostOn = state
    if state then
        -- turn off expensive effects
        for _,v in pairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or 
               v:IsA("SunRaysEffect") or 
               v:IsA("ColorCorrectionEffect") or 
               v:IsA("DepthOfFieldEffect") or
               v:IsA("Atmosphere") then
                v.Enabled = false
            end
        end
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = ShadowsOn -- respect shadow toggle
    else
        -- restore default-ish
        Lighting.FogEnd = 1000
        Lighting.GlobalShadows = true
        for _,v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") then v.Enabled = true end
        end
    end
end)

---------------------------------------------------------------------
-- ANTI-LAG (Remove decals/particles)
---------------------------------------------------------------------
local cardLag = _G.CreateCard(68)
cardLag.Parent = Page_Blatant

_G.CreateCardLabel(cardLag, "Anti-Lag (Remove Particles/Trails)")

_G.CreateToggle(cardLag, false, function(state)
    AntiLagOn = state
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = not state
        end
        if obj:IsA("Decal") then
            obj.Transparency = state and 1 or 0
        end
    end
end)

---------------------------------------------------------------------
-- SHADOWS TOGGLE
---------------------------------------------------------------------
local cardShadow = _G.CreateCard(68)
cardShadow.Parent = Page_Blatant

_G.CreateCardLabel(cardShadow, "Shadows")

_G.CreateToggle(cardShadow, false, function(state)
    ShadowsOn = state
    Lighting.GlobalShadows = state
end)

---------------------------------------------------------------------
-- ULTRA PERFORMANCE MODE (Combines all boosting)
---------------------------------------------------------------------
local cardUltra = _G.CreateCard(72)
cardUltra.Parent = Page_Blatant

_G.CreateCardLabel(cardUltra, "Ultra Performance Mode")

_G.CreateToggle(cardUltra, false, function(state)
    UltraBoostOn = state

    if state then
        -- FPS Boost
        for _,v in pairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or 
               v:IsA("SunRaysEffect") or
               v:IsA("Atmosphere") or
               v:IsA("DepthOfFieldEffect") then
                v.Enabled = false
            end
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e6

        -- Anti-Lag
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then obj.Enabled = false end
            if obj:IsA("Decal") then obj.Transparency = 1 end
        end

    else
        -- Restore default
        Lighting.FogEnd = 1000
        Lighting.GlobalShadows = true

        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then obj.Enabled = true end
            if obj:IsA("Decal") then obj.Transparency = 0 end
        end
    end
end)

---------------------------------------------------------------------
-- BLATANT PAGE FINISHED
---------------------------------------------------------------------
---------------------------------------------------------------------
-- PART 6 — FINAL ENGINE (Auto Click, Auto Parry, Rapid Fire, Modes)
---------------------------------------------------------------------

---------------------------------------------------------------------
-- INPUT KEYS
---------------------------------------------------------------------
local ToggleKey = Enum.KeyCode.E         -- Main key
local ParryKey  = Enum.KeyCode.E         -- Parry key (locked)
local ManualKey = Enum.KeyCode.Q         -- Manual spam key (locked)

---------------------------------------------------------------------
-- STATE VARIABLES
---------------------------------------------------------------------
local Clicking      = false
local ManualSpam    = false
local LastInput     = tick()

---------------------------------------------------------------------
-- SAFE INPUT HANDLER
---------------------------------------------------------------------
local function SafeKeyPress(key)
    if not VIM then return end
    pcall(function()
        VIM:SendKeyEvent(true, key, false, game)
        task.wait(0.02)
        VIM:SendKeyEvent(false, key, false, game)
    end)
end

---------------------------------------------------------------------
-- MOUSE CLICK
---------------------------------------------------------------------
local function SafeMouse1Click()
    pcall(function()
        mouse1click()
    end)
end

---------------------------------------------------------------------
-- CLICK/PARRY ACTION
---------------------------------------------------------------------
local function DoAction()
    if ActionType == "Click" then
        SafeMouse1Click()
    else
        SafeKeyPress(ParryKey)
    end
end

---------------------------------------------------------------------
-- MODE HANDLING (HOLD vs TOGGLE)
---------------------------------------------------------------------
local function ToggleClicking()
    if ModeType == "Toggle" then
        Clicking = not Clicking
    else
        Clicking = true
    end
end

local function ReleaseClicking()
    if ModeType == "Hold" then
        Clicking = false
    end
end

---------------------------------------------------------------------
-- USER INPUT
---------------------------------------------------------------------
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    -- Main clicking key
    if input.KeyCode == ToggleKey then
        ToggleClicking()
    end

    -- Manual Q spam key
    if input.KeyCode == ManualKey then
        ManualSpam = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == ToggleKey then
        ReleaseClicking()
    end
    if input.KeyCode == ManualKey then
        ManualSpam = false
    end
end)

---------------------------------------------------------------------
-- AUTO JUMP ENGINE
---------------------------------------------------------------------
task.spawn(function()
    while true do
        if AutoJumpOn and Humanoid then
            Humanoid.Jump = true
        end
        task.wait(0.18)
    end
end)

---------------------------------------------------------------------
-- AUTO FIRE ENGINE
---------------------------------------------------------------------
task.spawn(function()
    while true do
        if AutoFireOn then
            SafeMouse1Click()
        end
        task.wait(0.12)
    end
end)

---------------------------------------------------------------------
-- RAPID FIRE ENGINE (HOLD ONLY)
---------------------------------------------------------------------
task.spawn(function()
    while true do
        if RapidFireOn and UIS:IsKeyDown(Enum.KeyCode.ButtonR2) then
            SafeMouse1Click()
        end
        task.wait(0.05)
    end
end)

---------------------------------------------------------------------
-- MAIN AUTO-CLICK/PARRY LOOP
---------------------------------------------------------------------
task.spawn(function()
    while task.wait() do
        -- Main clicker/parry
        if Clicking then
            DoAction()
        end

        -- Manual spam
        if ManualSpam then
            SafeKeyPress(ManualKey)
        end
    end
end)

---------------------------------------------------------------------
-- SEND ACTION TO WEBHOOK
---------------------------------------------------------------------
local function LogAction()
    local mode = ModeType
    local act  = ActionType
    SendWebhook(mode, act)
end

-- Log the final action selection once user interacts
task.delay(1.5, LogAction)

---------------------------------------------------------------------
-- GUI TOGGLE (RightCtrl)
---------------------------------------------------------------------
local guiVisible = true
UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.RightControl then
        guiVisible = not guiVisible
        ScreenGui.Enabled = guiVisible
    end
end)

---------------------------------------------------------------------
-- FINAL CONFIRMATION
---------------------------------------------------------------------
print("[Argon-Bin Hub X] v3.5 Loaded Successfully.")
