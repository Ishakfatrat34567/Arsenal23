local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local existing = playerGui:FindFirstChild("StrikewareUI")
if existing then
	existing:Destroy()
end

local COLORS = {
	bg = Color3.fromRGB(14, 16, 23),
	panel = Color3.fromRGB(23, 27, 37),
	panelLight = Color3.fromRGB(31, 36, 48),
	text = Color3.fromRGB(235, 237, 243),
	subText = Color3.fromRGB(152, 160, 180),
	accent = Color3.fromRGB(116, 127, 255),
	accentMuted = Color3.fromRGB(83, 92, 181),
	good = Color3.fromRGB(93, 224, 134),
}

local function make(className, properties)
	local instance = Instance.new(className)
	for key, value in pairs(properties or {}) do
		instance[key] = value
	end
	return instance
end

local screenGui = make("ScreenGui", {
	Name = "StrikewareUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 10000,
	OnTopOfCoreBlur = true,
	Parent = playerGui,
})

local espLayer = make("Folder", {
	Name = "ESPLayer",
	Parent = screenGui,
})

local root = make("Frame", {
	Name = "Root",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(620, 430),
	BackgroundColor3 = COLORS.bg,
	BorderSizePixel = 0,
	Parent = screenGui,
})

make("UICorner", {
	CornerRadius = UDim.new(0, 14),
	Parent = root,
})

make("UIStroke", {
	Color = Color3.fromRGB(43, 48, 64),
	Thickness = 1,
	Transparency = 0.2,
	Parent = root,
})

local topBar = make("Frame", {
	Name = "TopBar",
	BackgroundColor3 = COLORS.panel,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 54),
	Parent = root,
})

make("UICorner", {
	CornerRadius = UDim.new(0, 14),
	Parent = topBar,
})

make("TextLabel", {
	Name = "Title",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(18, 0),
	Size = UDim2.fromOffset(220, 54),
	Text = "Strikeware",
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = COLORS.text,
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
local aimAssistTarget = nil

local function isTeammate(target)
	if not target then
		return false
	end
	if player.Team and target.Team then
		return player.Team == target.Team
	end
	if not player.Neutral and not target.Neutral then
		return player.TeamColor == target.TeamColor
	end
	return false
end

local function canSeeTarget(targetCharacter, targetHead)
	if not targetCharacter or not targetHead then
		return false
	end
	local currentCamera = Workspace.CurrentCamera
	if not currentCamera then
		return false
	end
	local origin = currentCamera.CFrame.Position
	local direction = targetHead.Position - origin
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	local filterList = { screenGui }
	if player.Character then
		table.insert(filterList, player.Character)
	end
	rayParams.FilterDescendantsInstances = filterList
	local result = Workspace:Raycast(origin, direction, rayParams)
	if not result then
		return true
	end
	return result.Instance and result.Instance:IsDescendantOf(targetCharacter)
end

local function createTabButton(name)
	local button = make("TextButton", {
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
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = button })
	return button
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

	local scroller = make("ScrollingFrame", {
		Name = "Scroller",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, 12),
		Size = UDim2.new(1, -24, 1, -24),
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarImageColor3 = COLORS.accent,
		ScrollBarImageTransparency = 0.15,
		ScrollBarThickness = 5,
		Parent = page,
	})

	local list = make("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = scroller,
	})

	list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroller.CanvasSize = UDim2.fromOffset(0, list.AbsoluteContentSize.Y + 6)
	end)

	return page, scroller
end

local function sectionTitle(parent, text)
	return make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		Text = text,
		Font = Enum.Font.GothamSemibold,
		TextSize = 15,
		TextColor3 = COLORS.text,
		TextXAlignment = Enum.TextXAlignment.Left,
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
		Size = UDim2.new(1, -84, 1, 0),
		Text = title,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = COLORS.text,
		TextXAlignment = Enum.TextXAlignment.Left,
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

	local clicker = make("TextButton", {
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.fromScale(1, 1),
		Parent = row,
	})

	local changed = Instance.new("BindableEvent")

	local function animate(state)
		TweenService:Create(toggle, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = state and COLORS.accent or Color3.fromRGB(66, 72, 94),
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(state and 1 or 0, state and -21 or 3, 0.5, 0),
		}):Play()
	end

	clicker.MouseButton1Click:Connect(function()
		value = not value
		animate(value)
		changed:Fire(value)
	end)

	return {
		Get = function()
			return value
		end,
		Set = function(state)
			value = state
			animate(value)
			changed:Fire(value)
		end,
		Changed = changed.Event,
	}
end

local combatButton = createTabButton("Combat")
local visualsButton = createTabButton("Visuals")
buttons.Combat = combatButton
buttons.Visuals = visualsButton

local combatPage, combatScroll = createPage("Combat")
local visualsPage, visualsScroll = createPage("Visuals")
pages.Combat = combatPage
pages.Visuals = visualsPage

sectionTitle(combatScroll, "Combat")
local combatStates = {
	AimAssist = createToggle(combatScroll, "Aim Assist", false),
}

make("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 36),
	Text = "Slow + legit assist toward visible heads",
	Font = Enum.Font.Gotham,
	TextSize = 14,
	TextColor3 = COLORS.subText,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = combatScroll,
})

sectionTitle(visualsScroll, "ESP Features")
local visualStates = {
	Chams = createToggle(visualsScroll, "Chams", false),
	NameESP = createToggle(visualsScroll, "Name ESP", false),
	HealthBarESP = createToggle(visualsScroll, "Health Bar ESP (Left Side)", false),
	DistanceESP = createToggle(visualsScroll, "Distance ESP", false),
}

local function setTabButton(button, active)
	TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = active and COLORS.accentMuted or COLORS.panelLight,
		TextColor3 = active and COLORS.text or COLORS.subText,
	}):Play()
end

local function switchTab(target)
	if target == currentTab then
		return
	end

	local fromPage = pages[currentTab]
	local toPage = pages[target]
	if not fromPage or not toPage then
		return
	end

	toPage.Visible = true
	toPage.Position = UDim2.fromOffset(20, 0)
	toPage.BackgroundTransparency = 1

	TweenService:Create(fromPage, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(-20, 0),
		BackgroundTransparency = 1,
	}):Play()

	TweenService:Create(toPage, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 0,
	}):Play()

	task.delay(0.21, function()
		fromPage.Visible = false
		fromPage.Position = UDim2.fromOffset(0, 0)
		fromPage.BackgroundTransparency = 0
	end)

	setTabButton(buttons[currentTab], false)
	currentTab = target
	setTabButton(buttons[currentTab], true)
end

combatButton.MouseButton1Click:Connect(function()
	switchTab("Combat")
end)

visualsButton.MouseButton1Click:Connect(function()
	switchTab("Visuals")
end)

pages.Combat.Visible = true
setTabButton(buttons.Combat, true)
setTabButton(buttons.Visuals, false)

local dragging = false
local dragStart = Vector2.zero
local startPosition = root.Position

topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPosition = root.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		root.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

local baseSize = root.Size
local hidden = false
local animating = false

local function setOpen(open)
	if animating then
		return
	end
	animating = true

	if open then
		root.Visible = true
		root.Size = UDim2.fromOffset(baseSize.X.Offset * 0.92, baseSize.Y.Offset * 0.92)
		root.BackgroundTransparency = 0.18
		TweenService:Create(root, TweenInfo.new(0.23, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = baseSize,
			BackgroundTransparency = 0,
		}):Play()
		task.delay(0.24, function()
			animating = false
		end)
	else
		local closeTween = TweenService:Create(root, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.fromOffset(baseSize.X.Offset * 0.9, baseSize.Y.Offset * 0.9),
			BackgroundTransparency = 0.35,
		})
		closeTween:Play()
		closeTween.Completed:Wait()
		root.Visible = false
		root.Size = baseSize
		root.BackgroundTransparency = 0
		animating = false
	end
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.Insert then
		hidden = not hidden
		setOpen(not hidden)
	end
end)

local espObjects = {}

local function makeESPForPlayer(targetPlayer)
	local holder = make("Folder", {
		Name = targetPlayer.Name,
		Parent = espLayer,
	})

	local healthBack = make("Frame", {
		Name = "HealthBack",
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 20,
		Parent = screenGui,
	})

	local healthFill = make("Frame", {
		Name = "HealthFill",
		BackgroundColor3 = COLORS.good,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Parent = healthBack,
	})

	local nameLabel = make("TextLabel", {
		Name = "Name",
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(245, 245, 245),
		TextStrokeTransparency = 0.35,
		Visible = false,
		ZIndex = 20,
		Parent = screenGui,
	})

	local distanceLabel = make("TextLabel", {
		Name = "Distance",
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = COLORS.subText,
		TextStrokeTransparency = 0.35,
		Visible = false,
		ZIndex = 20,
		Parent = screenGui,
	})

	espObjects[targetPlayer] = {
		Holder = holder,
		HealthBack = healthBack,
		HealthFill = healthFill,
		Name = nameLabel,
		Distance = distanceLabel,
		Highlight = nil,
	}
end

local function clearESPForPlayer(targetPlayer)
	local object = espObjects[targetPlayer]
	if not object then
		return
	end
	for _, guiObject in pairs(object) do
		if typeof(guiObject) == "Instance" then
			guiObject:Destroy()
		end
	end
	espObjects[targetPlayer] = nil
end

for _, target in ipairs(Players:GetPlayers()) do
	if target ~= player then
		makeESPForPlayer(target)
	end
end

Players.PlayerAdded:Connect(function(target)
	if target ~= player then
		makeESPForPlayer(target)
	end
end)

Players.PlayerRemoving:Connect(function(target)
	clearESPForPlayer(target)
end)

local function ensureHighlight(target, character)
	local object = espObjects[target]
	if not object then
		return nil
	end
	if object.Highlight and object.Highlight.Parent == character then
		return object.Highlight
	end
	if object.Highlight then
		object.Highlight:Destroy()
	end
	local highlight = make("Highlight", {
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
		FillColor = Color3.fromRGB(132, 145, 255),
		FillTransparency = 0.62,
		OutlineColor = Color3.fromRGB(255, 255, 255),
		OutlineTransparency = 0.3,
		Enabled = false,
		Parent = character,
	})
	object.Highlight = highlight
	return highlight
end

local function hideVisual(object)
	object.Name.Visible = false
	object.Distance.Visible = false
	object.HealthBack.Visible = false
	if object.Highlight then
		object.Highlight.Enabled = false
	end
end

RunService.RenderStepped:Connect(function()
	local mousePos = UserInputService:GetMouseLocation()
	local bestTargetHead = nil
	local bestDistance = math.huge

	for target, object in pairs(espObjects) do
		local currentCamera = Workspace.CurrentCamera
		if not currentCamera then
			hideVisual(object)
			continue
		end
		local character = target.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		local head = character and character:FindFirstChild("Head")

		if not character or not humanoid or not rootPart or not head or humanoid.Health <= 0 or isTeammate(target) then
			hideVisual(object)
			continue
		end

		local topPos, onScreenTop = currentCamera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3.2, 0))
		local bottomPos, onScreenBottom = currentCamera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3.2, 0))
		if not onScreenTop or not onScreenBottom then
			hideVisual(object)
			continue
		end

		local headPos, headOnScreen = currentCamera:WorldToViewportPoint(head.Position)
		local visibleTarget = canSeeTarget(character, head)
		if combatStates.AimAssist.Get() and headOnScreen and visibleTarget then
			local cursorDistance = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
			if cursorDistance < 140 and cursorDistance < bestDistance then
				bestDistance = cursorDistance
				bestTargetHead = head
			end
		end

		local boxHeight = math.abs(topPos.Y - bottomPos.Y)
		local boxWidth = boxHeight * 0.62
		local x = topPos.X - boxWidth / 2
		local y = topPos.Y

		local isName = visualStates.NameESP.Get()
		object.Name.Visible = isName
		if isName then
			object.Name.Text = target.Name
			object.Name.Position = UDim2.fromOffset(x - 30, y - 18)
			object.Name.Size = UDim2.fromOffset(boxWidth + 60, 16)
		end

		local isDistance = visualStates.DistanceESP.Get()
		object.Distance.Visible = isDistance
		if isDistance then
				local studs = (currentCamera.CFrame.Position - rootPart.Position).Magnitude
			object.Distance.Text = string.format("%dm", math.floor(studs))
			object.Distance.Position = UDim2.fromOffset(x - 20, y + boxHeight + 1)
			object.Distance.Size = UDim2.fromOffset(boxWidth + 40, 16)
		end

		local isHealth = visualStates.HealthBarESP.Get()
		object.HealthBack.Visible = isHealth
		if isHealth then
			local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
			object.HealthBack.Position = UDim2.fromOffset(x - 6, y)
			object.HealthBack.Size = UDim2.fromOffset(3, boxHeight)
			object.HealthFill.Size = UDim2.fromScale(1, healthPercent)
			object.HealthFill.BackgroundColor3 = Color3.fromRGB(255 - (200 * healthPercent), 70 + (140 * healthPercent), 90)
		end

			local highlight = ensureHighlight(target, character)
			if highlight then
				highlight.Enabled = visualStates.Chams.Get() and visibleTarget
			end
		end

	aimAssistTarget = bestTargetHead
end)

pcall(function()
	RunService:UnbindFromRenderStep("StrikewareAimAssist")
end)

RunService:BindToRenderStep("StrikewareAimAssist", Enum.RenderPriority.Camera.Value + 1, function()
	if not combatStates.AimAssist.Get() or not aimAssistTarget or not aimAssistTarget.Parent then
		return
	end
	local targetCharacter = aimAssistTarget.Parent
	local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
	local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
	if not targetHumanoid or targetHumanoid.Health <= 0 or isTeammate(targetPlayer) or not canSeeTarget(targetCharacter, aimAssistTarget) then
		return
	end
	local currentCamera = Workspace.CurrentCamera
	local lookAt = CFrame.lookAt(currentCamera.CFrame.Position, aimAssistTarget.Position)
	currentCamera.CFrame = currentCamera.CFrame:Lerp(lookAt, 0.03)
end)

setOpen(true)
