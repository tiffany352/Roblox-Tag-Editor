local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local Constants = require(script.Parent.Parent.Constants)

local function TextLabel(props)
    return Roact.createElement("TextLabel", {
        BackgroundTransparency = 1.0,
        Font = props.Font or Enum.Font.SourceSans,
        TextSize = props.TextSize or 20,
        TextColor3 = props.TextColor3 or Constants.Black,
        Size = props.Size,
        LayoutOrder = props.LayoutOrder,
        Text = props.Text or "<Text Not Set>",
        TextWrapped = props.TextWrapped,
        TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,

        [Roact.Ref] = not props.Size and function(rbx)
            if not rbx then return end

            rbx:GetPropertyChangedSignal("TextBounds"):Connect(function()
                local tb = rbx.TextBounds
                rbx.Size = UDim2.new(0, tb.x, 0, tb.y)
            end)
        end or nil,
    })
end

return TextLabel
