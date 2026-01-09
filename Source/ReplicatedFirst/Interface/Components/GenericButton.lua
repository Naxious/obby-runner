local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

export type buttonPress = (buttonName: string) -> string

export type props = {
	buttonPressed: buttonPress,
	buttonName: string,

	rounded: UDim?,

	Text: string?,
	TextColor3: Color3?,
	TextStrokeColor3: Color3?,
	BackgroundColor3: Color3?,
	Size: UDim2?,
	Position: UDim2?,

	Image: string?,
	ImageColor3: Color3?,
}

local function createImageButton(props: props)
	return React.createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.9, 0.9),
		Image = props.Image or "",
		ImageColor3 = props.ImageColor3 or Color3.fromRGB(255, 255, 255),
	}, {
		uICorner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0.2, 0),
		}),
	})
end

local function createTextButton(props: props)
	return React.createElement("TextLabel", {
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
	}, {
		uICorner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0.2, 0),
		}),
	})
end

function GenericButton(props: props)
	return React.createElement("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(255, 255, 255),
		FontFace = Font.new("rbxassetid://12187371840"),
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		Size = props.Size or UDim2.fromScale(0.8, 0.1),
		Text = "",
		[React.Event.Activated] = function()
			props.buttonPressed(props.buttonName)
		end,
	}, {
		button = if props.Image then createImageButton(props) else createTextButton(props),

		uICorner = React.createElement("UICorner", {
			CornerRadius = props.rounded or UDim.new(0.2, 0),
		}),
	})
end

return GenericButton
