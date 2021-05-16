local function setRenaming(tag: string, renaming: boolean)
	return {
		type = "SetRenaming",
		tag = tag,
		renaming = renaming,
	}
end

return setRenaming
