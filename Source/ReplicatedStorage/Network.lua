local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bolt = require(ReplicatedStorage:WaitForChild("Libraries"):WaitForChild("Bolt"))

local Network = {
	mapTest = Bolt.ReliableEvent("MapTest"),
	ragdoll = Bolt.ReliableEvent("Ragdoll") :: Bolt.ReliableEvent<{ state: string, time: number? }>,
	toggleAFK = Bolt.ReliableEvent("ToggleAFK") :: Bolt.ReliableEvent<boolean>,

	fireTurret = Bolt.ReliableEvent("FireTurret") :: Bolt.ReliableEvent<Model>,
	hitTarget = Bolt.ReliableEvent("HitTarget") :: Bolt.ReliableEvent<{
		id: string,
		hitPart: BasePart,
		pass: boolean,
		position: Vector3,
	}>,
	projectileFired = Bolt.ReliableEvent("ProjectileFired") :: Bolt.ReliableEvent<{
		owner: number,
		id: string,
		position: Vector3,
		direction: Vector3,
	}>,
	requestTrailChest = Bolt.ReliableEvent("RequestTrailChest") :: Bolt.ReliableEvent<>,
	openTrailChest = Bolt.ReliableEvent("OpenTrailChest") :: Bolt.ReliableEvent<string, string>,
	equipTrail = Bolt.ReliableEvent("EquipTrail") :: Bolt.ReliableEvent<string>,

	-- remote properties
	coins = Bolt.RemoteProperty("Coins", 0),
	hearts = Bolt.RemoteProperty("Hearts", 0),

	runnerHits = Bolt.RemoteProperty("RunnerHits", -1),
	shooterHits = Bolt.RemoteProperty("ShooterHits", -1),

	trailData = Bolt.RemoteProperty("TrailData", {}),
	equippedTrail = Bolt.RemoteProperty("EquippedTrail", ""),
}

return Network
