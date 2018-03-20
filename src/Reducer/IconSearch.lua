local Actions = require(script.Parent.Parent.Actions)

return function(state, action)
    state = state or ""

    if action.Type == Actions.ToggleIconPicker and not action.Tag then
        return ""
    end

    if action.Type == Actions.SetIconSearch then
        assert(typeof(action.Text) == 'string')
        return action.Text
    end

    return state
end
