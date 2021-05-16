local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local StudioThemeAccessor = require(script.Parent.StudioThemeAccessor)
local Util = require(Modules.Plugin.Util)

local RadioButton = Roact.PureComponent:extend("Button")
RadioButton.defaultProps = {
	Font = Enum.Font.SourceSans,
	TextSize = 16,
}

function RadioButton:init()
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

local function colorEq(c1: Color3, c2: Color3): boolean
	return c1.R == c2.R and c1.G == c2.G and c1.B == c2.B
end

function RadioButton:render()
	local props = self.props
	local buttonState = "Default"

	if props.Disabled then
		buttonState = "Disabled"
	elseif self.state.press then
		buttonState = "Pressed"
	elseif self.state.hover then
		buttonState = "Hover"
	elseif props.selected then
		buttonState = "Selected"
	end

	return StudioThemeAccessor.withTheme(function(theme)
		local bg = theme:GetColor("CheckedFieldBackground", buttonState)
		if buttonState == "Selected" and colorEq(bg, theme:GetColor("CheckedFieldBackground")) then
			bg = theme:GetColor("CheckedFieldIndicator")
		end

		return Roact.createElement(
			"TextButton",
			{
				AnchorPoint = props.AnchorPoint,
				AutoButtonColor = false,
				BackgroundColor3 = bg,
				BorderColor3 = theme:GetColor("CheckedFieldBorder", buttonState),
				BorderSizePixel = 1,
				Font = props.Font,
				LayoutOrder = props.LayoutOrder,
				Position = props.Position,
				Size = props.Size or UDim2.fromOffset(20, 20),
				Text = props.Text,
				TextColor3 = theme:GetColor("ButtonText", buttonState),
				TextSize = props.TextSize,
				ZIndex = props.ZIndex,
				[Roact.Event.MouseEnter] = self._mouseEnter,
				[Roact.Event.MouseLeave] = self._mouseLeave,
				[Roact.Event.MouseButton1Down] = self._mouseDown,
				[Roact.Event.MouseButton1Up] = self._mouseUp,
				[Roact.Event.Activated] = props.onSelect,
			},
			Util.merge(props[Roact.Children] or {}, {
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 5),
				}),
			})
		)
	end)
end

return RadioButton
