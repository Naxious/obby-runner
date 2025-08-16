local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local ClientObservers = require(ReplicatedFirst.ClientObservers)

local AREA_TAG = "Area"
local AREA_NAME_ATTRIBUTE = "Area"
local AREA_SIZE_MARGIN = Vector3.new(2, 2, 2)

local localPlayer = Players.LocalPlayer
local myAreas = {}
local trackedAreas = {}

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

-- local function preventEntry(character: Model, areaPart: Part)
-- 	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
-- 	if not humanoidRootPart then
-- 		return
-- 	end

-- 	local pushDirection = (character:GetPivot().Position - areaPart.Position).Unit
-- 	local pushForce = 50

-- 	humanoidRootPart.Velocity = pushDirection * pushForce
-- end

local Area = {}

function Area:Entered(areaName: string)
	ClientObservers.enteredArea:Fire(areaName)
end

function Area:Exited(areaName: string)
	ClientObservers.exitedArea:Fire(areaName)
end

function Area:AddArea(part: BasePart)
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

function Area:RemoveArea(part: BasePart)
	-- TODO: Implement removal logic
end

function Area:Init()
	CollectionService:GetInstanceAddedSignal(AREA_TAG):Connect(function(part)
		Area:AddArea(part)
	end)

	CollectionService:GetInstanceRemovedSignal(AREA_TAG):Connect(function(part)
		Area:RemoveArea(part)
	end)

	for _, part in CollectionService:GetTagged(AREA_TAG) do
		Area:AddArea(part)
	end

	RunService.Heartbeat:Connect(function()
		local character = localPlayer.Character
		local position = character and character:GetPivot().Position
		if not position then
			return
		end

		local currentAreas = {}
		for areaName, areaData in trackedAreas do
			if isPointInRegion(position, areaData.region) then
				for _, part in areaData.parts do
					if isPointInPart(position, part) then
						currentAreas[areaName] = true
						if not myAreas[areaName] then
							-- if not unlockedAreas[areaName] then
							-- 	preventEntry(character, part)
							-- 	continue
							-- end
							myAreas[areaName] = true
							Area:Entered(areaName)
						end
						break
					end
				end
			end
		end

		for areaName in myAreas do
			if not currentAreas[areaName] then
				myAreas[areaName] = nil
				Area:Exited(areaName)
			end
		end
	end)
end

return Area
