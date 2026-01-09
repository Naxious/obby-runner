local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData = require(ServerScriptService.Systems.PlayerData)
local Network = require(ReplicatedStorage.Network)

local CurrencyManager = {}

function CurrencyManager:CanBuyWithCoins(player, cost)
	local profile = PlayerData:GetProfile(player)
	local currentCoins = profile.Data.Player.coins or 0
	return currentCoins >= cost
end

function CurrencyManager:AddCoins(player, amount)
	local profile = PlayerData:GetProfile(player)
	local currentCoins = profile.Data.Player.coins or 0
	local newAmount = currentCoins + amount
	if newAmount < 0 then
		warn("Attempting to set coins below zero! Check CanBuyWithCoins First!")
		newAmount = 0
	end
	profile.Data.Player.coins = newAmount
	Network.coins:SetFor(player, newAmount)
end

function CurrencyManager:AddHearts(player, amount)
	local profile = PlayerData:GetProfile(player)
	profile.Data.Player.hearts = (profile.Data.Player.hearts or 0) + amount
	Network.hearts:SetFor(player, profile.Data.Player.hearts)
end

function CurrencyManager:Init()
	Players.PlayerAdded:Connect(function(player)
		local profile = PlayerData:GetProfile(player)
		local currentCoins = profile.Data.Player.coins or 0
		local currentHearts = profile.Data.Player.hearts or 0

		Network.coins:SetFor(player, currentCoins)
		Network.hearts:SetFor(player, currentHearts)

		while true do
			CurrencyManager:AddCoins(player, 500)
			task.wait(10)
		end
	end)
end

return CurrencyManager
