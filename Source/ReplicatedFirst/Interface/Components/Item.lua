local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

export type buttonPress = (itemName: string) -> string

export type props = {
	buttonPressed: buttonPress,
	itemName: string,

	amount: number?,
	cost: number?,
	equipped: boolean?,

	Text: string?,
	TextColor3: Color3?,
	TextStrokeColor3: Color3?,
	BackgroundColor3: Color3?,
	Size: UDim2?,
	Position: UDim2?,
	LayoutOrder: number?,

	image: string?,
}

local function createImageLabel(props: props)
	return React.createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 0.5,
		Position = UDim2.fromScale(0.5, 0.05),
		Size = UDim2.fromScale(0.9, 0.65),
		Image = props.image or "",
	}, {
		amount = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.02, 0.01),
			Size = UDim2.fromScale(0.9, 0.2),
			Text = "x" .. tostring(props.amount or 0),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextStrokeTransparency = 0,
			TextStrokeColor3 = Color3.fromRGB(138, 138, 138),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = Font.new("rbxassetid://12187371840"),
			Visible = props.amount or false,
		}),

		cost = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(0.6, 0.2),
			Text = "$" .. tostring(props.cost or 0),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextStrokeTransparency = 0,
			TextStrokeColor3 = Color3.fromRGB(138, 138, 138),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			FontFace = Font.new("rbxassetid://12187371840"),
			Visible = props.cost or false,
		}),
	})
end

function Item(props: props)
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		Size = props.Size or UDim2.fromScale(0.5, 0.5),
		LayoutOrder = props.LayoutOrder or 0,
	}, {
		body = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(255, 255, 255),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.95),
		}, {
			createImageLabel(props),

			equipButton = React.createElement("TextButton", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = Color3.fromRGB(0, 170, 255),
				Position = UDim2.fromScale(0.5, 0.95),
				Size = UDim2.fromScale(0.9, 0.1),
				Text = props.equipped and "Unequip" or "Equip",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				FontFace = Font.new("rbxassetid://12187371840"),
				[React.Event.Activated] = function()
					props.buttonPressed(props.itemName)
				end,
			}),

			itemName = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.86),
				Size = UDim2.fromScale(0.9, 0.18),
				Text = props.itemName or "",
				TextColor3 = Color3.fromRGB(83, 83, 83),
				TextStrokeTransparency = 0,
				TextStrokeColor3 = Color3.fromRGB(43, 43, 43),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Center,
				FontFace = Font.new("rbxassetid://12187371840"),
			}),

			uiAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),
		}),
	})
end

return Item
