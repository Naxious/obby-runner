--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Mapper = require(ServerScriptService.Systems.Mapper)

local playersSpawnPoints = {} :: { [Player]: CFrame }
local shooterSpawn = workspace.SHOOTER_SPAWN and workspace.SHOOTER_SPAWN:GetPivot() :: CFrame
local lobbySpawn = workspace.LOBBY_SPAWN and workspace.LOBBY_SPAWN:GetPivot() :: CFrame

local GameSpawner = {}

function GameSpawner:SpawnRunners(runners: { [Player]: boolean })
	local map = Mapper:GetCurrentMap()
	if not map then
		warn("No map loaded to spawn runners.")
		return
	end

	local runnerSpawn = map:FindFirstChild("START")
	if not runnerSpawn then
		warn("No START spawn found on map.")
		return
	end
	local runnerSpawnCFrame = runnerSpawn:GetPivot()

	for player, _ in runners do
		local character = player.Character
		if character then
			character:PivotTo(runnerSpawnCFrame)
		end
		playersSpawnPoints[player] = runnerSpawnCFrame
	end
end

function GameSpawner:SpawnPlayersInLobby(players: { [number]: Player })
	for _, player in players do
		local character = player.Character
		if character then
			character:PivotTo(lobbySpawn)
		end
		playersSpawnPoints[player] = lobbySpawn
	end
end

function GameSpawner:SpawnShooters(shooters: { [Player]: boolean })
	for player, _ in shooters do
		local character = player.Character
		if character then
			character:PivotTo(shooterSpawn)
		end
		playersSpawnPoints[player] = shooterSpawn
	end
end

function GameSpawner:Init()
	if not shooterSpawn or not lobbySpawn then
		error("SHOOTER_SPAWN or LOBBY_SPAWN parts not found in workspace.")
	end

	Players.PlayerAdded:Connect(function(player)
		if not playersSpawnPoints[player] then
			playersSpawnPoints[player] = lobbySpawn
		end

		player.CharacterAdded:Connect(function(character: Model)
			character:PivotTo(playersSpawnPoints[player])

			local humanoid = character:FindFirstChildWhichIsA("Humanoid")
			repeat
				task.wait()
				humanoid = character:FindFirstChildWhichIsA("Humanoid")
			until humanoid

			if humanoid then
				humanoid.Died:Connect(function()
					task.delay(0.5, function()
						player:LoadCharacter()
					end)
				end)
			end
		end)

		player:LoadCharacter()
	end)

	Players.PlayerRemoving:Connect(function(player)
		playersSpawnPoints[player] = nil
	end)
end

return GameSpawner
