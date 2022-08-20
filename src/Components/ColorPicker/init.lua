local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Constants = require(Modules.Plugin.Constants)
local TagManager = require(Modules.Plugin.TagManager)
local Actions = require(Modules.Plugin.Actions)

local Page = require(script.Parent.Page)
local TextBox = require(script.TextBox)
local Button = require(script.Parent.Button)
local StudioThemeAccessor = require(script.Parent.StudioThemeAccessor)
local ValueSlider = require(script.ValueSlider)

local ColorPicker = Roact.PureComponent:extend("ColorPicker")

function ColorPicker:init()
	self.state = {
		h = 0,
		s = 0,
		v = 0,
	}
end

function ColorPicker.getDerivedStateFromProps(nextProps, lastState)
	if nextProps.tagColor == nil then
		if lastState.tagColor then
			local h, s, v = Color3.toHSV(lastState.tagColor)
			return {
				h = h,
				s = s,
				v = v,
			}
		else
			return {
				h = 0,
				s = 0,
				v = 0,
			}
		end
	end
	if lastState.tagColor ~= nextProps.tagColor then
		lastState.tagColor = nextProps.tagColor
		local h, s, v = Color3.toHSV(nextProps.tagColor)
		return {
			-- When we open a fresh color picker, it should default to the color that the tag already was
			h = h,
			s = s,
			v = v,
			tagColor = nextProps.tagColor,
		}
	end
end

function ColorPicker:render()
	local props = self.props
	local hue, sat, val = self.state.h, self.state.s, self.state.v
	local color = Color3.fromHSV(hue, sat, val)
	local red, green, blue = color.r, color.g, color.b

	return StudioThemeAccessor.withTheme(function(theme)
		return Roact.createElement(Page, {
			visible = props.tagName ~= nil,
			titleKey = "ColorPicker_PageTitle",
			titleArgs = {
				Tag = props.tagName or "",
			},
			titleIcon = props.tagIcon,

			close = function()
				props.close()
			end,
		}, {
			Body = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
			}, {
				UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 500 / 280,
				}),
				UIPadding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
				}),
				Wheel = Roact.createElement("ImageButton", {
					Size = UDim2.new(0.5, -4, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
					BorderColor3 = theme:GetColor("Border"),
					Image = "rbxassetid://1357075261",
					BackgroundColor3 = Constants.Black,
					AutoButtonColor = false,
					ImageTransparency = 1 - val,

					[Roact.Event.MouseButton1Down] = function(_rbx)
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
								h = pos.x,
								s = 1 - pos.y,
								wheelMouseDown = false,
							})
						end
					end,

					[Roact.Event.InputChanged] = function(rbx, input)
						if self.state.wheelMouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
							local pos = Vector2.new(input.Position.X, input.Position.Y) - rbx.AbsolutePosition
							pos = pos / rbx.AbsoluteSize

							self:setState({
								h = pos.x,
								s = 1 - pos.y,
							})
						end
					end,
				}, {
					UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint"),
					Position = Roact.createElement("Frame", {
						Size = UDim2.new(0, 4, 0, 4),
						BorderSizePixel = 0,
						Position = UDim2.new(hue, 0, 1 - sat, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Constants.DarkGrey,
					}),
					ValueSlider = Roact.createElement(ValueSlider, {
						hue = hue,
						sat = sat,
						val = val,
						updatePosition = function(newValue)
							self:setState({
								v = newValue,
							})
						end,
					}),
				}),
				PropertiesPanel = Roact.createElement("Frame", {
					Position = UDim2.new(1, 0, 0, 0),
					AnchorPoint = Vector2.new(1, 0),
					Size = UDim2.new(0.5, -8, 1, -64),
					BackgroundTransparency = 1.0,
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 8),
					}),
					Hex = Roact.createElement(TextBox, {
						Size = UDim2.new(1, 0, 0, 20),
						Text = string.format("#%02x%02x%02x", red * 255, green * 255, blue * 255),
						labelKey = "ColorPicker_Hex",
						LayoutOrder = 1,

						Validate = function(text)
							return text:match("^%s*%#?(%x%x%x%x%x%x)%s*$") ~= nil
						end,

						TextChanged = function(text)
							local r, g, b = text:match("^%s*%#?(%x%x)(%x%x)(%x%x)%s*$")
							r = tonumber(r, 16)
							g = tonumber(g, 16)
							b = tonumber(b, 16)
							local intermediaryColor = Color3.fromRGB(r, g, b)
							local newH, newS, newV = Color3.toHSV(intermediaryColor)

							self:setState({
								h = newH,
								s = newS,
								v = newV,
							})
						end,
					}),
					Rgb = Roact.createElement(TextBox, {
						Size = UDim2.new(1, 0, 0, 20),
						Text = ("%d, %d, %d"):format(red * 255, green * 255, blue * 255),
						LayoutOrder = 2,
						labelKey = "ColorPicker_RGB",

						Validate = function(text)
							local r, g, b = text:match("^%s*(%d?%d?%d)%s*,%s*(%d?%d?%d)%s*,%s*(%d?%d?%d)%s*%s*$")

							if r == nil or g == nil or b == nil then
								return false
							end

							if tonumber(r) > 255 or tonumber(g) > 255 or tonumber(b) > 255 then
								return false
							end

							return true
						end,

						TextChanged = function(text)
							local r, g, b = text:match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%s*$")
							r = tonumber(r)
							g = tonumber(g)
							b = tonumber(b)
							local intermediaryColor = Color3.fromRGB(r, g, b)
							local newH, newS, newV = Color3.toHSV(intermediaryColor)

							self:setState({
								h = newH,
								s = newS,
								v = newV,
							})
						end,
					}),
					Hsv = Roact.createElement(TextBox, {
						Size = UDim2.new(1, 0, 0, 20),
						Text = ("%d, %d, %d"):format(hue * 360, sat * 100, val * 100),
						labelKey = "ColorPicker_HSV",
						LayoutOrder = 3,

						Validate = function(text)
							local h, s, v = text:match("^%s*(%d?%d?%d)%s*,%s*(%d?%d?%d)%s*,%s*(%d?%d?%d)%s*%s*$")

							if h == nil or s == nil or v == nil then
								return false
							end

							if tonumber(h) > 360 then
								return false
							end

							if tonumber(s) > 100 or tonumber(v) > 100 then
								return false
							end

							return true
						end,

						TextChanged = function(text)
							local h, s, v = text:match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%s*$")
							h = tonumber(h) / 360
							s = tonumber(s) / 100
							v = tonumber(v) / 100
							self:setState({
								h = h,
								s = s,
								v = v,
							})
						end,
					}),
					Preview = Roact.createElement("Frame", {
						LayoutOrder = 4,
						Size = UDim2.new(1, 0, 0, 48),
						AnchorPoint = Vector2.new(0, 1),
						BackgroundColor3 = color,
						BorderColor3 = theme:GetColor("Border"),
					}),
					Buttons = Roact.createElement("Frame", {
						LayoutOrder = 5,
						Size = UDim2.new(1, 0, 0, 24),
						BackgroundTransparency = 1.0,
					}, {
						UIListLayout = Roact.createElement("UIListLayout", {
							FillDirection = "Horizontal",
							HorizontalAlignment = "Center",
							SortOrder = "LayoutOrder",
							Padding = UDim.new(0, 8),
						}),
						Cancel = Roact.createElement(Button, {
							textKey = "ColorPicker_Cancel",
							Size = UDim2.new(0.5, 0, 0, 24),
							leftClick = props.close,
							LayoutOrder = 2,
						}),
						Submit = Roact.createElement(Button, {
							LayoutOrder = 1,
							textKey = "ColorPicker_Submit",
							Size = UDim2.new(0.5, 0, 0, 24),
							leftClick = function()
								TagManager.Get()
									:SetColor(props.tagName, Color3.fromHSV(self.state.h, self.state.s, self.state.v))
								props.close()
							end,
						}),
					}),
				}),
			}),
		})
	end)
end

local function mapStateToProps(state)
	local tag = state.ColorPicker
	local tagIcon
	local tagColor
	for _, entry in pairs(state.TagData) do
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
