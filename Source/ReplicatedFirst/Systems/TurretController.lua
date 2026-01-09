local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Network = require(ReplicatedStorage:WaitForChild("Network"))

local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local currentCharacter = nil
local characterConnections = {}
local aimStep = nil
local turrets = {}

local function getTurret(): Model?
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil
	end

	local seat = humanoid.SeatPart
	if not seat then
		return nil
	end

	local turret = seat:FindFirstAncestorOfClass("Model")
	if turret and turret:HasTag("Turret") then
		return turret
	end

	return nil
end

local TurretController = {}

function TurretController:EnableAiming(turret: Model?)
	if not turret or aimStep then
		return
	end

	camera.CameraType = Enum.CameraType.Scriptable
	local barrel = turret:FindFirstChild("Barrel")
	if not barrel then
		warn("Turret is missing Barrel part")
		return
	end

	aimStep = RunService.RenderStepped:Connect(function()
		if not barrel then
			return
		end

		if not currentCharacter then
			TurretController:DisableAiming()
			return
		end

		local barrelLook = -barrel:GetPivot().RightVector + Vector3.new(0, 1, 0)
		local cameraOffset = -barrelLook + Vector3.new(0, 2.5, 0)

		camera.CFrame = CFrame.new(barrel.Position + cameraOffset, barrel.Position + barrelLook)
	end)
end

function TurretController:DisableAiming()
	if aimStep then
		aimStep:Disconnect()
		aimStep = nil
	end
end

function TurretController:AddCharacter(character: Model)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	if currentCharacter then
		for _, connection in characterConnections do
			connection:Disconnect()
		end
	end

	currentCharacter = character
	characterConnections["SeatConnection"] = humanoid.Seated:Connect(function(active, seat)
		if active then
			local turret = getTurret()
			if turret then
				TurretController:EnableAiming(turret)
			end
			return
		end
		TurretController:DisableAiming()
	end)
end

function TurretController:RequestFire()
	local turret = getTurret()
	if turret then
		Network.fireTurret:FireServer(turret)
	end
end

function TurretController:AddTurret(turret: Model)
	local turretOriginalPivot = turret:GetAttribute("Pivot")
	turrets[turret] = {
		pivot = turretOriginalPivot,
		connections = {},
	}

	turret:GetAttributeChangedSignal("Yaw"):Connect(function()
		local yaw = turret:GetAttribute("Yaw")
		local pitch = turret:GetAttribute("Pitch")
		TurretController:AimTurret(turret, yaw, pitch)
	end)

	turret:GetAttributeChangedSignal("Pitch"):Connect(function()
		local yaw = turret:GetAttribute("Yaw")
		local pitch = turret:GetAttribute("Pitch")
		TurretController:AimTurret(turret, yaw, pitch)
	end)
end

function TurretController:AimTurret(turret: Model, yaw: number, pitch: number)
	local base = turret:FindFirstChild("Base") :: Model
	if not base then
		warn("Turret is missing Base part")
		return
	end

	local rotor = turret:FindFirstChild("Rotor") :: BasePart
	local motor6D = rotor and rotor:FindFirstChild("Motor6D") :: Motor6D
	if not motor6D then
		warn("Turret is missing Rotor part")
		return
	end

	base:PivotTo(turrets[turret].pivot * CFrame.Angles(0, yaw, 0))
	rotor.Motor6D.C1 = CFrame.Angles(0, 0, pitch)
end

function TurretController:Init()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			TurretController:RequestFire()
		end
	end)

	CollectionService:GetInstanceAddedSignal("Turret"):Connect(function(turret)
		TurretController:AddTurret(turret)
	end)
	for _, turret in CollectionService:GetTagged("Turret") do
		TurretController:AddTurret(turret)
	end

	localPlayer.CharacterAdded:Connect(function(character)
		TurretController:AddCharacter(character)
	end)
	TurretController:AddCharacter(localPlayer.Character)
end

return TurretController
