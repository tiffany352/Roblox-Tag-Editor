local Studio = game:GetService("StudioService")
local Config = require(script.Parent.Config)

local Localization = script.Parent.Localization

local supportedLanguages = {
	["en-us"] = "en-us",
}

local function tr(key: string, args: any): string
	local locale = supportedLanguages[Studio.StudioLocaleId] or "en-us"
	local l18n = Localization:GetTranslator(locale)

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
