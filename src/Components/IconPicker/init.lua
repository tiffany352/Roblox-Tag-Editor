local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Constants = require(Modules.Plugin.Constants)
local Actions = require(Modules.Plugin.Actions)
local IconCategories = require(Modules.Plugin.IconCategories)

local Icon = require(script.Parent.Icon)
local Search = require(script.Parent.Search)
local TextLabel = require(script.Parent.TextLabel)
local ScrollingFrame = require(script.Parent.ScrollingFrame)
local Category = require(script.Category)
local IconPreview = require(script.IconPreview)

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
					Text = tostring(props.tagName).." - Select an Icon",
					LayoutOrder = 2,
					TextColor3 = Constants.White,
					Font = Enum.Font.SourceSansSemibold,
				}),
			})
		}),
		Body = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -32),
			Position = UDim2.new(0, 0, 0, 32),
			BackgroundTransparency = 1.0,
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
			Sidebar = Roact.createElement("Frame", {
				BackgroundColor3 = Constants.LightGrey,
				BorderColor3 = Constants.DarkGrey,
				Size = UDim2.new(0, 80, 1, 0),
				Position = UDim2.new(1, -80, 0, 0),
			}, {
				Preview = Roact.createElement(IconPreview, {
					Position = UDim2.new(1, -8, 0, 8),
				}),
			}),
		})
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
