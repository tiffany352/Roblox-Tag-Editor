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

	local TitlebarButton = Roact.Component:extend("TitlebarButton")

	function TitlebarButton:render()
		local props = self.props

		return Roact.createElement("ImageButton", {
			Size = UDim2.new(0, 15, 0, 15),
			Position = props.Position,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(228, 228, 254),
			Image = props.Image,
			BackgroundTransparency = self.state.hover and 0.0 or 1.0,
			AutoButtonColor = false,

			[Roact.Event.MouseEnter] = function(rbx)
				self:setState({
					hover = true,
				})
			end,

			[Roact.Event.MouseLeave] = function(rbx)
				self:setState({
					hover = false,
				})
			end,

			[Roact.Event.MouseButton1Click] = function(rbx)
				props.onClick()
				self:setState({
					hover = false,
				})
			end,
		})
	end

	local gui
	local pluginGuiRef
	-- dragging params
	local startMousePos
	local startSize
	local startPos
	local clickCount = 0

	local States = setmetatable({
		Float = 'Float',
		Left = 'Left',
		Right = 'Right',
		Bottom = 'Bottom',
		Fullscreen = 'Fullscreen',
	}, {
		__index = function(t, k)
			error("No such enum item "..tostring(k).." in States")
		end
	})
	local state = States.Float
	local floatPos, floatSize = Vector2.new(0, 0), Vector2.new(400, 300)

	local function setState(newState)
		state = newState
		if state == States.Fullscreen then
			pluginGuiRef.Position = UDim2.new(0, 0, 0, 0)
			pluginGuiRef.Size = UDim2.new(1, 0, 1, 0)
		elseif state == States.Left then
			pluginGuiRef.Position = UDim2.new(0, 0, 0, 0)
			pluginGuiRef.Size = UDim2.new(0, floatSize.x, 1, 0)
		elseif state == States.Right then
			pluginGuiRef.Position = UDim2.new(1, -floatSize.x, 0, 0)
			pluginGuiRef.Size = UDim2.new(0, floatSize.x, 1, 0)
		elseif state == States.Bottom then
			pluginGuiRef.Position = UDim2.new(0, 0, 1, -floatSize.y)
			pluginGuiRef.Size = UDim2.new(1, 0, 0, floatSize.y)
		elseif state == States.Float then
			pluginGuiRef.Position = UDim2.new(0, floatPos.x, 0, floatPos.y)
			pluginGuiRef.Size = UDim2.new(0, floatSize.x, 0, floatSize.y)
		else
			assert(false)
		end
	end

	local function FakePluginGui(props)
		return Roact.createElement("ImageButton", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(208, 208, 208),
			AutoButtonColor = false,

			[Roact.Ref] = function(rbx)
				pluginGuiRef = rbx
				if rbx then
					setState(States.Float)
				end
			end,

			[Roact.Event.MouseButton1Click] = function(rbx, x, y)
				if clickCount > 0 then
					if state == States.Float then
						setState(States.Fullscreen)
					else
						setState(States.Float)
					end
				else
					clickCount = clickCount + 1
					wait(.3)
					clickCount = clickCount - 1
				end
			end,

			[Roact.Event.MouseButton1Down] = function(rbx, x, y)
				startMousePos = Vector2.new(x, y)
				startPos = pluginGuiRef.AbsolutePosition
				if startPos.x + floatSize.x < startMousePos.x then
					startPos = Vector2.new(startMousePos.x - floatSize.x, startPos.y)
				end
				if startPos.x > startMousePos.x + floatSize.x then
					startPos = Vector2.new(startMousePos.x, startPos.y)
				end
				local UserInputService = game:GetService("UserInputService")
				local inset = game:GetService("GuiService"):GetGuiInset()

				local function update(input)
					local mousePos = Vector2.new(input.Position.X, input.Position.Y)
					if (mousePos - startMousePos + inset).Magnitude < 4 then return end
					local newPos = startPos + (mousePos - startMousePos + inset)
					local max = gui.AbsoluteSize - pluginGuiRef.AbsoluteSize
					newPos = Vector2.new(math.clamp(newPos.x, 0, max.x), math.clamp(newPos.y, 0, max.y))
					if mousePos.x < 40 then
						-- left side
						setState(States.Left)
					elseif mousePos.x > gui.AbsoluteSize.x - 40 then
						-- right side
						setState(States.Right)
					elseif mousePos.y > gui.AbsoluteSize.y - 40 then
						-- bottom
						setState(States.Bottom)
					else
						floatPos = newPos
						setState(States.Float)
					end
				end

				local changedConn = UserInputService.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						update(input)
					end
				end)

				local endedConn
				endedConn = UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						changedConn:Disconnect()
						endedConn:Disconnect()
						update(input)
					end
				end)
			end,
		}, {
			Title = Roact.createElement("TextLabel", {
				Text = "Tag Editor",
				Font = Enum.Font.SourceSans,
				TextSize = 14,
				Size = UDim2.new(1, -32, 0, 23),
				BackgroundTransparency = 1.0,
				TextColor3 = Color3.fromRGB(0, 0, 0),
			}),
			Close = Roact.createElement(TitlebarButton, {
				Position = UDim2.new(1, -16, 0, 4),
				Image = 'rbxassetid://1384217206',
				onClick = function()
					gui.Enabled = false
				end,
			}),
			Maximize = Roact.createElement(TitlebarButton, {
				Position = UDim2.new(1, -32, 0, 4),
				Image = 'rbxassetid://1384227954',
				onClick = function()
					if state == States.Fullscreen then
						setState(States.Float)
					else
						setState(States.Fullscreen)
					end
				end,
			}),
			Resize = Roact.createElement("ImageButton", {
				Size = UDim2.new(0, 8, 0, 8),
				Position = UDim2.new(1, 0, 1, 0),
				AnchorPoint = Vector2.new(1, 1),
				BackgroundTransparency = 1.0,
				ZIndex = 2,

				[Roact.Event.MouseButton1Down] = function(rbx, x, y)
					startMousePos = Vector2.new(x, y)
					startSize = floatSize
					local UserInputService = game:GetService("UserInputService")
					local inset = game:GetService("GuiService"):GetGuiInset()

					local function update(input)
						local mousePos = Vector2.new(input.Position.X, input.Position.Y)
						local newSize = startSize + (mousePos - startMousePos + inset)
						newSize = Vector2.new(math.max(300, newSize.x), math.max(250, newSize.y))
						floatSize = newSize
						setState(state)
					end

					local changedConn = UserInputService.InputChanged:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							update(input)
						end
					end)

					local endedConn
					endedConn = UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							changedConn:Disconnect()
							endedConn:Disconnect()
							update(input)
						end
					end)
				end,
			}),
			Body = Roact.createElement("ImageButton", {
				Size = UDim2.new(1, -2, 1, -24),
				Position = UDim2.new(0, 1, 0, 24),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BorderColor3 = Color3.fromRGB(122, 122, 122),
				ClipsDescendants = true,
			}, props[Roact.Children])
		})
	end

	local usePluginGui = pcall(function()
		local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, false, false, 0, 0)
		gui = plugin:createDockWidgetPluginGui("Tag Editor", info)
		gui.Name = "Tag Editor"
		gui.Title = "Tag Editor"
		toggleButton:SetActive(gui.Enabled)
	end)
	if not usePluginGui then
		gui = Instance.new("ScreenGui")
		gui.Name = "TagEditor"
		gui.Enabled = false
		gui.Parent = game:GetService("CoreGui")
		toggleButton:SetActive(false)
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
