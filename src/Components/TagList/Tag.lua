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
	local function openMenu(_rbx)
		if not props.isMenuOpen then
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
			Text = Util.escapeTextColored(props.Tag, theme),
			AutoLocalize = false,
			RichText = true,
			Icon = props.Icon,
			IsInput = props.isBeingRenamed,
			ClearTextOnFocus = false,
			CaptureFocusOnBecomeInput = true,
			TextBoxText = props.Tag,
			LayoutOrder = props.LayoutOrder,
			Visible = props.Visible,
			Checked = checked,
			Active = props.isMenuOpen,
			Hidden = props.Hidden,
			Indent = props.Group and 10 or 0,

			onSetVisible = function()
				TagManager.Get():SetVisible(props.Tag, not props.Visible)
			end,

			onCheck = function(_rbx)
				TagManager.Get():SetTag(props.Tag, not props.HasAll)
			end,

			onSubmit = function(_rbx, newName)
				props.stopRenaming()
				TagManager.Get():Rename(props.Tag, newName)
			end,

			onFocusLost = props.stopRenaming,
			leftClick = openMenu,
			rightClick = function(_rbx)
				props.showContextMenu(props.Tag)
			end,
		}, {
			Settings = props.isMenuOpen and Roact.createElement(TagSettings, {}),
		})
	end)
end

local function mapStateToProps(state, props)
	return {
		isMenuOpen = state.TagMenu == props.Tag,
		isBeingRenamed = state.RenamingTag == props.Tag,
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
		stopRenaming = function(tag)
			dispatch(Actions.SetRenaming(tag, false))
		end,
	}
end

Tag = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(Tag)

return Tag
