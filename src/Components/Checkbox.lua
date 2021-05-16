local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local StudioThemeAccessor = require(script.Parent.StudioThemeAccessor)

local function Checkbox(props)
	local state = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		state = Enum.StudioStyleGuideModifier.Disabled
	elseif props.Checked then
		state = Enum.StudioStyleGuideModifier.Selected
	end

	return StudioThemeAccessor.withTheme(function(theme: StudioTheme)
		return Roact.createElement("ImageButton", {
			Size = UDim2.new(0, 20, 0, 20),
			BackgroundColor3 = theme:GetColor("CheckedFieldBackground", state),
			BorderColor3 = theme:GetColor("CheckedFieldBorder", state),
			AutoButtonColor = false,
			Position = props.Position,
			AnchorPoint = props.AnchorPoint,
			LayoutOrder = props.LayoutOrder,
			[Roact.Event.MouseButton1Click] = props.leftClick,
		}, {
			Check = Roact.createElement("ImageLabel", {
				Size = UDim2.new(0, 16, 0, 12),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Visible = not not props.Checked,
				ImageColor3 = theme:GetColor("CheckedFieldIndicator", state),
				Image = props.Checked == true and "rbxassetid://2617163557" or "rbxassetid://6826221991",
			}),
		})
	end)
end

return Checkbox
