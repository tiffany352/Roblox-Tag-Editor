local Collection = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")

local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Constants = require(script.Parent.Parent.Constants)
local TagManager = require(script.Parent.Parent.TagManager)
local Icon = require(script.Parent.Icon)

local function BoxAdorn(props)
    return Roact.createElement("SelectionBox", {
        LineThickness = 0.03,
        SurfaceTransparency = 0.7,
        SurfaceColor3 = props.Color,
        Adornee = props.Adornee,
        Color3 = props.Color,
    })
end

local function OutlineAdorn(props)
    return Roact.createElement("SelectionBox", {
        LineThickness = 0.05,
        Adornee = props.Adornee,
        Color3 = props.Color,
    })
end

local function SphereAdorn(props)
    return Roact.createElement("SphereHandleAdornment", {
        Adornee = props.Adornee,
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
    self.instanceAddedConns = {}
    self.instanceRemovedConns = {}
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

function WorldView:updateParts()
    local newList = {}

    for obj,_ in pairs(self.trackedParts) do
        if obj:IsA("BasePart") then
            newList[#newList+1] = {
                Position = obj.Position,
                Instance = obj,
            }
        elseif obj:IsA("Model") then
            local primary = obj.PrimaryPart
            if not primary then
                local largest
                local largest_by = 0
                for _,part in pairs(obj:GetChildren()) do
                    if part:IsA("BasePart") then
                        local size = part.Size.Magnitude
                        if size > largest_by then
                            largest_by = size
                            largest = part
                        end
                    end
                end
                primary = largest
            end
            if primary then
                newList[#newList+1] = {
                    Position = primary.Position,
                    Instance = obj,
                }
            end
        end
    end

    local cam = workspace.CurrentCamera
    if cam then
        local pos = cam.Focus.p
        table.sort(newList, function(a,b)
            local ap = a.Position - pos
            local ad = ap:Dot(ap)
            local bp = b.Position - pos
            local bd = bp:Dot(bp)
            return ad < bd
        end)
    end

    local newList2 = {}
    local nl2Index = 1
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
            newList2[nl2Index] = {
                Id = partId,
                Part = newList[i].Instance,
                DrawType = 'Outline',
                Color = avg,
                AlwaysOnTop = anyAlwaysOnTop,
            }
            nl2Index = nl2Index + 1
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
            newList2[nl2Index] = {
                Id = partId,
                Part = newList[i].Instance,
                DrawType = 'Box',
                Color = avg,
                AlwaysOnTop = anyAlwaysOnTop,
            }
            nl2Index = nl2Index + 1
        end

        if #icons > 0 then
            newList2[nl2Index] = {
                Id = partId,
                Part = newList[i].Instance,
                DrawType = 'Icon',
                Icon = icons,
                AlwaysOnTop = anyAlwaysOnTop,
            }
            nl2Index = nl2Index + 1
        end

        if #labels > 0 then
            table.sort(labels)
            if #icons > 0 then
                labels[#labels+1] = ''
            end
            newList2[nl2Index] = {
                Id = partId,
                Part = newList[i].Instance,
                DrawType = 'Text',
                TagName = labels,
                AlwaysOnTop = anyAlwaysOnTop,
            }
            nl2Index = nl2Index + 1
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
            newList2[nl2Index] = {
                Id = partId,
                Part = newList[i].Instance,
                DrawType = 'Sphere',
                Color = avg,
                AlwaysOnTop = anyAlwaysOnTop,
            }
            nl2Index = nl2Index + 1
        end

        if nl2Index >= 500 then
            break
        end
    end

    -- sort by part ID so the list remains stable in the view of roact
    table.sort(newList2, function(a, b)
        if a.Id < b.Id then return true end
        if b.Id < a.Id then return false end

        return a.DrawType < b.DrawType
    end)

    -- make sure it's not the same as the current list
    local isNew = false
    if #newList2 ~= #self.state.partsList then
        isNew = true
    else
        for i = 1, #newList2 do
            local props = {
                'Part',
                'Icon',
                'Id',
                'DrawType',
                'Color',
                'TagName',
                'AlwaysOnTop',
            }
            for j = 1, #props do
                local prop = props[j]
                if newList2[i][prop] ~= self.state.partsList[i][prop] then
                    isNew = true
                    break
                end
            end
        end
    end

    if isNew then
        self:setState({
            partsList = newList2,
        })
    end
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

function WorldView:tagAdded(tagName)
    assert(not self.trackedTags[tagName])
    self.trackedTags[tagName] = true
    assert(not self.instanceAddedConns[tagName])
    assert(not self.instanceRemovedConns[tagName])
    for _,obj in pairs(Collection:GetTagged(tagName)) do
        self:instanceAdded(obj)
    end
    self.instanceAddedConns[tagName] = Collection:GetInstanceAddedSignal(tagName):Connect(function(obj)
        self:instanceAdded(obj)
        self:updateParts()
    end)
    self.instanceRemovedConns[tagName] = Collection:GetInstanceRemovedSignal(tagName):Connect(function(obj)
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
    self.instanceAddedConns[tagName]:Disconnect()
    self.instanceAddedConns[tagName] = nil
    self.instanceRemovedConns[tagName]:Disconnect()
    self.instanceRemovedConns[tagName] = nil
end

function WorldView:willUnmount()
    self.onTagAddedConn:Disconnect()
    self.onTagRemovedConn:Disconnect()
    self.onTagChangedConn:Disconnect()
    for _,conn in pairs(self.instanceAddedConns) do
        conn:Disconnect()
    end
    for _,conn in pairs(self.instanceRemovedConns) do
        conn:Disconnect()
    end
end

function WorldView:render()
    local props = self.props

    if not props.worldView then
        return nil
    end

    local partsList = self.state.partsList

    local children = {}

    for i,entry in pairs(partsList) do
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
        children[entry.DrawType.." "..tostring(entry.Id)] = Roact.createElement(elt, {
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

WorldView = RoactRodux.connect(function(store)
    local state = store:getState()

    return {
        worldView = state.WorldView,
        tags = state.TagData,
    }
end)(WorldView)

return WorldView
