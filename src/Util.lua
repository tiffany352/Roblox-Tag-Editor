local function findIf(array, func: (any) -> boolean)
	for _, item in pairs(array) do
		if func(item) then
			return item
		end
	end
	return nil
end

return {
	findIf = findIf,
}
