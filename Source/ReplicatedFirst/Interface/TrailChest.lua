local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

export type props = {
	buttonPressed: () -> (),
}

function TopMessage(props: props)
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.3, 0.3),
	}, {
		textButton = React.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.5, 0.3),
			Text = "",
			[React.Event.Activated] = props.buttonPressed,
		}, {
			textLabel = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				FontFace = Font.new("rbxassetid://12187371840"),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.95, 1),
				Text = "BUY TRAIL",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextStrokeColor3 = Color3.fromRGB(112, 188, 255),
				TextStrokeTransparency = 0,
			}),

			uIGradient = React.createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 4)),
					ColorSequenceKeypoint.new(0.0726644, Color3.fromRGB(204, 0, 3)),
					ColorSequenceKeypoint.new(0.266436, Color3.fromRGB(8, 0, 255)),
					ColorSequenceKeypoint.new(0.429066, Color3.fromRGB(0, 251, 255)),
					ColorSequenceKeypoint.new(0.653979, Color3.fromRGB(13, 255, 0)),
					ColorSequenceKeypoint.new(0.738754, Color3.fromRGB(234, 255, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
				}),
			}),
		}),

		textLabel = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxassetid://12187371840"),
			Position = UDim2.fromScale(0.5, 0.8),
			Size = UDim2.fromScale(0.5, 0.3),
			Text = "COST: 500 Coins",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextStrokeColor3 = Color3.fromRGB(77, 104, 181),
			TextStrokeTransparency = 0,
		}),
	})
end

return TopMessage
