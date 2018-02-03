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
	local savedSize
	local savedPos
	local startMousePos
	local startSize
	local startPos
	local clickCount = 0

	local function FakePluginGui(props)
		return Roact.createElement("ImageButton", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(208, 208, 208),
			AutoButtonColor = false,

			[Roact.Ref] = function(rbx)
				if rbx then
					rbx.Size = UDim2.new(0, 400, 0, 300)
				end
				pluginGuiRef = rbx
			end,

			[Roact.Event.MouseButton1Click] = function(rbx, x, y)
				if clickCount > 0 then
					if savedPos then
						pluginGuiRef.Position = savedPos
						pluginGuiRef.Size = savedSize
						savedPos = nil
						savedSize = nil
					else
						savedPos = pluginGuiRef.Position
						savedSize = pluginGuiRef.Size
						pluginGuiRef.Position = UDim2.new(0, 0, 0, 0)
						pluginGuiRef.Size = UDim2.new(1, 0, 1, 0)
					end
				else
					clickCount = clickCount + 1
					print(clickCount)
					wait(.3)
					clickCount = clickCount - 1
				end
			end,

			[Roact.Event.MouseButton1Down] = function(rbx, x, y)
				if savedPos then
					pluginGuiRef.Position = savedPos
					pluginGuiRef.Size = savedSize
					savedPos = nil
					savedSize = nil
				end
				startMousePos = Vector2.new(x, y)
				startPos = Vector2.new(pluginGuiRef.Position.X.Offset, pluginGuiRef.Position.Y.Offset)
				local UserInputService = game:GetService("UserInputService")
				local inset = game:GetService("GuiService"):GetGuiInset()

				local changedConn = UserInputService.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						local mousePos = Vector2.new(input.Position.X, input.Position.Y)
						local newPos = startPos + (mousePos - startMousePos + inset)
						local max = gui.AbsoluteSize - pluginGuiRef.AbsoluteSize
						newPos = Vector2.new(math.clamp(newPos.x, 0, max.x), math.clamp(newPos.y, 0, max.y))
						if mousePos.x < 40 then
							-- left side
							savedPos = UDim2.new(0, newPos.x, 0, newPos.y)
							if not savedSize then
								savedSize = pluginGuiRef.Size
							end
							pluginGuiRef.Position = UDim2.new(0, 0, 0, 0)
							pluginGuiRef.Size = UDim2.new(pluginGuiRef.Size.X, UDim.new(1, 0))
						elseif mousePos.x > gui.AbsoluteSize.x - 40 then
							-- right side
							savedPos = UDim2.new(0, newPos.x, 0, newPos.y)
							if not savedSize then
								savedSize = pluginGuiRef.Size
							end
							pluginGuiRef.Position = UDim2.new(1, -pluginGuiRef.AbsoluteSize.X, 0, 0)
							pluginGuiRef.Size = UDim2.new(pluginGuiRef.Size.X, UDim.new(1, 0))
						elseif mousePos.y > gui.AbsoluteSize.y - 40 then
							-- bottom
							savedPos = UDim2.new(0, newPos.x, 0, newPos.y)
							if not savedSize then
								savedSize = pluginGuiRef.Size
							end
							pluginGuiRef.Position = UDim2.new(0, 0, 1, -pluginGuiRef.AbsoluteSize.Y)
							pluginGuiRef.Size = UDim2.new(UDim.new(1, 0), pluginGuiRef.Size.Y)
						else
							if savedSize then
								pluginGuiRef.Size = savedSize
								savedSize = nil
							end
							pluginGuiRef.Position = UDim2.new(0, newPos.x, 0, newPos.y)
						end
					end
				end)

				local endedConn
				endedConn = UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						changedConn:Disconnect()
						endedConn:Disconnect()

						local mousePos = Vector2.new(input.Position.X, input.Position.Y)
						local newPos = startPos + (mousePos - startMousePos + inset)
						local max = gui.AbsoluteSize - pluginGuiRef.AbsoluteSize
						newPos = Vector2.new(math.clamp(newPos.x, 0, max.x), math.clamp(newPos.y, 0, max.y))
						pluginGuiRef.Position = UDim2.new(0, newPos.x, 0, newPos.y)
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
					if pluginGuiRef then
						if savedPos then
							pluginGuiRef.Position = savedPos
							pluginGuiRef.Size = savedSize
							savedPos = nil
							savedSize = nil
						else
							savedPos = pluginGuiRef.Position
							savedSize = pluginGuiRef.Size
							pluginGuiRef.Position = UDim2.new(0, 0, 0, 0)
							pluginGuiRef.Size = UDim2.new(1, 0, 1, 0)
						end
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
					if savedPos then
						pluginGuiRef.Position = savedPos
						pluginGuiRef.Size = savedSize
						savedPos = nil
						savedSize = nil
					end
					startMousePos = Vector2.new(x, y)
					startSize = Vector2.new(pluginGuiRef.Size.X.Offset, pluginGuiRef.Size.Y.Offset)
					local UserInputService = game:GetService("UserInputService")
					local inset = game:GetService("GuiService"):GetGuiInset()

					local changedConn = UserInputService.InputChanged:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							local mousePos = Vector2.new(input.Position.X, input.Position.Y)
							local newSize = startSize + (mousePos - startMousePos + inset)
							newSize = Vector2.new(math.max(300, newSize.x), math.max(250, newSize.y))
							pluginGuiRef.Size = UDim2.new(0, newSize.x, 0, newSize.y)
						end
					end)

					local endedConn
					endedConn = UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							changedConn:Disconnect()
							endedConn:Disconnect()

							local mousePos = Vector2.new(input.Position.X, input.Position.Y)
							local newSize = startSize + (mousePos - startMousePos + inset)
							newSize = Vector2.new(math.max(300, newSize.x), math.max(250, newSize.y))
							pluginGuiRef.Size = UDim2.new(0, newSize.x, 0, newSize.y)
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

	local usePluginGui = false
	if usePluginGui then
		gui = plugin:createPluginGui("Tag Editor")
		gui.Name = "Tag Editor"
		toggleButton:SetActive(gui.Enabled)
	else
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
