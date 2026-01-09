local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local TrailChest = require(ReplicatedFirst.Interface.TrailChest)

local story = {
	react = React,
	reactRoblox = ReactRoblox,
	controls = {},
	story = function(props)
		return React.createElement(TrailChest, {
			buttonPressed = function()
				print("Button pressed!")
			end,
		})
	end,
}

return story
