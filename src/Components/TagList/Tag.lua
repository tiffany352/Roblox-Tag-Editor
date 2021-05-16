local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Actions = require(Modules.Plugin.Actions)
local TagManager = require(Modules.Plugin.TagManager)
local Item = require(Modules.Plugin.Components.ListItem)
local TagSettings = require(Modules.Plugin.Components.TagList.TagSettings)
local StudioThemeAccessor = require(Modules.Plugin.Components.StudioThemeAccessor)
local Util = require(Modules.Plugin.Util)
local PluginGlobals = require(Modules.Plugin.PluginGlobals)

local function Tag(props)
	local isOpen = props.tagWithOpenMenu == props.Tag

	local function openMenu(_rbx)
		if not isOpen then
			props.openTagMenu(props.Tag)
		else
			props.openTagMenu(nil)
		end
	end

	local checked = nil
	if not props.Disabled then
		if props.HasAll then
			checked = true
		elseif props.HasSome then
			checked = "ambiguous"
		else
			checked = false
		end
	end

	return StudioThemeAccessor.withTheme(function(theme)
		return Roact.createElement(Item, {
			Text = Util.escapeTagName(props.Tag, theme),
			RichText = true,
			Icon = props.Icon,
			IsInput = false,
			LayoutOrder = props.LayoutOrder,
			Visible = props.Visible,
			Checked = checked,
			Active = isOpen,
			Hidden = props.Hidden,
			Indent = props.Group and 10 or 0,
			Height = isOpen and 171 or 26,

			onSetVisible = function()
				TagManager.Get():SetVisible(props.Tag, not props.Visible)
			end,

			onCheck = function(_rbx)
				TagManager.Get():SetTag(props.Tag, not props.HasAll)
			end,

			leftClick = openMenu,
			rightClick = function(_rbx)
				props.showContextMenu(props.Tag)
			end,
		}, {
			Settings = isOpen and Roact.createElement(TagSettings, {}),
		})
	end)
end

local function mapStateToProps(state)
	return {
		tagWithOpenMenu = state.TagMenu,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		openTagMenu = function(tag)
			dispatch(Actions.OpenTagMenu(tag))
		end,
		showContextMenu = function(tag)
			PluginGlobals.showTagMenu(dispatch, tag)
		end,
	}
end

Tag = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(Tag)

return Tag
