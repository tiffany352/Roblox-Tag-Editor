local Modules = script.Parent.Parent
local Roact = require(Modules.Roact)
local Rodux = require(Modules.Rodux)
local RoactRodux = require(Modules.RoactRodux)

local App = require(script.Parent.Components.App)
local ThemeProvider = require(script.Parent.Components.ThemeProvider)
local Reducer = require(script.Parent.Reducer)
local TagManager = require(script.Parent.TagManager)
local ThemeManager = require(script.Parent.ThemeManager)
local ThemePolyfill = require(script.Parent.ThemePolyfill)
local Actions = require(script.Parent.Actions)

return function(plugin, savedState)
	local isDev = plugin.isDev

	local toolbar = plugin:toolbar(isDev and "Instance Tagging [DEV]" or "Instance Tagging")

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

	local StudioSettings = settings().Studio
	local function getTheme()
		local studioTheme = StudioSettings["UI Theme"]
		return
			ThemePolyfill[studioTheme.Name] or
			ThemePolyfill.Light
	end
	local themeManager = ThemeManager.new(getTheme())
	local themeConnection = StudioSettings:GetPropertyChangedSignal("UI Theme"):Connect(function()
		themeManager:setTheme(getTheme())
	end)

	local worldViewConnection = worldViewButton.Click:Connect(function()
		local state = store:getState()
		local newValue = not state.WorldView
		store:dispatch(Actions.ToggleWorldView(newValue))
		worldViewButton:SetActive(newValue)
	end)

	local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, false, false, 0, 0)
	local gui = plugin:createDockWidgetPluginGui("Tag Editor", info)
	gui.Name = isDev and "TagEditorDev" or "TagEditor"
	gui.Title = isDev and "Tag Editor [DEV]" or "Tag Editor"
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	toggleButton:SetActive(gui.Enabled)

	local connection = toggleButton.Click:Connect(function()
		gui.Enabled = not gui.Enabled
		toggleButton:SetActive(gui.Enabled)
	end)

	local element = Roact.createElement(RoactRodux.StoreProvider, {
		store = store,
	}, {
		ThemeProvider = Roact.createElement(ThemeProvider, {
			themeManager = themeManager,
		}, {
			App = Roact.createElement(App, {
				root = gui,
			})
		})
	})

	local instance = Roact.mount(element, gui, "TagEditor")

	plugin:beforeUnload(function()
		Roact.unmount(instance)
		connection:Disconnect()
		worldViewConnection:Disconnect()
		themeConnection:Disconnect()
		manager:Destroy()
		return store:getState()
	end)

	local unloadConnection
	unloadConnection = gui.AncestryChanged:Connect(function()
		print("New tag editor version coming online; unloading the old version")
		unloadConnection:Disconnect()
		plugin:unload()
	end)
end
