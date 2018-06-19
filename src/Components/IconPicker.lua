local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Icon = require(script.Parent.Icon)
local Icons = require(script.Parent.Parent.FamFamFam)
local Constants = require(script.Parent.Parent.Constants)
local TagManager = require(script.Parent.Parent.TagManager)
local Actions = require(script.Parent.Parent.Actions)
local Search = require(script.Parent.Search)
local TextLabel = require(script.Parent.TextLabel)
local ScrollingFrame = require(script.Parent.ScrollingFrame)
local IconCategories = require(script.Parent.Parent.IconCategories)

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

local IconPreview = Roact.Component:extend("IconPreview")

function IconPreview:render()
	local function update()
		local Vector2new = Vector2.new
		local image = self.props.icon and Icons.Lookup(self.props.icon)
		local rect = image and image.ImageRectOffset or Vector2.new(10000, 10000)
		for y = 0, 16-1 do
			for x = 0, 16-1 do
				local pixel = self.pixels[x * 16 + y]
				pixel.ImageRectOffset = rect + Vector2new(x + 0.5, y + 0.5)
			end
		end
	end

	--[[local function update()
		if not self.updateTriggered then
			self.updateTriggered = true
			local lastUpdate = self.lastUpdate or 0
			local cooldown = 0--0.3
			spawn(function()
				if lastUpdate + cooldown > tick() then
					wait(lastUpdate + cooldown - tick())
				end
				self.updateTriggered = false
				self.lastUpdate = tick()
				doUpdate()
			end)
		end
	end]]

	if self.pixels then
		update()
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(0, 64, 0, 72+20*3),
		Position = self.props.Position,
		BackgroundTransparency = 1.0,
		AnchorPoint = Vector2.new(1, 0),
	}, {
		IconName = Roact.createElement(TextLabel, {
			TextSize = 14,
			TextColor3 = Constants.DarkGrey,
			Size = UDim2.new(0, 64, 0, 20*3),
			Position = UDim2.new(0, 0, 0, 72),
			TextWrapped = true,
			Text = self.props.icon or "",
			TextYAlignment = Enum.TextYAlignment.Top,
		}),
		IconMagnify = Roact.createElement("Frame", {
			Size = UDim2.new(0, 64, 0, 64),
			BorderColor3 = Constants.DarkGrey,
			BackgroundColor3 = Constants.White,

			[Roact.Ref] = function(rbx)
				if not rbx then return end

				self.pixels = {}
				for x = 0, 15 do
					for y = 0, 15 do
						local image = Instance.new("ImageLabel")
						image.Name = string.format("Pixel [%d, %d]", x, y)
						image.Image = Icons.Asset
						image.ImageRectSize = Vector2.new(0, 0)
						image.Size = UDim2.new(0, 4, 0, 4)
						image.Position = UDim2.new(0, x*4, 0, y*4)
						image.BackgroundTransparency = 1.0
						image.Parent = rbx
						self.pixels[x * 16 + y] = image
					end
				end

				update()
			end,
		})
	})
end

local function mapStateToProps(state)
	return {
		icon = state.HoveredIcon,
	}
end

IconPreview = RoactRodux.connect(mapStateToProps)(IconPreview)

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
