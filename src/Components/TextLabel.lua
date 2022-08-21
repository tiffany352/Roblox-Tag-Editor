local TextService = game:GetService("TextService")

local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local tr = require(script.Parent.Parent.tr)

local function TextLabel(props)
	local update

	if props.TextWrapped then
		function update(rbx)
			if not rbx then
				return
			end
			local width = rbx.AbsoluteSize.x
			local tb = TextService:GetTextSize(rbx.Text, rbx.TextSize, rbx.Font, Vector2.new(width - 2, 100000))
			rbx.Size = UDim2.new(1, 0, 0, tb.y)

			if props.Ref then
				props.Ref(rbx)
			end
		end
	else
		function update(rbx)
			if not rbx then
				return
			end
			local tb = TextService:GetTextSize(rbx.Text, rbx.TextSize, rbx.Font, Vector2.new(100000, 100000))
			rbx.Size = UDim2.new(props.Width or UDim.new(0, tb.x), UDim.new(0, tb.y))

			if props.Ref then
				props.Ref(rbx)
			end
		end
	end

	local autoSize = not props.Size

	return Roact.createElement("TextLabel", {
		LayoutOrder = props.LayoutOrder,
		Position = props.Position,
		Size = props.Size or props.TextWrapped and UDim2.new(1, 0, 0, 0) or nil,
		AutomaticSize = props.AutomaticSize,
		BackgroundTransparency = 1.0,

		Font = props.Font or Enum.Font.SourceSans,
		TextSize = props.TextSize or 20,
		TextColor3 = props.TextColor3 or Color3.fromRGB(0, 0, 0),
		Text = if props.textKey then tr(props.textKey, props.textArgs) else props.Text or "<Text Not Set>",
		AutoLocalize = props.textKey == nil,
		RichText = props.RichText,
		TextWrapped = props.TextWrapped,
		TextTruncate = props.TextTruncate,
		TextScaled = props.TextScaled,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = props.TextYAlignment,

		[Roact.Ref] = autoSize and update or nil,
		[Roact.Change.TextBounds] = autoSize and update or nil,
		[Roact.Change.AbsoluteSize] = autoSize and update or nil,
		[Roact.Change.Parent] = autoSize and update or nil,
	}, {
		props.TextScaled and Roact.createElement("UITextSizeConstraint", {
			MaxTextSize = props.TextSize or 20,
		}),
	})
end

return TextLabel
