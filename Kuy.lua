-- [[ GODSTEAM HUB V2 - AUTO FARM AMMO (FIXED COLLECTION) ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- ===== 1. CONFIG & STATES =====
local Toggles = { AutoFarmAmmo = false }
local script_running = true

-- ===== 2. UI CONSTRUCTION =====
local gui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
gui.Name = "Godsteam_Farm_Fixed"; gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(240, 180); main.Position = UDim2.new(0.5, -120, 0.5, -90)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 18); main.Active = true; main.Draggable = true
Instance.new("UICorner", main); local mainStroke = Instance.new("UIStroke", main); mainStroke.Thickness = 2

local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 30); topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35); Instance.new("UICorner", topBar)
local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -40, 1, 0); title.Position = UDim2.new(0, 10, 0, 0); title.BackgroundTransparency = 1; 
title.Text = "GODSTEAM - AMMO FIX"; title.TextColor3 = Color3.new(1, 1, 1); title.TextSize = 13; title.Font = Enum.Font.GothamBold; title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", topBar)
minBtn.Size = UDim2.fromOffset(25, 25); minBtn.Position = UDim2.new(1, -27, 0, 2.5); minBtn.Text = "X"; minBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50); minBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", minBtn)

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.fromOffset(65, 30); openBtn.Position = UDim2.new(0.05, 0, 0.4, 0); openBtn.Text = "OPEN/เปิด"; openBtn.Visible = false; openBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30); openBtn.TextColor3 = Color3.new(1, 1, 1); openBtn.Draggable = true; Instance.new("UICorner", openBtn)

minBtn.MouseButton1Click:Connect(function() main.Visible = false; openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function() main.Visible = true; openBtn.Visible = false end)

local container = Instance.new("ScrollingFrame", main)
container.Size = UDim2.new(1, -10, 1, -45); container.Position = UDim2.new(0, 5, 0, 35); container.BackgroundTransparency = 1; container.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", container); layout.Padding = UDim.new(0, 5)

-- Helpers
local function addToggle(eng, thai, id)
    local b = Instance.new("TextButton", container); b.Size = UDim2.new(1, -5, 0, 38); b.Text = eng .. "\n(" .. thai .. ") : OFF"; b.BackgroundColor3 = Color3.fromRGB(35, 35, 40); b.TextColor3 = Color3.new(0.8, 0.8, 0.8); b.TextSize = 10; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() 
        Toggles[id] = not Toggles[id]
        b.Text = eng .. "\n(" .. thai .. ") : " .. (Toggles[id] and "ON/เปิด" or "OFF/ปิด")
        b.TextColor3 = Toggles[id] and Color3.new(0, 1, 0) or Color3.new(0.8, 0.8, 0.8) 
    end)
end

local function addBtn(eng, thai, color, cb)
    local b = Instance.new("TextButton", container); b.Size = UDim2.new(1, -5, 0, 38); b.Text = eng .. "\n(" .. thai .. ")"; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); b.TextSize = 10; Instance.new("UICorner", b); b.MouseButton1Click:Connect(cb)
end

-- ===== 3. BUTTONS =====
addToggle("Auto Farm Ammo", "ฟาร์มกระสุนอัตโนมัติ", "AutoFarmAmmo")
addBtn("Unload Script", "ลบสคริปต์", Color3.fromRGB(150, 0, 0), function() script_running = false; gui:Destroy() end)

-- ===== 4. IMPROVED COLLECTION LOGIC =====
task.spawn(function()
    while script_running do
        if Toggles.AutoFarmAmmo then
            pcall(function()
                local char = Player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- หาโมเดลกระสุนที่ใกล้ที่สุด
                local targetAmmo = nil
                local lastDist = math.huge
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v.Name == "Ammo" then
                        local part = v:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local d = (hrp.Position - part.Position).Magnitude
                            if d < lastDist then
                                lastDist = d
                                targetAmmo = v
                            end
                        end
                    end
                end

                if targetAmmo then
                    local part = targetAmmo:FindFirstChildWhichIsA("BasePart")
                    local prompt = targetAmmo:FindFirstChildOfClass("ProximityPrompt") or targetAmmo:FindFirstChildWhichIsA("ProximityPrompt", true)
                    
                    if part and prompt then
                        -- วาร์ปไปที่ตำแหน่งกระสุน (ปรับให้ตรงกลางพอดี)
                        hrp.CFrame = part.CFrame
                        task.wait(0.1) -- รอให้ตำแหน่งนิ่ง

                        -- ตั้งค่า Prompt ให้เก็บไวขึ้น
                        prompt.HoldDuration = 0
                        
                        -- ระบบย้ำการเก็บ (Fire 3 ครั้งกันพลาด)
                        for i = 1, 3 do
                            if not targetAmmo.Parent then break end -- ถ้าหายไปแล้วหยุดกด
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                prompt:InputHoldBegin()
                                task.wait(0.05)
                                prompt:InputHoldEnd()
                            end
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end
        task.wait(0.5) -- หน่วงเวลาเล็กน้อยเพื่อป้องกันเกมหลุด
    end
end)

-- Rainbow Effect
RunService.RenderStepped:Connect(function()
    if not script_running then return end
    local rainbow = Color3.fromHSV(tick() * 0.3 % 1, 0.7, 1)
    mainStroke.Color = rainbow; title.TextColor3 = rainbow
end)
