local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local Constants = require(script.Parent.Parent.Constants)

local function ScrollingFrame(props)
    local children = {}

    if props.List then
        local newProps = {}
        newProps[Roact.Ref] = function(rbx)
            if not rbx then return end
            local function update()
                local cs = rbx.AbsoluteContentSize
                rbx.Parent.CanvasSize = UDim2.new(0, 0, 0, cs.y)
            end
            rbx:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
            update()
        end
        newProps.SortOrder = Enum.SortOrder.LayoutOrder
        for key,value in pairs(props.List == true and {} or props.List) do
            newProps[key] = value
        end
        children.UIListLayout = Roact.createElement("UIListLayout", newProps)
    end

    for key, value in pairs(props[Roact.Children]) do
        children[key] = value
    end
    return Roact.createElement("ScrollingFrame", {
        Size = props.Size or UDim2.new(1, 0, 1, 0),
        Position = props.Position,
        BackgroundColor3 = Constants.DarkGrey,
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        BorderSizePixel = 0,
        MidImage = 'rbxasset://textures/ui/Gear.png',
        BottomImage = 'rbxasset://textures/ui/Gear.png',
        TopImage = 'rbxasset://textures/ui/Gear.png',
        VerticalScrollBarInset = Enum.ScrollBarInset.Always,
    }, children)
end

return ScrollingFrame
