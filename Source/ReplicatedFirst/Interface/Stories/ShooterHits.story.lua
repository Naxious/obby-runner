local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local ShooterHits = require(ReplicatedFirst.Interface.ShooterHits)

local story = {
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		count = 0,
	},
	story = function(props)
		return React.createElement(ShooterHits, {
			count = props.controls.count,
		})
	end,
}

return story
