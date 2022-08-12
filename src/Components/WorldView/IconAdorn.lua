local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Icon = require(Modules.Plugin.Components.Icon)

local SCALE_ONE = 1.5
local SCALE_GRID = 2.0

local function IconAdorn(props)
	local children = {}
	local count = #props.Icon

	local gridSize = math.ceil(math.sqrt(count))
	local width = if count > 1 then SCALE_GRID else SCALE_ONE

	for i = 1, count do
		local x = (i - 1) % gridSize
		local y = math.floor((i - 1) / gridSize)
		local icon = props.Icon[i]
		children[i] = Roact.createElement(Icon, {
			Name = icon,
			Position = UDim2.fromScale(x / gridSize, y / gridSize),
			Size = UDim2.fromScale(1 / gridSize, 1 / gridSize),
			TextScaled = true,
		})
	end
	return Roact.createElement("BillboardGui", {
		Adornee = props.Adornee,
		Size = UDim2.fromScale(width, width),
		AlwaysOnTop = props.AlwaysOnTop,
	}, children)
end

return IconAdorn
