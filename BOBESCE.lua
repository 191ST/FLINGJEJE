-- Xeno Executor ESP Script
-- Fitur: Wallhack, Box ESP, Name ESP, Health ESP

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Xeno ESP V2", "DarkTheme")

-- Variabel ESP
local ESP = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Tab Utama
local MainTab = Window:NewTab("ESP Settings")
local MainSection = MainTab:NewSection("ESP Controls")

-- Status ESP
local espEnabled = false
local wallhackEnabled = false
local boxESP = false
local nameESP = false
local healthESP = false
local distanceESP = false
local tracerESP = false
local headDotESP = false
local skeletonESP = false

-- Warna
local colors = {
    enemy = Color3.fromRGB(255, 0, 0),
    team = Color3.fromRGB(0, 255, 0),
    wallhack = Color3.fromRGB(255, 255, 255)
}

-- Fungsi untuk membuat ESP
function ESP:Create(player)
    if player == LocalPlayer then return end
    
    -- Drawing objects
    local espObjects = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        health = Drawing.new("Text"),
        distance = Drawing.new("Text"),
        tracer = Drawing.new("Line"),
        head = Drawing.new("Circle"),
        skeleton = {}
    }
    
    -- Setup drawing properties
    espObjects.box.Visible = false
    espObjects.box.Color = colors.enemy
    espObjects.box.Thickness = 2
    espObjects.box.Filled = false
    
    espObjects.name.Visible = false
    espObjects.name.Color = Color3.fromRGB(255, 255, 255)
    espObjects.name.Center = true
    espObjects.name.Size = 16
    espObjects.name.Outline = true
    espObjects.name.Font = 3
    
    espObjects.health.Visible = false
    espObjects.health.Color = Color3.fromRGB(0, 255, 0)
    espObjects.health.Size = 14
    espObjects.health.Outline = true
    
    espObjects.distance.Visible = false
    espObjects.distance.Color = Color3.fromRGB(255, 255, 0)
    espObjects.distance.Size = 12
    espObjects.distance.Outline = true
    
    espObjects.tracer.Visible = false
    espObjects.tracer.Color = colors.enemy
    espObjects.tracer.Thickness = 1
    
    espObjects.head.Visible = false
    espObjects.head.Color = Color3.fromRGB(255, 0, 0)
    espObjects.head.Radius = 3
    espObjects.head.Filled = true
    espObjects.head.NumSides = 30
    
    -- Store in player
    player:SetAttribute("ESPDrawing", espObjects)
end

-- Fungsi update ESP
function ESP:Update()
    if not espEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            
            if humanoid and rootPart and head and humanoid.Health > 0 then
                -- Get screen position
                local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                local headPos, _ = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                
                if onScreen then
                    -- Hitung ukuran box
                    local boxHeight = math.abs(headPos.Y - rootPos.Y) * 1.5
                    local boxWidth = boxHeight * 0.6
                    
                    -- Dapatkan ESP objects
                    local espObjects = player:GetAttribute("ESPDrawing")
                    
                    if espObjects then
                        -- Wallhack / Through walls
                        local isVisible = true
                        if wallhackEnabled then
                            -- Wallhack membuat player terlihat tembus dinding
                            espObjects.box.Color = colors.wallhack
                        else
                            -- Cek visibility
                            local ray = Ray.new(Camera.CFrame.Position, (rootPart.Position - Camera.CFrame.Position).Unit * 1000)
                            local hit, _ = workspace:FindPartOnRay(ray, LocalPlayer.Character)
                            isVisible = (hit and hit:IsDescendantOf(player.Character)) or false
                            espObjects.box.Color = isVisible and colors.enemy or colors.team
                        end
                        
                        -- Box ESP
                        if boxESP then
                            espObjects.box.Visible = true
                            espObjects.box.Position = Vector2.new(rootPos.X - boxWidth/2, rootPos.Y - boxHeight/2)
                            espObjects.box.Size = Vector2.new(boxWidth, boxHeight)
                        else
                            espObjects.box.Visible = false
                        end
                        
                        -- Name ESP
                        if nameESP then
                            espObjects.name.Visible = true
                            espObjects.name.Position = Vector2.new(rootPos.X, rootPos.Y - boxHeight/2 - 20)
                            espObjects.name.Text = player.Name
                        else
                            espObjects.name.Visible = false
                        end
                        
                        -- Health ESP
                        if healthESP then
                            espObjects.health.Visible = true
                            espObjects.health.Position = Vector2.new(rootPos.X + boxWidth/2 + 5, rootPos.Y - boxHeight/2)
                            espObjects.health.Text = string.format("❤️ %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
                            
                            -- Warna berdasarkan health
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            if healthPercent > 0.6 then
                                espObjects.health.Color = Color3.fromRGB(0, 255, 0)
                            elseif healthPercent > 0.3 then
                                espObjects.health.Color = Color3.fromRGB(255, 255, 0)
                            else
                                espObjects.health.Color = Color3.fromRGB(255, 0, 0)
                            end
                        else
                            espObjects.health.Visible = false
                        end
                        
                        -- Distance ESP
                        if distanceESP then
                            espObjects.distance.Visible = true
                            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                            espObjects.distance.Position = Vector2.new(rootPos.X, rootPos.Y + boxHeight/2 + 15)
                            espObjects.distance.Text = string.format("📏 %dm", math.floor(dist))
                        else
                            espObjects.distance.Visible = false
                        end
                        
                        -- Tracer ESP
                        if tracerESP then
                            espObjects.tracer.Visible = true
                            espObjects.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            espObjects.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                        else
                            espObjects.tracer.Visible = false
                        end
                        
                        -- Head Dot ESP
                        if headDotESP then
                            espObjects.head.Visible = true
                            espObjects.head.Position = Vector2.new(headPos.X, headPos.Y)
                        else
                            espObjects.head.Visible = false
                        end
                        
                        -- Skeleton ESP
                        if skeletonESP and character:FindFirstChild("UpperTorso") then
                            -- Implementasi skeleton sederhana
                            local joints = {
                                {"Head", "UpperTorso"},
                                {"UpperTorso", "LowerTorso"},
                                {"UpperTorso", "LeftUpperArm"},
                                {"LeftUpperArm", "LeftLowerArm"},
                                {"LeftLowerArm", "LeftHand"},
                                {"UpperTorso", "RightUpperArm"},
                                {"RightUpperArm", "RightLowerArm"},
                                {"RightLowerArm", "RightHand"},
                                {"LowerTorso", "LeftUpperLeg"},
                                {"LeftUpperLeg", "LeftLowerLeg"},
                                {"LeftLowerLeg", "LeftFoot"},
                                {"LowerTorso", "RightUpperLeg"},
                                {"RightUpperLeg", "RightLowerLeg"},
                                {"RightLowerLeg", "RightFoot"}
                            }
                            
                            for i, joint in ipairs(joints) do
                                local part1 = character:FindFirstChild(joint[1])
                                local part2 = character:FindFirstChild(joint[2])
                                
                                if part1 and part2 then
                                    local pos1, _ = Camera:WorldToViewportPoint(part1.Position)
                                    local pos2, _ = Camera:WorldToViewportPoint(part2.Position)
                                    
                                    if not espObjects.skeleton[i] then
                                        espObjects.skeleton[i] = Drawing.new("Line")
                                        espObjects.skeleton[i].Thickness = 1
                                        espObjects.skeleton[i].Color = Color3.fromRGB(255, 255, 255)
                                    end
                                    
                                    espObjects.skeleton[i].Visible = true
                                    espObjects.skeleton[i].From = Vector2.new(pos1.X, pos1.Y)
                                    espObjects.skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                                elseif espObjects.skeleton[i] then
                                    espObjects.skeleton[i].Visible = false
                                end
                            end
                        else
                            for i = 1, 14 do
                                if espObjects.skeleton[i] then
                                    espObjects.skeleton[i].Visible = false
                                end
                            end
                        end
                    end
                else
                    -- Hide jika off screen
                    local espObjects = player:GetAttribute("ESPDrawing")
                    if espObjects then
                        espObjects.box.Visible = false
                        espObjects.name.Visible = false
                        espObjects.health.Visible = false
                        espObjects.distance.Visible = false
                        espObjects.tracer.Visible = false
                        espObjects.head.Visible = false
                        for i = 1, 14 do
                            if espObjects.skeleton[i] then
                                espObjects.skeleton[i].Visible = false
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Buat ESP untuk player yang sudah ada
for _, player in ipairs(Players:GetPlayers()) do
    ESP:Create(player)
end

-- Buat ESP untuk player baru
Players.PlayerAdded:Connect(function(player)
    ESP:Create(player)
end)

-- Hapus ESP ketika player leave
Players.PlayerRemoving:Connect(function(player)
    local espObjects = player:GetAttribute("ESPDrawing")
    if espObjects then
        espObjects.box:Remove()
        espObjects.name:Remove()
        espObjects.health:Remove()
        espObjects.distance:Remove()
        espObjects.tracer:Remove()
        espObjects.head:Remove()
        for _, line in ipairs(espObjects.skeleton) do
            line:Remove()
        end
    end
end)

-- Update loop
RunService.RenderStepped:Connect(function()
    ESP:Update()
end)

-- UI Toggles
MainSection:NewToggle("Enable ESP", "Turn on/off ESP", function(state)
    espEnabled = state
end)

MainSection:NewToggle("Wallhack (Tembus Dinding)", "See players through walls", function(state)
    wallhackEnabled = state
end)

MainSection:NewToggle("Box ESP", "Show boxes around players", function(state)
    boxESP = state
end)

MainSection:NewToggle("Name ESP", "Show player names", function(state)
    nameESP = state
end)

MainSection:NewToggle("Health ESP", "Show health bars/numbers", function(state)
    healthESP = state
end)

MainSection:NewToggle("Distance ESP", "Show distance to players", function(state)
    distanceESP = state
end)

MainSection:NewToggle("Tracer ESP", "Draw lines to players", function(state)
    tracerESP = state
end)

MainSection:NewToggle("Head Dot ESP", "Show dots on heads", function(state)
    headDotESP = state
end)

MainSection:NewToggle("Skeleton ESP", "Show player skeletons", function(state)
    skeletonESP = state
end)

-- Color settings
local ColorTab = Window:NewTab("Colors")
local ColorSection = ColorTab:NewSection("ESP Colors")

ColorSection:NewColorPicker("Enemy Color", "Color for enemies", Color3.fromRGB(255, 0, 0), function(color)
    colors.enemy = color
end)

ColorSection:NewColorPicker("Team Color", "Color for teammates", Color3.fromRGB(0, 255, 0), function(color)
    colors.team = color
end)

-- Notification
Library:Notify("Xeno ESP Loaded!", "Script by System Dark", 5)
