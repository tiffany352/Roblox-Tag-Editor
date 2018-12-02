local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local e = Roact.createElement

local rootKey = require(Modules.Plugin.Components.rootKey)

local RootPortal = Roact.Component:extend("RootPortal")

function RootPortal:init()
    self._ref = self._context[rootKey]
end

function RootPortal:render()
    if self._ref.current then
        return e(Roact.Portal, {
            target = self._ref.current,
        }, self.props[Roact.Children])
    else
        return nil
    end
end

function RootPortal:didMount()
    self:setState({})
end

return RootPortal
