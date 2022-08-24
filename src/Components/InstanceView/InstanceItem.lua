local Selection = game:GetService("Selection")
local UserInputService = game:GetService("UserInputService")

local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local ClassIcon = require(Modules.Plugin.Components.ClassIcon)
local ThemedTextLabel = require(Modules.Plugin.Components.ThemedTextLabel)
local ListItemChrome = require(Modules.Plugin.Components.ListItemChrome)
local Icon = require(Modules.Plugin.Components.Icon)
local StudioThemeAccessor = require(Modules.Plugin.Components.StudioThemeAccessor)
local TagManager = require(Modules.Plugin.TagManager)

local InstanceItem = Roact.PureComponent:extend("InstanceItem")

function InstanceItem:render()
	local props = self.props

	local state = "Default"

	if props.Selected then
		state = "Selected"
	elseif self.state.hover then
		state = "Hover"
	end

	return Roact.createElement(ListItemChrome, {
		LayoutOrder = props.LayoutOrder,
		state = state,

		mouseEnter = function(_rbx)
			self:setState({
				hover = true,
			})
		end,

		mouseLeave = function(_rbx)
			self:setState({
				hover = false,
			})
		end,

		leftClick = function(_rbx)
			local sel = Selection:Get()
			local alreadySelected = false
			for _, instance in pairs(sel) do
				if instance == props.Instance then
					alreadySelected = true
					break
				end
			end
			if alreadySelected then
				if #sel > 1 then
					-- select only this
					Selection:Set({ props.Instance })
				else
					-- deselect
					local baseSel = {}
					for _, instance in pairs(sel) do
						if instance ~= props.Instance then
							baseSel[#baseSel + 1] = instance
						end
					end
					Selection:Set(baseSel)
				end
			else
				-- select
				local baseSel = {}
				local function isDown(key)
					return UserInputService:IsKeyDown(Enum.KeyCode[key])
				end
				if isDown("LeftControl") or isDown("RightControl") or isDown("LeftShift") or isDown("RightShift") then
					baseSel = sel
				end
				baseSel[#baseSel + 1] = props.Instance
				Selection:Set(baseSel)
			end
		end,
	}, {
		Container = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1.0, 0.0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1.0,
		}, {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
			}),
			UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
			}),
			InstanceClass = Roact.createElement(ClassIcon, {
				ClassName = props.ClassName,
			}),
			InstanceName = Roact.createElement(ThemedTextLabel, {
				state = state,
				Text = props.Name,
				LayoutOrder = 2,
			}),
			Path = Roact.createElement(ThemedTextLabel, {
				Font = Enum.Font.SourceSansItalic,
				state = state,
				Text = props.Path,
				LayoutOrder = 3,
				TextSize = 16,
			}),
			Delete = Roact.createElement(Icon, {
				Name = "cancel",
				Position = UDim2.new(1, -4, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				LayoutOrder = -1,
				ZIndex = 10,
				onClick = function()
					Selection:Set({ props.Instance })
					TagManager.Get():SetTag(props.TagName, false)
					Selection:Set({})
				end,
			}),
			Divider = StudioThemeAccessor.withTheme(function(theme: StudioTheme)
				return Roact.createElement("Frame", {
					Size = UDim2.new(0, 1, 0, 26),
					Position = UDim2.fromScale(0, 1),
					AnchorPoint = Vector2.new(0, 1),
					BorderSizePixel = 0,
					BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
				})
			end),
		}),
	})
end

return InstanceItem
