--[[
    ARSENAL HUB - Delta Fixed
    Aimbot + Silent Aim + ESP + Chams + FPS
    Fully fixed syntax for Delta Executor
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Settings
local Settings = {
    AimbotEnabled = false,
    AimbotFOV = 140,
    AimbotSmooth = 0.15,
    AimbotTeamCheck = true,
    AimbotVisibleCheck = true,
    AimbotPart = "Head",

    SilentEnabled = false,
    SilentFOV = 180,
    SilentTeamCheck = true,
    SilentPart = "Head",
    SilentHitChance = 100,

    ESPEnabled = false,
    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    ESPTracer = false,
    ESPDistance = true,
    ESPTeamCheck = true,
    ESPMaxDistance = 800,

    ChamsEnabled = false,
    ChamsTeamCheck = true,
    ChamsColor = Color3.fromRGB(255, 50, 50),
    ChamsFillTransparency = 0.6,

    ShowFOV = true,
    FPSBoost = false
}

-- FPS
local FPS = 60
local frames = 0
local lastTime = tick()

-- Drawing check
local DrawingAvailable = false
local FOVCircle = nil

pcall(function()
    if Drawing then
        DrawingAvailable = true
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1.5
        FOVCircle.NumSides = 64
        FOVCircle.Filled = false
        FOVCircle.Color = Color3.fromRGB(255, 70, 70)
        FOVCircle.Transparency = 0.7
        FOVCircle.Visible = false
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArsenalHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 240, 0, 380)
Main.Position = UDim2.new(0.02, 0, 0.15, 0)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ARSENAL HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local HeaderFPS = Instance.new("TextLabel")
HeaderFPS.Size = UDim2.new(0, 48, 1, 0)
HeaderFPS.Position = UDim2.new(1, -82, 0, 0)
HeaderFPS.BackgroundTransparency = 1
HeaderFPS.Text = "60 FPS"
HeaderFPS.TextColor3 = Color3.fromRGB(100, 255, 130)
HeaderFPS.Font = Enum.Font.GothamBold
HeaderFPS.TextSize = 12
HeaderFPS.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -33, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 7)
CloseCorner.Parent = CloseBtn

-- Mini Button
local MiniBtn = Instance.new("TextButton")
MiniBtn.Name = "MiniButton"
MiniBtn.Size = UDim2.new(0, 95, 0, 32)
MiniBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
MiniBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MiniBtn.Text = ""
MiniBtn.Visible = false
MiniBtn.Active = true
MiniBtn.Draggable = true
MiniBtn.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 8)
MiniCorner.Parent = MiniBtn

local MiniFPS = Instance.new("TextLabel")
MiniFPS.Size = UDim2.new(1, 0, 1, 0)
MiniFPS.BackgroundTransparency = 1
MiniFPS.Text = "60 FPS"
MiniFPS.TextColor3 = Color3.fromRGB(100, 255, 130)
MiniFPS.Font = Enum.Font.GothamBold
MiniFPS.TextSize = 13
MiniFPS.Parent = MiniBtn

-- Tabs
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -12, 0, 30)
TabFrame.Position = UDim2.new(0, 6, 0, 42)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Main

local Tabs = {"Aimbot", "Silent", "ESP", "Chams", "FPS"}
local TabButtons = {}
local Pages = {}

local function CreateTabButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 43, 1, 0)
    btn.Position = UDim2.new(0, (order - 1) * 45, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.Parent = TabFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn

    TabButtons[name] = btn
    return btn
end

for i, name in ipairs(Tabs) do
    CreateTabButton(name, i)
end

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -12, 1, -82)
Content.Position = UDim2.new(0, 6, 0, 78)
Content.BackgroundTransparency = 1
Content.Parent = Main

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 460)
    page.Parent = Content
    Pages[name] = page
    return page
end

for _, name in ipairs(Tabs) do
    CreatePage(name)
end

Pages["Aimbot"].Visible = true
TabButtons["Aimbot"].BackgroundColor3 = Color3.fromRGB(70, 70, 110)
TabButtons["Aimbot"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- UI Helpers
local function CreateToggle(parent, text, default, callback, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.68, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.Position = UDim2.new(1, -50, 0.5, -12)
    btn.BackgroundColor3 = default and Color3.fromRGB(40, 160, 70) or Color3.fromRGB(160, 40, 50)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 160, 70) or Color3.fromRGB(160, 40, 50)
        callback(state)
    end)
end

local function CreateBox(parent, text, default, callback, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 26)
    box.Position = UDim2.new(0, 0, 0, 20)
    box.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
    box.Text = tostring(default)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.ClearTextOnFocus = false
    box.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = box

    box.FocusLost:Connect(function()
        callback(box.Text)
    end)
end

-- Pages Content (Aimbot & Silent centered for mobile)
CreateToggle(Pages.Aimbot, "Enable Aimbot", false, function(v) Settings.AimbotEnabled = v end, 70)
CreateToggle(Pages.Aimbot, "Team Check", true, function(v) Settings.AimbotTeamCheck = v end, 110)
CreateToggle(Pages.Aimbot, "Visible Check", true, function(v) Settings.AimbotVisibleCheck = v end, 150)
CreateBox(Pages.Aimbot, "FOV", 140, function(v)
    local n = tonumber(v)
    if n then Settings.AimbotFOV = math.clamp(n, 20, 500) end
end, 190)
CreateBox(Pages.Aimbot, "Smoothness (0.01-1)", 0.15, function(v)
    local n = tonumber(v)
    if n then Settings.AimbotSmooth = math.clamp(n, 0.01, 1) end
end, 250)

CreateToggle(Pages.Silent, "Enable Silent Aim", false, function(v) Settings.SilentEnabled = v end, 70)
CreateToggle(Pages.Silent, "Team Check", true, function(v) Settings.SilentTeamCheck = v end, 110)
CreateBox(Pages.Silent, "FOV", 180, function(v)
    local n = tonumber(v)
    if n then Settings.SilentFOV = math.clamp(n, 20, 600) end
end, 150)
CreateBox(Pages.Silent, "Hit Chance %", 100, function(v)
    local n = tonumber(v)
    if n then Settings.SilentHitChance = math.clamp(n, 1, 100) end
end, 210)

CreateToggle(Pages.ESP, "Enable ESP", false, function(v) Settings.ESPEnabled = v end, 4)
CreateToggle(Pages.ESP, "Box", true, function(v) Settings.ESPBox = v end, 38)
CreateToggle(Pages.ESP, "Name", true, function(v) Settings.ESPName = v end, 72)
CreateToggle(Pages.ESP, "Health Bar", true, function(v) Settings.ESPHealth = v end, 106)
CreateToggle(Pages.ESP, "Tracers", false, function(v) Settings.ESPTracer = v end, 140)
CreateToggle(Pages.ESP, "Distance", true, function(v) Settings.ESPDistance = v end, 174)
CreateToggle(Pages.ESP, "Team Check", true, function(v) Settings.ESPTeamCheck = v end, 208)
CreateBox(Pages.ESP, "Max Distance", 800, function(v)
    local n = tonumber(v)
    if n then Settings.ESPMaxDistance = n end
end, 244)

CreateToggle(Pages.Chams, "Enable Chams", false, function(v) Settings.ChamsEnabled = v end, 4)
CreateToggle(Pages.Chams, "Team Check", true, function(v) Settings.ChamsTeamCheck = v end, 38)
CreateBox(Pages.Chams, "Fill Transparency (0-1)", 0.6, function(v)
    local n = tonumber(v)
    if n then Settings.ChamsFillTransparency = math.clamp(n, 0, 1) end
end, 74)

CreateToggle(Pages.FPS, "FPS Booster", false, function(v)
    Settings.FPSBoost = v
    if v then
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                end
            end
        end)
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
        end)
    else
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end)
    end
end, 4)

local FPSInfo = Instance.new("TextLabel")
FPSInfo.Size = UDim2.new(1, 0, 0, 55)
FPSInfo.Position = UDim2.new(0, 0, 0, 45)
FPSInfo.BackgroundTransparency = 1
FPSInfo.Text = "FPS shown in header + mini button when closed."
FPSInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
FPSInfo.Font = Enum.Font.Gotham
FPSInfo.TextSize = 12
FPSInfo.TextWrapped = true
FPSInfo.TextXAlignment = Enum.TextXAlignment.Left
FPSInfo.Parent = Pages.FPS

-- Tab Switching
for name, btn in pairs(TabButtons) do
    btn.MouseButton1Click:Connect(function()
        for n, page in pairs(Pages) do
            page.Visible = false
            TabButtons[n].BackgroundColor3 = Color3.fromRGB(35, 35, 48)
            TabButtons[n].TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        Pages[name].Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 110)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end

-- Close / Open
local function CloseGUI()
    Main.Visible = false
    MiniBtn.Visible = true
    MiniBtn.Position = Main.Position
end

local function OpenGUI()
    Main.Visible = true
    MiniBtn.Visible = false
    Main.Position = MiniBtn.Position
end

CloseBtn.MouseButton1Click:Connect(CloseGUI)
MiniBtn.MouseButton1Click:Connect(OpenGUI)

-- ESP / Chams Storage
local ESPObjects = {}
local ChamsObjects = {}

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, v in pairs(ESPObjects[player]) do
            pcall(function()
                if typeof(v) == "Instance" then
                    v:Destroy()
                else
                    v:Remove()
                end
            end)
        end
        ESPObjects[player] = nil
    end
end

local function RemoveChams(player)
    if ChamsObjects[player] then
        for _, v in pairs(ChamsObjects[player]) do
            pcall(function()
                v:Destroy()
            end)
        end
        ChamsObjects[player] = nil
    end
end

-- Get Closest Player
local function GetClosest(fov, teamCheck, visibleCheck, partName)
    local closest = nil
    local shortest = fov

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local skip = false
                    if teamCheck and player.Team == LocalPlayer.Team then
                        skip = true
                    end

                    if not skip then
                        local part = char:FindFirstChild(partName)
                        if not part then
                            part = char:FindFirstChild("HumanoidRootPart")
                        end

                        if part then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local canTarget = true
                                if visibleCheck then
                                    local origin = Camera.CFrame.Position
                                    local direction = (part.Position - origin).Unit * 1000
                                    local ray = Ray.new(origin, direction)
                                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                                    if hit and not hit:IsDescendantOf(char) then
                                        canTarget = false
                                    end
                                end

                                if canTarget then
                                    local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                                    if dist < shortest then
                                        shortest = dist
                                        closest = part
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Silent Aim Hook (Delta compatible)
local oldNamecall
pcall(function()
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if Settings.SilentEnabled and method == "FindPartOnRayWithIgnoreList" and not checkcaller() then
            local target = GetClosest(Settings.SilentFOV, Settings.SilentTeamCheck, false, Settings.SilentPart)
            if target and math.random(1, 100) <= Settings.SilentHitChance then
                local origin = args[1].Origin
                args[1] = Ray.new(origin, (target.Position - origin).Unit * 1000)
                return oldNamecall(self, unpack(args))
            end
        end

        return oldNamecall(self, ...)
    end))
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- FPS Counter
    frames = frames + 1
    if tick() - lastTime >= 1 then
        FPS = frames
        frames = 0
        lastTime = tick()
    end

    local fpsText = tostring(FPS) .. " FPS"
    HeaderFPS.Text = fpsText
    MiniFPS.Text = fpsText

    local fpsColor = Color3.fromRGB(255, 80, 80)
    if FPS >= 50 then
        fpsColor = Color3.fromRGB(100, 255, 130)
    elseif FPS >= 30 then
        fpsColor = Color3.fromRGB(255, 200, 50)
    end
    HeaderFPS.TextColor3 = fpsColor
    MiniFPS.TextColor3 = fpsColor

    -- FOV Circle
    if DrawingAvailable and FOVCircle then
        local show = Settings.ShowFOV and (Settings.AimbotEnabled or Settings.SilentEnabled)
        FOVCircle.Visible = show
        if show then
            FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
            if Settings.AimbotEnabled then
                FOVCircle.Radius = Settings.AimbotFOV
            else
                FOVCircle.Radius = Settings.SilentFOV
            end
        end
    end

    -- Aimbot
    if Settings.AimbotEnabled then
        local target = GetClosest(Settings.AimbotFOV, Settings.AimbotTeamCheck, Settings.AimbotVisibleCheck, Settings.AimbotPart)
        if target then
            local pos = Camera:WorldToViewportPoint(target.Position)
            local current = Vector2.new(Mouse.X, Mouse.Y)
            local newPos = current:Lerp(Vector2.new(pos.X, pos.Y), Settings.AimbotSmooth)
            pcall(function()
                mousemoverel(newPos.X - current.X, newPos.Y - current.Y)
            end)
        end
    end

    -- ESP + Chams
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if not char or not root or not hum or hum.Health <= 0 then
                RemoveESP(player)
                RemoveChams(player)
            else
                local dist = (root.Position - Camera.CFrame.Position).Magnitude
                if dist > Settings.ESPMaxDistance then
                    RemoveESP(player)
                    RemoveChams(player)
                else
                    local isEnemy = true
                    if (Settings.ESPTeamCheck or Settings.ChamsTeamCheck) and player.Team == LocalPlayer.Team then
                        isEnemy = false
                    end

                    -- ESP
                    if Settings.ESPEnabled and isEnemy and DrawingAvailable then
                        if not ESPObjects[player] then
                            ESPObjects[player] = {}
                        end

                        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                        if onScreen then
                            if Settings.ESPBox then
                                if not ESPObjects[player].Box then
                                    local box = Drawing.new("Square")
                                    box.Thickness = 1
                                    box.Filled = false
                                    box.Color = Color3.fromRGB(255, 50, 50)
                                    ESPObjects[player].Box = box
                                end
                                local size = 2000 / dist
                                ESPObjects[player].Box.Size = Vector2.new(size, size * 1.6)
                                ESPObjects[player].Box.Position = Vector2.new(screenPos.X - size / 2, screenPos.Y - size * 0.9)
                                ESPObjects[player].Box.Visible = true
                            elseif ESPObjects[player].Box then
                                ESPObjects[player].Box.Visible = false
                            end

                            if Settings.ESPName then
                                if not ESPObjects[player].Name then
                                    local name = Drawing.new("Text")
                                    name.Size = 14
                                    name.Center = true
                                    name.Outline = true
                                    name.Color = Color3.fromRGB(255, 255, 255)
                                    ESPObjects[player].Name = name
                                end
                                ESPObjects[player].Name.Text = player.Name
                                ESPObjects[player].Name.Position = Vector2.new(screenPos.X, screenPos.Y - (2000 / dist) * 0.95)
                                ESPObjects[player].Name.Visible = true
                            elseif ESPObjects[player].Name then
                                ESPObjects[player].Name.Visible = false
                            end

                            if Settings.ESPDistance then
                                if not ESPObjects[player].Dist then
                                    local d = Drawing.new("Text")
                                    d.Size = 13
                                    d.Center = true
                                    d.Outline = true
                                    d.Color = Color3.fromRGB(200, 200, 200)
                                    ESPObjects[player].Dist = d
                                end
                                ESPObjects[player].Dist.Text = math.floor(dist) .. "m"
                                ESPObjects[player].Dist.Position = Vector2.new(screenPos.X, screenPos.Y + (2000 / dist) * 0.7)
                                ESPObjects[player].Dist.Visible = true
                            elseif ESPObjects[player].Dist then
                                ESPObjects[player].Dist.Visible = false
                            end

                            if Settings.ESPTracer then
                                if not ESPObjects[player].Tracer then
                                    local t = Drawing.new("Line")
                                    t.Thickness = 1
                                    t.Color = Color3.fromRGB(255, 80, 80)
                                    ESPObjects[player].Tracer = t
                                end
                                ESPObjects[player].Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                ESPObjects[player].Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                                ESPObjects[player].Tracer.Visible = true
                            elseif ESPObjects[player].Tracer then
                                ESPObjects[player].Tracer.Visible = false
                            end
                        else
                            RemoveESP(player)
                        end
                    else
                        RemoveESP(player)
                    end

                    -- Chams
                    if Settings.ChamsEnabled and isEnemy then
                        if not ChamsObjects[player] then
                            ChamsObjects[player] = {}
                            local highlight = Instance.new("Highlight")
                            highlight.FillColor = Settings.ChamsColor
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.FillTransparency = Settings.ChamsFillTransparency
                            highlight.OutlineTransparency = 0
                            highlight.Parent = char
                            ChamsObjects[player].Highlight = highlight
                        else
                            local hl = ChamsObjects[player].Highlight
                            if hl and hl.Parent then
                                hl.FillTransparency = Settings.ChamsFillTransparency
                                hl.FillColor = Settings.ChamsColor
                            end
                        end
                    else
                        RemoveChams(player)
                    end
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
    RemoveChams(player)
end)

print("[Arsenal Hub] Loaded successfully for Delta")
