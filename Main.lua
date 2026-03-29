local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("Arsenal23UI")
if oldGui then
	oldGui:Destroy()
end

local COLORS = {
	bg = Color3.fromRGB(14, 16, 23),
	panel = Color3.fromRGB(23, 27, 37),
	panelLight = Color3.fromRGB(31, 36, 48),
	text = Color3.fromRGB(235, 237, 243),
	subText = Color3.fromRGB(152, 160, 180),
	accent = Color3.fromRGB(116, 127, 255),
	accentMuted = Color3.fromRGB(83, 92, 181),
	danger = Color3.fromRGB(255, 114, 129),
}

local function make(className, properties, children)
	local inst = Instance.new(className)
	for k, v in pairs(properties or {}) do
		inst[k] = v
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	return inst
end

local screenGui = make("ScreenGui", {
	Name = "Arsenal23UI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

local root = make("Frame", {
	Name = "Root",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(620, 410),
	BackgroundColor3 = COLORS.bg,
	BorderSizePixel = 0,
	Parent = screenGui,
})

make("UICorner", { CornerRadius = UDim.new(0, 14), Parent = root })
make("UIStroke", {
	Color = Color3.fromRGB(43, 48, 64),
	Thickness = 1,
	Transparency = 0.2,
	Parent = root,
})

make("ImageLabel", {
	Name = "Glow",
	BackgroundTransparency = 1,
	Image = "rbxassetid://5028857084",
	ImageColor3 = COLORS.accent,
	ImageTransparency = 0.82,
	ScaleType = Enum.ScaleType.Slice,
	SliceCenter = Rect.new(24, 24, 276, 276),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(1.4, 1.4),
	ZIndex = 0,
	Parent = root,
})

local topBar = make("Frame", {
	Name = "TopBar",
	BackgroundColor3 = COLORS.panel,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 54),
	Parent = root,
})
make("UICorner", { CornerRadius = UDim.new(0, 14), Parent = topBar })

make("TextLabel", {
	Name = "Title",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(18, 10),
	Size = UDim2.fromOffset(220, 34),
	Text = "Arsenal23 Interface",
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = COLORS.text,
	Parent = topBar,
})

make("TextLabel", {
	Name = "Subtitle",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(19, 29),
	Size = UDim2.fromOffset(220, 20),
	Text = "Insert to show / hide",
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = COLORS.subText,
	Parent = topBar,
})

local tabButtons = make("Frame", {
	Name = "TabButtons",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -14, 0.5, 0),
	Size = UDim2.fromOffset(260, 38),
	Parent = topBar,
})

make("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 10),
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Parent = tabButtons,
})

local content = make("Frame", {
	Name = "Content",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(14, 68),
	Size = UDim2.new(1, -28, 1, -82),
	Parent = root,
})

local pages = {}
local buttons = {}
local currentTab = "Combat"

local function createTabButton(name)
	local btn = make("TextButton", {
		Name = name .. "Button",
		AutoButtonColor = false,
		BackgroundColor3 = COLORS.panelLight,
		Size = UDim2.fromOffset(120, 32),
		Text = name,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = COLORS.subText,
		Parent = tabButtons,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btn })
	return btn
end

local function createPage(name)
	local page = make("Frame", {
		Name = name .. "Page",
		BackgroundColor3 = COLORS.panel,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = content,
	})
	make("UICorner", { CornerRadius = UDim.new(0, 12), Parent = page })

	local holder = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 14),
		Size = UDim2.new(1, -28, 1, -28),
		Parent = page,
	})

	make("UIListLayout", {
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = holder,
	})

	return page, holder
end

local function createSectionTitle(parent, text)
	return make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Text = text,
		Font = Enum.Font.GothamSemibold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = COLORS.text,
		Parent = parent,
	})
end

local function createToggle(parent, title, default)
	local value = default or false
	local row = make("Frame", {
		BackgroundColor3 = COLORS.panelLight,
		Size = UDim2.new(1, 0, 0, 50),
		Parent = parent,
	})
	make("UICorner", { CornerRadius = UDim.new(0, 10), Parent = row })

	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -80, 1, 0),
		Text = title,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = COLORS.text,
		Parent = row,
	})

	local toggle = make("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(46, 24),
		BackgroundColor3 = value and COLORS.accent or Color3.fromRGB(66, 72, 94),
		Parent = row,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggle })

	local knob = make("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(value and 1 or 0, value and -21 or 3, 0.5, 0),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = Color3.fromRGB(245, 247, 255),
		Parent = toggle,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

	local button = make("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Parent = row,
	})

	local function animateToggle(state)
		TweenService:Create(toggle, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = state and COLORS.accent or Color3.fromRGB(66, 72, 94),
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(state and 1 or 0, state and -21 or 3, 0.5, 0),
		}):Play()
	end

	button.MouseButton1Click:Connect(function()
		value = not value
		animateToggle(value)
	end)

	return {
		Get = function()
			return value
		end,
		Set = function(state)
			value = state
			animateToggle(value)
		end,
	}
end

local function createSlider(parent, title, min, max, default)
	local current = default or min
	local dragging = false

	local card = make("Frame", {
		BackgroundColor3 = COLORS.panelLight,
		Size = UDim2.new(1, 0, 0, 64),
		Parent = parent,
	})
	make("UICorner", { CornerRadius = UDim.new(0, 10), Parent = card })

	local label = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, -24, 0, 18),
		Text = title,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = COLORS.text,
		Parent = card,
	})

	local valueLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -72, 8 / 64, 0),
		Size = UDim2.fromOffset(60, 18),
		Text = tostring(current),
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = COLORS.accent,
		Parent = card,
	})

	local bar = make("Frame", {
		Position = UDim2.fromOffset(12, 38),
		Size = UDim2.new(1, -24, 0, 12),
		BackgroundColor3 = Color3.fromRGB(55, 60, 78),
		Parent = card,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })

	local fill = make("Frame", {
		Size = UDim2.fromScale((current - min) / (max - min), 1),
		BackgroundColor3 = COLORS.accent,
		Parent = bar,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

	local hitbox = make("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Parent = bar,
	})

	local function setFromX(x)
		local percent = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		current = math.floor((min + (max - min) * percent) + 0.5)
		local fillPercent = (current - min) / (max - min)
		TweenService:Create(fill, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(fillPercent, 1),
		}):Play()
		valueLabel.Text = tostring(current)
	end

	hitbox.MouseButton1Down:Connect(function(x)
		dragging = true
		setFromX(x)
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			setFromX(input.Position.X)
		end
	end)

	return {
		Get = function()
			return current
		end,
	}
end

local combatButton = createTabButton("Combat")
local visualsButton = createTabButton("Visuals")
buttons.Combat = combatButton
buttons.Visuals = visualsButton

local combatPage, combatHolder = createPage("Combat")
local visualsPage, visualsHolder = createPage("Visuals")
pages.Combat = combatPage
pages.Visuals = visualsPage

createSectionTitle(combatHolder, "Combat Features")
createToggle(combatHolder, "Enable Combat Assist", false)
createToggle(combatHolder, "Silent Aim (Placeholder)", false)
createSlider(combatHolder, "Aim FOV", 20, 300, 120)

createSectionTitle(visualsHolder, "Visual Settings")
createToggle(visualsHolder, "Player ESP (Placeholder)", false)
createToggle(visualsHolder, "Outline Chams (Placeholder)", false)
createSlider(visualsHolder, "Brightness", 0, 100, 65)

local function setButtonState(button, active)
	TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = active and COLORS.accentMuted or COLORS.panelLight,
		TextColor3 = active and COLORS.text or COLORS.subText,
	}):Play()
end

local function switchTab(target)
	if target == currentTab then
		return
	end
	local outgoing = pages[currentTab]
	local incoming = pages[target]
	if not outgoing or not incoming then
		return
	end

	outgoing.ClipsDescendants = true
	incoming.ClipsDescendants = true
	incoming.Visible = true
	incoming.Position = UDim2.fromOffset(18, 0)
	incoming.BackgroundTransparency = 1

	TweenService:Create(outgoing, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(-18, 0),
		BackgroundTransparency = 1,
	}):Play()

	TweenService:Create(incoming, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 0,
	}):Play()

	task.delay(0.21, function()
		outgoing.Visible = false
		outgoing.Position = UDim2.fromOffset(0, 0)
		outgoing.BackgroundTransparency = 0
	end)

	setButtonState(buttons[currentTab], false)
	currentTab = target
	setButtonState(buttons[currentTab], true)
end

for name, button in pairs(buttons) do
	button.MouseButton1Click:Connect(function()
		switchTab(name)
	end)
end

pages.Combat.Visible = true
setButtonState(buttons.Combat, true)
setButtonState(buttons.Visuals, false)

-- Draggable root frame
local dragging = false
local dragStart = Vector2.zero
local startPosition = root.Position

local function beginDrag(input)
	dragging = true
	dragStart = input.Position
	startPosition = root.Position
end

local function updateDrag(input)
	if not dragging then
		return
	end
	local delta = input.Position - dragStart
	root.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end

topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		beginDrag(input)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		updateDrag(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

local openSize = root.Size
local hidden = false
local animating = false

local function setOpenState(open)
	if animating then
		return
	end
	animating = true

	if open then
		root.Visible = true
		root.Size = UDim2.fromOffset(openSize.X.Offset * 0.92, openSize.Y.Offset * 0.92)
		root.BackgroundTransparency = 0.2
		TweenService:Create(root, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = openSize,
			BackgroundTransparency = 0,
		}):Play()
		task.delay(0.24, function()
			animating = false
		end)
	else
		local closeTween = TweenService:Create(root, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.fromOffset(openSize.X.Offset * 0.9, openSize.Y.Offset * 0.9),
			BackgroundTransparency = 0.35,
		})
		closeTween:Play()
		closeTween.Completed:Wait()
		root.Visible = false
		root.Size = openSize
		root.BackgroundTransparency = 0
		animating = false
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.Insert then
		hidden = not hidden
		setOpenState(not hidden)
	end
end)

setOpenState(true)
