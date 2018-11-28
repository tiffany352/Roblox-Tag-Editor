local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Actions = require(Modules.Plugin.Actions)
local TagManager = require(Modules.Plugin.TagManager)
local Item = require(Modules.Plugin.Components.ListItem)

local function Tag(props)
	return Roact.createElement(Item, {
		Text = props.Tag,
		Icon = props.Icon,
		IsInput = false,
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible,
		Active = props.HasAll,
		SemiActive = props.HasSome,
		Hidden = props.Hidden,
		Indent = props.Group and 10 or 0,

		onSetVisible = function()
			TagManager.Get():SetVisible(props.Tag, not props.Visible)
		end,

		onSettings = function()
			props.openTagMenu(props.Tag)
		end,

		leftClick = function(rbx)
			TagManager.Get():SetTag(props.Tag, not props.HasAll)
		end,

		rightClick = function(rbx)
			props.openTagMenu(props.Tag)
		end,
	})
end

local function mapStateToProps(state)
	return {}
end

local function mapDispatchToProps(dispatch)
	return {
		openTagMenu = function(tag)
			dispatch(Actions.OpenTagMenu(tag))
		end
	}
end

Tag = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(Tag)

return Tag
