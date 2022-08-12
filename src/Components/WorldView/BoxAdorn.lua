local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Util = require(Modules.Plugin.Util)

local function BoxAdorn(props)
	local children = {}
	if props.AlwaysOnTop then
		children = Util.GenerateOutline({
			Size = if props.Adornee.ClassName == "Attachment"
				then props.Adornee.Parent.Size
				elseif props.Adornee.ClassName == "Model" then props.Adornee:GetExtentsSize()
				else props.Adornee.Size,
			Adornee = if props.Adornee.ClassName == "Attachment" then props.Adornee.Parent else props.Adornee,
			Color3 = props.Color,
			Box = true,
		})
	end
	return Roact.createElement("SelectionBox", {
		LineThickness = 0.03,
		SurfaceTransparency = 0.7,
		SurfaceColor3 = props.Color,
		Adornee = if props.Adornee.ClassName == "Attachment" then props.Adornee.Parent else props.Adornee,
		Color3 = props.Color,
		Visible = not props.AlwaysOnTop,
	}, children)
end

return BoxAdorn
