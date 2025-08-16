local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Enums)

local Trails = {
	["Trail Name"] = {
		cost = 0,
		currency = Enums.Currency.Coins,
	},
}

return Trails
