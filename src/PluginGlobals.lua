local Actions = require(script.Parent.Actions)
local TagManager = require(script.Parent.TagManager)

type Exports = {
	tagMenu: PluginMenu?,
	changeIconAction: PluginAction?,
	changeGroupAction: PluginAction?,
	changeColorAction: PluginAction?,
	deleteAction: PluginAction?,
	viewTaggedAction: PluginAction?,
	visualizeBox: PluginAction?,
	visualizeSphere: PluginAction?,
	visualizeOutline: PluginAction?,
	visualizeText: PluginAction?,
	visualizeIcon: PluginAction?,
}

local exports: Exports = {}

function exports.showTagMenu(dispatch, tag: string)
	coroutine.wrap(function()
		local visualTypes = {
			[exports.visualizeBox] = "Box",
			[exports.visualizeSphere] = "Sphere",
			[exports.visualizeOutline] = "Outline",
			[exports.visualizeText] = "Text",
			[exports.visualizeIcon] = "Icon",
		}

		local action = exports.TagMenu:ShowAsync()
		if action == exports.changeIconAction then
			dispatch(Actions.ToggleIconPicker(tag))
		elseif action == exports.changeGroupAction then
			dispatch(Actions.ToggleGroupPicker(tag))
		elseif action == exports.changeColorAction then
			dispatch(Actions.ToggleColorPicker(tag))
		elseif action == exports.viewTaggedAction then
			dispatch(Actions.OpenInstanceView(tag))
		elseif action == exports.deleteAction then
			TagManager.Get():DelTag(tag)
		elseif visualTypes[action] then
			TagManager.Get():SetDrawType(tag, visualTypes[action])
		elseif action ~= nil then
			print("Missing handler for action " .. action.Title)
		end
	end)()
end

return exports
