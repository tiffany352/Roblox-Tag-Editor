local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local StudioThemeAccessor = require(Modules.Plugin.Components.StudioThemeAccessor)
local Tab = require(script.Parent.Tab)

local function TabGroup(props)
	local folderChildren = {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 3),
		}),
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 3),
			PaddingLeft = UDim.new(0, 3),
			PaddingRight = UDim.new(0, 3),
		}),
	}

	for index, tab in pairs(props.sortedTabs) do
		folderChildren["Tab_" .. tab.name] = Roact.createElement(Tab, {
			name = tab.name,
			selected = props.selected == tab.name,
			height = props.height,
			onSelect = props.onSelect,
			index = index,
		})
	end

	return StudioThemeAccessor.withTheme(function(theme: StudioTheme)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, props.height),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.TabBar),
			BorderSizePixel = 0,
		}, {
			Tabs = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1.0,
				ZIndex = 2,
			}, folderChildren),
			Divider = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 1),
				Position = UDim2.fromScale(0, 1),
				AnchorPoint = Vector2.new(0, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			}),
		})
	end)
end

return TabGroup
