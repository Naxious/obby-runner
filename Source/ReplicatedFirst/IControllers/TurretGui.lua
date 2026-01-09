local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local React = require(ReplicatedStorage.Packages.React)
local Root = require(ReplicatedFirst.Modules.Root)
local Turret = require(ReplicatedFirst.Interface.Turret)
local TurretController = require(ReplicatedFirst.Systems.TurretController)

local root = Root.new("TurretGui")
local render

local function buttonPressed()
	TurretController:RequestFire()
end

local TurretGui = {}

function TurretGui:Init()
	render = function()
		root:render(React.createElement(Turret, {
			buttonPressed = buttonPressed,
		}))
	end

	render()
end

return TurretGui
