local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local IconCategories = require(Modules.Plugin.IconCategories)
local Category = require(script.Parent.Category)
local ScrollingFrame = require(script.Parent.Parent.ScrollingFrame)

local function IconsPage(props)
	local children = {}
	local cats = {}
	for name, icons in pairs(IconCategories) do
		cats[#cats + 1] = {
			Name = name,
			Icons = icons,
		}
	end

	table.sort(cats, function(a, b)
		local aIsUncat = a.Name == "Uncategorized" and 1 or 0
		local bIsUncat = b.Name == "Uncategorized" and 1 or 0

		if aIsUncat < bIsUncat then
			return true
		end
		if bIsUncat < aIsUncat then
			return false
		end

		return a.Name < b.Name
	end)

	for i = 1, #cats do
		local name = cats[i].Name
		local icons = cats[i].Icons
		children[name] = Roact.createElement(Category, {
			LayoutOrder = i,
			CategoryName = name,
			Icons = icons,
			tagName = props.tagName,
			search = props.search,
			close = props.closeFunc,
			onHover = props.onHoverFunc,
		})
	end

	children.UIPadding = Roact.createElement("UIPadding", {
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
	})

	return Roact.createElement(ScrollingFrame, {
		Size = UDim2.fromScale(1, 1),
		List = true,
	}, children)
end

return IconsPage
