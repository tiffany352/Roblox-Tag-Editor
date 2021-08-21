local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Constants = require(Modules.Plugin.Constants)
local Icon = require(Modules.Plugin.Components.Icon)
local TextLabel = require(Modules.Plugin.Components.TextLabel)
local StudioThemeAccessor = require(Modules.Plugin.Components.StudioThemeAccessor)
local Util = require(Modules.Plugin.Util)

local function Tag(props)
	return StudioThemeAccessor.withTheme(function(theme)
		local text = Util.escapeTagName(props.Tag, theme)

		return Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1.0,
		}, {
			Divider = Roact.createElement("Frame", {
				Size = UDim2.new(1, -20, 0, 1),
				Position = UDim2.fromScale(0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = Constants.LightGrey,
			}),
			Holder = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1.0,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 10),
					PaddingTop = UDim.new(0, 6),
					PaddingBottom = UDim.new(0, 6),
				}),
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
					Text = text,
					RichText = true,
					LayoutOrder = 2,
					TextWrapped = true,
					Size = UDim2.new(1, -20, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
				}),
			}),
		})
	end)
end

return Tag
