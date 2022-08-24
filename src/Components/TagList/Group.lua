local CLOSED_ARROW_IMAGE = "rbxassetid://2606412312"
local OPEN_ARROW_IMAGE = "rbxasset://textures/StudioToolbox/ArrowDownIconWhite.png"

local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local ListItemChrome = require(Modules.Plugin.Components.ListItemChrome)
local StudioThemeAccessor = require(Modules.Plugin.Components.StudioThemeAccessor)
local Icon = require(Modules.Plugin.Components.Icon)
local TagManager = require(Modules.Plugin.TagManager)

local function Group(props)
	return Roact.createElement(ListItemChrome, {
		LayoutOrder = props.LayoutOrder,
		showDivider = true,
		leftClick = function()
			props.toggleHidden(props.Name)
		end,
	}, {
		StudioThemeAccessor.withTheme(function(theme, isDarkTheme)
			return Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 3),
					PaddingBottom = UDim.new(0, 3),
				}),
				Visibility = Roact.createElement(Icon, {
					Name = "folder_lightbulb",
					Position = UDim2.new(1, -4, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					ZIndex = 10,
					onClick = function()
						TagManager:Get():SetGroupVisiblity(props.Name)
					end,
				}),
				GroupText = Roact.createElement("TextLabel", {
					Font = Enum.Font.SourceSansSemibold,
					Text = props.Name,
					AutoLocalize = false,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -70, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					Position = UDim2.new(0, 20, 0, 0),
					TextColor3 = theme:GetColor("MainText"),
					TextXAlignment = "Left",
					TextSize = 20,
					TextWrapped = true,
				}),
				Arrow = Roact.createElement("ImageLabel", {
					Size = UDim2.new(0, 12, 0, 12),
					Position = UDim2.new(0, 10, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = props.Hidden and CLOSED_ARROW_IMAGE or OPEN_ARROW_IMAGE,
					BackgroundTransparency = 1,
					-- FIXME: This needs a non-hardcoded icon color.
					-- The studio theme API doesn't have a class for this :(
					ImageColor3 = isDarkTheme and Color3.fromRGB(242, 242, 242) or Color3.fromRGB(25, 25, 25),
				}),
			})
		end),
	})
end

return Group
