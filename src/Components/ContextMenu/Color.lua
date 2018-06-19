local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local Item = require(script.Parent.Item)

local function Color(props)
	local newProps = {
		LeftAlign = props.Color ~= nil,
	}
	for k,v in pairs(props) do
		if k ~= "Color" and k ~= "LeftAlign" then
			newProps[k] = v
		end
	end
	return Roact.createElement(Item, newProps, {
		Color = Roact.createElement("ImageLabel", {
			Visible = props.Color ~= nil,
			Position = UDim2.new(1, -24, .5, -1),
			Size = UDim2.new(0, 30, 0, 30),
			AnchorPoint = Vector2.new(.5, .5),
			BackgroundTransparency = 1.0,
			Image = "rbxasset://textures/ui/btn_newWhite.png",
			ImageColor3 = props.Color,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(10, 10, 10, 10),
		})
	})
end

return Color
