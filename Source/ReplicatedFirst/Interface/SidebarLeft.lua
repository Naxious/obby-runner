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
		BackgroundColor3 = props.afk and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0),
		Size = UDim2.fromScale(0.8, 0.1),
		Position = UDim2.fromScale(0.5, 0.5),
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
		afkButton = afkButton,
	})
end

return SidebarLeft
