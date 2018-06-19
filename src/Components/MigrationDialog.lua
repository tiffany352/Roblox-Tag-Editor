local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Constants = require(script.Parent.Parent.Constants)
local Actions = require(script.Parent.Parent.Actions)
local ScrollingFrame = require(script.Parent.ScrollingFrame)
local TextLabel = require(script.Parent.TextLabel)

local function MigrationDialog(props)
    if not props.enabled then
        return nil
    end

    return Roact.createElement("ImageButton", {
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 4,
        BackgroundTransparency = 0.5,
        BackgroundColor3 = Constants.Black,
        AutoButtonColor = false,

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
            Window = Roact.createElement("ImageButton", {
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
                    MaxSize = Vector2.new(350, 250),
                }),
                Title = Roact.createElement("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 4),
                    Text = "Migrated Legacy Format",
                    Font = Enum.Font.SourceSansSemibold,
                    TextColor3 = Constants.White,
                    TextSize = 20,
                    BackgroundTransparency = 1.0,
                }),
                Body = Roact.createElement("Frame", {
                    Size = UDim2.new(1, -10, 1, -30),
                    Position = UDim2.new(.5, 0, 1, -5),
                    AnchorPoint = Vector2.new(.5, 1),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Constants.White,
                }, {
                    UIPadding = Roact.createElement("UIPadding", {
                        PaddingTop = UDim.new(0, 10),
                        PaddingBottom = UDim.new(0, 10),
                        PaddingLeft = UDim.new(0, 10),
                        PaddingRight = UDim.new(0, 10),
                    }),
                    Scroll = Roact.createElement(ScrollingFrame, {
                        List = {
                            Padding = UDim.new(0, 8),
                        },
                        Size = UDim2.new(1, 0, 1, -32),
                    }, {
                        Paragraph1 = Roact.createElement(TextLabel, {
                            LayoutOrder = 1,
                            Text = "A tag list from Tag Editor v1 has been detected. Would you like to delete it or keep it?",
                            TextWrapped = true,
                            TextSize = 20,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        }),
                        Paragraph2 = Roact.createElement(TextLabel, {
                            LayoutOrder = 2,
                            Text = "If you or a team member relies on the v1 plugin or tools using its data format, you should probably keep it.",
                            TextWrapped = true,
                            TextSize = 20,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        }),
                        Paragraph3 = Roact.createElement(TextLabel, {
                            LayoutOrder = 3,
                            Text = "If you aren't sure, you may delete it later by navigating to ServerStorage.",
                            TextWrapped = true,
                            TextSize = 20,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        }),
                    }),
                    Keep = Roact.createElement("TextButton", {
                        Text = "Keep",
                        Size = UDim2.new(0, 80, 0, 24),
                        TextSize = 20,
                        Font = Enum.Font.SourceSansBold,
                        BackgroundColor3 = Constants.RobloxBlue,
                        BorderColor3 = Constants.RobloxBlue:lerp(Constants.Black, .3333),
                        Position = UDim2.new(.75, 0, 1, 0),
                        AnchorPoint = Vector2.new(.5, 1),
                        TextColor3 = Constants.White,

                        [Roact.Event.MouseButton1Click] = function(rbx)
                            props.close()
                        end,
                    }),
                    Delete = Roact.createElement("TextButton", {
                        Text = "Delete",
                        Size = UDim2.new(0, 80, 0, 24),
                        TextSize = 20,
                        Font = Enum.Font.SourceSansBold,
                        BackgroundColor3 = Constants.RobloxBlue,
                        BorderColor3 = Constants.RobloxBlue:lerp(Constants.Black, .3333),
                        Position = UDim2.new(.25, 0, 1, 0),
                        AnchorPoint = Vector2.new(.5, 1),
                        TextColor3 = Constants.White,

                        [Roact.Event.MouseButton1Click] = function(rbx)
                            local tl = game:GetService("ServerStorage"):FindFirstChild("TagList")
                            if tl then
                                tl:Destroy()
                            end
                            props.close()
                        end,
                    }),
                })
            })
        })
    })
end

local function mapStateToProps(state)
    return {
        enabled = state.MigrationDialog,
    }
end

local function mapDispatchToProps(dispatch)
    return {
        close = function()
            dispatch(Actions.OpenMigrationDialog(false))
        end,
    }
end

MigrationDialog = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(MigrationDialog)

return MigrationDialog
