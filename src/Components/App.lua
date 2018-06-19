local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local TagList = require(script.Parent.TagList)
local TagSearch = require(script.Parent.TagSearch)
local TagMenu = require(script.Parent.TagMenu)
local IconPicker = require(script.Parent.IconPicker)
local ColorPicker = require(script.Parent.ColorPicker)
local WorldView = require(script.Parent.WorldView)
local InstanceView = require(script.Parent.InstanceView)
local GroupPicker = require(script.Parent.GroupPicker)
local TooltipView = require(script.Parent.TooltipView)
local MigrationDialog = require(script.Parent.MigrationDialog)

return function(props)
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	}, {
		Container = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1.0,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,

				-- hack :(
				[Roact.Ref] = function(rbx)
					if rbx then
						spawn(function()
							wait()
							wait()
							rbx:ApplyLayout()
						end)
					end
				end,
			}),

			UIPadding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
			}),

			TagList = Roact.createElement(TagList, {
				Size = UDim2.new(1, 0, 1, -40),
			}),
			TagSearch = Roact.createElement(TagSearch, {
				Size = UDim2.new(1, 0, 0, 40),
			}),
		}),
		InstanceView = Roact.createElement(InstanceView),
		GroupPicker = Roact.createElement(GroupPicker),

		TagMenu = Roact.createElement(TagMenu),
		IconPicker = Roact.createElement(IconPicker),
		ColorPicker = Roact.createElement(ColorPicker),
		WorldView = Roact.createElement(WorldView),
		TooltipView = Roact.createElement(TooltipView),
		MigrationDialog = Roact.createElement(MigrationDialog),
	})
end
