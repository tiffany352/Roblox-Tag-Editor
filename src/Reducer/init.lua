local Search = require(script.Search)
local IconSearch = require(script.IconSearch)
local TagMenu = require(script.TagMenu)
local TagData = require(script.TagData)
local UnknownTags = require(script.UnknownTags)
local GroupData = require(script.GroupData)
local IconPicker = require(script.IconPicker)
local ColorPicker = require(script.ColorPicker)
local GroupPicker = require(script.GroupPicker)
local WorldView = require(script.WorldView)
local Dropdown = require(script.Dropdown)
local InstanceView = require(script.InstanceView)
local HoveredIcon = require(script.HoveredIcon)
local SelectionActive = require(script.SelectionActive)
local RenamingTag = require(script.RenamingTag)

return function(state, action)
	state = state or {}
	return {
		IconSearch = IconSearch(state.IconSearch, action),
		Search = Search(state.Search, action),
		TagMenu = TagMenu(state.TagMenu, action),
		TagData = TagData(state.TagData, action),
		UnknownTags = UnknownTags(state.UnknownTags, action),
		GroupData = GroupData(state.GroupData, action),
		IconPicker = IconPicker(state.IconPicker, action),
		ColorPicker = ColorPicker(state.ColorPicker, action),
		GroupPicker = GroupPicker(state.GroupPicker, action),
		WorldView = WorldView(state.WorldView, action),
		Dropdown = Dropdown(state.Dropdown, action),
		InstanceView = InstanceView(state.InstanceView, action),
		HoveredIcon = HoveredIcon(state.HoveredIcon, action),
		SelectionActive = SelectionActive(state.SelectionActive, action),
		RenamingTag = RenamingTag(state.RenamingTag, action),
	}
end
