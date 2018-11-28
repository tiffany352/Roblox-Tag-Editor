local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local StudioThemeAccessor = Roact.PureComponent:extend("StudioThemeAccessor")

function StudioThemeAccessor:init()
	local studioSettings = settings().Studio

	self.state = {
		theme = studioSettings.Theme,
	}

	self._themeConnection = studioSettings.ThemeChanged:Connect(function()
		self:setState({
			theme = studioSettings.Theme,
		})
	end)
end

function StudioThemeAccessor:willUnmount()
	self._themeConnection:Disconnect()
end

function StudioThemeAccessor:render()
	local render = Roact.oneChild(self.props[Roact.Children])

	return render(self.state.theme)
end

function StudioThemeAccessor.withTheme(render)
	return Roact.createElement(StudioThemeAccessor, {}, {
		render = render,
	})
end

return StudioThemeAccessor
