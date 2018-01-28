local Collection = game:GetService("CollectionService")
local Selection = game:GetService("Selection")

local Actions = require(script.Parent.Actions)

local TagManager = {}
TagManager.__index = TagManager

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
    local self = setmetatable({}, TagManager)

    self.store = store
    self.tags = {}
    self.groups = {}
    self.onTagAddedFuncs = {}
    self.onTagRemovedFuncs = {}
    self.onTagChangedFuncs = {}

    self.tagsFolder = Collection:FindFirstChild("Tags")
    if self.tagsFolder then
        for _,child in pairs(self.tagsFolder:GetChildren()) do
            local tag = {
                Folder = child,
            }
            for name, prop in pairs(propTypes) do
                local obj = child:FindFirstChild(name)
                if obj then
                    tag[name] = obj.Value
                else
                    tag[name] = prop.Default
                end
            end
            if not tag.Color then
                tag.Color = genColor(child.Name)
                local colorValue = Instance.new("Color3Value")
                colorValue.Name = "Color"
                colorValue.Value = tag.Color
                colorValue.Parent = child
            end
            self.tags[child.Name] = tag
        end
    else
        local ServerStorage = game:GetService("ServerStorage")
        local legacyTagsFolder = ServerStorage:FindFirstChild("TagList")
        if legacyTagsFolder then
            print("Migrating legacy tags format...")
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

                    folder.Parent = self:_tagsFolder()
                    local tag = {
                        Folder = folder,
                        Color = color,
                        DrawType = 'Box',
                    }
                    for propName, prop in pairs(propTypes) do
                        tag[propName] = tag[propName] or prop.Default
                    end
                    self.tags[name] = tag
                end
            end
        end
    end

    self.groupsFolder = Collection:FindFirstChild("Groups")
    if self.groupsFolder then
        for _,child in pairs(self.groupsFolder:GetChildren()) do
            local group = {
                Folder = child,
            }
            self.groups[child.Name] = group
        end
    end

    self:_updateStore()
    TagManager._global = self

    self.selectionChanged = Selection.SelectionChanged:Connect(function()
        self:_updateStore()
    end)

    return self
end

function TagManager:Destroy()
end

function TagManager.Get()
    return TagManager._global
end

function TagManager:_updateStore()
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

function TagManager:_folderOf(name, tag)
    tag = tag or self.tags[name]
    if tag.Folder then
        return tag.Folder
    end
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = self:_tagsFolder()
    tag.Folder = folder

    for k,v in pairs(tag) do
        if propTypes[k] then
            local obj = Instance.new(propTypes[k])
            obj.Name = k
            obj.Value = v
            obj.Parent = folder
        end
    end
    return folder
end

function TagManager:_setProp(tagName, key, value)
    local tag = self.tags[tagName]
    if not tag then
        assert(false)
        return false
    end
    if tag[key] == value then
        return false
    end
    tag[key] = value
    local folder = self:_folderOf(tagName, tag)
    local valueObj = folder:FindFirstChild(key)
    if value then
        if not valueObj then
            valueObj = Instance.new(propTypes[key].Type)
            valueObj.Name = key
            valueObj.Parent = folder
        end
        valueObj.Value = value
    elseif valueObj then
        valueObj:Destroy()
    end
    self:_updateStore()
    for func,_ in pairs(self.onTagChangedFuncs) do
        func(tagName, key, value)
    end
    return true
end

function TagManager:AddTag(name)
    if self.tags[name] then
        return
    end
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = self:_tagsFolder()
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
    if tag.Folder then
        tag.Folder:Destroy()
    end
    self.tags[name] = nil
    for _,inst in pairs(Collection:GetTagged(name)) do
        Collection:RemoveTag(inst, name)
    end
    self:_updateStore()
    for func,_ in pairs(self.onTagRemovedFuncs) do
        func(name)
    end
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
    folder.Parent = self:_groupsFolder()

    self.groups[name] = {
        Folder = folder,
    }

    self:_updateStore()
end

function TagManager:DelGroup(name)
    local group = self.groups[name]
    if not group then
        return
    end
    group.Folder:Destroy()
    self.groups[name] = nil

    for _,tag in pairs(self.tags) do
        if tag.Group == name then
            tag.Group = nil
        end
    end

    self:_updateStore()
end

return TagManager
