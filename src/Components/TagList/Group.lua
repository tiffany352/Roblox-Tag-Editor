local CLOSED_ARROW_IMAGE = "rbxassetid://2606412312"
local OPEN_ARROW_IMAGE = "rbxasset://textures/StudioToolbox/ArrowDownIconWhite.png"

local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local e = Roact.createElement
local ListItemChrome = require(Modules.Plugin.Components.ListItemChrome)
local StudioThemeAccessor = require(Modules.Plugin.Components.StudioThemeAccessor)

local function Group(props)
	return e(ListItemChrome, {
		LayoutOrder = props.LayoutOrder,
		showDivider = true,
		leftClick = function()
			props.toggleHidden(props.Name)
		end,
	}, {
		StudioThemeAccessor.withTheme(function(theme, themeType)
			return e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
			}, {
				GroupText = e("TextLabel", {
					Font = Enum.Font.SourceSansSemibold,
					Text = props.Name,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -70, 1, 0),
					Position = UDim2.new(0, 20, 0, 0),
					TextColor3 = theme:GetColor("MainText"),
					TextXAlignment = "Left",
					TextSize = 20,
				}),
				Arrow = e("ImageLabel", {
					Size = UDim2.new(0, 12, 0, 12),
					Position = UDim2.new(0, 10, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = props.Hidden and CLOSED_ARROW_IMAGE or OPEN_ARROW_IMAGE,
					BackgroundTransparency = 1,
					-- FIXME: This needs a non-hardcoded icon color.
					-- The studio theme API doesn't have a class for this :(
					ImageColor3 = themeType == Enum.UITheme.Light and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(242, 242, 242),
				})
			})
		end)
	})
end

return Group
