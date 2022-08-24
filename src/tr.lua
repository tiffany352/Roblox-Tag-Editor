local Studio = game:GetService("StudioService")
local Config = require(script.Parent.Config)

local Localization = script.Parent.Localization

local defaultLocale = "en_US"
local translator = Localization:GetTranslator(Studio.StudioLocaleId)
-- Just in case the string hasn't been translated
local fallback = Studio.StudioLocaleId ~= defaultLocale and Localization:GetTranslator(defaultLocale)

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
