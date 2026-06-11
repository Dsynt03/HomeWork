local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Lighting = game:GetService("Lighting")

-- ==================== PERSISTENT STATE SYSTEM ====================
-- This only saves when you use Server Hop or Rejoin from the GUI
local SavedState = {
    Toggles = {},
    Values = {}
}

local ShouldSaveState = false

local function SaveCurrentState()
    if not ShouldSaveState then return end

    SavedState.Toggles = {
        WalkSpeed = WS_Enabled,
        JumpPower = JumpPowerEnabled,
        InfiniteJump = InfJumpEnabled,
        NoClip = NoClipEnabled,
        Fly = FlyEnabled,
        ClickTeleport = CTEnabled,
        FreeCam = FreeCamEnabled,
        CustomCamera = CustomCameraEnabled,
        ESP = ESPEnabled,
        Fullbright = FBEnabled,
        XRay = XRayEnabled,
        AntiAFK = AFKEnabled,
        InstantPickup = PickupEnabled,
        AutoClicker = AutoClickerEnabled,
    }

    SavedState.Values = {
        WalkSpeedValue = WS_Value,
        JumpPowerValue = DesiredJumpPower,
        FlySpeed = FlySpeed,
        FreeCamSpeed = moveSpeed,
    }
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlayerToolsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ==================== AUTO CLICKER INDICATOR ====================
local ACIndicator = Instance.new("TextLabel")
ACIndicator.Name = "ACIndicator"
ACIndicator.Size = UDim2.new(0, 80, 0, 28)
ACIndicator.Position = UDim2.new(0.5, -40, 0, 8)   -- Default position (can be anything)
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

-- Make "AC: ON" follow the mouse cursor (only when visible)
RunService.RenderStepped:Connect(function()
    if ACIndicator and ACIndicator.Visible then
        local mousePos = UserInputService:GetMouseLocation()
        -- Position directly under the cursor (close but not touching)
        ACIndicator.Position = UDim2.new(0, mousePos.X - 35, 0, mousePos.Y + -35)
    end
end)



-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 420)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- ==================== RESIZE HANDLES (Invisible + Outside Corners) ====================
local ResizeHandles = {}
local MIN_SIZE = Vector2.new(180, 300)

local function CreateResizeHandle(corner)
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 18, 0, 18)           -- Slightly bigger hitbox
    handle.BackgroundTransparency = 1               -- Invisible
    handle.BorderSizePixel = 0
    handle.ZIndex = 50                              -- High ZIndex so it stays on top
    handle.Parent = MainFrame

    if corner == "TopLeft" then
        handle.Position = UDim2.new(0, -6, 0, -6)   -- Outside top-left
        handle.AnchorPoint = Vector2.new(0, 0)
    elseif corner == "TopRight" then
        handle.Position = UDim2.new(1, 6, 0, -6)    -- Outside top-right (avoids red X)
        handle.AnchorPoint = Vector2.new(1, 0)
    elseif corner == "BottomLeft" then
        handle.Position = UDim2.new(0, -6, 1, 6)    -- Outside bottom-left
        handle.AnchorPoint = Vector2.new(0, 1)
    elseif corner == "BottomRight" then
        handle.Position = UDim2.new(1, 6, 1, 6)     -- Outside bottom-right
        handle.AnchorPoint = Vector2.new(1, 1)
    end

    return handle
end

-- Create all 4 handles
ResizeHandles.TopLeft = CreateResizeHandle("TopLeft")
ResizeHandles.TopRight = CreateResizeHandle("TopRight")
ResizeHandles.BottomLeft = CreateResizeHandle("BottomLeft")
ResizeHandles.BottomRight = CreateResizeHandle("BottomRight")

-- ==================== RESIZE LOGIC (Keep this part the same) ====================
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
            newSize = Vector2.new(
                math.max(MIN_SIZE.X, startSize.X + delta.X),
                math.max(MIN_SIZE.Y, startSize.Y + delta.Y)
            )
        elseif resizeCorner == "BottomLeft" then
            newSize = Vector2.new(
                math.max(MIN_SIZE.X, startSize.X - delta.X),
                math.max(MIN_SIZE.Y, startSize.Y + delta.Y)
            )
            newPos = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset
            )
        elseif resizeCorner == "TopRight" then
            newSize = Vector2.new(
                math.max(MIN_SIZE.X, startSize.X + delta.X),
                math.max(MIN_SIZE.Y, startSize.Y - delta.Y)
            )
            newPos = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        elseif resizeCorner == "TopLeft" then
            newSize = Vector2.new(
                math.max(MIN_SIZE.X, startSize.X - delta.X),
                math.max(MIN_SIZE.Y, startSize.Y - delta.Y)
            )
            newPos = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
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

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -70, 1, 0)
TitleLabel.Position = UDim2.new(0, 8, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Player Tools"
TitleLabel.TextColor3 = Color3.new(1,1,1)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Chrome Controls
local function CreateChromeButton(text, color, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 18, 0, 18)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(0,0,0)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TitleBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
    return btn
end

local CloseBtn = CreateChromeButton("×", Color3.fromRGB(255,70,70), UDim2.new(1, -22, 0, 5))
local FullBtn  = CreateChromeButton("□", Color3.fromRGB(70,255,70), UDim2.new(1, -44, 0, 5))
local MinBtn   = CreateChromeButton("—", Color3.fromRGB(255,200,70), UDim2.new(1, -66, 0, 5))

CloseBtn.MouseButton1Click:Connect(function()
    CloseBtn.Active = false
    TitleLabel.Text = "Resetting..."
    ResetAllFeatures()
    task.wait(0.4)
    ScreenGui:Destroy()
end)

FullBtn.MouseButton1Click:Connect(function()
    if MainFrame.Size == UDim2.new(1,0,1,0) then
        MainFrame.Size = UDim2.new(0,220,0,420)
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

-- Draggable TitleBar
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

-- ==================== TAB SYSTEM ====================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 28)
TabBar.Position = UDim2.new(0, 0, 0, 28)
TabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabBar.Parent = MainFrame

-- Better spacing between tabs
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 2)
TabLayout.Parent = TabBar

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, -2, 1, 0)   -- 25% width each (with small gap)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    return btn
end

local MovementTab = CreateTab("Movement")
local CameraTab   = CreateTab("Camera")
local VisualTab   = CreateTab("Visual")
local UtilityTab  = CreateTab("Utility")

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -8, 1, -60)
ContentContainer.Position = UDim2.new(0, 4, 0, 56)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local function CreateContentFrame()
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 5
    frame.ScrollBarImageColor3 = Color3.fromRGB(100,100,100)
    frame.Visible = false
    frame.Parent = ContentContainer

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6)
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

-- Default tab
MovementContent.Visible = true
CurrentTab = MovementContent

-- ==================== HELPER ====================
local function CreateToggle(parent, defaultText)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = defaultText
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
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

-- Jump Power
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
JumpValueLabel.Text = "500"
JumpValueLabel.TextColor3 = Color3.new(1,1,1)
JumpValueLabel.TextScaled = true
JumpValueLabel.Font = Enum.Font.GothamBold

local JumpPowerEnabled = false
local DesiredJumpPower = 500
local JumpConnection = nil

local function ApplyJump()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    hum.JumpPower = DesiredJumpPower
    hum.JumpHeight = 7 + (DesiredJumpPower / 10000) * 300
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
        DesiredJumpPower = math.floor(50 + p * 9950)
        JumpKnob.Position = UDim2.new(p, 0, 0, 0)
        JumpValueLabel.Text = tostring(DesiredJumpPower)
        if JumpPowerEnabled then ApplyJump() end
    end
end)

-- ==================== INFINITE JUMP (Improved) ====================
local InfJumpButton = CreateToggle(MovementContent, "Infinite Jump: OFF")
local InfJumpEnabled = false

UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
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

-- ==================== FLY (Aggressive Version for Stubborn Games) ====================
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
FlyVal.Text = "100"
FlyVal.TextColor3 = Color3.new(1,1,1)
FlyVal.TextScaled = true
FlyVal.Font = Enum.Font.GothamBold

local FlyEnabled = false
local FlySpeed = 100
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

                if moveDirection.Magnitude > 0 then
                    hrp.AssemblyLinearVelocity = moveDirection.Unit * FlySpeed
                else
                    -- Hover in place instead of falling (small upward velocity to counter gravity)
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

        -- Reset velocity when turning off
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
end)

-- Fly Speed Slider
local dragFly = false
FlyKnob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragFly = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragFly = false end end)

RunService.RenderStepped:Connect(function()
    if dragFly then
        local mx = UserInputService:GetMouseLocation().X
        local sx = FlySlider.AbsolutePosition.X
        local sw = FlySlider.AbsoluteSize.X
        local p = math.clamp((mx - sx) / sw, 0, 1)
        FlySpeed = math.floor(50 + p * 450)
        FlyKnob.Position = UDim2.new(p, 0, 0, 0)
        FlyVal.Text = tostring(FlySpeed)
    end
end)

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

-- FreeCam Speed Slider
local draggingFreeCamSpeed = false
FreeCamKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFreeCamSpeed = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFreeCamSpeed = false end end)

RunService.RenderStepped:Connect(function()
    if draggingFreeCamSpeed then
        local mouseX = UserInputService:GetMouseLocation().X
        local sliderX = FreeCamSliderFrame.AbsolutePosition.X
        local sliderWidth = FreeCamSliderFrame.AbsoluteSize.X
        local percent = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
        moveSpeed = math.floor(10 + percent * 290)
        FreeCamKnob.Position = UDim2.new(percent, 0, 0, 0)
        FreeCamVal.Text = tostring(moveSpeed)
    end
end)

local initialFreeCamPercent = (moveSpeed - 10) / 290
FreeCamKnob.Position = UDim2.new(initialFreeCamPercent, 0, 0, 0)
FreeCamVal.Text = tostring(moveSpeed)

-- ==================== CUSTOM CAMERA (Default Roblox Recreation + Telescope) ====================
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

local function UpdateCustomCamera()
    local character = LocalPlayer.Character
    if not character then return end

    local focusPoint = GetFocusPoint()
    if focusPoint == Vector3.new() then return end

    IsFirstPerson = CurrentZoom <= 1.2
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
        -- Third Person (No Collisions)
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
-- ==================== ESP (Improved) ====================
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

    -- Highlight
    local h = Instance.new("Highlight", CoreGui)
    h.Adornee = char
    h.FillTransparency = 0.7
    h.OutlineColor = Color3.fromRGB(0, 200, 255)
    Highlights[player] = h

    -- Name Tag + Info
    local bb = Instance.new("BillboardGui", CoreGui)
    bb.Adornee = char:WaitForChild("Head")
    bb.Size = UDim2.new(0, 160, 0, 60)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true

    local nameLabel = Instance.new("TextLabel", bb)
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold

    local distLabel = Instance.new("TextLabel", bb)
    distLabel.Name = "DistanceLabel"
    distLabel.Size = UDim2.new(1, 0, 0, 14)
    distLabel.Position = UDim2.new(0, 0, 0, 18)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0 studs"
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Gotham

    local healthBG = Instance.new("Frame", bb)
    healthBG.Name = "HealthBG"
    healthBG.Size = UDim2.new(1, 0, 0, 8)
    healthBG.Position = UDim2.new(0, 0, 0, 36)
    healthBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", healthBG).CornerRadius = UDim.new(0, 2)

    local healthFill = Instance.new("Frame", healthBG)
    healthFill.Name = "HealthFill"
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    Instance.new("UICorner", healthFill).CornerRadius = UDim.new(0, 2)

    NameTags[player] = bb
    ESPData[player] = {DistanceLabel = distLabel, HealthFill = healthFill}
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
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local hrp = player.Character.HumanoidRootPart
            local hum = player.Character.Humanoid

            -- Distance
            if data.DistanceLabel and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                data.DistanceLabel.Text = dist .. " studs"
            end

            -- Health Bar
            if data.HealthFill and hum then
                local percent = hum.Health / hum.MaxHealth
                data.HealthFill.Size = UDim2.new(percent, 0, 1, 0)

                if percent > 0.6 then
                    data.HealthFill.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
                elseif percent > 0.3 then
                    data.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
                else
                    data.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
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
        ESPButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
        RemoveAllESP()
        if ESPUpdateConnection then ESPUpdateConnection:Disconnect() ESPUpdateConnection = nil end
    end
end)

-- Handle new players
Players.PlayerAdded:Connect(function(player)
    if ESPEnabled then
        player.CharacterAdded:Connect(function()
            task.wait(0.6)
            if ESPEnabled then CreateESP(player) end
        end)
    end
end)

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- ==================== FULLBRIGHT (Improved) ====================
local FBButton = CreateToggle(VisualContent, "Fullbright: OFF")
local FBEnabled = false
local FBOriginal = {}

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

        Lighting.Brightness = 2
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

-- ==================== X-RAY / WALLHACK (Improved) ====================
local XRayButton = CreateToggle(VisualContent, "X-Ray: OFF")
local XRayEnabled = false
local XRayConnection = nil
local OriginalTransparency = {}

local function ApplyXRay()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj ~= LocalPlayer.Character then
            if OriginalTransparency[obj] == nil then
                OriginalTransparency[obj] = obj.Transparency
            end
            obj.Transparency = 0.8
            obj.CastShadow = false
            obj.LocalTransparencyModifier = 0.8
        end
    end
end

local function RemoveXRay()
    for obj, original in pairs(OriginalTransparency) do
        if obj and obj.Parent then
            obj.Transparency = original
            obj.CastShadow = true
            obj.LocalTransparencyModifier = 0
        end
    end
    OriginalTransparency = {}
end

XRayButton.MouseButton1Click:Connect(function()
    XRayEnabled = not XRayEnabled

    if XRayEnabled then
        XRayButton.Text = "X-Ray: ON"
        XRayButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)

        if not XRayConnection then
            XRayConnection = RunService.Heartbeat:Connect(function()
                if XRayEnabled then
                    ApplyXRay()
                end
            end)
        end
        
        ApplyXRay()
        
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

-- Re-apply on new parts (for streaming games)
workspace.DescendantAdded:Connect(function(obj)
    if XRayEnabled and obj:IsA("BasePart") and obj ~= LocalPlayer.Character then
        if OriginalTransparency[obj] == nil then
            OriginalTransparency[obj] = obj.Transparency
        end
        obj.Transparency = 0.8
        obj.CastShadow = false
        obj.LocalTransparencyModifier = 0.8
    end
end)

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
    ShouldSaveState = true
    SaveCurrentState()

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

            queue_on_teleport([[
                loadstring(game:HttpGet("YOUR_RAW_SCRIPT_URL_HERE"))()
                
                task.wait(3)
                if _G.ReapplySavedState then
                    _G.ReapplySavedState()
                end
            ]])

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
    ShouldSaveState = true
    SaveCurrentState()

    RejoinButton.Text = "REJOINING..."
    RejoinButton.Active = false

    queue_on_teleport([[
        loadstring(game:HttpGet("YOUR_RAW_SCRIPT_URL_HERE"))()
        
        task.wait(3)
        if _G.ReapplySavedState then
            _G.ReapplySavedState()
        end
    ]])

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

-- ==================== INSTANT PICKUP (Improved) ====================
local PickupButton = CreateToggle(UtilityContent, "Instant Pickup: OFF")
local PickupEnabled = false
local PickupConnection = nil

local function ForceInstantPrompts()
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
        end
    end
end

PickupButton.MouseButton1Click:Connect(function()
    PickupEnabled = not PickupEnabled

    if PickupEnabled then
        PickupButton.Text = "Instant Pickup: ON"
        PickupButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)

        -- Constantly force prompts to be instant
        if not PickupConnection then
            PickupConnection = RunService.Heartbeat:Connect(function()
                if PickupEnabled then
                    ForceInstantPrompts()
                end
            end)
        end

        -- Also apply immediately to existing prompts
        ForceInstantPrompts()

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

-- ==================== RE-APPLY SAVED STATE AFTER TELEPORT ====================
_G.ReapplySavedState = function()
    task.wait(2)

    -- WalkSpeed
    if SavedState.Toggles.WalkSpeed then
        WS_Enabled = true
        WalkButton.Text = "WalkSpeed: ON"
        WalkButton.BackgroundColor3 = Color3.fromRGB(0,170,80)
        if not WS_Conn then
            WS_Conn = RunService.RenderStepped:Connect(ApplyWalkSpeed)
        end
    end

    -- Jump Power
    if SavedState.Toggles.JumpPower then
        JumpPowerEnabled = true
        JumpPowerButton.Text = "Jump Power: ON"
        JumpPowerButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        if not JumpConnection then
            JumpConnection = RunService.RenderStepped:Connect(ApplyJump)
        end
        ApplyJump()
    end

    -- Infinite Jump
    if SavedState.Toggles.InfiniteJump then
        InfJumpEnabled = true
        InfJumpButton.Text = "Infinite Jump: ON"
        InfJumpButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
    end

    -- No Clip
    if SavedState.Toggles.NoClip then
        NoClipEnabled = true
        NoClipButton.Text = "No Clip: ON"
        NoClipButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        EnableNoClip()
    end

    -- Fly
    if SavedState.Toggles.Fly then
        FlyEnabled = true
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

                if moveDirection.Magnitude > 0 then
                    hrp.AssemblyLinearVelocity = moveDirection.Unit * FlySpeed
                else
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0.5, 0)
                end
            end)
        end
    end

    -- ESP
    if SavedState.Toggles.ESP then
        ESPEnabled = true
        ESPButton.Text = "ESP: ON"
        ESPButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
        if not ESPUpdateConnection then
            ESPUpdateConnection = RunService.Heartbeat:Connect(UpdateESP)
        end
    end

    -- Fullbright
    if SavedState.Toggles.Fullbright then
        FBEnabled = true
        FBButton.Text = "Fullbright: ON"
        FBButton.BackgroundColor3 = Color3.fromRGB(0,170,80)
        if next(FBOriginal) == nil then
            FBOriginal = {
                Brightness = Lighting.Brightness, Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient, ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
                GlobalShadows = Lighting.GlobalShadows, ShadowSoftness = Lighting.ShadowSoftness
            }
        end
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
    end

    -- X-Ray
    if SavedState.Toggles.XRay then
        XRayEnabled = true
        XRayButton.Text = "X-Ray: ON"
        XRayButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        if not XRayConnection then
            XRayConnection = RunService.Heartbeat:Connect(function()
                if XRayEnabled then ApplyXRay() end
            end)
        end
        ApplyXRay()
    end

    -- Anti-AFK
    if SavedState.Toggles.AntiAFK then
        AFKEnabled = true
        AFKButton.Text = "Anti-AFK: ON"
        AFKButton.BackgroundColor3 = Color3.fromRGB(0,170,80)
        if not AFKConn then
            AFKConn = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                task.wait(1)
            end)
        end
    end

    -- Instant Pickup
    if SavedState.Toggles.InstantPickup then
        PickupEnabled = true
        PickupButton.Text = "Instant Pickup: ON"
        PickupButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        if not PickupConnection then
            PickupConnection = RunService.Heartbeat:Connect(function()
                if PickupEnabled then ForceInstantPrompts() end
            end)
        end
        ForceInstantPrompts()
    end

    -- Auto Clicker
    if SavedState.Toggles.AutoClicker then
        StartClicker()
    end

    -- Restore slider values
    if SavedState.Values.WalkSpeedValue then
        WS_Value = SavedState.Values.WalkSpeedValue
        WalkVal.Text = tostring(WS_Value)
    end
    if SavedState.Values.JumpPowerValue then
        DesiredJumpPower = SavedState.Values.JumpPowerValue
        JumpValueLabel.Text = tostring(DesiredJumpPower)
    end
    if SavedState.Values.FlySpeed then
        FlySpeed = SavedState.Values.FlySpeed
        FlyVal.Text = tostring(FlySpeed)
    end
    if SavedState.Values.FreeCamSpeed then
        moveSpeed = SavedState.Values.FreeCamSpeed
        FreeCamVal.Text = tostring(moveSpeed)
    end

    print("✅ Previous toggles restored after teleport")
end