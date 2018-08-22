local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local ThemeProvider = Roact.Component:extend("ThemeProvider")

function ThemeProvider:init(props)
	assert(props.themeManager, "Expected `themeManager` to be passed as props to ThemeProvider")
	self._context[ThemeProvider] = props.themeManager
end

function ThemeProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end

return ThemeProvider
