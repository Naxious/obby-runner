local Players = game:GetService("Players")

local playerDebounce = {}
local playersWithSpeed = {}

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
		local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then
			return
		end

		local speed = part:GetAttribute("Fast_Speed") or 16
		local duration = part:GetAttribute("Fast_Duration") or 2

		if playersWithSpeed[player] then
			if tick() - playersWithSpeed[player].tick < playersWithSpeed[player].duration then
				return
			end
		end
		task.delay(duration, function()
			humanoid.WalkSpeed -= speed
			playersWithSpeed[player] = nil
		end)

		humanoid.WalkSpeed += speed

		playersWithSpeed[player] = {
			tick = tick(),
			duration = duration,
		}
	end)
end
