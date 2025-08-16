local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Network = require(ReplicatedStorage.Network)

local AFKManager = {}

function AFKManager:IsPlayerAFK(player: Player)
	return player:GetAttribute("AFK")
end

function AFKManager:ToggleAFK(player: Player, afk: boolean)
	player:SetAttribute("AFK", afk)
end

function AFKManager:Init()
	Network.toggleAFK.OnServerEvent:Connect(function(player: Player, afk: boolean)
		AFKManager:ToggleAFK(player, afk)
	end)

	Players.PlayerAdded:Connect(function(player: Player)
		player:SetAttribute("AFK", false)
	end)
end

return AFKManager
