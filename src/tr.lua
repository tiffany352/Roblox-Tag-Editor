local Studio = game:GetService("StudioService")

local function tr(key: string, args: any): string
	local l18n = script.Parent.Localization:GetTranslator(Studio.StudioLocaleId)

	return l18n:FormatByKey(key, args)
end

return tr
