local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local ThemeAccessor = require(script.Parent.ThemeAccessor)
local TextLabel = require(script.Parent.TextLabel)

local function ThemedTextLabel(props)
	return ThemeAccessor.withTheme(function(theme)
		local object = props.object or 'MainSection'
		local state = props.state or 'Normal'
		local newProps = {
			TextColor3 = theme:get(object, 'TextColor3', state),
			Font = theme:get(object, 'Font', state),
		}
		for key, value in pairs(props) do
			if key ~= 'object' and key ~= 'state' then
				newProps[key] = value
			end
		end
		return Roact.createElement(TextLabel, newProps)
	end)
end

return ThemedTextLabel
