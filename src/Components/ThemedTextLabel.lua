local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local StudioThemeAccessor = require(script.Parent.StudioThemeAccessor)
local TextLabel = require(script.Parent.TextLabel)

local function ThemedTextLabel(props)
	local kind = props.object or "MainText"
	local state = props.state or "Default"

	return StudioThemeAccessor.withTheme(function(theme)
		local newProps = {
			TextColor3 = theme:GetColor(kind, state),
			Font = Enum.Font.SourceSans,
		}
		for key, value in pairs(props) do
			if key ~= "object" and key ~= "state" then
				newProps[key] = value
			end
		end
		return Roact.createElement(TextLabel, newProps, props[Roact.Children])
	end)
end

return ThemedTextLabel
