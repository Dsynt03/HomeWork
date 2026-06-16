local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Lighting = game:GetService("Lighting")

-- ==================== STATE VARIABLES (Declared Early) ====================
local WS_Enabled = false
local WS_Value = 16
local WS_Conn = nil

local JumpPowerEnabled = false
local JumpMultiplier = 1
local JumpConnection = nil

local InfJumpEnabled = false
local lastJumpTime = 0

local AirGravityEnabled = false
local AirGravityMultiplier = 0.3
local AirGravityConnection = nil
local OriginalGravity = workspace.Gravity

local NoClipEnabled = false
local NoClipConn = nil

local FlyEnabled = false
local FlyMultiplier = 1
local FlyConn = nil

local CTEnabled = false

local FreeCamEnabled = false
local FreeCamConnection = nil
local OriginalWalkSpeed = 16

local CustomCameraEnabled = false
local CustomCameraConnection = nil

local ESPEnabled = false
local Highlights = {}
local NameTags = {}
local ESPUpdateConnection = nil

local FBEnabled = false
local FBOriginal = {}
local FB_Brightness = 2.0

local XRayEnabled = false
local XRayDistance = 150
local XRayConnection = nil
local OriginalTransparency = {}
local CurrentAffected = {}

local AFKEnabled = false
local AFKConn = nil

local PickupEnabled = false
local PickupConnection = nil

local AutoClickerEnabled = false
local ClickerHotkey = Enum.KeyCode.KeypadMultiply
local ClickerLoop = nil
local ClickerHotkeyConnection = nil

-- ==================== RESET FUNCTION (Stays at the bottom as you want) ====================
-- (Your full ResetAllFeatures function stays exactly where it was at the bottom)

-- The rest of your script continues normally from here...
-- (GUI creation, tabs, Movement, Camera, Visual with Name ESP, Utility, Auto Clicker, etc.)

-- ==================== AUTO REQUEUE (Always Reappears) ====================
if queue_on_teleport then
    queue_on_teleport([[
        task.wait(15)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Dsynt03/HomeWork/refs/heads/main/PlayerTools.lua"))()
    ]])
end

-- ==================== DESTROY OLD GUI (Critical for queue_on_teleport) ====================
if CoreGui:FindFirstChild("PlayerToolsGUI") then
    CoreGui.PlayerToolsGUI:Destroy()
    task.wait(0.2)
end

-- ==================== SCREEN GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlayerToolsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ==================== AUTO CLICKER INDICATOR ====================
local ACIndicator = Instance.new("TextLabel")
ACIndicator.Name = "ACIndicator"
ACIndicator.Size = UDim2.new(0, 72, 0, 26)
ACIndicator.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
ACIndicator.Text = "AC: ON"
ACIndicator.TextColor3 = Color3.new(1, 1, 1)
ACIndicator.TextScaled = true
ACIndicator.Font = Enum.Font.GothamBold
ACIndicator.Visible = false
ACIndicator.Parent = ScreenGui

local ACIndicatorCorner = Instance.new("UICorner")
ACIndicatorCorner.CornerRadius = UDim.new(0, 6)
ACIndicatorCorner.Parent = ACIndicator

RunService.RenderStepped:Connect(function()
    if ACIndicator and ACIndicator.Visible then
        local mousePos = UserInputService:GetMouseLocation()
        ACIndicator.Position = UDim2.new(0, mousePos.X - 30, 0, mousePos.Y + -35)
    end
end)

-- ==================== MAIN FRAME ====================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 480)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 40)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- ==================== GUI RESIZER ====================
local ResizeHandles = {}
local MIN_SIZE = Vector2.new(200, 340)

local function CreateResizeHandle(corner)
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.BackgroundTransparency = 1
    handle.BorderSizePixel = 0
    handle.ZIndex = 50
    handle.Parent = MainFrame

    if corner == "TopLeft" then
        handle.Position = UDim2.new(0, -5, 0, -5)
        handle.AnchorPoint = Vector2.new(0, 0)
    elseif corner == "TopRight" then
        handle.Position = UDim2.new(1, 5, 0, -5)
        handle.AnchorPoint = Vector2.new(1, 0)
    elseif corner == "BottomLeft" then
        handle.Position = UDim2.new(0, -5, 1, 5)
        handle.AnchorPoint = Vector2.new(0, 1)
    elseif corner == "BottomRight" then
        handle.Position = UDim2.new(1, 5, 1, 5)
        handle.AnchorPoint = Vector2.new(1, 1)
    end
    return handle
end

ResizeHandles.TopLeft = CreateResizeHandle("TopLeft")
ResizeHandles.TopRight = CreateResizeHandle("TopRight")
ResizeHandles.BottomLeft = CreateResizeHandle("BottomLeft")
ResizeHandles.BottomRight = CreateResizeHandle("BottomRight")

local resizing = false
local resizeCorner = nil
local startMousePos, startSize, startPosition

for corner, handle in pairs(ResizeHandles) do
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeCorner = corner
            startMousePos = UserInputService:GetMouseLocation()
            startSize = MainFrame.AbsoluteSize
            startPosition = MainFrame.Position
        end
    end)
end

UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local delta = mousePos - startMousePos

        local newSize = startSize
        local newPos = startPosition

        if resizeCorner == "BottomRight" then
            newSize = Vector2.new(math.max(MIN_SIZE.X, startSize.X + delta.X), math.max(MIN_SIZE.Y, startSize.Y + delta.Y))
        elseif resizeCorner == "BottomLeft" then
            newSize = Vector2.new(math.max(MIN_SIZE.X, startSize.X - delta.X), math.max(MIN_SIZE.Y, startSize.Y + delta.Y))
            newPos = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset)
        elseif resizeCorner == "TopRight" then
            newSize = Vector2.new(math.max(MIN_SIZE.X, startSize.X + delta.X), math.max(MIN_SIZE.Y, startSize.Y - delta.Y))
            newPos = UDim2.new(startPosition.X.Scale, startPosition.X.Offset, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        elseif resizeCorner == "TopLeft" then
            newSize = Vector2.new(math.max(MIN_SIZE.X, startSize.X - delta.X), math.max(MIN_SIZE.Y, startSize.Y - delta.Y))
            newPos = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end

        MainFrame.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
        MainFrame.Position = newPos
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
        resizeCorner = nil
    end
end)

-- ==================== TITLE BAR ====================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 34)
TitleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Player Tools"
TitleLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Chrome Buttons
local function CreateChromeButton(text, color, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 20, 0, 20)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TitleBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    return btn
end

local CloseBtn = CreateChromeButton("×", Color3.fromRGB(230, 65, 65), UDim2.new(1, -26, 0, 7))
local FullBtn  = CreateChromeButton("□", Color3.fromRGB(85, 210, 85), UDim2.new(1, -50, 0, 7))
local MinBtn   = CreateChromeButton("—", Color3.fromRGB(210, 190, 70), UDim2.new(1, -74, 0, 7))

CloseBtn.MouseButton1Click:Connect(function()
    CloseBtn.Active = false
    TitleLabel.Text = "Resetting..."
    ResetAllFeatures()
    task.wait(0.4)
    ScreenGui:Destroy()
end)

FullBtn.MouseButton1Click:Connect(function()
    if MainFrame.Size == UDim2.new(1,0,1,0) then
        MainFrame.Size = UDim2.new(0,250,0,480)
        MainFrame.Position = UDim2.new(0,20,0,20)
    else
        MainFrame.Size = UDim2.new(1,0,1,0)
        MainFrame.Position = UDim2.new(0,0,0,0)
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightAlt then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Draggable
local dragging = false
local dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ==================== TAB BAR ====================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 32)
TabBar.Position = UDim2.new(0, 0, 0, 34)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
TabBar.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 2)
TabLayout.Parent = TabBar

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, -2, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 205)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local MovementTab = CreateTab("Movement")
local CameraTab   = CreateTab("Camera")
local VisualTab   = CreateTab("Visual")
local UtilityTab  = CreateTab("Utility")

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -12, 1, -72)
ContentContainer.Position = UDim2.new(0, 6, 0, 68)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local function CreateContentFrame()
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 4
    frame.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 75)
    frame.Visible = false
    frame.Parent = ContentContainer

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.Parent = frame
    return frame
end

local MovementContent = CreateContentFrame()
local CameraContent   = CreateContentFrame()
local VisualContent   = CreateContentFrame()
local UtilityContent  = CreateContentFrame()

local CurrentTab = nil
local function ShowTab(contentFrame)
    if CurrentTab then CurrentTab.Visible = false end
    contentFrame.Visible = true
    CurrentTab = contentFrame
end

MovementTab.MouseButton1Click:Connect(function() ShowTab(MovementContent) end)
CameraTab.MouseButton1Click:Connect(function() ShowTab(CameraContent) end)
VisualTab.MouseButton1Click:Connect(function() ShowTab(VisualContent) end)
UtilityTab.MouseButton1Click:Connect(function() ShowTab(UtilityContent) end)

MovementContent.Visible = true
CurrentTab = MovementContent

-- ==================== PREMIUM HELPERS ====================

local function CreateToggle(parent, defaultText)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
    btn.Text = defaultText
    btn.TextColor3 = Color3.fromRGB(235, 235, 240)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local function CreateSlider(parent)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -8, 0, 26)
    frame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

    local knob = Instance.new("Frame", frame)
    knob.Size = UDim2.new(0, 14, 1, -4)
    knob.Position = UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 4)

    local valueLabel = Instance.new("TextLabel", frame)
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    valueLabel.TextScaled = true
    valueLabel.Font = Enum.Font.GothamBold

    return frame, knob, valueLabel
end

-- ==================== MOVEMENT TAB ====================

-- WalkSpeed
local WalkButton = CreateToggle(MovementContent, "WalkSpeed: OFF")
local WalkSliderFrame, WalkKnob, WalkVal = CreateSlider(MovementContent)

WS_Enabled = false
WS_Value = 16
WS_Conn = nil

local function ApplyWalkSpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if WS_Enabled then
        local cam = workspace.CurrentCamera
        local moveDirection = Vector3.new(0,0,0)

        local forward = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit
        local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z).Unit

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= right end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += right end

        if moveDirection.Magnitude > 0 then
            local currentVel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(
                moveDirection.Unit.X * WS_Value,
                currentVel.Y,
                moveDirection.Unit.Z * WS_Value
            )
        end
    end
end

WalkButton.MouseButton1Click:Connect(function()
    WS_Enabled = not WS_Enabled
    if WS_Enabled then
        WalkButton.Text = "WalkSpeed: ON"
        WalkButton.BackgroundColor3 = Color3.fromRGB(0,170,80)
        if not WS_Conn then
            WS_Conn = RunService.RenderStepped:Connect(ApplyWalkSpeed)
        end
    else
        WalkButton.Text = "WalkSpeed: OFF"
        WalkButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
        if WS_Conn then WS_Conn:Disconnect() WS_Conn = nil end

        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
end)

-- WalkSpeed Slider
local dragWS = false
WalkKnob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragWS = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragWS = false end end)

RunService.RenderStepped:Connect(function()
    if dragWS then
        local mx = UserInputService:GetMouseLocation().X
        local sx = WalkSliderFrame.AbsolutePosition.X
        local sw = WalkSliderFrame.AbsoluteSize.X

        local knobWidth = 14
        local padding = 4

        local percent = math.clamp((mx - sx - 2) / (sw - knobWidth - padding), 0, 1)

        WalkKnob.Position = UDim2.new(0, 2 + percent * (sw - knobWidth - padding), 0, 2)

        WS_Value = math.floor(1 + percent * 1999)
        WalkVal.Text = tostring(WS_Value)
    end
end)

-- Set initial position
WalkKnob.Position = UDim2.new(0, 2, 0, 2)
WalkVal.Text = "16"

-- Jump Power
local JumpPowerButton = CreateToggle(MovementContent, "Jump Power: OFF")
local JumpSliderFrame, JumpKnob, JumpValueLabel = CreateSlider(MovementContent)

JumpPowerEnabled = false
JumpMultiplier = 1
JumpConnection = nil

local function ApplyJump()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    local power = 50 * JumpMultiplier
    hum.JumpPower = power
    hum.JumpHeight = 7 + (power / 10000) * 300
end

LocalPlayer.CharacterAdded:Connect(function()
    if JumpPowerEnabled then task.wait(0.5) ApplyJump() end
end)

JumpPowerButton.MouseButton1Click:Connect(function()
    JumpPowerEnabled = not JumpPowerEnabled
    if JumpPowerEnabled then
        JumpPowerButton.Text = "Jump Power: ON"
        JumpPowerButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        if not JumpConnection then
            JumpConnection = RunService.RenderStepped:Connect(ApplyJump)
        end
        ApplyJump()
    else
        JumpPowerButton.Text = "Jump Power: OFF"
        JumpPowerButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
        if JumpConnection then JumpConnection:Disconnect() JumpConnection = nil end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.JumpPower, hum.JumpHeight = 50, 7.2 end
        end
    end
end)

-- Jump Slider
local draggingJump = false
JumpKnob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingJump = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingJump = false end end)

RunService.RenderStepped:Connect(function()
    if draggingJump then
        local mouseX = UserInputService:GetMouseLocation().X
        local sx = JumpSliderFrame.AbsolutePosition.X
        local sw = JumpSliderFrame.AbsoluteSize.X

        local knobWidth = 14
        local padding = 4

        local rawPercent = math.clamp((mouseX - sx - 2) / (sw - knobWidth - padding), 0, 1)

        local steps = 20000
        JumpMultiplier = math.floor(1 + rawPercent * (steps - 1) + 0.5)
        JumpMultiplier = math.clamp(JumpMultiplier, 1, 20000)

        JumpKnob.Position = UDim2.new(0, 2 + rawPercent * (sw - knobWidth - padding), 0, 2)
        JumpValueLabel.Text = JumpMultiplier .. "x"

        if JumpPowerEnabled then ApplyJump() end
    end
end)

JumpKnob.Position = UDim2.new(0, 2, 0, 2)
JumpValueLabel.Text = "1x"

-- Infinite Jump
local InfJumpButton = CreateToggle(MovementContent, "Infinite Jump: OFF")
local InfJumpEnabled = false
local lastJumpTime = 0
local jumpDelay = 0.18

UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and LocalPlayer.Character then
        local currentTime = tick()
        if currentTime - lastJumpTime >= jumpDelay then
            lastJumpTime = currentTime
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then
                if JumpPowerEnabled then
                    local power = 500 * JumpMultiplier
                    hum.JumpPower = power
                    hum.JumpHeight = 7 + (power / 10000) * 300
                end
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

InfJumpButton.MouseButton1Click:Connect(function()
    InfJumpEnabled = not InfJumpEnabled
    if InfJumpEnabled then
        InfJumpButton.Text = "Infinite Jump: ON"
        InfJumpButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
    else
        InfJumpButton.Text = "Infinite Jump: OFF"
        InfJumpButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
    end
end)

-- Air Gravity
local AirGravityButton = CreateToggle(MovementContent, "Air Gravity: OFF")
local AirGravitySliderFrame, AirGravityKnob, AirGravityVal = CreateSlider(MovementContent)

AirGravityEnabled = false
AirGravityMultiplier = 0.3
OriginalGravity = workspace.Gravity
AirGravityConnection = nil

local function ApplyAirGravity()
    if not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not hum then return end

    local state = hum:GetState()
    local isInAir = state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall

    workspace.Gravity = isInAir and (196.2 * AirGravityMultiplier) or OriginalGravity
end

AirGravityButton.MouseButton1Click:Connect(function()
    AirGravityEnabled = not AirGravityEnabled
    if AirGravityEnabled then
        AirGravityButton.Text = "Air Gravity: ON"
        AirGravityButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        if not AirGravityConnection then
            AirGravityConnection = RunService.RenderStepped:Connect(function()
                if AirGravityEnabled then ApplyAirGravity() end
            end)
        end
    else
        AirGravityButton.Text = "Air Gravity: OFF"
        AirGravityButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
        if AirGravityConnection then AirGravityConnection:Disconnect() AirGravityConnection = nil end
        workspace.Gravity = OriginalGravity
    end
end)

-- Air Gravity Slider
local draggingAirGravity = false
AirGravityKnob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingAirGravity = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingAirGravity = false end end)

RunService.RenderStepped:Connect(function()
    if draggingAirGravity then
        local mouseX = UserInputService:GetMouseLocation().X
        local sx = AirGravitySliderFrame.AbsolutePosition.X
        local sw = AirGravitySliderFrame.AbsoluteSize.X

        local knobWidth = 14
        local padding = 4

        local rawPercent = math.clamp((mouseX - sx - 2) / (sw - knobWidth - padding), 0, 1)

        AirGravityMultiplier = 0.05 + (rawPercent * 0.95)
        AirGravityMultiplier = math.clamp(AirGravityMultiplier, 0.05, 1)

        AirGravityKnob.Position = UDim2.new(0, 2 + rawPercent * (sw - knobWidth - padding), 0, 2)
        AirGravityVal.Text = string.format("%.2fx", AirGravityMultiplier)
    end
end)

AirGravityKnob.Position = UDim2.new(0.26, 0, 0, 2)
AirGravityVal.Text = "0.30x"

-- No Clip
local NoClipButton = CreateToggle(MovementContent, "No Clip: OFF")
NoClipEnabled = false
NoClipConn = nil

local function EnableNoClip()
    if NoClipConn then return end
    NoClipConn = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

local function DisableNoClip()
    if NoClipConn then NoClipConn:Disconnect() NoClipConn = nil end
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

NoClipButton.MouseButton1Click:Connect(function()
    NoClipEnabled = not NoClipEnabled
    if NoClipEnabled then
        NoClipButton.Text = "No Clip: ON"
        NoClipButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        EnableNoClip()
    else
        NoClipButton.Text = "No Clip: OFF"
        NoClipButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
        DisableNoClip()
    end
end)

-- Fly
local FlyButton = CreateToggle(MovementContent, "Fly: OFF")
local FlySliderFrame, FlyKnob, FlyVal = CreateSlider(MovementContent)

FlyEnabled = false
FlyMultiplier = 1
FlyBaseSpeed = 50
FlyConn = nil

FlyButton.MouseButton1Click:Connect(function()
    FlyEnabled = not FlyEnabled
    if FlyEnabled then
        FlyButton.Text = "Fly: ON"
        FlyButton.BackgroundColor3 = Color3.fromRGB(0,170,80)
        if not FlyConn then
            FlyConn = RunService.RenderStepped:Connect(function()
                if not FlyEnabled then return end
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end

                local hrp = char.HumanoidRootPart
                local cam = workspace.CurrentCamera
                local moveDirection = Vector3.new(0,0,0)

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection -= Vector3.new(0,1,0) end

                local currentSpeed = FlyBaseSpeed * FlyMultiplier
                hrp.AssemblyLinearVelocity = moveDirection.Magnitude > 0 and (moveDirection.Unit * currentSpeed) or Vector3.new(0, 0.5, 0)
            end)
        end
    else
        FlyButton.Text = "Fly: OFF"
        FlyButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
        if FlyConn then FlyConn:Disconnect() FlyConn = nil end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
end)

-- Fly Slider
local dragFly = false
FlyKnob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragFly = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragFly = false end end)

RunService.RenderStepped:Connect(function()
    if dragFly then
        local mx = UserInputService:GetMouseLocation().X
        local sx = FlySliderFrame.AbsolutePosition.X
        local sw = FlySliderFrame.AbsoluteSize.X

        local knobWidth = 14
        local padding = 4

        local rawPercent = math.clamp((mx - sx - 2) / (sw - knobWidth - padding), 0, 1)

        local steps = 10000
        FlyMultiplier = math.floor(1 + rawPercent * (steps - 1) + 0.5)
        FlyMultiplier = math.clamp(FlyMultiplier, 1, 10000)

        FlyKnob.Position = UDim2.new(0, 2 + rawPercent * (sw - knobWidth - padding), 0, 2)
        FlyVal.Text = FlyMultiplier .. "x"
    end
end)

FlyKnob.Position = UDim2.new(0, 2, 0, 2)
FlyVal.Text = "1x"

-- Click Teleport
local CTButton = CreateToggle(MovementContent, "Click Teleport: OFF")
local CTEnabled = false

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and CTEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        local mouse = LocalPlayer:GetMouse()
        local ray = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude

        local result = workspace:Raycast(ray.Origin, ray.Direction * 5000, params)
        if result then
            char.HumanoidRootPart.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
        end
    end
end)

CTButton.MouseButton1Click:Connect(function()
    CTEnabled = not CTEnabled
    if CTEnabled then
        CTButton.Text = "Click Teleport: ON"
        CTButton.BackgroundColor3 = Color3.fromRGB(0,170,80)
    else
        CTButton.Text = "Click Teleport: OFF"
        CTButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
    end
end)

-- ==================== CAMERA TAB ====================

-- FreeCam
local FreeCamButton = CreateToggle(CameraContent, "FreeCam: OFF")
local FreeCamSliderFrame, FreeCamKnob, FreeCamVal = CreateSlider(CameraContent)

FreeCamEnabled = false
FreeCamConnection = nil
OriginalCameraType = nil
OriginalWalkSpeed = 16
OriginalMouseBehavior = nil
local camera = workspace.CurrentCamera
local yaw = 0
local pitch = 0
local FreeCamPosition = nil
local sensitivity = 0.012
local moveSpeed = 60
local isLooking = false

local function EnableFreeCam()
    if FreeCamEnabled then return end
    FreeCamEnabled = true
    isLooking = false

    local cam = workspace.CurrentCamera

    -- === Force take full camera control (important when coming from Custom Camera) ===
    cam.CameraType = Enum.CameraType.Scriptable
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        cam.CameraSubject = nil
    end
    task.wait()

    OriginalCameraType = cam.CameraType
    OriginalMouseBehavior = UserInputService.MouseBehavior

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        OriginalWalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed
        LocalPlayer.Character.Humanoid.WalkSpeed = 0
    end

    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    FreeCamPosition = cam.CFrame.Position

    local lookVector = cam.CFrame.LookVector
    yaw = math.atan2(lookVector.X, lookVector.Z)
    pitch = math.asin(lookVector.Y)

    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.Anchored = true end
        end
    end

    FreeCamConnection = RunService.RenderStepped:Connect(function(dt)
        if not FreeCamEnabled then return end

        local moveDirection = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection -= Vector3.new(0,1,0) end

        if moveDirection.Magnitude > 0 then
            FreeCamPosition += moveDirection.Unit * moveSpeed * dt
        end

        if isLooking then
            local delta = UserInputService:GetMouseDelta()
            yaw = yaw - delta.X * sensitivity
            pitch = math.clamp(pitch - delta.Y * sensitivity, -89, 89)
        end

        local rotation = CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
        cam.CFrame = CFrame.new(FreeCamPosition) * rotation
    end)
end

local function DisableFreeCam()
    if not FreeCamEnabled then return end
    FreeCamEnabled = false
    isLooking = false

    if FreeCamConnection then FreeCamConnection:Disconnect() FreeCamConnection = nil end

    camera.CameraType = OriginalCameraType or Enum.CameraType.Custom
    UserInputService.MouseBehavior = OriginalMouseBehavior or Enum.MouseBehavior.Default

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = OriginalWalkSpeed
    end

    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.Anchored = false end
        end
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = LocalPlayer.Character.Humanoid
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if FreeCamEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 and not gameProcessed then
        isLooking = true
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if FreeCamEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        isLooking = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

FreeCamButton.MouseButton1Click:Connect(function()
    if FreeCamEnabled then
        DisableFreeCam()
        FreeCamEnabled = false
        FreeCamButton.Text = "FreeCam: OFF"
        FreeCamButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
    else
        -- === Stronger handoff from Custom Camera ===
        if CustomCameraEnabled or CustomCameraConnection then
            if CustomCameraConnection then
                CustomCameraConnection:Disconnect()
                CustomCameraConnection = nil
            end
            CustomCameraEnabled = false
            CustomCameraButton.Text = "Custom Camera: OFF"
            CustomCameraButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)

            local cam = workspace.CurrentCamera
            cam.CameraType = Enum.CameraType.Custom
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                cam.CameraSubject = LocalPlayer.Character.Humanoid
            end
            task.wait(0.15)
        end

        EnableFreeCam()
        FreeCamEnabled = true
        FreeCamButton.Text = "FreeCam: ON"
        FreeCamButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
    end
end)

-- FreeCam Speed Slider
local draggingFreeCamSpeed = false
FreeCamKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFreeCamSpeed = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFreeCamSpeed = false end end)

RunService.RenderStepped:Connect(function()
    if draggingFreeCamSpeed then
        local mouseX = UserInputService:GetMouseLocation().X
        local sx = FreeCamSliderFrame.AbsolutePosition.X
        local sw = FreeCamSliderFrame.AbsoluteSize.X

        local knobWidth = 14
        local padding = 4

        local rawPercent = math.clamp((mouseX - sx - 2) / (sw - knobWidth - padding), 0, 1)

        local steps = 1000
        local FreeCamMultiplier = math.floor(1 + rawPercent * (steps - 1) + 0.5)
        FreeCamMultiplier = math.clamp(FreeCamMultiplier, 1, 1000)

        moveSpeed = 10 * FreeCamMultiplier

        FreeCamKnob.Position = UDim2.new(0, 2 + rawPercent * (sw - knobWidth - padding), 0, 2)
        FreeCamVal.Text = FreeCamMultiplier .. "x"
    end
end)

FreeCamKnob.Position = UDim2.new(0, 2, 0, 2)
FreeCamVal.Text = "1x"

-- Custom Camera
local CustomCameraButton = CreateToggle(CameraContent, "Custom Camera: OFF")
CustomCameraEnabled = false
CustomCameraConnection = nil
TelescopeActive = false

Yaw = 0
Pitch = 0
CurrentZoom = 1.9
TargetZoom = 1.9
MinZoom = 0.5
MaxZoom = math.huge
IsOrbiting = false
IsFirstPerson = false

OriginalCameraType = nil
OriginalCameraSubject = nil
OriginalFOV = 70
CurrentCamPosition = Vector3.new()
CurrentLookAt = Vector3.new()

local function GetFocusPoint()
    local character = LocalPlayer.Character
    if not character then return Vector3.new() end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    return hrp and (hrp.Position + Vector3.new(0, 1.41, 0)) or Vector3.new()
end

local function ForceCharacterVisible()
    local character = LocalPlayer.Character
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then part.LocalTransparencyModifier = 0 end
    end
end

local function UpdateCustomCamera()
    local character = LocalPlayer.Character
    if not character then return end

    local focusPoint = GetFocusPoint()
    if focusPoint == Vector3.new() then return end

    IsFirstPerson = CurrentZoom <= 2.0
    local cam = workspace.CurrentCamera

    if IsFirstPerson and TelescopeActive then
        local head = character:FindFirstChild("Head")
        if head then
            local headPos = head.Position
            local lookDir = CFrame.Angles(0, Yaw, 0) * CFrame.Angles(Pitch, 0, 0).LookVector
            local camPos = headPos + lookDir * 0.15
            cam.CFrame = CFrame.new(camPos, camPos + lookDir)
            cam.FieldOfView = 12
        end
    elseif IsFirstPerson then
        local head = character:FindFirstChild("Head")
        if head then
            local headPos = head.Position
            local lookDir = CFrame.Angles(0, Yaw, 0) * CFrame.Angles(Pitch, 0, 0).LookVector
            local camPos = headPos + lookDir * -1.5
            cam.CFrame = CFrame.new(camPos, camPos + lookDir)
            cam.FieldOfView = 70
            if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            end
        end
    else
        local rotation = CFrame.Angles(0, Yaw, 0) * CFrame.Angles(Pitch, 0, 0)
        local offset = rotation * Vector3.new(0, 0, CurrentZoom)
        local desiredPosition = focusPoint + offset

        if CurrentCamPosition == Vector3.new() then
            CurrentCamPosition = desiredPosition
            CurrentLookAt = focusPoint
        else
            CurrentCamPosition = CurrentCamPosition:Lerp(desiredPosition, 0.38)
            CurrentLookAt = CurrentLookAt:Lerp(focusPoint, 0.38)
        end

        cam.CFrame = CFrame.new(CurrentCamPosition, CurrentLookAt)
        cam.FieldOfView = 70
        ForceCharacterVisible()

        if IsOrbiting then
            if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCurrentPosition then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
            end
        else
            if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end
        end
    end
end

local function EnableCustomCamera()
    if CustomCameraConnection then return end
    OriginalCameraType = workspace.CurrentCamera.CameraType
    OriginalCameraSubject = workspace.CurrentCamera.CameraSubject
    OriginalFOV = workspace.CurrentCamera.FieldOfView

    CustomCameraConnection = RunService.RenderStepped:Connect(function()
        if not CustomCameraEnabled then return end
        CurrentZoom = CurrentZoom + (TargetZoom - CurrentZoom) * 0.2
        UpdateCustomCamera()
    end)
end

local function DisableCustomCamera()
    if CustomCameraConnection then 
        CustomCameraConnection:Disconnect() 
        CustomCameraConnection = nil 
    end

    TelescopeActive = false
    IsOrbiting = false
    IsFirstPerson = false

    local cam = workspace.CurrentCamera

    -- Force reset camera type and subject
    cam.CameraType = Enum.CameraType.Custom
    cam.FieldOfView = OriginalFOV or 70

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        cam.CameraSubject = LocalPlayer.Character.Humanoid
    end

    if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end

    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.LocalTransparencyModifier = 0 
            end
        end
    end

    -- Reset custom camera position tracking
    CurrentCamPosition = Vector3.new()
    CurrentLookAt = Vector3.new()
end

UserInputService.InputChanged:Connect(function(input)
    if CustomCameraEnabled and input.UserInputType == Enum.UserInputType.MouseWheel then
        if not (function()
            local mousePos = UserInputService:GetMouseLocation()
            local guiPos = MainFrame.AbsolutePosition
            local guiSize = MainFrame.AbsoluteSize
            return mousePos.X >= guiPos.X and mousePos.X <= guiPos.X + guiSize.X and mousePos.Y >= guiPos.Y and mousePos.Y <= guiPos.Y + guiSize.Y
        end)() then
            local change = input.Position.Z * -3
            TargetZoom = math.clamp(TargetZoom + change, MinZoom, MaxZoom)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if CustomCameraEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 and not IsFirstPerson then
        IsOrbiting = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then IsOrbiting = false end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if CustomCameraEnabled and not gp and input.KeyCode == Enum.KeyCode.LeftAlt and IsFirstPerson then
        TelescopeActive = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftAlt then TelescopeActive = false end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = UserInputService:GetMouseDelta()
        if CustomCameraEnabled and (IsFirstPerson or IsOrbiting) then
            Yaw = Yaw - delta.X * 0.0032
            Pitch = math.clamp(Pitch - delta.Y * 0.0032, -1.42, 1.42)
        end
    end
end)

CustomCameraButton.MouseButton1Click:Connect(function()
    if CustomCameraEnabled then
        -- Turn OFF: Call Disable FIRST, then set flag to false
        DisableCustomCamera()
        CustomCameraEnabled = false
        CustomCameraButton.Text = "Custom Camera: OFF"
        CustomCameraButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
    else
        -- Turn ON
        if FreeCamEnabled then
            DisableFreeCam()
            FreeCamEnabled = false
            FreeCamButton.Text = "FreeCam: OFF"
            FreeCamButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
        end

        EnableCustomCamera()
        CustomCameraEnabled = true
        CustomCameraButton.Text = "Custom Camera: ON"
        CustomCameraButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
    end
end)

-- ==================== VISUAL TAB ====================

-- ==================== MM2 ROLE DETECTION ====================
local IsMM2 = (game.PlaceId == 142823291)

local function GetMM2Role(player)
    if not IsMM2 or not player.Character then return "Normal" end

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        if backpack:FindFirstChild("Knife") then return "Murderer" end
        if backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver") then return "Sheriff" end
    end
    if player.Character:FindFirstChild("Knife") then return "Murderer" end
    if player.Character:FindFirstChild("Gun") or player.Character:FindFirstChild("Revolver") then return "Sheriff" end
    return "Innocent"
end

local MM2Colors = {
    Murderer = Color3.fromRGB(255, 50, 50),
    Sheriff  = Color3.fromRGB(30, 144, 255),
    Innocent = Color3.fromRGB(50, 255, 50),
}

-- ==================== ESP + NAME TAGS (Robust Version) ====================
local ESPButton = CreateToggle(VisualContent, "ESP: OFF")
local ESPEnabled = false
local Highlights = {}
local NameTags = {}
local ESPUpdateConnection = nil

local function CreateNameTag(player, char)
    if NameTags[player] then return end
    if not char or not char:FindFirstChild("Head") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameTag"
    billboard.Adornee = char.Head
    billboard.Size = UDim2.new(0, 200, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 2.3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = CoreGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0.4
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard

    NameTags[player] = billboard
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    if Highlights[player] then return end

    local char = player.Character
    if not char then return end

    local role = GetMM2Role(player)
    local outlineColor = MM2Colors[role] or Color3.fromRGB(50, 255, 50)

    local h = Instance.new("Highlight")
    h.Adornee = char
    h.FillTransparency = 1
    h.OutlineTransparency = 0.1
    h.OutlineColor = outlineColor
    h.Parent = CoreGui
    Highlights[player] = h

    CreateNameTag(player, char)
end

local function RemoveESP(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
    if NameTags[player] then
        NameTags[player]:Destroy()
        NameTags[player] = nil
    end
end

local function RemoveAllESP()
    for _, h in pairs(Highlights) do if h then h:Destroy() end end
    Highlights = {}
    for _, tag in pairs(NameTags) do if tag then tag:Destroy() end end
    NameTags = {}
end

-- This now actively loops and catches everyone (including respawns & new players)
local function UpdateESP()
    if not ESPEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- If player doesn't have ESP yet, create it
            if not Highlights[player] then
                CreateESP(player)
            end

            -- Update highlight color if role changed (MM2)
            if Highlights[player] and player.Character then
                local role = GetMM2Role(player)
                local color = MM2Colors[role] or Color3.fromRGB(50, 255, 50)
                Highlights[player].OutlineColor = color
            end
        end
    end
end

-- Toggle ESP
ESPButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    if ESPEnabled then
        ESPButton.Text = "ESP: ON"
        ESPButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)

        -- Hide default Roblox names
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            end
        end

        if not ESPUpdateConnection then
            ESPUpdateConnection = RunService.Heartbeat:Connect(UpdateESP)
        end
    else
        ESPButton.Text = "ESP: OFF"
        ESPButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)

        -- Restore default Roblox names
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            end
        end

        RemoveAllESP()
        if ESPUpdateConnection then
            ESPUpdateConnection:Disconnect()
            ESPUpdateConnection = nil
        end
    end
end)

-- Fullbright
local FBButton = CreateToggle(VisualContent, "Fullbright: OFF")
local FBSliderFrame, FBKnob, FBVal = CreateSlider(VisualContent)

FBEnabled = false
FBOriginal = {}
FB_Brightness = 2.0
local draggingFB = false

-- Fullbright Slider
RunService.RenderStepped:Connect(function()
    if draggingFB and FBEnabled then
        local mx = UserInputService:GetMouseLocation().X
        local sx = FBSliderFrame.AbsolutePosition.X
        local sw = FBSliderFrame.AbsoluteSize.X

        local knobWidth = 14
        local padding = 4

        local rawPercent = math.clamp((mx - sx - 2) / (sw - knobWidth - padding), 0, 1)

        FB_Brightness = 0.5 + rawPercent * 4.5
        FBKnob.Position = UDim2.new(0, 2 + rawPercent * (sw - knobWidth - padding), 0, 2)
        FBVal.Text = string.format("%.1f", FB_Brightness)
        Lighting.Brightness = FB_Brightness
    end
end)

FBKnob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingFB = true end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingFB = false end
end)

FBButton.MouseButton1Click:Connect(function()
    FBEnabled = not FBEnabled
    if FBEnabled then
        FBButton.Text = "Fullbright: ON"
        FBButton.BackgroundColor3 = Color3.fromRGB(0,170,80)

        if next(FBOriginal) == nil then
            FBOriginal = {
                Brightness = Lighting.Brightness,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                FogStart = Lighting.FogStart,
                GlobalShadows = Lighting.GlobalShadows,
                ShadowSoftness = Lighting.ShadowSoftness
            }
        end

        Lighting.Brightness = FB_Brightness
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
    else
        FBButton.Text = "Fullbright: OFF"
        FBButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
        if next(FBOriginal) ~= nil then
            for property, value in pairs(FBOriginal) do
                Lighting[property] = value
            end
        end
    end
end)

local initialFBPercent = (FB_Brightness - 0.5) / 4.5
FBKnob.Position = UDim2.new(initialFBPercent, 0, 0, 2)
FBVal.Text = string.format("%.1f", FB_Brightness)

-- X-Ray
local XRayButton = CreateToggle(VisualContent, "X-Ray: OFF")
local XRaySliderFrame, XRayKnob, XRayVal = CreateSlider(VisualContent)

XRayEnabled = false
XRayDistance = 150
XRayConnection = nil
OriginalTransparency = {}
CurrentAffected = {}

local function RemoveXRay()
    for part in pairs(CurrentAffected) do
        if part and part.Parent and OriginalTransparency[part] then
            part.Transparency = OriginalTransparency[part]
            part.CastShadow = true
        end
    end
    CurrentAffected = {}
    OriginalTransparency = {}
end

local function ApplyXRayOptimized()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
    local partsInRadius = workspace:GetPartBoundsInRadius(playerPos, XRayDistance)

    local newAffected = {}

    for _, part in ipairs(partsInRadius) do
        if part:IsA("BasePart") and part ~= LocalPlayer.Character then
            if not CurrentAffected[part] then
                if OriginalTransparency[part] == nil then
                    OriginalTransparency[part] = part.Transparency
                end
                part.Transparency = 0.75
                part.CastShadow = false
            end
            newAffected[part] = true
        end
    end

    for part in pairs(CurrentAffected) do
        if not newAffected[part] then
            if part and part.Parent and OriginalTransparency[part] then
                part.Transparency = OriginalTransparency[part]
                part.CastShadow = true
            end
        end
    end

    CurrentAffected = newAffected
end

XRayButton.MouseButton1Click:Connect(function()
    XRayEnabled = not XRayEnabled
    if XRayEnabled then
        XRayButton.Text = "X-Ray: ON"
        XRayButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)

        if not XRayConnection then
            XRayConnection = RunService.Heartbeat:Connect(function()
                if XRayEnabled then
                    ApplyXRayOptimized()
                end
            end)
        end
    else
        XRayButton.Text = "X-Ray: OFF"
        XRayButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
        if XRayConnection then 
            XRayConnection:Disconnect() 
            XRayConnection = nil 
        end
        RemoveXRay()
    end
end)

-- X-Ray Slider (live update)
local draggingXRay = false
XRayKnob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingXRay = true end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingXRay = false end
end)

RunService.RenderStepped:Connect(function()
    if draggingXRay then
        local mx = UserInputService:GetMouseLocation().X
        local sx = XRaySliderFrame.AbsolutePosition.X
        local sw = XRaySliderFrame.AbsoluteSize.X

        local knobWidth = 14
        local padding = 4

        local rawPercent = math.clamp((mx - sx - 2) / (sw - knobWidth - padding), 0, 1)

        XRayDistance = math.floor(50 + rawPercent * 450)
        XRayKnob.Position = UDim2.new(0, 2 + rawPercent * (sw - knobWidth - padding), 0, 2)
        XRayVal.Text = tostring(XRayDistance)

        if XRayEnabled then
            ApplyXRayOptimized()
        end
    end
end)

XRayKnob.Position = UDim2.new(0.22, 0, 0, 2)
XRayVal.Text = "150"

-- ==================== UTILITY TAB ====================

-- Position Saver
local SaveButton = CreateToggle(UtilityContent, "SAVE NEW POSITION")
SaveButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)

local PosScroll = Instance.new("ScrollingFrame", UtilityContent)
PosScroll.Size = UDim2.new(1, -8, 0, 130)
PosScroll.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
PosScroll.ScrollBarThickness = 4
Instance.new("UICorner", PosScroll).CornerRadius = UDim.new(0, 6)

local PosLayout = Instance.new("UIListLayout", PosScroll)
PosLayout.Padding = UDim.new(0, 6)

local SavedPositions = {}

local function RefreshPositions()
    for _, child in pairs(PosScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for name, data in pairs(SavedPositions) do
        local row = Instance.new("Frame", PosScroll)
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

        local nameLabel = Instance.new("TextLabel", row)
        nameLabel.Size = UDim2.new(0.4, -8, 1, 0)
        nameLabel.Position = UDim2.new(0, 8, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left

        local renameBtn = Instance.new("TextButton", row)
        renameBtn.Size = UDim2.new(0.18, 0, 0.75, 0)
        renameBtn.Position = UDim2.new(0.42, 0, 0.12, 0)
        renameBtn.Text = "Rename"
        renameBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 160)
        renameBtn.TextColor3 = Color3.new(1,1,1)
        renameBtn.TextScaled = true
        renameBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", renameBtn).CornerRadius = UDim.new(0, 4)

        renameBtn.MouseButton1Click:Connect(function()
            nameLabel.Visible = false
            local textBox = Instance.new("TextBox", row)
            textBox.Size = UDim2.new(0.4, -8, 1, 0)
            textBox.Position = UDim2.new(0, 8, 0, 0)
            textBox.Text = name
            textBox.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            textBox.TextColor3 = Color3.new(1,1,1)
            textBox.TextScaled = true
            textBox.Font = Enum.Font.GothamBold
            Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 4)

            textBox.FocusLost:Connect(function(enterPressed)
                if enterPressed and textBox.Text ~= "" and textBox.Text ~= name then
                    local newName = textBox.Text
                    SavedPositions[newName] = data
                    SavedPositions[name] = nil
                end
                textBox:Destroy()
                nameLabel.Visible = true
                RefreshPositions()
            end)
            textBox:CaptureFocus()
        end)

        local loadBtn = Instance.new("TextButton", row)
        loadBtn.Size = UDim2.new(0.18, 0, 0.75, 0)
        loadBtn.Position = UDim2.new(0.62, 0, 0.12, 0)
        loadBtn.Text = "Load"
        loadBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        loadBtn.TextColor3 = Color3.new(1,1,1)
        loadBtn.TextScaled = true
        loadBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 4)

        loadBtn.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = data.cframe
            end
        end)

        local delBtn = Instance.new("TextButton", row)
        delBtn.Size = UDim2.new(0.16, 0, 0.75, 0)
        delBtn.Position = UDim2.new(0.82, 0, 0.12, 0)
        delBtn.Text = "Del"
        delBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        delBtn.TextColor3 = Color3.new(1,1,1)
        delBtn.TextScaled = true
        delBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)

        delBtn.MouseButton1Click:Connect(function()
            SavedPositions[name] = nil
            RefreshPositions()
        end)
    end

    PosScroll.CanvasSize = UDim2.new(0, 0, 0, PosLayout.AbsoluteContentSize.Y + 10)
end

SaveButton.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local count = 0
    for _ in pairs(SavedPositions) do count += 1 end

    local defaultName = "Position " .. (count + 1)
    SavedPositions[defaultName] = {cframe = char.HumanoidRootPart.CFrame}
    RefreshPositions()
end)

-- Spectate
local SpectateButton = CreateToggle(UtilityContent, "Spectate Player")
local currentSpectateTarget = nil
local currentListFrame = nil

local function StopSpectating()
    if workspace.CurrentCamera then
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    end
    currentSpectateTarget = nil
    SpectateButton.Text = "Spectate Player"
end

local function StartSpectating(player)
    StopSpectating()
    currentSpectateTarget = player
    SpectateButton.Text = "Spectating: " .. player.Name

    if player.Character and player.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
    end
end

local function TogglePlayerList()
    if currentListFrame then 
        currentListFrame:Destroy() 
        currentListFrame = nil 
        return 
    end

    local listFrame = Instance.new("Frame", ScreenGui)
    listFrame.Size = UDim2.new(0, 220, 0, 380)
    listFrame.Position = UDim2.new(0.5, -110, 0.5, -190)
    listFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)

    local closeBtn = Instance.new("TextButton", listFrame)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(230, 60, 60)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    closeBtn.MouseButton1Click:Connect(function()
        listFrame:Destroy()
        currentListFrame = nil
    end)

    local scrolling = Instance.new("ScrollingFrame", listFrame)
    scrolling.Size = UDim2.new(1, -12, 1, -36)
    scrolling.Position = UDim2.new(0, 6, 0, 32)
    scrolling.BackgroundTransparency = 1
    scrolling.ScrollBarThickness = 5

    local layout = Instance.new("UIListLayout", scrolling)
    layout.Padding = UDim.new(0, 5)

    if currentSpectateTarget then
        local stopBtn = Instance.new("TextButton", scrolling)
        stopBtn.Size = UDim2.new(1, 0, 0, 34)
        stopBtn.Text = "Stop Spectating"
        stopBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        stopBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        stopBtn.Font = Enum.Font.GothamBold
        stopBtn.TextScaled = true
        Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 5)
        stopBtn.MouseButton1Click:Connect(function()
            StopSpectating()
            listFrame:Destroy()
            currentListFrame = nil
        end)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton", scrolling)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = player.Name
            btn.TextColor3 = Color3.fromRGB(240, 240, 245)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            btn.Font = Enum.Font.GothamBold
            btn.TextScaled = true
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

            btn.MouseButton1Click:Connect(function()
                StartSpectating(player)
                listFrame:Destroy()
                currentListFrame = nil
            end)
        end
    end

    currentListFrame = listFrame
end

SpectateButton.MouseButton1Click:Connect(function()
    if currentSpectateTarget then 
        StopSpectating() 
    else 
        TogglePlayerList() 
    end
end)

-- Server Hop
local ServerHopButton = CreateToggle(UtilityContent, "SERVER HOP")
ServerHopButton.BackgroundColor3 = Color3.fromRGB(200, 100, 60)

ServerHopButton.MouseButton1Click:Connect(function()
    ServerHopButton.Text = "HOPPING..."
    local HttpService = game:GetService("HttpService")

    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if success and result and result.data then
        local servers = {}
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end

        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
        else
            ServerHopButton.Text = "NO SERVERS"
            task.wait(1.5)
            ServerHopButton.Text = "SERVER HOP"
        end
    else
        ServerHopButton.Text = "FAILED"
        task.wait(1.5)
        ServerHopButton.Text = "SERVER HOP"
    end
end)

-- Rejoin
local RejoinButton = CreateToggle(UtilityContent, "REJOIN SERVER")
RejoinButton.BackgroundColor3 = Color3.fromRGB(60, 100, 200)

RejoinButton.MouseButton1Click:Connect(function()
    RejoinButton.Text = "REJOINING..."
    RejoinButton.Active = false

    local success = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)

    if not success then
        RejoinButton.Text = "FAILED"
        task.wait(1.5)
        RejoinButton.Text = "REJOIN SERVER"
        RejoinButton.Active = true
    end
end)

-- Anti-AFK
local AFKButton = CreateToggle(UtilityContent, "Anti-AFK: OFF")
local AFKEnabled = false
local AFKConn = nil

AFKButton.MouseButton1Click:Connect(function()
    AFKEnabled = not AFKEnabled
    if AFKEnabled then
        AFKButton.Text = "Anti-AFK: ON"
        AFKButton.BackgroundColor3 = Color3.fromRGB(0,170,80)
        if not AFKConn then
            AFKConn = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    else
        AFKButton.Text = "Anti-AFK: OFF"
        AFKButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
        if AFKConn then AFKConn:Disconnect() AFKConn = nil end
    end
end)

-- Instant Pickup
local PickupButton = CreateToggle(UtilityContent, "Instant Pickup: OFF")
local PickupEnabled = false
local PickupConnection = nil

local function MakePromptInstant(prompt)
    if prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
    end
end

PickupButton.MouseButton1Click:Connect(function()
    PickupEnabled = not PickupEnabled
    if PickupEnabled then
        PickupButton.Text = "Instant Pickup: ON"
        PickupButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)

        for _, obj in pairs(workspace:GetDescendants()) do
            MakePromptInstant(obj)
        end

        if not PickupConnection then
            PickupConnection = workspace.DescendantAdded:Connect(function(obj)
                if PickupEnabled then MakePromptInstant(obj) end
            end)
        end
    else
        PickupButton.Text = "Instant Pickup: OFF"
        PickupButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
        if PickupConnection then PickupConnection:Disconnect() PickupConnection = nil end
    end
end)

-- ==================== AUTO CLICKER (Fixed - Now properly stops on GUI close) ====================
local AutoClickerButton = CreateToggle(UtilityContent, "Auto Clicker: OFF")

local SetHotkeyButton = Instance.new("TextButton", UtilityContent)
SetHotkeyButton.Size = UDim2.new(1, -8, 0, 28)
SetHotkeyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
SetHotkeyButton.Text = "Set Hotkey (Current: KeypadMultiply)"
SetHotkeyButton.TextColor3 = Color3.fromRGB(240, 240, 245)
SetHotkeyButton.TextScaled = true
SetHotkeyButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", SetHotkeyButton).CornerRadius = UDim.new(0, 5)

AutoClickerEnabled = false
ClickerHotkey = Enum.KeyCode.KeypadMultiply
ClickerLoop = nil
IgnoreNextHotkey = false
ClickerHotkeyConnection = nil   -- NEW: Store the connection so we can disconnect it later

local function StopClicker()
    AutoClickerEnabled = false
    if ClickerLoop then
        pcall(function() task.cancel(ClickerLoop) end)
        ClickerLoop = nil
    end
    AutoClickerButton.Text = "Auto Clicker: OFF"
    AutoClickerButton.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
    if ACIndicator then ACIndicator.Visible = false end
end

local function StartClicker()
    if AutoClickerEnabled then return end
    StopClicker()
    AutoClickerEnabled = true
    AutoClickerButton.Text = "Auto Clicker: ON"
    AutoClickerButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)

    if ACIndicator then
        local mousePos = UserInputService:GetMouseLocation()
        ACIndicator.Position = UDim2.new(0, mousePos.X - 40, 0, mousePos.Y + 18)
        ACIndicator.Visible = true
    end

    ClickerLoop = task.spawn(function()
        while AutoClickerEnabled do
            mouse1click()
            task.wait()
        end
    end)
end

AutoClickerButton.MouseButton1Click:Connect(function()
    if AutoClickerEnabled then 
        StopClicker() 
    else 
        StartClicker() 
    end
end)

-- Hotkey connection (now stored so it can be disconnected later)
ClickerHotkeyConnection = UserInputService.InputBegan:Connect(function(input, gp)
    if IgnoreNextHotkey then return end
    if not gp and input.KeyCode == ClickerHotkey then
        if AutoClickerEnabled then 
            StopClicker() 
        else 
            StartClicker() 
        end
    end
end)

SetHotkeyButton.MouseButton1Click:Connect(function()
    SetHotkeyButton.Text = "Press any key..."
    IgnoreNextHotkey = true

    local connection
    connection = UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.UserInputType == Enum.UserInputType.Keyboard then
            ClickerHotkey = input.KeyCode
            SetHotkeyButton.Text = "Set Hotkey (Current: " .. tostring(ClickerHotkey) .. ")"
            connection:Disconnect()
            task.delay(0.8, function() IgnoreNextHotkey = false end)
        end
    end)
end)

-- Reset Function --
function ResetAllFeatures()
    pcall(function() WS_Enabled = false end)
    pcall(function() JumpPowerEnabled = false end)
    pcall(function() InfJumpEnabled = false end)
    pcall(function() AirGravityEnabled = false end)
    pcall(function() NoClipEnabled = false end)
    pcall(function() FlyEnabled = false end)
    pcall(function() CTEnabled = false end)
    pcall(function() FreeCamEnabled = false end)
    pcall(function() CustomCameraEnabled = false end)
    pcall(function() ESPEnabled = false end)
    pcall(function() FBEnabled = false end)
    pcall(function() XRayEnabled = false end)
    pcall(function() AFKEnabled = false end)
    pcall(function() PickupEnabled = false end)
    pcall(function() AutoClickerEnabled = false end)

    pcall(function() if WS_Conn then WS_Conn:Disconnect() WS_Conn = nil end end)
    pcall(function() if JumpConnection then JumpConnection:Disconnect() JumpConnection = nil end end)
    pcall(function() if AirGravityConnection then AirGravityConnection:Disconnect() AirGravityConnection = nil end end)
    pcall(function() if NoClipConn then NoClipConn:Disconnect() NoClipConn = nil end end)
    pcall(function() if FlyConn then FlyConn:Disconnect() FlyConn = nil end end)
    pcall(function() if FreeCamConnection then FreeCamConnection:Disconnect() FreeCamConnection = nil end end)
    pcall(function() if CustomCameraConnection then CustomCameraConnection:Disconnect() CustomCameraConnection = nil end end)
    pcall(function() if ESPUpdateConnection then ESPUpdateConnection:Disconnect() ESPUpdateConnection = nil end end)
    pcall(function() if AFKConn then AFKConn:Disconnect() AFKConn = nil end end)
    pcall(function() if XRayConnection then XRayConnection:Disconnect() XRayConnection = nil end end)
    pcall(function() if PickupConnection then PickupConnection:Disconnect() PickupConnection = nil end end)
    pcall(function() if ClickerLoop then pcall(function() task.cancel(ClickerLoop) end) ClickerLoop = nil end end)
	pcall(function() if ClickerHotkeyConnection then ClickerHotkeyConnection:Disconnect() ClickerHotkeyConnection = nil end end)

    pcall(DisableFreeCam)
    pcall(DisableCustomCamera)
    pcall(RemoveAllESP)
    pcall(RemoveXRay)

    pcall(function() if ACIndicator then ACIndicator.Visible = false end end)

    pcall(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = false
                    part.CanCollide = true
                end
            end
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                hum.JumpHeight = 7.2
            end
        end
    end)

    pcall(function()
        if next(FBOriginal) ~= nil then
            for k, v in pairs(FBOriginal) do Lighting[k] = v end
        end
    end)

    workspace.Gravity = 196.2
end
