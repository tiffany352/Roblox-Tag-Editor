local Studio = game:GetService("StudioService")
local Config = require(script.Parent.Config)

local function tr(key: string, args: any): string
	local l18n = script.Parent.Localization:GetTranslator(Studio.StudioLocaleId)

	if Config.testLocalization then
		return key
	end

	local ok, result = pcall(function()
		return l18n:FormatByKey(key, args)
	end)
	if ok then
		return result
	else
		warn(string.format("[%s] %s", key, result))
		return key
	end
end

return tr
