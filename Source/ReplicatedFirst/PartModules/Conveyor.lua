return function(part: BasePart)
	local axis = part:GetAttribute("Converyor_Axis") or Vector3.new(1, 0, 0)
	local speed = part:GetAttribute("Converyor_Speed") or 1
	part.AssemblyLinearVelocity = axis * speed
end
