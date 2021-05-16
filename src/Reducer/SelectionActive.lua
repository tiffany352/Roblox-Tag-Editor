return function(state, action)
	state = state or false

	if action.type == "SetSelectionActive" then
		return action.active
	end

	return state
end
