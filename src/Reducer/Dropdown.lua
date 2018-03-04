local Actions = require(script.Parent.Parent.Actions)

return function(state, action)
    state = state or false

    if action.Type == Actions.OpenDropdown then
        return action.Open
    end

    return state
end
