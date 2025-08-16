local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ReplicatedStorage.Network)
local Dropper = require(ServerScriptService.Systems.Dropper)

type turret = Model & {
	VehicleSeat: VehicleSeat,
	Rotor: BasePart & {
		Motor6D: Motor6D,
	},
	Base: BasePart,
	Barrel: BasePart & {
		Attachment: Attachment,
	},
}

local TURRET_MOTOR_SPEED = 35
local TURRET_LERP = 0.2

local YAW_SPEED = math.rad(TURRET_MOTOR_SPEED)
local YAW_MIN = math.rad(-65) -- right limit
local YAW_MAX = math.rad(65) -- left limit
local PITCH_SPEED = math.rad(TURRET_MOTOR_SPEED)
local PITCH_MIN = math.rad(-25) -- up limit
local PITCH_MAX = math.rad(40) -- down limit

local activeTurrets = {}

local TurretService = {}

function TurretService:FireTurret(player, turret: turret)
	local character = player.Character
	if not character then
		return
	end

	if not activeTurrets[turret] then
		warn("Attempted to fire a turret that is not active:", turret.Name)
		return
	end

	local seat = turret.VehicleSeat
	if not seat or not seat:IsA("VehicleSeat") then
		warn("Invalid turret: Missing or incorrect VehicleSeat")
		return
	end

	local occupiedHumanoid = seat.Occupant :: Humanoid
	local turretCharacter = occupiedHumanoid and occupiedHumanoid.Parent
	if turretCharacter ~= character then
		warn("Player attempted to fire a turret they are not occupying")
		return
	end

	local aim = turret.Barrel.Attachment.WorldCFrame.LookVector
	local origin = turret.Barrel.Attachment.WorldPosition

	Dropper:TurretFire(aim, origin)
end

function TurretService:AddTurret(turret: turret)
	local seat = turret.VehicleSeat
	local rotor = turret.Rotor
	local base = turret.Base
	local motor = rotor and rotor.Motor6D
	if not seat or not seat:IsA("VehicleSeat") then
		warn("Invalid turret: Missing or incorrect VehicleSeat")
		return
	end
	if not base then
		warn("Invalid turret: Missing or incorrect Base")
		return
	end
	if not rotor or not rotor:IsA("BasePart") then
		warn("Invalid turret: Missing or incorrect Rotor")
		return
	end
	if not motor or not motor:IsA("Motor6D") then
		warn("Invalid turret: Missing or incorrect Motor6D")
		return
	end

	local yaw = 0
	local pitch = 0

	local basePivot = base:GetPivot()

	motor.C0 = CFrame.new(0, 0, 0)

	local turretData = {}

	turretData["SeatConnection"] = seat.Changed:Connect(function()
		-- Handle seat changes here
	end)

	turretData["AimConnection"] = RunService.Stepped:Connect(function(_, deltaTime: number)
		yaw += -seat.Steer * YAW_SPEED * deltaTime
		yaw = math.clamp(yaw, YAW_MIN, YAW_MAX)

		pitch += seat.Throttle * PITCH_SPEED * deltaTime
		pitch = math.clamp(pitch, PITCH_MIN, PITCH_MAX)

		local newBasePivot = base:GetPivot():Lerp(basePivot * CFrame.Angles(0, yaw, 0), TURRET_LERP)
		base:PivotTo(newBasePivot)

		local newMotorC1 = motor.C1:Lerp(CFrame.Angles(0, 0, pitch), TURRET_LERP)
		motor.C1 = newMotorC1
	end)

	activeTurrets[turret] = turretData
end

function TurretService:Init()
	CollectionService:GetInstanceAddedSignal("Turret"):Connect(function(turret)
		TurretService:AddTurret(turret)
	end)
	for _, turret in CollectionService:GetTagged("Turret") do
		TurretService:AddTurret(turret)
	end

	Network.fireTurret.OnServerEvent:Connect(function(player, turret)
		TurretService:FireTurret(player, turret)
	end)
end

return TurretService
