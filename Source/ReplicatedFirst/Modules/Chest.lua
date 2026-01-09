local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Springer = require(ReplicatedStorage.Packages.Springer)

export type ChestInstance = Model & {
	Lid: Model,
}

export type Chest = {
	instance: ChestInstance,
	id: string,
	lidSpring: Springer.Springer,
	lidPivot: CFrame,

	Open: (self: Chest, item: Model | BasePart) -> (),
	Close: (self: Chest) -> (),
	RevealItem: (self: Chest, item: Model | BasePart) -> (),
}

local CHEST_OPEN_DISTANCE = 120
local REWARD_LIFT_DISTANCE = 3.5

local addedChests = {} :: { [string]: Chest }

local Chest = {}

function Chest.RevealItem(self: Chest, item: Model | BasePart)
	local itemClone = item:Clone()
	itemClone:PivotTo(self.instance:GetPivot() + Vector3.new(0, -1, 0))
	itemClone.Parent = workspace

	local revealTween = TweenService:Create(
		itemClone,
		TweenInfo.new(1),
		{ CFrame = itemClone.CFrame + Vector3.new(0, REWARD_LIFT_DISTANCE, 0) }
	)
	revealTween:Play()

	task.delay(3, function()
		itemClone:Destroy()
		self:Close()
	end)
end

function Chest.Open(self: Chest, item: Model | BasePart)
	self.lidSpring.value = 0
	self.lidSpring:SetTarget(1, 2, 0.4)
	local renderConnection
	self:RevealItem(item)
	renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
		local openAngle = self.lidSpring.value * CHEST_OPEN_DISTANCE
		self.instance.Lid:PivotTo(self.lidPivot * CFrame.Angles(0, 0, math.rad(openAngle)))
		if not self.lidSpring.isActive then
			renderConnection:Disconnect()
		end
	end)
end

function Chest.Close(self: Chest)
	self.lidSpring.value = 1
	self.lidSpring:SetTarget(0, 1.2, 1)
	local renderConnection
	renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
		local closeAngle = self.lidSpring.value * CHEST_OPEN_DISTANCE
		self.instance.Lid:PivotTo(self.lidPivot * CFrame.Angles(0, 0, math.rad(closeAngle)))
		if not self.lidSpring.isActive then
			renderConnection:Disconnect()
			self.instance.Lid:PivotTo(self.lidPivot)
		end
	end)
end

return {
	new = function(chest: ChestInstance, id: string)
		local self = setmetatable({
			instance = chest,
			id = id,
			lidSpring = Springer.new(0),
			lidPivot = chest.Lid:GetPivot(),
		}, { __index = Chest })

		addedChests[id] = self

		return self
	end,

	getChest = function(id: string): Chest?
		return addedChests[id]
	end,
}
