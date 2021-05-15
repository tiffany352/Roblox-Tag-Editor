local Modules = script.Parent.Parent
local Roact = require(Modules.Roact)
local Rodux = require(Modules.Rodux)
local RoactRodux = require(Modules.RoactRodux)

local App = require(script.Parent.Components.App)
local Reducer = require(script.Parent.Reducer)
local TagManager = require(script.Parent.TagManager)
local Actions = require(script.Parent.Actions)
local Config = require(script.Parent.Config)

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
