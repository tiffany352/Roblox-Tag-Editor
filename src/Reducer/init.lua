local Search = require(script.Search)

return function(state, action)
    state = state or {}
    return {
        Search = Search(state.Search, action),
    }
end
