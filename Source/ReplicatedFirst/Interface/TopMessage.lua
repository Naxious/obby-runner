local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

export type props = {
	message: string,
}

function TopMessage(props: props)
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 5),
		Size = UDim2.fromScale(0.4, 0.035),
	}, {
		textLabel = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxassetid://12187371840", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Text = props.message,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextStrokeColor3 = Color3.fromRGB(99, 99, 99),
			TextStrokeTransparency = 0,
		}),
	})
end

return TopMessage
