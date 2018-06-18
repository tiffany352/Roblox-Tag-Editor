local Actions = require(script.Parent.Parent.Actions)

return function(state, action)
    state = state or nil

    if action.type == 'ToggleColorPicker' then
        return action.tag
    end

    return state
end
