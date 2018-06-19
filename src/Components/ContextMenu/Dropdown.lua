local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Constants = require(Modules.Plugin.Constants)
local Actions = require(Modules.Plugin.Actions)

local Item = require(script.Parent.Item)

local Dropdown = Roact.Component:extend("ContextMenuDropdown")

function Dropdown:render()
	local props = self.props
	local newProps = {
		LeftAlign = true,

		onClick = function()
			self:setState({
				open = not self.state.open,
			})
			props.openDropdown(self.state.open)
		end,
		ZIndex = 2,
	}
	local blacklist = {
		Options = true,
		Value = true,
		onSubmit = true,
		openDropdown = true,
	}
	for k,v in pairs(props) do
		if not blacklist[k] then
			newProps[k] = v
		end
	end

	local children = {}

	children.UIListLayout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
	})

	local opts = {}
	for key, text in pairs(props.Options or {}) do
		opts[#opts+1] = { key = key, text = text}
	end
	table.sort(opts, function(a, b) return a.text < b.text end)
	for i = 1, #opts do
		local key = opts[i].key
		local text = opts[i].text
		local center, size, off
		local h = 24
		if i == 1 then
			center = Rect.new(10, 10, 10, 10)
			size = Vector2.new(20, 10)
			h = 32
		elseif i == #opts then
			center = Rect.new(10, 0, 10, 0)
			size = Vector2.new(20, 10)
			off = Vector2.new(0, 10)
			h = 32
		else
			center = Rect.new(10, 0, 10, 0)
			size = Vector2.new(20, 1)
			off = Vector2.new(0, 10)
		end

		local isHover = self.state.hover == key
		local veryLight = Constants.RobloxBlue:lerp(Constants.White, .3)
		children[key] = Roact.createElement("ImageButton", {
			Size = UDim2.new(1, 0, 0, h),
			BackgroundTransparency = 1.0,
			Image = "rbxasset://textures/ui/btn_newWhite.png",
			ImageColor3 = isHover and veryLight or Constants.RobloxBlue,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = center,
			ImageRectSize = size,
			ImageRectOffset = off,
			LayoutOrder = i,

			[Roact.Event.MouseEnter] = function(rbx)
				self:setState({
					hover = key,
				})
			end,

			[Roact.Event.MouseLeave] = function(rbx)
				if self.state.hover == key then
					self:setState({
						hover = false
					})
				end
			end,

			[Roact.Event.MouseButton1Click] = function(rbx)
				if props.onSubmit then
					props.onSubmit(key)
				end
				self:setState({
					open = false,
				})
				props.openDropdown(false)
			end,
		}, {
			Label = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				Text = text,
				Font = Enum.Font.SourceSansSemibold,
				TextSize = 18,
				TextColor3 = Constants.White,
				BackgroundTransparency = 1.0,
			}),
			Divider = i < #props.Options and Roact.createElement("Frame", {
				Size = UDim2.new(1, -16, 0, 1),
				Position = UDim2.new(.5, 0, 1, 0),
				AnchorPoint = Vector2.new(.5, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = Constants.DarkGrey,
			}) or nil,
		})
	end

	return Roact.createElement(Item, newProps, {
		Button = Roact.createElement("ImageLabel", {
			Image = "rbxasset://textures/ui/btn_newWhite.png",
			ImageColor3 = Constants.RobloxBlue,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(10, 10, 10, 10),
			Size = UDim2.new(0, 88, 1, 3),
			BackgroundTransparency = 1.0,
			AnchorPoint = Vector2.new(1, .5),
			Position = UDim2.new(1, -8, .5, -1),
			ZIndex = 2,
		}, {
			Label = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1, 0, 1, 0),
				Text = props.Options[props.Value],
				Font = Enum.Font.SourceSansSemibold,
				TextSize = 18,
				TextColor3 = Constants.White,
			}),
			Menu = Roact.createElement("ImageButton", {
				BackgroundTransparency = 1.0,
				Visible = self.state.open == true,
				Size = UDim2.new(1, 10000, 1, 10000),
				Position = UDim2.new(0, -5000, 0, -5000),
				ZIndex = 2,

				[Roact.Event.MouseButton1Click] = function(rbx)
					self:setState({
						open = false,
					})
					props.openDropdown(false)
				end,
			}, {
				Holder = Roact.createElement("ImageButton", {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1, -10000, 1, -10000),
					Position = UDim2.new(0, 5000, 0, 5000),

					[Roact.Event.MouseLeave] = function(rbx)
						self:setState({
							hover = false,
						})
					end,
				}, children)
			})
		})
	})
end

local function mapStateToProps(state)
	return {}
end

local function mapDispatchToProps(dispatch)
	return {
		openDropdown = function(value)
			dispatch(Actions.OpenDropdown(value))
		end
	}
end

Dropdown = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(Dropdown)

return Dropdown
