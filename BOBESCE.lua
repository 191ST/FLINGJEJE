local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remoteEvent = ReplicatedStorage:WaitForChild("FlingSystemEvent")

-- Tunggu character
repeat task.wait() until player.Character

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SuperFlingHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 180)
mainFrame.Position = UDim2.new(0, 20, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Shadow
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Parent = mainFrame

-- Corner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
title.Text = "⚡ SUPER FLING ZONE ⚡"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = title

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Content
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -50)
content.Position = UDim2.new(0, 10, 0, 45)
content.BackgroundTransparency = 1
content.Parent = mainFrame

-- Radius label
local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(1, 0, 0, 25)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Text = "🎯 RADIUS: 50"
radiusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
radiusLabel.TextSize = 16
radiusLabel.Font = Enum.Font.GothamBold
radiusLabel.TextXAlignment = Enum.TextXAlignment.Left
radiusLabel.Parent = content

-- Slider bg
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, 0, 0, 25)
sliderBg.Position = UDim2.new(0, 0, 0, 30)
sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = content

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 15)
sliderCorner.Parent = sliderBg

-- Slider fill
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.005, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 15)
fillCorner.Parent = sliderFill

-- Slider button
local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(0, 20, 0, 20)
sliderBtn.Position = UDim2.new(0.005, -10, 0.5, -10)
sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderBtn.Text = ""
sliderBtn.ZIndex = 2
sliderBtn.Parent = sliderBg

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = sliderBtn

-- Current radius display
local currentRadius = 50
local minRadius = 1
local maxRadius = 10000
local dragging = false

-- Update function
local function updateRadius(value)
	currentRadius = math.floor(value)
	radiusLabel.Text = "🎯 RADIUS: " .. currentRadius
	
	local percentage = (value - minRadius) / (maxRadius - minRadius)
	sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
	sliderBtn.Position = UDim2.new(percentage, -10, 0.5, -10)
	
	-- Kirim ke server
	remoteEvent:FireServer(currentRadius, "updateRadius")
end

-- Slider drag
sliderBtn.MouseButton1Down:Connect(function()
	dragging = true
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local mousePos = UserInputService:GetMouseLocation()
		local sliderPos = sliderBg.AbsolutePosition
		local sliderSize = sliderBg.AbsoluteSize.X
		
		local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize)
		local percentage = relativeX / sliderSize
		local newRadius = minRadius + (percentage * (maxRadius - minRadius))
		
		updateRadius(newRadius)
	end
end)

-- Radius input manual
local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(1, 0, 0, 35)
inputFrame.Position = UDim2.new(0, 0, 0, 65)
inputFrame.BackgroundTransparency = 1
inputFrame.Parent = content

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0.6, -5, 1, 0)
inputBox.Position = UDim2.new(0, 0, 0, 0)
inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
inputBox.PlaceholderText = "Radius 1-10000"
inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
inputBox.Text = "50"
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.TextSize = 14
inputBox.Font = Enum.Font.Gotham
inputBox.ClearTextOnFocus = false
inputBox.Parent = inputFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = inputBox

local setBtn = Instance.new("TextButton")
setBtn.Size = UDim2.new(0.4, -5, 1, 0)
setBtn.Position = UDim2.new(0.6, 5, 0, 0)
setBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
setBtn.Text = "SET"
setBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setBtn.TextSize = 14
setBtn.Font = Enum.Font.GothamBold
setBtn.Parent = inputFrame

local setCorner = Instance.new("UICorner")
setCorner.CornerRadius = UDim.new(0, 8)
setCorner.Parent = setBtn

setBtn.MouseButton1Click:Connect(function()
	local value = tonumber(inputBox.Text)
	if value then
		value = math.clamp(value, minRadius, maxRadius)
		inputBox.Text = tostring(value)
		updateRadius(value)
	end
end)

-- Info panel
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 25)
infoLabel.Position = UDim2.new(0, 0, 0, 110)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "🔥 KLIK TOOL UNTUK FLING 🔥"
infoLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
infoLabel.TextSize = 14
infoLabel.Font = Enum.Font.GothamBold
infoLabel.Parent = content

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 135)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🟢 ACTIVE"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = content

-- Initialize
updateRadius(50)

-- Animasi masuk
mainFrame.Position = UDim2.new(0, -320, 0.5, -90)
local tween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 20, 0.5, -90)})
tween:Play()
