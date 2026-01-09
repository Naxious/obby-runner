local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local Item = require(ReplicatedFirst.Interface.Components.Item)

local story = {
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		cost = 100,
		amount = 1,
	},
	story = function(props)
		return React.createElement(Item, {
			buttonPressed = function()
				print("Button pressed!")
			end,
			image = "rbxassetid://16658091225",
			itemName = "Example Item",
			cost = props.controls.cost or 100,
			amount = props.controls.amount or 1,
			Size = props.controls.Size or UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = props.controls.BackgroundColor3 or Color3.fromRGB(255, 255, 255),
			BorderColor3 = props.controls.BorderColor3 or Color3.fromRGB(0, 0, 0),
		})
	end,
}

return story
