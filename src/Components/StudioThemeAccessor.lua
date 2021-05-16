local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local StudioThemeAccessor = Roact.PureComponent:extend("StudioThemeAccessor")

function isDarkTheme(color: Color3)
	-- Not a correct luminance function but it doesn't need to be.
	local luminance = (color.R + color.G + color.B) / 3
	return luminance < 0.5
end

function StudioThemeAccessor:init()
	local studioSettings = settings().Studio

	self.state = {
		theme = studioSettings.Theme,
		isDarkTheme = isDarkTheme(studioSettings.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)),
	}

	self._themeConnection = studioSettings.ThemeChanged:Connect(function()
		self:setState({
			theme = studioSettings.Theme,
			isDarkTheme = isDarkTheme(studioSettings.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)),
		})
	end)
end

function StudioThemeAccessor:willUnmount()
	self._themeConnection:Disconnect()
end

function StudioThemeAccessor:render()
	local render = Roact.oneChild(self.props[Roact.Children])

	return render(self.state.theme, self.state.isDarkTheme)
end

function StudioThemeAccessor.withTheme(render: (StudioTheme) -> any)
	return Roact.createElement(StudioThemeAccessor, {}, {
		render = render,
	})
end

return StudioThemeAccessor
