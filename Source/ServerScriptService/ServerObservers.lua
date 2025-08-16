local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observer = require(ReplicatedStorage.Packages.Observer)

local ServerObservers = {
	enteredArea = Observer.Create("EnteredArea") :: Observer.Event<Player, string>,
	exitedArea = Observer.Create("ExitedArea") :: Observer.Event<Player, string>,
}

return ServerObservers
