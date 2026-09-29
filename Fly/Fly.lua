--== steve_F0xy FLY | Reverted Anti-Grav ==--
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
local pg = plr:WaitForChild("PlayerGui")

--== STATE ==--
local flying = false
local speed = 90
local minSpeed = 20
local maxSpeed = 400
local noclipConn
local flyConn
local antiGravForce

--== CLEANUP ==--
for _, n in ipairs({"STEVEFOXY_TOPBAR", "STEVEFOXY_FLY", "STEVEFOXY_SPEED", "STEVEFOXY_SPLASH"}) do
    local old = pg:FindFirstChild(n)
    if old then old:Destroy() end
end

--== PLACE NAME ==--
local function getPlaceName()
    local ok, name = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    if ok and name and name ~= "" then return name end
    return "Unknown Place"
end

local placeName = getPlaceName()

--== NOCLIP ==--
local function startNoclip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
end

--== ANTI-GRAVITY ==--
local function startAntiGrav()
    if antiGravForce and antiGravForce.Parent then return end
    antiGravForce = Instance.new("BodyForce")
    antiGravForce.Force = Vector3.new(0, workspace.Gravity * hrp:GetMass(), 0)
    antiGravForce.Parent = hrp
end

local function stopAntiGrav()
    if antiGravForce then
        antiGravForce:Destroy()
        antiGravForce = nil
    end
end

--== FLY CORE (WASD only) ==--
local function startFly()
    if flying then return end
    flying = true
    startNoclip()
    startAntiGrav()

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = true
    end

    flyConn = RunService.Heartbeat:Connect(function(dt)
        if not flying then return end
        if not hrp or not hrp.Parent then return end

        local camCF = camera.CFrame
        local look = camCF.LookVector
        local right = camCF.RightVector

        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += look end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= look end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += right end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= right end

        if move.Magnitude > 0 then
            move = move.Unit * speed * dt
        end

        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = hrp.CFrame + move

        if antiGravForce then
            antiGravForce.Force = Vector3.new(0, workspace.Gravity * hrp:GetMass(), 0)
        end

        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude > 0.01 then
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + flatLook)
        end
    end)
end

local function stopFly()
    flying = false

    if flyConn then
        flyConn:Disconnect()
        flyConn = nil
    end

    stopNoclip()
    stopAntiGrav()

    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

--== SPLASH ==--
local function createSplash()
    local sg = Instance.new("ScreenGui")
    sg.Name = "STEVEFOXY_SPLASH"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999
    sg.Parent = pg

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BorderSizePixel = 0
    bg.BackgroundTransparency = 1
    bg.Parent = sg

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 0, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 20, 120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 0, 40)),
    })
    grad.Rotation = 45
    grad.Parent = bg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 80)
    title.Position = UDim2.new(0, 0, 0.4, -60)
    title.BackgroundTransparency = 1
    title.Text = "steve_F0xy"
    title.TextColor3 = Color3.fromRGB(200, 140, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 56
    title.TextTransparency = 1
    title.Parent = bg

    local titleStroke = Instance.new("UIStroke")
    titleStroke.Color = Color3.fromRGB(120, 60, 220)
    titleStroke.Thickness = 2
    titleStroke.Transparency = 1
    titleStroke.Parent = title

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 40)
    sub.Position = UDim2.new(0, 0, 0.4, 20)
    sub.BackgroundTransparency = 1
    sub.Text = "F L Y"
    sub.TextColor3 = Color3.fromRGB(255, 255, 255)
    sub.Font = Enum.Font.GothamBold
    sub.TextSize = 28
    sub.TextTransparency = 1
    sub.Parent = bg

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0, 360, 0, 6)
    barBg.Position = UDim2.new(0.5, -180, 0.4, 90)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
    barBg.BorderSizePixel = 0
    barBg.BackgroundTransparency = 1
    barBg.Parent = bg

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = barBg

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(160, 90, 255)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = barFill

    local fillGrad = Instance.new("UIGradient")
    fillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 60, 220)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 140, 255)),
    })
    fillGrad.Parent = barFill

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0.4, 110)
    status.BackgroundTransparency = 1
    status.Text = "initializing..."
    status.TextColor3 = Color3.fromRGB(140, 120, 180)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextTransparency = 1
    status.Parent = bg

    TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
    task.wait(0.4)
    TweenService:Create(title, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(titleStroke, TweenInfo.new(0.4), {Transparency = 0}):Play()
    task.wait(0.25)
    TweenService:Create(sub, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(barBg, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
    TweenService:Create(status, TweenInfo.new(0.4), {TextTransparency = 0}):Play()

    for i = 1, 4 do
        local ox = math.random(-6, 6)
        title.Position = UDim2.new(0, ox, 0.4, -60)
        task.wait(0.04)
    end
    title.Position = UDim2.new(0, 0, 0.4, -60)

    local steps = {
        {0.0, "loading modules..."},
        {0.25, "patching memory..."},
        {0.5, "initializing fly core..."},
        {0.75, "injecting hooks..."},
        {1.0, "ready."},
    }
    for _, step in ipairs(steps) do
        TweenService:Create(barFill, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {Size = UDim2.new(step[1], 0, 1, 0)}):Play()
        status.Text = step[2]
        task.wait(0.35)
    end

    task.wait(0.3)
    TweenService:Create(title, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(titleStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
    TweenService:Create(sub, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(status, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(barBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    task.wait(0.6)
    sg:Destroy()
end

--== WINDOW FACTORY ==--
local function makeWindow(name, size, position, accent)
    local gui = Instance.new("ScreenGui")
    gui.Name = "STEVEFOXY_" .. name
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = pg

    local main = Instance.new("Frame")
    main.Size = size
    main.Position = position
    main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    main.BorderSizePixel = 0
    main.Active = true
    main.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main

    local stroke = Instance.new("UIStroke")
    stroke.Color = accent
    stroke.Thickness = 1.5
    stroke.Parent = main

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 28)
    header.BackgroundColor3 = Color3.fromRGB(24, 20, 34)
    header.BorderSizePixel = 0
    header.Parent = main

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 10)
    hCorner.Parent = header

    local hFix = Instance.new("Frame")
    hFix.Size = UDim2.new(1, 0, 0, 10)
    hFix.Position = UDim2.new(0, 0, 1, -10)
    hFix.BackgroundColor3 = Color3.fromRGB(24, 20, 34)
    hFix.BorderSizePixel = 0
    hFix.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -24, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Color3.fromRGB(220, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local dragStart, startPos, dragging = nil, nil, false
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    main.AncestryChanged:Connect(function(_, parent)
        if not parent then main.Parent = gui end
    end)
    gui.AncestryChanged:Connect(function(_, parent)
        if not parent then gui.Parent = pg end
    end)
    pg.ChildRemoved:Connect(function(child)
        if child == gui then gui.Parent = pg end
    end)

    return gui, main
end

--== TOPBAR ==--
local topGui = Instance.new("ScreenGui")
topGui.Name = "STEVEFOXY_TOPBAR"
topGui.ResetOnSpawn = false
topGui.IgnoreGuiInset = true
topGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
topGui.DisplayOrder = 10
topGui.Parent = pg

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(0, 520, 0, 38)
topBar.Position = UDim2.new(0.5, -260, 0, 14)
topBar.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
topBar.BackgroundTransparency = 0.35
topBar.BorderSizePixel = 0
topBar.Parent = topGui

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 19)
topCorner.Parent = topBar

local topStroke = Instance.new("UIStroke")
topStroke.Color = Color3.fromRGB(160, 90, 255)
topStroke.Thickness = 1.2
topStroke.Transparency = 0.3
topStroke.Parent = topBar

local topGrad = Instance.new("UIGradient")
topGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 30, 110)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 15, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 30, 110)),
})
topGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.2),
    NumberSequenceKeypoint.new(0.5, 0.5),
    NumberSequenceKeypoint.new(1, 0.2),
})
topGrad.Parent = topBar

local brand = Instance.new("TextLabel")
brand.Size = UDim2.new(0, 180, 1, 0)
brand.Position = UDim2.new(0, 18, 0, 0)
brand.BackgroundTransparency = 1
brand.Text = "steve_F0xy"
brand.TextColor3 = Color3.fromRGB(220, 200, 255)
brand.Font = Enum.Font.GothamBold
brand.TextSize = 13
brand.TextXAlignment = Enum.TextXAlignment.Left
brand.Parent = topBar

local brandStroke = Instance.new("UIStroke")
brandStroke.Color = Color3.fromRGB(120, 60, 220)
brandStroke.Thickness = 1
brandStroke.Transparency = 0.4
brandStroke.Parent = brand

local placeLbl = Instance.new("TextLabel")
placeLbl.Size = UDim2.new(0, 200, 1, 0)
placeLbl.Position = UDim2.new(0.5, -100, 0, 0)
placeLbl.BackgroundTransparency = 1
placeLbl.Text = placeName
placeLbl.TextColor3 = Color3.fromRGB(200, 190, 230)
placeLbl.Font = Enum.Font.GothamBold
placeLbl.TextSize = 11
placeLbl.TextTruncate = Enum.TextTruncate.AtEnd
placeLbl.TextXAlignment = Enum.TextXAlignment.Center
placeLbl.Parent = topBar

local placeStroke = Instance.new("UIStroke")
placeStroke.Color = Color3.fromRGB(120, 60, 220)
placeStroke.Thickness = 1
placeStroke.Transparency = 0.5
placeStroke.Parent = placeLbl

local timeLbl = Instance.new("TextLabel")
timeLbl.Size = UDim2.new(0, 180, 1, 0)
timeLbl.Position = UDim2.new(1, -198, 0, 0)
timeLbl.BackgroundTransparency = 1
timeLbl.Text = "00:00:00"
timeLbl.TextColor3 = Color3.fromRGB(220, 200, 255)
timeLbl.Font = Enum.Font.GothamBold
timeLbl.TextSize = 13
timeLbl.TextXAlignment = Enum.TextXAlignment.Right
timeLbl.Parent = topBar

local timeStroke = Instance.new("UIStroke")
timeStroke.Color = Color3.fromRGB(120, 60, 220)
timeStroke.Thickness = 1
timeStroke.Transparency = 0.4
timeStroke.Parent = timeLbl

task.spawn(function()
    while timeLbl.Parent do
        local t = os.date("*t")
        timeLbl.Text = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
        task.wait(1)
    end
end)

topBar.AncestryChanged:Connect(function(_, parent)
    if not parent then topBar.Parent = topGui end
end)
topGui.AncestryChanged:Connect(function(_, parent)
    if not parent then topGui.Parent = pg end
end)
pg.ChildRemoved:Connect(function(child)
    if child == topGui then topGui.Parent = pg end
end)

--== WINDOW 1: FLY ==--
local flyGui, flyMain = makeWindow("FLY", UDim2.new(0, 180, 0, 90), UDim2.new(0.5, -270, 0.5, -45), Color3.fromRGB(120, 80, 220))

local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(1, -24, 0, 40)
flyBtn.Position = UDim2.new(0, 12, 0, 38)
flyBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 50)
flyBtn.Text = "Fly: OFF"
flyBtn.TextColor3 = Color3.fromRGB(230, 220, 255)
flyBtn.Font = Enum.Font.GothamMedium
flyBtn.TextSize = 14
flyBtn.AutoButtonColor = false
flyBtn.Parent = flyMain

local fbCorner = Instance.new("UICorner")
fbCorner.CornerRadius = UDim.new(0, 8)
fbCorner.Parent = flyBtn

flyBtn.MouseEnter:Connect(function()
    TweenService:Create(flyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 42, 75)}):Play()
end)
flyBtn.MouseLeave:Connect(function()
    if not flying then
        TweenService:Create(flyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 30, 50)}):Play()
    end
end)

local function refreshFlyBtn()
    if flying then
        flyBtn.Text = "Fly: ON"
        TweenService:Create(flyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 50, 160)}):Play()
    else
        flyBtn.Text = "Fly: OFF"
        TweenService:Create(flyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 30, 50)}):Play()
    end
end

flyBtn.MouseButton1Click:Connect(function()
    if flying then stopFly() else startFly() end
    refreshFlyBtn()
end)

--== WINDOW 2: SPEED ==--
local spdGui, spdMain = makeWindow("SPEED", UDim2.new(0, 200, 0, 100), UDim2.new(0.5, 90, 0.5, -50), Color3.fromRGB(160, 90, 255))

local speedLbl = Instance.new("TextLabel")
speedLbl.Size = UDim2.new(1, -24, 0, 20)
speedLbl.Position = UDim2.new(0, 12, 0, 36)
speedLbl.BackgroundTransparency = 1
speedLbl.Text = "Speed: " .. speed
speedLbl.TextColor3 = Color3.fromRGB(190, 175, 220)
speedLbl.Font = Enum.Font.GothamMedium
speedLbl.TextSize = 12
speedLbl.TextXAlignment = Enum.TextXAlignment.Left
speedLbl.Parent = spdMain

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -24, 0, 8)
sliderBg.Position = UDim2.new(0, 12, 0, 68)
sliderBg.BackgroundColor3 = Color3.fromRGB(35, 30, 50)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = spdMain

local sCorner = Instance.new("UICorner")
sCorner.CornerRadius = UDim.new(0, 4)
sCorner.Parent = sliderBg

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((speed - minSpeed) / (maxSpeed - minSpeed), 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(140, 90, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local sfCorner = Instance.new("UICorner")
sfCorner.CornerRadius = UDim.new(0, 4)
sfCorner.Parent = sliderFill

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 14, 0, 14)
knob.Position = UDim2.new((speed - minSpeed) / (maxSpeed - minSpeed), -7, 0.5, -7)
knob.BackgroundColor3 = Color3.fromRGB(245, 240, 255)
knob.BorderSizePixel = 0
knob.ZIndex = 3
knob.Parent = sliderBg

local kCorner = Instance.new("UICorner")
kCorner.CornerRadius = UDim.new(1, 0)
kCorner.Parent = knob

local draggingSpd = false
local function updateSlider(input)
    local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
    speed = math.floor(minSpeed + (maxSpeed - minSpeed) * rel)
    sliderFill.Size = UDim2.new(rel, 0, 1, 0)
    knob.Position = UDim2.new(rel, -7, 0.5, -7)
    speedLbl.Text = "Speed: " .. speed
end

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingSpd = true
        updateSlider(input)
    end
end)

UIS.InputChanged:Connect(function(input)
    if draggingSpd and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingSpd = false
    end
end)

--== RESPAWN ==--
plr.CharacterAdded:Connect(function(c)
    stopFly()
    char = c
    hrp = char:WaitForChild("HumanoidRootPart")
    camera = workspace.CurrentCamera
    refreshFlyBtn()
end)

--== BOOT ==--
task.spawn(function()
    createSplash()
end)
