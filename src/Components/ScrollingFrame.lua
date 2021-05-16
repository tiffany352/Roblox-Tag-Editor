local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local StudioThemeAccessor = require(Modules.Plugin.Components.StudioThemeAccessor)
local Util = require(Modules.Plugin.Util)

local function ScrollingFrame(props)
	local children = {}

	if props.List then
		local listProps = props.List == true and {} or props.List
		children.UIListLayout = Roact.createElement(
			"UIListLayout",
			Util.merge({
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, listProps)
		)
	end

	for key, value in pairs(props[Roact.Children]) do
		children[key] = value
	end

	return StudioThemeAccessor.withTheme(function(theme, isDarkTheme)
		return Roact.createElement("Frame", {
			Size = props.Size or UDim2.new(1, 0, 1, 0),
			Position = props.Position,
			AnchorPoint = props.AnchorPoint,
			BorderSizePixel = props.ShowBorder and 1 or 0,
			BackgroundColor3 = theme:GetColor("MainBackground"),
			BorderColor3 = theme:GetColor("Border"),
			LayoutOrder = props.LayoutOrder,
			ZIndex = props.ZIndex,
			Visible = props.Visible,
			ClipsDescendants = true,
			[Roact.Ref] = props[Roact.Ref],
		}, {
			BarBackground = Roact.createElement("Frame", {
				BackgroundColor3 = theme:GetColor("ScrollBarBackground"),
				Size = UDim2.new(0, 12, 1, 0),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				BorderSizePixel = 0,
			}),
			ScrollingFrame = Roact.createElement("ScrollingFrame", {
				Size = UDim2.new(1, -2, 1, 0),
				VerticalScrollBarInset = Enum.ScrollBarInset.Always,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 8,
				TopImage = "rbxasset://textures/StudioToolbox/ScrollBarTop.png",
				MidImage = "rbxasset://textures/StudioToolbox/ScrollBarMiddle.png",
				BottomImage = "rbxasset://textures/StudioToolbox/ScrollBarBottom.png",
				ScrollBarImageColor3 = isDarkTheme and Color3.fromRGB(85, 85, 85) or Color3.fromRGB(245, 245, 245), --theme:GetColor("ScrollBar"),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
			}, children),
		})
	end)
end

return ScrollingFrame
