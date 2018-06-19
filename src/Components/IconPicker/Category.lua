local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local TagManager = require(Modules.Plugin.TagManager)
local Icon = require(Modules.Plugin.Components.Icon)
local TextLabel = require(Modules.Plugin.Components.TextLabel)

local function matchesSearch(term, subject)
	if not term then return true end
	return subject:find(term) ~= nil
end

local function Category(props)
	local children = {}
	children.UIGridLayout = Roact.createElement("UIGridLayout", {
		CellSize = UDim2.new(0, 16, 0, 16),
		CellPadding = UDim2.new(0, 4, 0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,

		[Roact.Ref] = function(rbx)
			if not rbx then return end

			local function update()
				local cs = rbx.AbsoluteContentSize
				if rbx.Parent then
					rbx.Parent.Size = UDim2.new(1, 0, 0, cs.y)
					if rbx.Parent.Parent then
						rbx.Parent.Parent.Size = UDim2.new(1, 0, 0, cs.y + 28)
					end
				end
			end
			update()
			rbx:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
		end
	})

	local numMatched = 0
	for i,icon in pairs(props.Icons) do
		local matches = matchesSearch(props.search, icon)
		if matches then
			numMatched = numMatched + 1
		end
		children[icon] = Roact.createElement(Icon, {
			Name = icon,
			LayoutOrder = i,
			Visible = matches,

			onClick = function(rbx)
				TagManager.Get():SetIcon(props.tagName, icon)
				props.close()
			end,

			onHover = function(value)
				props.onHover(value and icon or nil)
			end,
		})
	end

	return Roact.createElement("Frame", {
		LayoutOrder = props.LayoutOrder,
		BackgroundTransparency = 1.0,
		Visible = numMatched > 0,
	}, {
		Label = Roact.createElement(TextLabel, {
			Text = props.CategoryName,
			Size = UDim2.new(1, 0, 0, 20),
			Font = Enum.Font.SourceSansSemibold,
		}),
		Body = Roact.createElement("Frame", {
			Position = UDim2.new(0, 0, 0, 20),
			BackgroundTransparency = 1.0,
		}, children)
	})
end

return Category
