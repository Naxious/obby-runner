local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local DO_PLAYERS_COLLIDE = false

local CollisionManager = {
	Name = "CollisionManager",
	Icon = "⏹️",
	Priority = 0,

	CollisionGroups = {
		players = "players",
		drop = "drop",
	},
}

function setupCollisionGroups(self: CollisionManager)
	for _, groupName in self.CollisionGroups do
		PhysicsService:RegisterCollisionGroup(groupName)
	end
end

function setCollisionGroupsCollidable(self: CollisionManager, group1: string, group2: string, collidable: boolean)
	if not self.CollisionGroups[group1] or not self.CollisionGroups[group2] then
		warn(`{group1} or {group2} is not a valid collision group`)
		return
	end

	PhysicsService:CollisionGroupSetCollidable(group1, group2, collidable)
end

function CollisionManager.AddPartToCollisionGroup(self: CollisionManager, part: BasePart, groupName: string)
	if not self.CollisionGroups[groupName] then
		warn(`{groupName} is not a valid collision group`)
		return
	end
	part.CollisionGroup = groupName
end

function CollisionManager.AddModelToCollisionGroup(self: CollisionManager, model: Model, groupName: string)
	if not self.CollisionGroups[groupName] then
		warn(`{groupName} is not a valid collision group`)
		return
	end

	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.CollisionGroup = groupName
		end
	end
end

function CollisionManager.RemovePartFromCollisionGroup(_self: CollisionManager, part: BasePart)
	part.CollisionGroup = ""
end

function CollisionManager.RemoveModelFromCollisionGroup(_self: CollisionManager, model: Model)
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.CollisionGroup = ""
		end
	end
end

function CollisionManager.Init(self: CollisionManager)
	setupCollisionGroups(self)

	setCollisionGroupsCollidable(self, self.CollisionGroups.players, self.CollisionGroups.drop, false)
	setCollisionGroupsCollidable(self, self.CollisionGroups.players, self.CollisionGroups.players, DO_PLAYERS_COLLIDE)

	for _, player in Players:GetPlayers() do
		local character = player.Character
		if character then
			self:AddModelToCollisionGroup(character, self.CollisionGroups.players)
		end
	end

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			self:AddModelToCollisionGroup(character, self.CollisionGroups.players)
		end)
	end)
end

export type CollisionManager = typeof(CollisionManager)

return CollisionManager
