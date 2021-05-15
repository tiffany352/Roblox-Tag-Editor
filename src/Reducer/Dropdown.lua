return function(state, action)
	state = state or false

	if action.type == "OpenDropdown" then
		return action.open
	end

	return state
end
