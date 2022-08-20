local Collection = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local StudioThemeAccessor = require(Modules.Plugin.Components.StudioThemeAccessor)
local TextService = game:GetService("TextService")

local TextLabel = require(script.Parent.TextLabel)
local Tag = require(script.Tag)
local ClassIcon = require(Modules.Plugin.Components.ClassIcon)
local Util = require(Modules.Plugin.Util)

local TooltipView = Roact.PureComponent:extend("TooltipView")

function TooltipView:didMount()
	self.mouseSunk = false
	self.steppedConn = self:_runRunServiceEvent():Connect(function()
		local camera = workspace.CurrentCamera
		local part = false
		local tags = {}
		if camera and not self.mouseSunk then
			local mouse = UserInput:GetMouseLocation()
			local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
			local params = RaycastParams.new()
			params.IgnoreWater = true
			params.FilterType = Enum.RaycastFilterType.Blacklist
			local direction = ray.Direction.Unit * 1000

			local ignore = {}
			for _i = 1, 10 do
				params.FilterDescendantsInstances = ignore
				local result = workspace:Raycast(ray.Origin, direction, params)
				local obj = result and result.Instance
				local objTags = obj and Collection:GetTags(obj)
				if objTags then
					for i = #objTags, 1, -1 do
						if objTags[i]:sub(1, 1) == "." then
							table.remove(objTags, i)
						end
					end
				end
				local model = obj and obj.Parent and obj.Parent:IsA("Model") and obj.Parent or nil
				local modelTags = model and Collection:GetTags(model)
				if objTags and #objTags > 0 then
					part = obj
					tags = objTags
					break
				elseif modelTags and #modelTags > 0 then
					part = model
					tags = modelTags
					break
				elseif obj and obj:IsA("Part") and obj.Transparency >= 0.9 then
					ignore[#ignore + 1] = obj
				else
					break
				end
			end
		end
		self:setState({
			Part = part,
			Tags = tags,
		})
	end)
	self.inputChangedConn = UserInput.InputChanged:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self.mouseSunk = gameProcessed
		end
	end)
end

function TooltipView:willUnmount()
	self.steppedConn:Disconnect()
	self.inputChangedConn:Disconnect()
end

function TooltipView:render()
	local props = self.props

	local children = {}

	children.UIListLayout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local maxWidth = 50

	local tooltipTitle = self.state.Part and self.state.Part.Name or ""
	local tooltipTitleSize = TextService:GetTextSize(
		Util.escapeTextPlain(tooltipTitle),
		20.0,
		Enum.Font.SourceSansSemibold,
		Vector2.new(0.0, 0.0)
	)
	maxWidth = math.max(maxWidth, tooltipTitleSize.X)

	children.ObjectDesc = Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1.0,
		LayoutOrder = 0,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 4),
		}),
		Margin = Roact.createElement("Frame", {
			Size = UDim2.new(0, 10, 1, 0),
			BackgroundTransparency = 1.0,
		}),
		InstanceClass = Roact.createElement(ClassIcon, {
			ClassName = self.state.Part and self.state.Part.ClassName or "Part",
		}),
		InstanceName = StudioThemeAccessor.withTheme(function(theme)
			return Roact.createElement(TextLabel, {
				Text = Util.escapeTextColored(tooltipTitle, theme),
				RichText = true,
				TextColor3 = theme:GetColor("MainText", "Default"),
				LayoutOrder = 2,
				Font = Enum.Font.SourceSansSemibold,
			})
		end),
	})

	local tags = self.state.Tags or {}
	table.sort(tags)

	for i = 1, #tags do
		local tag = tags[i]
		local icon = "computer_error"
		for _, entry in pairs(props.tagData) do
			if entry.Name == tag then
				icon = entry.Icon or icon
				break
			end
		end
		local size = TextService:GetTextSize(Util.escapeTextPlain(tag), 20, Enum.Font.SourceSans, Vector2.new(0.0, 0.0))
		maxWidth = math.max(maxWidth, size.X)

		children[tag] = Roact.createElement(Tag, {
			Tag = tag,
			Icon = icon,
		})
	end

	return StudioThemeAccessor.withTheme(function(theme)
		return Roact.createElement(Roact.Portal, {
			target = CoreGui,
		}, {
			TagEditorTooltip = Roact.createElement("ScreenGui", {
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			}, {
				Window = Roact.createElement("Frame", {
					BackgroundTransparency = 1.0,
					Visible = self.state.Part ~= false and props.worldView,
					Size = UDim2.new(0, maxWidth + 50, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					[Roact.Ref] = function(rbx)
						if rbx then
							self.mouseSteppedConn = self:_runRunServiceEvent():Connect(function()
								local inset = GuiService:GetGuiInset()
								local pos = UserInput:GetMouseLocation() - inset + Vector2.new(20, 0)
								rbx.Position = UDim2.new(0, pos.x, 0, pos.y)
							end)
						else
							self.mouseSteppedConn:Disconnect()
						end
					end,
				}, {
					HorizontalDivider = Roact.createElement("Frame", {
						Size = UDim2.new(1, 2, 1, 0),
						Position = UDim2.new(0, -1, 0, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = theme:GetColor("Tooltip"),
					}),
					VerticalDivider = Roact.createElement("Frame", {
						Size = UDim2.new(1, 0, 1, 2),
						Position = UDim2.new(0, 0, 0, -1),
						BorderSizePixel = 0,
						BackgroundColor3 = theme:GetColor("Tooltip"),
					}),
					Container = Roact.createElement("Frame", {
						ZIndex = 2,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.fromScale(1.0, 0.0),
						BorderSizePixel = 0,
						BackgroundColor3 = theme:GetColor("MainBackground"),
					}, children),
				}),
			}),
		})
	end)
end

--- RenderStepped errors out in Start Server, so bind to stepped if we can't bind to RenderStepped
function TooltipView:_runRunServiceEvent()
	if RunService:IsClient() then
		return RunService.RenderStepped
	else
		return RunService.Stepped
	end
end

local function mapStateToProps(state)
	return {
		tagData = state.TagData,
		worldView = state.WorldView,
	}
end

TooltipView = RoactRodux.connect(mapStateToProps)(TooltipView)

return TooltipView
