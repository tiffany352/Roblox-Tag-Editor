local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local RootPortal = require(script.Parent.Parent.RootPortal)
local StudioThemeAccessor = require(script.Parent.Parent.StudioThemeAccessor)

local ValueSlider = Roact.PureComponent:extend("ValueSlider")

function ValueSlider:init()
	self.state = {
		mouseDown = false,
	}

	self._rootRef = Roact.createRef()
end

function ValueSlider:xToAlpha(x)
	local rbx = self._rootRef.current

	return math.clamp((x - rbx.AbsolutePosition.X) / rbx.AbsoluteSize.X, 0, 1)
end

function ValueSlider:render()
	return StudioThemeAccessor.withTheme(function(theme)
		return Roact.createElement("ImageButton", {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 1, 5),
			AnchorPoint = Vector2.new(0, 0),
			Image = "rbxassetid://1357203924",
			ImageColor3 = Color3.fromHSV(self.props.hue, self.props.sat, 1),
			AutoButtonColor = false,
			BorderColor3 = theme:GetColor("Border"),
			[Roact.Ref] = self._rootRef,

			[Roact.Event.MouseButton1Down] = function(_rbx, x, _y)
				self:setState({
					valueMouseDown = true,
				})

				self.props.updatePosition(self:xToAlpha(x))
			end,
		}, {
			Position = Roact.createElement("ImageLabel", {
				Size = UDim2.new(0, 8, 0, 5),
				BackgroundTransparency = 1,
				Position = UDim2.new(self.props.val, 0, 0, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				Image = "rbxassetid://2610863246",
				-- Hardcode this color, since the color it's on top of doesn't respond to themes
				ImageColor3 = Color3.fromRGB(255, 255, 255),
			}),
			Portal = Roact.createElement(RootPortal, nil, {
				ValueSliderInputCapturer = Roact.createElement("ImageButton", {
					BackgroundTransparency = 1,
					ZIndex = 100,
					Size = self.state.valueMouseDown and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 0, 0),
					Visible = self.state.valueMouseDown,
					[Roact.Event.MouseButton1Up] = function(_rbx, x, _y)
						if self.state.valueMouseDown then
							self:setState({
								valueMouseDown = false,
							})

							self.props.updatePosition(self:xToAlpha(x))
						end
					end,
					[Roact.Event.MouseMoved] = function(_rbx, x, _y)
						if self.state.valueMouseDown then
							self.props.updatePosition(self:xToAlpha(x))
						end
					end,
				}),
			}),
		})
	end)
end

return ValueSlider
