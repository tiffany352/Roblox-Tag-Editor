local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Constants = require(script.Parent.Parent.Constants)
local Actions = require(script.Parent.Parent.Actions)
local Icon = require(script.Parent.Icon)
local TagManager = require(script.Parent.Parent.TagManager)

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
        buttonStyle = buttonStyle or {
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
        Icon = Roact.createElement(Icon, {
            Name = props.Icon or "tag_green",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 24, 0.5, 0),
        }),
        Name = Roact.createElement(props.IsInput and "TextBox" or "TextLabel", merge({
            BackgroundTransparency = 1.0,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 40, 0, 0),
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
        }, textStyle)),
        Visibility = props.onSetVisible and Roact.createElement(Icon, {
            Name = props.Visible and "lightbulb" or "lightbulb_off",
            Position = UDim2.new(1, -4, .5, 0),
            AnchorPoint = Vector2.new(1, .5),

            onClick = props.onSetVisible,
        }) or nil,
    })
end

Item = RoactRodux.connect(function(store)
    local state = store:getState()

    return {
        menuOpen = state.TagMenu,
    }
end)(Item)

local function Tag(props)
    return Roact.createElement(Item, {
        Text = props.Tag,
        Icon = props.Icon,
        IsInput = false,
        LayoutOrder = props.LayoutOrder,
        Visible = props.Visible,
        Active = props.HasAll,
        SemiActive = props.HasSome,

        onSetVisible = function()
            TagManager.Get():SetVisible(props.Tag, not props.Visible)
        end,

        leftClick = function(rbx)
            TagManager.Get():SetTag(props.Tag, not props.HasAll)
        end,

        rightClick = function(rbx)
            props.openTagMenu(props.Tag)
        end,
    })
end

Tag = RoactRodux.connect(function(store)
    local state = store:getState()

    return {
        openTagMenu = function(tag)
            store:dispatch(Actions.OpenTagMenu(tag))
        end
    }
end)(Tag)

local function TagList(props)
    local tags = props.Tags
    table.sort(tags, function(a,b) return (a.Name or "") < (b.Name or "") end)

    local children = {}

    children.UIListLayout = Roact.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),

        [Roact.Ref] = function(rbx)
            if not rbx then return end
            local function update()
                local cs = rbx.AbsoluteContentSize
                rbx.Parent.CanvasSize = UDim2.new(0, cs.x, 0, cs.y)
            end
            update()
            rbx:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
        end,
    })

    for i = 1, #tags do
        children[tags[i].Name] = Roact.createElement(Tag, merge(tags[i], {
            Tag = tags[i].Name,
            LayoutOrder = i,
        }))
    end
    children.AddNew = Roact.createElement(Item, {
        LayoutOrder = #tags + 1,
        Text = "Add new tag...",
        Icon = "tag_blue_add",
        IsInput = true,

        onSubmit = function(rbx, text)
            TagManager.Get():AddTag(text)
        end,
    })

    return Roact.createElement("ScrollingFrame", {
        Size = props.Size or UDim2.new(1, 0, 1, 0),
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

TagList = RoactRodux.connect(function(store)
    local state = store:getState()

    local tags = {}

    for _, tag in pairs(state.TagData) do
        -- todo: LCS
        local passSearch = not state.Search or tag.Name:lower():find(state.Search:lower())
        if passSearch then
            tags[#tags+1] = tag
        end
    end

    return {
        Tags = tags,
        menuOpen = state.TagMenu,
    }
end)(TagList)

return TagList
