local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local ThemeAccessor = require(script.Parent.ThemeAccessor)
local Icon = require(script.Parent.Icon)
local TextLabel = require(script.Parent.TextLabel)

local function Page(props)
	return ThemeAccessor.withTheme(function(theme)
		return Roact.createElement("ImageButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = theme:get("MainSection", "BackgroundColor3"),
			ZIndex = 10,
			Visible = props.visible,
			AutoButtonColor = false,
		}, {
			Topbar = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = theme:get("Topbar", "BackgroundColor3"),
				BorderSizePixel = 0,
				ZIndex = 2,
			}, {
				Back = Roact.createElement("TextButton", {
					Size = UDim2.new(0, 48, 0, 32),
					Text = "Back",
					TextSize = 20,
					Font = Enum.Font.SourceSansBold,
					BackgroundTransparency = 1.0,
					TextColor3 = theme:get("Topbar", "TextColor3"),

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
					Icon = props.titleIcon and Roact.createElement(Icon, {
						Name = props.titleIcon,
						LayoutOrder = 1,
					}),
					Label = Roact.createElement(TextLabel, {
						Text = props.title,
						LayoutOrder = 2,
						TextColor3 = theme:get("Topbar", "TextColor3"),
						Font = Enum.Font.SourceSansSemibold,
					}),
				})
			}),
			Body = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, -32),
				Position = UDim2.new(0, 0, 0, 32),
				BackgroundTransparency = 1.0,
			}, props[Roact.Children])
		})
	end)
end

return Page
