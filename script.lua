-- [[ GODSTEAM HUB V2 - ORIGINAL STYLE WITH CUSTOM SPEED ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ===== 1. CONFIG & STATES =====
local Toggles = { 
    AutoKill = false, PlayerESP = false, AmmoESP = false, 
    AutoFarmAmmo = false, InfiniteTP = false, FollowPlayer = false,
    ShowTracers = false
}
local AmmoESP_Storage = {}
local PlayerESP_Storage = {}
local script_running = true

-- ===== 2. UI CONSTRUCTION =====
local gui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
gui.Name = "Godsteam_V2_Original_Fixed"; gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(200, 280); main.Position = UDim2.new(0.5, -100, 0.5, -140)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 18); main.Active = true; main.Draggable = true
Instance.new("UICorner", main); local mainStroke = Instance.new("UIStroke", main); mainStroke.Thickness = 2

-- Header
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 30); topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35); Instance.new("UICorner", topBar)
local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -40, 1, 0); title.Position = UDim2.new(0, 10, 0, 0); title.BackgroundTransparency = 1; title.Text = "GODSTEAM HUB V2"; title.TextColor3 = Color3.new(1, 1, 1); title.TextSize = 12; title.Font = Enum.Font.GothamBold; title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", topBar)
minBtn.Size = UDim2.fromOffset(25, 25); minBtn.Position = UDim2.new(1, -27, 0, 2.5); minBtn.Text = "X"; minBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50); minBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", minBtn)
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.fromOffset(50, 50); openBtn.Position = UDim2.new(0.05, 0, 0.4, 0); openBtn.Text = "V2"; openBtn.Visible = false; openBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30); openBtn.TextColor3 = Color3.new(1, 1, 1); openBtn.Draggable = true; Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
minBtn.MouseButton1Click:Connect(function() main.Visible = false; openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function() main.Visible = true; openBtn.Visible = false end)

-- Page System
local pageContainer = Instance.new("Frame", main)
pageContainer.Size = UDim2.new(1, -10, 1, -75); pageContainer.Position = UDim2.new(0, 5, 0, 35); pageContainer.BackgroundTransparency = 1
local pages = {}
local function createPage(name)
    local f = Instance.new("ScrollingFrame", pageContainer); f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 1; f.ScrollBarThickness = 2; f.Visible = false
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 4); pages[name] = f; return f
end
local pCombat = createPage("Combat"); pCombat.Visible = true
local pFarm = createPage("Farm"); local pVisual = createPage("Visual"); local pMore = createPage("More")

local function addTab(txt, pageObj, posX)
    local b = Instance.new("TextButton", main); b.Size = UDim2.new(0.25, 0, 0, 30); b.Position = UDim2.new(posX, 0, 1, -30)
    b.Text = txt; b.TextColor3 = Color3.new(1, 1, 1); b.BackgroundColor3 = Color3.fromRGB(25, 25, 30); b.TextSize = 10
    b.MouseButton1Click:Connect(function() for _, p in pairs(pages) do p.Visible = false end pageObj.Visible = true end)
end
addTab("สู้", pCombat, 0); addTab("ฟาร์ม", pFarm, 0.25); addTab("มอง", pVisual, 0.5); addTab("อื่น", pMore, 0.75)

-- Helpers
local function addToggle(parent, txt, id)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, -5, 0, 28); b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(35, 35, 40); b.TextColor3 = Color3.new(0.7, 0.7, 0.7); b.TextSize = 10; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() Toggles[id] = not Toggles[id]; b.TextColor3 = Toggles[id] and Color3.new(0, 1, 0) or Color3.new(0.7, 0.7, 0.7) end)
end
local function addBtn(parent, txt, color, cb)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, -5, 0, 28); b.Text = txt; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); b.TextSize = 10; Instance.new("UICorner", b); b.MouseButton1Click:Connect(cb)
end

-- ===== 3. FILLING FUNCTIONS =====
addToggle(pCombat, "Auto Kill (ฟันรัว)", "AutoKill")
addToggle(pCombat, "ติดตามคน (Follow)", "FollowPlayer")
addBtn(pCombat, "แปลงร่างไททัน", Color3.fromRGB(120, 30, 30), function() pcall(function() ReplicatedStorage.Remoted.Titan.TransformarEV:FireServer("Colossus Titan", "Common", "ErenC", false) end) end)
addBtn(pCombat, "คืนร่างมนุษย์", Color3.fromRGB(45, 75, 140), function() pcall(function() ReplicatedStorage.Remoted.Titan.HumanEV:FireServer("AbacateAzul") end) end)

addToggle(pFarm, "ออโต้เก็บกระสุน", "AutoFarmAmmo")
addBtn(pFarm, "วาร์ปหา Ammo (TP)", Color3.fromRGB(0, 120, 200), function() for _, v in pairs(workspace:GetDescendants()) do if v:IsA("Model") and v.Name == "Ammo" then local p = v:FindFirstChildWhichIsA("BasePart") if p then Player.Character.HumanoidRootPart.CFrame = p.CFrame break end end end end)

addToggle(pVisual, "เปิด ESP ผู้เล่น", "PlayerESP")
addToggle(pVisual, "เปิด ESP กระสุน", "AmmoESP")
addToggle(pVisual, "เส้น Tracers", "ShowTracers")

addToggle(pMore, "Chaos Random TP", "InfiniteTP")

-- [[ ส่วนที่เพิ่มใหม่: ช่องพิมพ์ความเร็วแบบเรียบง่าย ]]
local speedInput = Instance.new("TextBox", pMore)
speedInput.Size = UDim2.new(1, -5, 0, 28); speedInput.PlaceholderText = "พิมพ์ความเร็วที่นี่..."; speedInput.Text = ""; speedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50); speedInput.TextColor3 = Color3.new(1, 1, 1); speedInput.TextSize = 10; Instance.new("UICorner", speedInput)

addBtn(pMore, "ยืนยันความเร็ว (Set)", Color3.fromRGB(0, 100, 0), function() 
    local s = tonumber(speedInput.Text)
    if s and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = s
    end
end)

addBtn(pMore, "ลบสคริปต์ (Unload)", Color3.fromRGB(150, 0, 0), function() script_running = false; for _, v in pairs(AmmoESP_Storage) do v:Remove() end; for _, v in pairs(PlayerESP_Storage) do v.T:Remove() v.L:Remove() end; gui:Destroy() end)

-- ===== 4. LOGIC ENGINE (เหมือนเดิมทุกประการ) =====
task.spawn(function()
    while script_running and task.wait(0.1) do
        pcall(function()
            local hrp = Player.Character.HumanoidRootPart
            if Toggles.AutoKill or Toggles.FollowPlayer then
                local target = nil; local dist = math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                        local d = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if d < dist then dist = d; target = p end
                    end
                end
                if target then
                    hrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2.5)
                    if Toggles.AutoKill then ReplicatedStorage.ODM.Remoted.Attack:FireServer({target.Character.HumanoidRootPart.CFrame}) end
                end
            end
            if Toggles.AutoFarmAmmo then
                local ammos = {}
                for _, v in pairs(workspace:GetDescendants()) do if v:IsA("Model") and v.Name == "Ammo" then table.insert(ammos, v) end end
                if #ammos > 0 then
                    local target = ammos[math.random(1, #ammos)]; local p = target:FindFirstChildWhichIsA("BasePart"); local pmt = target:FindFirstChildOfClass("ProximityPrompt") or target:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if p and pmt then
                        hrp.CFrame = p.CFrame; pmt.HoldDuration = 0; local retry = 0
                        while target.Parent and retry < 3 do if fireproximityprompt then fireproximityprompt(pmt) end pmt:InputHoldBegin(); pmt:InputHoldEnd(); task.wait(0.12); retry = retry + 1 end
                    end
                end
            end
        end)
    end
end)

-- RENDERING (เหมือนเดิมทุกประการ)
RunService.RenderStepped:Connect(function()
    if not script_running then return end
    local rainbow = Color3.fromHSV(tick() * 0.3 % 1, 0.7, 1)
    mainStroke.Color = rainbow; title.TextColor3 = rainbow

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            if not PlayerESP_Storage[p] then 
                PlayerESP_Storage[p] = {T = Drawing.new("Text"), L = Drawing.new("Line")}
                PlayerESP_Storage[p].T.Center = true; PlayerESP_Storage[p].T.Outline = true; PlayerESP_Storage[p].T.Size = 13
            end
            local comp = PlayerESP_Storage[p]
            if Toggles.PlayerESP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                local pos, on = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if on then
                    comp.T.Text = p.Name .. " [" .. math.floor(p.Character.Humanoid.Health) .. "]"
                    comp.T.Position = Vector2.new(pos.X, pos.Y - 40)
                    comp.T.Visible = true; comp.T.Color = Color3.new(1,1,1)
                    if Toggles.ShowTracers then
                        comp.L.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        comp.L.To = Vector2.new(pos.X, pos.Y)
                        comp.L.Visible = true; comp.L.Color = rainbow
                    else comp.L.Visible = false end
                else comp.T.Visible = false; comp.L.Visible = false end
            else
                comp.T.Visible = false; comp.L.Visible = false
            end
        end
    end

    if Toggles.AmmoESP then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Ammo" then
                local p = obj:FindFirstChildWhichIsA("BasePart")
                if p then
                    if not AmmoESP_Storage[obj] then 
                        local t = Drawing.new("Text"); t.Text = "[ AMMO ]"; t.Color = Color3.new(1, 1, 0); t.Size = 13; t.Outline = true; t.Center = true
                        AmmoESP_Storage[obj] = t
                    end
                    local pos, on = Camera:WorldToViewportPoint(p.Position)
                    AmmoESP_Storage[obj].Visible = on
                    if on then AmmoESP_Storage[obj].Position = Vector2.new(pos.X, pos.Y) end
                end
            end
        end
    else
        for _, v in pairs(AmmoESP_Storage) do v.Visible = false end
    end
end)
