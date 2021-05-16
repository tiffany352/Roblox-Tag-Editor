local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Actions = require(Modules.Plugin.Actions)
local Util = require(Modules.Plugin.Util)

local InstanceList = require(script.InstanceList)
local TaggedInstanceProvider = require(script.TaggedInstanceProvider)

local function InstanceView(props)
	return Roact.createElement(TaggedInstanceProvider, {
		tagName = props.tagName,
	}, {
		render = function(parts, selected)
			return Roact.createElement(InstanceList, {
				parts = parts,
				selected = selected,
				tagName = props.tagName,
				tagIcon = props.tagIcon,
				close = props.close,
			})
		end,
	})
end

local function mapStateToProps(state)
	local tag = state.InstanceView
		and Util.findIf(state.TagData, function(item)
			return item.Name == state.InstanceView
		end)

	return {
		tagName = state.InstanceView,
		tagIcon = tag and tag.Icon or nil,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		close = function()
			dispatch(Actions.OpenInstanceView(nil))
		end,
	}
end

InstanceView = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(InstanceView)

return InstanceView
