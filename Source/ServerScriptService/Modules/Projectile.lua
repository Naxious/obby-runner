local HTTPService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local CONVERSION = 196.2 / 9.8
local HIT_TARGET_TAG = "HitTarget"
local PASS_THROUGH_TAG = "PassThrough"
local TYPE_ID_ATTRIBUTE = "TypeId"

local function createVisualPart(size: Vector3, position: Vector3, color: Color3, parent: Instance)
	local visualPart = Instance.new("Part")
	visualPart.Anchored = true
	visualPart.CanCollide = false
	visualPart.CanQuery = false
	visualPart.CanTouch = false
	visualPart.Shape = Enum.PartType.Ball
	visualPart.Size = size or Vector3.new(1, 1, 1)
	visualPart.Position = position or Vector3.new(0, 0, 0)
	visualPart.Color = color or Color3.fromRGB(255, 255, 255)
	visualPart.Material = Enum.Material.Neon
	visualPart.Parent = parent
	task.delay(10, function()
		visualPart:Destroy()
	end)
end

local Projectile = {
	targetTag = HIT_TARGET_TAG,
	passThroughTag = PASS_THROUGH_TAG,
}
Projectile.__index = Projectile

function Projectile.new(
	callbackUpdate: (...any) -> ()?, -- projectile update callback function
	callbackHit: (...any) -> ()?, -- projectile hit callback function
	gravityScale: number?, -- gravityScale
	exclude: { Instance }?, -- ignoreList
	radius: number?, -- projectile radius for sphereCast
	wind: Vector3?, -- wind for physics
	despawnTime: number?, -- time in seconds before projectile auto ends
	maxBounces: number?, -- max possible bounces
	decay: number?, -- rate of velocity upon hitting something
	threshold: number?, -- min velocity before projectile will end its life
	typeId: number?, -- typeId used to determine collision with other projectiles
	debug: boolean? -- debug to show projectile flight path
)
	local self = setmetatable({}, Projectile)
	self.id = HTTPService:GenerateGUID(false)
	self.debug = debug or false

	self.callbackUpdate = callbackUpdate or nil
	self.callbackHit = callbackHit or nil

	self.gravityScale = gravityScale or 1
	self.wind = wind or Vector3.zero
	self.exclude = exclude or {}
	self.radius = radius or 1
	self.despawnTime = despawnTime or 5
	self.maxBounces = maxBounces or 0
	self.decay = decay or 0.1
	self.threshold = threshold or 3
	self.typeId = typeId or 0

	self.params = RaycastParams.new()
	self.params.FilterType = Enum.RaycastFilterType.Exclude
	self.params.FilterDescendantsInstances = exclude or {}

	self.heartbeat = nil

	return self
end

function Projectile:GetId()
	return self.id
end

function Projectile:StopProjectile(hitResult: RaycastResult, bulletDone: boolean)
	if self.heartbeat then
		self.heartbeat:Disconnect()

		if not bulletDone then
			if typeof(self.callbackUpdate) == "function" then
				self.callbackUpdate(self.id, nil, nil)
			end
		end

		if not hitResult then
			return
		end

		if self.debug then
			createVisualPart(Vector3.new(1, 1, 1), hitResult.Position, Color3.fromRGB(255, 0, 0), workspace)
		end
	end
end

function Projectile:HitTarget(target: BasePart, passThrough: boolean)
	if typeof(self.callbackHit) == "function" then
		self.callbackHit(self.id, target, passThrough)
	end
end

function Projectile:Cast(start: Vector3, destination: Vector3, initialVelocity: number)
	-- local velocity = (destination - start).Unit * initialVelocity * CONVERSION
	local velocity = destination * initialVelocity
	local a = Vector3.new(self.wind.X, self.wind.Y - self.gravityScale * 9.8, self.wind.Z) * CONVERSION

	local totalTime = 0
	local t = 0
	local currentPosition = start
	local rayResult = nil
	local bounces = 0

	local passThrough = {}

	local hitDebounce = {}

	local currentVelocity

	local debug = false
	if debug then
		local currentPos = start
		local currentAim = velocity
		for i = 1, 10 do
			local part = Instance.new("Part")
			part.Name = "PINK"
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Color = Color3.new(1, 0, 0.815686)
			part.Transparency = 0.5
			part.Material = Enum.Material.Neon
			part.Size = Vector3.new(0.5, 0.2, 0.5)
			part.Position = currentPos
			part.Anchored = true
			part.Parent = workspace

			currentPos += currentAim * 1
			task.delay(10, function()
				part:Destroy()
			end)
		end
	end

	self.heartbeat = RunService.Heartbeat:Connect(function(deltaTime)
		t += deltaTime
		totalTime += deltaTime

		currentVelocity = velocity + a * t

		local projectedPosition = Vector3.new(
			start.X + velocity.X * t + 0.5 * a.X * t * t,
			start.Y + velocity.Y * t + 0.5 * a.Y * t * t,
			start.Z + velocity.Z * t + 0.5 * a.Z * t * t
		)

		if projectedPosition.Y <= -100 then
			self:StopProjectile(nil, true)
			return
		end

		rayResult =
			workspace:Spherecast(currentPosition, self.radius * 0.5, projectedPosition - currentPosition, self.params)

		if typeof(self.callbackUpdate) == "function" then
			self.callbackUpdate(self.id, currentPosition, projectedPosition)
		end

		currentPosition = projectedPosition

		if rayResult then
			local instance = rayResult.Instance

			if hitDebounce[instance] then
				return
			end

			local typeId = instance:GetAttribute(TYPE_ID_ATTRIBUTE)

			if instance:HasTag(HIT_TARGET_TAG) then
				hitDebounce[instance] = instance

				task.delay(self.despawnTime, function()
					hitDebounce[instance] = nil
				end)

				local passThroughAttribute = instance:GetAttribute(PASS_THROUGH_TAG)
				if passThroughAttribute and self.typeId ~= typeId then
					passThrough[instance] = instance
					self:HitTarget(instance, true)
				elseif self.typeId == typeId or self.typeId == 2 then
					self:HitTarget(instance, false)
				else
					self:HitTarget(instance, false)
					self:StopProjectile(rayResult, true)
				end
			end

			if passThrough[instance] then
				return
			end

			if bounces >= self.maxBounces then
				self:StopProjectile(rayResult, false)
				return
			end

			local normal = rayResult.Normal
			velocity = self.decay * (currentVelocity - 2 * (currentVelocity:Dot(normal)) * normal)

			if velocity.Magnitude < self.threshold then
				self:StopProjectile(rayResult, false)
				return
			end

			start = rayResult.Position + normal * self.radius
			currentPosition = start
			t = 0

			bounces += 1

			-- Hit Something: rayResult.Position
			if self.debug then
				createVisualPart(Vector3.new(1, 1, 1), rayResult.Position, Color3.fromRGB(255, 196, 0), workspace)
			end
		end

		-- FlightPath: currentPosition
		if self.debug then
			createVisualPart(Vector3.new(0.2, 0.2, 0.2), currentPosition, Color3.fromRGB(37, 255, 3), workspace)
		end

		if totalTime > self.despawnTime then
			self:StopProjectile(rayResult, false)
		end
	end)
end

return Projectile
