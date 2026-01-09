local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Root = require(ReplicatedFirst.Modules.Root)
local ChestController = require(ReplicatedFirst.Systems.ChestController)
local ClientObservers = require(ReplicatedFirst.ClientObservers)
local TrailChest = require(ReplicatedFirst.Interface.TrailChest)
local Network = require(ReplicatedStorage.Network)

local assetsFolder = ReplicatedStorage:WaitForChild("Assets")
local trailsFolder = assetsFolder and assetsFolder:WaitForChild("Trails")

local root = Root.new("TrailChest")
local render

local TrailStore = {}

function TrailStore:OpenTrailChest(trailId: string, rarity: string)
	local rarityFolder = trailsFolder:FindFirstChild(rarity)
	if not rarityFolder then
		error("Rarity folder not found in ReplicatedStorage/Assets/Trails/")
		return
	end

	local reward = rarityFolder:FindFirstChild(trailId)
	if not reward then
		error(`Trail {trailId} not found in Trails folder`)
		return
	end

	reward = reward:FindFirstChildOfClass("Part")
	if not reward then
		error(`Trail {trailId} is not a valid trail`)
		return
	end

	ChestController:OpenChest("Trail_01", reward)
end

function TrailStore:RequestBuyChest()
	Network.requestTrailChest:FireServer()
	TrailStore:CloseUI()
end

function TrailStore:OpenUI()
	render()
end

function TrailStore:CloseUI()
	root:unmount()
end

function TrailStore:Init()
	if not trailsFolder then
		error("Trails folder not found in ReplicatedStorage/Assets/")
	end

	render = function()
		root:render(React.createElement(TrailChest, {
			buttonPressed = function()
				TrailStore:RequestBuyChest()
			end,
		}))
	end

	ClientObservers.enteredArea:Connect(function(areaName: string)
		if areaName == "TrailChest" then
			TrailStore:OpenUI()
		end
	end)

	ClientObservers.exitedArea:Connect(function(areaName: string)
		if areaName == "TrailChest" then
			TrailStore:CloseUI()
		end
	end)

	Network.openTrailChest.OnClientEvent:Connect(function(trailId: string, rarity: string)
		TrailStore:OpenTrailChest(trailId, rarity)
	end)
end

return TrailStore
