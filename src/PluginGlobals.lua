local CoreGui = game:GetService("CoreGui")

local Actions = require(script.Parent.Actions)
local TagManager = require(script.Parent.TagManager)
local tr = require(script.Parent.tr)

type Exports = {
	tagMenu: PluginMenu?,
	currentTagMenu: string?,
	changeIconAction: PluginAction?,
	changeGroupAction: PluginAction?,
	changeColorAction: PluginAction?,
	deleteAction: PluginAction?,
	viewTaggedAction: PluginAction?,
	renameAction: PluginAction?,
	visualizeBox: PluginAction?,
	visualizeSphere: PluginAction?,
	visualizeOutline: PluginAction?,
	visualizeText: PluginAction?,
	visualizeIcon: PluginAction?,
	visualizeHighlight: PluginAction?,
	selectAllAction: PluginAction?,
}

local exports: Exports = {}

function exports.promptPickColor(dispatch, tag: string)
	local module = CoreGui:FindFirstChild("ColorPane")
	if module and module:IsA("ModuleScript") then
		local manager = TagManager.Get()
		local ColorPane = require(module)

		ColorPane.PromptForColor({
			PromptTitle = tr("ColorPane_PromptSelectColor", { Tag = tag }),
			InitialColor = manager:GetColor(tag),
			OnColorChanged = function(color: Color3)
				manager:SetColor(tag, color)
			end,
		})
	else
		dispatch(Actions.ToggleColorPicker(tag))
	end
end

function exports.showTagMenu(dispatch, tag: string)
	task.spawn(function()
		local visualTypes = {
			[exports.visualizeBox] = "Box",
			[exports.visualizeSphere] = "Sphere",
			[exports.visualizeOutline] = "Outline",
			[exports.visualizeText] = "Text",
			[exports.visualizeIcon] = "Icon",
			[exports.visualizeHighlight] = "Highlight",
		}

		exports.currentTagMenu = tag
		local action = exports.TagMenu:ShowAsync()
		exports.currentTagMenu = nil
		if action == exports.changeIconAction then
			dispatch(Actions.ToggleIconPicker(tag))
		elseif action == exports.changeGroupAction then
			dispatch(Actions.ToggleGroupPicker(tag))
		elseif action == exports.changeColorAction then
			exports.promptPickColor(dispatch, tag)
		elseif action == exports.viewTaggedAction then
			dispatch(Actions.OpenInstanceView(tag))
		elseif action == exports.deleteAction then
			TagManager.Get():DelTag(tag)
		elseif action == exports.renameAction then
			dispatch(Actions.SetRenaming(tag, true))
		elseif visualTypes[action] then
			TagManager.Get():SetDrawType(tag, visualTypes[action])
		elseif action ~= nil and action ~= exports.selectAllAction then
			print("Missing handler for action " .. action.Title)
		end
	end)
end

return exports
