return function(state, action)
	state = state or nil

	if action.type == "OpenInstanceView" then
		return action.view
	end

	return state
end
