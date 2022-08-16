local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local ThemedTextLabel = require(Modules.Plugin.Components.ThemedTextLabel)
local ScrollingFrame = require(Modules.Plugin.Components.ScrollingFrame)
local Page = require(Modules.Plugin.Components.Page)

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
		Label = Roact.createElement(ThemedTextLabel, {
			Position = UDim2.new(0, 16, 0, 4),
			TextSize = 24,
			textKey = "InstanceView_ListTitle",
			textArgs = {
				Count = #parts,
			},
			Font = Enum.Font.SourceSansLight,
		}),
	})

	for i, entry in pairs(parts) do
		local part = entry.instance
		local id = entry.id
		local path = entry.path

		children[id] = Roact.createElement(InstanceItem, {
			LayoutOrder = i,
			Name = part.Name,
			ClassName = part.ClassName,
			TagName = props.tagName,
			Path = path,
			Instance = part,
			Selected = selected[part] ~= nil,
		})
	end

	return Roact.createElement(Page, {
		visible = props.tagName ~= nil,
		titleIcon = props.tagIcon,
		titleKey = "InstanceView_PageTitle",
		titleArgs = {
			Tag = tostring(props.tagName),
		},

		close = props.close,
	}, {
		Body = Roact.createElement(ScrollingFrame, {
			Size = UDim2.new(1, 0, 1, 0),
			List = {
				Padding = UDim.new(0, 1),
			},
		}, children),
	})
end

return InstanceList
