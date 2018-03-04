local Actions = require(script.Parent.Parent.Actions)

return function(state, action)
    state = state or false

    if action.Type == Actions.OpenMigrationDialog then
        return action.Enabled
    end

    return state
end
