local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local GenericButton = require(ReplicatedFirst.Interface.Components.GenericButton)
local Item = require(ReplicatedFirst.Interface.Components.Item)

export type props = {
	items: { { itemName: string, image: string, cost: number?, amount: number? } },
	activeTab: string,
	buttonPressed: (itemName: string) -> (),
	rounded: UDim?,
	equippedTrail: string,
}

function Inventory(props: props)
	local function trailsButton()
		return React.createElement(GenericButton, {
			buttonPressed = function(buttonName: string)
				print(buttonName .. " button pressed")
			end,
			buttonName = "Trails",
			Text = "Trails",
			BackgroundColor3 = Color3.fromRGB(0, 255, 0),
			Size = UDim2.fromScale(0.2, 1),
			rounded = UDim.new(0, 0),
		})
	end

	local function buildItems(props: props)
		local items = {}

		for index, item in props.items do
			items[item.itemName] = React.createElement(Item, {
				buttonPressed = function(itemName: string)
					props.buttonPressed(itemName)
				end,
				itemName = item.itemName,
				amount = item.amount,
				cost = item.cost,
				image = item.image,
				LayoutOrder = index,
				Size = UDim2.fromScale(0.25, 0.5),
				equipped = props.equippedTrail == item.itemName,
				BackgroundColor3 = item.BackgroundColor3 or Color3.fromRGB(255, 255, 255),
			})
		end

		items["uiListLayout"] = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			Wraps = true,
			HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly,
		})

		items["uiPadding"] = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 0),
			PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 0),
			PaddingBottom = UDim.new(0, 0),
		})

		return items
	end

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.7),
	}, {
		Categories = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.1),
			BackgroundTransparency = 1,
		}, {
			UIListLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Trails = props.activeTab == "Trails" and trailsButton() or nil,
		}),
		Body = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.9),
			Position = UDim2.fromScale(0, 0.1),
			BackgroundTransparency = 0,
		}, {
			ScrollingFrame = React.createElement("ScrollingFrame", {
				Size = UDim2.fromScale(1, 1),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 6,
				CanvasSize = UDim2.new(0, 0, 1, 0),
			}, {
				buildItems(props),
			}),
		}),

		UIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.8,
		}),
	})
end

return Inventory
