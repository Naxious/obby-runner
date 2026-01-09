local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local React = require(ReplicatedStorage.Packages.React)
local Root = require(ReplicatedFirst.Modules.Root)
local SidebarLeft = require(ReplicatedFirst.Interface.SidebarLeft)
local InventoryController = require(ReplicatedFirst.IControllers.InventoryController)

local Network = require(ReplicatedStorage.Network)

local root = Root.new("SidebarLeft")
local render

local isAFK = false

local function buttonPressed(buttonName)
	if buttonName == "AFK" then
		isAFK = not isAFK
		Network.toggleAFK:FireServer(isAFK)
	elseif buttonName == "Inventory" then
		InventoryController:Toggle()
	end

	render()
end

local Sidebar = {}

function Sidebar:Init()
	render = function()
		root:render(React.createElement(SidebarLeft, {
			buttonPressed = buttonPressed,
			afk = isAFK,
		}))
	end

	render()
end

return Sidebar
