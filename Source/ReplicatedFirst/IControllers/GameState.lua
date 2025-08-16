local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local React = require(ReplicatedStorage.Packages.React)
local Root = require(ReplicatedFirst.Modules.Root)
local TopMessage = require(ReplicatedFirst.Interface.TopMessage)

local assetsFolder = ReplicatedStorage:WaitForChild("Assets", 5)
local stateMessage = assetsFolder:WaitForChild("GameStateMessage", 5)

local root = Root.new("GameStateMessage")
local render

local currentProps = {
	message = "Awaiting ...",
}

local GameState = {}

function GameState:Init()
	if not stateMessage then
		error("GameStateMessage not found in Assets folder")
	end

	render = function()
		root:render(React.createElement(TopMessage, currentProps))
	end

	stateMessage.Changed:Connect(function()
		currentProps.message = stateMessage.Value
		render()
	end)

	render()
end

return GameState
