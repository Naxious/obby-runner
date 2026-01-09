local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local Turret = require(ReplicatedFirst.Interface.Turret)

local story = {
	react = React,
	reactRoblox = ReactRoblox,
	controls = {},
	story = function(props)
		return React.createElement(Turret, {
			buttonPressed = function()
				print("Button pressed")
			end,
		})
	end,
}

return story
