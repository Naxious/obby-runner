--!strict
local RunService = game:GetService("RunService")

type Timer = {
	_stoppedBindable: BindableEvent,
	_steppedBindable: BindableEvent,

	running: boolean,
	defaultDuration: number,
	remaining: number,
	heartbeat: RBXScriptConnection?,
	Stopped: RBXScriptSignal,
	Stepped: RBXScriptSignal,

	Start: (self: Timer, duration: number?) -> (),
	Stop: (self: Timer) -> (),
	Destroy: (self: Timer) -> (),
}

local INCREMENT = 0.1

local Timer = {} :: Timer

function Timer.Start(self: Timer, duration: number?)
	if self.running then
		warn(`Timer is already running`)
		return
	end
	self.running = true
	self.remaining = duration or self.defaultDuration

	self._steppedBindable:Fire(self.remaining)

	local incrementCounter = INCREMENT
	self.heartbeat = RunService.Heartbeat:Connect(function(deltaTime)
		incrementCounter += deltaTime
		if incrementCounter < INCREMENT then
			return
		end
		incrementCounter -= INCREMENT

		self.remaining -= INCREMENT
		self.remaining = math.max(0, math.floor(self.remaining * 10) / 10)

		self._steppedBindable:Fire(self.remaining)

		if self.remaining <= 0 then
			self:Stop()
		end
	end)
end

function Timer.Stop(self: Timer)
	if not self.running then
		warn(`Timer is not running`)
		return
	end
	self.running = false
	self.remaining = 0
	if self.heartbeat then
		self.heartbeat:Disconnect()
		self.heartbeat = nil
	end
	self._stoppedBindable:Fire("Stopped")
end

function Timer.Destroy(self: Timer)
	if self.running then
		self:Stop()
	end
	self._stoppedBindable:Fire("Destroy")
end

return {
	new = function(duration: number?): Timer
		local stoppedBindable = Instance.new("BindableEvent")
		local steppedBindable = Instance.new("BindableEvent")

		local instance = setmetatable(
			{
				_stoppedBindable = stoppedBindable,
				_steppedBindable = steppedBindable,

				running = false,
				defaultDuration = duration or 1,
				remaining = 0,
				heartbeat = nil,
				Stopped = stoppedBindable.Event,
				Stepped = steppedBindable.Event,
			} :: any,
			{ __index = Timer }
		) :: Timer

		stoppedBindable.Event:Connect(function(reason: string)
			if reason == "Destroy" then
				if instance.heartbeat then
					instance.heartbeat:Disconnect()
					instance.heartbeat = nil
				end

				stoppedBindable:Destroy()
				instance = nil :: any
			end
		end)

		return instance
	end,
}
