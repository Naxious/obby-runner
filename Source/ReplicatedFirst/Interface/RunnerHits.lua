local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactSpring = require(ReplicatedStorage.Packages.ReactSpring)

export type props = {
	count: number,
}

function RunnerHits(props: props)
	local count = props.count or 0

	local lastCount, setCount = React.useState(count)

	local countScale, countApi = ReactSpring.useSpring(function()
		return {
			to = {
				scale = 1,
			},
			config = {
				tension = 220,
				friction = 4,
			},
		}
	end)

	React.useEffect(function()
		if lastCount ~= count then
			setCount(count)
			countApi.start({
				to = { scale = 1 },
				from = { scale = 0.3 },
			})
		end
	end)

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.9, 0.15),
		Size = UDim2.fromScale(0.1, 0.08),
	}, {
		textLabel = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxassetid://12187371840"),
			Position = UDim2.fromScale(-1, 0.5),
			Size = UDim2.fromScale(1, 1),
			Text = "Lives: ",
			TextColor3 = Color3.new(0.219608, 0.219608, 0.219608),
			TextScaled = true,
			TextStrokeColor3 = Color3.fromRGB(255, 255, 255),
			TextStrokeTransparency = 0,
			TextXAlignment = Enum.TextXAlignment.Right,
		}),

		countLabel = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxassetid://12187371840"),
			Position = UDim2.fromScale(0, 0.5),
			Size = countScale.scale:map(function(s)
				return UDim2.fromScale(s, s)
			end),
			Text = tostring(count),
			TextColor3 = Color3.new(0.219608, 0.219608, 0.219608),
			TextScaled = true,
			TextStrokeColor3 = Color3.fromRGB(255, 255, 255),
			TextStrokeTransparency = 0,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),

		uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 3.28,
		}),
	})
end

return RunnerHits
