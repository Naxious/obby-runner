local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bolt = require(ReplicatedStorage:WaitForChild("Libraries"):WaitForChild("Bolt"))

local Network = {
	mapTest = Bolt.ReliableEvent("MapTest"),
	ragdoll = Bolt.ReliableEvent("Ragdoll") :: Bolt.ReliableEvent<{ state: string, time: number? }>,
	fireTurret = Bolt.ReliableEvent("FireTurret") :: Bolt.ReliableEvent<Model>,
	toggleAFK = Bolt.ReliableEvent("ToggleAFK") :: Bolt.ReliableEvent<boolean>,
}

return Network
