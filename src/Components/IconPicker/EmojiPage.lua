local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Category = require(script.Parent.Category)
local ScrollingFrame = require(script.Parent.Parent.ScrollingFrame)
local RadioButton = require(Modules.Plugin.Components.RadioButton)
local Emoji = require(Modules.Plugin.Emoji)

local labels = {
	[2] = "\u{1F3FB}",
	[3] = "\u{1F3FC}",
	[4] = "\u{1F3FD}",
	[5] = "\u{1F3FE}",
	[6] = "\u{1F3FF}",
}

local function ModifierButton(props)
	return Roact.createElement(RadioButton, {
		LayoutOrder = props.modifier or 0,
		Text = labels[props.modifier] or "❌",
		selected = props.currentMod == props.modifier,
		onSelect = function()
			props.onSelect(props.modifier)
		end,
	})
end

local EmojiPage = Roact.PureComponent:extend("EmojiPage")

function EmojiPage:init()
	self.state = {
		modifier = nil,
	}

	self._onSelect = function(mod)
		self:setState({
			modifier = mod or Roact.None,
		})
	end
end

function EmojiPage:render()
	local props = self.props
	local children = {}
	local cats = Emoji.getCategories()
	local mod = self.state.modifier

	for i = 1, #cats do
		local name = cats[i].name
		local items = {}
		for _, value in pairs(cats[i].items) do
			if mod and value.alts and value.alts[mod] then
				table.insert(items, "emoji:" .. value.name .. mod)
			else
				table.insert(items, "emoji:" .. value.name)
			end
		end
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

	--[[
		🏻 U+1F3FB Emoji Modifier Fitzpatrick Type-1-2
		🏼 U+1F3FC Emoji Modifier Fitzpatrick Type-3
		🏽 U+1F3FD Emoji Modifier Fitzpatrick Type-4
		🏾 U+1F3FE Emoji Modifier Fitzpatrick Type-5
		🏿 U+1F3FF Emoji Modifier Fitzpatrick Type-6
	]]

	children.UIPadding = Roact.createElement("UIPadding", {
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
	})

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1.0,
	}, {
		SkinToneModifier = Roact.createElement("Frame", {
			Size = UDim2.new(1, -8, 0, 20),
			Position = UDim2.fromOffset(4, 4),
			BackgroundTransparency = 1.0,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 5),
			}),
			None = Roact.createElement(ModifierButton, {
				modifier = nil,
				currentMod = mod,
				onSelect = self._onSelect,
			}),
			Type2 = Roact.createElement(ModifierButton, {
				modifier = 2,
				currentMod = mod,
				onSelect = self._onSelect,
			}),
			Type3 = Roact.createElement(ModifierButton, {
				modifier = 3,
				currentMod = mod,
				onSelect = self._onSelect,
			}),
			Type4 = Roact.createElement(ModifierButton, {
				modifier = 4,
				currentMod = mod,
				onSelect = self._onSelect,
			}),
			Type5 = Roact.createElement(ModifierButton, {
				modifier = 5,
				currentMod = mod,
				onSelect = self._onSelect,
			}),
			Type6 = Roact.createElement(ModifierButton, {
				modifier = 6,
				currentMod = mod,
				onSelect = self._onSelect,
			}),
		}),
		Scroll = Roact.createElement(ScrollingFrame, {
			Size = UDim2.new(1, 0, 1, -28),
			Position = UDim2.new(0, 0, 0, 28),
			List = true,
		}, children),
	})
end

return EmojiPage
