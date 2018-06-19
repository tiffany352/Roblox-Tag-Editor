local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Constants = require(Modules.Plugin.Constants)

local Item = require(script.Parent.Item)

local Confirm = Roact.Component:extend("ContextMenuConfirm")

function Confirm:init()
	self.state = {
		open = false,
	}
end

function Confirm.getDerivedStateFromProps(nextProps, lastState)
	return {
		open = lastState.open and nextProps.confirmKey == lastState.confirmKey,
		confirmKey = nextProps.confirmKey or Roact.None,
	}
end

function Confirm:render()
	local props = self.props
	local confirm = props.ConfirmText or "Are you sure?"
	local newProps = {
		First = false,
		Last = false,
		Text = self.state.open and confirm or props.Text,

		[Roact.Event.MouseButton1Click] = function(rbx)
			self:setState({
				open = not self.state.open,
			})
		end
	}
	local blacklist = {
		ConfirmText = true,
		Text = true,
		onClick = true,
		confirmKey = true,
	}
	for k,v in pairs(props) do
		if not blacklist[k] then
			newProps[k] = v
		end
	end
	return Roact.createElement(Item, newProps, {
		Button = Roact.createElement("ImageButton", {
			Size = UDim2.new(0, self.state.open and 40 or 0, 1, 0),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = Constants.RobloxBlue,

			[Roact.Event.MouseButton1Click] = function(rbx)
				if props.onClick then
					props.onClick(rbx)
					self:setState({
						open = false,
					})
				end
			end,
		}, {
			Label = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1.0,
				Text = "Yes",
				Size = UDim2.new(1, 0, 1, 0),
				TextSize = 20,
				Font = Enum.Font.SourceSansBold,
				TextColor3 = Constants.White,
				ClipsDescendants = true,
			})
		})
	})
end

return Confirm
