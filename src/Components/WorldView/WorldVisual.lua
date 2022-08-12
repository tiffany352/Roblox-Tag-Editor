local CoreGui = game:GetService("CoreGui")

local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)

local BoxAdorn = require(script.Parent.BoxAdorn)
local SphereAdorn = require(script.Parent.SphereAdorn)
local OutlineAdorn = require(script.Parent.OutlineAdorn)
local IconAdorn = require(script.Parent.IconAdorn)
local TextAdorn = require(script.Parent.TextAdorn)
local HighlightAdorn = require(script.Parent.HighlightAdorn)

local function WorldVisual(props)
	local partsList = props.partsList

	local children = {}

	for key, entry in pairs(partsList) do
		local elt
		if entry.DrawType == "Outline" then
			elt = OutlineAdorn
		elseif entry.DrawType == "Box" then
			elt = BoxAdorn
		elseif entry.DrawType == "Sphere" then
			elt = SphereAdorn
		elseif entry.DrawType == "Icon" then
			elt = IconAdorn
		elseif entry.DrawType == "Highlight" then
			elt = HighlightAdorn
		elseif entry.DrawType == "Text" then
			elt = TextAdorn
		else
			error("Unknown DrawType: " .. tostring(entry.DrawType))
		end
		children[key] = Roact.createElement(elt, {
			Adornee = entry.Part,
			Icon = entry.Icon,
			Color = entry.Color,
			TagName = entry.TagName,
			AlwaysOnTop = entry.AlwaysOnTop,
		})
	end

	return Roact.createElement(Roact.Portal, {
		target = CoreGui,
	}, {
		TagEditorWorldView = Roact.createElement("Folder", {}, children),
	})
end

return WorldVisual
