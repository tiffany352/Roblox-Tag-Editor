local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Constants = require(script.Parent.Parent.Constants)
local Icon = require(script.Parent.Icon)
local Actions = require(script.Parent.Parent.Actions)

local ContextMenu = {}

function ContextMenu.Container(props)
    local children = {}
    children.UISizeConstraint = Roact.createElement("UISizeConstraint", {
        MaxSize = Vector2.new(250, math.huge),
    })
    children.UIListLayout = Roact.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    for k,v in pairs(props[Roact.Children] or {}) do
        children[k] = v
    end

    return Roact.createElement("ImageButton", {
        Size = UDim2.new(1, 0, 1, 0),
        Transparency = 0.5,
        BackgroundColor3 = Constants.Black,
        AutoButtonColor = false,
        ZIndex = 2,
        Visible = props.Visible,

        [Roact.Event.MouseButton1Click] = function(rbx)
            if props.OnClose then
                props.OnClose()
            end
        end,
    }, {
        Window = Roact.createElement("ImageButton", {
            Size = UDim2.new(.95, 0, .95, 0),
            AnchorPoint = Vector2.new(.5, 1),
            Position = UDim2.new(.5, 0, 1, -10),
            BackgroundTransparency = 1.0,
        }, children)
    })
end

ContextMenu.Item = Roact.Component:extend("ContextMenuItem")

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

function ContextMenu.Item:render()
    local props = self.props
    local height = 28
    local center, size, offset = Rect.new(10, 10, 10, 10), Vector2.new(20, 20), Vector2.new(0, 0)
    if props.First and props.Last then
        height = height + 8
    elseif props.First then
        height = height + 4
        size = Vector2.new(20, 10)
    elseif props.Last then
        height = height + 4
        center = Rect.new(10, 0, 10, 0)
        offset = Vector2.new(0, 10)
        size = Vector2.new(20, 10)
    else
        center = Rect.new(10, 0, 10, 0)
        size = Vector2.new(20, 1)
        offset = Vector2.new(0, 10)
    end

    local children = {}
    if not props.Last and not props.NoDivider then
        children.Divider = Roact.createElement("Frame", {
            Size = UDim2.new(1, -20, 0, 1),
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, 1),
            BorderSizePixel = 0,
            BackgroundTransparency = Constants.LightGrey,
        })
    end
    children.UIPadding = Roact.createElement("UIPadding", {
        PaddingLeft = UDim.new(0, 3),
        PaddingRight = UDim.new(0, 3),
        PaddingTop = UDim.new(0, props.First and 4 or 0),
        PaddingBottom = UDim.new(0, props.Last and 4 or 1),
    })
    if props.Text or props.Icon then
        children.Frame = Roact.createElement("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1.0,
        }, {
            UIPadding = Roact.createElement("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, props.LeftAlign and 96 or 8),
            }),
            UIListLayout = Roact.createElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,--Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 4),
            }),
            Icon = props.Icon and Roact.createElement(Icon, {
                Name = props.Icon,
                LayoutOrder = 1,
            }) or nil,
            Label = props.Text and Roact.createElement("TextLabel", merge({
                BackgroundTransparency = 1.0,
                Text = props.Text,
                Font = Enum.Font.SourceSans,
                TextSize = 18,
                TextColor3 = Constants.Black,
                LayoutOrder = 2,
                TextXAlignment = Enum.TextXAlignment.Left,

                [Roact.Ref] = function(rbx)
                    if not rbx then return end
                    local function update()
                        local tb = rbx.TextBounds
                        rbx.Size = UDim2.new(0, tb.x + 4, 0, 18)
                    end
                    rbx:GetPropertyChangedSignal("TextBounds"):Connect(update)
                    update()
                    spawn(update)
                end,
            }, props.TextProps)) or nil,
        })
    end

    for k,v in pairs(props[Roact.Children] or {}) do
        children[k] = v
    end

    local hoverColor = Constants.LightGrey --Constants.RobloxBlue:lerp(Constants.White, .9)
    local isHover = self.state.hover and not props.dropdownOpen

    local newProps = {
        Size = UDim2.new(1, 0, 0, height),
        Image = "rbxasset://textures/ui/btn_newWhite.png",
        ImageColor3 = isHover and hoverColor or Constants.White,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = center,
        ImageRectOffset = offset,
        ImageRectSize = size,
        BackgroundTransparency = 1.0,
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
            self:setState({
                hover = false,
            })
            props.onClick(rbx)
        end,
    }

    local blacklist = {
        First = true,
        Last = true,
        NoDivider = true,
        Text = true,
        Icon = true,
        onClick = true,
        LeftAlign = true,
        dropdownOpen = true,
        TextProps = true,
        [Roact.Children] = true,
    }
    for k,v in pairs(props) do
        if not blacklist[k] then
            newProps[k] = v
        end
    end

    return Roact.createElement("ImageButton", newProps, children)
end

ContextMenu.Item = RoactRodux.connect(function(store)
    local state = store:getState()

    return {
        dropdownOpen = state.Dropdown,
    }
end)(ContextMenu.Item)

function ContextMenu.Header(props)
    local newProps = {
        First = true,
        Last = false,
        ImageColor3 = Constants.RobloxBlue,
        TextProps = {
            TextColor3 = Constants.White,
            Font = Enum.Font.SourceSansSemibold,
        },
        NoDivider = true,
        Text = props.Text,

        onClick = function()
        end,
    }
    local blacklist = {
        Text = true,
    }
    for k,v in pairs(props) do
        if not blacklist[k] then
            newProps[k] = v
        end
    end
    return Roact.createElement(ContextMenu.Item, newProps)
end

ContextMenu.Dropdown = Roact.Component:extend("ContextMenuDropdown")

function ContextMenu.Dropdown:render()
    local props = self.props
    local newProps = {
        LeftAlign = true,

        onClick = function()
            self:setState({
                open = not self.state.open,
            })
            props.openDropdown(self.state.open)
        end,
        ZIndex = 2,
    }
    local blacklist = {
        Options = true,
        Value = true,
        onSubmit = true,
        openDropdown = true,
    }
    for k,v in pairs(props) do
        if not blacklist[k] then
            newProps[k] = v
        end
    end

    local children = {}

    children.UIListLayout = Roact.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
    })

    local opts = {}
    for key, text in pairs(props.Options or {}) do
        opts[#opts+1] = { key = key, text = text}
    end
    table.sort(opts, function(a, b) return a.text < b.text end)
    for i = 1, #opts do
        local key = opts[i].key
        local text = opts[i].text
        local center, size, off
        local h = 24
        if i == 1 then
            center = Rect.new(10, 10, 10, 10)
            size = Vector2.new(20, 10)
            h = 32
        elseif i == #opts then
            center = Rect.new(10, 0, 10, 0)
            size = Vector2.new(20, 10)
            off = Vector2.new(0, 10)
            h = 32
        else
            center = Rect.new(10, 0, 10, 0)
            size = Vector2.new(20, 1)
            off = Vector2.new(0, 10)
        end

        local isHover = self.state.hover == key
        local veryLight = Constants.RobloxBlue:lerp(Constants.White, .3)
        children[key] = Roact.createElement("ImageButton", {
            Size = UDim2.new(1, 0, 0, h),
            BackgroundTransparency = 1.0,
            Image = "rbxasset://textures/ui/btn_newWhite.png",
            ImageColor3 = isHover and veryLight or Constants.RobloxBlue,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = center,
            ImageRectSize = size,
            ImageRectOffset = off,
            LayoutOrder = i,

            [Roact.Event.MouseEnter] = function(rbx)
                self:setState({
                    hover = key,
                })
            end,

            [Roact.Event.MouseLeave] = function(rbx)
                if self.state.hover == key then
                    self:setState({
                        hover = false
                    })
                end
            end,

            [Roact.Event.MouseButton1Click] = function(rbx)
                if props.onSubmit then
                    props.onSubmit(key)
                end
                self:setState({
                    open = false,
                })
                props.openDropdown(false)
            end,
        }, {
            Label = Roact.createElement("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                Text = text,
                Font = Enum.Font.SourceSansSemibold,
                TextSize = 18,
                TextColor3 = Constants.White,
                BackgroundTransparency = 1.0,
            }),
            Divider = i < #props.Options and Roact.createElement("Frame", {
                Size = UDim2.new(1, -16, 0, 1),
                Position = UDim2.new(.5, 0, 1, 0),
                AnchorPoint = Vector2.new(.5, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = Constants.DarkGrey,
            }) or nil,
        })
    end

    return Roact.createElement(ContextMenu.Item, newProps, {
        Button = Roact.createElement("ImageLabel", {
            Image = "rbxasset://textures/ui/btn_newWhite.png",
            ImageColor3 = Constants.RobloxBlue,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(10, 10, 10, 10),
            Size = UDim2.new(0, 88, 1, 3),
            BackgroundTransparency = 1.0,
            AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, -8, .5, -1),
            ZIndex = 2,
        }, {
            Label = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1.0,
                Size = UDim2.new(1, 0, 1, 0),
                Text = props.Options[props.Value],
                Font = Enum.Font.SourceSansSemibold,
                TextSize = 18,
                TextColor3 = Constants.White,
            }),
            Menu = Roact.createElement("ImageButton", {
                BackgroundTransparency = 1.0,
                Visible = self.state.open == true,
                Size = UDim2.new(1, 10000, 1, 10000),
                Position = UDim2.new(0, -5000, 0, -5000),
                ZIndex = 2,

                [Roact.Event.MouseButton1Click] = function(rbx)
                    self:setState({
                        open = false,
                    })
                    props.openDropdown(false)
                end,
            }, {
                Holder = Roact.createElement("ImageButton", {
                    BackgroundTransparency = 1.0,
                    Size = UDim2.new(1, -10000, 1, -10000),
                    Position = UDim2.new(0, 5000, 0, 5000),

                    [Roact.Event.MouseLeave] = function(rbx)
                        self:setState({
                            hover = false,
                        })
                    end,
                }, children)
            })
        })
    })
end

ContextMenu.Dropdown = RoactRodux.connect(function(store)
    return {
        openDropdown = function(value)
            store:dispatch(Actions.OpenDropdown(value))
        end
    }
end)(ContextMenu.Dropdown)

function ContextMenu.Color(props)
    local newProps = {
        LeftAlign = props.Color ~= nil,
    }
    for k,v in pairs(props) do
        if k ~= "Color" and k ~= "LeftAlign" then
            newProps[k] = v
        end
    end
    return Roact.createElement(ContextMenu.Item, newProps, {
        Color = Roact.createElement("ImageLabel", {
            Visible = props.Color ~= nil,
            Position = UDim2.new(1, -24, .5, -1),
            Size = UDim2.new(0, 30, 0, 30),
            AnchorPoint = Vector2.new(.5, .5),
            BackgroundTransparency = 1.0,
            Image = "rbxasset://textures/ui/btn_newWhite.png",
            ImageColor3 = props.Color,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(10, 10, 10, 10),
        })
    })
end

ContextMenu.Confirm = Roact.Component:extend("ContextMenuConfirm")

function ContextMenu.Confirm:init()
    self.state = {
        open = false,
    }
end

function ContextMenu.Confirm:render()
    local props = self.props
    local confirm = props.ConfirmText or "Are you sure?"
    local newProps = {
        First = false,
        Last = false,
        Text = self.state.open and confirm or props.Text,

        [Roact.Event.MouseButton1Click] = function(rbx)
            self:setState({
                open = not self.state.open,
            })
        end
    }
    local blacklist = {
        ConfirmText = true,
        Text = true,
        onClick = true,
    }
    for k,v in pairs(props) do
        if not blacklist[k] then
            newProps[k] = v
        end
    end
    return Roact.createElement(ContextMenu.Item, newProps, {
        Button = Roact.createElement("ImageButton", {
            Size = UDim2.new(0, self.state.open and 40 or 0, 1, 0),
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Constants.RobloxBlue,

            [Roact.Event.MouseButton1Click] = function(rbx)
                if props.onClick then
                    props.onClick(rbx)
                end
            end,
        }, {
            Label = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1.0,
                Text = "Yes",
                Size = UDim2.new(1, 0, 1, 0),
                TextSize = 20,
                Font = Enum.Font.SourceSansBold,
                TextColor3 = Constants.White,
                ClipsDescendants = true,
            })
        })
    })
end

function ContextMenu.Cancel(props)
    local newProps = {
        First = true,
        Last = true,

        [Roact.Event.MouseButton1Click] = function(rbx)
            if props.OnClose then
                props.OnClose()
            end
        end,
    }
    local blacklist = {
        OnClose = true,
        Text = true,
    }
    for k,v in pairs(props) do
        if not blacklist[k] then
            newProps[k] = v
        end
    end
    return Roact.createElement(ContextMenu.Item, newProps, {
        Label = Roact.createElement("TextLabel", {
            Text = props.Text or "Cancel",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1.0,
            TextSize = 19,
            Font = Enum.Font.SourceSansSemibold,
            TextColor3 = Constants.Black,
        })
    })
end

function ContextMenu.Checkbox(props)
    local newProps = {
        LeftAlign = true,

        [Roact.Event.MouseButton1Click] = function(rbx)
            if props.onSubmit then
                props.onSubmit(not props.Value)
            end
        end,
    }
    local blacklist = {
        onSubmit = true,
        Value = true,
    }
    for k,v in pairs(props) do
        if not blacklist[k] then
            newProps[k] = v
        end
    end

    return Roact.createElement(ContextMenu.Item, newProps, {
        Checkbox = Roact.createElement("ImageLabel", {
            Image = 'rbxasset://textures/ui/LuaChat/9-slice/input-default.png',
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(4, 4, 4, 4),
            Size = UDim2.new(0, 24, 0, 24),
            BackgroundTransparency = 1.0,
            BorderSizePixel = 1,
            BackgroundColor3 = Constants.White,
            BorderColor3 = Constants.DarkGrey,
            Position = UDim2.new(1, -24, 0.5, 0),
            AnchorPoint = Vector2.new(.5, .5),
        }, {
            Checked = Roact.createElement("ImageLabel", {
                Image = 'rbxasset://textures/ui/LuaChat/9-slice/input-default.png',
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(4, 4, 4, 4),
                ImageColor3 = Constants.RobloxBlue,
                BackgroundTransparency = 1.0,
                BorderSizePixel = 0,
                BackgroundColor3 = Constants.RobloxBlue,
                Visible = props.Value,
                Size = UDim2.new(1, -4, 1, -4),
                Position = UDim2.new(.5, 0, .5, 0),
                AnchorPoint = Vector2.new(.5, .5),
            })
        })
    })
end

return ContextMenu
