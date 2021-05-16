local function setSelectionActive(active: boolean)
	return {
		type = "SetSelectionActive",
		active = active,
	}
end

return setSelectionActive
