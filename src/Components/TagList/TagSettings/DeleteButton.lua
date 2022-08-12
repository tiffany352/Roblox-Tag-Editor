local Modules = script.Parent.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local Button = require(Modules.Plugin.Components.Button)

local DeleteButton = Roact.PureComponent:extend("DeleteButton")

function DeleteButton:init()
	self.state = {
		confirming = false,
	}
end

function DeleteButton:render()
	return Roact.createElement(Button, {
		textKey = self.state.confirming and "TagSettings_DeleteConfirm" or "TagSettings_Delete",
		Size = self.props.Size,
		Position = self.props.Position,
		LayoutOrder = self.props.LayoutOrder,
		BorderColor3 = Color3.fromRGB(255, 0, 0),

		leftClick = function()
			if self.state.confirming then
				self.props.leftClick()
			else
				self:setState({
					confirming = true,
				})
			end
		end,
	})
end

return DeleteButton
