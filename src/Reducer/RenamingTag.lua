return function(state, action)
	if action.type == "SetRenaming" then
		if action.renaming then
			return action.tag
		else
			return nil
		end
	end

	return state
end
