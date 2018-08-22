local ThemeManager = {}
ThemeManager.__index = ThemeManager

function ThemeManager.new(theme)
	local self = {
		onThemeChanged = {},
		theme = theme,
	}
	setmetatable(self, ThemeManager)

	return self
end

function ThemeManager:connectThemeChanged(func)
	self.onThemeChanged[func] = true
end

function ThemeManager:disconnectThemeChanged(func)
	self.onThemeChanged[func] = nil
end

function ThemeManager:setTheme(theme)
	if self.theme ~= theme then
		self.theme = theme
		for func in pairs(self.onThemeChanged) do
			func(theme)
		end
	end
end

return ThemeManager
