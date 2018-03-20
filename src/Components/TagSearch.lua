local Modules = script.Parent.Parent.Parent
local RoactRodux = require(Modules.RoactRodux)

local Actions = require(script.Parent.Parent.Actions)
local Search = require(script.Parent.Search)

local TagSearch = RoactRodux.connect(function(store)
    local state = store:getState()

    return {
        term = state.Search,
        setTerm = function(text)
            store:dispatch(Actions.SetSearch(text))
        end
    }
end)(Search)

return TagSearch
