local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local UiLabs = require(ReplicatedStorage.Packages.UiLabs)

local Inventory = require(ReplicatedFirst.Interface.Inventory)

local story = {
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		activeTab = UiLabs.Choose({
			"Trails",
			"Items",
		}, 1),
	},
	story = function(props)
		return React.createElement(Inventory, {
			buttonPressed = function(itemName: string)
				print(itemName .. " button pressed")
			end,
			items = {
				{ itemName = "Item1", image = "rbxassetid://13248698425", cost = 100, amount = 1 },
				{ itemName = "Item2", image = "rbxassetid://107648487427751", cost = 200, amount = 2 },
				{ itemName = "Item3", image = "rbxassetid://16658091225", cost = 300, amount = 3 },
				{ itemName = "Item4", image = "rbxassetid://13357847676", cost = 400, amount = 4 },
				{ itemName = "Item5", image = "rbxassetid://11260120531", cost = 500, amount = 5 },
				{ itemName = "Item6", image = "rbxassetid://10190764933", cost = 600, amount = 6 },
				{ itemName = "Item7", image = "rbxassetid://7384634412", cost = 700, amount = 7 },
				{ itemName = "Item8", image = "rbxassetid://85039094506841", cost = 800, amount = 8 },
				{ itemName = "Item9", image = "rbxassetid://14155716410", cost = 900, amount = 9 },
				{ itemName = "Item10", image = "rbxassetid://111898661172362", cost = 1000, amount = 10 },
			},
			activeTab = props.controls.activeTab or "Items",
			rounded = UDim.new(0, 0),
		})
	end,
}

return story
