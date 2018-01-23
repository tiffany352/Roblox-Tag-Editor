local Collection = game:GetService("CollectionService")
local Selection = game:GetService("Selection")

local Actions = require(script.Parent.Actions)

local TagManager = {}
TagManager.__index = TagManager

function TagManager.new(store)
    local self = setmetatable({}, TagManager)

    self.store = store
    self.tags = {}
    self.tagsFolder = Collection:FindFirstChild("Tags")
    if self.tagsFolder then
        for _,child in pairs(self.tagsFolder:GetChildren()) do
            local iconValue = child:FindFirstChild("Icon")
            self.tags[child.Name] = {
                Folder = child,
                Icon = iconValue and iconValue.Value,
            }
        end
    end

    return self
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

    self.store:Dispatch(Actions.SetTagData(data))
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

function TagManager:AddTag(name)
    if self.tags[name] then
        return
    end
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = self._tagsFolder()
    self.tags[name] = {
        Folder = folder,
    }
    self:_updateStore()
end

function TagManager:SetIcon(name, icon)
    local tag = self.tags[name]
    if not tag then
        return
    end
    tag.Icon = icon
    local folder = tag.Folder
    local iconValue = folder:FindFirstChild("Icon")
    if not iconValue then
        iconValue = Instance.new("StringValue")
        iconValue.Name = "Icon"
        iconValue.Parent = folder
    end
    iconValue.Value = icon
    self:_updateStore()
end

function TagManager:DelTag(name)
    if not self.tags[name] then
        return
    end
    self.tags[name].Folder:Destroy()
    self.tags[name] = nil
    self:_updateStore()
end

function TagManager:Destroy()
end

return TagManager
