return function(plugin, savedState)
    local Modules = script.Parent.Parent
	local Roact = require(Modules.Roact)
	local Rodux = require(Modules.Rodux)
    local RoactRodux = require(Modules.RoactRodux)

    local App = require(script.Parent.Components.App)
    local Reducer = require(script.Parent.Reducer)

	local toolbar = plugin:toolbar("Tag Editor")

	local toggleButton = plugin:button(
		toolbar,
		"Tag Editor",
		"Manipulate CollectionService tags",
		"rbxasset://textures/ui/TixIcon.png"
	)

	local usePluginGui = false
	local gui
	if usePluginGui then
		gui = plugin:createPluginGui("Tag Editor")
		gui.Name = "Tag Editor"
	else
		gui = Instance.new("ScreenGui")
		gui.Name = "TagEditor"
		gui.Parent = game:GetService("CoreGui")
	end

	local store = Rodux.Store.new(Reducer, savedState)

    local connection = toggleButton.Click:Connect(function()
        gui.Enabled = not gui.Enabled
	end)

	local element = Roact.createElement(RoactRodux.StoreProvider, {
		store = store,
	}, {
		App = Roact.createElement(App)
	})

	local instance = Roact.reify(element, gui, "TagEditor")

    plugin:beforeUnload(function()
		Roact.teardown(instance)
		connection:Disconnect()
		if not usePluginGui then
			gui:Destroy()
		end
        return store:getState()
	end)

end
