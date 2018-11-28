local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local ThemeAccessor = require(script.Parent.ThemeAccessor)
local StudioThemeAccessor = require(script.Parent.StudioThemeAccessor)

local function Search(props)
	return Roact.createElement("Frame", {
		Size = props.Size,
		BackgroundTransparency = 1.0,
	}, {
		SearchBarContainer = StudioThemeAccessor.withTheme(function(theme)
			return Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -16, 1, -16),
				BackgroundColor3 = theme:GetColor("InputFieldBackground", "Default"),
				BorderSizePixel = 1,
				BorderColor3 = theme:GetColor("Border", "Default"),
			}, {
				SearchBar = Roact.createElement("TextBox", {
					AnchorPoint = Vector2.new(.5, .5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(1, -20, 0, 20),
					BackgroundTransparency = 1.0,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSans,
					TextSize = 20,
					PlaceholderText = "Search",
					PlaceholderColor3 = theme:GetColor("DimmedText"),
					TextColor3 = theme:GetColor("MainText"),
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
			})
		end)
	})
end

return Search
