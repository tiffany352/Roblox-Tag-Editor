local Selection = game:GetService("Selection")
local UserInputService = game:GetService("UserInputService")

local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local Constants = require(Modules.Plugin.Constants)
local TextLabel = require(Modules.Plugin.Components.TextLabel)

local InstanceItem = Roact.Component:extend("InstanceItem")

function InstanceItem:render()
	local props = self.props

	local isActive = props.Selected
	local isHover = self.state.hover

	local imageColor
	local showDivider
	local flairColor
	if isActive then
		if isHover then
			imageColor = Constants.RobloxBlue:lerp(Constants.LightGrey, 0.5)
			flairColor = Constants.VeryDarkGrey
		else
			imageColor = Constants.RobloxBlue:lerp(Constants.White, 0.5)
		end
		showDivider = false
	elseif isHover then
		imageColor = Constants.LightGrey
		flairColor = Constants.DarkGrey
		showDivider = false
	end

	return Roact.createElement("ImageButton", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1.0,
		Image = imageColor and "rbxasset://textures/ui/dialog_white.png" or nil,
		SliceCenter = Rect.new(10, 10, 10, 10),
		ImageColor3 = imageColor,
		ScaleType = Enum.ScaleType.Slice,
		LayoutOrder = props.LayoutOrder,

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
			local sel = Selection:Get()
			local alreadySelected = false
			for _,instance in pairs(sel) do
				if instance == props.Instance then
					alreadySelected = true
					break
				end
			end
			if alreadySelected then
				if #sel > 1 then
					-- select only this
					Selection:Set({ props.Instance })
				else
					-- deselect
					local baseSel = {}
					for _,instance in pairs(sel) do
						if instance ~= props.Instance then
							baseSel[#baseSel+1] = instance
						end
					end
					Selection:Set(baseSel)
				end
			else
				-- select
				local baseSel = {}
				local function isDown(key)
					return UserInputService:IsKeyDown(Enum.KeyCode[key])
				end
				if isDown('LeftControl') or isDown('RightControl') or isDown('LeftShift') or isDown('RightShift') then
					baseSel = sel
				end
				baseSel[#baseSel+1] = props.Instance
				Selection:Set(baseSel)
			end
		end,
	}, {
		Divider = Roact.createElement("Frame", {
			Visible = showDivider,
			Size = UDim2.new(1, -20, 0, 1),
			Position = UDim2.new(.5, 0, 1, 0),
			AnchorPoint = Vector2.new(.5, 1),
			BorderSizePixel = 0,
			BackgroundColor3 = Constants.LightGrey,
		}),
		Flair = Roact.createElement("ImageLabel", {
			Size = UDim2.new(0, 8, 1, 0),
			Image = "rbxassetid://1353014916",
			BackgroundTransparency = 1.0,
			ImageColor3 = flairColor,
			Visible = flairColor ~= nil,
			ImageRectSize = Vector2.new(4, 40),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(4, 20, 4, 20),
		}),
		Container = Roact.createElement("Frame", {
			Size = UDim2.new(1, -16, 0, 20),
			Position = UDim2.new(0, 16, .5, 0),
			AnchorPoint = Vector2.new(0, .5),
			BackgroundTransparency = 1.0,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
			}),
			InstanceClass = Roact.createElement(TextLabel, {
				Text = props.ClassName,
				LayoutOrder = 1,
				Font = Enum.Font.SourceSansSemibold,
				TextColor3 = Constants.VeryDarkGrey,
			}),
			InstanceName = Roact.createElement(TextLabel, {
				Text = props.Name,
				LayoutOrder = 2,
				TextColor3 = Constants.Black,
				Font = Enum.Font.SourceSansSemibold,
			}),
			Path = Roact.createElement(TextLabel, {
				Text = props.Path,
				LayoutOrder = 3,
				Font = Enum.Font.SourceSansItalic,
				TextSize = 18,
				TextColor3 = Constants.VeryDarkGrey,
			})
		}),
	})
end

return InstanceItem
