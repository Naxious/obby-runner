local Table = {}

function Table.DeepCopy(original)
	if type(original) ~= "table" then
		return original
	end

	local copy = {}
	for key, value in pairs(original) do
		copy[key] = Table.DeepCopy(value)
	end
	return copy
end

return Table
