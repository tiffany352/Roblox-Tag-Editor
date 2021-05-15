return function(state, action)
	state = state or {}

	if action.type == "SetTagData" then
		return action.data
	end

	return state
end
