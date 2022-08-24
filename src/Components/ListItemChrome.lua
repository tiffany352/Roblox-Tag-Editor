local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local StudioThemeAccessor = require(script.Parent.StudioThemeAccessor)

local function ListItemChrome(props)
	local state = props.state or Enum.StudioStyleGuideModifier.Default
	local showDivider = props.showDivider

	local child = Roact.oneChild(props[Roact.Children])

	return StudioThemeAccessor.withTheme(function(theme)
		return Roact.createElement("TextButton", {
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			AutoButtonColor = false,
			LayoutOrder = props.LayoutOrder,
			Visible = not props.hidden,
			BackgroundColor3 = theme:GetColor("Item", state),
			BorderSizePixel = 0,
			Text = "",

			[Roact.Event.MouseEnter] = props.mouseEnter,
			[Roact.Event.MouseLeave] = props.mouseLeave,
			[Roact.Event.MouseButton1Click] = props.leftClick,
			[Roact.Event.MouseButton2Click] = props.rightClick,
		}, {
			Divider = Roact.createElement("Frame", {
				Visible = showDivider,
				Size = UDim2.new(1, 0, 0, 1),
				Position = UDim2.new(0.5, 0, 0, -1),
				AnchorPoint = Vector2.new(0.5, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = theme:GetColor("Separator"),
			}),
			Contents = child,
		})
	end)
end

return ListItemChrome
