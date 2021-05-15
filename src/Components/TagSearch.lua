local Modules = script.Parent.Parent.Parent
local RoactRodux = require(Modules.RoactRodux)
local Actions = require(Modules.Plugin.Actions)

local Search = require(script.Parent.Search)

local function mapStateToProps(state)
	return {
		term = state.Search,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		setTerm = function(text)
			dispatch(Actions.SetSearch(text))
		end,
	}
end

local TagSearch = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(Search)

return TagSearch
