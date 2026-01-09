local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local Topbar = require(ReplicatedFirst.Interface.Topbar)

local story = {
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		coins = 50,
		hearts = 3,
	},
	story = function(props)
		return React.createElement(Topbar, {
			coins = props.controls.coins,
			hearts = props.controls.hearts,
		})
	end,
}

return story
