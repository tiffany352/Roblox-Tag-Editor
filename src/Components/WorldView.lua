local Collection = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")

local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Constants = require(script.Parent.Parent.Constants)
local TagManager = require(script.Parent.Parent.TagManager)
local Icon = require(script.Parent.Icon)
local Maid = require(script.Parent.Parent.Maid)

local function BoxAdorn(props)
    if props.Adornee.ClassName == 'Attachment' then
        return Roact.createElement("BoxHandleAdornment", {
            Adornee = props.Adornee.Parent,
            CFrame = props.Adornee.CFrame,
            Size = Vector3.new(1.2, 1.2, 1.2),
            Transparency = 0.3,
            Color3 = props.Color,
        })
    end
    return Roact.createElement("SelectionBox", {
        LineThickness = 0.03,
        SurfaceTransparency = 0.7,
        SurfaceColor3 = props.Color,
        Adornee = props.Adornee,
        Color3 = props.Color,
    })
end

local function OutlineAdorn(props)
    if props.Adornee.ClassName == 'Attachment' then
        return Roact.createElement("BoxHandleAdornment", {
            Adornee = props.Adornee.Parent,
            CFrame = props.Adornee.CFrame,
            Size = Vector3.new(1.5, 1.5, 1.5),
            Transparency = 0.3,
            Color3 = props.Color,
        })
    end
    return Roact.createElement("SelectionBox", {
        LineThickness = 0.05,
        Adornee = props.Adornee,
        Color3 = props.Color,
    })
end

local function SphereAdorn(props)
    local adorn, cframe
    if props.Adornee.ClassName == 'Attachment' then
        adorn = props.Adornee.Parent
        cframe = props.Adornee.CFrame
    else
        adorn = props.Adornee
    end
    return Roact.createElement("SphereHandleAdornment", {
        Adornee = adorn,
        CFrame = cframe,
        Color3 = props.Color,
        AlwaysOnTop = props.AlwaysOnTop,
        Transparency = 0.3,
        ZIndex = props.AlwaysOnTop and 1 or nil,
    })
end

local function IconAdorn(props)
    local children = {}
    if #props.Icon > 1 then
        children.UIListLayout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(2/16, 0),
        })
    end
    for i = 1, #props.Icon do
        local icon = props.Icon[i]
        children[i] = Roact.createElement(Icon, {
            Name = icon,
            Size = UDim2.new(1/#props.Icon, 0, 1, 0),
        })
    end
    return Roact.createElement("BillboardGui", {
        Adornee = props.Adornee,
        Size = UDim2.new(#props.Icon, 0, 1, 0),
        SizeOffset = Vector2.new(.5, .5),
        ExtentsOffsetWorldSpace = Vector3.new(1, 1, 1),
        AlwaysOnTop = props.AlwaysOnTop,
    }, children)
end

local function TextAdorn(props)
    local children = {}
    if #props.TagName > 1 then
        children.UIListLayout = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    end
    for i = 1, #props.TagName do
        local name = props.TagName[i]
        children[name] = Roact.createElement("TextLabel", {
            LayoutOrder = i,
            Size = UDim2.new(1, 0, 1/#props.TagName, 0),
            Text = name,
            TextScaled = true,
            TextSize = 20,
            Font = Enum.Font.SourceSansBold,
            TextColor3 = Constants.White,
            BackgroundTransparency = 1.0,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Bottom,
            TextStrokeTransparency = 0.0,
        })
    end
    return Roact.createElement("BillboardGui", {
        Adornee = props.Adornee,
        Size = UDim2.new(10, 0, #props.TagName, 0),
        SizeOffset = Vector2.new(.5, .5),
        ExtentsOffsetWorldSpace = Vector3.new(1, 1, 1),
        AlwaysOnTop = props.AlwaysOnTop,
    }, children)
end

local WorldView = Roact.Component:extend("WorldView")

function WorldView:init()
    self.state = {
        partsList = {},
    }

    self.nextId = 0
    self.partIds = {}
    self.trackedParts = {}
    self.trackedTags = {}
    self.instanceAddedConns = Maid.new()
    self.instanceRemovedConns = Maid.new()
    self.instanceAncestryChangedConns = Maid.new()
    self.maid = Maid.new()

    local function cameraAdded(camera)
        self.maid.cameraMovedConn = nil
        if camera then
            local origPos = camera.CFrame.p
            self.maid.cameraMovedConn = camera:GetPropertyChangedSignal("CFrame"):Connect(function()
                local newPos = camera.CFrame.p
                if (origPos - newPos).Magnitude > 50 then
                    origPos = newPos
                    self:updateParts()
                end
            end)
        end
    end
    self.maid.cameraChangedConn = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(cameraAdded)
    cameraAdded(workspace.CurrentCamera)
end

function WorldView:didMount()
    local manager = TagManager.Get()

    for name,_ in pairs(manager:GetTags()) do
        self:tagAdded(name)
    end
    self.onTagAddedConn = manager:OnTagAdded(function(name)
        if manager.tags[name].Visible ~= false and manager.tags[name].DrawType ~= 'None' then
            self:tagAdded(name)
            self:updateParts()
        end
    end)
    self.onTagRemovedConn = manager:OnTagRemoved(function(name)
        if manager.tags[name].Visible ~= false and manager.tags[name].DrawType ~= 'None' then
            self:tagRemoved(name)
            self:updateParts()
        end
    end)
    self.onTagChangedConn = manager:OnTagChanged(function(name, prop, value)
        local tag = manager.tags[name]
        local wasVisible = (self.trackedTags[name] ~= nil)
        local nowVisible = tag.DrawType ~= 'None' and tag.Visible ~= false
        if nowVisible and not wasVisible then
            self:tagAdded(name)
        elseif wasVisible and not nowVisible then
            self:tagRemoved(name)
        end
        self:updateParts()
    end)

    self:updateParts()
end

local function sortedInsert(array, value, lessThan)
    local start = 1
    local stop = #array

    while stop - start > 1 do
        local pivot = math.floor(start + (stop - start) / 2)
        if lessThan(value, array[pivot]) then
            stop = pivot
        else
            start = pivot + 1
        end
    end

    table.insert(array, start, value)
end

function WorldView:updateParts()
    debug.profilebegin("[Tag Editor] Update WorldView")

    local newList = {}

    local cam = workspace.CurrentCamera
    if not cam then return end
    local camPos = cam.CFrame.p

    local function sortFunc(a, b)
        return a.AngularSize > b.AngularSize
    end
    local function partAngularSize(pos, size)
        local dist = (pos - camPos).Magnitude
        local sizeM = size.Magnitude
        return sizeM / dist
    end
    for obj,_ in pairs(self.trackedParts) do
        local class = obj.ClassName
        if class == 'Model' then
            local primary = obj.PrimaryPart
            if not primary then
                local children = obj:GetChildren()
                for i = 1, #children do
                    if children[i]:IsA("BasePart") then
                        primary = children[i]
                        break
                    end
                end
            end
            if primary then
                local entry = {
                    AngularSize = partAngularSize(primary.Position, obj:GetExtentsSize()),
                    Instance = obj,
                }
                sortedInsert(newList, entry, sortFunc)
            end
        elseif class == 'Attachment' then
            local entry = {
                AngularSize = partAngularSize(obj.WorldPosition, Vector3.new()),
                Instance = obj,
            }
            sortedInsert(newList, entry, sortFunc)
        else -- assume part
            local entry = {
                AngularSize = partAngularSize(obj.Position, obj.Size),
                Instance = obj,
            }
            sortedInsert(newList, entry, sortFunc)
        end
        local size = #newList
        while size > 500 do
            newList[size] = nil
            size = size - 1
        end
    end

    local adornMap = {}
    for i = 1, #newList do
        local tags = Collection:GetTags(newList[i].Instance)
        local outlines = {}
        local boxes = {}
        local icons = {}
        local labels = {}
        local spheres = {}
        local anyAlwaysOnTop = false
        for j = 1, #tags do
            local tagName = tags[j]
            local tag = TagManager.Get().tags[tagName]
            if self.trackedTags[tagName] and tag then
                if tag.DrawType == 'Outline' then
                    outlines[#outlines+1] = tag.Color
                elseif tag.DrawType == 'Box' then
                    boxes[#boxes+1] = tag.Color
                elseif tag.DrawType == 'Icon' then
                    icons[#icons+1] = tag.Icon
                elseif tag.DrawType == 'Text' then
                    labels[#labels+1] = tagName
                elseif tag.DrawType == 'Sphere' then
                    spheres[#spheres+1] = tag.Color
                end
                if tag.AlwaysOnTop then
                    anyAlwaysOnTop = true
                end
            end
        end

        local partId = self.partIds[newList[i].Instance]

        if #outlines > 0 then
            local r, g, b = 0, 0, 0
            for i = 1, #outlines do
                r = r + outlines[i].r
                g = g + outlines[i].g
                b = b + outlines[i].b
            end
            r = r / #outlines
            g = g / #outlines
            b = b / #outlines
            local avg = Color3.new(r, g, b)
            adornMap['Outline:'..partId] = {
                Id = partId,
                Part = newList[i].Instance,
                DrawType = 'Outline',
                Color = avg,
                AlwaysOnTop = anyAlwaysOnTop,
            }
        end

        if #boxes > 0 then
            local r, g, b = 0, 0, 0
            for i = 1, #boxes do
                r = r + boxes[i].r
                g = g + boxes[i].g
                b = b + boxes[i].b
            end
            r = r / #boxes
            g = g / #boxes
            b = b / #boxes
            local avg = Color3.new(r, g, b)
            adornMap['Box:'..partId] = {
                Id = partId,
                Part = newList[i].Instance,
                DrawType = 'Box',
                Color = avg,
                AlwaysOnTop = anyAlwaysOnTop,
            }
        end

        if #icons > 0 then
            adornMap['Icon:'..partId] = {
                Id = partId,
                Part = newList[i].Instance,
                DrawType = 'Icon',
                Icon = icons,
                AlwaysOnTop = anyAlwaysOnTop,
            }
        end

        if #labels > 0 then
            table.sort(labels)
            if #icons > 0 then
                labels[#labels+1] = ''
            end
            adornMap['Text:'..partId] = {
                Id = partId,
                Part = newList[i].Instance,
                DrawType = 'Text',
                TagName = labels,
                AlwaysOnTop = anyAlwaysOnTop,
            }
        end

        if #spheres > 0 then
            local r, g, b = 0, 0, 0
            for i = 1, #spheres do
                r = r + spheres[i].r
                g = g + spheres[i].g
                b = b + spheres[i].b
            end
            r = r / #spheres
            g = g / #spheres
            b = b / #spheres
            local avg = Color3.new(r, g, b)
            adornMap['Sphere:'..partId] = {
                Id = partId,
                Part = newList[i].Instance,
                DrawType = 'Sphere',
                Color = avg,
                AlwaysOnTop = anyAlwaysOnTop,
            }
        end
    end

    -- make sure it's not the same as the current list
    local isNew = false
    local props = {
        'Part',
        'Icon',
        'Id',
        'DrawType',
        'Color',
        'TagName',
        'AlwaysOnTop',
    }
    local oldMap = self.state.partsList
    for key, newValue in pairs(adornMap) do
        local oldValue = oldMap[key]
        if not oldValue then
            isNew = true
            break
        else
            for i = 1, #props do
                local prop = props[i]
                if newValue[prop] ~= oldValue[prop] then
                    isNew = true
                    break
                end
            end
        end
    end
    if not isNew then
        for key, oldValue in pairs(oldMap) do
            if not adornMap[key] then
                isNew = true
                break
            end
        end
    end

    if isNew then
        self:setState({
            partsList = adornMap,
        })
    end

    debug.profileend()
end

function WorldView:instanceAdded(inst)
    if self.trackedParts[inst] then
        self.trackedParts[inst] = self.trackedParts[inst] + 1
    else
        self.trackedParts[inst] = 1
        self.nextId = self.nextId + 1
        self.partIds[inst] = self.nextId
    end
end

function WorldView:instanceRemoved(inst)
    if self.trackedParts[inst] <= 1 then
        self.trackedParts[inst] = nil
        self.partIds[inst] = nil
    else
        self.trackedParts[inst] = self.trackedParts[inst] - 1
    end
end

local function isTypeAllowed(instance)
    if instance.ClassName == 'Model' then return true end
    if instance.ClassName == 'Attachment' then return true end
    if instance:IsA("BasePart") then return true end
    return false
end

function WorldView:tagAdded(tagName)
    assert(not self.trackedTags[tagName])
    self.trackedTags[tagName] = true
    for _,obj in pairs(Collection:GetTagged(tagName)) do
        if isTypeAllowed(obj) then
            if obj:IsDescendantOf(workspace) then
                self:instanceAdded(obj)
            end
            if not self.instanceAncestryChangedConns[obj] then
                self.instanceAncestryChangedConns[obj] = obj.AncestryChanged:Connect(function()
                    if not self.trackedParts[obj] and obj:IsDescendantOf(workspace) then
                        self:instanceAdded(obj)
                        self:updateParts()
                    elseif self.trackedParts[obj] and not obj:IsDescendantOf(workspace) then
                        self:instanceRemoved(obj)
                        self:updateParts()
                    end
                end)
            end
        end
    end
    self.instanceAddedConns[tagName] = Collection:GetInstanceAddedSignal(tagName):Connect(function(obj)
        if not isTypeAllowed(obj) then return end
        if obj:IsDescendantOf(workspace) then
            self:instanceAdded(obj)
            self:updateParts()
        else
            print("outside workspace", obj)
        end
        if not self.instanceAncestryChangedConns[obj] then
            self.instanceAncestryChangedConns[obj] = obj.AncestryChanged:Connect(function()
                if not self.trackedParts[obj] and obj:IsDescendantOf(workspace) then
                    self:instanceAdded(obj)
                    self:updateParts()
                elseif self.trackedParts[obj] and not obj:IsDescendantOf(workspace) then
                    self:instanceRemoved(obj)
                    self:updateParts()
                end
            end)
        end
    end)
    self.instanceRemovedConns[tagName] = Collection:GetInstanceRemovedSignal(tagName):Connect(function(obj)
        if not isTypeAllowed(obj) then return end
        self:instanceRemoved(obj)
        self:updateParts()
    end)
end

function WorldView:tagRemoved(tagName)
    assert(self.trackedTags[tagName])
    self.trackedTags[tagName] = nil
    for _,obj in pairs(Collection:GetTagged(tagName)) do
        self:instanceRemoved(obj)
    end
    self.instanceAddedConns[tagName] = nil
    self.instanceRemovedConns[tagName] = nil
end

function WorldView:willUnmount()
    self.onTagAddedConn:Disconnect()
    self.onTagRemovedConn:Disconnect()
    self.onTagChangedConn:Disconnect()

    self.instanceAddedConns:clean()
    self.instanceRemovedConns:clean()
    self.maid:clean()
end

function WorldView:render()
    local props = self.props

    if not props.worldView then
        return nil
    end

    local partsList = self.state.partsList

    local children = {}

    for key,entry in pairs(partsList) do
        local elt
        if entry.DrawType == 'Outline' then
            elt = OutlineAdorn
        elseif entry.DrawType == 'Box' then
            elt = BoxAdorn
        elseif entry.DrawType == 'Sphere' then
            elt = SphereAdorn
        elseif entry.DrawType == 'Icon' then
            elt = IconAdorn
        elseif entry.DrawType == 'Text' then
            elt = TextAdorn
        else
            error("Unknown DrawType: "..tostring(entry.DrawType))
        end
        children[key] = Roact.createElement(elt, {
            Adornee = entry.Part,
            Icon = entry.Icon,
            Color = entry.Color,
            TagName = entry.TagName,
            AlwaysOnTop = entry.AlwaysOnTop,
        })
    end

    return Roact.createElement(Roact.Portal, {
        target = CoreGui,
    }, {
        TagEditorWorldView = Roact.createElement("Folder", {}, children),
    })
end

local function conditionalComponent(component, property)
    return function(props)
        if props[property] then
            return Roact.createElement(component, props)
        else
            return nil
        end
    end
end

WorldView = conditionalComponent(WorldView, 'worldView')

WorldView = RoactRodux.connect(function(store)
    local state = store:getState()

    return {
        worldView = state.WorldView,
        tags = state.TagData,
    }
end)(WorldView)

return WorldView
