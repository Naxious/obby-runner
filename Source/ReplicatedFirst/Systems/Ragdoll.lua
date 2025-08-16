local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

local Network = require(ReplicatedStorage.Network)

local localPlayer = Players.LocalPlayer
local currentlyRagDolled = false

local Ragdoll = {}

function Ragdoll:Start()
	if currentlyRagDolled then
		return
	end
	currentlyRagDolled = true

	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		currentlyRagDolled = false
		return
	end

	humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	humanoid.WalkSpeed = 0
	humanoid.PlatformStand = true
end

function Ragdoll:Stop()
	if not currentlyRagDolled then
		return
	end
	currentlyRagDolled = false

	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

	humanoid.WalkSpeed = StarterPlayer.CharacterWalkSpeed
	humanoid.PlatformStand = false
end

function Ragdoll:Init()
	Network.ragdoll.OnClientEvent:Connect(function(data)
		local state = data.state
		if state == "Start" then
			Ragdoll:Start()
		elseif state == "Stop" then
			Ragdoll:Stop()
		end
	end)
end

return Ragdoll
