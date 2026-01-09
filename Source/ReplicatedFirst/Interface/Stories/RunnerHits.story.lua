local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local RunnerHits = require(ReplicatedFirst.Interface.RunnerHits)

local story = {
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		count = 0,
	},
	story = function(props)
		return React.createElement(RunnerHits, {
			count = props.controls.count,
		})
	end,
}

return story
