local Theme = {}
Theme.__index = Theme

Theme.Tags = {
	Normal = 'Normal',
	Hover = 'Hover',
	Pressed = 'Pressed',
	Active = 'Active',
	Semiactive = 'Semiactive',
	Disabled = 'Disabled',
}

Theme.Nil = {}

function Theme.tagsToState(tags)
	local newTags = {}
	for key, value in pairs(tags) do
		if value then
			newTags[key] = true
		end
	end
	newTags.Normal = nil
	if newTags.Pressed then
		newTags.Hover = nil
	end
	if newTags.Active then
		newTags.Semiactive = nil
	end

	local array = {}
	for key, value in pairs(newTags) do
		array[#array+1] = key
	end
	table.sort(array)

	if #array > 0 then
		return table.concat(array, '')
	else
		return 'Normal'
	end
end

function Theme.new(data)
	local self = {
		data = data,
		haveWarned = {},
	}
	setmetatable(self, Theme)

	return self
end

function Theme:getRaw(object, property, state)
	local objectData = self.data[object]
	if objectData then
		local propertyData = objectData[property]
		if propertyData then
			local stateData = propertyData[state]
			if stateData ~= nil then
				return stateData
			end
		end
	end
	return nil
end

function Theme:getObjectOnly(object, property, state)
	local result

	result = self:getRaw(object, property, state)
	if result ~= nil then
		return result
	end

	if state ~= 'Normal' then
		result = self:getRaw(object, property, 'Normal')
		if result ~= nil then
			return result
		end
	end

	return nil
end

function Theme:get(object, property, state)
	state = state or 'Normal'

	local result1 = self:getObjectOnly(object, property, state)
	local result2 = self:getObjectOnly('MainSection', property, state)

	local result = result1
	if result1 == nil then
		result = result2
	end

	if result == Theme.Nil then
		return nil
	elseif result ~= nil then
		return result
	else
		local key = string.format("%s.%s.%s", object, property, state)
		if not self.haveWarned[key] then
			self.haveWarned[key] = true
			warn(string.format("Theme is missing key for %s", key))
		end
		return nil
	end
end

return Theme
