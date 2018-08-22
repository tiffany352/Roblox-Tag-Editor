local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Constants = require(Modules.Plugin.Constants)
local ThemeAccessor = require(Modules.Plugin.Components.ThemeAccessor)

local Item = require(script.Parent.Item)

local function Header(props)
	return ThemeAccessor.withTheme(function(theme)
		local newProps = {
			First = true,
			Last = false,
			ImageColor3 = theme:get("ContextMenuHeader", "BackgroundColor3", "Normal"),
			TextProps = {
				TextColor3 = Constants.White,
				Font = Enum.Font.SourceSansSemibold,
			},
			NoDivider = true,
			Text = props.Text,

			onClick = function()
			end,
		}
		local blacklist = {
			Text = true,
		}
		for k,v in pairs(props) do
			if not blacklist[k] then
				newProps[k] = v
			end
		end
		return Roact.createElement(Item, newProps)
	end)
end

return Header
