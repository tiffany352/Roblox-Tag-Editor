local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Actions = require(Modules.Plugin.Actions)
local IconCategories = require(Modules.Plugin.IconCategories)

local Page = require(script.Parent.Page)
local Search = require(script.Parent.Search)
local ScrollingFrame = require(script.Parent.ScrollingFrame)
local Category = require(script.Category)
local IconPreview = require(script.IconPreview)
local ThemeAccessor = require(script.Parent.ThemeAccessor)

local IconPicker = Roact.Component:extend("IconPicker")

function IconPicker:init()
	self.closeFunc = function()
		self.props.close()
	end
	self.onHoverFunc = function(icon)
		self.props.setHoveredIcon(icon)
	end
end

function IconPicker:shouldUpdate(newProps)
	return self.props.tagName ~= newProps.tagName or self.props.search ~= newProps.search
end

function IconPicker:render()
	local props = self.props
	local children = {}
	local cats = {}
	for name,icons in pairs(IconCategories) do
		cats[#cats+1] = {
			Name = name,
			Icons = icons,
		}
	end

	table.sort(cats, function(a,b)
		local aIsUncat = a.Name == 'Uncategorized' and 1 or 0
		local bIsUncat = b.Name == 'Uncategorized' and 1 or 0

		if aIsUncat < bIsUncat then return true end
		if bIsUncat < aIsUncat then return false end

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
			close = self.closeFunc,
			onHover = self.onHoverFunc,
		})
	end

	children.UIPadding = Roact.createElement("UIPadding", {
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
	})

	return Roact.createElement(Page, {
		visible = props.tagName ~= nil,
		title = tostring(props.tagName).." - Select an Icon",
		titleIcon = props.tagIcon,

		close = function()
			props.close()
		end,
	}, {
		IconList = Roact.createElement(ScrollingFrame, {
			Size = UDim2.new(1, -80, 1, -40),
			Position = UDim2.new(0, 0, 0, 40),
			List = true,
		}, children),
		Search = Roact.createElement(Search, {
			Size = UDim2.new(1, -80, 0, 40),

			term = props.search,
			setTerm = function(term)
				props.setTerm(term)
			end,
		}),
		Sidebar = ThemeAccessor.withTheme(function(theme)
			return Roact.createElement("Frame", {
				BackgroundColor3 = theme:get("IconPickerSidebar", "BackgroundColor3"),
				BorderColor3 = theme:get("IconPickerSidebar", "BorderColor3"),
				Size = UDim2.new(0, 80, 1, 0),
				Position = UDim2.new(1, -80, 0, 0),
			}, {
				Preview = Roact.createElement(IconPreview, {
					Position = UDim2.new(1, -8, 0, 8),
				}),
			})
		end),
	})
end

local function mapStateToProps(state, props)
	local tagName = state.IconPicker
	local tagIcon
	for _,tag in pairs(state.TagData) do
		if tag.Name == tagName then
			tagIcon = tag.Icon
			break
		end
	end

	return {
		tagName = tagName,
		tagIcon = tagIcon,
		search = state.IconSearch,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		close = function()
			dispatch(Actions.ToggleIconPicker(nil))
		end,

		setTerm = function(term)
			dispatch(Actions.SetIconSearch(term))
		end,

		setHoveredIcon = function(icon)
			dispatch(Actions.SetHoveredIcon(icon))
		end,
	}
end

IconPicker = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(IconPicker)

return IconPicker
