local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local StudioThemeAccessor = require(script.Parent.StudioThemeAccessor)
local tr = require(script.Parent.Parent.tr)

local Button = Roact.PureComponent:extend("Button")
Button.defaultProps = {
	Font = Enum.Font.SourceSans,
	TextSize = 16,
}

function Button:init()
	self.state = {
		hover = false,
		press = false,
	}

	self._mouseEnter = function(_rbx)
		self:setState({
			hover = true,
		})
	end

	self._mouseLeave = function(_rbx)
		self:setState({
			hover = false,
			press = false,
		})
	end

	self._mouseDown = function(_rbx)
		self:setState({
			press = true,
		})
	end

	self._mouseUp = function(_rbx)
		self:setState({
			press = false,
		})
	end
end

function Button:render()
	local props = self.props
	local buttonState = "Default"

	if props.Disabled then
		buttonState = "Disabled"
	elseif self.state.press then
		buttonState = "Pressed"
	elseif self.state.hover then
		buttonState = "Hover"
	end

	return StudioThemeAccessor.withTheme(function(theme)
		return Roact.createElement("TextButton", {
			AnchorPoint = props.AnchorPoint,
			AutoButtonColor = false,
			BackgroundColor3 = theme:GetColor("Button", buttonState),
			BorderColor3 = theme:GetColor("ButtonBorder", buttonState),
			BorderSizePixel = 1,
			Font = props.Font,
			LayoutOrder = props.LayoutOrder,
			Position = props.Position,
			Size = props.Size,
			Text = if props.textKey then tr(props.textKey, props.textArgs) else props.Text,
			AutoLocalize = props.textKey == nil,
			TextColor3 = theme:GetColor("ButtonText", buttonState),
			TextSize = props.TextSize,
			TextScaled = props.TextScaled,
			ZIndex = props.ZIndex,
			[Roact.Event.MouseEnter] = self._mouseEnter,
			[Roact.Event.MouseLeave] = self._mouseLeave,
			[Roact.Event.MouseButton1Down] = self._mouseDown,
			[Roact.Event.MouseButton1Up] = self._mouseUp,
			[Roact.Event.MouseButton1Click] = props.leftClick,
			[Roact.Event.Changed] = props[Roact.Event.Changed],
		}, props[Roact.Children])
	end)
end

return Button
