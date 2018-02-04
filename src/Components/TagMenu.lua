local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Constants = require(script.Parent.Parent.Constants)
local ContextMenu = require(script.Parent.ContextMenu)
local Actions = require(script.Parent.Parent.Actions)
local TagManager = require(script.Parent.Parent.TagManager)
local ScrollingFrame = require(script.Parent.ScrollingFrame)

local function TagMenu(props)
    return Roact.createElement(ContextMenu.Container, {
        Visible = props.tagMenu ~= nil,
        OnClose = props.close,
    }, {
        Header = Roact.createElement(ContextMenu.Header, {
            Text = props.tagMenu,
            Icon = props.tagIcon,
            LayoutOrder = 1,
        }),
        Scroll = Roact.createElement(ScrollingFrame, {
            List = true,
            LayoutOrder = 2,
            -- header = 32, footer = 8, close = 36
            Size = UDim2.new(1, 4, 1, 0 - 32 - 8 - 36),
        }, {
            UISizeConstraint = Roact.createElement("UISizeConstraint", {
                MaxSize = Vector2.new(math.huge, 28 * 7),
            }),
            Delete = Roact.createElement(ContextMenu.Confirm, {
                Text = "Delete...",
                LayoutOrder = 2,
                onClick = function()
                    TagManager.Get():DelTag(props.tagMenu)
                    props.close()
                end,
            }),
            ChangeIcon = Roact.createElement(ContextMenu.Item, {
                Text = "Change Icon...",
                LayoutOrder = 3,
                onClick = function()
                    props.iconPicker()
                end,
            }),
            Instances = Roact.createElement(ContextMenu.Item, {
                Text = "Instances with this tag...",
                LayoutOrder = 4,
                onClick = function()
                    props.instanceView()
                end,
            }),
            Group = Roact.createElement(ContextMenu.Item, {
                Text = "Change Group...",
                LayoutOrder = 5,
                onClick = function()
                    props.groupPicker()
                end,
            }),
            Color = Roact.createElement(ContextMenu.Color, {
                Text = "Color...",
                LayoutOrder = 6,
                Color = props.tagColor,

                onClick = function()
                    props.colorPicker()
                end,
            }),
            DrawType = Roact.createElement(ContextMenu.Dropdown, {
                Text = "Visualization Type",
                Value = props.tagDrawType,
                Options = {
                    None = "None",
                    Icon = "Icon",
                    Outline = "Outline",
                    Box = "Box",
                    Sphere = "Sphere",
                    Text = "Label",
                },
                LayoutOrder = 7,

                onSubmit = function(value)
                    TagManager.Get():SetDrawType(props.tagMenu, value)
                end,
            }),
            AlwaysOnTop = Roact.createElement(ContextMenu.Checkbox, {
                Text = "Always On Top",
                LayoutOrder = 8,
                Value = props.tagAlwaysOnTop,

                onSubmit = function(value)
                    TagManager.Get():SetAlwaysOnTop(props.tagMenu, value)
                end,
            }),
        }),
        Footer = Roact.createElement(ContextMenu.Item, {
            LayoutOrder = 3,
            Last = true,
            Size = UDim2.new(1, 0, 0, 8),
            ImageColor3 = Constants.RobloxBlue,
        }),
        Close = Roact.createElement(ContextMenu.Cancel, {
            LayoutOrder = 99,
            OnClose = props.close,
            Text = "Close",
        }),
    })
end

TagMenu = RoactRodux.connect(function(store)
    local state = store:getState()

    local icon
    local drawType
    local color
    local alwaysOnTop
    for _,v in pairs(state.TagData) do
        if v.Name == state.TagMenu then
            icon = v.Icon
            drawType = v.DrawType or "Box"
            color = v.Color
            alwaysOnTop = v.AlwaysOnTop
        end
    end

    return {
        tagMenu = not state.IconPicker and state.TagMenu or nil,
        tagIcon = icon or "tag_green",
        tagColor = color,
        tagDrawType = drawType,
        tagAlwaysOnTop = alwaysOnTop,
        close = function()
            store:dispatch(Actions.OpenTagMenu(nil))
        end,
        iconPicker = function()
            store:dispatch(Actions.ToggleIconPicker(state.TagMenu))
        end,
        colorPicker = function()
            store:dispatch(Actions.ToggleColorPicker(state.TagMenu))
        end,
        groupPicker = function()
            store:dispatch(Actions.ToggleGroupPicker(state.TagMenu))
        end,
        instanceView = function()
            store:dispatch(Actions.OpenInstanceView(state.TagMenu))
        end,
    }
end)(TagMenu)

return TagMenu
