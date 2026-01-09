local RarityRoller = {}

local RNG = Random.new()

local RARITIES = {
	{ name = "Common", weight = 68000 }, -- 68%
	{ name = "Rare", weight = 22000 }, -- 22%
	{ name = "Epic", weight = 8500 }, -- 8.5%
	{ name = "Legendary", weight = 1300 }, -- 1.3%
	{ name = "Mythical", weight = 200 }, -- 0.2%
}

local TOTAL_WEIGHT = 0
for _, rarity in RARITIES do
	TOTAL_WEIGHT += rarity.weight
end

function RarityRoller.Roll(): string
	local roll = RNG:NextInteger(1, TOTAL_WEIGHT)
	local accumulated = 0
	for _, rarity in RARITIES do
		accumulated += rarity.weight
		if roll <= accumulated then
			return rarity.name
		end
	end

	return RARITIES[#RARITIES].name
end

function RarityRoller.RollMany(count: number): { string }
	local out = table.create(count)
	for i = 1, count do
		out[i] = RarityRoller.Roll()
	end
	return out
end

return RarityRoller
