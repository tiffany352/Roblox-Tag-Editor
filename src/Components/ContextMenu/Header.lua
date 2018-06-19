local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Constants = require(Modules.Plugin.Constants)

local Item = require(script.Parent.Item)

local function Header(props)
	local newProps = {
		First = true,
		Last = false,
		ImageColor3 = Constants.RobloxBlue,
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
end

return Header
