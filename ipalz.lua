--[[
    XENO AUTO AIM HUB MODERN - PALZZ 👻
    Fitur: Auto Aim 0 Delay, ESP Box Name Presisi
    Toggle: ALT (tekan sekali start, tekan lagi stop)
    Creator: PALZZ 👻
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("PALZZ 👻 XENO HUB", "DarkTheme")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variabel global
local aimEnabled = false
local espEnabled = true
local selectedTarget = nil
local players = game:GetService("Players")

-- Tab menu
local CombatTab = Window:NewTab("Combat")
local CombatSection = CombatTab:NewSection("Auto Aim Settings")
local VisualTab = Window:NewTab("Visual")
local VisualSection = VisualTab:NewSection("ESP Settings")

-- Fungsi mendapatkan target terdekat
local function getClosestTarget()
    local closestDist = math.huge
    local closestPlayer = nil
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, v in pairs(players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local head = v.Character:FindFirstChild("Head")
            if head then
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = v
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- AUTO AIM 0 DELAY - MELEKAT SEMPURNA
local aimConnection
local function startAim()
    if aimConnection then aimConnection:Disconnect() end
    
    aimConnection = RunService.RenderStepped:Connect(function()
        if aimEnabled then
            local target = getClosestTarget()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local head = target.Character.Head
                camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
            end
        end
    end)
end

-- ESP BOX NAME - SESUAI BENTUK TUBUH (PRESISI)
local espConnections = {}
local function createESP(player)
    if player == game.Players.LocalPlayer then return end
    
    local function updateESP()
        if not espEnabled or not player.Character then return end
        
        local character = player.Character
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not rootPart or humanoid.Health <= 0 then return end
        
        -- Hitung ukuran box berdasarkan tinggi karakter
        local head = character:FindFirstChild("Head")
        local root = rootPart
        if head and root then
            local topPos, topOnScreen = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local bottomPos, bottomOnScreen = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2, 0))
            
            if topOnScreen and bottomOnScreen then
                local height = math.abs(topPos.Y - bottomPos.Y)
                local width = height * 0.6 -- Proporsi tubuh ideal
                
                -- Box outline
                local boxOutline = Drawing.new("Square")
                boxOutline.Visible = true
                boxOutline.Size = Vector2.new(width + 2, height + 2)
                boxOutline.Position = Vector2.new(topPos.X - width/2 - 1, topPos.Y - 1)
                boxOutline.Color = Color3.fromRGB(0, 0, 0)
                boxOutline.Thickness = 2
                boxOutline.Filled = false
                
                -- Box utama
                local box = Drawing.new("Square")
                box.Visible = true
                box.Size = Vector2.new(width, height)
                box.Position = Vector2.new(topPos.X - width/2, topPos.Y)
                box.Color = Color3.fromRGB(255, 0, 0)
                box.Thickness = 1
                box.Filled = false
                
                -- Nama player
                local nameText = Drawing.new("Text")
                nameText.Visible = true
                nameText.Text = player.Name
                nameText.Size = 16
                nameText.Position = Vector2.new(topPos.X - width/2, topPos.Y - 20)
                nameText.Color = Color3.fromRGB(255, 255, 255)
                nameText.Center = true
                nameText.Outline = true
                
                -- Cleanup function
                local conn
                conn = RunService.RenderStepped:Connect(function()
                    if not espEnabled or not player.Character or not humanoid or humanoid.Health <= 0 then
                        boxOutline:Remove()
                        box:Remove()
                        nameText:Remove()
                        conn:Disconnect()
                    end
                end)
                
                table.insert(espConnections, conn)
            end
        end
    end
    
    -- Run update when character loads
    if player.Character then
        updateESP()
    end
    
    player.CharacterAdded:Connect(updateESP)
end

-- Initialize ESP for all players
for _, v in pairs(players:GetPlayers()) do
    createESP(v)
end

players.PlayerAdded:Connect(createESP)

-- Toggle ALT untuk start/stop auto aim
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt then
        aimEnabled = not aimEnabled
        if aimEnabled then
            startAim()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "PALZZ 👻 HUB",
                Text = "Auto Aim: ON (ALT toggle)",
                Duration = 2
            })
        else
            if aimConnection then
                aimConnection:Disconnect()
                aimConnection = nil
            end
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "PALZZ 👻 HUB",
                Text = "Auto Aim: OFF",
                Duration = 2
            })
        end
    end
end)

-- GUI Controls
CombatSection:NewToggle("Auto Aim 0 Delay", "Toggle auto aim 0 delay (tekan ALT)", function(state)
    if not state then
        aimEnabled = false
        if aimConnection then
            aimConnection:Disconnect()
            aimConnection = nil
        end
    end
end)

CombatSection:NewKeybind("Toggle Key", "Ganti tombol toggle", Enum.KeyCode.LeftAlt, function()
    -- Default sudah ALT
end)

VisualSection:NewToggle("ESP Box Name", "Toggle ESP box dan nama", function(state)
    espEnabled = state
end)

VisualSection:NewColorPicker("Box Color", "Warna box ESP", Color3.fromRGB(255, 0, 0), function(color)
    -- Update warna box akan di-handle di loop
end)

-- Cleanup on script end
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "PALZZ_HUB" then
        if aimConnection then
            aimConnection:Disconnect()
        end
        for _, conn in pairs(espConnections) do
            conn:Disconnect()
        end
    end
end)

print("PALZZ 👻 HUB loaded - Tekan ALT untuk toggle auto aim")
