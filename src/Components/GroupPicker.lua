local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Constants = require(script.Parent.Parent.Constants)
local Actions = require(script.Parent.Parent.Actions)
local Icon = require(script.Parent.Icon)
local TextLabel = require(script.Parent.TextLabel)
local ScrollingFrame = require(script.Parent.ScrollingFrame)
local TagManager = require(script.Parent.Parent.TagManager)
local Item = require(script.Parent.ListItem)

local function Group(props)
    return Roact.createElement(Item, {
        Icon = 'folder',
        Text = props.Name,
        Active = props.Active,
        LayoutOrder = props.LayoutOrder,

        leftClick = function(rbx)
            TagManager.Get():SetGroup(props.Tag, props.Group)
            props.close()
        end,

        onDelete = props.Group and function()
            props.delete(props.Group)
        end or nil,
    })
end

local function mapStateToProps(state)
    return {
        Tag = state.GroupPicker,
    }
end

local function mapDispatchToProps(dispatch)
    return {
        close = function()
            dispatch(Actions.ToggleGroupPicker(nil))
        end,
        delete = function(name)
            TagManager.Get():DelGroup(name)
        end,
    }
end

Group = RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(Group)

local function GroupPicker(props)
    local children = {}

    children.UIPadding = Roact.createElement("UIPadding", {
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 2),
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 2),
    })

    children.Default = Roact.createElement(Group, {
        Name = "Default",
        Group = nil,
        Active = props.tagGroup == nil,
        LayoutOrder = -1,
    })

    table.sort(props.groups, function(a,b) return a.Name < b.Name end)

    for i,entry in pairs(props.groups) do
        local group = entry.Name
        children['Group '..group] = Roact.createElement(Group, {
            Name = group,
            Group = group,
            Active = props.tagGroup == group,
            LayoutOrder = i,
        })
    end

    children.AddNew = Roact.createElement(Item, {
        LayoutOrder = 99999999,
        Text = "Add new group...",
        Icon = "folder_add",
        IsInput = true,

        onSubmit = function(rbx, text)
            TagManager.Get():AddGroup(text)
        end,
    })

    return Roact.createElement("ImageButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Constants.White,
        ZIndex = 10,
        Visible = props.groupPicker ~= nil,
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
                    Text = tostring(props.groupPicker).." - Select a Group",
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

local function mapStateToProps(state)
    local tag = state.GroupPicker and TagManager.Get().tags[state.GroupPicker]

    return {
        groupPicker = state.GroupPicker,
        tagIcon = tag and tag.Icon or nil,
        tagGroup = tag and tag.Group or nil,
        groups = state.GroupData,
    }
end

local function mapDispatchToProps(dispatch)
    return {
        close = function()
            dispatch(Actions.ToggleGroupPicker(nil))
        end,
    }
end

GroupPicker = RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(GroupPicker)

return GroupPicker
