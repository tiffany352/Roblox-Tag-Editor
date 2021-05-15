local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local function BoxAdorn(props)
	if props.Adornee.ClassName == "Attachment" then
		return Roact.createElement("BoxHandleAdornment", {
			Adornee = props.Adornee.Parent,
			CFrame = props.Adornee.CFrame,
			Size = Vector3.new(1.2, 1.2, 1.2),
			Transparency = 0.3,
			Color3 = props.Color,
		})
	end
	return Roact.createElement("SelectionBox", {
		LineThickness = 0.03,
		SurfaceTransparency = 0.7,
		SurfaceColor3 = props.Color,
		Adornee = props.Adornee,
		Color3 = props.Color,
	})
end

return BoxAdorn
