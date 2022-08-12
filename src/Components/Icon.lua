local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Icons = require(Modules.Plugin.FamFamFam)
local Emoji = require(Modules.Plugin.Emoji)
local Util = require(Modules.Plugin.Util)

local function EmojiIcon(props)
	local defaultProps = {
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundTransparency = 1.0,
		Font = Enum.Font.SourceSans,
		TextSize = 22,
		TextScaled = props.TextScaled,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		AutoLocalize = false,

		[Roact.Event.MouseButton1Click] = props.onClick,

		[Roact.Event.MouseEnter] = function()
			if props.onHover then
				props.onHover(true)
			end
		end,

		[Roact.Event.MouseLeave] = function()
			if props.onHover then
				props.onHover(false)
			end
		end,
	}

	return Roact.createElement(
		props.onClick and "TextButton" or "TextLabel",
		Util.merge(defaultProps, props, {
			onClick = Roact.None,
			onHover = Roact.None,
		})
	)
end

local function ImageIcon(props)
	local defaultProps = {
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundTransparency = 1.0,
		ResampleMode = Enum.ResamplerMode.Pixelated,

		[Roact.Event.MouseButton1Click] = props.onClick,

		[Roact.Event.MouseEnter] = function()
			if props.onHover then
				props.onHover(true)
			end
		end,

		[Roact.Event.MouseLeave] = function()
			if props.onHover then
				props.onHover(false)
			end
		end,
	}

	return Roact.createElement(
		props.onClick and "ImageButton" or "ImageLabel",
		Util.merge(defaultProps, props, {
			onClick = Roact.None,
			onHover = Roact.None,
		})
	)
end

local function Icon(props)
	if props.Name:sub(1, 13) == "rbxassetid://" then
		return Roact.createElement(
			ImageIcon,
			Util.merge(props, {
				Name = Roact.None,
				TextScaled = Roact.None,
				TextSize = Roact.None,
				Image = props.Name,
			})
		)
	elseif props.Name:sub(1, 6) == "emoji:" then
		local text = props.Name:sub(7, -1)
		local emoji = Emoji.getNamedEmoji(text)
		if not emoji and not text:match("^[a-zA-Z%-_]+$") then
			emoji = text
		elseif not emoji then
			emoji = "❌"
		end
		return Roact.createElement(
			EmojiIcon,
			Util.merge(props, {
				Name = Roact.None,
				Text = emoji,
				TextScaled = props.TextScaled,
			})
		)
	else
		local imageProps = Icons.Lookup(props.Name) or Icons.Lookup("computer_error")
		return Roact.createElement(
			ImageIcon,
			Util.merge(props, {
				Name = Roact.None,
				TextScaled = Roact.None,
				TextSize = Roact.None,
				Image = imageProps.Image,
				-- Adding these super tiny offsets prevents bleedover from
				-- neighboring pixels.
				ImageRectOffset = imageProps.ImageRectOffset + Vector2.new(0.001, 0.001),
				ImageRectSize = imageProps.ImageRectSize - Vector2.new(0.0005, 0.0005),
			})
		)
	end
end

return Icon
