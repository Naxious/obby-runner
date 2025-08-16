local Time = {}

function Time.stringifyMinSeconds(seconds: number): string
	local minutes = math.floor(seconds / 60)
	local remainingSeconds = seconds % 60
	return string.format("%02d:%02d", minutes, remainingSeconds)
end

return Time
