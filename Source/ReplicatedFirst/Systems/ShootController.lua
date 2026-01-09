local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CloneCacher = require(ReplicatedFirst.Modules.CloneCacher)
local Network = require(ReplicatedStorage.Network)

local unreliableRemoteEvent = ReplicatedStorage:WaitForChild("UnreliableRemoteEvent", 5) :: UnreliableRemoteEvent
local assetsFolder = ReplicatedStorage:WaitForChild("Assets", 5)
local projectilesFolder = assetsFolder and assetsFolder:WaitForChild("Projectiles", 5)
local ball = projectilesFolder and projectilesFolder:WaitForChild("Ball", 5)

local tempFolder = Instance.new("Folder")
local projectiles = {} :: { [string]: { projectile: BasePart, owner: number, position: Vector3? } }
local cleanup = {}
local ballCache = CloneCacher.new(ball, 300, tempFolder)

local ShootController = {}

function ShootController:ShootEffect(origin: Vector3, direction: Vector3)
	print(`ShootEffect: {origin}, {direction}`)
	-- TODO: Particles or effect...
end

function ShootController:HitTarget(id: string, hitPart: BasePart, hitPosition: Vector3)
	print(`HitTarget: {id}, {hitPart}, {hitPosition}`)
	ShootController:CleanupProjectile(id)
end

function ShootController:PassThrough(id: string, hitPart: BasePart, hitPosition: Vector3)
	print(`PassThrough: {id}, {hitPart}, {hitPosition}`)
end

function ShootController:ShootBounce(id: string, hitPosition: Vector3)
	print(`ShootBounce: {id}, {hitPosition}`)
end

function ShootController:OnShootHit(id: string, hitPart: BasePart, hitPosition: Vector3, pass: boolean)
	print(`OnShootHit: {id}, {hitPart}, {hitPosition}`)
	if pass then
		ShootController:PassThrough(id, hitPart, hitPosition)
	elseif not hitPart then
		ShootController:ShootBounce(id, hitPosition)
	else
		ShootController:HitTarget(id, hitPart, hitPosition)
	end
end

function ShootController:ProjectileFired(id: string, owner: number, position: Vector3, direction: Vector3)
	local newProjectile = ballCache:GetPart()
	projectiles[id] = { projectile = newProjectile, owner = owner, position = position }

	newProjectile:PivotTo(CFrame.new(position, position + direction))
end

function ShootController:ProjectileUpdated(id: string, currentPos: Vector3, newPos: Vector3, owner: number)
	local projectileData = projectiles[id]
	local projectile = projectileData and projectileData.projectile
	if not projectile then
		if projectileData then
			projectileData = nil
		end
		return
	end

	if not currentPos or not newPos then
		ShootController:CleanupProjectile(id)
		return
	end

	local newPosition = projectileData.position:Lerp(newPos, 0.35)
	projectile:PivotTo(CFrame.lookAt(newPosition, newPos))
	projectiles[id].position = newPosition
end

function ShootController:CleanupProjectile(id: string)
	local projectileData = projectiles[id]
	if not projectileData then
		return
	end

	cleanup[id] = true
	-- TODO, fade etc.. animation..
	ballCache:ReturnPart(projectileData.projectile)

	task.delay(1, function()
		cleanup[id] = nil
	end)
end

function ShootController:Init()
	if not unreliableRemoteEvent then
		error("UnreliableRemoteEvent not found")
		return
	end

	unreliableRemoteEvent.OnClientEvent:Connect(
		function(data: { owner: number, id: string, currentPos: Vector3, newPos: Vector3 })
			ShootController:ProjectileUpdated(data.id, data.currentPos, data.newPos, data.owner)
		end
	)

	Network.projectileFired.OnClientEvent:Connect(function(data)
		data.
		ShootController:ProjectileFired(data.id, data.owner, data.direction, data.position)
	end)
end

return ShootController
