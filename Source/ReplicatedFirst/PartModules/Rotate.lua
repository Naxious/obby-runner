local RunService = game:GetService("RunService")

return function(part: BasePart)
	local rotationsPerSecond = part:GetAttribute("Rotate_Speed")
	local rotationAxis = part:GetAttribute("Rotate_Axis") or Vector3.yAxis
	if rotationsPerSecond == 0 then
		warn("Cannot Roate 0 times per second setting to 1", part)
		rotationsPerSecond = 1
	end

	local originalRotation = part:GetPivot().Rotation

	local connection = RunService.RenderStepped:Connect(function(deltaTime)
		local timePerRotation = 1 / rotationsPerSecond
		local progress = (workspace.DistributedGameTime % timePerRotation) / timePerRotation
		local rotationProgress = math.pi * 2.00 * progress

		local partPivot = part:GetPivot()

		part:PivotTo(
			CFrame.new(partPivot.Position)
				* (
					originalRotation
					* CFrame.Angles(
						rotationAxis.X * rotationProgress,
						rotationAxis.Y * rotationProgress,
						rotationAxis.Z * rotationProgress
					)
				)
		)
	end)

	part.Destroying:Once(function()
		connection:Disconnect()
	end)
end
