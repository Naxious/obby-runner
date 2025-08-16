local RunService = game:GetService("RunService")

return function(part: BasePart)
	local originCFrame = part:GetPivot()
	local axis = part:GetAttribute("Oscilate_Axis") or Vector3.new(0, 1, 0)
	local speed = part:GetAttribute("Oscilate_Speed") or 1
	local amplitude = part:GetAttribute("Oscilate_Amplitude") or 1
	local offsetTime = part:GetAttribute("Oscilate_OffsetTime") or 0

	local connection = RunService.RenderStepped:Connect(function(deltaTime)
		local elapsed = workspace.DistributedGameTime + offsetTime
		local offset = axis * math.sin(elapsed * speed) * amplitude
		part:PivotTo(originCFrame + offset)
		if part:IsA("Model") then
			for _, child in part:GetDescendants() do
				if child:IsA("BasePart") then
					child.AssemblyLinearVelocity = axis * math.cos(elapsed * speed) * amplitude * speed
				end
			end
		else
			part.AssemblyLinearVelocity = axis * math.cos(elapsed * speed) * amplitude * speed
		end
	end)

	part.Destroying:Once(function()
		connection:Disconnect()
	end)
end
