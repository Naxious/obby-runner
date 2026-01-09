local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

export type props = {
	buttonPressed: () -> (),
}

function Turret(props: props)
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.98, 0.45),
		Size = UDim2.fromScale(0.05, 0.1),
	}, {
		textButton = React.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 90, 93),
			BorderColor3 = Color3.new(),
			BorderSizePixel = 0,
			FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Text = "",
			TextColor3 = Color3.new(),
			TextSize = 14,
			[React.Event.Activated] = function()
				props.buttonPressed()
			end,
		}, {
			textLabel = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				FontFace = Font.new("rbxassetid://12187371840"),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.9),
				Text = "FIRE",
				TextColor3 = Color3.new(),
				TextScaled = true,
				TextStrokeColor3 = Color3.fromRGB(147, 147, 147),
				TextStrokeTransparency = 0,
			}),
		}),
	})
end

return Turret
