local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local function HighlightAdorn(props)
	return Roact.createElement("Highlight", {
		FillTransparency = 0.5,
		Adornee = props.Adornee.ClassName == "Attachment" and props.Adornee.Parent or props.Adornee,
		FillColor = props.Color,
		OutlineColor = props.Color,
		DepthMode = props.AlwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
	})
end

return HighlightAdorn
