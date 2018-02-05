local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Actions = require(script.Parent.Parent.Actions)
local Constants = require(script.Parent.Parent.Constants)

local function Search(props)
    return Roact.createElement("Frame", {
        Size = props.Size,
        BackgroundTransparency = 1.0,
    }, {
        SearchBarContainer = Roact.createElement("ImageLabel", {
            BackgroundTransparency = 1.0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -10, 1, -10),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(32, 32, 32, 32),
            Image = "rbxasset://textures/ui/Keyboard/key_selection_9slice.png", -- rbxassetid://1353028396
        }, {
            SearchBar = Roact.createElement("TextBox", {
                AnchorPoint = Vector2.new(.5, .5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, -20, 0, 20),
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
