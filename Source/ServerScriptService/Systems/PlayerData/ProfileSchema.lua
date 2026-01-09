local ProfileSchema = {
	Game = {
		totalPlayed = 0,
		totalWins = 0,
	},
	Player = {
		cups = 0,
		coins = 0,
		hearts = 0,
		trails = {},
		equippedTrail = "",
	},
	Lifetime = {
		cups = 0,
		coins = 0,
		hearts = 0,
	},
}

return ProfileSchema
