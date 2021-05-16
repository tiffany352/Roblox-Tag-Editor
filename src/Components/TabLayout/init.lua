local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local TabGroup = require(script.TabGroup)
local Util = require(Modules.Plugin.Util)

local TABLIST_HEIGHT = 24

local TabLayout = Roact.PureComponent:extend("TabLayout")

function TabLayout:render()
	local currentTab = Util.findIf(self.props.tabs, function(tab)
		return tab.name == self.state.currentTab
	end)
	local renderFunc = currentTab.render

	return Roact.createElement("Frame", {
		Size = self.props.Size or UDim2.fromScale(1, 1),
		Position = self.props.Position,
		AnchorPoint = self.props.AnchorPoint,
		LayoutOrder = self.props.LayoutOrder,
		BackgroundTransparency = 1.0,
	}, {
		TabGroup = Roact.createElement(TabGroup, {
			sortedTabs = self.props.tabs,
			selected = self.state.currentTab,
			height = TABLIST_HEIGHT,
			onSelect = function(tab)
				self:setState({
					currentTab = tab,
				})
			end,
		}),
		TabPanel = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -TABLIST_HEIGHT),
			Position = UDim2.fromOffset(0, TABLIST_HEIGHT),
			BackgroundTransparency = 1.0,
		}, {
			Content = renderFunc(),
		}),
	})
end

function TabLayout.getDerivedStateFromProps(props, lastState)
	return {
		currentTab = lastState.currentTab or props.tabs[1].name,
	}
end

return TabLayout
