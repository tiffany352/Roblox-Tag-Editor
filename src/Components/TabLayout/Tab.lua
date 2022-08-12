local TextService = game:GetService("TextService")

local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local StudioThemeAccessor = require(Modules.Plugin.Components.StudioThemeAccessor)
local tr = require(script.Parent.Parent.Parent.tr)

local function Tab(props)
	local state = props.selected and Enum.StudioStyleGuideModifier.Selected or Enum.StudioStyleGuideModifier.Default

	local text = tr(props.name)

	-- Ugly workaround due to an AutomaticSize bug.
	local width = TextService:GetTextSize(text, 16, Enum.Font.SourceSans, Vector2.new()).X

	return StudioThemeAccessor.withTheme(function(theme: StudioTheme)
		return Roact.createElement("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			-- Size = UDim2.fromScale(0, 1),
			-- AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, width + 18, 1, 0),
			LayoutOrder = props.index,
		}, {
			Label = Roact.createElement("TextButton", {
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Tab, state),
				BorderSizePixel = 0,
				Text = text,
				AutoLocalize = false,
				AutoButtonColor = false,
				Size = UDim2.fromScale(1, 1),
				-- AutomaticSize = Enum.AutomaticSize.X,
				Font = Enum.Font.SourceSans,
				TextSize = 16,
				TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),

				[Roact.Event.Activated] = function(_rbx)
					props.onSelect(props.name)
				end,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingBottom = UDim.new(0, props.selected and 1 or 0),
				}),
			}),
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 1),
				PaddingRight = UDim.new(0, 1),
				PaddingTop = UDim.new(0, 1),
				PaddingBottom = UDim.new(0, props.selected and 0 or 1),
			}),
		})
	end)
end

return Tab
