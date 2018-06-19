local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Constants = require(Modules.Plugin.Constants)

local Item = require(script.Parent.Item)

local function Checkbox(props)
	local newProps = {
		LeftAlign = true,

		[Roact.Event.MouseButton1Click] = function(rbx)
			if props.onSubmit then
				props.onSubmit(not props.Value)
			end
		end,
	}
	local blacklist = {
		onSubmit = true,
		Value = true,
	}
	for k,v in pairs(props) do
		if not blacklist[k] then
			newProps[k] = v
		end
	end

	return Roact.createElement(Item, newProps, {
		Checkbox = Roact.createElement("ImageLabel", {
			Image = 'rbxasset://textures/ui/LuaChat/9-slice/input-default.png',
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(4, 4, 4, 4),
			Size = UDim2.new(0, 24, 0, 24),
			BackgroundTransparency = 1.0,
			BorderSizePixel = 1,
			BackgroundColor3 = Constants.White,
			BorderColor3 = Constants.DarkGrey,
			Position = UDim2.new(1, -24, 0.5, 0),
			AnchorPoint = Vector2.new(.5, .5),
		}, {
			Checked = Roact.createElement("ImageLabel", {
				Image = 'rbxasset://textures/ui/LuaChat/9-slice/input-default.png',
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(4, 4, 4, 4),
				ImageColor3 = Constants.RobloxBlue,
				BackgroundTransparency = 1.0,
				BorderSizePixel = 0,
				BackgroundColor3 = Constants.RobloxBlue,
				Visible = props.Value,
				Size = UDim2.new(1, -4, 1, -4),
				Position = UDim2.new(.5, 0, .5, 0),
				AnchorPoint = Vector2.new(.5, .5),
			})
		})
	})
end

return Checkbox
