local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observer = require(ReplicatedStorage.Packages.Observer)

local ClientObservers = {
	enteredArea = Observer.Create("EnteredArea") :: Observer.Event<string>,
	exitedArea = Observer.Create("ExitedArea") :: Observer.Event<string>,
}

return ClientObservers
