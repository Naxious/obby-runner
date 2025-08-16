local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

local noJumpParts = {} :: { BasePart }

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Include
rayParams.IgnoreWater = true

RunService.Heartbeat:Connect(function()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	rayParams.FilterDescendantsInstances = { noJumpParts }

	local rayResult = workspace:Raycast(character:GetPivot().Position, Vector3.new(0, -50, 0), rayParams)

	if rayResult then
		humanoid.JumpHeight = 0
	else
		humanoid.JumpHeight = 7.2
	end
end)

return function(part: BasePart)
	table.insert(noJumpParts, part)

	part.Destroying:Once(function()
		local index = table.find(noJumpParts, part)
		if index then
			table.remove(noJumpParts, index)
		end
	end)
end
