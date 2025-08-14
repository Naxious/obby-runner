export type SpatialHash = {
	cellSize: number,
	hashTable: { [string]: { [Model | BasePart]: boolean } },
	taggedObjects: { [Model | BasePart]: string },

	IsObjectInHash: (self: SpatialHash, object: Model | BasePart) -> boolean,
	GetCellKey: (self: SpatialHash, position: Vector3) -> string,
	Add: (self: SpatialHash, object: Model | BasePart) -> (),
	Remove: (self: SpatialHash, object: Model | BasePart) -> (),
	Update: (self: SpatialHash, object: Model | BasePart) -> (),
	Query: (self: SpatialHash, position: Vector3, radius: number) -> { Model | BasePart },
	QuerySorted: (self: SpatialHash, position: Vector3, radius: number) -> { Model | BasePart },
	QueryForNearest: (self: SpatialHash, position: Vector3, radius: number) -> Model | BasePart,
}

local SpatialHash = {}
SpatialHash.__index = SpatialHash

function SpatialHash:IsObjectInHash(object: Model | BasePart): boolean
	return self.taggedObjects[object] ~= nil
end

function SpatialHash.GetCellKey(self: SpatialHash, position: Vector3): string
	local cellX = math.floor(position.X / self.cellSize)
	local cellY = math.floor(position.Y / self.cellSize)
	local cellZ = math.floor(position.Z / self.cellSize)
	return string.format("%d,%d,%d", cellX, cellY, cellZ)
end

function SpatialHash.Add(self: SpatialHash, object)
	if self.taggedObjects[object] then
		warn(`Object ${object} is already in the spatial hash. Please call Update instead.`)
		return
	end

	local key = self:GetCellKey(object:GetPivot().Position)
	self.hashTable[key] = self.hashTable[key] or {}
	self.hashTable[key][object] = true
	self.taggedObjects[object] = key
end

function SpatialHash.Remove(self: SpatialHash, object: BasePart | Model)
	local key = self.taggedObjects[object]
	if key and self.hashTable[key] then
		self.hashTable[key][object] = nil
		if next(self.hashTable[key]) == nil then
			self.hashTable[key] = nil
		end
	end
	self.taggedObjects[object] = nil
end

function SpatialHash.Update(self: SpatialHash, object: Model | BasePart)
	if not object:GetPivot().Position then
		return
	end

	local newKey = self:GetCellKey(object:GetPivot().Position)
	local oldKey = self.taggedObjects[object]

	if newKey ~= oldKey then
		if oldKey and self.hashTable[oldKey] then
			self.hashTable[oldKey][object] = nil
			if next(self.hashTable[oldKey]) == nil then
				self.hashTable[oldKey] = nil
			end
		end

		self.hashTable[newKey] = self.hashTable[newKey] or {}
		self.hashTable[newKey][object] = true
		self.taggedObjects[object] = newKey
	end
end

function SpatialHash.Query(self: SpatialHash, position: Vector3, radius: number): { (Model | BasePart)? }
	local nearbyObjects = {}
	local radiusSquared = radius * radius
	local minX = math.floor((position.X - radius) / self.cellSize)
	local maxX = math.floor((position.X + radius) / self.cellSize)
	local minY = math.floor((position.Y - radius) / self.cellSize)
	local maxY = math.floor((position.Y + radius) / self.cellSize)
	local minZ = math.floor((position.Z - radius) / self.cellSize)
	local maxZ = math.floor((position.Z + radius) / self.cellSize)

	for x = minX, maxX do
		for y = minY, maxY do
			for z = minZ, maxZ do
				local key = string.format("%d,%d,%d", x, y, z)
				local cell = self.hashTable[key]
				if not cell then
					continue
				end

				for object in cell do
					local delta = object:GetPivot().Position - position
					if delta:Dot(delta) <= radiusSquared then
						table.insert(nearbyObjects, object)
					end
				end
			end
		end
	end

	return nearbyObjects
end

function SpatialHash.QuerySorted(self: SpatialHash, position: Vector3, radius: number): { (Model | BasePart)? }
	local nearbyObjects = self:Query(position, radius)
	table.sort(nearbyObjects, function(a, b)
		return (a:GetPivot().Position - position).Magnitude < (b:GetPivot().Position - position).Magnitude
	end)
	return nearbyObjects
end

function SpatialHash.QueryForNearest(self: SpatialHash, position: Vector3, radius: number): (Model | BasePart)?
	local closestObject = nil
	local closestDistance = math.huge

	local nearbyObjects = self:Query(position, radius)
	for _, object in nearbyObjects do
		local distance = (object:GetPivot().Position - position).Magnitude
		if distance < closestDistance then
			closestObject = object
			closestDistance = distance
		end
	end

	return closestObject
end

return {
	new = function(cellSize: number): SpatialHash
		local instance = setmetatable({
			cellSize = cellSize or 10,
			hashTable = {},
			taggedObjects = {},
		}, {
			__index = SpatialHash,
		})
		return instance
	end,
}
