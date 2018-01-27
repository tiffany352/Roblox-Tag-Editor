local Actions = require(script.Parent.Parent.Actions)

return function(state, action)
    state = state or nil

    if action.Type == Actions.OpenInstanceView then
        return action.View
    end

    return state
end
