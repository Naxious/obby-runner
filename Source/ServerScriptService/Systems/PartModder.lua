local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")

local PartModder = {}

function PartModder:Init()
	CollectionService:GetInstanceAddedSignal("Fast"):Connect(function(part)
		require(ServerScriptService.PartModules.Fast)(part)
	end)
	for _, part in CollectionService:GetTagged("Fast") do
		require(ServerScriptService.PartModules.Fast)(part)
	end

	CollectionService:GetInstanceAddedSignal("Slow"):Connect(function(part)
		require(ServerScriptService.PartModules.Slow)(part)
	end)
	for _, part in CollectionService:GetTagged("Slow") do
		require(ServerScriptService.PartModules.Slow)(part)
	end

	CollectionService:GetInstanceAddedSignal("Kill"):Connect(function(part)
		require(ServerScriptService.PartModules.Kill)(part)
	end)
	for _, part in CollectionService:GetTagged("Kill") do
		require(ServerScriptService.PartModules.Kill)(part)
	end
end

return PartModder
