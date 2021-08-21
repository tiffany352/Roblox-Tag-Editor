local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Icon = require(Modules.Plugin.Components.Icon)
local ThemedTextLabel = require(Modules.Plugin.Components.ThemedTextLabel)

local SIZE = UDim2.new(0, 48, 0, 48)

local function Preview(props)
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
		Position = props.Position,
		BackgroundTransparency = 1.0,
		AnchorPoint = Vector2.new(0, 0),
	}, {
		IconName = Roact.createElement(ThemedTextLabel, {
			TextSize = 14,
			Size = UDim2.new(1, -56, 0, 20 * 3),
			Position = UDim2.new(0, 56, 0, 32),
			TextWrapped = true,
			Text = props.icon or "",
			TextYAlignment = Enum.TextYAlignment.Top,
		}),
		Preview = Roact.createElement(Icon, {
			Name = props.icon or "tag_green",
			Size = SIZE,
			TextSize = 48,
		}),
	})
end

local function mapStateToProps(state)
	local icon = state.HoveredIcon

	if icon == nil then
		local tagName = state.IconPicker

		for _, tag in pairs(state.TagData) do
			if tag.Name == tagName then
				icon = tag.Icon
				break
			end
		end
	end
	return {
		icon = icon,
	}
end

Preview = RoactRodux.connect(mapStateToProps)(Preview)

return Preview
