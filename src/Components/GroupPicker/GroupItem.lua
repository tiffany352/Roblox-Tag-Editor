local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local TagManager = require(Modules.Plugin.TagManager)
local Actions = require(Modules.Plugin.Actions)
local Item = require(Modules.Plugin.Components.ListItem)

local function GroupItem(props)
	return Roact.createElement(Item, {
		Icon = "folder",
		Text = props.Name,
		textKey = props.nameKey,
		textArgs = props.nameArgs,
		Active = props.Active,
		LayoutOrder = props.LayoutOrder,

		leftClick = function(_rbx)
			TagManager.Get():SetGroup(props.Tag, props.Group)
			props.close()
		end,

		onDelete = props.Group and function()
			props.delete(props.Group)
			props.close()
		end or nil,
	})
end

local function mapStateToProps(state)
	return {
		Tag = state.GroupPicker,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		close = function()
			dispatch(Actions.ToggleGroupPicker(nil))
		end,
		delete = function(name)
			TagManager.Get():DelGroup(name)
		end,
	}
end

GroupItem = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(GroupItem)

return GroupItem
