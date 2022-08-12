local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local TagManager = require(Modules.Plugin.TagManager)
local Icon = require(Modules.Plugin.Components.Icon)
local ThemedTextLabel = require(Modules.Plugin.Components.ThemedTextLabel)

local function matchesSearch(term, subject)
	if not term then
		return true
	end
	return subject:find(term) ~= nil
end

local Category = Roact.PureComponent:extend("Category")

function Category:render()
	local cellSize = 24
	local props = self.props
	local children = {}
	children.UIGridLayout = Roact.createElement("UIGridLayout", {
		CellSize = UDim2.new(0, cellSize, 0, cellSize),
		CellPadding = UDim2.new(0, 0, 0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local numMatched = 0
	for i, icon in pairs(props.Icons) do
		local matches = matchesSearch(props.search, icon)
		if matches then
			numMatched = numMatched + 1
		end
		children[icon] = Roact.createElement("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Visible = matches,
			LayoutOrder = i,
			[Roact.Event.MouseButton1Click] = function(_rbx)
				TagManager.Get():SetIcon(props.tagName, icon)
				props.close()
			end,

			[Roact.Event.MouseEnter] = function(rbx)
				self._enteredButton = rbx
				props.onHover(icon)
			end,

			[Roact.Event.MouseLeave] = function(rbx)
				if self._enteredButton == rbx then
					props.onHover(nil)
					self._enteredButton = nil
				end
			end,
		}, {
			Icon = Roact.createElement(Icon, {
				Name = icon,
				Size = UDim2.new(0, 16, 0, 16),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
			}),
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = props.LayoutOrder,
		BackgroundTransparency = 1.0,
		Visible = numMatched > 0,
		AutomaticSize = Enum.AutomaticSize.Y,
	}, {
		Label = Roact.createElement(ThemedTextLabel, {
			textKey = "Category_" .. props.CategoryName,
			Size = UDim2.new(1, 0, 0, 20),
			Font = Enum.Font.SourceSansSemibold,
		}),
		Body = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 20),
			BackgroundTransparency = 1.0,
			AutomaticSize = Enum.AutomaticSize.Y,
		}, children),
	})
end

return Category
