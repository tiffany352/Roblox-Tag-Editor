local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Constants = require(Modules.Plugin.Constants)

local function TextBox(props)
	local inset = props.Inset or 36
	return Roact.createElement("Frame", {
		Size = props.Size,
		Position = props.Position,
		BackgroundTransparency = 1.0,
		LayoutOrder = props.LayoutOrder,
	}, {
		Label = props.Label and Roact.createElement("TextLabel", {
			Text = props.Label,
			Size = UDim2.new(0, inset, 0, 20),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 20,
			Font = Enum.Font.SourceSans,
			TextColor3 = Constants.Black,
			BackgroundTransparency = 1.0,
		}) or nil,
		Input = Roact.createElement("Frame", {
			Size = UDim2.new(1, -inset, 1, 0),
			Position = UDim2.new(0, inset, 0, 0),
			BackgroundColor3 = Constants.White,
			BorderColor3 = Constants.DarkGrey,
		}, {
			TextBox = Roact.createElement("TextBox", {
				Text = "",
				PlaceholderText = props.Text,
				PlaceholderColor3 = Constants.DarkGrey,
				Font = Enum.Font.SourceSans,
				TextSize = 20,
				TextColor3 = Constants.Black,
				Size = UDim2.new(1, -16, 1, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(.5, 0, .5, 0),
				BackgroundTransparency = 1.0,

				[Roact.Ref] = function(rbx)
					if not rbx then return end
					local oldText = rbx.Text
					if rbx and props.Validate then
						local debounce = false
						rbx:GetPropertyChangedSignal("Text"):Connect(function()
							if debounce then return end
							debounce = true
							local text = props.Validate(rbx.Text)
							if text then
								rbx.Text = text
								oldText = text
							else
								rbx.Text = oldText
							end
							debounce = false
						end)
					end
				end,
			})
		})
	})
end

return TextBox
