local TextService = game:GetService("TextService")

local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local function TextLabel(props)
	return Roact.createElement("TextLabel", {
		LayoutOrder = props.LayoutOrder,
		Position = props.Position,
		Size = props.Size or props.TextWrapped and UDim2.new(1, 0, 0, 0) or nil,
		BackgroundTransparency = 1.0,

		Font = props.Font or Enum.Font.SourceSans,
		TextSize = props.TextSize or 20,
		TextColor3 = props.TextColor3 or Color3.fromRGB(0, 0, 0),
		Text = props.Text or "<Text Not Set>",
		TextWrapped = props.TextWrapped,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = props.TextYAlignment,

		[Roact.Ref] = not props.Size and function(rbx)
			if not rbx then return end

			if props.TextWrapped then
				local function update()
					local width = rbx.AbsoluteSize.x
					local tb = TextService:GetTextSize(rbx.Text, rbx.TextSize, rbx.Font, Vector2.new(width - 2, 100000))
					rbx.Size = UDim2.new(1, 0, 0, tb.y)
				end
				rbx:GetPropertyChangedSignal("TextBounds"):Connect(update)
				local oldX = rbx.AbsoluteSize.x
				rbx:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					if oldX ~= rbx.AbsoluteSize.x then
						oldX = rbx.AbsoluteSize.x
						update()
					end
				end)
				rbx:GetPropertyChangedSignal("Parent"):Connect(update)
				update()
			else
				local function update()
					local tb = rbx.TextBounds
					rbx.Size = UDim2.new(props.Width or UDim.new(0, tb.x), UDim.new(0, tb.y))
				end
				rbx:GetPropertyChangedSignal("TextBounds"):Connect(update)
				update()
			end
		end or nil,
	})
end

return TextLabel
