local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local activePortals = {}
local playerDebounce = {}

local Portals = {}

function Portals:OnPortalTouched(portal, hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	if playerDebounce[player] then
		return
	end
	playerDebounce[player] = true
	task.delay(1, function()
		playerDebounce[player] = false
	end)

	if activePortals[portal] then
		character:PivotTo(activePortals[portal].Destination:GetPivot())
	end
end

function Portals:AddPortal(portal)
	assert(portal:IsA("BasePart"), "Invalid portal type, portal must be a BasePart")

	local objectValue = portal:FindFirstChildWhichIsA("ObjectValue")
	assert(objectValue, "Portal is missing ObjectValue")

	if not objectValue.Value or not objectValue.Value:IsA("BasePart") then
		warn("Portal's Destination is invalid")
		return
	end

	activePortals[portal] = {
		Destination = objectValue.Value,
		connections = {},
	}

	portal.Touched:Connect(function(hit)
		Portals:OnPortalTouched(portal, hit)
	end)
end

function Portals:RemovePortal(portal)
	activePortals[portal] = nil
end

function Portals:Init()
	CollectionService:GetInstanceAddedSignal("Portal"):Connect(function(portal)
		Portals:AddPortal(portal)
	end)

	for _, portal in CollectionService:GetTagged("Portal") do
		Portals:AddPortal(portal)
	end

	CollectionService:GetInstanceRemovedSignal("Portal"):Connect(function(portal)
		Portals:RemovePortal(portal)
	end)
end

return Portals
