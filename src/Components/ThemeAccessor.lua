local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local ThemeProvider = require(script.Parent.ThemeProvider)

local ThemeAccessor = Roact.Component:extend("ThemeAccessor")

function ThemeAccessor:init()
	local themeManager = self._context[ThemeProvider]
	self.state = {
		theme = themeManager.theme,
	}
	self.connection = function(theme)
		self:setState({
			theme = theme
		})
	end
	themeManager:connectThemeChanged(self.connection)
end

function ThemeAccessor:willUnmount()
	local themeManager = self._context[ThemeProvider]

	themeManager:disconnectThemeChanged(self.connection)
end

function ThemeAccessor:render()
	local render = Roact.oneChild(self.props[Roact.Children])

	return render(self.state.theme)
end

function ThemeAccessor.withTheme(render)
	return Roact.createElement(ThemeAccessor, {}, {
		render = render,
	})
end

return ThemeAccessor
