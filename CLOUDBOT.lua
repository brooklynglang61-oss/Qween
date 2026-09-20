--[[
    CLOUDBOT — Mobile Only
    Key System: FREEKEY_XXX_XXX_XXX | 12H Expire | Random Generation
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
if not isMobile then
    warn("[CLOUDBOT] Mobile devices only. Unloading.")
    return
end

-- ═══════════════════════════════════════════════════════════════
-- KEY SYSTEM
-- VIPKEY  : Lifetime | 25 total | one-time use
-- FREEKEY : 12 Hours | unlimited | expires after 12h
-- ═══════════════════════════════════════════════════════════════

local USED_VIP_FILE  = "cloudbot_used_vips.txt"
local FREE_KEY_FILE  = "cloudbot_freekey.txt"
local REMEMBER_FILE  = "cloudbot_remember.txt"
local FREE_EXPIRE_H  = 12

-- 25 Lifetime VIP Keys
local VIP_KEYS = {
    ["VIPKEY_G69_LS4_SAY"] = true,
    ["VIPKEY_4AG_EBE_R59"] = true,
    ["VIPKEY_K86_YM4_AGX"] = true,
    ["VIPKEY_NY6_LNA_USY"] = true,
    ["VIPKEY_JA8_8M8_NHZ"] = true,
    ["VIPKEY_4XJ_JJN_JC9"] = true,
    ["VIPKEY_WK8_JKE_8R8"] = true,
    ["VIPKEY_G86_HHQ_K48"] = true,
    ["VIPKEY_2GQ_D5D_QR7"] = true,
    ["VIPKEY_4ZP_VD2_MT5"] = true,
    ["VIPKEY_4H8_R8D_SN6"] = true,
    ["VIPKEY_LFV_LS4_HUT"] = true,
    ["VIPKEY_2Q8_BDM_AB6"] = true,
    ["VIPKEY_46X_UUL_BS6"] = true,
    ["VIPKEY_F7L_99V_U5J"] = true,
    ["VIPKEY_XQH_LZK_KHF"] = true,
    ["VIPKEY_2CL_PYZ_MHT"] = true,
    ["VIPKEY_S8Y_Z98_5SX"] = true,
    ["VIPKEY_XXA_LGF_FCH"] = true,
    ["VIPKEY_3JY_QE5_4XW"] = true,
    ["VIPKEY_2R4_96X_7YQ"] = true,
    ["VIPKEY_SYJ_K8Z_JXS"] = true,
    ["VIPKEY_TPS_D2J_3V4"] = true,
    ["VIPKEY_QZA_EBP_ACS"] = true,
    ["VIPKEY_ZM8_N9V_G3T"] = true,
}

-- VIP helpers
local function LoadUsedVips()
    local used = {}
    local ok, data = pcall(function() return readfile(USED_VIP_FILE) end)
    if ok and data and data ~= "" then
        for key in string.gmatch(data, "[^|]+") do used[string.upper(key)] = true end
    end
    return used
end

local function MarkVipUsed(key)
    local used = LoadUsedVips()
    used[string.upper(key)] = true
    local list = {}
    for k in pairs(used) do table.insert(list, k) end
    pcall(function() writefile(USED_VIP_FILE, table.concat(list, "|")) end)
end

local function IsVipUsed(key)
    return LoadUsedVips()[string.upper(key)] == true
end

local function CountUsedVips()
    local used = LoadUsedVips()
    local c = 0
    for _ in pairs(used) do c = c + 1 end
    return c
end

-- FREEKEY helpers (12h)
local function SaveFreeKey(key, expireTime)
    pcall(function() writefile(FREE_KEY_FILE, string.upper(key) .. "|" .. tostring(expireTime)) end)
end

local function LoadFreeKey()
    local ok, data = pcall(function() return readfile(FREE_KEY_FILE) end)
    if ok and data and data ~= "" then
        local parts = string.split(data, "|")
        if #parts == 2 then return parts[1], tonumber(parts[2]) end
    end
    return nil, nil
end

local function ClearFreeKey()
    pcall(function() writefile(FREE_KEY_FILE, "") end)
end

-- Remember helpers
local function SaveRememberedKey(key, keyType)
    pcall(function() writefile(REMEMBER_FILE, string.upper(key) .. "|" .. keyType) end)
end

local function LoadRememberedKey()
    local ok, data = pcall(function() return readfile(REMEMBER_FILE) end)
    if ok and data and data ~= "" then
        local parts = string.split(data, "|")
        if #parts == 2 then return parts[1], parts[2] end
        return string.upper(data), "VIP"
    end
    return nil, nil
end

local function ClearRememberedKey()
    pcall(function() writefile(REMEMBER_FILE, "") end)
end

-- ── Key GUI ───────────────────────────────────────────────────────────────────
local CoreGui = game:GetService("CoreGui")
pcall(function()
    local old = CoreGui:FindFirstChild("CLOUDBOT_KEY")
    if old then old:Destroy() end
    local old2 = CoreGui:FindFirstChild("CLOUDBOT_GUI")
    if old2 then old2:Destroy() end
end)

local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "CLOUDBOT_KEY"
KeyGui.ResetOnSpawn = false
KeyGui.IgnoreGuiInset = true
KeyGui.DisplayOrder = 1000
pcall(function() KeyGui.Parent = CoreGui end)

local Overlay = Instance.new("Frame", KeyGui)
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(5, 3, 10)
Overlay.BorderSizePixel = 0

local Card = Instance.new("Frame", Overlay)
Card.Size = UDim2.new(0, 350, 0, 480)
Card.Position = UDim2.new(0.5, -175, 0.5, -240)
Card.BackgroundColor3 = Color3.fromRGB(12, 8, 20)
Card.BorderSizePixel = 0

local CardCorner = Instance.new("UICorner", Card)
CardCorner.CornerRadius = UDim.new(0, 12)
local CardStroke = Instance.new("UIStroke", Card)
CardStroke.Color = Color3.fromRGB(140, 40, 255)
CardStroke.Thickness = 2

local TopBar = Instance.new("Frame", Card)
TopBar.Size = UDim2.new(1, 0, 0, 4)
TopBar.BackgroundColor3 = Color3.fromRGB(155, 40, 255)
TopBar.BorderSizePixel = 0

local Logo = Instance.new("Frame", Card)
Logo.Size = UDim2.new(0, 42, 0, 42)
Logo.Position = UDim2.new(0.5, -21, 0, 20)
Logo.BackgroundColor3 = Color3.fromRGB(155, 40, 255)
Logo.BorderSizePixel = 0
local LogoC = Instance.new("UICorner", Logo)
LogoC.CornerRadius = UDim.new(0, 10)

local LogoTxt = Instance.new("TextLabel", Logo)
LogoTxt.Size = UDim2.new(1, 0, 1, 0)
LogoTxt.BackgroundTransparency = 1
LogoTxt.Text = "⚡"
LogoTxt.TextSize = 22
LogoTxt.Font = Enum.Font.GothamBold
LogoTxt.TextColor3 = Color3.fromRGB(255, 255, 255)

local Title = Instance.new("TextLabel", Card)
Title.Size = UDim2.new(1, -20, 0, 26)
Title.Position = UDim2.new(0, 10, 0, 70)
Title.BackgroundTransparency = 1
Title.Text = "CLOUDBOT"
Title.TextSize = 24
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

local Sub = Instance.new("TextLabel", Card)
Sub.Size = UDim2.new(1, -20, 0, 16)
Sub.Position = UDim2.new(0, 10, 0, 98)
Sub.BackgroundTransparency = 1
Sub.Text = "VIP  •  FREEKEY  •  12H / LIFETIME"
Sub.TextSize = 12
Sub.Font = Enum.Font.GothamBold
Sub.TextColor3 = Color3.fromRGB(155, 40, 255)

-- Option 1
local Opt1 = Instance.new("TextButton", Card)
Opt1.Size = UDim2.new(1, -30, 0, 40)
Opt1.Position = UDim2.new(0, 15, 0, 130)
Opt1.BackgroundColor3 = Color3.fromRGB(25, 15, 45)
Opt1.BorderSizePixel = 0
Opt1.Text = "①  JOIN DISCORD FOR MORE INFOS"
Opt1.TextSize = 12
Opt1.Font = Enum.Font.GothamBold
Opt1.TextColor3 = Color3.fromRGB(220, 210, 240)
local Opt1C = Instance.new("UICorner", Opt1)
Opt1C.CornerRadius = UDim.new(0, 8)

Opt1.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://discord.gg/WwP6e98Bpp") end)
    Opt1.Text = "✓  LINK COPIED!"
    task.delay(1.4, function()
        if Opt1 then Opt1.Text = "①  JOIN DISCORD FOR MORE INFOS" end
    end)
end)

-- Option 2
local Opt2 = Instance.new("TextButton", Card)
Opt2.Size = UDim2.new(1, -30, 0, 40)
Opt2.Position = UDim2.new(0, 15, 0, 180)
Opt2.BackgroundColor3 = Color3.fromRGB(25, 15, 45)
Opt2.BorderSizePixel = 0
Opt2.Text = "②  DOWNLOAD APK FROM DISCORD"
Opt2.TextSize = 12
Opt2.Font = Enum.Font.GothamBold
Opt2.TextColor3 = Color3.fromRGB(220, 210, 240)
local Opt2C = Instance.new("UICorner", Opt2)
Opt2C.CornerRadius = UDim.new(0, 8)

Opt2.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://discord.gg/WwP6e98Bpp") end)
    Opt2.Text = "✓  LINK COPIED!"
    task.delay(1.4, function()
        if Opt2 then Opt2.Text = "②  DOWNLOAD APK FROM DISCORD" end
    end)
end)

-- Divider
local Div = Instance.new("Frame", Card)
Div.Size = UDim2.new(1, -40, 0, 1)
Div.Position = UDim2.new(0, 20, 0, 240)
Div.BackgroundColor3 = Color3.fromRGB(50, 30, 90)
Div.BorderSizePixel = 0

-- Key Input Section
local KeyLabel = Instance.new("TextLabel", Card)
KeyLabel.Size = UDim2.new(1, -30, 0, 18)
KeyLabel.Position = UDim2.new(0, 15, 0, 260)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "③  PASTE YOUR KEY HERE"
KeyLabel.TextSize = 12
KeyLabel.Font = Enum.Font.GothamBold
KeyLabel.TextColor3 = Color3.fromRGB(200, 190, 220)

local KeyInfo = Instance.new("TextLabel", Card)
KeyInfo.Size = UDim2.new(1, -30, 0, 16)
KeyInfo.Position = UDim2.new(0, 15, 0, 282)
KeyInfo.BackgroundTransparency = 1
KeyInfo.Text = "VIPKEY = Lifetime  |  FREEKEY = 12 Hours"
KeyInfo.TextSize = 11
KeyInfo.Font = Enum.Font.GothamSemibold
KeyInfo.TextColor3 = Color3.fromRGB(140, 120, 180)

local KeyBox = Instance.new("TextBox", Card)
KeyBox.Size = UDim2.new(1, -30, 0, 40)
KeyBox.Position = UDim2.new(0, 15, 0, 305)
KeyBox.BackgroundColor3 = Color3.fromRGB(8, 5, 15)
KeyBox.BorderSizePixel = 0
KeyBox.PlaceholderText = "VIPKEY_... or FREEKEY_..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(90, 80, 120)
KeyBox.Text = ""
KeyBox.TextSize = 15
KeyBox.Font = Enum.Font.GothamBold
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.ClearTextOnFocus = false
local KeyBoxC = Instance.new("UICorner", KeyBox)
KeyBoxC.CornerRadius = UDim.new(0, 8)
local KeyBoxS = Instance.new("UIStroke", KeyBox)
KeyBoxS.Color = Color3.fromRGB(80, 40, 140)
KeyBoxS.Thickness = 1.5

-- Remember this key? toggle
local rememberState = true
local RememberRow = Instance.new("Frame", Card)
RememberRow.Size = UDim2.new(1, -30, 0, 28)
RememberRow.Position = UDim2.new(0, 15, 0, 352)
RememberRow.BackgroundTransparency = 1

local RememberLbl = Instance.new("TextLabel", RememberRow)
RememberLbl.Size = UDim2.new(1, -50, 1, 0)
RememberLbl.BackgroundTransparency = 1
RememberLbl.Text = "Remember this key?"
RememberLbl.TextSize = 13
RememberLbl.Font = Enum.Font.GothamBold
RememberLbl.TextColor3 = Color3.fromRGB(200, 190, 220)
RememberLbl.TextXAlignment = Enum.TextXAlignment.Left

local RememberTrack = Instance.new("Frame", RememberRow)
RememberTrack.Size = UDim2.new(0, 40, 0, 22)
RememberTrack.Position = UDim2.new(1, -42, 0.5, -11)
RememberTrack.BackgroundColor3 = Color3.fromRGB(155, 40, 255)
RememberTrack.BorderSizePixel = 0
local RememberTrackC = Instance.new("UICorner", RememberTrack)
RememberTrackC.CornerRadius = UDim.new(0, 11)

local RememberKnob = Instance.new("Frame", RememberTrack)
RememberKnob.Size = UDim2.new(0, 18, 0, 18)
RememberKnob.Position = UDim2.new(1, -20, 0.5, -9)
RememberKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RememberKnob.BorderSizePixel = 0
local RememberKnobC = Instance.new("UICorner", RememberKnob)
RememberKnobC.CornerRadius = UDim.new(0, 9)

local RememberBtn = Instance.new("TextButton", RememberRow)
RememberBtn.Size = UDim2.new(1, 0, 1, 0)
RememberBtn.BackgroundTransparency = 1
RememberBtn.Text = ""

RememberBtn.MouseButton1Click:Connect(function()
    rememberState = not rememberState
    if rememberState then
        RememberTrack.BackgroundColor3 = Color3.fromRGB(155, 40, 255)
        RememberKnob.Position = UDim2.new(1, -20, 0.5, -9)
    else
        RememberTrack.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
        RememberKnob.Position = UDim2.new(0, 2, 0.5, -9)
    end
end)

local EnterBtn = Instance.new("TextButton", Card)
EnterBtn.Size = UDim2.new(1, -30, 0, 42)
EnterBtn.Position = UDim2.new(0, 15, 0, 390)
EnterBtn.BackgroundColor3 = Color3.fromRGB(155, 40, 255)
EnterBtn.BorderSizePixel = 0
EnterBtn.Text = "ENTER KEY"
EnterBtn.TextSize = 15
EnterBtn.Font = Enum.Font.GothamBold
EnterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
local EnterBtnC = Instance.new("UICorner", EnterBtn)
EnterBtnC.CornerRadius = UDim.new(0, 8)

local StatusTxt = Instance.new("TextLabel", Card)
StatusTxt.Size = UDim2.new(1, -20, 0, 18)
StatusTxt.Position = UDim2.new(0, 10, 0, 438)
StatusTxt.BackgroundTransparency = 1
StatusTxt.Text = ""
StatusTxt.TextSize = 12
StatusTxt.Font = Enum.Font.GothamBold
StatusTxt.TextColor3 = Color3.fromRGB(255, 80, 80)

-- ── Key Validation ────────────────────────────────────────────────────────────
local function AcceptAndLoad(msg)
    StatusTxt.Text = msg
    StatusTxt.TextColor3 = Color3.fromRGB(50, 230, 120)
    EnterBtn.Text = "ACCESS GRANTED"
    EnterBtn.BackgroundColor3 = Color3.fromRGB(30, 140, 70)
    task.wait(0.75)
    KeyGui:Destroy()
    loadMain()
end

local function CheckKey()
    local input = string.upper(KeyBox.Text:gsub("%s+", ""))
    
    if input == "" then
        StatusTxt.Text = "✗ ENTER A KEY FIRST"
        StatusTxt.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end
    
    local isVip  = string.match(input, "^VIPKEY_[%w]+_[%w]+_[%w]+$")
    local isFree = string.match(input, "^FREEKEY_[%w]+_[%w]+_[%w]+$")
    
    if not isVip and not isFree then
        StatusTxt.Text = "✗ INVALID FORMAT (VIPKEY_ or FREEKEY_)"
        StatusTxt.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end
    
    -- ── VIP KEY ───────────────────────────────────────────────
    if isVip then
        if not VIP_KEYS[input] then
            StatusTxt.Text = "✗ INVALID VIP KEY"
            StatusTxt.TextColor3 = Color3.fromRGB(255, 80, 80)
            return
        end
        
        local alreadyUsed = IsVipUsed(input)
        local remembered, remType = LoadRememberedKey()
        
        if alreadyUsed and (remembered ~= input) then
            StatusTxt.Text = "✗ THIS VIP KEY WAS ALREADY USED"
            StatusTxt.TextColor3 = Color3.fromRGB(255, 80, 80)
            return
        end
        
        if not alreadyUsed and CountUsedVips() >= 25 then
            StatusTxt.Text = "✗ ALL 25 VIP KEYS HAVE BEEN USED"
            StatusTxt.TextColor3 = Color3.fromRGB(255, 80, 80)
            return
        end
        
        if not alreadyUsed then
            MarkVipUsed(input)
        end
        
        if rememberState then
            SaveRememberedKey(input, "VIP")
        else
            ClearRememberedKey()
        end
        
        AcceptAndLoad("✓ VIP KEY ACCEPTED — LIFETIME")
        return
    end
    
    -- ── FREE KEY ──────────────────────────────────────────────
    if isFree then
        local savedFree, expireTime = LoadFreeKey()
        
        -- Already have this free key saved and still valid
        if savedFree and string.upper(savedFree) == input and expireTime then
            if os.time() > expireTime then
                StatusTxt.Text = "✗ FREEKEY EXPIRED (12H) — GET A NEW ONE"
                StatusTxt.TextColor3 = Color3.fromRGB(255, 80, 80)
                ClearFreeKey()
                return
            end
            if rememberState then
                SaveRememberedKey(input, "FREE")
            end
            local leftH = math.floor((expireTime - os.time()) / 3600)
            local leftM = math.floor(((expireTime - os.time()) % 3600) / 60)
            AcceptAndLoad("✓ FREEKEY ACCEPTED — " .. leftH .. "h " .. leftM .. "m LEFT")
            return
        end
        
        -- New free key → save with 12h expiry
        local newExpire = os.time() + (FREE_EXPIRE_H * 3600)
        SaveFreeKey(input, newExpire)
        
        if rememberState then
            SaveRememberedKey(input, "FREE")
        else
            ClearRememberedKey()
        end
        
        AcceptAndLoad("✓ FREEKEY ACCEPTED — 12 HOURS")
        return
    end
end

EnterBtn.MouseButton1Click:Connect(CheckKey)
KeyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then CheckKey() end
end)

-- Auto-login if a remembered key is still valid
task.spawn(function()
    task.wait(0.15)
    local remembered, remType = LoadRememberedKey()
    
    if remembered and remType == "VIP" and VIP_KEYS[remembered] then
        KeyGui:Destroy()
        loadMain()
        return
    end
    
    if remembered and remType == "FREE" then
        local savedFree, expireTime = LoadFreeKey()
        if savedFree and string.upper(savedFree) == remembered and expireTime and os.time() < expireTime then
            KeyGui:Destroy()
            loadMain()
            return
        else
            -- free key expired
            ClearRememberedKey()
            ClearFreeKey()
        end
    end
    
    -- Show status
    local left = 25 - CountUsedVips()
    if left <= 0 then
        StatusTxt.Text = "ALL VIP KEYS USED  •  FREEKEY STILL AVAILABLE"
        StatusTxt.TextColor3 = Color3.fromRGB(255, 180, 80)
    else
        StatusTxt.Text = left .. " VIP LEFT  •  FREEKEY = 12H"
        StatusTxt.TextColor3 = Color3.fromRGB(140, 200, 255)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- MAIN SCRIPT
-- ═══════════════════════════════════════════════════════════════

function loadMain()

local CFG = {
    aimbot = {
        enabled     = true,
        bone        = "Head",
        smooth      = 0.35,
        fov         = 120,
        predict     = true,
        predict_str = 0.09,
        team_check  = true,
        wall_check  = false,
        silent      = true,
        auto_shoot  = true,
        draw_fov    = true,
    },
    esp = {
        enabled     = false,
        boxes       = true,
        names       = true,
        health      = true,
        distance    = true,
        chams       = true,
        chams_color = Color3.fromRGB(160, 50, 255),
        team_check  = true,
    },
    fps = {
        booster     = false,
        show_fps    = true,
    },
}

local FovCircle = Drawing.new("Circle")
FovCircle.Filled = false
FovCircle.Thickness = 1.5
FovCircle.NumSides = 64
FovCircle.Color = Color3.fromRGB(170, 60, 255)
FovCircle.Transparency = 0.55
FovCircle.Radius = CFG.aimbot.fov
FovCircle.Visible = false

local LockLine = Drawing.new("Line")
LockLine.Thickness = 1.4
LockLine.Color = Color3.fromRGB(255, 60, 80)
LockLine.Transparency = 0.3
LockLine.Visible = false

local LockDot = Drawing.new("Circle")
LockDot.Filled = true
LockDot.Radius = 5
LockDot.Color = Color3.fromRGB(255, 60, 80)
LockDot.Transparency = 0
LockDot.Visible = false

local ACCENT   = Color3.fromRGB(155, 40, 255)
local BG       = Color3.fromRGB(8, 6, 14)
local CARD     = Color3.fromRGB(14, 10, 22)
local TXT      = Color3.fromRGB(235, 230, 245)
local TXT_DIM  = Color3.fromRGB(150, 130, 180)
local WHITE    = Color3.fromRGB(255, 255, 255)
local GREEN    = Color3.fromRGB(50, 230, 120)

pcall(function()
    local old = CoreGui:FindFirstChild("CLOUDBOT_GUI")
    if old then old:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CLOUDBOT_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
pcall(function() ScreenGui.Parent = CoreGui end)

local function Corner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = p
end

local function Stroke(p, color, thick)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(90, 40, 160)
    s.Thickness = thick or 1.2
    s.Parent = p
end

local function Lbl(parent, text, size, bold, color, pos, sz, xa)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = size
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.GothamSemibold
    l.TextColor3 = color
    l.Position = pos or UDim2.new(0,0,0,0)
    l.Size = sz or UDim2.new(1,0,1,0)
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local WIN_W, WIN_H = 520, 430

local Win = Instance.new("Frame", ScreenGui)
Win.Size = UDim2.new(0, WIN_W, 0, WIN_H)
Win.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
Win.BackgroundColor3 = BG
Win.BorderSizePixel = 0
Win.Active = true
Win.Draggable = false
Corner(10, Win)
Stroke(Win, Color3.fromRGB(120, 40, 220), 2)

local TopLine = Instance.new("Frame", Win)
TopLine.Size = UDim2.new(1, 0, 0, 4)
TopLine.BackgroundColor3 = ACCENT
TopLine.BorderSizePixel = 0
Corner(10, TopLine)

local Header = Instance.new("Frame", Win)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundTransparency = 1
Header.Active = true
Header.ZIndex = 2

local LogoBg = Instance.new("Frame", Header)
LogoBg.Size = UDim2.new(0, 30, 0, 30)
LogoBg.Position = UDim2.new(0, 14, 0.5, -15)
LogoBg.BackgroundColor3 = ACCENT
LogoBg.BorderSizePixel = 0
Corner(8, LogoBg)
Lbl(LogoBg, "⚡", 16, true, WHITE, UDim2.new(0,0,0,0), UDim2.new(1,0,1,0), Enum.TextXAlignment.Center)

Lbl(Header, "CLOUDBOT", 19, true, WHITE, UDim2.new(0, 52, 0, 7), UDim2.new(0.5, 0, 0, 22))
Lbl(Header, "MOBILE ONLY  •  ENERGY", 10, true, ACCENT, UDim2.new(0, 52, 0, 28), UDim2.new(0.5, 0, 0, 14))

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 28, 0, 24)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 15, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"
CloseBtn.TextColor3 = TXT
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
Corner(5, CloseBtn)

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 28, 0, 24)
MinBtn.Position = UDim2.new(1, -70, 0.5, -12)
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 15, 50)
MinBtn.BorderSizePixel = 0
MinBtn.Text = "–"
MinBtn.TextColor3 = TXT
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
Corner(5, MinBtn)

local draggingWindow, dragStart, startPos = false, nil, nil
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = true
        dragStart = input.Position
        startPos = Win.Position
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local TabBar = Instance.new("Frame", Win)
TabBar.Size = UDim2.new(1, -20, 0, 36)
TabBar.Position = UDim2.new(0, 10, 0, 56)
TabBar.BackgroundColor3 = Color3.fromRGB(12, 8, 20)
TabBar.BorderSizePixel = 0
Corner(8, TabBar)
TabBar.ZIndex = 2

local tabs = {}
local function CreateTab(name, icon, x)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, 155, 0, 28)
    btn.Position = UDim2.new(0, x, 0.5, -14)
    btn.BackgroundColor3 = Color3.fromRGB(25, 15, 45)
    btn.BorderSizePixel = 0
    btn.Text = icon .. "  " .. name
    btn.TextColor3 = TXT_DIM
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    Corner(6, btn)
    tabs[name] = btn
    return btn
end

local TabAimbot = CreateTab("AIMBOT", "⚡", 6)
local TabESP    = CreateTab("ESP / CHAMS", "◉", 168)
local TabFPS    = CreateTab("FPS TOOLS", "☰", 330)

local Content = Instance.new("Frame", Win)
Content.Size = UDim2.new(1, -20, 0, 280)
Content.Position = UDim2.new(0, 10, 0, 100)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.ZIndex = 2

local pages = {}
local function CreatePage(name)
    local page = Instance.new("Frame", Content)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    pages[name] = page
    return page
end

local PageAimbot = CreatePage("Aimbot")
local PageESP    = CreatePage("ESP / CHAMS")
local PageFPS    = CreatePage("FPS TOOLS")

local function SwitchTab(name)
    for n, btn in pairs(tabs) do
        if n == name then
            btn.BackgroundColor3 = ACCENT
            btn.TextColor3 = WHITE
        else
            btn.BackgroundColor3 = Color3.fromRGB(25, 15, 45)
            btn.TextColor3 = TXT_DIM
        end
    end
    for n, page in pairs(pages) do page.Visible = (n == name) end
end

TabAimbot.MouseButton1Click:Connect(function() SwitchTab("Aimbot") end)
TabESP.MouseButton1Click:Connect(function() SwitchTab("ESP / CHAMS") end)
TabFPS.MouseButton1Click:Connect(function() SwitchTab("FPS TOOLS") end)
SwitchTab("Aimbot")

local StatusBar = Instance.new("Frame", Win)
StatusBar.Size = UDim2.new(1, 0, 0, 34)
StatusBar.Position = UDim2.new(0, 0, 1, -34)
StatusBar.BackgroundColor3 = Color3.fromRGB(12, 6, 22)
StatusBar.BorderSizePixel = 0
StatusBar.ZIndex = 2

local StatusDot = Instance.new("Frame", StatusBar)
StatusDot.Size = UDim2.new(0, 9, 0, 9)
StatusDot.Position = UDim2.new(0, 14, 0.5, -4.5)
StatusDot.BackgroundColor3 = Color3.fromRGB(80, 70, 100)
StatusDot.BorderSizePixel = 0
Corner(5, StatusDot)

local StatusLbl = Lbl(StatusBar, "READY", 12, true, WHITE, UDim2.new(0, 30, 0, 0), UDim2.new(0.5, 0, 1, 0))
Lbl(StatusBar, "CLOUDBOT  |  MOBILE", 10, true, ACCENT, UDim2.new(0.42, 0, 0, 0), UDim2.new(0.58, -12, 1, 0), Enum.TextXAlignment.Right)

local function MakeCard(parent, title, icon, x, y, w, h)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(0, w, 0, h)
    card.Position = UDim2.new(0, x, 0, y)
    card.BackgroundColor3 = CARD
    card.BorderSizePixel = 0
    Corner(8, card)
    Stroke(card, Color3.fromRGB(70, 30, 130), 1.2)
    Lbl(card, icon .. "  " .. title, 12, true, TXT, UDim2.new(0, 12, 0, 8), UDim2.new(1, -16, 0, 18))
    return card
end

local function MakeToggle(parent, label, default, y, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -16, 0, 28)
    row.Position = UDim2.new(0, 8, 0, y)
    row.BackgroundTransparency = 1
    Lbl(row, label, 12, false, TXT, UDim2.new(0, 4, 0, 0), UDim2.new(1, -50, 1, 0))
    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(0, 38, 0, 20)
    track.Position = UDim2.new(1, -42, 0.5, -10)
    track.BackgroundColor3 = default and ACCENT or Color3.fromRGB(40, 30, 60)
    track.BorderSizePixel = 0
    Corner(10, track)
    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.BackgroundColor3 = WHITE
    knob.BorderSizePixel = 0
    Corner(8, knob)
    knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    local state = default
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.MouseButton1Click:Connect(function()
        state = not state
        track.BackgroundColor3 = state and ACCENT or Color3.fromRGB(40, 30, 60)
        knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        callback(state)
    end)
end

local function MakeSlider(parent, label, mn, mx, def, y, callback, isFloat)
    local con = Instance.new("Frame", parent)
    con.Size = UDim2.new(1, -16, 0, 48)
    con.Position = UDim2.new(0, 8, 0, y)
    con.BackgroundTransparency = 1
    Lbl(con, label, 11, false, TXT_DIM, UDim2.new(0, 4, 0, 0), UDim2.new(0.7, 0, 0, 16))
    local valLbl = Lbl(con, isFloat and string.format("%.2f", def) or tostring(def), 11, true, ACCENT,
        UDim2.new(0.7, 0, 0, 0), UDim2.new(0.3, -4, 0, 16), Enum.TextXAlignment.Right)
    local track = Instance.new("Frame", con)
    track.Size = UDim2.new(1, -8, 0, 5)
    track.Position = UDim2.new(0, 4, 0, 28)
    track.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
    track.BorderSizePixel = 0
    Corner(3, track)
    local pct = (def - mn) / (mx - mn)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = ACCENT
    fill.BorderSizePixel = 0
    Corner(3, fill)
    local thumb = Instance.new("Frame", track)
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.Position = UDim2.new(pct, -7, 0.5, -7)
    thumb.BackgroundColor3 = WHITE
    thumb.BorderSizePixel = 0
    Corner(7, thumb)
    local dragging = false
    thumb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    RunService.RenderStepped:Connect(function()
        if not dragging or track.AbsoluteSize.X == 0 then return end
        local mp = UserInputService:GetMouseLocation()
        local rel = math.clamp((mp.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = mn + rel * (mx - mn)
        if not isFloat then val = math.floor(val) end
        fill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, -7, 0.5, -7)
        valLbl.Text = isFloat and string.format("%.2f", val) or tostring(val)
        callback(val)
    end)
end

local leftCard = MakeCard(PageAimbot, "AIMBOT SETTINGS", "⚡", 0, 0, 245, 150)
MakeToggle(leftCard, "Enable Aimbot", CFG.aimbot.enabled, 32, function(v) CFG.aimbot.enabled = v end)
MakeToggle(leftCard, "Team Check", CFG.aimbot.team_check, 64, function(v) CFG.aimbot.team_check = v end)
MakeToggle(leftCard, "Head Priority", true, 96, function(v) CFG.aimbot.bone = v and "Head" or "HumanoidRootPart" end)

local fovCard = MakeCard(PageAimbot, "FOV SETTINGS", "◉", 0, 160, 245, 110)
MakeSlider(fovCard, "FOV Radius", 40, 400, CFG.aimbot.fov, 32, function(v) CFG.aimbot.fov = v FovCircle.Radius = v end, false)
MakeToggle(fovCard, "Draw FOV Circle", CFG.aimbot.draw_fov, 78, function(v) CFG.aimbot.draw_fov = v end)

local smoothCard = MakeCard(PageAimbot, "SMOOTHNESS", "☰", 255, 0, 245, 110)
Lbl(smoothCard, "How smooth the aimbot locks on target.", 10, false, TXT_DIM, UDim2.new(0, 12, 0, 30), UDim2.new(1, -20, 0, 16))
MakeSlider(smoothCard, "", 0.05, 1, CFG.aimbot.smooth, 50, function(v) CFG.aimbot.smooth = v end, true)

local extraCard = MakeCard(PageAimbot, "EXTRA OPTIONS", "★", 255, 120, 245, 150)
MakeToggle(extraCard, "Silent Aim", CFG.aimbot.silent, 32, function(v) CFG.aimbot.silent = v end)
MakeToggle(extraCard, "Auto Shoot", CFG.aimbot.auto_shoot, 64, function(v) CFG.aimbot.auto_shoot = v end)
MakeToggle(extraCard, "Prediction", CFG.aimbot.predict, 96, function(v) CFG.aimbot.predict = v end)

local espCard = MakeCard(PageESP, "ESP / CHAMS", "◉", 0, 0, 500, 260)
MakeToggle(espCard, "Enable ESP", false, 36, function(v) CFG.esp.enabled = v end)
MakeToggle(espCard, "Boxes", true, 70, function(v) CFG.esp.boxes = v end)
MakeToggle(espCard, "Names", true, 104, function(v) CFG.esp.names = v end)
MakeToggle(espCard, "Health Bars", true, 138, function(v) CFG.esp.health = v end)
MakeToggle(espCard, "Distance", true, 172, function(v) CFG.esp.distance = v end)
MakeToggle(espCard, "Chams (Highlight)", true, 206, function(v) CFG.esp.chams = v end)

local fpsCard = MakeCard(PageFPS, "FPS TOOLS", "☰", 0, 0, 500, 180)
MakeToggle(fpsCard, "Show FPS Counter", true, 36, function(v) CFG.fps.show_fps = v end)
MakeToggle(fpsCard, "Enable FPS Booster", false, 70, function(v)
    CFG.fps.booster = v
    if v then
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            for _, fx in ipairs(Lighting:GetChildren()) do
                if fx:IsA("BlurEffect") or fx:IsA("SunRaysEffect") or fx:IsA("BloomEffect") or fx:IsA("ColorCorrectionEffect") then fx.Enabled = false end
            end
        end)
    else
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            Lighting.GlobalShadows = true
        end)
    end
end)

local FpsInfo = Lbl(fpsCard, "Current FPS: --", 14, true, ACCENT, UDim2.new(0, 14, 0, 120), UDim2.new(1, -20, 0, 24))

local FpsGui = Instance.new("TextLabel", ScreenGui)
FpsGui.Size = UDim2.new(0, 100, 0, 24)
FpsGui.Position = UDim2.new(0, 8, 0, 8)
FpsGui.BackgroundColor3 = BG
FpsGui.BackgroundTransparency = 0.15
FpsGui.TextColor3 = GREEN
FpsGui.TextSize = 13
FpsGui.Font = Enum.Font.GothamBold
FpsGui.Text = "FPS: --"
FpsGui.Visible = true
Corner(6, FpsGui)
Stroke(FpsGui, ACCENT, 1)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    TabBar.Visible = not minimized
    StatusBar.Visible = not minimized
    Win.Size = minimized and UDim2.new(0, WIN_W, 0, 54) or UDim2.new(0, WIN_W, 0, WIN_H)
    MinBtn.Text = minimized and "+" or "–"
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    FovCircle.Visible = false
    LockLine.Visible = false
    LockDot.Visible = false
end)

local ESPObjects = {}
local function ClearESP(player)
    local data = ESPObjects[player]
    if not data then return end
    for _, obj in pairs(data) do
        if typeof(obj) == "Instance" then obj:Destroy()
        elseif typeof(obj) == "table" and obj.Remove then obj:Remove() end
    end
    ESPObjects[player] = nil
end

local function CreateESP(player)
    if ESPObjects[player] then return end
    local data = {}
    local box = Drawing.new("Square")
    box.Thickness = 1.3
    box.Filled = false
    box.Color = ACCENT
    box.Transparency = 0.75
    box.Visible = false
    data.box = box
    local name = Drawing.new("Text")
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Color = WHITE
    name.Visible = false
    data.name = name
    local dist = Drawing.new("Text")
    dist.Size = 12
    dist.Center = true
    dist.Outline = true
    dist.Color = TXT_DIM
    dist.Visible = false
    data.dist = dist
    local hbg = Drawing.new("Square")
    hbg.Filled = true
    hbg.Color = Color3.fromRGB(25, 20, 35)
    hbg.Visible = false
    data.hbg = hbg
    local hfill = Drawing.new("Square")
    hfill.Filled = true
    hfill.Color = GREEN
    hfill.Visible = false
    data.hfill = hfill
    local char = player.Character
    if char then
        local hl = Instance.new("Highlight")
        hl.FillColor = CFG.esp.chams_color
        hl.OutlineColor = Color3.fromRGB(200, 100, 255)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0.15
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = false
        hl.Parent = char
        data.chams = hl
    end
    ESPObjects[player] = data
end

local PrevPos = {}
local function Predicted(part, player)
    local id = player.UserId
    local cur = part.Position
    if PrevPos[id] then
        local vel = (cur - PrevPos[id]) / 0.016
        PrevPos[id] = cur
        return cur + vel * CFG.aimbot.predict_str
    end
    PrevPos[id] = cur
    return cur
end

local function IsTeammate(player, check)
    if not check then return false end
    if LP.Team == nil or player.Team == nil then return false end
    return LP.Team == player.Team
end

local function GetClosestTarget()
    local best, bestDist, bestPlayer = nil, math.huge, nil
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if IsTeammate(p, CFG.aimbot.team_check) then continue end
        local char = p.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = char:FindFirstChild(CFG.aimbot.bone) or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if dist <= CFG.aimbot.fov and dist < bestDist then
            best = part
            bestDist = dist
            bestPlayer = p
        end
    end
    return best, bestDist, bestPlayer
end

local fpsCounter, fpsLast, currentFps = 0, tick(), 60

RunService.RenderStepped:Connect(function()
    fpsCounter = fpsCounter + 1
    if tick() - fpsLast >= 1 then
        currentFps = fpsCounter
        fpsCounter = 0
        fpsLast = tick()
        FpsInfo.Text = "Current FPS: " .. currentFps
        FpsGui.Text = "FPS: " .. currentFps
        FpsGui.TextColor3 = currentFps >= 50 and GREEN or (currentFps >= 30 and Color3.fromRGB(255,200,50) or Color3.fromRGB(230,60,60))
    end
    FpsGui.Visible = CFG.fps.show_fps

    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FovCircle.Position = center
    FovCircle.Visible = CFG.aimbot.enabled and CFG.aimbot.draw_fov

    if CFG.aimbot.enabled then
        local target, _, tPlayer = GetClosestTarget()
        if target and tPlayer then
            local aimPos = CFG.aimbot.predict and Predicted(target, tPlayer) or target.Position
            local sp, onScreen = Camera:WorldToViewportPoint(aimPos)
            if onScreen then
                if not CFG.aimbot.silent then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, aimPos), CFG.aimbot.smooth)
                end
                LockLine.From = center
                LockLine.To = Vector2.new(sp.X, sp.Y)
                LockLine.Visible = true
                LockDot.Position = Vector2.new(sp.X, sp.Y)
                LockDot.Visible = true
                StatusLbl.Text = "LOCKED  →  " .. tPlayer.Name
                StatusDot.BackgroundColor3 = GREEN
            else
                LockLine.Visible = false
                LockDot.Visible = false
            end
        else
            LockLine.Visible = false
            LockDot.Visible = false
            StatusLbl.Text = "SCANNING..."
            StatusDot.BackgroundColor3 = Color3.fromRGB(220, 180, 40)
        end
    else
        LockLine.Visible = false
        LockDot.Visible = false
        StatusLbl.Text = "READY"
        StatusDot.BackgroundColor3 = Color3.fromRGB(80, 70, 100)
    end

    if CFG.esp.enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LP then continue end
            if IsTeammate(p, CFG.esp.team_check) then ClearESP(p) continue end
            local char = p.Character
            if not char then ClearESP(p) continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if not hum or not root or hum.Health <= 0 then ClearESP(p) continue end
            if not ESPObjects[p] then CreateESP(p) end
            local data = ESPObjects[p]
            if not data then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if not onScreen then
                data.box.Visible = false
                data.name.Visible = false
                data.dist.Visible = false
                data.hbg.Visible = false
                data.hfill.Visible = false
                if data.chams then data.chams.Enabled = false end
                continue
            end
            local size = 2000 / pos.Z
            local h, w = size * 1.8, size
            if CFG.esp.boxes then
                data.box.Size = Vector2.new(w, h)
                data.box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
                data.box.Visible = true
            else data.box.Visible = false end
            if CFG.esp.names then
                data.name.Text = p.Name
                data.name.Position = Vector2.new(pos.X, pos.Y - h/2 - 16)
                data.name.Visible = true
            else data.name.Visible = false end
            if CFG.esp.distance then
                data.dist.Text = math.floor((root.Position - Camera.CFrame.Position).Magnitude) .. "m"
                data.dist.Position = Vector2.new(pos.X, pos.Y + h/2 + 4)
                data.dist.Visible = true
            else data.dist.Visible = false end
            if CFG.esp.health then
                local hpPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                data.hbg.Size = Vector2.new(3, h)
                data.hbg.Position = Vector2.new(pos.X - w/2 - 6, pos.Y - h/2)
                data.hbg.Visible = true
                data.hfill.Size = Vector2.new(3, h * hpPct)
                data.hfill.Position = Vector2.new(pos.X - w/2 - 6, pos.Y - h/2 + h*(1-hpPct))
                data.hfill.Color = Color3.fromRGB(255*(1-hpPct), 255*hpPct, 40)
                data.hfill.Visible = true
            else
                data.hbg.Visible = false
                data.hfill.Visible = false
            end
            if data.chams then
                data.chams.Enabled = CFG.esp.chams
                if not data.chams.Parent then data.chams.Parent = char end
            end
        end
    else
        for p in pairs(ESPObjects) do ClearESP(p) end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    ClearESP(p)
    PrevPos[p.UserId] = nil
end)

LP.CharacterRemoving:Connect(function() PrevPos = {} end)

print("[CLOUDBOT] Key accepted — Main loaded")

end -- end loadMain
