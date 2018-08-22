local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local ThemeAccessor = require(script.Parent.ThemeAccessor)

local function Search(props)
	return Roact.createElement("Frame", {
		Size = props.Size,
		BackgroundTransparency = 1.0,
	}, {
		SearchBarContainer = Roact.createElement("ImageLabel", {
			BackgroundTransparency = 1.0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -10, 1, -10),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(32, 32, 32, 32),
			Image = "rbxasset://textures/ui/Keyboard/key_selection_9slice.png", -- rbxassetid://1353028396
		}, {
			SearchBar = ThemeAccessor.withTheme(function(theme)
				return Roact.createElement("TextBox", {
					AnchorPoint = Vector2.new(.5, .5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(1, -20, 0, 20),
					BackgroundTransparency = 1.0,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSans,
					TextSize = 20,
					PlaceholderText = "Search",
					PlaceholderColor3 = theme:get("SearchBar", "PlaceholderColor3", "Normal"),
					TextColor3 = theme:get("SearchBar", "TextColor3", "Normal"),
					Text = props.term,
					ClearTextOnFocus = false,

					[Roact.Event.Changed] = function(rbx, prop)
						if prop == 'Text' then
							props.setTerm(rbx.Text)
						end
					end,

					[Roact.Event.InputBegan] = function(rbx, input)
						if input.UserInputType == Enum.UserInputType.MouseButton2 and input.UserInputState == Enum.UserInputState.Begin then
							props.setTerm("")
						end
					end,
				})
			end)
		})
	})
end

return Search
