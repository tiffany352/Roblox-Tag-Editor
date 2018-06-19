local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Constants = require(Modules.Plugin.Constants)
local Icon = require(Modules.Plugin.Components.Icon)

local Item = Roact.Component:extend("ContextMenuItem")

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

function Item:render()
	local props = self.props
	local height = 28
	local center, size, offset = Rect.new(10, 10, 10, 10), Vector2.new(20, 20), Vector2.new(0, 0)
	if props.First and props.Last then
		height = height + 8
	elseif props.First then
		height = height + 4
		size = Vector2.new(20, 10)
	elseif props.Last then
		height = height + 4
		center = Rect.new(10, 0, 10, 0)
		offset = Vector2.new(0, 10)
		size = Vector2.new(20, 10)
	else
		center = Rect.new(10, 0, 10, 0)
		size = Vector2.new(20, 1)
		offset = Vector2.new(0, 10)
	end

	local children = {}
	if not props.Last and not props.NoDivider then
		children.Divider = Roact.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, 1),
			BorderSizePixel = 0,
			BackgroundTransparency = Constants.LightGrey,
		})
	end
	children.UIPadding = Roact.createElement("UIPadding", {
		PaddingLeft = UDim.new(0, 3),
		PaddingRight = UDim.new(0, 3),
		PaddingTop = UDim.new(0, props.First and 4 or 0),
		PaddingBottom = UDim.new(0, props.Last and 4 or 1),
	})
	if props.Text or props.Icon then
		children.Frame = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1.0,
		}, {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, props.LeftAlign and 96 or 8),
			}),
			UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,--Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 4),
			}),
			Icon = props.Icon and Roact.createElement(Icon, {
				Name = props.Icon,
				LayoutOrder = 1,
			}) or nil,
			Label = props.Text and Roact.createElement("TextLabel", merge({
				BackgroundTransparency = 1.0,
				Text = props.Text,
				Font = Enum.Font.SourceSans,
				TextSize = 18,
				TextColor3 = Constants.Black,
				LayoutOrder = 2,
				TextXAlignment = Enum.TextXAlignment.Left,

				[Roact.Ref] = function(rbx)
					if not rbx then return end
					local function update()
						local tb = rbx.TextBounds
						rbx.Size = UDim2.new(0, tb.x + 4, 0, 18)
					end
					rbx:GetPropertyChangedSignal("TextBounds"):Connect(update)
					update()
					spawn(update)
				end,
			}, props.TextProps)) or nil,
		})
	end

	for k,v in pairs(props[Roact.Children] or {}) do
		children[k] = v
	end

	local hoverColor = Constants.LightGrey --Constants.RobloxBlue:lerp(Constants.White, .9)
	local isHover = self.state.hover and not props.dropdownOpen

	local newProps = {
		Size = UDim2.new(1, 0, 0, height),
		Image = "rbxasset://textures/ui/btn_newWhite.png",
		ImageColor3 = isHover and hoverColor or Constants.White,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = center,
		ImageRectOffset = offset,
		ImageRectSize = size,
		BackgroundTransparency = 1.0,
		LayoutOrder = props.LayoutOrder,

		[Roact.Event.MouseEnter] = function(rbx)
			self:setState({
				hover = true,
			})
		end,

		[Roact.Event.MouseLeave] = function(rbx)
			self:setState({
				hover = false,
			})
		end,

		[Roact.Event.MouseButton1Click] = function(rbx)
			self:setState({
				hover = false,
			})
			props.onClick(rbx)
		end,
	}

	local blacklist = {
		First = true,
		Last = true,
		NoDivider = true,
		Text = true,
		Icon = true,
		onClick = true,
		LeftAlign = true,
		dropdownOpen = true,
		TextProps = true,
		[Roact.Children] = true,
	}
	for k,v in pairs(props) do
		if not blacklist[k] then
			newProps[k] = v
		end
	end

	return Roact.createElement("ImageButton", newProps, children)
end

local function mapStateToProps(state)
	return {
		dropdownOpen = state.Dropdown,
	}
end

Item = RoactRodux.connect(mapStateToProps)(Item)

return Item
