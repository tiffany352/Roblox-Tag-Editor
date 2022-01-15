type Category = {
	name: string,
	items: { Emoji },
}

type Emoji = {
	name: string,
	base: string,
	alts: { string },
}

local nameLookup = nil
local function getLookup()
	if nameLookup then
		return nameLookup
	end

	nameLookup = {}
	local data: { Category } = require(script.Data)

	for _, category in pairs(data) do
		for _, emoji in pairs(category.items) do
			nameLookup[emoji.name] = emoji
		end
	end

	return nameLookup
end

local function getNamedEmoji(name: string): string?
	local lookup = getLookup()
	if lookup[name] then
		return lookup[name].base
	end
	local alt = name:match("[2-6]$")
	if alt then
		alt = tonumber(alt)
		name = name:sub(1, -2)
		if lookup[name] then
			return lookup[name].alts[alt]
		end
	end
end

local function getCategories(): { Category }
	return require(script.Data)
end

return {
	getNamedEmoji = getNamedEmoji,
	getCategories = getCategories,
}
