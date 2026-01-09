--!strict
local CloneCacher = {}
CloneCacher.__index = CloneCacher
CloneCacher.__type = "CloneCache"

export type CloneCache = {
	Open: { [BasePart]: boolean },
	InUse: { [BasePart]: boolean },
	CurrentCacheParent: Instance,
	Template: BasePart,
	ExpansionSize: number,
	GetPart: (self: CloneCache) -> BasePart,
	ReturnPart: (self: CloneCache, part: BasePart) -> (),
	SetCacheParent: (self: CloneCache, newParent: Instance) -> (),
	Expand: (self: CloneCache, numParts: number?) -> (),
	Dispose: (self: CloneCache) -> (),
}

local CF_REALLY_FAR_AWAY = CFrame.new(0, 10e8, 0)

local function cloneTemplate(template: BasePart, cacheParent: Instance): BasePart
	local part: BasePart = template:Clone()
	part.CFrame = CF_REALLY_FAR_AWAY
	part.Anchored = true
	part.Parent = cacheParent
	return part
end

function CloneCacher.new(template: BasePart, cacheAmount: number, cacheParent: Instance): CloneCache
	assert(
		typeof(cacheAmount) == "number" and cacheAmount > 0,
		`Cache amount must be a positive number. Got ${cacheAmount} instead.`
	)
	assert(typeof(cacheParent) == "Instance", `Cache parent must be an instance. Got ${cacheParent} instead.`)
	cacheParent.Parent = workspace

	template = cloneTemplate(template, cacheParent)

	local object = setmetatable(
		{
			Open = {},
			InUse = {},
			CacheParent = cacheParent,
			Template = template,
			ExpansionSize = 10,
		} :: any,
		CloneCacher
	) :: CloneCache

	for _ = 1, cacheAmount do
		local part = cloneTemplate(template, cacheParent)
		object.Open[part] = true
	end

	return object
end

function CloneCacher:GetPart(): BasePart?
	local part, _ = next(self.Open)
	if not part then
		self:Expand(self.ExpansionSize)
		part, _ = next(self.Open)
	end
	self.Open[part] = nil
	self.InUse[part] = true

	return part
end

function CloneCacher:ReturnPart(part: BasePart)
	if self.InUse[part] then
		self.InUse[part] = nil
		self.Open[part] = true
		part.CFrame = CF_REALLY_FAR_AWAY
		part.Anchored = true
	else
		error("Part not in use: " .. part:GetFullName())
	end
end

function CloneCacher:SetCacheParent(newParent: Instance)
	assert(newParent:IsDescendantOf(workspace), "Cache parent must be in the workspace.")
	self.CurrentCacheParent = newParent
	for part in self.Open do
		part.Parent = newParent
	end
	for part in self.InUse do
		part.Parent = newParent
	end
end

function CloneCacher:Expand(numParts: number)
	for _ = 1, numParts or self.ExpansionSize do
		local part = cloneTemplate(self.Template, self.CurrentCacheParent)
		self.Open[part] = true
	end
end

function CloneCacher:Dispose()
	for part in self.Open do
		part:Destroy()
	end
	for part in self.InUse do
		part:Destroy()
	end
	self.Template:Destroy()
	self.Open = {}
	self.InUse = {}
	self.CurrentCacheParent = nil
end

return CloneCacher
