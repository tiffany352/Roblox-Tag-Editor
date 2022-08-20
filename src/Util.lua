local Modules = script.Parent.Parent
local Roact = require(Modules.Roact)

local function findIf(array, func: (any) -> boolean)
	for _, item in pairs(array) do
		if func(item) then
			return item
		end
	end
	return nil
end

local b = string.byte
local namedEscapes = {
	[b("\a")] = "\\a",
	[b("\b")] = "\\b",
	[b("\f")] = "\\f",
	[b("\n")] = "\\n",
	[b("\r")] = "\\r",
	[b("\t")] = "\\t",
	[b("\v")] = "\\v",
}
local function escape(char: number): string?
	if namedEscapes[char] then
		return namedEscapes[char]
	end
	if char < 32 or char == 127 then
		return string.format("\\x%02x", char)
	end

	return nil
end

local xmlEscapes = {
	[b("<")] = "&lt;",
	[b(">")] = "&gt;",
	[b("&")] = "&amp;",
}

local function formatColorAttr(color: Color3): string
	return string.format('color="rgb(%d, %d, %d)"', color.R * 255, color.G * 255, color.B * 255)
end

local function escapeTagNameImpl(name: string, escapeFmt: string, errorFmt: string): string
	local output = {}
	local offset = 1
	local len = string.len(name)
	local errorStart = nil
	while offset <= len do
		local ok, ch = pcall(utf8.codepoint, name, offset)
		if ok then
			if errorStart then
				local errorContent = ""
				for i = errorStart, offset - 1 do
					local byte = string.byte(name, i)
					errorContent = errorContent .. string.format("\\x%02x", byte or 0)
				end
				table.insert(output, errorFmt:format(errorContent))
				errorStart = nil
			end
			local escaped = escape(ch)
			local charStr = utf8.char(ch)
			if escaped then
				table.insert(output, escapeFmt:format(escaped))
			elseif xmlEscapes[ch] then
				table.insert(output, xmlEscapes[ch])
			else
				table.insert(output, charStr)
			end
			offset += charStr:len()
		else
			errorStart = errorStart or offset
			offset += 1
		end
	end

	if errorStart then
		local errorContent = ""
		for i = errorStart, offset - 1 do
			local byte = string.byte(name, i)
			errorContent = errorContent .. string.format("\\x%02x", byte or 0)
		end
		table.insert(output, errorFmt:format(errorContent))
		errorStart = nil
	end

	return table.concat(output)
end

local function escapeTextPlain(name: string): string
	return escapeTagNameImpl(name, "%s", "%s")
end

local function escapeTextColored(name: string, theme: StudioTheme): string
	local dimmedColor = theme:GetColor(Enum.StudioStyleGuideColor.DimmedText)
	local errorColor = theme:GetColor(Enum.StudioStyleGuideColor.ErrorText)
	local escapeFmt = "<font " .. formatColorAttr(dimmedColor) .. ">%s</font>"
	local errorFmt = "<font " .. formatColorAttr(errorColor) .. ">%s</font>"

	return escapeTagNameImpl(name, escapeFmt, errorFmt)
end

local function merge(...)
	local map = {}

	for i = 1, select("#", ...) do
		local arg = select(i, ...)
		local ty = typeof(arg)
		if ty ~= "table" then
			error("Expected table for argument #" .. i .. ", got " .. ty)
		end
		for key, value in pairs(arg) do
			if value == Roact.None then
				map[key] = nil
			else
				map[key] = value
			end
		end
	end

	return map
end

local function GenerateOutline(props)
	local OutlineVertices = {
		{ 1, 1, -1 },
		{ -1, 1, -1 },
		{ -1, 1, -1 },
		{ -1, 1, 1 },
		{ -1, 1, 1 },
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 1, 1, -1 },
		{ 1, -1, -1 },
		{ -1, -1, -1 },
		{ -1, -1, -1 },
		{ -1, -1, 1 },
		{ -1, -1, 1 },
		{ 1, -1, 1 },
		{ 1, -1, 1 },
		{ 1, -1, -1 },
		{ 1, 1, -1 },
		{ 1, -1, -1 },
		{ -1, -1, -1 },
		{ -1, 1, -1 },
		{ 1, 1, 1 },
		{ 1, -1, 1 },
		{ -1, -1, 1 },
		{ -1, 1, 1 },
	}
	local Corners = {}
	for _, Vector in OutlineVertices do
		table.insert(
			Corners,
			(CFrame.new(props.Size.X / 2 * Vector[1], props.Size.Y / 2 * Vector[2], props.Size.Z / 2 * Vector[3])).Position
		)
	end
	local Instances = {}
	for i, _ in Corners do
		if i % 2 == 0 then
			continue
		end
		local displacement = Corners[i] - Corners[i + 1]
		table.insert(
			Instances,
			Roact.createElement("CylinderHandleAdornment", {
				Color3 = props.Color3,
				Adornee = props.Adornee,
				AlwaysOnTop = true,
				Height = displacement.Magnitude,
				CFrame = CFrame.lookAt(Corners[i], Corners[i + 1]) * CFrame.new(0, 0, -displacement.Magnitude / 2),
				Radius = 0.033,
				ZIndex = 0,
			})
		)
	end
	if props.Box then
		table.insert(
			Instances,
			Roact.createElement("BoxHandleAdornment", {
				Color3 = props.Color3,
				Transparency = 0.7,
				Adornee = props.Adornee,
				AlwaysOnTop = true,
				Size = props.Size,
				ZIndex = 0,
			})
		)
	end
	return Instances
end

return {
	findIf = findIf,
	escapeTextColored = escapeTextColored,
	escapeTextPlain = escapeTextPlain,
	merge = merge,
	GenerateOutline = GenerateOutline,
}
