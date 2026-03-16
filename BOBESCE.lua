-- Xeno Executor ESP Simple Version
-- 100% Work untuk Xeno Executor

loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/Executor/main/ScriptHub.lua"))()

-- Atau pake script ESP murni tanpa library
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Table untuk menyimpan drawing objects
local ESP = {}
local ESPEnabled = true

-- Fungsi create ESP
function CreateESP(player)
    if player == LocalPlayer then return end
    
    ESP[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        Head = Drawing.new("Circle")
    }
    
    -- Box settings
    ESP[player].Box.Thickness = 2
    ESP[player].Box.Color = Color3.fromRGB(255, 0, 0)
    ESP[player].Box.Filled = false
    ESP[player].Box.Visible = true
    
    -- Name settings
    ESP[player].Name.Size = 16
    ESP[player].Name.Center = true
    ESP[player].Name.Color = Color3.fromRGB(255, 255, 255)
    ESP[player].Name.Outline = true
    ESP[player].Name.Visible = true
    
    -- Health settings
    ESP[player].Health.Size = 14
    ESP[player].Health.Color = Color3.fromRGB(0, 255, 0)
    ESP[player].Health.Outline = true
    ESP[player].Health.Visible = true
    
    -- Distance settings
    ESP[player].Distance.Size = 12
    ESP[player].Distance.Color = Color3.fromRGB(255, 255, 0)
    ESP[player].Distance.Outline = true
    ESP[player].Distance.Visible = true
    
    -- Tracer settings
    ESP[player].Tracer.Thickness = 1
    ESP[player].Tracer.Color = Color3.fromRGB(255, 0, 0)
    ESP[player].Tracer.Visible = true
    
    -- Head dot settings
    ESP[player].Head.Radius = 3
    ESP[player].Head.Color = Color3.fromRGB(255, 0, 0)
    ESP[player].Head.Filled = true
    ESP[player].Head.NumSides = 30
    ESP[player].Head.Visible = true
end

-- Loop update ESP
RunService.RenderStepped:Connect(function()
    if not ESPEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local humanoid = character.Humanoid
            local rootPart = character.HumanoidRootPart
            local head = character:FindFirstChild("Head")
            
            if humanoid.Health > 0 and head then
                local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                local headPos, _ = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                
                if onScreen then
                    if not ESP[player] then
                        CreateESP(player)
                    end
                    
                    local esp = ESP[player]
                    
                    -- Hitung box size
                    local boxHeight = math.abs(headPos.Y - rootPos.Y) * 1.5
                    local boxWidth = boxHeight * 0.6
                    
                    -- Update Box
                    esp.Box.Position = Vector2.new(rootPos.X - boxWidth/2, rootPos.Y - boxHeight/2)
                    esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                    
                    -- Update Name
                    esp.Name.Position = Vector2.new(rootPos.X, rootPos.Y - boxHeight/2 - 20)
                    esp.Name.Text = player.Name
                    
                    -- Update Health
                    esp.Health.Position = Vector2.new(rootPos.X + boxWidth/2 + 5, rootPos.Y - boxHeight/2)
                    esp.Health.Text = string.format("%d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
                    
                    -- Update Distance
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                    esp.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + boxHeight/2 + 15)
                    esp.Distance.Text = string.format("%dm", math.floor(dist))
                    
                    -- Update Tracer
                    esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                    
                    -- Update Head dot
                    esp.Head.Position = Vector2.new(headPos.X, headPos.Y)
                else
                    if ESP[player] then
                        ESP[player].Box.Visible = false
                        ESP[player].Name.Visible = false
                        ESP[player].Health.Visible = false
                        ESP[player].Distance.Visible = false
                        ESP[player].Tracer.Visible = false
                        ESP[player].Head.Visible = false
                    end
                end
            end
        end
    end
end)

-- Buat ESP untuk player baru
Players.PlayerAdded:Connect(CreateESP)

-- Hapus ESP saat player leave
Players.PlayerRemoving:Connect(function(player)
    if ESP[player] then
        ESP[player].Box:Remove()
        ESP[player].Name:Remove()
        ESP[player].Health:Remove()
        ESP[player].Distance:Remove()
        ESP[player].Tracer:Remove()
        ESP[player].Head:Remove()
        ESP[player] = nil
    end
end)

-- Buat ESP untuk player yang sudah ada
for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end

-- Notifikasi
print("Xeno ESP Loaded! - System Dark")
