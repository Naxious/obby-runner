local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local React = require(ReplicatedStorage.Packages.React)
local Root = require(ReplicatedFirst.Modules.Root)
local Inventory = require(ReplicatedFirst.Interface.Inventory)
local Network = require(ReplicatedStorage.Network)
local Rarity = require(ReplicatedStorage.Data.Rarity)

local root = Root.new("Inventory")
local render

local isOpen = false
local trailData = {}
local equippedTrail = ""
local activeTab = "Trails"

local function buttonPressed(buttonName)
	if buttonName == "Trails" then
		activeTab = "Trails"
		return
	end

	if activeTab == "Trails" then
		Network.equipTrail:FireServer(buttonName)
		equippedTrail = buttonName
		isOpen = false
		root:unmount()
		return
	end
	render()
end

local function buildTrailItems(trailData)
	local items = {}
	for trailId, rarity in trailData do
		if typeof(rarity) ~= "string" then
			continue
		end
		local rarityFolder = ReplicatedStorage.Assets.Trails[rarity] :: Folder
		local trailFolder = rarityFolder and rarityFolder[trailId] :: Folder
		local imageObject = trailFolder:FindFirstChildOfClass("StringValue")
		local trailImage = imageObject and imageObject.Value or "rbxassetid://13248698425"
		local rarityColor = Rarity[rarity] and Rarity[rarity].color or Color3.fromRGB(255, 255, 255)
		table.insert(items, {
			itemName = trailId,
			image = trailImage,
			cost = nil, -- Placeholder cost
			amount = nil, -- Placeholder amount
			BackgroundColor3 = rarityColor,
		})
	end

	return items
end

local InventoryController = {}

function InventoryController:Open()
	isOpen = true
	render()
end

function InventoryController:Close()
	isOpen = false
	root:unmount()
end

function InventoryController:Toggle()
	if isOpen then
		InventoryController:Close()
	else
		InventoryController:Open()
	end
end

function InventoryController:Init()
	render = function()
		root:render(React.createElement(Inventory, {
			buttonPressed = buttonPressed,
			items = trailData,
			activeTab = activeTab,
			rounded = UDim.new(0, 0),
			equippedTrail = equippedTrail,
		}))
	end

	Network.trailData:Observe(function(newTrailData)
		trailData = buildTrailItems(newTrailData)

		if isOpen then
			render()
		end
	end)

	Network.equippedTrail:Observe(function(newEquippedTrail)
		equippedTrail = newEquippedTrail

		if isOpen then
			render()
		end
	end)
end

return InventoryController
