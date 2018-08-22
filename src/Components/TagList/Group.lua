local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Item = require(Modules.Plugin.Components.ListItem)

local function Group(props)
	return Roact.createElement(Item, {
		object = "ListItemGroup",
		Text = props.Name,
		TextProps = {
			Font = Enum.Font.SourceSansSemibold,
		},
		menuOpen = true,
		LayoutOrder = props.LayoutOrder,
		SemiActive = props.Hidden,

		leftClick = function()
			props.toggleHidden(props.Name)
		end,
	})
end

return Group
