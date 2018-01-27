local Collection = game:GetService("CollectionService")
local Selection = game:GetService("Selection")
local UserInputService = game:GetService("UserInputService")

local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Constants = require(script.Parent.Parent.Constants)
local Actions = require(script.Parent.Parent.Actions)
local TagManager = require(script.Parent.Parent.TagManager)
local Icon = require(script.Parent.Icon)
local TextLabel = require(script.Parent.TextLabel)
local ScrollingFrame = require(script.Parent.ScrollingFrame)

local InstanceItem = Roact.Component:extend("InstanceItem")

function InstanceItem:render()
    local props = self.props

    local isActive = props.Selected
    local isHover = self.state.hover

    local imageColor
    local showDivider
    local flairColor
    if isActive then
        if isHover then
            imageColor = Constants.RobloxBlue:lerp(Constants.LightGrey, 0.5)
            flairColor = Constants.VeryDarkGrey
        else
            imageColor = Constants.RobloxBlue:lerp(Constants.White, 0.5)
        end
        showDivider = false
    elseif isHover then
        imageColor = Constants.LightGrey
        flairColor = Constants.DarkGrey
        showDivider = false
    end

    return Roact.createElement("ImageButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1.0,
        Image = imageColor and "rbxasset://textures/ui/dialog_white.png" or nil,
        SliceCenter = Rect.new(10, 10, 10, 10),
        ImageColor3 = imageColor,
        ScaleType = Enum.ScaleType.Slice,
        LayoutOrder = props.LayoutOrder,

        [Roact.Event.MouseEnter] = function(rbx)
            self:setState({
                hover = true,
            })
        end,

        [Roact.Event.MouseLeave] = function(rbx)
            self:setState({
                hover = false,
            })
        end,

        [Roact.Event.MouseButton1Click] = function(rbx)
            local sel = Selection:Get()
            local alreadySelected = false
            for _,instance in pairs(sel) do
                if instance == props.Instance then
                    alreadySelected = true
                    break
                end
            end
            if alreadySelected then
                if #sel > 1 then
                    -- select only this
                    Selection:Set({ props.Instance })
                else
                    -- deselect
                    local baseSel = {}
                    for _,instance in pairs(sel) do
                        if instance ~= props.Instance then
                            baseSel[#baseSel+1] = instance
                        end
                    end
                    Selection:Set(baseSel)
                end
            else
                -- select
                local baseSel = {}
                local function isDown(key)
                    return UserInputService:IsKeyDown(Enum.KeyCode[key])
                end
                if isDown('LeftControl') or isDown('RightControl') or isDown('LeftShift') or isDown('RightShift') then
                    baseSel = sel
                end
                baseSel[#baseSel+1] = props.Instance
                Selection:Set(baseSel)
            end
        end,
    }, {
        Divider = Roact.createElement("Frame", {
            Visible = showDivider,
            Size = UDim2.new(1, -20, 0, 1),
            Position = UDim2.new(.5, 0, 1, 0),
            AnchorPoint = Vector2.new(.5, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = Constants.LightGrey,
        }),
        Flair = Roact.createElement("ImageLabel", {
            Size = UDim2.new(0, 8, 1, 0),
            Image = "rbxassetid://1353014916",
            BackgroundTransparency = 1.0,
            ImageColor3 = flairColor,
            Visible = flairColor ~= nil,
            ImageRectSize = Vector2.new(4, 40),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(4, 20, 4, 20),
        }),
        Container = Roact.createElement("Frame", {
            Size = UDim2.new(1, -16, 0, 20),
            Position = UDim2.new(0, 16, .5, 0),
            AnchorPoint = Vector2.new(0, .5),
            BackgroundTransparency = 1.0,
        }, {
            UIListLayout = Roact.createElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 4),
            }),
            InstanceClass = Roact.createElement(TextLabel, {
                Text = props.ClassName,
                LayoutOrder = 1,
                Font = Enum.Font.SourceSansSemibold,
                TextColor3 = Constants.VeryDarkGrey,
            }),
            InstanceName = Roact.createElement(TextLabel, {
                Text = props.Name,
                LayoutOrder = 2,
                TextColor3 = Constants.Black,
                Font = Enum.Font.SourceSansSemibold,
            }),
            Path = Roact.createElement(TextLabel, {
                Text = props.Path,
                LayoutOrder = 3,
                Font = Enum.Font.SourceSansItalic,
                TextSize = 18,
                TextColor3 = Constants.VeryDarkGrey,
            })
        }),
    })
end

local InstanceView = Roact.Component:extend("InstanceView")

function InstanceView:init()
    self.nextId = 1
    self.partIds = {}

    self.selectionChangedConn = Selection.SelectionChanged:Connect(function()
        self:_forceUpdate()
    end)
    self.ancestryChangedConns = {}
    self.nameChangedConns = {}
end

function InstanceView:willUnmount()
    if self.instanceAddedConn then
        self.instanceAddedConn:Disconnect()
    end
    if self.instanceRemovedConn then
        self.instanceRemovedConn:Disconnect()
    end
    self.selectionChangedConn:Disconnect()
    for _,conn in pairs(self.ancestryChangedConns) do
        conn:Disconnect()
    end
    for _,conn in pairs(self.nameChangedConns) do
        conn:Disconnect()
    end
end

function InstanceView:render()
    local props = self.props

    local children = {}

    -- begin hack
    if props.instanceView then
        if self.instanceAddedConn then
            self.instanceAddedConn:Disconnect()
            self.instanceAddedConn = nil
        end
        if self.instanceRemovedConn then
            self.instanceRemovedConn:Disconnect()
            self.instanceRemovedConn = nil
        end
        for _,conn in pairs(self.ancestryChangedConns) do
            conn:Disconnect()
        end
        for _,conn in pairs(self.nameChangedConns) do
            conn:Disconnect()
        end
        self.ancestryChangedConns = {}
        self.nameChangedConns = {}
        self.instanceAddedConn = Collection:GetInstanceAddedSignal(props.instanceView):Connect(function(inst)
            self.nameChangedConns[inst] = inst:GetPropertyChangedSignal("Name"):Connect(function()
                self:_forceUpdate()
            end)
            self.ancestryChangedConns[inst] = inst.AncestryChanged:Connect(function()
                self:_forceUpdate()
            end)
            self:_forceUpdate()
        end)
        self.instanceRemovedConn = Collection:GetInstanceRemovedSignal(props.instanceView):Connect(function(inst)
            self.nameChangedConns[inst]:Disconnect()
            self.nameChangedConns[inst] = nil
            self.ancestryChangedConns[inst]:Disconnect()
            self.ancestryChangedConns[inst] = nil
            self:_forceUpdate()
        end)

        local selected = {}
        for _,instance in pairs(Selection:Get()) do
            selected[instance] = true
        end

        local parts = Collection:GetTagged(props.instanceView)
        -- end hack

        for i,obj in pairs(parts) do
            local path = {}
            local cur = obj.Parent
            while cur and cur ~= game do
                table.insert(path, 1, cur.Name)
                cur = cur.Parent
            end
            parts[i] = {
                Instance = obj,
                Path = table.concat(path, "."),
            }
        end

        table.sort(parts, function(a,b)
            if a.Path < b.Path then return true end
            if b.Path < a.Path then return false end

            if a.Instance.Name < b.Instance.Name then return true end
            if b.Instance.Name < b.Instance.Name then return false end

            if a.Instance.ClassName < b.Instance.ClassName then return true end
            if b.Instance.ClassName < b.Instance.ClassName then return false end

            return false
        end)

        for i,entry in pairs(parts) do
            local part = entry.Instance
            local id = self.partIds[part]
            if not id then
                id = self.nextId
                self.nextId = self.nextId + 1
                self.partIds[part] = id
            end
            self.nameChangedConns[part] = part:GetPropertyChangedSignal("Name"):Connect(function()
                self:_forceUpdate()
            end)
            self.ancestryChangedConns[part] = part.AncestryChanged:Connect(function()
                self:_forceUpdate()
            end)
            children[id] = Roact.createElement(InstanceItem, {
                LayoutOrder = i,
                Name = part.Name,
                ClassName = part.ClassName,
                Path = entry.Path,
                Instance = part,
                Selected = selected[part] ~= nil,
            })
        end
    end

    return Roact.createElement("ImageButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Constants.White,
        ZIndex = 10,
        Visible = props.instanceView ~= nil,
        AutoButtonColor = false,
    }, {
        Topbar = Roact.createElement("Frame", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Constants.RobloxBlue,
            BorderSizePixel = 0,
        }, {
            Back = Roact.createElement("TextButton", {
                Size = UDim2.new(0, 48, 0, 32),
                Text = "Back",
                TextSize = 20,
                Font = Enum.Font.SourceSansBold,
                BackgroundTransparency = 1.0,
                TextColor3 = Constants.White,

                [Roact.Event.MouseButton1Click] = function(rbx)
                    props.close()
                end,
            }),
            Title = Roact.createElement("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1.0,
            }, {
                UIListLayout = Roact.createElement("UIListLayout", {
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4),
                }),
                Icon = Roact.createElement(Icon, {
                    Name = props.tagIcon,
                    LayoutOrder = 1,
                }),
                Label = Roact.createElement(TextLabel, {
                    Text = tostring(props.instanceView).." - Instance List",
                    LayoutOrder = 2,
                    TextColor3 = Constants.White,
                    Font = Enum.Font.SourceSansSemibold,
                }),
            })
        }),
        Body = Roact.createElement(ScrollingFrame, {
            Size = UDim2.new(1, 0, 1, -32),
            Position = UDim2.new(0, 0, 0, 32),
            List = true,
        }, children)
    })
end

InstanceView = RoactRodux.connect(function(store)
    local state = store:getState()

    local tag = state.InstanceView and TagManager.Get().tags[state.InstanceView]

    return {
        instanceView = state.InstanceView,
        tagIcon = tag and tag.Icon or nil,
        close = function()
            store:dispatch(Actions.OpenInstanceView(nil))
        end,
    }
end)(InstanceView)

return InstanceView
