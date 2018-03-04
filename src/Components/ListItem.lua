local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Constants = require(script.Parent.Parent.Constants)
local Icon = require(script.Parent.Icon)

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

local Item = Roact.Component:extend("Item")

local function fade(color, amount)
    return color:lerp(Constants.White, amount or 0.7)
end

function Item:render()
    local props = self.props
    local height = 26
    local buttonStyle
    local textStyle
    local flairColor
    local showDivider = true
    local isHover = self.state.Hover and not props.menuOpen
    if props.Active or props.SemiActive then
        local onlySemi = props.SemiActive and not props.Active
        local color = Constants.RobloxBlue
        if isHover then
            color = Constants.RobloxBlueDark
        end
        if onlySemi then
            color = fade(color, .5)
        end
        buttonStyle = {
            Image = "rbxasset://textures/ui/dialog_white.png",
            SliceCenter = Rect.new(10, 10, 10, 10),
            ImageColor3 = color,
        }
        textStyle = {
            TextColor3 = Constants.White,
            Font = Enum.Font.SourceSansSemibold,
        }
        showDivider = false
        if isHover then
            flairColor = Constants.VeryDarkGrey
        end
    elseif isHover then
        buttonStyle = {
            Image = "rbxasset://textures/ui/dialog_white.png",
            SliceCenter = Rect.new(10, 10, 10, 10),
            ImageColor3 = Constants.LightGrey,
        }
        flairColor = Constants.DarkGrey
        showDivider = false
    end
    return Roact.createElement("ImageButton", merge({
        ScaleType = Enum.ScaleType.Slice,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1.0,
        LayoutOrder = props.LayoutOrder,
        Visible = not props.Hidden,

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

        [Roact.Event.MouseButton1Click] = function(rbx)
            if props.leftClick then
                props.leftClick(rbx)
            end
        end,

        [Roact.Event.MouseButton2Click] = function(rbx)
            if props.rightClick then
                props.rightClick(rbx)
            end
        end,
    }, buttonStyle), {
        Divider = Roact.createElement("Frame", {
            Visible = showDivider,
            Size = UDim2.new(1, -10, 0, 1),
            Position = UDim2.new(0.5, 0, 0, 0),
            AnchorPoint = Vector2.new(0.5, 0),
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
        Icon = props.Icon and Roact.createElement(Icon, {
            Name = props.Icon,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 24, 0.5, 0),
        }) or nil,
        Name = Roact.createElement(props.IsInput and "TextBox" or "TextLabel", merge(merge({
            BackgroundTransparency = 1.0,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = props.Icon and UDim2.new(0, 40, 0, 0) or UDim2.new(0, 14, 0, 0),
            Size = UDim2.new(1, -40, 0, height),
            Text = props.IsInput and "" or props.Text,
            PlaceholderText = props.IsInput and props.Text or nil,
            PlaceholderColor3 = props.IsInput and Constants.DarkGrey or nil,
            Font = Enum.Font.SourceSans,
            TextSize = 20,
            TextColor3 = Color3.fromRGB(0, 0, 0),

            [Roact.Event.FocusLost] = props.IsInput and function(rbx, enterPressed)
                local text = rbx.Text
                rbx.Text = ""
                if props.onSubmit and enterPressed then
                    props.onSubmit(rbx, text)
                end
            end or nil,
        }, textStyle), props.TextProps or {})),
        Visibility = props.onSetVisible and Roact.createElement(Icon, {
            Name = props.Visible and "lightbulb" or "lightbulb_off",
            Position = UDim2.new(1, -4, .5, 0),
            AnchorPoint = Vector2.new(1, .5),

            onClick = props.onSetVisible,
        }) or nil,
        Settings = props.onSettings and Roact.createElement(Icon, {
            Name = 'cog',
            Position = UDim2.new(1, -24, .5, 0),
            AnchorPoint = Vector2.new(1, .5),

            onClick = props.onSettings,
        }) or nil,
        Delete = props.onDelete and Roact.createElement(Icon, {
            Name = "cancel",
            Position = UDim2.new(1, -4, .5, 0),
            AnchorPoint = Vector2.new(1, .5),

            onClick = props.onDelete,
        }) or nil,
    })
end

Item = RoactRodux.connect(function(store)
    local state = store:getState()

    return {
        menuOpen = state.TagMenu and not state.GroupPicker,
    }
end)(Item)

return Item
