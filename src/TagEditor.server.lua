--[[
	
	Copyright (c) 2015 Tiffany Bennett

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]

local inactiveColor1 = Color3.fromRGB(0, 0, 0)
local inactiveColor2 = Color3.fromRGB(27, 27, 27)
local activeColor1 = Color3.fromRGB(0, 100, 0)
local activeColor2 = Color3.fromRGB(27, 127, 27)
local ambigColor1 = Color3.fromRGB(0, 0, 120)
local ambigColor2 = Color3.fromRGB(27, 27, 160)
local unknownColor1 = Color3.fromRGB(100, 0, 0)
local unknownColor2 = Color3.fromRGB(160, 27, 27)

local rowHeight = 30

local colorLookup = {
	[0] = inactiveColor1,
	inactiveColor2,
	activeColor1,
	activeColor2,
	ambigColor1,
	ambigColor2,
	unknownColor1,
	unknownColor2,
}

local Collections = game:GetService("CollectionService")
local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")

local mouse = plugin:GetMouse()

local isVisible = false
local draw

local taglistObj
local function getTagListObj(create)
	if taglistObj then
		return taglistObj
	end

	local tl = ServerStorage:FindFirstChild("TagList")

	if create and not tl then
		tl = Instance.new("Folder")
		tl.Name = "Folder"
		tl.Parent = ServerStorage
	end

	if tl then
		tl.ChildAdded:Connect(function()
			if draw then
				draw()
			end
		end)

		tl.ChildRemoved:Connect(function()
			if draw then
				draw()
			end
		end)

		taglistObj = tl
	end

	return taglistObj
end

local function getTaglist(create)
	local taglist = {}
	
	local tl = getTagListObj(create)
	if tl then
		for _,tag in pairs(tl:GetChildren()) do
			if tag:IsA("StringValue") then
				taglist[#taglist+1] = tag.Value
			end
		end
	end
	table.sort(taglist)
	
	return taglist
end

local function createUi()
	local ui = Instance.new("ScreenGui")
	ui.Name = "TagEditorMenu"
	
	local window = Instance.new("Frame")
	window.Name = "Window"
	window.BackgroundTransparency = 1.0
	window.Size = UDim2.new(0, 200, 0, 100)
	window.Active = true
	window.Draggable = true
	window.Parent = ui
	
	local create = Instance.new("ImageButton")
	create.Name = "Create"
	create.BackgroundTransparency = 1.0
	create.Image = 'rbxasset://textures/ui/btn_newWhite.png'
	create.ImageColor3 = Color3.fromRGB(27, 27, 27)
	create.ImageRectOffset = Vector2.new(0, 10)
	create.ImageRectSize = Vector2.new(20, 10)
	create.ImageTransparency = 0.5
	create.ScaleType = Enum.ScaleType.Slice
	create.SliceCenter = Rect.new(10, 0, 10, 0)
	create.Size = UDim2.new(1, 0, 0, rowHeight)
	create.Parent = window
	
	local textbox = Instance.new("TextBox")
	textbox.AnchorPoint = Vector2.new(0, .5)
	textbox.BackgroundTransparency = 1.0
	textbox.Position = UDim2.new(0, 10, .5, 0)
	textbox.Size = UDim2.new(1, -10, 0, 20)
	textbox.ClearTextOnFocus = false
	textbox.Text = "Add new tag..."
	textbox.Font = Enum.Font.SourceSans
	textbox.TextColor3 = Color3.fromRGB(194, 194, 194)
	textbox.TextScaled = true
	textbox.Parent = create
	
	local firstFocus = true
	textbox.Focused:Connect(function()
		if firstFocus then
			firstFocus = false
			textbox.Text = ""
			textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end)
	textbox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			local text = textbox.Text
			local value = Instance.new("StringValue")
			value.Name = text
			value.Value = text
			value.Parent = getTagListObj('create')
			textbox.Text = ''
		end
		if #textbox.Text == 0 then
			textbox.Text = "Add new tag..."
			textbox.TextColor3 = Color3.fromRGB(194, 194, 194)
			firstFocus = true
		end
	end)

	local top = Instance.new("ImageLabel")
	top.Name = "Top"
	top.BackgroundTransparency = 1.0
	top.Size = UDim2.new(1, 0, 0, rowHeight)
	top.Image = 'rbxasset://textures/ui/btn_newBlue.png'
	top.ImageRectSize = Vector2.new(20, 10)
	top.ScaleType = Enum.ScaleType.Slice
	top.SliceCenter = Rect.new(10, 10, 10, 10)
	top.Parent = window
	
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1.0
	label.Position = UDim2.new(0, 0, 0, 0)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Text = "Tag Editor"
	label.Font = Enum.Font.SourceSans
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 18
	label.Parent = top
	
	local tooltip = Instance.new("Frame")
	tooltip.Name = "Tooltip"
	tooltip.BackgroundTransparency = 1.0
	tooltip.Size = UDim2.new(0, 200, 0, 30)
	tooltip.Visible = false
	tooltip.Parent = ui
	
	local bottom = Instance.new("ImageLabel")
	bottom.Name = "Bottom"
	bottom.BackgroundTransparency = 1.0
	bottom.Position = UDim2.new(0, 0, 0, 40)
	bottom.Size = UDim2.new(1, 0, 0, 10)
	bottom.Image = 'rbxasset://textures/ui/btn_newWhite.png'
	bottom.ImageColor3 = Color3.fromRGB(27, 27, 27)
	bottom.ImageRectOffset = Vector2.new(0, 10)
	bottom.ImageRectSize = Vector2.new(20, 10)
	bottom.ImageTransparency = 0.5
	bottom.ScaleType = Enum.ScaleType.Slice
	bottom.SliceCenter = Rect.new(10, 0, 10, 0)
	bottom.Parent = tooltip
	
	local top = Instance.new("ImageLabel")
	top.Name = "Top"
	top.BackgroundTransparency = 1.0
	top.Size = UDim2.new(1, 0, 0, rowHeight)
	top.Image = 'rbxasset://textures/ui/btn_newBlue.png'
	top.ImageRectSize = Vector2.new(20, 10)
	top.ScaleType = Enum.ScaleType.Slice
	top.SliceCenter = Rect.new(10, 10, 10, 10)
	top.Parent = tooltip
	
	local label = Instance.new("TextLabel")
	label.Name = "PartName"
	label.AnchorPoint = Vector2.new(0, .5)
	label.BackgroundTransparency = 1.0
	label.Position = UDim2.new(0, 0, .5, 0)
	label.Size = UDim2.new(1, 0, 0, 20)
	label.Text = "Part"
	label.Font = Enum.Font.SourceSans
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 18
	label.Parent = top
	
	return ui
end

-- rowColor, sampleColor, text, [addToggle, addRemove]
local function createRow(opts)
	local row = Instance.new("ImageLabel")
	row.Name = "Row"
	row.BackgroundTransparency = 1.0
	row.Position = UDim2.new(0, 0, 0, 20)
	row.Size = UDim2.new(1, 0, 0, rowHeight)
	row.Image = 'rbxasset://textures/ui/btn_newWhite.png'
	row.ImageColor3 = opts.rowColor
	row.ImageRectOffset = Vector2.new(0, 10)
	row.ImageRectSize = Vector2.new(20, 1)
	row.ImageTransparency = 0.5
	row.ScaleType = Enum.ScaleType.Slice
	row.SliceCenter = Rect.new(10, 0, 10, 0)
	
	if opts.addRemove then
		local remove = Instance.new("ImageButton")
		remove.Name = "RemoveTag"
		remove.BackgroundTransparency = 1.0
		remove.AnchorPoint = Vector2.new(1, .5)
		remove.Position = UDim2.new(1, -6, 0.5, 0)
		remove.Size = UDim2.new(0, 12, 0, 12)
		remove.Image = 'rbxasset://textures/ui/Keyboard/close_button_icon.png'
		remove.Parent = row
	end
	
	local toggle
	if opts.addToggle then
		toggle = Instance.new("ImageButton")
		toggle.Name = "Toggle"
		toggle.BackgroundTransparency = 1.0
		toggle.Size = UDim2.new(1, -20, 1, 0)
		toggle.Parent = row
	end
	
	local sample = Instance.new("ImageLabel")
	sample.Name = "ColorSample"
	sample.AnchorPoint = Vector2.new(0, .5)
	sample.BackgroundTransparency = 1.0
	sample.Position = UDim2.new(0, 5, 0.5, 0)
	sample.Size = UDim2.new(0, 20, 0, 20)
	sample.Image = 'rbxasset://textures/ui/btn_newWhite.png'
	sample.ImageColor3 = opts.sampleColor or Color3.fromRGB(255, 255, 255)
	sample.ImageTransparency = opts.sampleTransparency or 0.0
	sample.Parent = toggle or row
	
	local tag = Instance.new("TextLabel")
	tag.Name = "Tag"
	tag.AnchorPoint = Vector2.new(0, .5)
	tag.BackgroundTransparency = 1.0
	tag.Position = UDim2.new(0, 30, .5, 0)
	tag.Size = UDim2.new(1, -30, 0, 20)
	tag.Text = opts.text
	tag.TextScaled = true
	tag.Font = Enum.Font.SourceSans
	tag.TextSize = 20
	tag.TextColor3 = Color3.fromRGB(255, 255, 255)
	tag.TextXAlignment = Enum.TextXAlignment.Left
	tag.Parent = toggle or row
	
	return row
end

local ui = createUi()
local selections = {}

local ttRows = {}
local function tooltip()
	for _,row in pairs(ttRows) do
		row:Destroy()
	end
	ttRows = {}
	if not ui.Parent then return end
	local target = mouse.Target
	local tags = target and Collections:GetTags(target)
	if target and tags and #tags > 0 then
		local taglist = getTaglist()
		local reverseTaglist = {}
		for i,name in pairs(taglist) do
			reverseTaglist[name] = i
		end
		
		table.sort(tags)
		for i,name in pairs(tags) do
			local row = createRow {
				rowColor = colorLookup[i % 2],
				sampleColor = reverseTaglist[name] and Color3.fromHSV(reverseTaglist[name] / #taglist, 1, 1),
				sampleTransparency = not reverseTaglist[name] and 0.9,
				text = name,
			}
			row.Position = UDim2.new(0, 0, 0, i * rowHeight)
			row.Parent = ui.Tooltip
			ttRows[#ttRows+1] = row
		end
		ui.Tooltip.Top.PartName.Text = target.Name
		ui.Tooltip.Bottom.Position = UDim2.new(0, 0, 0, (#tags + 1) * rowHeight)
		ui.Tooltip.Bottom.ImageColor3 = colorLookup[(#tags+1) % 2]
		
		ui.Tooltip.Position = UDim2.new(0, mouse.X, 0, mouse.Y)

		ui.Tooltip.Visible = true
	else
		ui.Tooltip.Visible = false
	end
end

local rows = {}
function draw()
	for _,sel in pairs(selections) do
		sel:Destroy()
	end
	selections = {}
	for _,row in pairs(rows) do
		row:Destroy()
	end
	rows = {}
	
	if not isVisible then ui.Parent = nil return end
	
	ui.Parent = game:GetService("CoreGui")
	
	local taglist = getTaglist()
	local isKnown = {}
	for _,tag in pairs(taglist) do
		isKnown[tag] = true
	end
	local knownCount = #taglist
	local isUnknown = {}
	for _,selection in pairs(Selection:Get()) do
		for _,tag in pairs(Collections:GetTags(selection)) do
			if not isKnown[tag] and not isUnknown[tag] then
				taglist[#taglist+1] = tag
				isUnknown[tag] = true
			end
		end
	end

	for i,name in pairs(taglist) do
		local allActive = true
		local noneActive = true
		local selection = Selection:Get()
		if #selection == 0 then allActive = false end
		for _,selected in pairs(selection) do
			if Collections:HasTag(selected, name) then
				noneActive = false
			else
				allActive = false 
			end
		end
		local index = (i % 2) + ((isUnknown[name] and 6) or (not noneActive and not allActive and 4) or (allActive and 2) or 0)
		local row = createRow{
			sampleColor = isKnown[name] and Color3.fromHSV(i / knownCount, 1, 1),
			sampleTransparency = not isKnown[name] and 0.9,
			rowColor = colorLookup[index],
			text = name,
			addToggle = true,
			addRemove = true,
		}
		row.Position = UDim2.new(0, 0, 0, i * rowHeight)
		row.Parent = ui.Window
		rows[#rows+1] = row
		row.Toggle.MouseButton1Click:Connect(function()
			if isUnknown[name] then
				local value = Instance.new("StringValue")
				value.Name = name
				value.Value = name
				local tl = getTagListObj('create')
				value.Parent = tl
			end
			for _,selected in pairs(Selection:Get()) do
				if isUnknown[name] or not allActive then
					Collections:AddTag(selected, name)
				else
					Collections:RemoveTag(selected, name)
				end
			end
			draw()
		end)
		row.RemoveTag.MouseButton1Click:Connect(function()
			for _,selected in pairs(Selection:Get()) do
				Collections:RemoveTag(selected, name)
			end
			local tl = getTagListObj()
			if tl then
				for _,tag in pairs(tl:GetChildren()) do
					if tag.Value == name then
						tag:Destroy()
					end
				end
			end
			draw()
		end)
	end

	ui.Window.Create.Position = UDim2.new(0, 0, 0, (#taglist + 1) * rowHeight)
	ui.Window.Create.ImageColor3 = colorLookup[(#taglist + 1) % 2]
	ui.Window.Size = UDim2.new(0, 200, 0, (#taglist + 2) * rowHeight)
	
	local reverseTaglist = {}
	local closest = {}
	local alreadyPicked = {}
	for i, name in pairs(taglist) do
		if isKnown[name] then
			reverseTaglist[name] = i
			for _,inst in pairs(Collections:GetTagged(name)) do
				if not alreadyPicked[inst] and (inst:IsA("BasePart") or inst:IsA("Model")) then
					alreadyPicked[inst] = true
					closest[#closest+1] = inst
				end
			end
		end
	end
	
	local cam = workspace.CurrentCamera and workspace.CurrentCamera.CFrame.p or Vector3.new()
	table.sort(closest, function(a, b)
		if a:IsA("Model") then
			if a.PrimaryPart then
				a = a.PrimaryPart
			else
				a = a:FindFirstChildWhichIsA("BasePart")
			end
		end
		if b:IsA("Model") then
			if b.PrimaryPart then
				b = b.PrimaryPart
			else
				b = b:FindFirstChildWhichIsA("BasePart")
			end
		end
		if not a and b then return true end
		if not a or not b then return false end
		local ap = (a.Position - cam)
		local bp = (b.Position - cam)
		return ap:Dot(ap) < bp:Dot(bp)
	end)
	
	for i = 1, math.min(#closest, 1000) do
		local inst = closest[i]
		local tags = Collections:GetTags(inst)
		if #tags > 0 then
			local h = 0
			local hasKnown = false
			for j = 1, #tags do
				local v = reverseTaglist[tags[j]]
				if v then
					hasKnown = true
					h = h + v / knownCount
				end
			end
			if hasKnown then
				local color = Color3.fromHSV(h / #tags, 1, 1)
				local sel = Instance.new("SelectionBox")
				sel.LineThickness = 0.02
				sel.SurfaceTransparency = 0.8
				sel.Color3 = color
				sel.SurfaceColor3 = color
				sel.Adornee = inst
				sel.Parent = game:GetService("CoreGui")
				selections[#selections+1] = sel
			end
		end
	end

	tooltip()
end

plugin = plugin
local toolbar = plugin:CreateToolbar("Tag Editor")
local button = toolbar:CreateButton("Tag Editor", "Opens the tag editing menu", "rbxasset://textures/ui/TixIcon.png")
button.Click:Connect(function()
	isVisible = not isVisible
	draw()
end)

ServerStorage.ChildAdded:Connect(function(child)
	if ui.Parent and child.Name == "TagList" then
		getTagListObj()
		draw()
	end
end)
ServerStorage.ChildRemoved:Connect(function(child)
	if ui.Parent and child.Name == "TagList" then
		taglistObj = nil
		getTagListObj()
		draw()
	end
end)

getTagListObj()

Selection.SelectionChanged:Connect(function()
	if ui.Parent then
		draw()
	end
end)

local debounce = -math.huge
local cameraChangedConn
local function addcamera()
	if cameraChangedConn then cameraChangedConn:Disconnect() end
	if not workspace.CurrentCamera then return end
	cameraChangedConn = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
		if ui.Parent and time() > debounce then
			debounce = time() + 0.1
			draw()
		elseif ui.Parent then
			tooltip()
		end
	end)
end
addcamera()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(addcamera)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		tooltip()
	end
end)