local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local GenericButton = require(ReplicatedFirst.Interface.Components.GenericButton)

export type props = {
	buttonPressed: GenericButton.buttonPress,
	afk: boolean,
}

function SidebarLeft(props: props)
	local afkButton = React.createElement(GenericButton, {
		buttonPressed = props.buttonPressed,
		buttonName = "AFK",

		Text = "AFK",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextStrokeColor3 = Color3.fromRGB(130, 130, 130),
		BackgroundColor3 = props.afk and Color3.fromRGB(22, 131, 51) or Color3.fromRGB(131, 0, 0),
		Size = UDim2.fromScale(0.8, 0.1),
		Position = UDim2.fromScale(0.5, 0.5),
		rounded = UDim.new(0, 0),
	})

	local inventoryButton = React.createElement(GenericButton, {
		buttonPressed = props.buttonPressed,
		buttonName = "Inventory",

		Text = "Inventory",
		BackgroundColor3 = Color3.fromRGB(22, 131, 51),
		Size = UDim2.fromScale(0.8, 0.1),
		Position = UDim2.fromScale(0.5, 0.38),
		Image = "rbxassetid://129289889496378",
		rounded = UDim.new(0, 0),
	})

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromScale(0.06, 1),
	}, {
		uICorner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0.2, 0),
		}),
		uiAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 0.14,
		}),
		afkButton = afkButton,
		inventoryButton = inventoryButton,
	})
end

return SidebarLeft
