local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local rootGui = Instance.new("ScreenGui")
rootGui.Name = "RootGui"
rootGui.ResetOnSpawn = false
rootGui.Enabled = true
rootGui.IgnoreGuiInset = true
rootGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

return {
	new = function(guiName: string)
		local newRootGui = rootGui:Clone()
		newRootGui.Name = guiName
		newRootGui.Parent = playerGui

		local root = ReactRoblox.createRoot(newRootGui)
		return root
	end,
}
