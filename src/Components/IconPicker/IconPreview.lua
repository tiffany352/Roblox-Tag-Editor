local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)
local Icons = require(Modules.Plugin.FamFamFam)
local Constants = require(Modules.Plugin.Constants)
local TextLabel = require(Modules.Plugin.Components.TextLabel)

local IconPreview = Roact.Component:extend("IconPreview")

function IconPreview:render()
	local function update()
		local Vector2new = Vector2.new
		local image = self.props.icon and Icons.Lookup(self.props.icon)
		local rect = image and image.ImageRectOffset or Vector2.new(10000, 10000)
		for y = 0, 16-1 do
			for x = 0, 16-1 do
				local pixel = self.pixels[x * 16 + y]
				pixel.ImageRectOffset = rect + Vector2new(x + 0.5, y + 0.5)
			end
		end
	end

	if self.pixels then
		update()
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(0, 64, 0, 72+20*3),
		Position = self.props.Position,
		BackgroundTransparency = 1.0,
		AnchorPoint = Vector2.new(1, 0),
	}, {
		IconName = Roact.createElement(TextLabel, {
			TextSize = 14,
			TextColor3 = Constants.DarkGrey,
			Size = UDim2.new(0, 64, 0, 20*3),
			Position = UDim2.new(0, 0, 0, 72),
			TextWrapped = true,
			Text = self.props.icon or "",
			TextYAlignment = Enum.TextYAlignment.Top,
		}),
		IconMagnify = Roact.createElement("Frame", {
			Size = UDim2.new(0, 64, 0, 64),
			BorderColor3 = Constants.DarkGrey,
			BackgroundColor3 = Constants.White,

			[Roact.Ref] = function(rbx)
				if rbx == self.oldRbx then return end

				if self.pixels then
					for _,pixel in pairs(self.pixels) do
						pixel:Destroy()
					end
				end

				self.oldRbx = rbx
				self.pixels = {}

				if rbx then
					for x = 0, 15 do
						for y = 0, 15 do
							local image = Instance.new("ImageLabel")
							image.Name = string.format("Pixel [%d, %d]", x, y)
							image.Image = Icons.Asset
							image.ImageRectSize = Vector2.new(0, 0)
							image.Size = UDim2.new(0, 4, 0, 4)
							image.Position = UDim2.new(0, x*4, 0, y*4)
							image.BackgroundTransparency = 1.0
							image.Parent = rbx
							self.pixels[x * 16 + y] = image
						end
					end

					update()
				end
			end,
		})
	})
end

local function mapStateToProps(state)
	return {
		icon = state.HoveredIcon,
	}
end

IconPreview = RoactRodux.connect(mapStateToProps)(IconPreview)

return IconPreview
