local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local IconPreview = require(script.Parent.IconPreview)
local ThemedTextLabel = require(Modules.Plugin.Components.ThemedTextLabel)

local SIZE = UDim2.new(0, 48, 0, 48)

local function Preview(props)
	local child
	local icon = props.icon
	if icon and icon:sub(1, 6) == "emoji:" then
		child = Roact.createElement("TextLabel", {
			Size = SIZE,
			TextSize = 48,
			Text = icon:sub(7, -1),
			Font = Enum.Font.SourceSans,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1.0,
		})
	elseif icon and icon:sub(1, 13) == "rbxassetid://" then
		child = Roact.createElement("ImageLabel", {
			Size = SIZE,
			BackgroundTransparency = 1.0,
			Image = icon,
		})
	else
		child = Roact.createElement(IconPreview, {
			Size = SIZE,
			icon = icon,
		})
	end

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
			Text = icon or "",
			TextYAlignment = Enum.TextYAlignment.Top,
		}),
		Preview = child,
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
