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
local tr = require(script.Parent.tr)

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

	local toolbar = plugin:toolbar(tr("Toolbar_InstanceTagging_Title") .. displaySuffix)

	local function pluginButton(key: string, icon: string): PluginToolbarButton
		return plugin:button(
			toolbar,
			key,
			tr("PluginButton_" .. key .. "_ToolTip"),
			icon,
			tr("PluginButton_" .. key .. "_Title")
		)
	end

	local toggleButton = pluginButton("TagWindow", "http://www.roblox.com/asset/?id=1367281857")
	local worldViewButton = pluginButton("WorldView", "http://www.roblox.com/asset/?id=1367285594")

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
	gui.Title = tr("PluginGui_TagEditor_Title") .. displaySuffix
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.RootLocalizationTable = script.Parent.Localization
	toggleButton:SetActive(gui.Enabled)

	local connection = toggleButton.Click:Connect(function()
		gui.Enabled = not gui.Enabled
		toggleButton:SetActive(gui.Enabled)
	end)

	local prefix = "TagEditor" .. nameSuffix .. "_"
	local function createAction(id: string, icon: string?, allowBinding: boolean?): PluginAction
		local label = tr("PluginAction_" .. id .. "_Label")
		local description = tr("PluginAction_" .. id .. "_Description")
		return plugin:createAction(prefix .. id, label, description, icon, allowBinding)
	end

	local changeIconAction = createAction("ChangeIcon")
	local changeGroupAction = createAction("ChangeGroup")
	local changeColorAction = createAction("ChangeColor")
	local renameAction = createAction("Rename")
	local deleteAction = createAction("Delete")
	local viewTaggedAction = createAction("ViewTagged")
	local selectAllAction: PluginAction = createAction("SelectAll")

	local selectAllConn = selectAllAction.Triggered:Connect(function()
		local state = store:getState()
		local tag = state.InstanceView or PluginGlobals.currentTagMenu or state.TagMenu
		if tag then
			TagManager.Get():SelectAll(tag)
		end
	end)

	local visualizeBox = createAction("Visualize_Box")
	local visualizeSphere = createAction("Visualize_Sphere")
	local visualizeOutline = createAction("Visualize_Outline")
	local visualizeText = createAction("Visualize_Text")
	local visualizeIcon = createAction("Visualize_Icon")
	local visualizeHighlight = createAction("Visualize_Highlight")

	local visualizeMenu: PluginMenu = plugin:createMenu("TagMenu_VisualizeAs", tr("PluginMenu_TagMenu_VisualizeAs"))
	visualizeMenu:AddAction(visualizeBox)
	visualizeMenu:AddAction(visualizeSphere)
	visualizeMenu:AddAction(visualizeOutline)
	visualizeMenu:AddAction(visualizeText)
	visualizeMenu:AddAction(visualizeIcon)
	visualizeMenu:AddAction(visualizeHighlight)

	local tagMenu: PluginMenu = plugin:createMenu("TagMenu")
	tagMenu:AddAction(viewTaggedAction)
	tagMenu:AddAction(selectAllAction)
	tagMenu:AddMenu(visualizeMenu)
	tagMenu:AddSeparator()
	tagMenu:AddAction(renameAction)
	tagMenu:AddAction(changeIconAction)
	tagMenu:AddAction(changeColorAction)
	tagMenu:AddAction(changeGroupAction)
	tagMenu:AddAction(deleteAction)

	PluginGlobals.TagMenu = tagMenu
	PluginGlobals.changeIconAction = changeIconAction
	PluginGlobals.changeGroupAction = changeGroupAction
	PluginGlobals.changeColorAction = changeColorAction
	PluginGlobals.renameAction = renameAction
	PluginGlobals.deleteAction = deleteAction
	PluginGlobals.selectAllAction = selectAllAction
	PluginGlobals.viewTaggedAction = viewTaggedAction
	PluginGlobals.visualizeBox = visualizeBox
	PluginGlobals.visualizeSphere = visualizeSphere
	PluginGlobals.visualizeOutline = visualizeOutline
	PluginGlobals.visualizeText = visualizeText
	PluginGlobals.visualizeIcon = visualizeIcon
	PluginGlobals.visualizeHighlight = visualizeHighlight

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
		selectAllConn:Disconnect()
		return store:getState()
	end)
end
