local ProfileSchema = {
	WitStones = 0,
	Faction = 0,
	lastPosition = {
		X = 0,
		Y = 0,
		Z = 0,
	},
	UnlockedAreas = {} :: { [string]: boolean },
}

return ProfileSchema
