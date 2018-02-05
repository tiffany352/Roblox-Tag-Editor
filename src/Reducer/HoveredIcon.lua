local Actions = require(script.Parent.Parent.Actions)

return function(state, action)
    state = state or nil

    if action.Type == Actions.SetHoveredIcon then
        return action.Icon
    end

    return state
end
