local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local Icons = require(script.Parent.Parent.FamFamFam)

local function merge(orig, new)
    local t = {}
    for k,v in pairs(orig or {}) do
        t[k] = v
    end
    for k,v in pairs(new or {}) do
        t[k] = v
    end
    return t
end

local function Icon(props)
    local data = Icons.Lookup(props.Name) or Icons.Lookup("computer_error")
    return Roact.createElement("ImageLabel", merge(data, {
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundTransparency = props.BackgroundTransparency or 1.0,
        Position = props.Position,
        AnchorPoint = props.AnchorPoint,
    }))
end

local Button = Roact.Component:extend("Button")

function Button:render()
    local active = self.state.Active
    local hover = self.state.Hover
    local activeHoverStyle = merge(self.props.HoverStyle, self.props.ActiveStyle)
    return Roact.createElement("ImageButton", merge({
        [Roact.Event.MouseEnter] = function(rbx)
            self:setState({
                Hover = true
            })
        end,

        [Roact.Event.MouseLeave] = function(rbx)
            self:setState({
                Hover = false
            })
        end,
    }, active and hover and activeHoverStyle or
        active and self.props.ActiveStyle or
        hover and self.props.HoverSyle or
        self.props.DefaultStyle
    ), {
        self.props[Roact.Children]
    })
end

local function Tag(props)
    local height = 32
    local buttonStyle
    local textStyle
    if props.Active then
        buttonStyle = {
            Image = "rbxasset://textures/ui/dialog_white.png", -- rbxassetid://1353014916
            SliceCenter = Rect.new(10, 10, 10, 10),
            ImageColor3 = Color3.fromRGB(0, 162, 255),
        }
        textStyle = {
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.SourceSansSemibold,
        }
    elseif props.Hover then
        buttonStyle = {
            Image = "rbxasset://textures/ui/dialog_green.png",
            SliceCenter = Rect.new(20, 20, 20, 20),
            ImageColor3 = Color3.fromRGB(232, 232, 232),
        }
    end
    return Roact.createElement("ImageButton", merge({
        ScaleType = Enum.ScaleType.Slice,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1.0,
    }, buttonStyle), {
        Icon = Roact.createElement(Icon, {
            Name = props.Icon or "tag_green",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 16, 0.5, 0),
        }),
        Name = Roact.createElement("TextLabel", merge({
            BackgroundTransparency = 1.0,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 32, 0, 0),
            Size = UDim2.new(0, 200, 0, height),
            Text = props.Tag,
            Font = Enum.Font.SourceSans,
            TextSize = 20,
            TextColor3 = Color3.fromRGB(0, 0, 0),
        }, textStyle)),
    })
end

return function(props)
    props = {
        {
            Tag = "Door",
            Icon = "door",
            Active = true,
        },
        {
            Tag = "Computer",
            Icon = "computer",
            Hover = true,
        },
        {
            Tag = "Activation",
            Icon = "mouse",
        }
    }

    table.sort(props, function(a,b) return a.Tag < b.Tag end)

    local children = {}

    children.UIListLayout = Roact.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    })

    for i = 1, #props do
        children[tostring(i)] = Roact.createElement(Tag, merge(props[i], {
            SortOrder = i,
        }))
    end

    return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, children)
end
