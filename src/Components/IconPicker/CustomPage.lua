local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Search = require(Modules.Plugin.Components.Search)
local Button = require(Modules.Plugin.Components.Button)
local TagManager = require(Modules.Plugin.TagManager)

local CustomPage = Roact.PureComponent:extend("CustomPage")

function CustomPage:init()
	self.state = {
		text = "",
		focused = false,
	}
end

local rbxassetid = "^rbxassetid://[0-9]+$"
local rawNumber = "^[0-9]+$"

local function validate(url)
	if string.match(url, rbxassetid) then
		return url
	elseif string.match(url, rawNumber) then
		return "rbxassetid://" .. url
	end
	return false
end

function CustomPage:render()
	local valid = validate(self.state.text)

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 60),
		BackgroundTransparency = 1.0,
	}, {
		Input = Roact.createElement(Search, {
			Size = UDim2.new(1, 0, 0, 40),
			term = self.state.text,
			placeholderTextKey = "IconPicker_EnterAssetId",
			error = not valid,
			setTerm = function(term)
				self:setState({
					text = term,
				})
				local url = validate(term)
				if url then
					self.props.onHoverFunc(url)
				end
			end,
			onFocusLost = function(_rbx, _enterPressed)
				local url = validate(self.state.text)
				if url then
					self:setState({
						text = url,
					})
					self.props.onHoverFunc(url)
				end
			end,
		}),
		Submit = Roact.createElement(Button, {
			Size = UDim2.new(0, 100, 0, 24),
			Position = UDim2.fromOffset(8, 50),
			textKey = "IconPicker_Save",
			leftClick = function()
				local url = validate(self.state.text)
				if url then
					TagManager.Get():SetIcon(self.props.tagName, url)
					self.props.closeFunc()
				end
			end,
		}),
	})
end

return CustomPage
