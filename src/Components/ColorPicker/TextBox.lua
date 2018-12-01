local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local e = Roact.createElement
local Constants = require(Modules.Plugin.Constants)
local StudioThemeAccessor = require(Modules.Plugin.Components.StudioThemeAccessor)

local TextBox = Roact.PureComponent:extend("ColorPicker.TextBox")

function TextBox:init()
	self.state = {
		hover = false,
		press = false,
		isValid = true,
	}

	self._textboxRef = Roact.createRef()
end

function TextBox:render()
	local props = self.props
	local inset = props.Inset or 36

	return StudioThemeAccessor.withTheme(function(theme)
		local borderColor
		if not self.state.isValid then
			borderColor = Color3.new(1, 0, 0)
		else
			local searchBarState = "Default"
			if self.state.focus then
				searchBarState = "Selected"
			elseif self.state.hover then
				searchBarState = "Hover"
			end

			borderColor = theme:GetColor("InputFieldBorder", searchBarState)
		end

		return e("Frame", {
			Size = props.Size,
			Position = props.Position,
			BackgroundTransparency = 1.0,
			LayoutOrder = props.LayoutOrder,
		}, {
			Label = props.Label and e("TextLabel", {
				Text = props.Label,
				Size = UDim2.new(0, inset, 0, 20),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 20,
				Font = Enum.Font.SourceSans,
				TextColor3 = theme:GetColor("MainText"),
				BackgroundTransparency = 1.0,
			}) or nil,
			Input = e("Frame", {
				Size = UDim2.new(1, -inset, 1, 0),
				Position = UDim2.new(0, inset, 0, 0),
				BackgroundColor3 = theme:GetColor("InputFieldBackground"),
				BorderColor3 = borderColor,

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
			}, {
				TextBox = e("TextBox", {
					Text = "",
					PlaceholderText = props.Text,
					PlaceholderColor3 = theme:GetColor("DimmedText"),
					Font = Enum.Font.SourceSans,
					TextSize = 20,
					TextColor3 = theme:GetColor("MainText"),
					Size = UDim2.new(1, -16, 1, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					BackgroundTransparency = 1.0,
					TextXAlignment = Enum.TextXAlignment.Left,

					[Roact.Ref] = self._textboxRef,

					[Roact.Event.Focused] = function(rbx)
						self:setState({
							focus = true,
						})
					end,

					[Roact.Event.FocusLost] = function(rbx, enterPressed)
						self:setState({
							focus = false,
						})

						if enterPressed then
							if props.Validate(rbx.Text) then
								self.props.TextChanged(rbx.Text)
							end
						end
					end,
				})
			})
		})
	end)
end

function TextBox:didMount()
	local debounce = false
	local rbx = self._textboxRef.current

	self._inputConnection = rbx:GetPropertyChangedSignal("Text"):Connect(function()
		if debounce then return end
		debounce = true
		local isValid = true

		if rbx.Text ~= "" then
			isValid = self.props.Validate(rbx.Text)
		end

		if isValid ~= self.state.isValid then
			self:setState({
				isValid = isValid
			})
		end

		debounce = false
	end)
end

function TextBox:willUnmount()
	self._inputConnection:Disconnect()
end

return TextBox
