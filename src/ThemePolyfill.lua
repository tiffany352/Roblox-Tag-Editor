local Theme = require(script.Parent.Theme)

local function hex(hex)
	local r = hex / 256 / 256 % 256
	local g = hex / 256 % 256
	local b = hex % 256
	return Color3.fromRGB(r, g, b)
end

local white = Color3.fromRGB(255, 255, 255)
local black = Color3.fromRGB(0, 0, 0)

local function darken(color, alpha)
	return color:lerp(black, alpha)
end

local robloxBlue = Color3.fromRGB(0, 162, 255)
local robloxBlueDark = darken(robloxBlue, 0.2)
local lightGrey = Color3.fromRGB(226, 226, 226)
local darkGrey = Color3.fromRGB(112, 112, 112)
local veryDarkGrey = Color3.fromRGB(64, 64, 48)

local lightColors = {
	-- main colors --

	-- chrome
	border = darkGrey,
	mainSection = white,
	highlightSection = darken(white, 0.1),
	dimmerSection = robloxBlue,
	-- text
	placeholderText = darkGrey,
	dimmerText = veryDarkGrey, -- semibold
	mainText = black,
	highlightText = hex(0x222222),
	titleText = veryDarkGrey,
	inverseText = white,
	dimmerInverseText = darken(white, 0.1),
	-- blues
	button = hex(0x00a2ff),

	mainFlair = darkGrey,
	dimmerFlair = veryDarkGrey,

	-- blue buttons
	blueButtonHover = robloxBlueDark,
	blueButtonPressed = robloxBlue,

	-- grey buttons
	greyButtonDefault = white,
	greyButtonHover = lightGrey,
}

local lightTheme = Theme.new({
	MainSection = {
		BackgroundColor3 = {
			Normal = lightColors.mainSection,
		},
		TextColor3 = {
			Normal = lightColors.mainText,
			Hover = lightColors.highlightText,
			ActiveHover = lightColors.highlightText,
		},
		Font = {
			Normal = Enum.Font.SourceSans,
		},
		PlaceholderColor3 = {
			Normal = lightColors.placeholderText,
			Hover = lightColors.placeholderText,
		},
	},

	ListItem = {
		BackgroundColor3 = {
			Normal = lightColors.mainSection,
			Hover = lightColors.highlightSection,
			Pressed = lightColors.blueButtonPressed,
			Active = lightColors.blueButtonPressed,
			ActiveHover = lightColors.blueButtonHover,
		},
		TextColor3 = {
			Pressed = lightColors.inverseText,
			Active = lightColors.inverseText,
			ActiveHover = lightColors.inverseText,
		},
		FlairColor = {
			Normal = Theme.Nil,
			Hover = lightColors.mainFlair,
			ActiveHover = lightColors.dimmerFlair,
		},
		ShowDivider = {
			Normal = true,
			Hover = true,
			Active = false,
			ActiveHover = false,
		},
	},

	ListItemGroup = {
		TextColor3 = {
			Normal = lightColors.titleText,
		},
	},

	ContextMenuItem = {
		BackgroundColor3 = {
			Normal = lightColors.greyButtonDefault,
			Hover = lightColors.greyButtonHover,
		},
		TextColor3 = {
			Normal = lightColors.mainText,
			Hover = lightColors.mainText,
		},
	},

	ContextMenuHeader = {
		BackgroundColor3 = {
			Normal = lightColors.dimmerSection,
		}
	},

	Topbar = {
		BackgroundColor3 = {
			Normal = lightColors.dimmerSection,
		},
		TextColor3 = {
			Normal = lightColors.inverseText,
		},
	},

	IconPickerSidebar = {
		BackgroundColor3 = {
			Normal = lightColors.highlightSection,
		},
		BorderColor3 = {
			Normal = lightColors.border,
		},
	},

	InstanceItemClass = {
		TextColor3 = {
			Normal = lightColors.dimmerText,
			Active = lightColors.dimmerInverseText,
			ActiveHover = lightColors.dimmerInverseText,
		},
		Font = {
			Normal = Enum.Font.SourceSansSemibold,
			Active = Enum.Font.SourceSansSemibold,
			ActiveHover = Enum.Font.SourceSansSemibold,
		},
	},

	InstanceItemName = {
		TextColor3 = {
			Active = lightColors.inverseText,
			ActiveHover = lightColors.inverseText,
		},
		Font = {
			Normal = Enum.Font.SourceSansSemibold,
			Active = Enum.Font.SourceSansSemibold,
			ActiveHover = Enum.Font.SourceSansSemibold,
		},
	},

	InstanceItemPath = {
		TextColor3 = {
			Normal = lightColors.dimmerText,
			Active = lightColors.dimmerInverseText,
			ActiveHover = lightColors.dimmerInverseText,
		},
		Font = {
			Normal = Enum.Font.SourceSansItalic,
			Active = Enum.Font.SourceSansItalic,
			ActiveHover = Enum.Font.SourceSansItalic,
		},
	},
})

-- From Studio design spec
local darkColors = {
	-- main colors --

	-- chrome
	border = hex(0x222222),
	--inputField = hex(0x252525),
	--scrollbar = hex(0x292929),
	mainSection = hex(0x2e2e2e),
	highlightSection = hex(0x353535),
	--tabbarScrollbar = hex(0x383838),
	-- text
	--disabledText = hex(0x555555),
	dimmerText = hex(0x666666), -- semibold
	titleText = hex(0xaaaaaa),
	mainText = hex(0xcccccc),
	highlightText = hex(0xe5e5e5),
	-- blues
	--linkText = hex(0x35b5ff),
	button = hex(0x00a2ff),
	selectionBackground = hex(0x0b5aaf),

	-- hover states --

	-- ribbon bar icons
	--selectedBackground = hex(0x1c1c1c),
	--selectedBorder = hex(0x353535),
	--hoverBackground = hex(0x252525),
	--hoverBorder = hex(0x353535),

	-- buttons --

	-- blue buttons
	--blueButtonDefault = hex(0x00a2ff),
	blueButtonHover = hex(0x32b5ff),
	blueButtonPressed = hex(0x0074bd),

	-- grey buttons
	greyButtonDefault = hex(0x3a3a3a),
	--greyButtonHover = hex(0x454545),
	--greyButtonPressed = hex(0x292929),
}

local darkTheme = Theme.new({
	mainSectionBg = darkColors.mainSection,
	mainSectionHover = darkColors.highlightSection,
	mainSectionPressed = darkColors.button,
	textNormal = darkColors.mainText,

	MainSection = {
		BackgroundColor3 = {
			Normal = darkColors.mainSection,
		},
		TextColor3 = {
			Normal = darkColors.mainText,
			Hover = darkColors.highlightText,
			ActiveHover = darkColors.highlightText,
		},
		PlaceholderColor3 = {
			Normal = darkColors.dimmerText,
			Hover = darkColors.mainText,
		},
		Font = {
			Normal = Enum.Font.SourceSans,
		},
	},

	ListItem = {
		BackgroundColor3 = {
			Normal = darkColors.mainSection,
			Hover = darkColors.highlightSection,
			Pressed = darkColors.blueButtonPressed,
			Active = darkColors.blueButtonPressed,
			ActiveHover = darkColors.blueButtonPressed,
		},
		FlairColor = {
			Normal = Theme.Nil,
			Hover = darkColors.blueButtonHover,
			ActiveHover = darkColors.blueButtonHover,
		},
		ShowDivider = {
			Normal = true,
			Hover = true,
			Active = false,
			ActiveHover = false,
		},
	},

	ContextMenuHeader = {
		BackgroundColor3 = {
			Normal = darkColors.selectionBackground,
		}
	},

	Topbar = {
		BackgroundColor3 = {
			Normal = darkColors.greyButtonDefault,
		},
	},

	IconPickerSidebar = {
		BackgroundColor3 = {
			Normal = darkColors.highlightSection,
		},
		BorderColor3 = {
			Normal = darkColors.border,
		},
	},

	InstanceItemClass = {
		TextColor3 = {
			Normal = darkColors.titleText,
			Active = darkColors.titleText,
			ActiveHover = darkColors.titleText,
		},
		Font = {
			Normal = Enum.Font.SourceSansSemibold,
			Active = Enum.Font.SourceSansSemibold,
			ActiveHover = Enum.Font.SourceSansSemibold,
		},
	},

	InstanceItemName = {
		TextColor3 = {
			Active = darkColors.Text,
			ActiveHover = darkColors.Text,
		},
		Font = {
			Normal = Enum.Font.SourceSansSemibold,
			Active = Enum.Font.SourceSansSemibold,
			ActiveHover = Enum.Font.SourceSansSemibold,
		},
	},

	InstanceItemPath = {
		TextColor3 = {
			Normal = darkColors.titleText,
			Active = darkColors.titleText,
			ActiveHover = darkColors.titleText,
		},
		Font = {
			Normal = Enum.Font.SourceSansItalic,
			Active = Enum.Font.SourceSansItalic,
			ActiveHover = Enum.Font.SourceSansItalic,
		},
	},
})

return {
	Light = lightTheme,
	Dark = darkTheme,
}
