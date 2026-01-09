local CollectionService = game:GetService("CollectionService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Chest = require(ReplicatedFirst.Modules.Chest)

local storedIDs = {}

local ChestController = {}

function ChestController:OpenChest(chestID: string, reward: (Model | BasePart)?)
	local chest = storedIDs[chestID]
	if chest then
		chest:Open(reward)
	else
		warn(`Tried to open chest with ID {chestID} but it is not stored! FIX!`, chestID)
	end
end

function ChestController:AddChest(chest: Chest.ChestInstance)
	local lid = chest:FindFirstChild("Lid")
	if not chest:IsA("Model") or not lid:IsA("Model") then
		return
	end

	local chestID = chest:GetAttribute("ID")
	if not storedIDs[chestID] then
		storedIDs[chestID] = Chest.new(chest, chestID)
	else
		warn(`Chest with ID {chestID} is already stored! FIX!`, chestID)
	end
end

function ChestController:Init()
	CollectionService:GetInstanceAddedSignal("Chest"):Connect(function(chest)
		ChestController:AddChest(chest)
	end)

	for _, chest in CollectionService:GetTagged("Chest") do
		ChestController:AddChest(chest)
	end
end

return ChestController
