--[[
	RootPortal allows rendering elements into the root of the tag editor's UI tree safely.
	Using portals alone would cause an error because Roact doesn't update refs until after
	children have been mounted, and portals cannot have a target of nil. For example, this
	code would break on initial render (but work for all subsequent renders):

	render()
		return Roact.createElement(Roact.Portal, {
			target = self._context[rootKey].current
		})
	end
]]

local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local rootKey = require(Modules.Plugin.Components.rootKey)

local RootPortal = Roact.Component:extend("RootPortal")

function RootPortal:init()
	self._ref = self._context[rootKey]
end

function RootPortal:render()
	if self._ref.current then
		return Roact.createElement(Roact.Portal, {
			target = self._ref.current,
		}, self.props[Roact.Children])
	else
		return nil
	end
end

function RootPortal:didMount()
	spawn(function()
		if not self._unmounted then
			self:setState({})
		end
	end)
end

function RootPortal:willUnmount()
	self._unmounted = true
end

return RootPortal
