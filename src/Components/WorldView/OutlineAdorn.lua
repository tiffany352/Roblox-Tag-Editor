local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Util = require(Modules.Plugin.Util)

local function OutlineAdorn(props)
	local children = {}
	if props.AlwaysOnTop then
		children = Util.GenerateOutline({
			Size = if props.Adornee.ClassName == "Attachment"
				then props.Adornee.Parent.Size
				elseif props.Adornee.ClassName == "Model" then props.Adornee:GetExtentsSize()
				else props.Adornee.Size,
			Adornee = if props.Adornee.ClassName == "Attachment" then props.Adornee.Parent else props.Adornee,
			Color3 = props.Color,
		})
	end
	return Roact.createElement("SelectionBox", {
		LineThickness = 0.03,
		Adornee = if props.Adornee.ClassName == "Attachment" then props.Adornee.Parent else props.Adornee,
		Color3 = props.Color,
		Visible = not props.AlwaysOnTop,
	}, children)
end

return OutlineAdorn
