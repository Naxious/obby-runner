local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Network)
local VoteMachine = require(ServerScriptService.Modules.VoteMachine)
local Mapper = require(ServerScriptService.Systems.Mapper)
local AFKManager = require(ServerScriptService.Systems.AFKManager)
local GameSpawner = require(ServerScriptService.Systems.GameSpawner)
local CurrencyManager = require(ServerScriptService.Systems.CurrencyManager)
local Dropper = require(ServerScriptService.Systems.Dropper)

local RUNNER_LIVES = 3

local roundData = {
	playersVoted = {},
	shooters = {} :: { [Player]: boolean },
	runners = {} :: { [Player]: boolean },
	players = {} :: { [number]: Player },
	runnersFinished = {} :: { [Player]: boolean },
	shooterHits = {} :: { [Player]: number },
	runnerHits = {} :: { [Player]: number },
}

local roundConnections = {} :: { RBXScriptConnection }
local mapStartWall = workspace.MAP_START_WALL :: Model & {
	Counter: BasePart & {
		SurfaceGui: SurfaceGui & {
			TextLabel: TextLabel,
		},
	},
	Wall: BasePart,
	Ribbon: BasePart,
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

local function resetStartWall()
	mapStartWall.Counter.Transparency = 1
	mapStartWall.Counter.SurfaceGui.Enabled = false
	mapStartWall.Ribbon.Transparency = 0
	mapStartWall.Wall.CanCollide = true
end

local GameRound = {}

function GameRound:ShooterHit(player: Player)
	if not player or not roundData.shooters[player] then
		return
	end

	local newCount = (roundData.shooterHits[player] or 0) + 1

	Network.shooterHits:SetFor(player, newCount)

	roundData.shooterHits[player] = newCount
end

function GameRound:RunnerHit(player: Player)
	if not player or not roundData.runners[player] then
		return
	end

	local newCount = (roundData.runnerHits[player] or RUNNER_LIVES) - 1
	if newCount <= 0 then
		GameSpawner:TeleportPlayerToCurrentSpawn(player)
		Network.runnerHits:SetFor(player, RUNNER_LIVES)
		roundData.runnerHits[player] = RUNNER_LIVES
		return
	end

	Network.runnerHits:SetFor(player, newCount)
	roundData.runnerHits[player] = newCount
end

function GameRound:StartWallCount(number: number?)
	mapStartWall.Counter.Transparency = 1
	mapStartWall.Counter.SurfaceGui.Enabled = true
	mapStartWall.Wall.CanCollide = true

	local wallConnection
	local timer = number or 10
	wallConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
		if not mapStartWall or not mapStartWall.Counter then
			warn("MAP_START_WALL or its Counter part not found.")
			return
		end

		timer = timer - deltaTime
		if timer <= 0 then
			if wallConnection then
				wallConnection:Disconnect()
				wallConnection = nil
			end
			mapStartWall.Counter.SurfaceGui.TextLabel.Text = "GO!"
			mapStartWall.Ribbon.Transparency = 1
			mapStartWall.Wall.CanCollide = false
			task.delay(2, function()
				mapStartWall.Counter.Transparency = 1
				mapStartWall.Counter.SurfaceGui.Enabled = false
			end)
			return
		end

		mapStartWall.Counter.SurfaceGui.TextLabel.Text = string.format("%02d", math.ceil(timer))
	end)
end

function GameRound:RewardWinners()
	local winningRunnerCount = 0
	for _ in roundData.runnersFinished do
		winningRunnerCount += 1
	end

	if winningRunnerCount <= 0 then
		-- SHOOTERS WON
		for player, _ in roundData.shooters do
			CurrencyManager:AddCoins(player, 40)
		end
	else
		-- RUNNERS WON
		for player, _ in roundData.runners do
			if roundData.runnersFinished[player] then
				-- Reward the Finished Runner
				CurrencyManager:AddCoins(player, 40)
			else
				-- Reward runners who did not finish
				CurrencyManager:AddCoins(player, 15)
			end
		end
	end
end

function GameRound:Reset()
	for player, _ in roundData.shooters do
		Network.shooterHits:SetFor(player, -1)
	end

	for player, _ in roundData.runners do
		Network.runnerHits:SetFor(player, -1)
	end

	roundData.playersVoted = {}
	roundData.shooters = {}
	roundData.runners = {}
	roundData.players = {}
	roundData.runnersFinished = {}

	resetStartWall()
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

function GameRound:Start(): boolean
	local selectedMapName = VoteMachine:StopVote()

	local mapFinishPart = workspace.MAP_FINISH :: BasePart
	if not mapFinishPart then
		warn("No finish part found in the map.")
		GameRound:Reset()
		return false
	end

	local mapLoaded = Mapper:LoadMap(selectedMapName)
	if not mapLoaded then
		warn("Failed to load map: " .. selectedMapName)
		GameRound:Reset()
		return false
	end

	GameSpawner:SpawnRunners(roundData.runners)
	GameSpawner:SpawnShooters(roundData.shooters)

	for player, _ in roundData.runners do
		Network.runnerHits:SetFor(player, RUNNER_LIVES)
		roundData.runnerHits[player] = RUNNER_LIVES
	end

	for player, _ in roundData.shooters do
		Network.shooterHits:SetFor(player, 0)
		roundData.shooterHits[player] = 0
	end

	if roundConnections["FinishLine"] then
		roundConnections["FinishLine"]:Disconnect()
	end

	roundConnections["FinishLine"] = mapFinishPart.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or not roundData.runners[player] then
			return
		end

		if roundData.runnersFinished[player] then
			return
		end

		roundData.runnersFinished[player] = true
		GameSpawner:TeleportPlayerToLobby(player)

		--TODO: Reward Crown/Streak...
	end)

	GameRound:StartWallCount(10)

	return true
end

function GameRound:Stop()
	GameSpawner:SpawnPlayersInLobby(roundData.players)

	GameRound:RewardWinners()
	GameRound:Reset()

	VoteMachine:ResetVoteMachine()
end

function GameRound:Init()
	if not mapStartWall then
		error("MAP_START_WALL not found in workspace.")
	end

	VoteMachine:Init()

	Dropper.runnerHit.Event:Connect(function(player)
		if not player or not roundData.runners[player] then
			return
		end
		GameRound:RunnerHit(player)
	end)

	Dropper.shooterHit.Event:Connect(function(player)
		if not player or not roundData.shooters[player] then
			return
		end
		GameRound:ShooterHit(player)
	end)
end

return GameRound
