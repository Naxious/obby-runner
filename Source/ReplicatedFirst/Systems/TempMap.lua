local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Network)

local TempMap = {}

function TempMap:Init()
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		if input.KeyCode == Enum.KeyCode.M then
			Network.mapTest:FireServer()
		end
	end)
end

return TempMap
