local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerObservers = require(ServerScriptService.ServerObservers)

local trackedAreas = {} :: { [string]: { parts: { BasePart }, region: Region3 } }
local playerAreas = {} :: { [Player]: { string } }

local AREA_TAG = "Area"
local AREA_NAME_ATTRIBUTE = "Area"
local AREA_SIZE_MARGIN = Vector3.zero

local function isPointInPart(point: Vector3, part: BasePart): boolean
	local partCFrame = part:GetPivot()
	local partSize = part.Size + AREA_SIZE_MARGIN
	local localPoint = partCFrame:pointToObjectSpace(point)
	return math.abs(localPoint.X) <= partSize.X / 2
		and math.abs(localPoint.Y) <= partSize.Y / 2
		and math.abs(localPoint.Z) <= partSize.Z / 2
end

local function isPointInRegion(point: Vector3, region: Region3): boolean
	local min = region.CFrame.Position - ((region.Size + AREA_SIZE_MARGIN) / 2)
	local max = region.CFrame.Position + ((region.Size + AREA_SIZE_MARGIN) / 2)
	return point.X >= min.X
		and point.X <= max.X
		and point.Y >= min.Y
		and point.Y <= max.Y
		and point.Z >= min.Z
		and point.Z <= max.Z
end

local function computeRegion(parts: { BasePart }): Region3
	local minBound = Vector3.new(math.huge, math.huge, math.huge)
	local maxBound = Vector3.new(-math.huge, -math.huge, -math.huge)

	for _, part in parts do
		if not part:IsA("BasePart") then
			continue
		end

		local partCFrame = part.CFrame
		local partSize = part.Size
		local corners = {}

		for x = -0.5, 0.5, 1 do
			for y = -0.5, 0.5, 1 do
				for z = -0.5, 0.5, 1 do
					local corner =
						partCFrame:PointToWorldSpace(Vector3.new(x * partSize.X, y * partSize.Y, z * partSize.Z))
					table.insert(corners, corner)
				end
			end
		end

		for _, corner in corners do
			minBound = Vector3.new(
				math.min(minBound.X, corner.X),
				math.min(minBound.Y, corner.Y),
				math.min(minBound.Z, corner.Z)
			)
			maxBound = Vector3.new(
				math.max(maxBound.X, corner.X),
				math.max(maxBound.Y, corner.Y),
				math.max(maxBound.Z, corner.Z)
			)
		end
	end

	return Region3.new(minBound, maxBound)
end

local AreaService = {}

function AreaService:GetPlayersInArea(area: string): { Player }
	local playersInArea = {}
	for player, areas in playerAreas do
		if areas[area] then
			table.insert(playersInArea, player)
		end
	end
	return playersInArea
end

function AreaService:OnPlayerEntered(player: Player, area: string)
	-- print(player.Name .. " entered area: " .. area)
	ServerObservers.enteredArea:Fire(player, area)
end

function AreaService:OnPlayerExited(player: Player, area: string)
	-- print(player.Name .. " exited area: " .. area)
	ServerObservers.exitedArea:Fire(player, area)
end

function AreaService:AddArea(part: BasePart)
	if not part:IsA("BasePart") then
		return
	end

	local areaName = part:GetAttribute(AREA_NAME_ATTRIBUTE)
	if not areaName then
		error(`Area part {part.Name} does not have an 'Area' name attribute`)
	end

	if not trackedAreas[areaName] then
		local region = computeRegion({ part })
		trackedAreas[areaName] = {
			region = region,
			parts = { part },
		}
	else
		local areaData = trackedAreas[areaName]
		table.insert(areaData.parts, part)
		areaData.region = computeRegion(areaData.parts)
	end

	part.Transparency = 1
end

function AreaService:RemoveArea(part: BasePart)
	-- TODO: Implement removal logic
end

function AreaService:Init()
	CollectionService:GetInstanceAddedSignal(AREA_TAG):Connect(function(part)
		AreaService:AddArea(part)
	end)

	CollectionService:GetInstanceRemovedSignal(AREA_TAG):Connect(function(part)
		AreaService:RemoveArea(part)
	end)

	for _, part in CollectionService:GetTagged(AREA_TAG) do
		AreaService:AddArea(part)
	end

	RunService.Heartbeat:Connect(function()
		for _, player in Players:GetPlayers() do
			local character = player.Character
			local position = character and character:GetPivot().Position
			if not position then
				continue
			end

			local previousAreas = playerAreas[player] or {}
			local currentAreas = {}

			for areaName, areaData in trackedAreas do
				if isPointInRegion(position, areaData.region) then
					local inArea = false
					for _, part in areaData.parts do
						if isPointInPart(position, part) then
							inArea = true
							currentAreas[areaName] = true
							if not previousAreas[areaName] then
								AreaService:OnPlayerEntered(player, areaName)
							end
							break
						end
					end
					if not inArea and previousAreas[areaName] then
						AreaService:OnPlayerExited(player, areaName)
					end
				else
					if previousAreas[areaName] then
						AreaService:OnPlayerExited(player, areaName)
					end
				end
			end

			playerAreas[player] = currentAreas
		end
	end)
end

return AreaService
