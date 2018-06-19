return function(state, action)
	state = state or false

	if action.type == 'OpenMigrationDialog' then
		return action.enabled
	end

	return state
end
