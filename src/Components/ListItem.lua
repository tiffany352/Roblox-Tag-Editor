local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Theme = require(Modules.Plugin.Theme)

local Icon = require(script.Parent.Icon)
local ThemeAccessor = require(script.Parent.ThemeAccessor)
local ListItemChrome = require(script.Parent.ListItemChrome)

local function merge(orig, new)
	local t = {}
	for k,v in pairs(orig or {}) do
		t[k] = v
	end
	for k,v in pairs(new or {}) do
		t[k] = v
	end
	return t
end

local Item = Roact.Component:extend("Item")

function Item:render()
	local props = self.props
	local height = 26
	local isHover = self.state.Hover and not props.menuOpen

	local object = props.object or 'ListItem'
	local state = Theme.tagsToState({
		[Theme.Tags.Hover] = isHover,
		[Theme.Tags.Pressed] = false,
		[Theme.Tags.Active] = props.Active,
		[Theme.Tags.Semiactive] = props.SemiActive,
	})

	return Roact.createElement(ListItemChrome, {
		LayoutOrder = props.LayoutOrder,
		visible = not props.Hidden,
		state = state,

		mouseEnter = function(rbx)
			self:setState({
				Hover = true
			})
		end,

		mouseLeave = function(rbx)
			self:setState({
				Hover = false
			})
		end,

		leftClick = props.leftClick,
		rightClick = props.rightClick,
	}, {
		ThemeAccessor.withTheme(function(theme)
			return Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1.0,
			}, {
				Icon = props.Icon and Roact.createElement(Icon, {
					Name = props.Icon,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0, 24, 0.5, 0),
				}),
				Name = Roact.createElement(props.IsInput and "TextBox" or "TextLabel", merge({
					BackgroundTransparency = 1.0,
					TextXAlignment = Enum.TextXAlignment.Left,
					Position = props.Icon and UDim2.new(0, 40, 0, 0) or UDim2.new(0, 14, 0, 0),
					Size = UDim2.new(1, -40, 0, height),
					Text = props.IsInput and "" or props.Text,
					PlaceholderText = props.IsInput and props.Text or nil,
					PlaceholderColor3 = props.IsInput and theme:get(object, 'PlaceholderColor3', state) or nil,
					Font = Enum.Font.SourceSans,
					TextSize = 20,
					TextColor3 = theme:get(object, 'TextColor3', state),

					[Roact.Event.FocusLost] = props.IsInput and function(rbx, enterPressed)
						local text = rbx.Text
						rbx.Text = ""
						if props.onSubmit and enterPressed then
							props.onSubmit(rbx, text)
						end
					end or nil,
				}, props.TextProps or {})),
				Visibility = props.onSetVisible and Roact.createElement(Icon, {
					Name = props.Visible and "lightbulb" or "lightbulb_off",
					Position = UDim2.new(1, -4, .5, 0),
					AnchorPoint = Vector2.new(1, .5),

					onClick = props.onSetVisible,
				}),
				Settings = props.onSettings and Roact.createElement(Icon, {
					Name = 'cog',
					Position = UDim2.new(1, -24, .5, 0),
					AnchorPoint = Vector2.new(1, .5),

					onClick = props.onSettings,
				}),
				Delete = props.onDelete and Roact.createElement(Icon, {
					Name = "cancel",
					Position = UDim2.new(1, -4, .5, 0),
					AnchorPoint = Vector2.new(1, .5),

					onClick = props.onDelete,
				}),
			})
		end)
	})
end

local function mapStateToProps(state)
	return {
		menuOpen = state.TagMenu and not state.GroupPicker,
	}
end

Item = RoactRodux.connect(mapStateToProps)(Item)

return Item
