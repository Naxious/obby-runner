local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GameRound = require(ServerScriptService.Systems.GameRound)
local Time = require(ReplicatedStorage.Libraries.Time)

type stateNames = "Intermission" | "Voting" | "Round"

type GameState = {
	name: stateNames,
	duration: number,
}

local GAME_SPEED_SCALE = 0.5

local TIME_INTERMISSION = 20 * GAME_SPEED_SCALE
local TIME_VOTING = 15 * GAME_SPEED_SCALE
local TIME_ROUND = 90 * GAME_SPEED_SCALE

local Timer = require(ReplicatedStorage.Libraries.Timer)

local timer = Timer.new()
local gameState = 1
local gameStates = {
	[1] = {
		name = "Intermission",
		duration = TIME_INTERMISSION,
	},
	[2] = {
		name = "Voting",
		duration = TIME_VOTING,
	},
	[3] = {
		name = "Round",
		duration = TIME_ROUND,
	},
} :: { [number]: GameState }

local RoundManager = {}

function RoundManager:ForceIntermission()
	gameState = 0
	timer:Stop()
end

function RoundManager:StartIntermission()
	print("Intermission started!")
	GameRound:Stop()
end

function RoundManager:StartVoting()
	print("Voting started!")
	local voteStarted = GameRound:Vote()
	if not voteStarted then
		RoundManager:ForceIntermission()
		return
	end
end

function RoundManager:StartRound()
	print("Round started!")
	GameRound:Start()
end

function RoundManager:UpdateState()
	if gameState < #gameStates then
		gameState += 1
	else
		gameState = 1
	end

	local stateInfo = gameStates[gameState]
	print(`Game state changed to: {stateInfo.name}`)

	if timer.running then
		timer:Stop()
	end

	timer:Start(stateInfo.duration)

	if stateInfo.name == "Round" then
		RoundManager:StartRound()
	elseif stateInfo.name == "Voting" then
		RoundManager:StartVoting()
	elseif stateInfo.name == "Intermission" then
		RoundManager:StartIntermission()
	end
end

function RoundManager:Init()
	local gameStateMessage = ReplicatedStorage.Assets.GameStateMessage
	timer.Stepped:Connect(function(timeLeft: number)
		local gamestateName = gameStates[gameState] and gameStates[gameState].name or gameStates[1].name
		gameStateMessage.Value = `{gamestateName}: {Time.stringifyMinSeconds(timeLeft)}`
	end)

	timer.Stopped:Connect(function(reason: string)
		RoundManager:UpdateState()
	end)

	timer:Start(gameStates[gameState].duration)
end

return RoundManager
