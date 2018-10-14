local TextService = game:GetService("TextService")

local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Constants = require(Modules.Plugin.Constants)

local function TextLabel(props)
	local update

	if props.TextWrapped then
		function update(rbx)
			local width = rbx.AbsoluteSize.x
			local tb = TextService:GetTextSize(rbx.Text, rbx.TextSize, rbx.Font, Vector2.new(width - 2, 100000))
			rbx.Size = UDim2.new(1, 0, 0, tb.y)
		end
	else
		function update(rbx)
			local tb = rbx.TextBounds
			rbx.Size = UDim2.new(props.Width or UDim.new(0, tb.x), UDim.new(0, tb.y))
		end
	end

	local autoSize = not props.Size

	return Roact.createElement("TextLabel", {
		BackgroundTransparency = 1.0,
		Font = props.Font or Enum.Font.SourceSans,
		TextSize = props.TextSize or 20,
		TextColor3 = props.TextColor3 or Constants.Black,
		Size = props.Size or props.TextWrapped and UDim2.new(1, 0, 0, 0) or nil,
		Position = props.Position,
		LayoutOrder = props.LayoutOrder,
		Text = props.Text or "<Text Not Set>",
		TextWrapped = props.TextWrapped,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = props.TextYAlignment,

		[Roact.Change.TextBounds] = autoSize and update or nil,
		[Roact.Change.AbsoluteSize] = autoSize and update or nil,
		[Roact.Change.Parent] = autoSize and update or nil,
	})
end

return TextLabel
