--!strict

local Collection = game:GetService("CollectionService")
local Selection = game:GetService("Selection")
local ChangeHistory = game:GetService("ChangeHistoryService")

local Actions = require(script.Parent.Actions)

local tagsRoot = game:GetService("ServerStorage")
local tagsFolderName = "TagList"

local TagManager = {}
TagManager.__index = TagManager

type Tag = {
	Name: string,
	Icon: string,
	Visible: boolean,
	DrawType: string,
	Color: Color3,
	AlwaysOnTop: boolean,
	Group: string,
}

local defaultValues = {
	Icon = "tag_green",
	Visible = true,
	DrawType = "Box",
	AlwaysOnTop = false,
	Group = "",
}

TagManager._global = nil

local function lerp(start: number, stop: number, t: number): number
	return (stop - start) * t + start
end

local function genColor(name: string): Color3
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

	v = lerp(0.3, 1.0, v)
	s = lerp(0.5, 1.0, s)

	return Color3.fromHSV(h, s, v)
end

function TagManager.new(store)
	local self = setmetatable({
		store = store,
		selectionChanged = nil,
		updateTriggered = false,
		tagsFolder = tagsRoot:FindFirstChild(tagsFolderName),
		childAddedConn = nil,
		childRemovedConn = nil,
		attributeChangedSignals = {},
		nameChangedSignals = {},
		tags = {},
		onUpdate = {},
	}, TagManager)

	TagManager._global = self

	-- Migration path to new attribute based format.
	if self.tagsFolder then
		ChangeHistory:SetWaypoint("Migrating tags folder")

		local migrateCount = 0
		for _, tagInstance in pairs(self.tagsFolder:GetChildren()) do
			if tagInstance:IsA("Folder") then
				local newInstance = Instance.new("Configuration")
				newInstance.Name = tagInstance.Name

				local inherited = {}
				for _, valueInst in pairs(tagInstance:GetChildren()) do
					if valueInst:IsA("ValueBase") then
						newInstance:SetAttribute(valueInst.Name, valueInst.Value)
						inherited[valueInst.Name] = true
					end
				end
				for name, value in pairs(defaultValues) do
					if inherited[name] then
						continue
					end
					newInstance:SetAttribute(name, value)
				end
				newInstance.Parent = self.tagsFolder
				tagInstance.Parent = nil
				migrateCount += 1
			end
		end
		if migrateCount > 0 then
			print(string.format("TagEditor: Converted %d tags to attribute-based format.", migrateCount))
		end

		ChangeHistory:SetWaypoint("Migrated tags folder")
	end

	self:_updateStore()

	self.selectionChanged = Selection.SelectionChanged:Connect(function()
		self:_updateStore()
		self:_updateUnknown()

		local sel = Selection:Get()
		self.store:dispatch(Actions.SetSelectionActive(#sel > 0))
	end)

	if self.tagsFolder then
		self:_watchFolder()
	end

	return self
end

function TagManager:Destroy()
	self.selectionChanged:Disconnect()
	if self.childAddedConn then
		self.childAddedConn:Disconnect()
	end
	if self.childRemovedConn then
		self.childRemovedConn:Disconnect()
	end
	for _, signal in pairs(self.attributeChangedSignals) do
		signal:Disconnect()
	end
	for _, signal in pairs(self.nameChangedSignals) do
		signal:Disconnect()
	end
end

function TagManager.Get(): TagManager
	return TagManager._global
end

function TagManager:GetTags(): { Tag }
	return self.tags
end

function TagManager:OnTagsUpdated(func)
	local connection = {
		Disconnect = function(id)
			self.onUpdate[id] = nil
		end,
	}
	self.onUpdate[connection] = func
	return connection
end

function TagManager:_watchFolder()
	for _, child in pairs(self.tagsFolder:GetChildren()) do
		if child:IsA("Configuration") then
			self:_watchChild(child)
		end
	end
	self.childAddedConn = self.tagsFolder.ChildAdded:Connect(function(instance: Instance)
		if instance:IsA("Configuration") then
			self:_watchChild(instance)
		end
	end)
	self.childRemovedConn = self.tagsFolder.ChildRemoved:Connect(function(instance)
		if instance:IsA("Configuration") then
			self:_updateStore()
			local nameChangedSignal = self.nameChangedSignals[instance]
			if nameChangedSignal then
				nameChangedSignal:Disconnect()
				self.nameChangedSignals[instance] = nil
			end
			local attributeChangedSignal = self.attributeChangedSignals[instance]
			if attributeChangedSignal then
				attributeChangedSignal:Disconnect()
				self.attributeChangedSignals[instance] = nil
			end
		end
	end)
end

function TagManager:_watchChild(instance: Configuration)
	self:_updateStore()

	self.attributeChangedSignals[instance] = instance.AttributeChanged:Connect(function(_attribute)
		self:_updateStore()
	end)

	self.nameChangedSignals[instance] = instance:GetPropertyChangedSignal("Name"):Connect(function(_attribute)
		self:_updateStore()
	end)
end

function TagManager:_getFolder()
	if not self.tagsFolder then
		self.tagsFolder = Instance.new("Folder")
		self.tagsFolder.Name = tagsFolderName
		self.tagsFolder.Parent = tagsRoot
		self:_watchFolder()
	end
	return self.tagsFolder
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
	local tags: { [number]: Tag } = {}
	local groups: { [string]: boolean } = {}
	local sel = Selection:Get()

	if self.tagsFolder then
		for _, inst in pairs(self.tagsFolder:GetChildren()) do
			if not inst:IsA("Configuration") then
				continue
			end
			local hasAny = false
			local missingAny = false
			local entry: Tag = {
				Name = inst.Name,
				Icon = inst:GetAttribute("Icon") or defaultValues.Icon,
				Visible = inst:GetAttribute("Visible") or false,
				DrawType = inst:GetAttribute("DrawType") or defaultValues.DrawType,
				AlwaysOnTop = inst:GetAttribute("AlwaysOnTop") or defaultValues.AlwaysOnTop,
				Group = inst:GetAttribute("Group") or defaultValues.Group,
				Color = inst:GetAttribute("Color") or genColor(inst.Name),
				HasAll = false,
				HasSome = false,
			}
			if entry.Group == "" then
				entry.Group = nil
			end
			if entry.Icon == "" then
				entry.Icon = defaultValues.Icon
			end
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
			tags[#tags + 1] = entry
			if entry.Group then
				groups[entry.Group] = true
			end
		end
	end

	table.sort(tags, function(a, b)
		return a.Name < b.Name
	end)

	local oldTags = self.tags
	self.tags = tags
	self.store:dispatch(Actions.SetTagData(tags))

	local groupList = {}
	for name, _true in pairs(groups) do
		table.insert(groupList, name)
	end
	table.sort(groupList)

	self.store:dispatch(Actions.SetGroupData(groupList))

	for _, func in pairs(self.onUpdate) do
		func(tags, oldTags)
	end
end

function TagManager:_updateUnknown()
	local sel = Selection:Get()

	local knownTags = {}
	for _, tag in pairs(self.tags) do
		knownTags[tag.Name] = true
	end

	local unknownTagsMap = {}
	for _, inst in pairs(sel) do
		local tags = Collection:GetTags(inst)
		for _, name in pairs(tags) do
			-- Ignore unknown tags that start with a dot.
			if not knownTags[name] and name:sub(1, 1) ~= "." then
				unknownTagsMap[name] = true
			end
		end
	end
	local unknownTagsList: { string } = {}
	for tag, _ in pairs(unknownTagsMap) do
		table.insert(unknownTagsList, tag)
	end
	table.sort(unknownTagsList)

	self.store:dispatch(Actions.SetUnknownTags(unknownTagsList))
end

function TagManager:_setProp(tagName: string, key: string, value: any)
	local tagsFolder = self:_getFolder()
	local tag = tagsFolder:FindFirstChild(tagName)
	if not tag then
		error("Setting property of non-existent tag `" .. tostring(tagName) .. "`")
	end

	-- don't do unnecessary updates
	if tag:GetAttribute(key) == value then
		return false
	end

	ChangeHistory:SetWaypoint(string.format("Setting property %q of tag %q", key, tagName))
	tag:SetAttribute(key, value)
	ChangeHistory:SetWaypoint(string.format("Set property %q of tag %q", key, tagName))

	return true
end

function TagManager:_getProp(tagName: string, key: string)
	if not self.tagsFolder then
		return nil
	end

	local instance = self.tagsFolder:FindFirstChild(tagName)
	if not instance then
		return nil
	end

	return instance:GetAttribute(key)
end

function TagManager:AddTag(name)
	-- Early out if tag already exists.
	if self.tagsFolder and self.tagsFolder:FindFirstChild(name) then
		return
	end

	ChangeHistory:SetWaypoint(string.format("Creating tag %q", name))

	local tagsFolder = self:_getFolder()
	local instance = Instance.new("Configuration")
	instance.Name = name
	instance:SetAttribute("Icon", defaultValues.Icon)
	instance:SetAttribute("Visible", defaultValues.Visible)
	instance:SetAttribute("DrawType", defaultValues.DrawType)
	instance:SetAttribute("AlwaysOnTop", defaultValues.AlwaysOnTop)
	instance:SetAttribute("Group", defaultValues.Group)
	instance:SetAttribute("Color", genColor(name))
	instance.Parent = tagsFolder

	ChangeHistory:SetWaypoint(string.format("Created tag %q", name))
end

function TagManager:Rename(oldName, newName)
	local instance = self.tagsFolder and self.tagsFolder:FindFirstChild(oldName)
	if not instance then
		return
	end

	ChangeHistory:SetWaypoint(string.format("Renaming tag %q to %q", oldName, newName))

	instance.Name = newName
	for _, taggedInstance in pairs(Collection:GetTagged(oldName)) do
		Collection:RemoveTag(taggedInstance, oldName)
		Collection:AddTag(taggedInstance, newName)
	end

	ChangeHistory:SetWaypoint(string.format("Renamed tag %q to %q", oldName, newName))
end

function TagManager:SelectAll(tag: string)
	Selection:Set(Collection:GetTagged(tag))
end

function TagManager:GetIcon(name: string): string
	return self:_getProp(name, "Icon") or defaultValues.Icon
end

function TagManager:GetVisible(name: string): boolean
	return self:_getProp(name, "Visible") or defaultValues.Visible
end

function TagManager:GetDrawType(name: string): string
	return self:_getProp(name, "DrawType") or defaultValues.DrawType
end

function TagManager:GetColor(name: string): Color3
	return self:_getProp(name, "Color") or defaultValues.Color
end

function TagManager:GetAlwaysOnTop(name: string): boolean
	return self:_getProp(name, "AlwaysOnTop") or defaultValues.AlwaysOnTop
end

function TagManager:GetGroup(name: string): string
	return self:_getProp(name, "Group") or defaultValues.Group
end

function TagManager:SetIcon(name: string, icon: string?)
	self:_setProp(name, "Icon", icon or "")
end

function TagManager:SetVisible(name: string, visible: boolean)
	self:_setProp(name, "Visible", visible)
end

function TagManager:SetDrawType(name: string, type: string)
	self:_setProp(name, "DrawType", type)
end

function TagManager:SetColor(name: string, color: Color3)
	self:_setProp(name, "Color", color)
end

function TagManager:SetAlwaysOnTop(name: string, value: boolean)
	self:_setProp(name, "AlwaysOnTop", value)
end

function TagManager:SetGroup(name: string, value: string?)
	self:_setProp(name, "Group", value or "")
end

function TagManager:DelTag(name: string)
	local tagsFolder = self.tagsFolder
	if not tagsFolder then
		return
	end
	local instance = tagsFolder:FindFirstChild(name)
	if not instance then
		return
	end

	ChangeHistory:SetWaypoint(string.format("Deleting tag %q", name))

	-- Don't use Destroy as it prevents undo.
	instance.Parent = nil
	for _, inst in pairs(Collection:GetTagged(name)) do
		Collection:RemoveTag(inst, name)
	end

	ChangeHistory:SetWaypoint(string.format("Deleted tag %q", name))
end

function TagManager:SetTag(name: string, value: boolean)
	if value then
		ChangeHistory:SetWaypoint(string.format("Applying tag %q to selection", name))
	else
		ChangeHistory:SetWaypoint(string.format("Removing tag %q from selection", name))
	end

	local sel = Selection:Get()
	for _, obj in pairs(sel) do
		if value then
			Collection:AddTag(obj, name)
		else
			Collection:RemoveTag(obj, name)
		end
	end
	-- No changed events are bound on selected objects, so the store needs
	-- to be manually marked for update.
	self:_updateStore()

	if value then
		ChangeHistory:SetWaypoint(string.format("Applied tag %q to selection", name))
	else
		ChangeHistory:SetWaypoint(string.format("Removed tag %q from selection", name))
	end
end

type TagManager = typeof(TagManager.new())

return TagManager
