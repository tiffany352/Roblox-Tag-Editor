local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local function HighlightAdorn(props)
	return Roact.createElement("Highlight", {
		FillTransparency = 0.7,
		Adornee = if props.Adornee.ClassName == "Attachment" then props.Adornee.Parent else props.Adornee,
		FillColor = props.Color,
		OutlineColor = props.Color,
		DepthMode = if props.AlwaysOnTop then Enum.HighlightDepthMode.AlwaysOnTop else Enum.HighlightDepthMode.Occluded,
	})
end

return HighlightAdorn
