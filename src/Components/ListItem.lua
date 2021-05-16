local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Util = require(Modules.Plugin.Util)

local Icon = require(script.Parent.Icon)
local Checkbox = require(script.Parent.Checkbox)
local StudioThemeAccessor = require(script.Parent.StudioThemeAccessor)
local ListItemChrome = require(script.Parent.ListItemChrome)

local Item = Roact.PureComponent:extend("Item")

function Item:init()
	self.textboxRef = Roact.createRef()
end

function Item:render()
	local props = self.props
	local ignoresMenuOpen = props.ignoresMenuOpen
	local isHover = self.state.Hover and (not props.menuOpen or ignoresMenuOpen)
	local indent = props.Indent or 0
	local height = props.Height or 26

	local state = Enum.StudioStyleGuideModifier.Default
	if props.Active or props.SemiActive then
		state = Enum.StudioStyleGuideModifier.Selected
	elseif isHover then
		state = Enum.StudioStyleGuideModifier.Hover
	end

	return Roact.createElement(ListItemChrome, {
		LayoutOrder = props.LayoutOrder,
		hidden = props.Hidden,
		state = state,
		height = height,
		showDivider = props.ShowDivider,

		mouseEnter = function(_rbx)
			self:setState({
				Hover = true,
			})
		end,

		mouseLeave = function(_rbx)
			self:setState({
				Hover = false,
			})
		end,

		leftClick = props.leftClick,
		rightClick = props.rightClick,
	}, {
		StudioThemeAccessor.withTheme(function(theme)
			return Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1.0,
				Position = UDim2.new(0, 0, 0, 0),
			}, {
				TopElements = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -indent, 0, 26),
					Position = UDim2.new(0, indent, 0, 0),
				}, {
					Checkbox = props.Checked ~= nil and Roact.createElement(Checkbox, {
						Checked = props.Checked,
						Disabled = props.CheckDisabled,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0, 24, 0.5, 0),
						leftClick = props.onCheck,
					}),
					Icon = props.Icon and Roact.createElement(Icon, {
						Name = props.Icon,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0, 24 + 24, 0.5, 0),
					}),
					Name = Roact.createElement(
						props.IsInput and "TextBox" or "TextLabel",
						Util.merge({
							BackgroundTransparency = 1.0,
							TextXAlignment = Enum.TextXAlignment.Left,
							Position = props.Icon and UDim2.new(0, 48 + 16, 0, 0) or UDim2.new(0, 14, 0, 0),
							Size = UDim2.new(1, -40, 1, 0),
							Text = props.IsInput and (props.TextBoxText or "") or props.Text,
							ClearTextOnFocus = (function()
								if props.IsInput then
									return props.ClearTextOnFocus
								else
									return nil
								end
							end)(),
							RichText = props.RichText and not props.IsInput,
							PlaceholderText = props.IsInput and props.Text or nil,
							PlaceholderColor3 = props.IsInput and theme:GetColor("DimmedText") or nil,
							Font = Enum.Font.SourceSans,
							TextSize = 20,
							TextColor3 = theme:GetColor("MainText"),

							[Roact.Event.FocusLost] = props.IsInput and function(rbx, enterPressed)
								local text = rbx.Text
								rbx.Text = ""
								if props.onSubmit and enterPressed then
									props.onSubmit(rbx, text)
								elseif props.onFocusLost then
									props.onFocusLost(rbx, text)
								end
							end or nil,

							[Roact.Ref] = self.textboxRef,
						}, props.TextProps or {})
					),
					Visibility = props.onSetVisible and Roact.createElement(Icon, {
						Name = props.Visible and "lightbulb" or "lightbulb_off",
						Position = UDim2.new(1, -4, 0.5, 0),
						AnchorPoint = Vector2.new(1, 0.5),

						onClick = props.onSetVisible,
					}),
					Settings = props.onSettings and Roact.createElement(Icon, {
						Name = "cog",
						Position = UDim2.new(1, -24, 0.5, 0),
						AnchorPoint = Vector2.new(1, 0.5),

						onClick = props.onSettings,
					}),
					Delete = props.onDelete and Roact.createElement(Icon, {
						Name = "cancel",
						Position = UDim2.new(1, -4, 0.5, 0),
						AnchorPoint = Vector2.new(1, 0.5),

						onClick = props.onDelete,
					}),
				}),
				Children = Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 1, -26),
					Position = UDim2.new(0, 0, 0, 26),
					BackgroundColor3 = theme:GetColor("MainBackground"),
					BorderSizePixel = 0,
				}, props[Roact.Children]),
			})
		end),
	})
end

function Item:didUpdate(previousProps, _previousState)
	local instance = self.textboxRef.current
	if
		previousProps.IsInput == false
		and self.props.IsInput == true
		and self.props.CaptureFocusOnBecomeInput
		and instance ~= nil
	then
		instance:CaptureFocus()
		instance.SelectionStart = 1
		instance.CursorPosition = string.len(instance.Text) + 1
	end
end

local function mapStateToProps(state)
	return {
		menuOpen = state.TagMenu and not state.GroupPicker,
	}
end

Item = RoactRodux.connect(mapStateToProps)(Item)

return Item
