return function(state, action)
	state = state or ""

	if action.type == "ToggleIconPicker" and not action.tag then
		return ""
	end

	if action.type == "SetIconSearch" then
		assert(typeof(action.text) == "string")
		return action.text
	end

	return state
end
