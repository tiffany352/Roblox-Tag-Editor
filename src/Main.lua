local Modules = script.Parent.Parent
local Roact = require(Modules.Roact)
local Rodux = require(Modules.Rodux)
local RoactRodux = require(Modules.RoactRodux)

local App = require(script.Parent.Components.App)
local Reducer = require(script.Parent.Reducer)
local TagManager = require(script.Parent.TagManager)
local Actions = require(script.Parent.Actions)
local Config = require(script.Parent.Config)
local PluginGlobals = require(script.Parent.PluginGlobals)

local function getSuffix(plugin)
	if plugin.isDev then
		return " [DEV]", "Dev"
	elseif Config.betaRelease then
		return " [BETA]", "Beta"
	end

	return "", ""
end

return function(plugin, savedState)
	local displaySuffix, nameSuffix = getSuffix(plugin)

	local toolbar = plugin:toolbar("Instance Tagging" .. displaySuffix)

	local toggleButton = plugin:button(
		toolbar,
		"Tag Window",
		"Manipulate CollectionService tags",
		"http://www.roblox.com/asset/?id=1367281857"
	)

	local worldViewButton = plugin:button(
		toolbar,
		"World View",
		"Visualize tagged objects in the 3D view",
		"http://www.roblox.com/asset/?id=1367285594"
	)

	local store = Rodux.Store.new(Reducer, savedState)

	local manager = TagManager.new(store)

	local worldViewConnection = worldViewButton.Click:Connect(function()
		local state = store:getState()
		local newValue = not state.WorldView
		store:dispatch(Actions.ToggleWorldView(newValue))
		worldViewButton:SetActive(newValue)
	end)

	local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, false, false, 0, 0)
	local gui = plugin:createDockWidgetPluginGui("TagEditor" .. nameSuffix, info)
	gui.Name = "TagEditor" .. nameSuffix
	gui.Title = "Tag Editor" .. displaySuffix
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	toggleButton:SetActive(gui.Enabled)

	local connection = toggleButton.Click:Connect(function()
		gui.Enabled = not gui.Enabled
		toggleButton:SetActive(gui.Enabled)
	end)

	local prefix = "TagEditor" .. nameSuffix .. "_"

	local changeIconAction =
		plugin:createAction(prefix .. "ChangeIcon", "Change icon...", "Change the icon of the tag.")

	local changeGroupAction = plugin:createAction(
		prefix .. "ChangeGroup",
		"Change group...",
		"Change the sorting group of the tag."
	)

	local changeColorAction = plugin:createAction(
		prefix .. "ChangeColor",
		"Change color...",
		"Change the color of the tag."
	)

	local deleteAction = plugin:createAction(
		prefix .. "Delete",
		"Delete",
		"Delete the tag and remove it from all instances."
	)

	local viewTaggedAction = plugin:createAction(
		prefix .. "ViewTagged",
		"View tagged instances",
		"Show a list of all instances that have this tag."
	)

	local visualizeBox = plugin:createAction(
		prefix .. "Visualize_Box",
		"Box",
		"Render this tag as a box when the overlay is enabled."
	)

	local visualizeSphere = plugin:createAction(
		prefix .. "Visualize_Sphere",
		"Sphere",
		"Render this tag as a sphere when the overlay is enabled."
	)

	local visualizeOutline = plugin:createAction(
		prefix .. "Visualize_Outline",
		"Outline",
		"Render this tag as an outline around parts when the overlay is enabled."
	)

	local visualizeText = plugin:createAction(
		prefix .. "Visualize_Text",
		"Text",
		"Render this tag as a floating text label when the overlay is enabled."
	)

	local visualizeIcon = plugin:createAction(
		prefix .. "Visualize_Icon",
		"Icon",
		"Render the tag's icon when the overlay is enabled."
	)

	local visualizeMenu: PluginMenu = plugin:createMenu(prefix .. "TagMenu_VisualizeAs", "Change draw mode")
	visualizeMenu:AddAction(visualizeBox)
	visualizeMenu:AddAction(visualizeSphere)
	visualizeMenu:AddAction(visualizeOutline)
	visualizeMenu:AddAction(visualizeText)
	visualizeMenu:AddAction(visualizeIcon)

	local tagMenu: PluginMenu = plugin:createMenu(prefix .. "TagMenu")
	tagMenu:AddAction(viewTaggedAction)
	tagMenu:AddMenu(visualizeMenu)
	tagMenu:AddSeparator()
	tagMenu:AddAction(changeIconAction)
	tagMenu:AddAction(changeColorAction)
	tagMenu:AddAction(changeGroupAction)
	tagMenu:AddAction(deleteAction)

	PluginGlobals.TagMenu = tagMenu
	PluginGlobals.changeIconAction = changeIconAction
	PluginGlobals.changeGroupAction = changeGroupAction
	PluginGlobals.changeColorAction = changeColorAction
	PluginGlobals.deleteAction = deleteAction
	PluginGlobals.viewTaggedAction = viewTaggedAction
	PluginGlobals.visualizeBox = visualizeBox
	PluginGlobals.visualizeSphere = visualizeSphere
	PluginGlobals.visualizeOutline = visualizeOutline
	PluginGlobals.visualizeText = visualizeText
	PluginGlobals.visualizeIcon = visualizeIcon

	local element = Roact.createElement(RoactRodux.StoreProvider, {
		store = store,
	}, {
		App = Roact.createElement(App, {
			root = gui,
		}),
	})

	local instance = Roact.mount(element, gui, "TagEditor")

	plugin:beforeUnload(function()
		Roact.unmount(instance)
		connection:Disconnect()
		worldViewConnection:Disconnect()
		manager:Destroy()
		return store:getState()
	end)
end
