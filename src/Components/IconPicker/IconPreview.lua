local Modules = script.Parent.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local Icons = require(Modules.Plugin.FamFamFam)

local IconPreview = Roact.PureComponent:extend("IconPreview")

function IconPreview:render()
	local scaleFactor = 3

	local function update()
		local Vector2new = Vector2.new
		local image = self.props.icon and Icons.Lookup(self.props.icon)
		local rect = image and image.ImageRectOffset or Vector2.new(10000, 10000)
		for y = 0, 16 - 1 do
			for x = 0, 16 - 1 do
				local pixel = self.pixels[x * 16 + y]
				pixel.ImageRectOffset = rect + Vector2new(x + 0.5, y + 0.5)
			end
		end
	end

	if self.pixels then
		update()
	end

	return Roact.createElement("Frame", {
		Size = self.props.Size,
		BackgroundTransparency = 1,

		[Roact.Ref] = function(rbx)
			if rbx == self.oldRbx then
				return
			end

			if self.pixels then
				for _, pixel in pairs(self.pixels) do
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
						image.Size = UDim2.new(0, scaleFactor, 0, scaleFactor)
						image.Position = UDim2.new(0, x * scaleFactor, 0, y * scaleFactor)
						image.BackgroundTransparency = 1.0
						image.Parent = rbx
						self.pixels[x * 16 + y] = image
					end
				end

				update()
			end
		end,
	})
end

return IconPreview
