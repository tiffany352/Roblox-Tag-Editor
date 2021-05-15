return function(state, action)
	state = state or nil

	if action.type == "ToggleIconPicker" then
		return action.tag
	end

	return state
end
