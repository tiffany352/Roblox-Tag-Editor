local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local TagList = require(script.Parent.TagList)
local Search = require(script.Parent.Search)

return function(props)
    return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    }, {
        UIListLayout = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),

        UIPadding = Roact.createElement("UIPadding", {
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
        }),

        TagList = Roact.createElement(TagList),
        Search = Roact.createElement(Search),
    })
end
