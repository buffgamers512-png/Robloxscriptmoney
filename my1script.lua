-- MOD MENU | Fly, Speed, Infinite Jump, Money, Minimize

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "ModMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(240, 285)
frame.Position = UDim2.new(0, 25, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(23, 23, 33)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -75, 0, 38)
title.BackgroundTransparency = 1
title.Text = "MOD MENU"
title.TextColor3 = Color3.fromRGB(255, 190, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.Parent = frame

local function button(text, y)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -20, 0, 37)
	b.Position = UDim2.fromOffset(10, y)
	b.BackgroundColor3 = Color3.fromRGB(48, 48, 65)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.TextSize = 14
	b.Font = Enum.Font.GothamSemibold
	b.Text = text
	b.Parent = frame
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(32, 30)
minimize.Position = UDim2.new(1, -68, 0, 4)
minimize.Text = "-"
minimize.TextSize = 20
minimize.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -33, 0, 4)
close.Text = "X"
close.Parent = frame

local flyButton = button("Fly: OFF", 45)
local speedButton = button("Walk Speed: 16", 88)
local jumpButton = button("Infinite Jump: OFF", 131)
local moneyButton = button("Give 100k Money", 174)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 25)
status.Position = UDim2.fromOffset(10, 222)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(190, 190, 200)
status.TextSize = 12
status.Parent = frame

local minimized = false
local oldSize = frame.Size

minimize.Activated:Connect(function()
	minimized = not minimized
	frame.Size = minimized
		and UDim2.fromOffset(240, 38)
		or oldSize

	flyButton.Visible = not minimized
	speedButton.Visible = not minimized
	jumpButton.Visible = not minimized
	moneyButton.Visible = not minimized
	status.Visible = not minimized
	minimize.Text = minimized and "+" or "-"
end)

close.Activated:Connect(function()
	gui:Destroy()
end)

-- WALK SPEED
local fast = false

speedButton.Activated:Connect(function()
	fast = not fast
	local character = player.Character
	local hum = character and character:FindFirstChildOfClass("Humanoid")

	if hum then
		hum.WalkSpeed = fast and 32 or 16
	end

	speedButton.Text = fast and "Walk Speed: 32" or "Walk Speed: 16"
end)

-- INFINITE JUMP
local infiniteJump = false

jumpButton.Activated:Connect(function()
	infiniteJump = not infiniteJump
	jumpButton.Text = infiniteJump
		and "Infinite Jump: ON"
		or "Infinite Jump: OFF"
end)

UIS.JumpRequest:Connect(function()
	if not infiniteJump then return end

	local character = player.Character
	local hum = character and character:FindFirstChildOfClass("Humanoid")

	if hum and hum.Health > 0 then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- FLY
local flying = false
local flyConnection
local flyVelocity
local flyGyro

local function stopFly()
	flying = false

	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end

	if flyVelocity then flyVelocity:Destroy() end
	if flyGyro then flyGyro:Destroy() end

	flyVelocity = nil
	flyGyro = nil
	flyButton.Text = "Fly: OFF"
end

flyButton.Activated:Connect(function()
	if flying then
		stopFly()
		return
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		status.Text = "Character not ready"
		return
	end

	flying = true
	flyButton.Text = "Fly: ON"

	flyVelocity = Instance.new("BodyVelocity")
	flyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	flyVelocity.Velocity = Vector3.zero
	flyVelocity.Parent = root

	flyGyro = Instance.new("BodyGyro")
	flyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	flyGyro.P = 10000
	flyGyro.Parent = root

	flyConnection = RunService.RenderStepped:Connect(function()
		if not root.Parent then
			stopFly()
			return
		end

		local camera = workspace.CurrentCamera
		local direction = Vector3.zero

		if UIS:IsKeyDown(Enum.KeyCode.W) then
			direction += camera.CFrame.LookVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.S) then
			direction -= camera.CFrame.LookVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.A) then
			direction -= camera.CFrame.RightVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.D) then
			direction += camera.CFrame.RightVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then
			direction += Vector3.yAxis
		end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
			direction -= Vector3.yAxis
		end

		flyVelocity.Velocity =
			direction.Magnitude > 0 and direction.Unit * 50
			or Vector3.zero

		flyGyro.CFrame = camera.CFrame
	end)
end)

-- MONEY: gives 100,000 (needs the server script below in ServerScriptService)
moneyButton.Activated:Connect(function()
	local event = ReplicatedStorage:FindFirstChild("AdminMoneyEvent")

	if event then
		event:FireServer()
		status.Text = "Gave +100,000 Money"
	else
		status.Text = "Add the server Script first"
	end
end)

player.CharacterAdded:Connect(function()
	stopFly()
	fast = false
	infiniteJump = false
	speedButton.Text = "Walk Speed: 16"
	jumpButton.Text = "Infinite Jump: OFF"
end)

--[[
==================================================
SERVER SCRIPT (copy this part into a new Script
in ServerScriptService so the money actually works)
==================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local event = ReplicatedStorage:FindFirstChild("AdminMoneyEvent")
if not event then
	event = Instance.new("RemoteEvent")
	event.Name = "AdminMoneyEvent"
	event.Parent = ReplicatedStorage
end

event.OnServerEvent:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local money = leaderstats:FindFirstChild("Money")
	if not money then
		money = Instance.new("IntValue")
		money.Name = "Money"
		money.Value = 0
		money.Parent = leaderstats
	end

	money.Value = money.Value + 100000
	print(player.Name .. " received 100,000 money")
end)

==================================================
]]
