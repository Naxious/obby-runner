local CollectionService = game:GetService("CollectionService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local PartModder = {}

function PartModder:Init()
	CollectionService:GetInstanceAddedSignal("Conveyor"):Connect(function(part)
		require(ReplicatedFirst.PartModules.Conveyor)(part)
	end)
	for _, part in ipairs(CollectionService:GetTagged("Conveyor")) do
		require(ReplicatedFirst.PartModules.Conveyor)(part)
	end

	CollectionService:GetInstanceAddedSignal("Spleef"):Connect(function(part)
		require(ReplicatedFirst.PartModules.Spleef)(part)
	end)
	for _, part in ipairs(CollectionService:GetTagged("Spleef")) do
		require(ReplicatedFirst.PartModules.Spleef)(part)
	end

	CollectionService:GetInstanceAddedSignal("Rotate"):Connect(function(part)
		require(ReplicatedFirst.PartModules.Rotate)(part)
	end)
	for _, part in ipairs(CollectionService:GetTagged("Rotate")) do
		require(ReplicatedFirst.PartModules.Rotate)(part)
	end

	CollectionService:GetInstanceAddedSignal("Oscillate"):Connect(function(part)
		require(ReplicatedFirst.PartModules.Oscillate)(part)
	end)
	for _, part in ipairs(CollectionService:GetTagged("Oscillate")) do
		require(ReplicatedFirst.PartModules.Oscillate)(part)
	end

	CollectionService:GetInstanceAddedSignal("NoJump"):Connect(function(part)
		require(ReplicatedFirst.PartModules.NoJump)(part)
	end)
	for _, part in ipairs(CollectionService:GetTagged("NoJump")) do
		require(ReplicatedFirst.PartModules.NoJump)(part)
	end
end

return PartModder
