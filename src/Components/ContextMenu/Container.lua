local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Constants = require(Modules.Plugin.Constants)

local function Container(props)
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
		Window = Roact.createElement("ImageLabel", {
			Size = UDim2.new(.95, 0, .95, 0),
			AnchorPoint = Vector2.new(.5, 1),
			Position = UDim2.new(.5, 0, 1, -10),
			BackgroundTransparency = 1.0,
		}, children)
	})
end

return Container
