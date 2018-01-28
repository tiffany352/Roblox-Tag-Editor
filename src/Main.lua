return function(plugin, savedState)
    local Modules = script.Parent.Parent
	local Roact = require(Modules.Roact)
	local Rodux = require(Modules.Rodux)
    local RoactRodux = require(Modules.RoactRodux)

    local App = require(script.Parent.Components.App)
	local Reducer = require(script.Parent.Reducer)
	local TagManager = require(script.Parent.TagManager)
	local Actions = require(script.Parent.Actions)

	local toolbar = plugin:toolbar("Instance Tagging")

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

	local function FakePluginGui(props)
		return Roact.createElement("Frame", {
			Position = UDim2.new(0, 32, 0, 32),
			Size = UDim2.new(0, 400, 0, 300),
			BorderColor3 = Color3.fromRGB(142, 142, 142),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		}, props[Roact.Children])
	end

	local usePluginGui = false
	local gui
	if usePluginGui then
		gui = plugin:createPluginGui("Tag Editor")
		gui.Name = "Tag Editor"
		toggleButton:SetActive(gui.Enabled)
	else
		gui = Instance.new("ScreenGui")
		gui.Name = "TagEditor"
		gui.Parent = game:GetService("CoreGui")
		toggleButton:SetActive(true)
	end
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local connection = toggleButton.Click:Connect(function()
		gui.Enabled = not gui.Enabled
		toggleButton:SetActive(gui.Enabled)
	end)

	local element = Roact.createElement(RoactRodux.StoreProvider, {
		store = store,
	}, {
		App = Roact.createElement(App)
	})

	if not usePluginGui then
		element = Roact.createElement(FakePluginGui, {}, { App = element })
	end

	local instance = Roact.reify(element, gui, "TagEditor")

    plugin:beforeUnload(function()
		Roact.teardown(instance)
		connection:Disconnect()
		worldViewConnection:Disconnect()
		if not usePluginGui then
			gui:Destroy()
		end
		manager:Destroy()
        return store:getState()
	end)

end
