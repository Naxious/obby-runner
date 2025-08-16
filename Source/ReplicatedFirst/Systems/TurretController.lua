local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Network = require(ReplicatedStorage:WaitForChild("Network"))

local localPlayer = Players.LocalPlayer

local function getTurret()
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

function TurretController:RequestFire()
	local turret = getTurret()
	if turret then
		Network.fireTurret:FireServer(turret)
	end
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
end

return TurretController
