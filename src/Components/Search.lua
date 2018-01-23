local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Actions = require(script.Parent.Parent.Actions)

local function Search(props)
    return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1.0,
    }, {
        SearchBarContainer = Roact.createElement("ImageLabel", {
            BackgroundTransparency = 1.0,
            Size = UDim2.new(1, 0, 1, 0),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(48, 48, 48, 48),
            Image = "rbxasset://textures/ui/Menu/buttonHover.png", -- rbxassetid://1353028396
        }, {
            SearchBar = Roact.createElement("TextBox", {
                AnchorPoint = Vector2.new(.5, .5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, -40, 1, -20),
                BackgroundTransparency = 1.0,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.SourceSans,
                TextSize = 20,
                PlaceholderText = "Search",
                PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
                TextColor3 = Color3.fromRGB(0, 0, 0),
                Text = props.Search,
                ClearTextOnFocus = false,

                [Roact.Event.Changed] = function(rbx, prop)
                    if prop == 'Text' then
                        props.SetSearch(rbx.Text)
                    end
                end,

                [Roact.Event.InputBegan] = function(rbx, input)
                    if input.UserInputType == Enum.UserInputType.MouseButton2 and input.UserInputState == Enum.UserInputState.Begin then
                        props.SetSearch("")
                    end
                end,
            }),
        })
    })
end

Search = RoactRodux.connect(function(store)
    local state = store:getState()

    return {
        Search = state.Search,
        SetSearch = function(text)
            store:dispatch(Actions.SetSearch(text))
        end
    }
end)(Search)

return Search
