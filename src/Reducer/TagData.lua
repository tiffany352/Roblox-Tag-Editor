local Actions = require(script.Parent.Parent.Actions)

return function(state, action)
	state = state or {}

	if action.type == 'SetTagData' then
		return action.data
	end

	return state
end
