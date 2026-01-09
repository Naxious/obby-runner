local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local React = require(ReplicatedStorage.Packages.React)
local Root = require(ReplicatedFirst.Modules.Root)
local ShooterHits = require(ReplicatedFirst.Interface.ShooterHits)
local RunnerHits = require(ReplicatedFirst.Interface.RunnerHits)

local Network = require(ReplicatedStorage.Network)

local root = Root.new("Topbar")
local renderShooter
local renderRunner

local shooterHits = 0
local runnerHits = 0

local HitsController = {}

function HitsController:Init()
	renderShooter = function()
		root:render(React.createElement(ShooterHits, {
			count = shooterHits,
		}))
	end

	renderRunner = function()
		root:render(React.createElement(RunnerHits, {
			count = runnerHits,
		}))
	end

	Network.shooterHits:Observe(function(newShooterHits)
		shooterHits = newShooterHits
		if shooterHits ~= -1 then
			renderShooter()
		end
	end)

	Network.runnerHits:Observe(function(newRunnerHits)
		runnerHits = newRunnerHits
		if runnerHits ~= -1 then
			renderRunner()
		end
	end)
end

return HitsController
