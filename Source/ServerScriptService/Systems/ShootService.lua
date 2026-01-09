local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Projectiles = require(ReplicatedStorage.Data.Projectiles)
local Network = require(ReplicatedStorage.Network)
local Projectile = require(ServerScriptService.Modules.Projectile)

local unreliableRemote = Instance.new("UnreliableRemoteEvent")

local ShootService = {}

function ShootService:PassThrough(id: number, hitPart: BasePart, position: Vector3)
	print(`PassThrough: {id}, {hitPart}, {position}`)
end

function ShootService:HitTarget(owner: number, id: string, hitPart: BasePart, pass: boolean, position: Vector3)
	local possiblePlayer = Players:GetPlayerByCharacter(hitPart.Parent)
	local possibleCharacter = possiblePlayer and possiblePlayer.Character
	if possibleCharacter then
		print(`Shooter {owner} Hit {possibleCharacter.Name}`)
	end
	Network.hitTarget:FireAllClients({
		owner = owner,
		id = id,
		hitPart = hitPart,
		pass = pass,
		position = position,
	})
end

function ShootService:Fire(owner: number, projectileId: string, position: Vector3, direction: Vector3)
	local projectileData = Projectiles[projectileId]
	if not projectileData then
		warn("Attempted to fire an unknown projectile:", projectileId)
		return
	end

	local debug = false
	if debug then
		local currentPosition = position
		local currentAim = direction
		for i = 1, 10 do
			local part = Instance.new("Part")
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Color = Color3.new(1, 0, 0)
			part.Transparency = 0.5
			part.Material = Enum.Material.Neon
			part.Size = Vector3.new(0.2, 0.2, 0.2)
			part.Position = currentPosition
			part.Anchored = true
			part.Parent = workspace

			currentPosition += currentAim * 1
			task.delay(10, function()
				part:Destroy()
			end)
		end
	end

	local function projectileUpdate(id: string, currentPos: Vector3, newPos: Vector3)
		unreliableRemote:FireAllClients({
			owner = owner,
			id = id,
			currentPos = currentPos,
			newPos = newPos,
		})
	end

	local function projectileHit(id: string, hitPart: BasePart, pass: boolean, position: Vector3)
		ShootService:HitTarget(owner, id, hitPart, pass, position)
	end

	local projectile = Projectile.new(
		projectileUpdate,
		projectileHit,
		projectileData.gravityScale, -- gravityScale
		{}, -- { character }, -- ignoreList
		projectileData.radius, -- projectile radius for sphereCast
		workspace.GlobalWind, -- wind for physics
		projectileData.totalTime, -- time in seconds before projectile auto ends
		projectileData.maxBounces, -- max possible bounces
		projectileData.velocityDecay, -- rate of velocity upon hitting something
		projectileData.velocityThreshold, -- min velocity before projectile will end its life
		projectileData.typeId, -- type
		projectileData.debug -- debug to show projectile flight path
	)

	projectile:Cast(position, direction, projectileData.initialVelocity)

	Network.projectileFired:FireAllClients({
		owner = owner,
		id = projectile:GetId(),
		position = position,
		direction = direction,
	})
end

function ShootService:Init()
	unreliableRemote.Name = "UnreliableRemoteEvent"
	unreliableRemote.Parent = ReplicatedStorage

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			while not humanoidRootPart do
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				task.wait()
			end
			humanoidRootPart:AddTag(Projectile.targetTag)
		end)
	end)
end

return ShootService
