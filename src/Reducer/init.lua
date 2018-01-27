local Search = require(script.Search)
local TagMenu = require(script.TagMenu)
local TagData = require(script.TagData)
local GroupData = require(script.GroupData)
local IconPicker = require(script.IconPicker)
local ColorPicker = require(script.ColorPicker)
local GroupPicker = require(script.GroupPicker)
local WorldView = require(script.WorldView)
local Dropdown = require(script.Dropdown)
local InstanceView = require(script.InstanceView)

return function(state, action)
    state = state or {}
    return {
        Search = Search(state.Search, action),
        TagMenu = TagMenu(state.TagMenu, action),
        TagData = TagData(state.TagData, action),
        GroupData = GroupData(state.GroupData, action),
        IconPicker = IconPicker(state.IconPicker, action),
        ColorPicker = ColorPicker(state.ColorPicker, action),
        GroupPicker = GroupPicker(state.GroupPicker, action),
        WorldView = WorldView(state.WorldView, action),
        Dropdown = Dropdown(state.Dropdown, action),
        InstanceView = InstanceView(state.InstanceView, action),
    }
end
