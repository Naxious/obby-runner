local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local SidebarLeft = require(ReplicatedFirst.Interface.SidebarLeft)

local story = {
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		afk = false,
	},
	story = function(props)
		return React.createElement(SidebarLeft, {
			buttonPressed = function(buttonName: string)
				print(buttonName .. " button pressed")
			end,
			afk = props.controls.afk,
		})
	end,
}

return story
