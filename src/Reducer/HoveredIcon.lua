return function(state, action)
	state = state or nil

	if action.type == "SetHoveredIcon" then
		return action.icon
	end

	return state
end
