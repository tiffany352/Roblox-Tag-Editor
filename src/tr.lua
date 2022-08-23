local Studio = game:GetService("StudioService")
local Config = require(script.Parent.Config)

local Localization = script.Parent.Localization

local supportedLanguages = {
	["en_US"] = "en-us",
	["es_ES"] = "es-es"
}

local defaultLocale = "en-us"
local locale = supportedLanguages[Studio.StudioLocaleId]

local translator = Localization:GetTranslator(locale or defaultLocale)
local fallback = locale ~= defaultLocale and Localization:GetTranslator(defaultLocale) -- JIC the string hasn't been translated

local function tr(key: string, args: any): string
	if Config.testLocalization then
		return key
	end

	local ok, result = pcall(function()
		return translator:FormatByKey(key, args)
	end)

	if not ok and fallback then
		ok, result = pcall(function()
			return fallback:FormatByKey(key, args)
		end)
	end

	if ok then
		return result
	else
		warn(string.format("[%s] %s", key, result))
		return key
	end
end

return tr
