local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Icon = require(Modules.Plugin.Components.Icon)

local function IconAdorn(props)
	local children = {}
	if #props.Icon > 1 then
		children.UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(2 / 16, 0),
		})
	end
	for i = 1, #props.Icon do
		local icon = props.Icon[i]
		children[i] = Roact.createElement(Icon, {
			Name = icon,
			Size = UDim2.new(1 / #props.Icon, 0, 1, 0),
			TextScaled = true,
		})
	end
	return Roact.createElement("BillboardGui", {
		Adornee = props.Adornee,
        Size = UDim2.fromScale(1.5, 1.5),
        SizeOffset = Vector2.new(0.5, 0.5),
        StudsOffset = Vector3.new(-0.75, -0.75, 0.0),
        AlwaysOnTop = props.AlwaysOnTop,
	}, children)
end

return IconAdorn
