local Actions = require(script.Parent.Parent.Actions)

return function(state, action)
	state = state or false

	if action.type == 'ToggleWorldView' then
		return action.enabled
	end

	return state
end
