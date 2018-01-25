local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Constants = require(script.Parent.Parent.Constants)
local TagManager = require(script.Parent.Parent.TagManager)
local Actions = require(script.Parent.Parent.Actions)
local ContextMenu = require(script.Parent.ContextMenu)

local function DisplayOptions(props)
    props = {
        tagName = "Computer",
        tagIcon = "computer",
    }
    return Roact.createElement(ContextMenu.Container, {

    }, {
        Header = Roact.createElement(ContextMenu.Header, {
            Text = (props.tagName or "").." - Display Options",
            Icon = props.tagIcon,
            LayoutOrder = 1,
        }),
        DrawType = Roact.createElement(ContextMenu.Item, {
            Text = "Visualization type",
            --[[Options = {
                "None",
                "Icon",
                "Box",
                "Box with icon",
                "Sphere",
            },]]
            LayoutOrder = 2,
        }),
        Color = Roact.createElement(ContextMenu.Item, {
            Text = "Color",
            Last = true,
            LayoutOrder = 3,
        }),
        Back = Roact.createElement(ContextMenu.Cancel, {
            Text = "Back",
            LayoutOrder = 99,
        }),
    })
end

return DisplayOptions
