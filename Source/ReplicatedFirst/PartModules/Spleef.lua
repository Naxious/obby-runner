local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer

local partDebounce = {}

return function(part: BasePart)
	part.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or player ~= localPlayer then
			return
		end
		if partDebounce[part] then
			return
		end
		partDebounce[part] = true
		task.delay(2, function()
			partDebounce[part] = false
		end)

		if part.Transparency ~= 0 then
			return
		end

		local hideTime = part:GetAttribute("Spleef_HideTime") or 2
		local revealTime = part:GetAttribute("Spleef_RevealTime") or 2

		local hideTween: Tween = TweenService:Create(part, TweenInfo.new(hideTime), {
			Transparency = 1,
		})
		hideTween:Play()

		hideTween.Completed:Once(function()
			part.CanCollide = false
			task.delay(revealTime, function()
				part.CanCollide = true
				TweenService:Create(part, TweenInfo.new(hideTime), {
					Transparency = 0,
				}):Play()
			end)
		end)
	end)
end
