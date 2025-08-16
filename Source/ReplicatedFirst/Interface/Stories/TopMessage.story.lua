local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local TopMessage = require(ReplicatedFirst.Interface.TopMessage)

local story = {
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		message = "Hello, World!",
	},
	story = function(props)
		return React.createElement(TopMessage, {
			message = props.controls.message,
		})
	end,
}

return story
