local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Constants = require(Modules.Plugin.Constants)
local TagManager = require(Modules.Plugin.TagManager)
local Actions = require(Modules.Plugin.Actions)

local TextLabel = require(script.Parent.TextLabel)
local Icon = require(script.Parent.Icon)
local TextBox = require(script.TextBox)

local ColorPicker = Roact.Component:extend("ColorPicker")

function ColorPicker:init()
	self.state = {
		color = Constants.RobloxRed,
	}
end

function ColorPicker.getDerivedStateFromProps(nextProps, lastState)
	return {
		-- When we open a fresh color picker, it should default to the color that the tag already was
		color = nextProps.tagColor,
	}
end

function ColorPicker:render()
	local props = self.props
	local color = self.state.color
	local hue, sat, val = Color3.toHSV(color)
	local red, grn, blu = color.r, color.g, color.b

	return Roact.createElement("ImageButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Constants.Black,
		BackgroundTransparency = .3,
		ZIndex = 10,
		Visible = props.tagName ~= nil,
		AutoButtonColor = false,
	}, {
		Topbar = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = Constants.RobloxBlue,
			BorderSizePixel = 0,
		}, {
			Back = Roact.createElement("TextButton", {
				Size = UDim2.new(0, 48, 0, 32),
				Text = "Back",
				TextSize = 20,
				Font = Enum.Font.SourceSansBold,
				BackgroundTransparency = 1.0,
				TextColor3 = Constants.White,

				[Roact.Event.MouseButton1Click] = function(rbx)
					props.close()
				end,
			}),
			Title = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1.0,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4),
				}),
				Icon = Roact.createElement(Icon, {
					Name = props.tagIcon,
					LayoutOrder = 1,
				}),
				Label = Roact.createElement(TextLabel, {
					Text = tostring(props.tagName).." - Select Color",
					LayoutOrder = 2,
					TextColor3 = Constants.White,
					Font = Enum.Font.SourceSansSemibold,
				}),
			})
		}),
		Body = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -32),
			Position = UDim2.new(0.5, 0, 0.5, 16),
			AnchorPoint = Vector2.new(.5, .5),
			BackgroundColor3 = Constants.White,
			BorderColor3 = Constants.LightGrey,
		}, {
			UISizeConstraint = Roact.createElement("UISizeConstraint", {
				MaxSize = Vector2.new(500, 300),
			}),
			UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 298 / (226 - 32), --500 / ((500-20)/2 - 4 + 32 + 20),
			}),
			UIPadding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),
			Wheel = Roact.createElement("ImageButton", {
				Size = UDim2.new(.5, -4, 1, -32),
				Position = UDim2.new(0, 0, 0, 0),
				BorderColor3 = Constants.DarkGrey,
				Image = 'rbxassetid://1357075261',
				BackgroundColor3 = Constants.Black,
				AutoButtonColor = false,
				ImageTransparency = 1 - val,

				[Roact.Event.MouseButton1Down] = function(rbx)
					self:setState({
						wheelMouseDown = true,
					})
				end,

				[Roact.Event.InputEnded] = function(rbx, input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and self.state.wheelMouseDown then
						local x, y = input.Position.X, input.Position.Y
						local pos = Vector2.new(x, y) - rbx.AbsolutePosition
						pos = pos / rbx.AbsoluteSize
						pos = Vector2.new(math.clamp(pos.x, 0, 1), math.clamp(pos.y, 0, 1))
						self:setState({
							color = Color3.fromHSV(pos.x, 1 - pos.y, val),
							wheelMouseDown = false,
						})
					end
				end,

				[Roact.Event.InputChanged] = function(rbx, input)
					if self.state.wheelMouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
						local pos = Vector2.new(input.Position.X, input.Position.Y) - rbx.AbsolutePosition
						pos = pos / rbx.AbsoluteSize

						self:setState({
							color = Color3.fromHSV(pos.x, 1 - pos.y, val),
						})
					end
				end,
			}, {
				UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint"),
				Position = Roact.createElement("ImageLabel", {
					Size = UDim2.new(0, 3, 0, 3),
					BorderSizePixel = 0,
					Position = UDim2.new(hue, -1, 1 - sat, -1),
					BackgroundColor3 = Constants.DarkGrey,
				})
			}),
			ValueSlider = Roact.createElement("ImageButton", {
				Size = UDim2.new(.5, -4, 0, 20),
				Position = UDim2.new(1, 0, 0, 0),
				AnchorPoint = Vector2.new(1, 0),
				Image = 'rbxassetid://1357203924',
				AutoButtonColor = false,

				[Roact.Event.MouseButton1Down] = function(rbx)
					self:setState({
						valueMouseDown = true,
					})
				end,

				[Roact.Event.MouseButton1Up] = function(rbx, x, y)
					if self.state.valueMouseDown then
						local pos = x - rbx.AbsolutePosition.X
						pos = pos / rbx.AbsoluteSize.X
						pos = math.clamp(pos, 0, 1)

						self:setState({
							valueMouseDown = false,
							color = Color3.fromHSV(hue, sat, pos),
						})
					end
				end,

				[Roact.Event.InputChanged] = function(rbx, input)
					if self.state.valueMouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
						local pos = input.Position.X - rbx.AbsolutePosition.X
						pos = pos / rbx.AbsoluteSize.x

						self:setState({
							color = Color3.fromHSV(hue, sat, pos),
						})
					end
				end,
			}, {
				Position = Roact.createElement("Frame", {
					Size = UDim2.new(0, 1, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Constants.RobloxBlue,
					Position = UDim2.new(val, 0, 0, 0),
				})
			}),
			Cancel = Roact.createElement("TextButton", {
				Text = "Cancel",
				Size = UDim2.new(0, 80, 0, 24),
				TextSize = 20,
				Font = Enum.Font.SourceSansBold,
				BackgroundColor3 = Constants.RobloxBlue,
				BorderColor3 = Constants.RobloxBlue:lerp(Constants.Black, .3333),
				Position = UDim2.new(.25, 0, 1, 0),
				AnchorPoint = Vector2.new(.5, 1),
				TextColor3 = Constants.White,

				[Roact.Event.MouseButton1Click] = function(rbx)
					props.close()
				end,
			}),
			Submit = Roact.createElement("TextButton", {
				Text = "Submit",
				Size = UDim2.new(0, 80, 0, 24),
				TextSize = 20,
				Font = Enum.Font.SourceSansBold,
				BackgroundColor3 = Constants.RobloxBlue,
				BorderColor3 = Constants.RobloxBlue:lerp(Constants.Black, .3333),
				Position = UDim2.new(.75, 0, 1, 0),
				AnchorPoint = Vector2.new(.5, 1),
				TextColor3 = Constants.White,

				[Roact.Event.MouseButton1Click] = function(rbx)
					TagManager.Get():SetColor(props.tagName, self.state.color)
					props.close()
				end,
			}),
			PropertiesPanel = Roact.createElement("Frame", {
				Position = UDim2.new(1, 0, 0, 24),
				AnchorPoint = Vector2.new(1, 0),
				Size = UDim2.new(.5, -8, 1, -32 - 32),
				BackgroundTransparency = 1.0,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4),
				}),
				Hex = Roact.createElement(TextBox, {
					Size = UDim2.new(0, 128, 0, 20),
					Text = string.format(
						"%02x%02x%02x",
						red*255, grn*255, blu*255
					),
					Label = "Hex",
					LayoutOrder = 1,

					Validate = function(text)
						local col = text:match("^%#?(%x?%x?%x?%x?%x?%x?)$")
						if col then
							local r, g, b = col:match("^(%x%x)(%x%x)(%x%x)$")
							if not r and g and b then
								r, g, b = col:match("^(%x)(%x)(%x)$")
								if r and g and b then
									col = r..r..g..g..b..b
								end
							end
							if r and g and b then
								r = tonumber(r, 16)
								g = tonumber(g, 16)
								b = tonumber(b, 16)
								self:setState({
									color = Color3.fromRGB(r, g, b),
								})
							end
						end
						return col
					end,
				}),
				Rgb = Roact.createElement(TextBox, {
					Size = UDim2.new(0, 128, 0, 20),
					Text = (function()
						local col = self.state.color
						local r, g, b = col.r, col.g, col.b
						return string.format(
							"%d, %d, %d",
							r*255, g*255, b*255
						)
					end)(),
					LayoutOrder = 2,
					Label = "RGB",

					Validate = function(text)
						local col = text:match("^%d?%d?%d,%s?%d?%d?%d,%s?%d?%d?%d$")
						if col then
							local r, g, b = col:match("^(%d+),%s?(%d+),%s?(%d+)$")
							if r and g and b then
								r = tonumber(r)
								g = tonumber(g)
								b = tonumber(b)
								self:setState({
									Color3.fromRGB(r, g, b),
								})
							end
						end
						return col
					end,
				}),
				Hsv = Roact.createElement(TextBox, {
					Size = UDim2.new(0, 128, 0, 20),
					Text = (function()
						local col = self.state.color
						local h, s, v = Color3.toHSV(col)
						return string.format(
							"%d, %d, %d",
							h*255, s*255, v*255
						)
					end)(),
					Label = "HSV",
					LayoutOrder = 3,

				}),
				Preview = Roact.createElement("Frame", {
					LayoutOrder = 10,
					Size = UDim2.new(0, 64, 0, 32),
					AnchorPoint = Vector2.new(0, 1),
					BackgroundColor3 = self.state.color,
					BorderColor3 = Constants.DarkGrey,
				}),
			}),
		})
	})
end

local function mapStateToProps(state)
	local tag = state.ColorPicker
	local tagIcon
	local tagColor
	for _,entry in pairs(state.TagData) do
		if entry.Name == tag then
			tagIcon = entry.Icon
			tagColor = entry.Color
			break
		end
	end

	return {
		tagName = tag,
		tagIcon = tagIcon,
		tagColor = tagColor,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		close = function()
			dispatch(Actions.ToggleColorPicker(nil))
		end,
	}
end

ColorPicker = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(ColorPicker)

return ColorPicker
