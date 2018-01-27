local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Icon = require(script.Parent.Icon)
local Icons = require(script.Parent.Parent.FamFamFam)
local Constants = require(script.Parent.Parent.Constants)
local TagManager = require(script.Parent.Parent.TagManager)
local Actions = require(script.Parent.Parent.Actions)

local iconsWhitelist = {}
local blacklisted = {
    "_add$",
    "_edit$",
    "_delete$",
    "_error$",
    "_go$",
    "_link$",
    "^application_",
    "_form_",
    "^page_white_",
    "^control_",
    "^bullet_",
    "^resultset_",
    "^text_",
}

for name,_ in pairs(Icons.Table) do
    local pass = true
    for _,pat in pairs(blacklisted) do
        if name:match(pat) then
            pass = false
            break
        end
    end
    if pass then
        iconsWhitelist[#iconsWhitelist+1] = name
    end
end

table.sort(iconsWhitelist)

local function IconPicker(props)
    local children = {}
    for _,name in pairs(iconsWhitelist) do
        children[name] = Roact.createElement(Icon, {
            Name = name,

            onClick = function(rbx)
                TagManager.Get():SetIcon(props.tagName, name)
                props.close()
            end,
        })
    end

    children.UIGridLayout = Roact.createElement("UIGridLayout", {
        CellSize = UDim2.new(0, 16, 0, 16),
        CellPadding = UDim2.new(0, 4, 0, 4),

        [Roact.Ref] = function(rbx)
            if not rbx then return end
            local function update()
                local cs = rbx.AbsoluteContentSize
                rbx.Parent.CanvasSize = UDim2.new(0, 0, 0, cs.y + 8)
            end
            update()
            rbx:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
        end,
    })

    children.UIPadding = Roact.createElement("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
    })

    return Roact.createElement("ImageButton", {
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 2,
        BackgroundTransparency = 0.5,
        BackgroundColor3 = Constants.Black,
        AutoButtonColor = false,
        Visible = props.tagName ~= nil,

        [Roact.Event.MouseButton1Click] = function(rbx)
            props.close()
        end,
    }, {
        Container = Roact.createElement("Frame", {
            BackgroundTransparency = 1.0,
            Size = UDim2.new(1, -20, 1, -20),
            AnchorPoint = Vector2.new(.5, 1),
            Position = UDim2.new(.5, 0, 1, -10),
        }, {
            Window = Roact.createElement("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.new(0.5, 0, 1, 0),
                BackgroundTransparency = 1.0,
                Image = "rbxasset://textures/ui/btn_newWhite.png",
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(10, 10, 10, 10),
                ImageColor3 = Constants.RobloxBlue,
            }, {
                UISizeConstraint = Roact.createElement("UISizeConstraint", {
                    MaxSize = Vector2.new(300, 300),
                }),
                Title = Roact.createElement("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 4),
                    Text = "Pick an Icon",
                    Font = Enum.Font.SourceSansSemibold,
                    TextColor3 = Constants.White,
                    TextSize = 20,
                    BackgroundTransparency = 1.0,
                }),
                IconList = Roact.createElement("ScrollingFrame", {
                    Size = UDim2.new(1, -10, 1, -30),
                    Position = UDim2.new(.5, 0, 1, -5),
                    AnchorPoint = Vector2.new(.5, 1),
                    ScrollBarThickness = 4,
                    BorderSizePixel = 0,
                    MidImage = 'rbxasset://textures/ui/Gear.png',
                    BottomImage = 'rbxasset://textures/ui/Gear.png',
                    TopImage = 'rbxasset://textures/ui/Gear.png',
                    VerticalScrollBarInset = Enum.ScrollBarInset.Always,
                    BackgroundColor3 = Constants.White,
                }, children)
            })
        }),
    })
end

IconPicker = RoactRodux.connect(function(store)
    local state = store:getState()

    return {
        close = function()
            store:dispatch(Actions.ToggleIconPicker(nil))
        end,
        tagName = state.IconPicker,
    }
end)(IconPicker)

return IconPicker
