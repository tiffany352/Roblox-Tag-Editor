local Collection = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")

local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Constants = require(script.Parent.Parent.Constants)
local Icon = require(script.Parent.Icon)
local TextLabel = require(script.Parent.TextLabel)

local TooltipView = Roact.Component:extend("TooltipView")

local function Tag(props)
    local size = TextService:GetTextSize(props.Tag, 20, Enum.Font.SourceSans, Vector2.new(160, 100000))

    return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 0, 32 - 20 + size.y),
        BackgroundTransparency = 1.0,
    }, {
        Divider = Roact.createElement("Frame", {
            Size = UDim2.new(1, -20, 0, 1),
            Position = UDim2.new(.5, 0, 0, 0),
            AnchorPoint = Vector2.new(.5, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Constants.LightGrey,
        }),
        Holder = Roact.createElement("Frame", {
            Size = UDim2.new(1, -20, 0, size.y),
            Position = UDim2.new(.5, 0, .5, 0),
            AnchorPoint = Vector2.new(.5, .5),
            BackgroundTransparency = 1.0,
        }, {
            UIListLayout = Roact.createElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 4),
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),
            Icon = Roact.createElement(Icon, {
                Name = props.Icon,
                LayoutOrder = 1,
            }),
            Tag = Roact.createElement(TextLabel, {
                Text = props.Tag,
                LayoutOrder = 2,
                TextWrapped = true,
                Size = UDim2.new(1, -20, 0, size.y),
            })
        }),
    })
end

local TooltipGrey = Color3.fromRGB(238, 238, 238)

function TooltipView:didMount()
    self.mouseSunk = false
    self.steppedConn = RunService.RenderStepped:Connect(function()
        local camera = workspace.CurrentCamera
        local part = false
        local tags = {}
        if camera and not self.mouseSunk then
            local mouse = UserInput:GetMouseLocation()
            local ray = camera:ViewportPointToRay(mouse.x, mouse.y)
            ray = Ray.new(ray.Origin, ray.Direction.Unit * 1000)

            local ignore = {}
            for i = 1, 10 do
                local obj = workspace:FindPartOnRayWithIgnoreList(ray, ignore, true)
                local objTags = obj and Collection:GetTags(obj)
                local model = obj and obj.Parent and obj.Parent:IsA("Model") and obj.Parent
                local modelTags = model and Collection:GetTags(model)
                if objTags and #objTags > 0 then
                    part = obj
                    tags = objTags
                    break
                elseif modelTags and #modelTags > 0 then
                    part = model
                    tags = modelTags
                    break
                elseif obj and obj:IsA("Part") and obj.Transparency >= 0.9 then
                    ignore[#ignore+1] = obj
                else
                    break
                end
            end
        end
        self:setState({
            Part = part,
            Tags = tags,
        })
    end)
    self.inputChangedConn = UserInput.InputChanged:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            self.mouseSunk = gameProcessed
        end
    end)
end

function TooltipView:willUnmount()
    self.steppedConn:Disconnect()
    self.inputChangedConn:Disconnect()
end

function TooltipView:render()
    local props = self.props

    local children = {}

    children.UIListLayout = Roact.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,

        [Roact.Ref] = function(rbx)
            if not rbx then return end
            local function update()
                local cs = rbx.AbsoluteContentSize
                if rbx.Parent and rbx.Parent.Parent then
                    rbx.Parent.Parent.Size = UDim2.new(0, 200, 0, cs.y)
                end
            end
            rbx:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
            update()
        end
    })

    children.ObjectDesc = Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1.0,
        LayoutOrder = 0,
    }, {
        UIListLayout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 4),
        }),
        Margin = Roact.createElement("Frame", {
            Size = UDim2.new(0, 10, 1, 0),
            BackgroundTransparency = 1.0,
        }),
        InstanceClass = Roact.createElement(TextLabel, {
            Text = self.state.Part and self.state.Part.ClassName or "",
            LayoutOrder = 1,
            TextColor3 = Constants.VeryDarkGrey,
            Font = Enum.Font.SourceSansSemibold,
        }),
        InstanceName = Roact.createElement(TextLabel, {
            Text = self.state.Part and self.state.Part.Name or "",
            LayoutOrder = 2,
            Font = Enum.Font.SourceSansSemibold,
        })
    })

    local tags = self.state.Tags or {}
    table.sort(tags)

    for i = 1, #tags do
        local tag = tags[i]
        local icon = 'computer_error'
        for _,entry in pairs(props.tagData) do
            if entry.Name == tag then
                icon = entry.Icon or icon
                break
            end
        end
        children[tag] = Roact.createElement(Tag, {
            Tag = tag,
            Icon = icon,
        })
    end

    return Roact.createElement(Roact.Portal, {
        target = CoreGui,
    }, {
        TagEditorTooltip = Roact.createElement("ScreenGui", {
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        }, {
            Window = Roact.createElement("Frame", {
                BackgroundTransparency = 1.0,
                Visible = self.state.Part ~= false and props.worldView,

                [Roact.Ref] = function(rbx)
                    if rbx then
                        self.mouseSteppedConn = RunService.RenderStepped:Connect(function()
                            local inset = GuiService:GetGuiInset()
                            local pos = UserInput:GetMouseLocation() - inset + Vector2.new(20, 0)
                            rbx.Position = UDim2.new(0, pos.x, 0, pos.y)
                        end)
                    else
                        self.mouseSteppedConn:Disconnect()
                    end
                end,
            }, {
                HorizontalDivider = Roact.createElement("Frame", {
                    Size = UDim2.new(1, 2, 1, 0),
                    Position = UDim2.new(0, -1, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = TooltipGrey,
                }),
                VerticalDivider = Roact.createElement("Frame", {
                    Size = UDim2.new(1, 0, 1, 2),
                    Position = UDim2.new(0, 0, 0, -1),
                    BorderSizePixel = 0,
                    BackgroundColor3 = TooltipGrey,
                }),
                Container = Roact.createElement("Frame", {
                    ZIndex = 2,
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Constants.White,
                }, children)
            })
        })
    })
end

TooltipView = RoactRodux.connect(function(store)
    local state = store:getState()

    return {
        tagData = state.TagData,
        worldView = state.WorldView,
    }
end)(TooltipView)

return TooltipView
