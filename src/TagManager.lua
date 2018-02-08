local Collection = game:GetService("CollectionService")
local Selection = game:GetService("Selection")

local Actions = require(script.Parent.Actions)
local Watcher = require(script.Parent.Watcher)

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
    local self = setmetatable(Watcher.new(Collection), TagManager)

    self.store = store
    self.tags = {}
    self.groups = {}
    self.onTagAddedFuncs = {}
    self.onTagRemovedFuncs = {}
    self.onTagChangedFuncs = {}
    self.updateTriggered = false

    TagManager._global = self

    self:WatcherStart()

    -- attempt legacy data import
    if not self.tagsFolder then
        local ServerStorage = game:GetService("ServerStorage")
        local legacyTagsFolder = ServerStorage:FindFirstChild("TagList")
        if legacyTagsFolder then
            local legacyTags = {}
            for _,child in pairs(legacyTagsFolder:GetChildren()) do
                if child:IsA("StringValue") then
                    legacyTags[#legacyTags+1] = child.Name
                end
            end
            table.sort(legacyTags)
            for i = 1, #legacyTags do
                local name = legacyTags[i]
                if not self.tags[name] then
                    local color = Color3.fromHSV(i / #legacyTags, 1, 1)

                    local folder = Instance.new("Folder")
                    folder.Name = legacyTags[i]

                    local colorValue = Instance.new("Color3Value")
                    colorValue.Name = "Color"
                    colorValue.Value = color
                    colorValue.Parent = folder

                    local tag = {
                        Folder = folder,
                        Color = color,
                        DrawType = 'Box',
                    }
                    for propName, prop in pairs(propTypes) do
                        tag[propName] = tag[propName] or prop.Default
                    end
                    self.tags[name] = tag
                    folder.Parent = self:_tagsFolder()
                end
            end

            local RunService = game:GetService("RunService")
            if not RunService:IsRunning() then
                self.store:dispatch(Actions.OpenMigrationDialog(true))
            end
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
    self.tagsFolder.Name = "Tags"
    self.tagsFolder.Parent = Collection
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

    -- update entry first
    tag[key] = value
    local folder = tag.Folder
    local valueObj = folder:FindFirstChild(key)
    if value then
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
    return true
end

function TagManager:AddTag(name)
    if self.tags[name] then
        return
    end
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
    for _,obj in pairs(sel) do
        if value then
            Collection:AddTag(obj, name)
        else
            Collection:RemoveTag(obj, name)
        end
    end

    self:_updateStore()
end

function TagManager:_groupsFolder()
    if self.groupsFolder then
        return self.groupsFolder
    end
    self.groupsFolder = Instance.new("Folder")
    self.groupsFolder.Name = "Groups"
    self.groupsFolder.Parent = Collection
    return self.groupsFolder
end

function TagManager:AddGroup(name)
    if self.groups[name] then
        return
    end
    local folder = Instance.new("Folder")
    folder.Name = name

    self.groups[name] = {
        Folder = folder,
    }

    folder.Parent = self:_groupsFolder()

    self:_updateStore()
end

function TagManager:DelGroup(name)
    local group = self.groups[name]
    if not group then
        return
    end

    self.groups[name] = nil
    for _,tag in pairs(self.tags) do
        if tag.Group == name then
            tag.Group = nil
        end
    end

    group.Folder:Destroy()

    self:_updateStore()
end

-- Watcher overrides

function TagManager:InstanceAdded(instance)
    if not self.tagsFolder and instance.Parent == Collection and instance.Name == 'Tags' then
        self.tagsFolder = instance
    end

    if not self.groupsFolder and instance.Parent == Collection and instance.Name == 'Groups' then
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

function TagManager:InstanceRemoved(instance)
    if instance.Parent == Collection and instance == self.tagsFolder then
        self.tagsFolder = nil
        for name,_ in pairs(self.tags) do
            for func,_ in pairs(self.onTagRemovedFuncs) do
                func(instance.Name)
            end
        end
        self.tags = {}
        self:_updateStore()
    end

    if instance.Parent == Collection and instance == self.groupsFolder then
        self.groupsFolder = nil
        self.groups = {}
        self:_updateStore()
    end

    if instance.Parent == self.tagsFolder and self.tags[instance.Name] then
        for func,_ in pairs(self.onTagRemovedFuncs) do
            func(instance.Name)
        end
        self.tags[instance.Name] = nil
        self:_updateStore()
    end

    if instance.Parent == self.groupsFolder and self.groups[instance.Name] then
        self.groups[instance.Name] = nil
        for tagName,tag in pairs(self.tags) do
            if tag.Group == instance.Name then
                tag.Group = nil
                for func,_ in pairs(self.onTagChangedFuncs) do
                    func(tagName, 'Group', nil)
                end
            end
        end
        self:_updateStore()
    end

    if instance.Parent and instance.Parent.Parent == self.tagsFolder and self.tags[instance.Parent.Name] then
        self.tags[instance.Parent.Name][instance.Name] = nil
        for func,_ in pairs(self.onTagChangedFuncs) do
            func(instance.Parent.Name, instance.Name, nil)
        end
        self:_updateStore()
    end
end

function TagManager:InstanceChanged(instance, oldValue, newValue)
    if instance.Parent and instance.Parent.Parent == self.tagsFolder and self.tags[instance.Parent.Name] and self.tags[instance.Parent.Name][instance.Name] ~= instance.Value then
        self.tags[instance.Parent.Name][instance.Name] = newValue
        for func,_ in pairs(self.onTagChangedFuncs) do
            func(instance.Parent.Name, instance.Name, newValue)
        end
        self:_updateStore()
    end
end

return TagManager
