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

return {
    SetSearch = Action.new("SetSearch", require(script.SetSearch)),
    SetTagData = Action.new("SetTagData", require(script.SetTagData)),
}
