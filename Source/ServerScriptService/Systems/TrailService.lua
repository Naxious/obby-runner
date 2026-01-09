local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Network = require(ReplicatedStorage.Network)
local PlayerData = require(ServerScriptService.Systems.PlayerData)
local CurrencyManager = require(ServerScriptService.Systems.CurrencyManager)
local RarityRoller = require(ServerScriptService.Modules.RarityRoller)
local Table = require(ReplicatedStorage.Libraries.Table)

local trailsFolder = ReplicatedStorage.Assets.Trails

local TRAIL_CHEST_COST = 500

local equippedParticles = {} :: { [Player]: BasePart }

local TrailService = {}

function TrailService:EquipTrail(character: Model, trailId: string)
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		local timer = 0
		while not humanoidRootPart and timer < 5 do
			task.wait(0.3)
			humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			timer += 0.3
		end
		if not humanoidRootPart then
			return
		end
	end

	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	if equippedParticles[player] then
		equippedParticles[player]:Destroy()
		equippedParticles[player] = nil
	end

	local trails = trailsFolder:GetChildren()
	for _, rarityFolder in trails do
		for _, trailFolder in rarityFolder:GetChildren() do
			if trailFolder.Name == trailId then
				local trailObject = trailFolder:FindFirstChildOfClass("Part")
				local trailClone = trailObject:Clone() :: BasePart
				trailClone.CanCollide = false
				trailClone.Transparency = 1
				trailClone.CanQuery = false
				trailClone.CanTouch = false
				trailClone.Anchored = false
				trailClone:PivotTo(humanoidRootPart:GetPivot())
				trailClone.Parent = character

				local weld = Instance.new("WeldConstraint")
				weld.Part0 = humanoidRootPart
				weld.Part1 = trailClone
				weld.Parent = trailClone

				equippedParticles[player] = trailClone
				break
			end
		end
	end

	Network.equippedTrail:SetFor(player, trailId)
end

function TrailService:UpdatePlayersTrails(player: Player)
	local profile = PlayerData:GetProfile(player)
	local trails = profile.Data.Player.trails

	local trailData = Table.DeepCopy(trails)

	Network.trailData:SetFor(player, trailData)
end

function TrailService:AwardTrail(player: Player, trailId: string, rarity: string)
	local profile = PlayerData:GetProfile(player)
	profile.Data.Player.trails[trailId] = rarity

	Network.openTrailChest:FireClient(player, trailId, rarity)
	TrailService:UpdatePlayersTrails(player)
end

function TrailService:PlayerOwnsTrail(player: Player, trailId: string): boolean
	local profile = PlayerData:GetProfile(player)
	if profile.Data.Player.trails[trailId] then
		return true
	end
	return false
end

function TrailService:RequestBuyChest(player: Player)
	if not CurrencyManager:CanBuyWithCoins(player, TRAIL_CHEST_COST) then
		return
	end

	local rarity = RarityRoller.Roll()
	local rarityFolder = trailsFolder:FindFirstChild(rarity)

	if not rarityFolder then
		error("Rarity folder not found in ReplicatedStorage/Assets/Trails/")
	end

	local selectedTrail = nil
	local trails = {}
	for _, trail in rarityFolder:GetChildren() do
		table.insert(trails, trail.Name)
	end

	if #trails == 0 then
		error("No trails found in rarity folder")
	end

	selectedTrail = trails[math.random(#trails)]

	if TrailService:PlayerOwnsTrail(player, selectedTrail) then
		CurrencyManager:AddCoins(player, -TRAIL_CHEST_COST)
		CurrencyManager:AddHearts(player, 1)
		Network.openTrailChest:FireClient(player, selectedTrail, rarity)
		return
	end

	CurrencyManager:AddCoins(player, -TRAIL_CHEST_COST)

	TrailService:AwardTrail(player, selectedTrail, rarity)
end

function TrailService:CharacterAdded(player: Player, character: Model)
	local profile = PlayerData:GetProfile(player)
	if not profile or not character then
		return
	end

	local equippedTrail = profile.Data.Player.equippedTrail
	TrailService:EquipTrail(character, equippedTrail)
end

function TrailService:Init()
	if not trailsFolder then
		error("Trails folder not found in ReplicatedStorage/Assets/")
	end

	Network.requestTrailChest.OnServerEvent:Connect(function(player)
		TrailService:RequestBuyChest(player)
	end)

	Network.equipTrail.OnServerEvent:Connect(function(player, trailId)
		local profile = PlayerData:GetProfile(player)
		if TrailService:PlayerOwnsTrail(player, trailId) then
			profile.Data.Player.equippedTrail = trailId
			if equippedParticles[player] then
				if equippedParticles[player].Name == trailId then
					equippedParticles[player]:Destroy()
					equippedParticles[player] = nil

					Network.equippedTrail:SetFor(player, "")
					profile.Data.Player.equippedTrail = ""
					return
				end
			end
			TrailService:EquipTrail(player.Character, trailId)
			profile.Data.Player.equippedTrail = trailId
		end
	end)

	Players.PlayerAdded:Connect(function(player)
		TrailService:UpdatePlayersTrails(player)
		player.CharacterAdded:Connect(function(character)
			TrailService:CharacterAdded(player, character)
		end)

		TrailService:CharacterAdded(player, player.Character)
	end)
end

return TrailService
