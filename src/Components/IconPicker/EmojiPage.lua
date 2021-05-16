local HttpService = game:GetService("HttpService")

local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Category = require(script.Parent.Category)
local ScrollingFrame = require(script.Parent.Parent.ScrollingFrame)

local cached = nil
local function getData()
	if cached then
		return cached
	end

	local orderingsStr = require(script.Parent.EmojiOrderings)
	local orderings = HttpService:JSONDecode(orderingsStr)

	local groups = {}
	for _, entry in pairs(orderings) do
		local emojiList = {}
		for _, emoji in pairs(entry.emoji) do
			local text = utf8.char(table.unpack(emoji.base))
			-- local alternates = {}
			-- for _, alt in pairs(emoji.alternates) do
			-- 	table.insert(alternates, utf8.char(table.unpack(alt)))
			-- end
			table.insert(emojiList, "emoji:" .. text)
		end
		table.insert(groups, {
			name = entry.group,
			items = emojiList,
		})
	end
	cached = groups

	return cached
end

local function EmojiPage(props)
	local children = {}
	local cats = getData()

	for i = 1, #cats do
		local name = cats[i].name
		local items = cats[i].items
		children[name] = Roact.createElement(Category, {
			LayoutOrder = i,
			CategoryName = name,
			Icons = items,
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

return EmojiPage
