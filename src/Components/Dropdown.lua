local ARROW_IMAGE = "rbxasset://textures/StudioToolbox/ArrowDownIconWhite.png"

local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local e = Roact.createElement

local Button = require(Modules.Plugin.Components.Button)
local ListItem = require(Modules.Plugin.Components.ListItem)
local ScrollingFrame = require(Modules.Plugin.Components.ScrollingFrame)
local StudioThemeAccessor = require(Modules.Plugin.Components.StudioThemeAccessor)
local rootKey = require(Modules.Plugin.Components.rootKey)
local RootPortal = require(Modules.Plugin.Components.RootPortal)

local DropdownItem = function(props)
    return e(ListItem, {
        ShowDivider = false,
        Text = props.Text,
        leftClick = props.leftClick,
        ignoresMenuOpen = true,
        TextProps = {
            TextSize = 16,
        }
    })
end

local Dropdown = Roact.PureComponent:extend("Dropdown")

function Dropdown:init()
    self.state = {
        open = false
    }

    self._listRef = Roact.createRef()
end

function Dropdown.getDerivedStateFromProps(nextProps, lastState)
    return {
        dropdownHeight = math.min(120, #nextProps.Options * 26),
    }
end

function Dropdown:render()
    local props = self.props
    local children = {}

    for _, option in ipairs(props.Options) do
        children[option] = e(DropdownItem, {
            Text = option,
            Height = 26,
            leftClick = function()
                self:setState({
                    open = false,
                })

                props.onOptionSelected(option)
            end,
        })
    end

    return StudioThemeAccessor.withTheme(function(theme, themeType)
        return e(Button, {
            Size = props.Size,
            LayoutOrder = props.LayoutOrder,
            Position = props.Position,
            Text = props.CurrentOption,
            [Roact.Event.Changed] = function(rbx)
                local list = self._listRef.current

                if list ~= nil then
                    local buttonPosition = rbx.AbsolutePosition
                    local buttonSize = rbx.AbsoluteSize
                    local viewportHeight = self._context[rootKey].current.AbsoluteSize.Y
                    local remainingHeight = viewportHeight - buttonPosition.Y - buttonSize.Y - 8
                    local listHeight = math.min(remainingHeight, self.state.dropdownHeight)

                    if remainingHeight - self.state.dropdownHeight < -60 then
                        -- There's not enough space below; put the dropdown above the button
                        list.Position = UDim2.new(0, buttonPosition.X, 0, buttonPosition.Y - self.state.dropdownHeight - 4)
                        list.Size = UDim2.new(0, buttonSize.X, 0, self.state.dropdownHeight)
                    else
                        list.Position = UDim2.new(0, buttonPosition.X, 0, buttonPosition.Y + buttonSize.Y + 4)
                        list.Size = UDim2.new(0, buttonSize.X, 0, listHeight)
                    end
                end
            end,

            leftClick = function()
                self:setState({
                    open = not self.state.open,
                })
            end,
        }, {
            Portal = e(RootPortal, nil, {
                OptionList = e(ScrollingFrame, {
                    ShowBorder = true,
                    Size = UDim2.new(1, 0, 0, self.state.dropdownHeight),
                    Visible = self.state.open,
                    List = true,
                    [Roact.Ref] = self._listRef,
                    ZIndex = 5,
                }, children),
            }),
            Arrow = e("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(1, -6, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                Image = ARROW_IMAGE,
                -- FIXME: This needs a non-hardcoded icon color.
                -- The studio theme API doesn't have a class for this :(
                ImageColor3 = themeType == Enum.UITheme.Light and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(242, 242, 242),
            })
        })
    end)
end

return Dropdown
