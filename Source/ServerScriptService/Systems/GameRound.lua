local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local VoteMachine = require(ServerScriptService.Modules.VoteMachine)
local Mapper = require(ServerScriptService.Systems.Mapper)
local AFKManager = require(ServerScriptService.Systems.AFKManager)
local GameSpawner = require(ServerScriptService.Systems.GameSpawner)

local roundData = {
	playersVoted = {},
	shooters = {} :: { [Player]: boolean },
	runners = {} :: { [Player]: boolean },
	players = {} :: { [number]: Player },
}

local function getNumberOfShooters(players: { [number]: Player })
	local totalPlayers = #players
	if totalPlayers < 2 then
		return 0
	elseif totalPlayers < 7 then
		return 1
	elseif totalPlayers < 12 then
		return 2
	else
		return 3
	end
end

local GameRound = {}

function GameRound:Reset()
	roundData.playersVoted = {}
	roundData.shooters = {}
	roundData.runners = {}
	roundData.players = {}
end

function GameRound:SetShootersAndRunners(shooterCount: number)
	roundData.shooters = {}
	roundData.runners = {}

	local shuffledPlayers = {}
	for i, player in roundData.players do
		local randomIndex = math.random(1, #shuffledPlayers + 1)
		table.insert(shuffledPlayers, randomIndex, player)
	end

	for i = 1, shooterCount do
		roundData.shooters[shuffledPlayers[i]] = true
	end

	for i = shooterCount + 1, #shuffledPlayers do
		roundData.runners[shuffledPlayers[i]] = true
	end
end

function GameRound:Vote(): boolean
	roundData.players = {}
	for _, player in Players:GetPlayers() do
		if AFKManager:IsPlayerAFK(player) then
			continue
		end
		table.insert(roundData.players, player)
	end
	print("Players in round: " .. #roundData.players)

	local shooterCount = getNumberOfShooters(roundData.players)
	if shooterCount < 1 then
		print("Not enough players to start a round.")
		GameRound:Reset()
		return false
	end

	GameRound:SetShootersAndRunners(shooterCount)
	for player, _ in roundData.shooters do
		print(player.Name .. " is a shooter.")
	end
	for player, _ in roundData.runners do
		print(player.Name .. " is a runner.")
	end

	Mapper:UnloadMap()
	print("Starting vote with " .. #roundData.players .. " players.")
	VoteMachine:StartVote()
	return true
end

function GameRound:Start()
	local selectedMapName = VoteMachine:StopVote()

	Mapper:LoadMap(selectedMapName)

	GameSpawner:SpawnRunners(roundData.runners)
	GameSpawner:SpawnShooters(roundData.shooters)
end

function GameRound:Stop()
	GameSpawner:SpawnPlayersInLobby(roundData.players)

	VoteMachine:ResetVoteMachine()
end

function GameRound:Init()
	VoteMachine:Init()
end

return GameRound
