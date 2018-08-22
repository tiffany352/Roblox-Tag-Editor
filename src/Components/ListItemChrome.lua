local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Constants = require(Modules.Plugin.Constants)

local ThemeAccessor = require(script.Parent.ThemeAccessor)

local function ListItemChrome(props)
	local height = 26

	local object = props.object or 'ListItem'
	local state = props.state or 'Normal'

	local child = Roact.oneChild(props[Roact.Children])

	return ThemeAccessor.withTheme(function(theme)
		local showDivider = theme:get(object, 'ShowDivider', state)
		local flairColor = theme:get(object, 'FlairColor', state)

		return Roact.createElement("ImageButton", {
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.new(1, 0, 0, height),
			BackgroundTransparency = 1.0,
			LayoutOrder = props.LayoutOrder,
			Visible = not props.hidden,
			Image = "rbxasset://textures/ui/dialog_white.png",
			SliceCenter = Rect.new(10, 10, 10, 10),
			ImageColor3 = theme:get(object, 'BackgroundColor3', state),

			[Roact.Event.MouseEnter] = props.mouseEnter,
			[Roact.Event.MouseLeave] = props.mouseLeave,
			[Roact.Event.MouseButton1Click] = props.leftClick,
			[Roact.Event.MouseButton2Click] = props.rightClick,
		}, {
			Divider = Roact.createElement("Frame", {
				Visible = showDivider,
				Size = UDim2.new(1, -10, 0, 1),
				Position = UDim2.new(0.5, 0, 0, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = Constants.LightGrey,
			}),
			Flair = Roact.createElement("ImageLabel", {
				Size = UDim2.new(0, 8, 1, 0),
				Image = "rbxassetid://1353014916",
				BackgroundTransparency = 1.0,
				ImageColor3 = flairColor,
				Visible = flairColor ~= nil,
				ImageRectSize = Vector2.new(4, 40),
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(4, 20, 4, 20),
			}),
			Contents = child,
		})
	end)
end

return ListItemChrome
