local Actions = require(script.Parent.Parent.Actions)

return function(state, action)
    state = state or {}

    if action.Type == Actions.SetUnknownTags then
        return action.Data
    end

    return state
end
