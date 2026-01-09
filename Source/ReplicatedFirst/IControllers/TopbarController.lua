local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local React = require(ReplicatedStorage.Packages.React)
local Root = require(ReplicatedFirst.Modules.Root)
local Topbar = require(ReplicatedFirst.Interface.Topbar)

local Network = require(ReplicatedStorage.Network)

local root = Root.new("Topbar")
local render

local coins = 0
local hearts = 0

local TopbarController = {}

function TopbarController:Init()
	render = function()
		root:render(React.createElement(Topbar, {
			coins = coins,
			hearts = hearts,
		}))
	end

	Network.coins:Observe(function(newCoins)
		coins = newCoins
		render()
	end)

	Network.hearts:Observe(function(newHearts)
		hearts = newHearts
		render()
	end)

	render()
end

return TopbarController
