local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Network = require(ReplicatedStorage.Network)

local Ragdoll = {}

function Ragdoll:StartRagdoll(character: Model, time: number?)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	if humanoid:GetState() == Enum.HumanoidStateType.Physics then
		return
	end

	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	humanoid.BreakJointsOnDeath = false

	for _, joint in character:GetDescendants() do
		if not joint:IsA("Motor6D") then
			continue
		end
		joint.Enabled = false

		local attachmentOne = Instance.new("Attachment")
		local attachmentTwo = Instance.new("Attachment")
		attachmentOne.CFrame = joint.C0
		attachmentOne.Parent = joint.Part0
		attachmentTwo.CFrame = joint.C1
		attachmentTwo.Parent = joint.Part1

		if joint.Name == "Root" then
			local hinge = Instance.new("HingeConstraint")
			hinge.Attachment0 = attachmentOne
			hinge.Attachment1 = attachmentTwo
			hinge.LimitsEnabled = true
			hinge.Parent = joint.Parent
			continue
		elseif joint.Name == "Neck" then
			local hinge = Instance.new("HingeConstraint")
			hinge.Attachment0 = attachmentOne
			hinge.Attachment1 = attachmentTwo
			hinge.LimitsEnabled = true
			hinge.Parent = joint.Parent
			continue
		end

		local socket = Instance.new("BallSocketConstraint")
		socket.Attachment0 = attachmentOne
		socket.Attachment1 = attachmentTwo
		socket.TwistLimitsEnabled = true
		socket.Parent = joint.Parent
	end

	Network.ragdoll:FireClient(player, { state = "Start", time = time })

	if time then
		task.delay(time, function()
			Ragdoll:EndRagdoll(character)
		end)
	end
end

function Ragdoll:EndRagdoll(character)
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	for _, joint in character:GetDescendants() do
		if not joint:IsA("Motor6D") then
			continue
		end

		local socket = joint.Parent:FindFirstChild("BallSocketConstraint")
			or joint.Parent:FindFirstChild("HingeConstraint")
		local attachmentOne = joint.Part0:FindFirstChild("Attachment")
		local attachmentTwo = joint.Part1:FindFirstChild("Attachment")

		if socket then
			socket:Destroy()
		end
		if attachmentOne then
			attachmentOne:Destroy()
		end
		if attachmentTwo then
			attachmentTwo:Destroy()
		end

		joint.Enabled = true
	end

	Network.ragdoll:FireClient(player, { state = "Stop" })
end

return Ragdoll
