local Action = {}
Action.__index = Action

function Action.new(name, func)
    local self = setmetatable({
        _func = func,
        Name = name,
    }, Action)

    return self
end

function Action:__call(...)
    local t = self._func(...)
    t.Type = self
    return t
end

return setmetatable({
    SetSearch = Action.new("SetSearch", require(script.SetSearch)),
    SetTagData = Action.new("SetTagData", require(script.SetTagData)),
    SetGroupData = Action.new("SetGroupData", require(script.SetGroupData)),
    OpenTagMenu = Action.new("OpenTagMenu", require(script.OpenTagMenu)),
    ToggleIconPicker = Action.new("ToggleIconPicker", require(script.ToggleIconPicker)),
    ToggleColorPicker = Action.new("ToggleColorPicker", require(script.ToggleColorPicker)),
    ToggleGroupPicker = Action.new("ToggleGroupPicker", require(script.ToggleGroupPicker)),
    ToggleWorldView = Action.new("ToggleWorldView", require(script.ToggleWorldView)),
    OpenDropdown = Action.new("OpenDropdown", require(script.OpenDropdown)),
    OpenInstanceView = Action.new("OpenInstanceView", require(script.OpenInstanceView)),
}, {
    __index = function(self, k)
        error("No such key `"..tostring(k).."` in Actions")
    end,
})
