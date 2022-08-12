local ARROW_IMAGE = "rbxasset://textures/StudioToolbox/ArrowDownIconWhite.png"

local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local Button = require(Modules.Plugin.Components.Button)
local ListItem = require(Modules.Plugin.Components.ListItem)
local ScrollingFrame = require(Modules.Plugin.Components.ScrollingFrame)
local StudioThemeAccessor = require(Modules.Plugin.Components.StudioThemeAccessor)
local rootKey = require(Modules.Plugin.Components.rootKey)
local RootPortal = require(Modules.Plugin.Components.RootPortal)

local DropdownItem = function(props)
	return Roact.createElement(ListItem, {
		ShowDivider = false,
		textKey = props.textKey,
		leftClick = props.leftClick,
		ignoresMenuOpen = true,
		TextProps = {
			TextSize = 16,
		},
	})
end

local Dropdown = Roact.PureComponent:extend("Dropdown")

function Dropdown:init()
	self.state = {
		open = false,
	}

	self._listRef = Roact.createRef()
end

function Dropdown.getDerivedStateFromProps(nextProps, _lastState)
	return {
		dropdownHeight = math.min(120, #nextProps.Options * 26),
	}
end

function Dropdown:render()
	local props = self.props
	local children = {}
	local keyPrefix = props.keyPrefix or "Dropdown_"

	for _, option in ipairs(props.Options) do
		children[option] = Roact.createElement(DropdownItem, {
			textKey = keyPrefix .. option,
			Height = 26,
			leftClick = function()
				self:setState({
					open = false,
				})

				props.onOptionSelected(option)
			end,
		})
	end

	return StudioThemeAccessor.withTheme(function(_theme, isDarkTheme)
		return Roact.createElement(Button, {
			Size = props.Size,
			LayoutOrder = props.LayoutOrder,
			Position = props.Position,
			textKey = keyPrefix .. props.CurrentOption,
			[Roact.Event.Changed] = function(rbx)
				local list = self._listRef.current

				if list ~= nil then
					local buttonPosition = rbx.AbsolutePosition
					local buttonSize = rbx.AbsoluteSize
					local viewportHeight = self._context[rootKey].current.AbsoluteSize.Y
					local remainingHeight = viewportHeight - buttonPosition.Y - buttonSize.Y - 8
					local listHeight = math.min(remainingHeight, self.state.dropdownHeight)

					if remainingHeight - self.state.dropdownHeight < -60 then
						-- There's not enough space below; put the dropdown above the button
						list.Position =
							UDim2.new(0, buttonPosition.X, 0, buttonPosition.Y - self.state.dropdownHeight - 4)
						list.Size = UDim2.new(0, buttonSize.X, 0, self.state.dropdownHeight)
					else
						list.Position = UDim2.new(0, buttonPosition.X, 0, buttonPosition.Y + buttonSize.Y + 4)
						list.Size = UDim2.new(0, buttonSize.X, 0, listHeight)
					end
				end
			end,

			leftClick = function()
				self:setState({
					open = not self.state.open,
				})
			end,
		}, {
			Portal = Roact.createElement(RootPortal, nil, {
				OptionList = Roact.createElement(ScrollingFrame, {
					ShowBorder = true,
					Size = UDim2.new(1, 0, 0, self.state.dropdownHeight),
					Visible = self.state.open,
					List = true,
					[Roact.Ref] = self._listRef,
					ZIndex = 5,
				}, children),
			}),
			Arrow = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 12, 0, 12),
				Position = UDim2.new(1, -6, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				Image = ARROW_IMAGE,
				-- FIXME: This needs a non-hardcoded icon color.
				-- The studio theme API doesn't have a class for this :(
				ImageColor3 = isDarkTheme and Color3.fromRGB(242, 242, 242) or Color3.fromRGB(25, 25, 25),
			}),
		})
	end)
end

return Dropdown
