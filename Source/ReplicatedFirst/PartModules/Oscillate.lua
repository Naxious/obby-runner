local RunService = game:GetService("RunService")

return function(part: BasePart)
	local originCFrame = part:GetPivot()
	local axis = part:GetAttribute("Oscilate_Axis") or Vector3.new(0, 1, 0)
	local speed = part:GetAttribute("Oscilate_Speed") or 1
	local amplitude = part:GetAttribute("Oscilate_Amplitude") or 1
	local offsetTime = part:GetAttribute("Oscilate_OffsetTime") or 0

	local axisUnit = axis.Magnitude > 0 and axis.Unit or Vector3.new(0, 1, 0)

	local cachedParts = {} :: { BasePart }
	if typeof(part) == "Instance" and part:IsA("Model") then
		cachedParts = {}
		for _, child in part:GetDescendants() do
			if not child:IsA("BasePart") then
				continue
			end
			table.insert(cachedParts, child)
		end
	end

	local connection = RunService.RenderStepped:Connect(function(deltaTime)
		local elapsed = workspace.DistributedGameTime + offsetTime

		local sin = math.sin(elapsed * speed)
		local cos = math.cos(elapsed * speed)

		local offset = axisUnit * sin * amplitude

		part:PivotTo(originCFrame * CFrame.new(offset))

		local worldAxis = originCFrame:VectorToWorldSpace(axisUnit)
		local v = worldAxis * (cos * amplitude * speed)

		if part:IsA("Model") then
			for _, child in part:GetDescendants() do
				if child:IsA("BasePart") then
					child.AssemblyLinearVelocity = v
				end
			end
		else
			part.AssemblyLinearVelocity = worldAxis * (cos * amplitude * speed)
		end
	end)

	part.Destroying:Once(function()
		connection:Disconnect()
	end)
end
