return function(state, action)
	state = state or ""

	if action.type == "SetSearch" then
		assert(typeof(action.text) == "string", "SetSearch action requires a string")
		return action.text
	end

	return state
end
