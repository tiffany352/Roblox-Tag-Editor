local TextService = game:GetService("TextService")

local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Constants = require(Modules.Plugin.Constants)
local Icon = require(Modules.Plugin.Components.Icon)
local TextLabel = require(Modules.Plugin.Components.TextLabel)

local function Tag(props)
	local size = TextService:GetTextSize(props.Tag, 20, Enum.Font.SourceSans, Vector2.new(160, 100000))

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 32 - 20 + size.y),
		BackgroundTransparency = 1.0,
	}, {
		Divider = Roact.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 1),
			Position = UDim2.new(.5, 0, 0, 0),
			AnchorPoint = Vector2.new(.5, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = Constants.LightGrey,
		}),
		Holder = Roact.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, size.y),
			Position = UDim2.new(.5, 0, .5, 0),
			AnchorPoint = Vector2.new(.5, .5),
			BackgroundTransparency = 1.0,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			Icon = Roact.createElement(Icon, {
				Name = props.Icon,
				LayoutOrder = 1,
			}),
			Tag = Roact.createElement(TextLabel, {
				Text = props.Tag,
				LayoutOrder = 2,
				TextWrapped = true,
				Size = UDim2.new(1, -20, 0, size.y),
			})
		}),
	})
end

return Tag
