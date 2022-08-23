local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Constants = require(Modules.Plugin.Constants)
local Actions = require(Modules.Plugin.Actions)
local TagManager = require(Modules.Plugin.TagManager)
local Util = require(Modules.Plugin.Util)

local Item = require(script.Parent.ListItem)
local Tag = require(script.Tag)
local Group = require(script.Group)
local ScrollingFrame = require(Modules.Plugin.Components.ScrollingFrame)
local StudioThemeAccessor = require(Modules.Plugin.Components.StudioThemeAccessor)

local TagList = Roact.PureComponent:extend("TagList")

function TagList:render()
	local props = self.props

	local function toggleGroup(group)
		self:setState({
			["Hide" .. group] = not self.state["Hide" .. group],
		})
	end

	local tags = props.Tags
	table.sort(tags, function(a, b)
		local ag = a.Group or ""
		local bg = b.Group or ""
		if ag < bg then
			return true
		end
		if bg < ag then
			return false
		end

		local an = a.Name or ""
		local bn = b.Name or ""

		return an < bn
	end)

	local children = {}

	children.UIListLayout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 1),

		[Roact.Ref] = function(rbx)
			if not rbx then
				return
			end
			local function update()
				if not rbx.Parent then
					return
				end
				local cs = rbx.AbsoluteContentSize
				rbx.Parent.CanvasSize = UDim2.new(0, 0, 0, cs.y)
			end
			update()
			rbx:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
		end,
	})

	local lastGroup
	local itemCount = 1
	for i = 1, #tags do
		local groupName = tags[i].Group or "Default"
		if tags[i].Group ~= lastGroup then
			lastGroup = tags[i].Group
			children["Group" .. groupName] = Roact.createElement(Group, {
				Name = groupName,
				LayoutOrder = itemCount,
				toggleHidden = toggleGroup,
				Hidden = self.state["Hide" .. groupName],
			})
			itemCount = itemCount + 1
		end
		children[tags[i].Name] = Roact.createElement(
			Tag,
			Util.merge(tags[i], {
				Hidden = self.state["Hide" .. groupName],
				Disabled = not props.selectionActive,
				Tag = tags[i].Name,
				LayoutOrder = itemCount,
			})
		)
		itemCount = itemCount + 1
	end

	local unknownTags = props.unknownTags

	for i = 1, #unknownTags do
		local tag = unknownTags[i]
		children[tag] = StudioThemeAccessor.withTheme(function(theme)
			return Roact.createElement(Item, {
				textKey = "TagList_ImportTag",
				textArgs = {
					Tag = Util.escapeTextColored(tag, theme),
				},
				RichText = true,
				Icon = "help",
				ButtonColor = Constants.LightRed,
				LayoutOrder = itemCount,
				TextProps = {
					Font = Enum.Font.SourceSansItalic,
				},

				leftClick = function(_rbx)
					TagManager.Get():AddTag(tag)
					props.openTagMenu(tag)
				end,
			})
		end)
		itemCount = itemCount + 1
	end

	if #tags == 0 then
		children.NoResults = Roact.createElement(Item, {
			LayoutOrder = itemCount,
			textKey = "TagList_NoSearchResults",
			Icon = "cancel",
			TextProps = {
				Font = Enum.Font.SourceSansItalic,
			},
		})
		itemCount = itemCount + 1
	end

	local searchTagExists = false
	for i = 1, #tags do
		if tags[i] == props.searchTerm then
			searchTagExists = true
			break
		end
	end
	if props.searchTerm and #props.searchTerm > 0 and not searchTagExists then
		children.AddNew = Roact.createElement(Item, {
			LayoutOrder = itemCount,
			textKey = "TagList_AddFromSearch",
			textArgs = {
				Tag = props.searchTerm,
			},
			Icon = "tag_blue_add",

			leftClick = function(_rbx)
				TagManager.Get():AddTag(props.searchTerm)
				props.setSearch("")
			end,
		})
	else
		children.AddNew = Roact.createElement(Item, {
			LayoutOrder = itemCount,
			textKey = "TagList_AddNew",
			Icon = "tag_blue_add",
			IsInput = true,

			onSubmit = function(_rbx, text)
				TagManager.Get():AddTag(text)
			end,
		})
	end

	return Roact.createElement(ScrollingFrame, {
		Size = props.Size or UDim2.new(1, 0, 1, 0),
	}, children)
end

local function mapStateToProps(state)
	local tags = {}

	for _, tag in pairs(state.TagData) do
		-- todo: LCS
		local passSearch = not state.Search or tag.Name:lower():find(state.Search:lower(), 1, true)
		if passSearch then
			tags[#tags + 1] = tag
		end
	end

	local unknownTags = {}
	for _, tag in pairs(state.UnknownTags) do
		-- todo: LCS
		local passSearch = not state.Search or tag:lower():find(state.Search:lower(), 1, true)
		if passSearch then
			unknownTags[#unknownTags + 1] = tag
		end
	end

	return {
		Tags = tags,
		searchTerm = state.Search,
		unknownTags = unknownTags,
		selectionActive = state.SelectionActive,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		setSearch = function(term)
			dispatch(Actions.SetSearch(term))
		end,
		openTagMenu = function(tag)
			dispatch(Actions.OpenTagMenu(tag))
		end,
	}
end

TagList = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(TagList)

return TagList
