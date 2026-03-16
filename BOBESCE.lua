-- XENO ESP SUPER SIMPLE
-- COPY PASTE INI, DIJAMIN WORK!

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Buat ESP untuk semua player
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local rootPart = character.HumanoidRootPart
            local head = character:FindFirstChild("Head")
            
            if rootPart and head then
                local pos, visible = Camera:WorldToViewportPoint(rootPart.Position)
                local headPos = Camera:WorldToViewportPoint(head.Position)
                
                if visible then
                    -- Gambar box (kotak)
                    local box = Drawing.new("Square")
                    box.Thickness = 2
                    box.Color = Color3.fromRGB(255, 0, 0)
                    box.Filled = false
                    box.Size = Vector2.new(50, 80)
                    box.Position = Vector2.new(pos.X - 25, pos.Y - 40)
                    box.Visible = true
                    
                    -- Gambar nama
                    local name = Drawing.new("Text")
                    name.Text = player.Name
                    name.Color = Color3.fromRGB(255, 255, 255)
                    name.Size = 16
                    name.Position = Vector2.new(pos.X - 25, pos.Y - 60)
                    name.Outline = true
                    name.Visible = true
                    
                    -- Hapus setelah 1 frame
                    task.wait()
                    box:Remove()
                    name:Remove()
                end
            end
        end
    end
end)

print("XENO ESP ACTIVATED - SYSTEM DARK")
