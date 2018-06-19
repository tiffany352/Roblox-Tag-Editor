local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Constants = require(Modules.Plugin.Constants)
local Icon = require(Modules.Plugin.Components.Icon)
local TextLabel = require(Modules.Plugin.Components.TextLabel)
local ScrollingFrame = require(Modules.Plugin.Components.ScrollingFrame)

local InstanceItem = require(script.Parent.InstanceItem)

local function InstanceList(props)
	local children = {}

	children.UIPadding = Roact.createElement("UIPadding", {
		PaddingTop = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 2),
		PaddingLeft = UDim.new(0, 2),
		PaddingRight = UDim.new(0, 2),
	})

	local parts = props.parts
	local selected = props.selected

	children.InstanceCount = Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		LayoutOrder = -1,
		BackgroundTransparency = 1.0,
	}, {
		Label = Roact.createElement(TextLabel, {
			Position = UDim2.new(0, 16, 0, 4),
			TextSize = 24,
			Text = string.format("Instance List (%d instances)", #parts),
			TextColor3 = Constants.Black,
			Font = Enum.Font.SourceSansLight,
		}),
		Divider = Roact.createElement("Frame", {
			Size = UDim2.new(1, -20, 0, 2),
			AnchorPoint = Vector2.new(0.5, 1.0),
			Position = UDim2.new(0.5, 0, 1, -2),
			BorderSizePixel = 0,
			BackgroundColor3 = Constants.LightGrey,
		})
	})

	for i,entry in pairs(parts) do
		local part = entry.instance
		local id = entry.id
		local path = entry.path

		children[id] = Roact.createElement(InstanceItem, {
			LayoutOrder = i,
			Name = part.Name,
			ClassName = part.ClassName,
			Path = path,
			Instance = part,
			Selected = selected[part] ~= nil,
		})
	end

	return Roact.createElement("ImageButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Constants.White,
		ZIndex = 10,
		Visible = props.tagName ~= nil,
		AutoButtonColor = false,
	}, {
		Topbar = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = Constants.RobloxBlue,
			BorderSizePixel = 0,
		}, {
			Back = Roact.createElement("TextButton", {
				Size = UDim2.new(0, 48, 0, 32),
				Text = "Back",
				TextSize = 20,
				Font = Enum.Font.SourceSansBold,
				BackgroundTransparency = 1.0,
				TextColor3 = Constants.White,

				[Roact.Event.MouseButton1Click] = function(rbx)
					props.close()
				end,
			}),
			Title = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1.0,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4),
				}),
				Icon = Roact.createElement(Icon, {
					Name = props.tagIcon,
					LayoutOrder = 1,
				}),
				Label = Roact.createElement(TextLabel, {
					Text = tostring(props.tagName),
					LayoutOrder = 2,
					TextColor3 = Constants.White,
					Font = Enum.Font.SourceSansSemibold,
				}),
			})
		}),
		Body = Roact.createElement(ScrollingFrame, {
			Size = UDim2.new(1, 0, 1, -32),
			Position = UDim2.new(0, 0, 0, 32),
			List = true,
		}, children)
	})
end

return InstanceList
