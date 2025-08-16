local Players = game:GetService("Players")

local playerDebounce = {}

return function(part: BasePart)
	part.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then
			return
		end

		if playerDebounce[player] then
			return
		end
		playerDebounce[player] = true

		task.delay(2, function()
			playerDebounce[player] = false
		end)

		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")
			if humanoid then
				humanoid.Health = 0
			end
		end
	end)
end
