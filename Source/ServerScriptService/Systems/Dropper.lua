local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local CollisionManager = require(ServerScriptService.Systems.CollisionManager)
local Ragdoll = require(ServerScriptService.Systems.Ragdoll)

type DropperData = {
	lookVector: Vector3,
	position: Vector3,
	power: number,
	minFrequency: number,
	maxFrequency: number,
	dropName: string,
	lastDropped: number,
}

type Drop = {
	lastPosition: Vector3,
	timeStill: number,
	isStill: boolean,
	connections: { RBXScriptConnection },
}

local DROP_RATE_CHECK = 0.1
local STILL_TIME_THRESHOLD = 0.2
local ACTIVE_DROP_CHECK = 0.1
local PLAYER_HIT_DEBOUNCE_TIME = 2

local activeDroppers = {} :: { [BasePart]: DropperData }
local activeDrops = {} :: { [BasePart]: Drop }
local dropperCheckCount = 0
local dropCheckCount = 0
local playerDebounces = {} :: { [Player]: boolean }

local Dropper = {
	runnerHit = Instance.new("BindableEvent"),
	shooterHit = Instance.new("BindableEvent"),
}

function Dropper:TurretFire(aim: Vector3, origin: Vector3, player: Player, parent)
	local drop = Dropper:CreateDrop({
		lookVector = aim,
		position = origin,
		power = 100,
		minFrequency = 1,
		maxFrequency = 5,
		dropName = "Ball",
		lastDropped = 0,
	}, player.UserId)

	drop.Parent = parent.Parent
	local ball = drop.BALL :: BasePart
	for _, child in drop:GetChildren() do
		if child:IsA("BasePart") then
			child.Transparency = 1
		end
	end
	ball:ApplyImpulse(aim * 10000)

	for _, child in drop:GetChildren() do
		if child:IsA("BasePart") then
			if child.Name == "BALL" then
				child.Transparency = 1
			else
				child.Transparency = 0
			end
		end
	end
end

function Dropper:DropHitPlayer(drop: BasePart, player: Player)
	local character = player.Character
	if not character then
		return
	end

	local dropName = drop.Name
	if dropName == "Ball" then
		Ragdoll:StartRagdoll(character, 1.5)
	elseif dropName == "Bomb" then
		Ragdoll:StartRagdoll(character, 2.5)
	else
		warn(`Dropper: Drop "{dropName}" does not have a defined effect on players.`)
	end

	Dropper.runnerHit:Fire(player)
	-- TODO: Add Hit tally to player.. (3 hits, and they lose unless spending a heart)

	local ownerId = drop:GetAttribute("owner")
	if not ownerId or ownerId == player.UserId then
		return
	end

	local ownerPlayer = Players:GetPlayerByUserId(ownerId)
	if not ownerPlayer then
		return
	end

	Dropper.shooterHit:Fire(ownerPlayer)

	-- TODO: Implement owner-specific effects
	-- check if owner is a shooter.. add score
end

function Dropper:RemoveDrop(drop: BasePart)
	assert(drop:IsA("BasePart"), "Invalid drop type")
	if not activeDrops[drop] then
		return
	end

	activeDrops[drop] = nil
	drop:Destroy()
end

function Dropper:UpdateDrops(deltaTime: number)
	dropCheckCount += deltaTime
	if dropCheckCount < ACTIVE_DROP_CHECK then
		return
	end
	dropCheckCount -= ACTIVE_DROP_CHECK

	local currentTime = os.clock()

	for drop, data in activeDrops do
		local currentPosition = drop.BALL:GetPivot().Position
		local positionChange = (currentPosition - data.lastPosition).Magnitude
		local isStill = false
		if positionChange < 0.05 then
			if not data.isStill then
				data.timeStill = os.clock()
			end
			isStill = true
		else
			data.timeStill = os.clock() + STILL_TIME_THRESHOLD
			isStill = false
		end

		data.lastPosition = currentPosition
		data.isStill = isStill

		if isStill and currentTime - data.timeStill >= STILL_TIME_THRESHOLD then
			activeDrops[drop] = nil
			drop:Destroy()
		end

		if currentPosition.Y < 200 then
			activeDrops[drop] = nil
			drop:Destroy()
		end
	end
end

function Dropper:CreateDrop(dropperData: DropperData, owner: number?)
	local dropPosition = dropperData.position
	local drop = ReplicatedStorage.Assets.SpawnParts:FindFirstChild(dropperData.dropName):Clone()
	drop:PivotTo(CFrame.new(dropPosition))

	CollisionManager:AddModelToCollisionGroup(drop, CollisionManager.CollisionGroups.drop)

	if owner then
		drop:SetAttribute("owner", owner)
	end

	local ball = drop:FindFirstChild("BALL")
	if not ball then
		warn(`Dropper "{dropperData.dropName}" is missing the BALL part.`)
		return nil
	end

	local data: Drop = {
		lastPosition = dropPosition,
		timeStill = 0,
		isStill = false,
		connections = {},
	}

	table.insert(
		data.connections,
		ball.Touched:Connect(function(hit)
			if hit:IsA("BasePart") and hit.Parent and hit.Parent:IsA("Model") then
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if player and not playerDebounces[player] then
					playerDebounces[player] = true
					Dropper:DropHitPlayer(drop, player)
					task.delay(PLAYER_HIT_DEBOUNCE_TIME, function()
						playerDebounces[player] = false
					end)
				end
			end
		end)
	)

	activeDrops[drop] = data
	return drop
end

function Dropper:Drop(dropperData: DropperData)
	local drop = Dropper:CreateDrop(dropperData)
	if not drop then
		return
	end
	drop.Parent = workspace

	dropperData.lastDropped = tick()
end

function Dropper:Update(deltaTime: number)
	dropperCheckCount += deltaTime
	if dropperCheckCount < DROP_RATE_CHECK then
		return
	end
	dropperCheckCount -= DROP_RATE_CHECK

	local currentTime = tick()
	for dropper, data in activeDroppers do
		local timeSinceLastDrop = currentTime - data.lastDropped
		local didDrop = false
		if timeSinceLastDrop >= data.minFrequency then
			local shouldDrop = math.random() < 0.3
			if shouldDrop then
				Dropper:Drop(data)

				data.lastDropped = currentTime
				didDrop = true
			end
		end

		if not didDrop and timeSinceLastDrop >= data.maxFrequency then
			data.lastDropped = currentTime
			Dropper:Drop(data)
		end
	end
end

function Dropper:AddDropper(dropper: BasePart)
	assert(dropper:IsA("BasePart"), "Invalid dropper type")
	local mapFolder = workspace:FindFirstChild("MapWorkspace")
	if not mapFolder then
		warn("MapWorkspace not found in workspace. Cannot add dropper.")
		return
	end
	if not dropper:IsDescendantOf(mapFolder) then
		return
	end

	local drop = dropper:GetAttribute("drop")
	local minFrequency = dropper:GetAttribute("minFrequency")
	local maxFrequency = dropper:GetAttribute("maxFrequency")
	local power = dropper:GetAttribute("power")
	if not drop or not minFrequency or not maxFrequency or not power then
		warn(`Dropper "{dropper.Name}" is missing required attributes.`)
		return
	end

	if not ReplicatedStorage.Assets.SpawnParts:FindFirstChild(drop) then
		warn(`Dropper "{dropper:GetFullName()}" has an invalid drop type: {drop}.`, dropper)
		return
	end

	local dropperCFrame = dropper:GetPivot()

	local dropperData: DropperData = {
		lookVector = dropperCFrame.LookVector,
		position = dropperCFrame.Position,
		power = power or 1,
		minFrequency = minFrequency or 1,
		maxFrequency = maxFrequency or 1,
		dropName = drop or "Ball_Template",
		lastDropped = tick(),
	}

	activeDroppers[dropper] = dropperData
end

function Dropper:RemoveDropper(dropper: BasePart)
	CollectionService:RemoveTag(dropper, "Dropper")
	activeDroppers[dropper] = nil
end

function Dropper:Init()
	CollectionService:GetInstanceAddedSignal("Dropper"):Connect(function(dropper)
		Dropper:AddDropper(dropper)
	end)

	local droppers = CollectionService:GetTagged("Dropper")
	for _, dropper in droppers do
		Dropper:AddDropper(dropper)
	end

	CollectionService:GetInstanceRemovedSignal("Dropper"):Connect(function(dropper)
		Dropper:RemoveDropper(dropper)
	end)

	RunService.Heartbeat:Connect(function(deltaTime)
		Dropper:Update(deltaTime)
		Dropper:UpdateDrops(deltaTime)
	end)
end

return Dropper
