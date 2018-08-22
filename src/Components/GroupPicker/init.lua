local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Actions = require(Modules.Plugin.Actions)
local TagManager = require(Modules.Plugin.TagManager)

local Page = require(script.Parent.Page)
local ScrollingFrame = require(script.Parent.ScrollingFrame)
local Item = require(script.Parent.ListItem)
local GroupItem = require(script.GroupItem)

local function GroupPicker(props)
	local children = {}

	children.UIPadding = Roact.createElement("UIPadding", {
		PaddingTop = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 2),
		PaddingLeft = UDim.new(0, 2),
		PaddingRight = UDim.new(0, 2),
	})

	children.Default = Roact.createElement(GroupItem, {
		Name = "Default",
		Group = nil,
		Active = props.tagGroup == nil,
		LayoutOrder = -1,
	})

	table.sort(props.groups, function(a,b) return a.Name < b.Name end)

	for i,entry in pairs(props.groups) do
		local group = entry.Name
		children['Group '..group] = Roact.createElement(GroupItem, {
			Name = group,
			Group = group,
			Active = props.tagGroup == group,
			LayoutOrder = i,
		})
	end

	children.AddNew = Roact.createElement(Item, {
		LayoutOrder = 99999999,
		Text = "Add new group...",
		Icon = "folder_add",
		IsInput = true,

		onSubmit = function(rbx, text)
			TagManager.Get():AddGroup(text)
		end,
	})

	return Roact.createElement(Page, {
		visible = props.groupPicker ~= nil,
		title = tostring(props.groupPicker).." - Select a Group",
		titleIcon = props.tagIcon,

		close = props.close,
	}, {
		Body = Roact.createElement(ScrollingFrame, {
			Size = UDim2.new(1, 0, 1, 0),
			List = true,
		}, children)
	})
end

local function mapStateToProps(state)
	local tag = state.GroupPicker and TagManager.Get().tags[state.GroupPicker]

	return {
		groupPicker = state.GroupPicker,
		tagIcon = tag and tag.Icon or nil,
		tagGroup = tag and tag.Group or nil,
		groups = state.GroupData,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		close = function()
			dispatch(Actions.ToggleGroupPicker(nil))
		end,
	}
end

GroupPicker = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(GroupPicker)

return GroupPicker
