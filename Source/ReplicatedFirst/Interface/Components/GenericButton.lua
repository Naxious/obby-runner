local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

export type buttonPress = (buttonName: string) -> string

export type props = {
	buttonPressed: buttonPress,
	buttonName: string,

	Text: string?,
	TextColor3: Color3?,
	TextStrokeColor3: Color3?,
	BackgroundColor3: Color3?,
	Size: UDim2?,
	Position: UDim2?,
}

function GenericButton(props: props)
	return React.createElement("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(255, 255, 255),
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = props.Size or UDim2.fromScale(0.8, 0.1),
		Text = "",
		[React.Event.Activated] = function()
			props.buttonPressed(props.buttonName)
		end,
	}, {
		textLabel = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxassetid://12187371840"),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.9, 0.9),
			Text = props.Text or "",
			TextColor3 = props.TextColor3 or Color3.fromRGB(0, 0, 0),
			TextScaled = true,
			TextStrokeColor3 = props.TextStrokeColor3 or Color3.fromRGB(130, 130, 130),
			TextStrokeTransparency = 0,
		}),

		uICorner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0.2, 0),
		}),
	})
end

return GenericButton
