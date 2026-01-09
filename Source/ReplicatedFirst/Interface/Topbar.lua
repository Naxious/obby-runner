local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactSpring = require(ReplicatedStorage.Packages.ReactSpring)

export type props = {
	coins: number,
	hearts: number,
}

local TO_SCALE = 1
local FROM_SCALE = 0.3

function Topbar(props: props)
	local hearts = props.hearts
	local coins = props.coins

	local lastHearts, setHearts = React.useState(hearts)
	local lastCoins, setCoins = React.useState(coins)

	local heartScale, heartApi = ReactSpring.useSpring(function()
		return {
			to = {
				scale = TO_SCALE,
			},
			config = {
				tension = 220,
				friction = 4,
			},
		}
	end)

	local coinScale, coinApi = ReactSpring.useSpring(function()
		return {
			to = {
				scale = TO_SCALE,
			},
			config = {
				tension = 220,
				friction = 4,
			},
		}
	end)

	React.useEffect(function()
		if hearts ~= lastHearts then
			setHearts(hearts)
			heartApi.start({
				to = { scale = TO_SCALE },
				from = { scale = FROM_SCALE },
			})
		end

		if coins ~= lastCoins then
			setCoins(coins)
			coinApi.start({
				to = { scale = TO_SCALE },
				from = { scale = FROM_SCALE },
			})
		end
	end, { hearts, coins })

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromScale(1, 0.08),
	}, {
		coinFrame = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.98, 1),
			Size = UDim2.fromScale(0.05, 1),
		}, {
			uiAspectRatio = React.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1.4,
			}),

			coinsImage = React.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://93076620516447",
				Position = UDim2.fromScale(0.5, 0.5),
				-- Size = UDim2.fromScale(0.7, 0.8),
				Size = coinScale.scale:map(function(s)
					return UDim2.fromScale(0.7 * s, 0.8 * s)
				end),
				ImageColor3 = Color3.fromRGB(255, 207, 97),
			}),

			coins = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.95, 0.5),
				BackgroundTransparency = 1,
				FontFace = Font.new("rbxassetid://12187371840", Enum.FontWeight.Bold),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(2, 0.8),
				Text = tostring(coins),
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextStrokeTransparency = 0,
				TextXAlignment = Enum.TextXAlignment.Right,
			}),
		}),

		heartFrame = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.98, 0.5),
			Size = UDim2.fromScale(0.05, 1),
		}, {
			uiAspectRatio = React.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1.4,
			}),

			heartsImage = React.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://83789458551481",
				Position = UDim2.fromScale(0.5, 0.5),
				Size = heartScale.scale:map(function(s)
					return UDim2.fromScale(0.7 * s, 0.8 * s)
				end),
			}),

			hearts = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.95, 0.5),
				BackgroundTransparency = 1,
				FontFace = Font.new("rbxassetid://12187371840", Enum.FontWeight.Bold),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(2, 0.8),
				Text = tostring(hearts),
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextStrokeTransparency = 0,
				TextXAlignment = Enum.TextXAlignment.Right,
			}),
		}),
	})
end

return Topbar
