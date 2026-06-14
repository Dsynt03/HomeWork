local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Lighting = game:GetService("Lighting")

-- ==================== AUTO REQUEUE (Always Reappears) ====================
if queue_on_teleport then
    queue_on_teleport([[
        task.wait(15)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Dsynt03/HomeWork/refs/heads/main/PlayerTools.lua"))()
    ]])
end

-- ==================== DESTROY OLD GUI (Critical for queue_on_teleport) ====================
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("PlayerToolsGUI") then
    CoreGui.PlayerToolsGUI:Destroy()
    task.wait(0.2)
end

-- ==================== SCREEN GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlayerToolsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

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
-- WalkSpeed (Updated - More Aggressive)
local WalkButton = CreateToggle(MovementContent, "WalkSpeed: OFF")
local WalkSlider = Instance.new("Frame", MovementContent)
WalkSlider.Size = UDim2.new(1, -10, 0, 22)
WalkSlider.BackgroundColor3 = Color3.fromRGB(35,35,35)
Instance.new("UICorner", WalkSlider).CornerRadius = UDim.new(0,4)

local WalkKnob = Instance.new("Frame", WalkSlider)
WalkKnob.Size = UDim2.new(0,16,1,0)
WalkKnob.BackgroundColor3 = Color3.fromRGB(0,170,255)
Instance.new("UICorner", WalkKnob).CornerRadius = UDim.new(0,4)

local WalkVal = Instance.new("TextLabel", WalkSlider)
WalkVal.Size = UDim2.new(1,0,1,0)
WalkVal.BackgroundTransparency = 1
WalkVal.Text = "16"
WalkVal.TextColor3 = Color3.new(1,1,1)
WalkVal.TextScaled = true
WalkVal.Font = Enum.Font.GothamBold

local WS_Enabled = false
local WS_Value = 16
local WS_Conn = nil

local function ApplyWalkSpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if WS_Enabled then
        local cam = workspace.CurrentCamera
        local moveDirection = Vector3.new(0,0,0)

        -- Horizontal movement only
        local forward = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit
        local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z).Unit

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= forward end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= right end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += right end

        if moveDirection.Magnitude > 0 then
            local currentVel = hrp.AssemblyLinearVelocity
            
            -- Apply horizontal speed but keep current vertical velocity (so jumping/gravity works normally)
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
        WalkButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
        if WS_Conn then WS_Conn:Disconnect() WS_Conn = nil end

        -- Reset velocity when turned off
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
end)

local dragWS = false
WalkKnob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragWS=true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragWS=false end end)

RunService.RenderStepped:Connect(function()
    if dragWS then
        local mx = UserInputService:GetMouseLocation().X
        local sx = WalkSlider.AbsolutePosition.X
        local sw = WalkSlider.AbsoluteSize.X
        local p = math.clamp((mx-sx)/sw, 0, 1)
        WS_Value = math.floor(1 + p*1999)
        WalkKnob.Position = UDim2.new(p,0,0,0)
        WalkVal.Text = tostring(WS_Value)
    end
end)

-- Jump Power (Multiplier Style - 1x = Default Roblox 50)
local JumpPowerButton = CreateToggle(MovementContent, "Jump Power: OFF")
local JumpSliderFrame = Instance.new("Frame", MovementContent)
JumpSliderFrame.Size = UDim2.new(1, -10, 0, 22)
JumpSliderFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
Instance.new("UICorner", JumpSliderFrame).CornerRadius = UDim.new(0, 4)

local JumpKnob = Instance.new("Frame", JumpSliderFrame)
JumpKnob.Size = UDim2.new(0, 16, 1, 0)
JumpKnob.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", JumpKnob).CornerRadius = UDim.new(0, 4)

local JumpValueLabel = Instance.new("TextLabel", JumpSliderFrame)
JumpValueLabel.Size = UDim2.new(1,0,1,0)
JumpValueLabel.BackgroundTransparency = 1
JumpValueLabel.Text = "1x"
JumpValueLabel.TextColor3 = Color3.new(1,1,1)
JumpValueLabel.TextScaled = true
JumpValueLabel.Font = Enum.Font.GothamBold

local JumpPowerEnabled = false
local JumpMultiplier = 1
local JumpConnection = nil

local function ApplyJump()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    local power = 50 * JumpMultiplier     -- 1x = 50 (default), 20000x = 1,000,000
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
        JumpPowerButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
        if JumpConnection then JumpConnection:Disconnect() JumpConnection = nil end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.JumpPower, hum.JumpHeight = 50, 7.2 end
        end
    end
end)

local draggingJump = false
JumpKnob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingJump = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingJump = false end end)

RunService.RenderStepped:Connect(function()
    if draggingJump then
        local mouseX = UserInputService:GetMouseLocation().X
        local sx = JumpSliderFrame.AbsolutePosition.X
        local sw = JumpSliderFrame.AbsoluteSize.X
        local p = math.clamp((mouseX - sx) / sw, 0, 1)

        -- Snap to whole numbers
        local steps = 20000          -- 20000x = 1,000,000 jump power
        JumpMultiplier = math.floor(1 + p * (steps - 1) + 0.5)
        JumpMultiplier = math.clamp(JumpMultiplier, 1, 20000)

        local percent = (JumpMultiplier - 1) / (steps - 1)
        JumpKnob.Position = UDim2.new(percent, 0, 0, 0)
        JumpValueLabel.Text = JumpMultiplier .. "x"

        if JumpPowerEnabled then ApplyJump() end
    end
end)

-- Set initial slider position
JumpKnob.Position = UDim2.new(0, 0, 0, 0)
JumpValueLabel.Text = "1x"

-- ==================== INFINITE JUMP (With Delay) ====================
local InfJumpButton = CreateToggle(MovementContent, "Infinite Jump: OFF")
local InfJumpEnabled = false

local lastJumpTime = 0
local jumpDelay = 0.18          -- Change this number to adjust delay (in seconds)

UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and LocalPlayer.Character then
        local currentTime = tick()
        
        -- Only allow jump if enough time has passed since last jump
        if currentTime - lastJumpTime >= jumpDelay then
            lastJumpTime = currentTime
            
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then
                -- If Jump Power is also enabled, apply the custom height
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
        InfJumpButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
    end
end)

-- ==================== AIR GRAVITY (New Feature) ====================
-- Reduces gravity while the player is in the air (great with Jump Power + Infinite Jump)

local AirGravityButton = CreateToggle(MovementContent, "Air Gravity: OFF")
local AirGravitySliderFrame = Instance.new("Frame", MovementContent)
AirGravitySliderFrame.Size = UDim2.new(1, -10, 0, 22)
AirGravitySliderFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
Instance.new("UICorner", AirGravitySliderFrame).CornerRadius = UDim.new(0, 4)

local AirGravityKnob = Instance.new("Frame", AirGravitySliderFrame)
AirGravityKnob.Size = UDim2.new(0, 16, 1, 0)
AirGravityKnob.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", AirGravityKnob).CornerRadius = UDim.new(0, 4)

local AirGravityVal = Instance.new("TextLabel", AirGravitySliderFrame)
AirGravityVal.Size = UDim2.new(1,0,1,0)
AirGravityVal.BackgroundTransparency = 1
AirGravityVal.Text = "0.3x"
AirGravityVal.TextColor3 = Color3.new(1,1,1)
AirGravityVal.TextScaled = true
AirGravityVal.Font = Enum.Font.GothamBold

local AirGravityEnabled = false
local AirGravityMultiplier = 0.3          -- Default = 0.3x gravity while in air
local OriginalGravity = workspace.Gravity
local AirGravityConnection = nil

local function ApplyAirGravity()
    if not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not hum then return end

    -- Check if player is in the air
    local state = hum:GetState()
    local isInAir = state == Enum.HumanoidStateType.Jumping 
                 or state == Enum.HumanoidStateType.Freefall

    if isInAir then
        workspace.Gravity = 196.2 * AirGravityMultiplier
    else
        workspace.Gravity = OriginalGravity
    end
end

AirGravityButton.MouseButton1Click:Connect(function()
    AirGravityEnabled = not AirGravityEnabled

    if AirGravityEnabled then
        AirGravityButton.Text = "Air Gravity: ON"
        AirGravityButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)

        if not AirGravityConnection then
            AirGravityConnection = RunService.RenderStepped:Connect(function()
                if AirGravityEnabled then
                    ApplyAirGravity()
                end
            end)
        end
    else
        AirGravityButton.Text = "Air Gravity: OFF"
        AirGravityButton.BackgroundColor3 = Color3.fromRGB(45,45,45)

        if AirGravityConnection then
            AirGravityConnection:Disconnect()
            AirGravityConnection = nil
        end

        -- Restore normal gravity
        workspace.Gravity = OriginalGravity
    end
end)

-- Slider Logic
local draggingAirGravity = false
AirGravityKnob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingAirGravity = true
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingAirGravity = false
    end
end)

RunService.RenderStepped:Connect(function()
    if draggingAirGravity then
        local mouseX = UserInputService:GetMouseLocation().X
        local sx = AirGravitySliderFrame.AbsolutePosition.X
        local sw = AirGravitySliderFrame.AbsoluteSize.X
        local p = math.clamp((mouseX - sx) / sw, 0, 1)

        -- 0.05x (very low) to 1.0x (normal)
        AirGravityMultiplier = 0.05 + (p * 0.95)
        AirGravityMultiplier = math.clamp(AirGravityMultiplier, 0.05, 1)

        local percent = (AirGravityMultiplier - 0.05) / 0.95
        AirGravityKnob.Position = UDim2.new(percent, 0, 0, 0)
        AirGravityVal.Text = string.format("%.2fx", AirGravityMultiplier)
    end
end)

-- Set initial slider position
AirGravityKnob.Position = UDim2.new(0.26, 0, 0, 0)   -- ~0.3x
AirGravityVal.Text = "0.30x"

-- ==================== NO CLIP (Improved - More Aggressive) ====================
local NoClipButton = CreateToggle(MovementContent, "No Clip: OFF")
local NoClipEnabled = false
local NoClipConn = nil

local function EnableNoClip()
    if NoClipConn then return end
    NoClipConn = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then 
                    part.CanCollide = false 
                end
            end
        end
    end)
end

local function DisableNoClip()
    if NoClipConn then 
        NoClipConn:Disconnect() 
        NoClipConn = nil 
    end
    
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.CanCollide = true 
            end
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
        NoClipButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
        DisableNoClip()
    end
end)

-- Fly (Multiplier Style - Now up to 10,000x)
local FlyButton = CreateToggle(MovementContent, "Fly: OFF")
local FlySlider = Instance.new("Frame", MovementContent)
FlySlider.Size = UDim2.new(1, -10, 0, 22)
FlySlider.BackgroundColor3 = Color3.fromRGB(35,35,35)
Instance.new("UICorner", FlySlider).CornerRadius = UDim.new(0,4)

local FlyKnob = Instance.new("Frame", FlySlider)
FlyKnob.Size = UDim2.new(0,16,1,0)
FlyKnob.BackgroundColor3 = Color3.fromRGB(0,170,255)
Instance.new("UICorner", FlyKnob).CornerRadius = UDim.new(0,4)

local FlyVal = Instance.new("TextLabel", FlySlider)
FlyVal.Size = UDim2.new(1,0,1,0)
FlyVal.BackgroundTransparency = 1
FlyVal.Text = "1x"
FlyVal.TextColor3 = Color3.new(1,1,1)
FlyVal.TextScaled = true
FlyVal.Font = Enum.Font.GothamBold

local FlyEnabled = false
local FlyMultiplier = 1
local FlyBaseSpeed = 50
local FlyConn = nil

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

                if moveDirection.Magnitude > 0 then
                    hrp.AssemblyLinearVelocity = moveDirection.Unit * currentSpeed
                else
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0.5, 0)
                end
            end)
        end
    else
        FlyButton.Text = "Fly: OFF"
        FlyButton.BackgroundColor3 = Color3.fromRGB(45,45,45)

        if FlyConn then
            FlyConn:Disconnect()
            FlyConn = nil
        end

        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
end)

-- Fly Speed Slider (Now supports up to 10,000x)
local dragFly = false
FlyKnob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragFly = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragFly = false end end)

RunService.RenderStepped:Connect(function()
    if dragFly then
        local mx = UserInputService:GetMouseLocation().X
        local sx = FlySlider.AbsolutePosition.X
        local sw = FlySlider.AbsoluteSize.X
        local p = math.clamp((mx - sx) / sw, 0, 1)

        -- Changed from 1000 to 10,000
        local steps = 10000
        FlyMultiplier = math.floor(1 + p * (steps - 1) + 0.5)
        FlyMultiplier = math.clamp(FlyMultiplier, 1, 10000)

        local percent = (FlyMultiplier - 1) / (steps - 1)
        FlyKnob.Position = UDim2.new(percent, 0, 0, 0)
        FlyVal.Text = FlyMultiplier .. "x"
    end
end)

-- Set initial slider position
FlyKnob.Position = UDim2.new(0, 0, 0, 0)
FlyVal.Text = "1x"

-- ==================== CLICK TELEPORT (Improved) ====================
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
        CTButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
    end
end)

-- ==================== FREECAM (Updated - More Stable) ====================
local FreeCamButton = CreateToggle(CameraContent, "FreeCam: OFF")

local FreeCamSliderFrame = Instance.new("Frame", CameraContent)
FreeCamSliderFrame.Size = UDim2.new(1, -10, 0, 22)
FreeCamSliderFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
Instance.new("UICorner", FreeCamSliderFrame).CornerRadius = UDim.new(0,4)

local FreeCamKnob = Instance.new("Frame", FreeCamSliderFrame)
FreeCamKnob.Size = UDim2.new(0,16,1,0)
FreeCamKnob.BackgroundColor3 = Color3.fromRGB(0,170,255)
Instance.new("UICorner", FreeCamKnob).CornerRadius = UDim.new(0,4)

local FreeCamVal = Instance.new("TextLabel", FreeCamSliderFrame)
FreeCamVal.Size = UDim2.new(1,0,1,0)
FreeCamVal.BackgroundTransparency = 1
FreeCamVal.Text = "60"
FreeCamVal.TextColor3 = Color3.new(1,1,1)
FreeCamVal.TextScaled = true
FreeCamVal.Font = Enum.Font.GothamBold

local FreeCamEnabled = false
local FreeCamConnection = nil
local OriginalCameraType = nil
local OriginalWalkSpeed = 16
local OriginalMouseBehavior = nil
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
    
    OriginalCameraType = camera.CameraType
    OriginalMouseBehavior = UserInputService.MouseBehavior
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        OriginalWalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed
        LocalPlayer.Character.Humanoid.WalkSpeed = 0
    end
    
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    camera.CameraType = Enum.CameraType.Scriptable
    FreeCamPosition = camera.CFrame.Position
    
    local lookVector = camera.CFrame.LookVector
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
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += camera.CFrame.RightVector end
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
        camera.CFrame = CFrame.new(FreeCamPosition) * rotation
    end)
end

local function DisableFreeCam()
    if not FreeCamEnabled then return end
    FreeCamEnabled = false
    isLooking = false
    
    if FreeCamConnection then 
        FreeCamConnection:Disconnect() 
        FreeCamConnection = nil 
    end
    
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

-- Right Click to Look Around
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
        FreeCamButton.Text = "FreeCam: OFF"
        FreeCamButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    else
        EnableFreeCam()
        FreeCamButton.Text = "FreeCam: ON"
        FreeCamButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
    end
end)

-- FreeCam Speed Slider (Multiplier Style - Max 1000x)
local draggingFreeCamSpeed = false
FreeCamKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFreeCamSpeed = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFreeCamSpeed = false end end)

RunService.RenderStepped:Connect(function()
    if draggingFreeCamSpeed then
        local mouseX = UserInputService:GetMouseLocation().X
        local sliderX = FreeCamSliderFrame.AbsolutePosition.X
        local sliderWidth = FreeCamSliderFrame.AbsoluteSize.X
        local p = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)

        -- Snap to whole numbers (1x to 1000x)
        local steps = 1000
        local FreeCamMultiplier = math.floor(1 + p * (steps - 1) + 0.5)
        FreeCamMultiplier = math.clamp(FreeCamMultiplier, 1, 1000)

        moveSpeed = 10 * FreeCamMultiplier     -- 1000x = 10,000 speed

        local percent = (FreeCamMultiplier - 1) / (steps - 1)
        FreeCamKnob.Position = UDim2.new(percent, 0, 0, 0)
        FreeCamVal.Text = FreeCamMultiplier .. "x"
    end
end)

-- Set initial slider position (1x)
FreeCamKnob.Position = UDim2.new(0, 0, 0, 0)
FreeCamVal.Text = "1x"

-- ==================== CUSTOM CAMERA (Default Roblox Recreation + Telescope + Avatar Visibility Fix) ====================
local CustomCameraButton = CreateToggle(CameraContent, "Custom Camera: OFF")
local CustomCameraEnabled = false
local CustomCameraConnection = nil
local TelescopeActive = false

local Yaw = 0
local Pitch = 0
local CurrentZoom = 1.9
local TargetZoom = 1.9
local MinZoom = 0.5
local MaxZoom = math.huge

local IsOrbiting = false
local IsFirstPerson = false

local OriginalCameraType = nil
local OriginalCameraSubject = nil
local OriginalFOV = 70

local CurrentCamPosition = Vector3.new()
local CurrentLookAt = Vector3.new()

local function GetFocusPoint()
    local character = LocalPlayer.Character
    if not character then return Vector3.new() end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        return hrp.Position + Vector3.new(0, 1.41, 0)
    end
    return Vector3.new()
end

local function ForceCharacterVisible()
    local character = LocalPlayer.Character
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 0
        end
    end
end

local function UpdateCustomCamera()
    local character = LocalPlayer.Character
    if not character then return end

    local focusPoint = GetFocusPoint()
    if focusPoint == Vector3.new() then return end

    IsFirstPerson = CurrentZoom <= 2.0   -- Slightly raised threshold
    local cam = workspace.CurrentCamera

    if IsFirstPerson and TelescopeActive then
        -- Telescope Mode
        local head = character:FindFirstChild("Head")
        if head then
            local headPos = head.Position
            local lookDir = CFrame.Angles(0, Yaw, 0) * CFrame.Angles(Pitch, 0, 0).LookVector
            local camPos = headPos + lookDir * 0.15
            cam.CFrame = CFrame.new(camPos, camPos + lookDir)
            cam.FieldOfView = 12
        end

    elseif IsFirstPerson then
        -- Normal First Person
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
        -- Third Person (No Collisions) + Force Avatar Visible
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

        -- Key fix: Force avatar to stay visible when zooming in from far away
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

    local cam = workspace.CurrentCamera
    cam.CameraType = OriginalCameraType or Enum.CameraType.Custom
    cam.FieldOfView = OriginalFOV or 70

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        cam.CameraSubject = OriginalCameraSubject or LocalPlayer.Character.Humanoid
    end

    if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end

    -- Reset visibility when turning off
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
            end
        end
    end
end

-- Scroll Wheel (only zoom when mouse is NOT over the GUI)
local function isMouseOverGUI()
    local mousePos = UserInputService:GetMouseLocation()
    local guiPos = MainFrame.AbsolutePosition
    local guiSize = MainFrame.AbsoluteSize

    return mousePos.X >= guiPos.X 
       and mousePos.X <= guiPos.X + guiSize.X
       and mousePos.Y >= guiPos.Y 
       and mousePos.Y <= guiPos.Y + guiSize.Y
end

UserInputService.InputChanged:Connect(function(input)
    if CustomCameraEnabled and input.UserInputType == Enum.UserInputType.MouseWheel then
        if not isMouseOverGUI() then
            local change = input.Position.Z * -3
            TargetZoom = math.clamp(TargetZoom + change, MinZoom, MaxZoom)
        end
    end
end)

-- Right Click Orbit
UserInputService.InputBegan:Connect(function(input)
    if CustomCameraEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 and not IsFirstPerson then
        IsOrbiting = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsOrbiting = false
    end
end)

-- Telescope Keybind (Left Alt)
UserInputService.InputBegan:Connect(function(input, gp)
    if CustomCameraEnabled and not gp and input.KeyCode == Enum.KeyCode.LeftAlt and IsFirstPerson then
        TelescopeActive = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        TelescopeActive = false
    end
end)

-- Mouse Look
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = UserInputService:GetMouseDelta()
        if CustomCameraEnabled and (IsFirstPerson or IsOrbiting) then
            Yaw = Yaw - delta.X * 0.0032
            Pitch = math.clamp(Pitch - delta.Y * 0.0032, -1.42, 1.42)
        end
    end
end)

-- Toggle Button Logic
CustomCameraButton.MouseButton1Click:Connect(function()
    CustomCameraEnabled = not CustomCameraEnabled

    if CustomCameraEnabled then
        CustomCameraButton.Text = "Custom Camera: ON"
        CustomCameraButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        EnableCustomCamera()
    else
        CustomCameraButton.Text = "Custom Camera: OFF"
        CustomCameraButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        DisableCustomCamera()
    end
end)

-- ==================== VISUAL TAB ====================
-- ==================== ESP (Outline Only - Premium) ====================
local ESPButton = CreateToggle(VisualContent, "ESP: OFF")
local ESPEnabled = false
local Highlights = {}
local NameTags = {}
local ESPData = {}
local ESPUpdateConnection = nil

local function CreateESP(player)
    if player == LocalPlayer then return end
    if Highlights[player] then return end

    local char = player.Character
    if not char then return end

    -- === Outline Only (No Body Fill) ===
    local h = Instance.new("Highlight")
    h.Adornee = char
    h.FillTransparency = 1                    -- No fill at all
    h.OutlineTransparency = 0.05              -- Very visible outline
    h.OutlineColor = Color3.fromRGB(0, 230, 255)  -- Bright cyan outline
    h.Parent = CoreGui
    Highlights[player] = h

    -- === Name Tag (Premium Style) ===
    local bb = Instance.new("BillboardGui")
    bb.Adornee = char:WaitForChild("Head")
    bb.Size = UDim2.new(0, 180, 0, 72)
    bb.StudsOffset = Vector3.new(0, 3.8, 0)
    bb.AlwaysOnTop = true
    bb.Parent = CoreGui

    -- Dark background for readability
    local bg = Instance.new("Frame", bb)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    bg.BackgroundTransparency = 0.35
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

    -- Player Name
    local nameLabel = Instance.new("TextLabel", bb)
    nameLabel.Size = UDim2.new(1, -8, 0, 20)
    nameLabel.Position = UDim2.new(0, 4, 0, 4)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold

    -- Distance
    local distLabel = Instance.new("TextLabel", bb)
    distLabel.Name = "DistanceLabel"
    distLabel.Size = UDim2.new(1, -8, 0, 16)
    distLabel.Position = UDim2.new(0, 4, 0, 24)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0 studs"
    distLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Gotham

    -- Health Bar Background
    local healthBG = Instance.new("Frame", bb)
    healthBG.Name = "HealthBG"
    healthBG.Size = UDim2.new(1, -8, 0, 10)
    healthBG.Position = UDim2.new(0, 4, 0, 44)
    healthBG.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", healthBG).CornerRadius = UDim.new(0, 3)

    -- Health Bar Fill
    local healthFill = Instance.new("Frame", healthBG)
    healthFill.Name = "HealthFill"
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    Instance.new("UICorner", healthFill).CornerRadius = UDim.new(0, 3)

    NameTags[player] = bb
    ESPData[player] = {
        DistanceLabel = distLabel,
        HealthFill = healthFill
    }
end

local function RemoveESP(player)
    if Highlights[player] then Highlights[player]:Destroy() Highlights[player] = nil end
    if NameTags[player] then NameTags[player]:Destroy() NameTags[player] = nil end
    ESPData[player] = nil
end

local function RemoveAllESP()
    for _, h in pairs(Highlights) do if h then h:Destroy() end end
    for _, bb in pairs(NameTags) do if bb then bb:Destroy() end end
    Highlights, NameTags, ESPData = {}, {}, {}
end

local function UpdateESP()
    if not ESPEnabled then return end

    for player, data in pairs(ESPData) do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local hrp = char.HumanoidRootPart
            local hum = char.Humanoid

            -- Distance + Color Coding
            if data.DistanceLabel and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                data.DistanceLabel.Text = dist .. " studs"

                if dist < 50 then
                    data.DistanceLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                elseif dist < 150 then
                    data.DistanceLabel.TextColor3 = Color3.fromRGB(255, 180, 80)
                else
                    data.DistanceLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
                end
            end

            -- Health Bar Coloring
            if data.HealthFill and hum then
                local percent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                data.HealthFill.Size = UDim2.new(percent, 0, 1, 0)

                if percent > 0.6 then
                    data.HealthFill.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
                elseif percent > 0.3 then
                    data.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
                else
                    data.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
                end
            end
        end
    end
end

ESPButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled

    if ESPEnabled then
        ESPButton.Text = "ESP: ON"
        ESPButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)

        for _, p in ipairs(Players:GetPlayers()) do
            CreateESP(p)
        end

        if not ESPUpdateConnection then
            ESPUpdateConnection = RunService.Heartbeat:Connect(UpdateESP)
        end
    else
        ESPButton.Text = "ESP: OFF"
        ESPButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        RemoveAllESP()
        if ESPUpdateConnection then 
            ESPUpdateConnection:Disconnect() 
            ESPUpdateConnection = nil 
        end
    end
end)

-- Auto create ESP for new players
Players.PlayerAdded:Connect(function(player)
    if ESPEnabled then
        player.CharacterAdded:Connect(function()
            task.wait(0.6)
            if ESPEnabled then CreateESP(player) end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- ==================== FULLBRIGHT (Improved with Brightness Slider) ====================
local FBButton = CreateToggle(VisualContent, "Fullbright: OFF")
local FBEnabled = false
local FBOriginal = {}

-- Brightness Slider
local FBSliderFrame = Instance.new("Frame", VisualContent)
FBSliderFrame.Size = UDim2.new(1, -10, 0, 22)
FBSliderFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
Instance.new("UICorner", FBSliderFrame).CornerRadius = UDim.new(0, 4)

local FBKnob = Instance.new("Frame", FBSliderFrame)
FBKnob.Size = UDim2.new(0, 16, 1, 0)
FBKnob.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", FBKnob).CornerRadius = UDim.new(0, 4)

local FBVal = Instance.new("TextLabel", FBSliderFrame)
FBVal.Size = UDim2.new(1,0,1,0)
FBVal.BackgroundTransparency = 1
FBVal.Text = "2.0"
FBVal.TextColor3 = Color3.new(1,1,1)
FBVal.TextScaled = true
FBVal.Font = Enum.Font.GothamBold

local FB_Brightness = 2.0
local draggingFB = false

-- Update brightness live when slider is moved (only if Fullbright is on)
RunService.RenderStepped:Connect(function()
    if draggingFB and FBEnabled then
        local mx = UserInputService:GetMouseLocation().X
        local sx = FBSliderFrame.AbsolutePosition.X
        local sw = FBSliderFrame.AbsoluteSize.X
        local p = math.clamp((mx - sx) / sw, 0, 1)
        
        FB_Brightness = 0.5 + p * 4.5          -- Range: 0.5 to 5.0
        FBKnob.Position = UDim2.new(p, 0, 0, 0)
        FBVal.Text = string.format("%.1f", FB_Brightness)
        
        Lighting.Brightness = FB_Brightness
    end
end)

FBKnob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFB = true
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFB = false
    end
end)

-- Fullbright Toggle
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
        FBButton.BackgroundColor3 = Color3.fromRGB(45,45,45)

        if next(FBOriginal) ~= nil then
            for property, value in pairs(FBOriginal) do
                Lighting[property] = value
            end
        end
    end
end)

-- Set initial slider position
local initialFBPercent = (FB_Brightness - 0.5) / 4.5
FBKnob.Position = UDim2.new(initialFBPercent, 0, 0, 0)
FBVal.Text = string.format("%.1f", FB_Brightness)

-- ==================== X-RAY / WALLHACK (Improved - Low Lag) ====================
local XRayButton = CreateToggle(VisualContent, "X-Ray: OFF")

-- X-Ray Distance Slider
local XRaySliderFrame = Instance.new("Frame", VisualContent)
XRaySliderFrame.Size = UDim2.new(1, -10, 0, 22)
XRaySliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", XRaySliderFrame).CornerRadius = UDim.new(0, 4)

local XRayKnob = Instance.new("Frame", XRaySliderFrame)
XRayKnob.Size = UDim2.new(0, 16, 1, 0)
XRayKnob.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", XRayKnob).CornerRadius = UDim.new(0, 4)

local XRayVal = Instance.new("TextLabel", XRaySliderFrame)
XRayVal.Size = UDim2.new(1, 0, 1, 0)
XRayVal.BackgroundTransparency = 1
XRayVal.Text = "150"
XRayVal.TextColor3 = Color3.new(1, 1, 1)
XRayVal.TextScaled = true
XRayVal.Font = Enum.Font.GothamBold

local XRayEnabled = false
local XRayDistance = 150
local XRayConnection = nil
local OriginalTransparency = {}

local function ApplyXRayInRadius()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
    local parts = workspace:GetPartBoundsInRadius(playerPos, XRayDistance)

    for _, part in ipairs(parts) do
        if part:IsA("BasePart") and part ~= LocalPlayer.Character then
            if OriginalTransparency[part] == nil then
                OriginalTransparency[part] = part.Transparency
            end
            part.Transparency = 0.75
            part.CastShadow = false
        end
    end
end

local function RemoveXRay()
    for part, original in pairs(OriginalTransparency) do
        if part and part.Parent then
            part.Transparency = original
            part.CastShadow = true
        end
    end
    OriginalTransparency = {}
end

-- X-Ray Toggle
XRayButton.MouseButton1Click:Connect(function()
    XRayEnabled = not XRayEnabled

    if XRayEnabled then
        XRayButton.Text = "X-Ray: ON"
        XRayButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)

        if not XRayConnection then
            XRayConnection = RunService.Heartbeat:Connect(function()
                if XRayEnabled then
                    ApplyXRayInRadius()
                end
            end)
        end
    else
        XRayButton.Text = "X-Ray: OFF"
        XRayButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

        if XRayConnection then
            XRayConnection:Disconnect()
            XRayConnection = nil
        end

        RemoveXRay()
    end
end)

-- X-Ray Distance Slider
local draggingXRay = false

XRayKnob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingXRay = true
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingXRay = false
    end
end)

RunService.RenderStepped:Connect(function()
    if draggingXRay then
        local mx = UserInputService:GetMouseLocation().X
        local sx = XRaySliderFrame.AbsolutePosition.X
        local sw = XRaySliderFrame.AbsoluteSize.X
        local p = math.clamp((mx - sx) / sw, 0, 1)

        -- Range: 50 to 500 studs
        XRayDistance = math.floor(50 + p * 450)
        XRayKnob.Position = UDim2.new(p, 0, 0, 0)
        XRayVal.Text = tostring(XRayDistance)
    end
end)

-- Set initial slider position (150 studs)
XRayKnob.Position = UDim2.new(0.22, 0, 0, 0)
XRayVal.Text = "150"

-- ==================== UTILITY TAB ====================
-- ==================== POSITION SAVER (Improved) ====================
local SaveButton = CreateToggle(UtilityContent, "SAVE NEW POSITION")
SaveButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)

local PosScroll = Instance.new("ScrollingFrame", UtilityContent)
PosScroll.Size = UDim2.new(1, -10, 0, 110)
PosScroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
PosScroll.ScrollBarThickness = 5
Instance.new("UICorner", PosScroll).CornerRadius = UDim.new(0,4)

local PosLayout = Instance.new("UIListLayout", PosScroll)
PosLayout.Padding = UDim.new(0,5)

local SavedPositions = {}

local function RefreshPositions()
    for _, child in pairs(PosScroll:GetChildren()) do 
        if child:IsA("Frame") then child:Destroy() end 
    end

    for name, data in pairs(SavedPositions) do
        local row = Instance.new("Frame", PosScroll)
        row.Size = UDim2.new(1, 0, 0, 28)
        row.BackgroundColor3 = Color3.fromRGB(45,45,45)
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

        -- Name Label
        local nameLabel = Instance.new("TextLabel", row)
        nameLabel.Size = UDim2.new(0.38, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 4, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = Color3.new(1,1,1)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold

        -- Rename Button
        local renameBtn = Instance.new("TextButton", row)
        renameBtn.Size = UDim2.new(0.18, 0, 1, 0)
        renameBtn.Position = UDim2.new(0.38, 0, 0, 0)
        renameBtn.Text = "Rename"
        renameBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
        renameBtn.TextColor3 = Color3.new(1,1,1)
        renameBtn.TextScaled = true
        renameBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", renameBtn).CornerRadius = UDim.new(0, 4)

        renameBtn.MouseButton1Click:Connect(function()
            nameLabel.Visible = false
            local textBox = Instance.new("TextBox", row)
            textBox.Size = UDim2.new(0.38, 0, 1, 0)
            textBox.Position = UDim2.new(0, 4, 0, 0)
            textBox.Text = name
            textBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
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

        -- Load Button
        local loadBtn = Instance.new("TextButton", row)
        loadBtn.Size = UDim2.new(0.2, 0, 1, 0)
        loadBtn.Position = UDim2.new(0.56, 0, 0, 0)
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

        -- Delete Button
        local delBtn = Instance.new("TextButton", row)
        delBtn.Size = UDim2.new(0.2, 0, 1, 0)
        delBtn.Position = UDim2.new(0.78, 0, 0, 0)
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

    -- Count how many positions are currently saved
    local count = 0
    for _ in pairs(SavedPositions) do
        count += 1
    end

    local defaultName = "Position " .. (count + 1)
    SavedPositions[defaultName] = {cframe = char.HumanoidRootPart.CFrame}
    RefreshPositions()
end)

-- ==================== SPECTATE (Improved) ====================
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
    listFrame.Size = UDim2.new(0, 200, 0, 340)
    listFrame.Position = UDim2.new(0.5, -100, 0.5, -170)
    listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)

    -- Close button
    local closeBtn = Instance.new("TextButton", listFrame)
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -26, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
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
    scrolling.Size = UDim2.new(1, -10, 1, -30)
    scrolling.Position = UDim2.new(0, 5, 0, 28)
    scrolling.BackgroundTransparency = 1
    scrolling.ScrollBarThickness = 6

    local layout = Instance.new("UIListLayout", scrolling)
    layout.Padding = UDim.new(0, 4)

    -- Stop Spectating button
    if currentSpectateTarget then
        local stopBtn = Instance.new("TextButton", scrolling)
        stopBtn.Size = UDim2.new(1, 0, 0, 32)
        stopBtn.Text = "Stop Spectating"
        stopBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        stopBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        stopBtn.Font = Enum.Font.GothamBold
        stopBtn.TextScaled = true
        Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 4)
        stopBtn.MouseButton1Click:Connect(function()
            StopSpectating()
            listFrame:Destroy()
            currentListFrame = nil
        end)
    end

    -- Player list
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton", scrolling)
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.Text = player.Name
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            btn.Font = Enum.Font.GothamBold
            btn.TextScaled = true
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

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

-- Server Hop (Saves state only when clicked from GUI)
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
            ShouldSaveState = false
        end
    else
        ServerHopButton.Text = "FAILED"
        task.wait(1.5)
        ServerHopButton.Text = "SERVER HOP"
        ShouldSaveState = false
    end
end)

-- Rejoin Server (Saves state only when clicked from GUI)
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
        ShouldSaveState = false
    end
end)

-- ==================== ANTI-AFK (Improved) ====================
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
                task.wait(1) -- Small delay to look more natural
            end)
        end
    else
        AFKButton.Text = "Anti-AFK: OFF"
        AFKButton.BackgroundColor3 = Color3.fromRGB(45,45,45)

        if AFKConn then
            AFKConn:Disconnect()
            AFKConn = nil
        end
    end
end)

-- ==================== INSTANT PICKUP (Improved - Performance Fixed) ====================
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

        -- Apply to all existing prompts once
        for _, obj in pairs(workspace:GetDescendants()) do
            MakePromptInstant(obj)
        end

        -- Only update new prompts when they are added (much lighter than every frame)
        if not PickupConnection then
            PickupConnection = workspace.DescendantAdded:Connect(function(obj)
                if PickupEnabled then
                    MakePromptInstant(obj)
                end
            end)
        end

    else
        PickupButton.Text = "Instant Pickup: OFF"
        PickupButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

        if PickupConnection then
            PickupConnection:Disconnect()
            PickupConnection = nil
        end
    end
end)

-- ==================== AUTO CLICKER (Improved) ====================
local AutoClickerButton = CreateToggle(UtilityContent, "Auto Clicker: OFF")
local SetHotkeyButton = Instance.new("TextButton", UtilityContent)
SetHotkeyButton.Size = UDim2.new(1, -10, 0, 26)
SetHotkeyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
SetHotkeyButton.Text = "Set Hotkey (Current: Enum.KeyCode.KeypadMultiply)"
SetHotkeyButton.TextColor3 = Color3.new(1,1,1)
SetHotkeyButton.TextScaled = true
SetHotkeyButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", SetHotkeyButton).CornerRadius = UDim.new(0, 6)

local AutoClickerEnabled = false
local ClickerHotkey = Enum.KeyCode.KeypadMultiply
local ClickerLoop = nil
local IgnoreNextHotkey = false

local function StopClicker()
    AutoClickerEnabled = false
    if ClickerLoop then 
        pcall(function() task.cancel(ClickerLoop) end) 
        ClickerLoop = nil 
    end
    AutoClickerButton.Text = "Auto Clicker: OFF"
    AutoClickerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ACIndicator.Visible = false
end

local function StartClicker()
    if AutoClickerEnabled then return end
    StopClicker()
    AutoClickerEnabled = true
    AutoClickerButton.Text = "Auto Clicker: ON"
    AutoClickerButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
    
    -- Show indicator under cursor
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

UserInputService.InputBegan:Connect(function(input, gp)
    if IgnoreNextHotkey then return end
    if not gp and input.KeyCode == ClickerHotkey then
        if AutoClickerEnabled then StopClicker() else StartClicker() end
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

-- ==================== RESET FUNCTION ====================
function ResetAllFeatures()
    pcall(function() FreeCamEnabled = false end)
    pcall(function() ESPEnabled = false end)
    pcall(function() WS_Enabled = false end)
    pcall(function() JumpPowerEnabled = false end)
    pcall(function() NoClipEnabled = false end)
    pcall(function() FlyEnabled = false end)
    pcall(function() FBEnabled = false end)
	pcall(function() XRayEnabled = false end)
	pcall(function() ACIndicator.Visible = false end)
    pcall(function() AFKEnabled = false end)
    pcall(function() PickupEnabled = false end)
    pcall(function() InfJumpEnabled = false end)
    pcall(function() CTEnabled = false end)
    pcall(function() AutoClickerEnabled = false end)

    pcall(function() if FreeCamConnection then FreeCamConnection:Disconnect() end end)
    pcall(function() if ESPUpdateConnection then ESPUpdateConnection:Disconnect() end end)
    pcall(function() if WS_Conn then WS_Conn:Disconnect() end end)
    pcall(function() if JumpConnection then JumpConnection:Disconnect() end end)
    pcall(function() if NoClipConn then NoClipConn:Disconnect() end end)
    pcall(function() if FlyConn then FlyConn:Disconnect() end end)
    pcall(function() if AFKConn then AFKConn:Disconnect() end end)
	pcall(function() if XRayConnection then XRayConnection:Disconnect() end end)
    pcall(function() if PickupConnection then PickupConnection:Disconnect() end end)
	pcall(function() if ClickerLoop then task.cancel(ClickerLoop) ClickerLoop = nil end end)

    pcall(DisableFreeCam)
    pcall(RemoveAllESP)
	pcall(RemoveXRay)
    pcall(DisableNoClip)
    pcall(StopFly)
    pcall(StopSpectating)
	pcall(StopClicker)

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
end
