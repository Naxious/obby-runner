--!strict
local Players = game:GetService("Players")

local playersSpawnPoints = {} :: { [Player]: CFrame }
local shooterSpawn = workspace.SHOOTER_SPAWN and workspace.SHOOTER_SPAWN:GetPivot() :: CFrame
local lobbySpawn = workspace.LOBBY_SPAWN and workspace.LOBBY_SPAWN:GetPivot() :: CFrame

local GameSpawner = {}

function GameSpawner:TeleportCharacter(character: Model, spawnPoint: CFrame)
	if not character then
		warn("No character to teleport")
		return
	end

	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		warn("No humanoid found in character")
		return
	end

	local isSeated = humanoid.SeatPart ~= nil

	if isSeated then
		local seat = humanoid.SeatPart :: Seat & VehicleSeat
		if seat then
			seat.Disabled = true
		end
		task.delay(1, function()
			if seat then
				seat.Disabled = false
			end
		end)
		humanoid.Sit = false
		repeat
			task.wait()
		until not humanoid.Sit
		character:PivotTo(spawnPoint)
	else
		task.defer(function()
			character:PivotTo(spawnPoint)
		end)
	end
end

function GameSpawner:TeleportPlayerToCurrentSpawn(player: Player)
	local spawnPoint = playersSpawnPoints[player]
	if spawnPoint then
		local character = player.Character
		if character then
			GameSpawner:TeleportCharacter(character, spawnPoint)
		end
	end
end

function GameSpawner:SpawnRunners(runners: { [Player]: boolean })
	local runnerSpawn = workspace:FindFirstChild("MAP_START") :: BasePart
	if not runnerSpawn then
		warn("No START spawn found on map.")
		return
	end

	-- Collect and order players
	local orderedPlayers = {}
	for player, isRunner in runners do
		table.insert(orderedPlayers, player)
	end

	local n = #orderedPlayers
	if n == 0 then
		return
	end

	local base = runnerSpawn:GetPivot()
	local topY = runnerSpawn.Size.Y * 0.5

	local margin = 30
	local usableZ = runnerSpawn.Size.Z - margin * 2

	local spacing = usableZ / math.max(n - 1, 1)
	local startOffset = -(usableZ / 2)

	for i, player in orderedPlayers do
		local character = player.Character
		if character then
			local characterSize = character:GetExtentsSize()
			local offsetZ = startOffset + (i - 1) * spacing
			local spawnCF = base * CFrame.new(0, topY + characterSize.Y, 0) * CFrame.new(0, 0, offsetZ)
			GameSpawner:TeleportCharacter(character, spawnCF)
			playersSpawnPoints[player] = spawnCF
		end
	end
end

function GameSpawner:SpawnPlayersInLobby(players: { [number]: Player })
	for _, player in players do
		local character = player.Character
		if character then
			GameSpawner:TeleportCharacter(character, lobbySpawn)
		end
		playersSpawnPoints[player] = lobbySpawn
	end
end

function GameSpawner:TeleportPlayerToLobby(player: Player)
	local character = player.Character
	if character then
		GameSpawner:TeleportCharacter(character, lobbySpawn)
	end
	playersSpawnPoints[player] = lobbySpawn
end

function GameSpawner:SpawnShooters(shooters: { [Player]: boolean })
	for player, _ in shooters do
		local character = player.Character
		if character then
			GameSpawner:TeleportCharacter(character, shooterSpawn)
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
			GameSpawner:TeleportCharacter(character, playersSpawnPoints[player])

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
