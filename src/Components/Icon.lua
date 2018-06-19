local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local Icons = require(script.Parent.Parent.FamFamFam)

local function Icon(props)
	local data = typeof(props.Name) == 'string' and Icons.Lookup(props.Name) or Icons.Lookup("computer_error")
	local newProps = {
		Size = props.Size or UDim2.new(0, 16, 0, 16),
		BackgroundTransparency = props.BackgroundTransparency or 1.0,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,

		[Roact.Event.MouseButton1Click] = props.onClick,

		[Roact.Event.MouseEnter] = function()
			if props.onHover then
				props.onHover(true)
			end
		end,

		[Roact.Event.MouseLeave] = function()
			if props.onHover then
				props.onHover(false)
			end
		end,
	}

	for k,v in pairs(data) do
		newProps[k] = v
	end

	for k,v in pairs(props) do
		if k ~= "Name" and k ~= "onClick" and k ~= 'onHover' then
			newProps[k] = v
		end
	end

	return Roact.createElement(props.onClick and "ImageButton" or "ImageLabel", newProps)
end

return Icon
