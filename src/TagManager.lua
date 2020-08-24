local Collection = game:GetService("CollectionService")
local Selection = game:GetService("Selection")
local ChangeHistory = game:GetService("ChangeHistoryService")

local Actions = require(script.Parent.Actions)
local Watcher = require(script.Parent.Watcher)

local TagsRoot = game:GetService("ServerStorage")
local TagsFolderName = "TagList"
local GroupsFolderName = "TagGroupList"

local TagManager = {}
TagManager.__index = TagManager
setmetatable(TagManager, Watcher)

TagManager._global = nil

local propTypes = {
	Icon = {
		Type = "StringValue",
		Default = "tag_green",
	},
	Visible = {
		Type = "BoolValue",
		Default = true,
	},
	Color = {
		Type = "Color3Value",
	},
	DrawType = {
		Type = "StringValue",
		Default = "Box",
	},
	AlwaysOnTop = {
		Type = "BoolValue",
		Default = false,
	},
	Group = {
		Type = "StringValue",
		Default = nil,
	},
}

local function genColor(name)
	local hash = 2166136261
	local prime = 16777619
	local base = math.pow(2, 32)
	for i = 1, #name do
		hash = (hash * prime) % base
		hash = (hash + name:byte(i)) % base
	end
	local h = (hash / math.pow(2, 16)) % 256 / 255
	local s = (hash / math.pow(2, 8)) % 256 / 255
	local v = (hash / math.pow(2, 0)) % 256 / 255

	local function lerp(start, stop, t)
		return (stop - start) * t + start
	end

	v = lerp(0.3, 1.0, v)
	s = lerp(0.5, 1.0, s)

	return Color3.fromHSV(h, s, v)
end

function TagManager.new(store)
	local self = setmetatable(Watcher.new(TagsRoot), TagManager)

	self.store = store
	self.tags = {}
	self.groups = {}
	self.onTagAddedFuncs = {}
	self.onTagRemovedFuncs = {}
	self.onTagChangedFuncs = {}
	self.updateTriggered = false

	TagManager._global = self

	self:WatcherStart()

	-- move tags folder back from CollectionService from editor beta version
	if not self.tagsFolder and Collection:FindFirstChild("Tags") then
		local tagsList = Collection:FindFirstChild("Tags")
		tagsList.Name = TagsFolderName
		tagsList.Parent = TagsRoot
		self.tagsFolder = tagsList
	end
	if not self.groupsFolder and Collection:FindFirstChild("Groups") then
		local groupsList = Collection:FindFirstChild("Groups")
		groupsList.Name = GroupsFolderName
		groupsList.Parent = TagsRoot
		self.groupsFolder = groupsList
	end

	-- migrate legacy format in backwards compatible fashion
	if self.tagsFolder then
		local oldTags = {}

		for _,child in pairs(self.tagsFolder:GetChildren()) do
			if child:IsA("StringValue") then
				oldTags[#oldTags+1] = child
			end
		end

		table.sort(oldTags, function(a,b) return a.Name < b.Name end)

		for i = 1, #oldTags do
			local oldTag = oldTags[i]
			local folder = Instance.new("Folder")
			folder.Name = oldTag.Name
			local color = Color3.fromHSV(i / #oldTags, 1, 1)
			local newTag = {
				Folder = folder,
			}
			for propName, prop in pairs(propTypes) do
				newTag[propName] = prop.Default
			end
			newTag.Color = color
			local colorValue = Instance.new("Color3Value")
			colorValue.Name = "Color"
			colorValue.Value = color
			colorValue.Parent = folder

			oldTag:Destroy()
			self.tags[folder.Name] = newTag
			folder.Parent = self.tagsFolder
		end
	end

	self:_updateStore()

	self.selectionChanged = Selection.SelectionChanged:Connect(function()
		self:_updateStore()
	end)

	return self
end

function TagManager:Destroy()
	self.selectionChanged:Disconnect()
	Watcher.Destroy(self)
end

function TagManager.Get()
	return TagManager._global
end

function TagManager:_updateStore()
	if not self.updateTriggered then
		self.updateTriggered = true
		spawn(function()
			self:_doUpdateStore()
		end)
	end
end

function TagManager:_doUpdateStore()
	self.updateTriggered = false
	local data = {}
	local sel = Selection:Get()

	for name,tag in pairs(self.tags) do
		local hasAny = false
		local missingAny = false
		local entry = {
			Name = name,
			Icon = tag.Icon,
			Visible = tag.Visible,
			DrawType = tag.DrawType,
			Color = tag.Color,
			AlwaysOnTop = tag.AlwaysOnTop,
			Group = tag.Group,
		}
		for i = 1, #sel do
			local obj = sel[i]
			if Collection:HasTag(obj, entry.Name) then
				hasAny = true
			else
				missingAny = true
			end
		end
		entry.HasAll = hasAny and not missingAny
		entry.HasSome = hasAny and missingAny
		data[#data+1] = entry
	end

	table.sort(data, function(a, b)
		return a.Name < b.Name
	end)

	self.store:dispatch(Actions.SetTagData(data))

	local unknownTagsMap = {}
	for _,obj in pairs(sel) do
		local tags = Collection:GetTags(obj)
		for _,tag in pairs(tags) do
			-- Ignore unknown tags that start with a dot.
			if not self.tags[tag] and tag:sub(1,1) ~= '.' then
				unknownTagsMap[tag] = true
			end
		end
	end
	local unknownTags = {}
	for tag,_ in pairs(unknownTagsMap) do
		unknownTags[#unknownTags+1] = tag
	end
	table.sort(unknownTags)

	self.store:dispatch(Actions.SetUnknownTags(unknownTags))

	local data = {}

	for name,group in pairs(self.groups) do
		data[#data+1] = {
			Name = name,
		}
	end

	self.store:dispatch(Actions.SetGroupData(data))
end

function TagManager:GetTags()
	return self.tags
end

function TagManager:_tagsFolder()
	if self.tagsFolder then
		return self.tagsFolder
	end
	self.tagsFolder = Instance.new("Folder")
	self.tagsFolder.Name = TagsFolderName
	self.tagsFolder.Parent = TagsRoot
	return self.tagsFolder
end

function TagManager:_setProp(tagName, key, value)
	local tag = self.tags[tagName]
	if not tag then
		error("Setting property of non-existent tag `"..tostring(tagName).."`")
	end
	assert(tag.Folder)

	-- don't do unnecessary updates
	if tag[key] == value then
		return false
	end

	ChangeHistory:SetWaypoint(string.format("Setting property %q of tag %q", key, tagName))
	-- update entry first
	tag[key] = value
	local folder = tag.Folder
	local valueObj = folder:FindFirstChild(key)
	if value ~= nil then
		if not valueObj then
			valueObj = Instance.new(propTypes[key].Type)
			valueObj.Name = key
		end
		valueObj.Value = value

		valueObj.Parent = folder
	elseif valueObj then
		valueObj:Destroy()
	end
	for func,_ in pairs(self.onTagChangedFuncs) do
		func(tagName, key, value)
	end

	self:_updateStore()
	ChangeHistory:SetWaypoint(string.format("Set property %q of tag %q", key, tagName))
	return true
end

function TagManager:AddTag(name)
	if string.byte(string.sub(name, #name, #name)) == 13 then
		name = string.sub(name, 1, #name-1)
	end
	if self.tags[name] then
		return
	end
	ChangeHistory:SetWaypoint(string.format("Creating tag %q", name))
	local folder = Instance.new("Folder")
	folder.Name = name

	local tag = {
		Folder = folder,
	}
	for propName, prop in pairs(propTypes) do
		tag[propName] = prop.Default
	end
	tag.Color = genColor(name)
	local colorValue = Instance.new("Color3Value")
	colorValue.Value = tag.Color
	colorValue.Name = "Color"
	colorValue.Parent = folder
	self.tags[name] = tag

	folder.Parent = self:_tagsFolder()

	self:_updateStore()
	for func,_ in pairs(self.onTagAddedFuncs) do
		func(name)
	end
	ChangeHistory:SetWaypoint(string.format("Created tag %q", name))
end

function TagManager:SetIcon(name, icon)
	self:_setProp(name, "Icon", icon)
end

function TagManager:SetVisible(name, visible)
	self:_setProp(name, "Visible", visible)
end

function TagManager:SetDrawType(name, type)
	self:_setProp(name, "DrawType", type)
end

function TagManager:SetColor(name, color)
	self:_setProp(name, "Color", color)
end

function TagManager:SetAlwaysOnTop(name, value)
	self:_setProp(name, "AlwaysOnTop", value)
end

function TagManager:SetGroup(name, value)
	self:_setProp(name, "Group", value)
end

function TagManager:DelTag(name)
	local tag = self.tags[name]
	if not tag then
		return
	end

	ChangeHistory:SetWaypoint(string.format("Deleting tag %q", name))
	for func,_ in pairs(self.onTagRemovedFuncs) do
		func(name)
	end

	self.tags[name] = nil

	if tag.Folder then
		tag.Folder:Destroy()
	end

	for _,inst in pairs(Collection:GetTagged(name)) do
		Collection:RemoveTag(inst, name)
	end

	self:_updateStore()
	ChangeHistory:SetWaypoint(string.format("Deleted tag %q", name))
end

function TagManager:OnTagAdded(func)
	self.onTagAddedFuncs[func] = true

	return {
		Disconnect = function(_self)
			self.onTagAddedFuncs[func] = nil
		end,
	}
end

function TagManager:OnTagRemoved(func)
	self.onTagRemovedFuncs[func] = true

	return {
		Disconnect = function(_self)
			self.onTagRemovedFuncs[func] = nil
		end
	}
end

function TagManager:OnTagChanged(func)
	self.onTagChangedFuncs[func] = true

	return {
		Disconnect = function(_self)
			self.onTagChangedFuncs[func] = nil
		end
	}
end

function TagManager:SetTag(name, value)
	local sel = Selection:Get()
	if value then
		ChangeHistory:SetWaypoint(string.format("Applying tag %q to selection", name))
	else
		ChangeHistory:SetWaypoint(string.format("Removing tag %q from selection", name))
	end
	for _,obj in pairs(sel) do
		if value then
			Collection:AddTag(obj, name)
		else
			Collection:RemoveTag(obj, name)
		end
	end

	self:_updateStore()
	if value then
		ChangeHistory:SetWaypoint(string.format("Applied tag %q to selection", name))
	else
		ChangeHistory:SetWaypoint(string.format("Removed tag %q from selection", name))
	end
end

function TagManager:_groupsFolder()
	if self.groupsFolder then
		return self.groupsFolder
	end
	self.groupsFolder = Instance.new("Folder")
	self.groupsFolder.Name = GroupsFolderName
	self.groupsFolder.Parent = TagsRoot
	return self.groupsFolder
end

function TagManager:AddGroup(name)
	if self.groups[name] then
		return
	end
	ChangeHistory:SetWaypoint(string.format("Creating tag group %q", name))
	local folder = Instance.new("Folder")
	folder.Name = name

	self.groups[name] = {
		Folder = folder,
	}

	folder.Parent = self:_groupsFolder()

	self:_updateStore()
	ChangeHistory:SetWaypoint(string.format("Created tag group %q", name))
end

function TagManager:DelGroup(name)
	local group = self.groups[name]
	if not group then
		return
	end
	ChangeHistory:SetWaypoint(string.format("Deleting tag group %q", name))

	self.groups[name] = nil
	for _,tag in pairs(self.tags) do
		if tag.Group == name then
			tag.Group = nil
		end
	end

	group.Folder:Destroy()

	self:_updateStore()
	ChangeHistory:SetWaypoint(string.format("Deleted tag group %q", name))
end

-- Watcher overrides

local doLog = false

function TagManager:InstanceAdded(instance)
	if doLog then print("TagManager:InstanceAdded(",instance,")") end
	if not self.tagsFolder and instance.Parent == TagsRoot and instance.Name == TagsFolderName then
		self.tagsFolder = instance
	end

	if not self.groupsFolder and instance.Parent == TagsRoot and instance.Name == GroupsFolderName then
		self.groupsFolder = instance
	end

	if instance.Parent == self.tagsFolder and not self.tags[instance.Name] then
		-- deserialize tag
		local tag = {
			Folder = instance,
		}
		for name, prop in pairs(propTypes) do
			local obj = instance:FindFirstChild(name)
			if obj then
				tag[name] = obj.Value
			else
				tag[name] = prop.Default
			end
		end
		if not tag.Color then
			tag.Color = genColor(instance.Name)
			local colorValue = Instance.new("Color3Value")
			colorValue.Name = "Color"
			colorValue.Value = tag.Color
			colorValue.Parent = instance
		end
		self.tags[instance.Name] = tag

		for func,_ in pairs(self.onTagAddedFuncs) do
			func(instance.Name)
		end

		self:_updateStore()
	end

	if instance.Parent == self.groupsFolder and not self.groups[instance.Name] then
		-- deserialize group
		local group = {
			Folder = instance,
		}
		self.groups[instance.Name] = group
		self:_updateStore()
	end

	if instance.Parent and instance.Parent.Parent == self.tagsFolder and self.tags[instance.Parent.Name] and self.tags[instance.Parent.Name][instance.Name] ~= instance.Value then
		-- set property
		self.tags[instance.Parent.Name][instance.Name] = instance.Value

		for func,_ in pairs(self.onTagChangedFuncs) do
			func(instance.Parent.Name, instance.Name, instance.Value)
		end

		self:_updateStore()
	end
end

function TagManager:InstanceRemoving(instance, instanceName)
	if doLog then print("TagManager:InstanceRemoved(",instance,", ",instanceName,")") end
	if instance.Parent == TagsRoot and instance == self.tagsFolder then
		self.tagsFolder = nil
		for name,_ in pairs(self.tags) do
			for func,_ in pairs(self.onTagRemovedFuncs) do
				func(instanceName)
			end
		end
		self.tags = {}
		self:_updateStore()
	end

	if instance.Parent == TagsRoot and instance == self.groupsFolder then
		self.groupsFolder = nil
		self.groups = {}
		self:_updateStore()
	end

	if instance.Parent == self.tagsFolder and self.tags[instanceName] then
		for func,_ in pairs(self.onTagRemovedFuncs) do
			func(instanceName)
		end
		self.tags[instanceName] = nil
		self:_updateStore()
	end

	if instance.Parent == self.groupsFolder and self.groups[instanceName] then
		self.groups[instanceName] = nil
		for tagName,tag in pairs(self.tags) do
			if tag.Group == instanceName then
				tag.Group = nil
				for func,_ in pairs(self.onTagChangedFuncs) do
					func(tagName, 'Group', nil)
				end
			end
		end
		self:_updateStore()
	end

	if instance.Parent and instance.Parent.Parent == self.tagsFolder and self.tags[instance.Parent.Name] then
		self.tags[instance.Parent.Name][instanceName] = nil
		for func,_ in pairs(self.onTagChangedFuncs) do
			func(instance.Parent.Name, instanceName, nil)
		end
		self:_updateStore()
	end
end

function TagManager:InstanceChanged(instance, oldValue, newValue)
	if doLog then print("TagManager:InstanceChanged(",instance,", ",oldValue,", ",newValue,")") end
	if instance.Parent and instance.Parent.Parent == self.tagsFolder and self.tags[instance.Parent.Name] and self.tags[instance.Parent.Name][instance.Name] ~= instance.Value then
		self.tags[instance.Parent.Name][instance.Name] = newValue
		for func,_ in pairs(self.onTagChangedFuncs) do
			func(instance.Parent.Name, instance.Name, newValue)
		end
		self:_updateStore()
	end
end

return TagManager
