-- ============================================
-- Roblox Universal Hub - Komplettes Executor GUI v2.0
-- Compatible mit allen populären Exploits
-- BUGFIX: CornerRadius Fehler behoben
-- Verbesserungen: UICorner, Memory Management, TweenService
-- ============================================

local hub = {}
hub.version = "2.0"
hub.running = true
hub.minimized = false
hub.settings = {
	theme = "Dark",
	transparency = 0.1,
	hotkey = Enum.KeyCode.RightShift,
	guiPosition = nil,
}
hub.data = {
	teleportSlots = {},
	teleportHistory = {},
	deathPosition = nil,
	isFlying = false,
	isNoclipping = false,
	infiniteJumpEnabled = false,
}
hub.connections = {}
hub.loops = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Farb-Themes
local themes = {
	Dark = {
		primary = Color3.fromRGB(20, 20, 20),
		secondary = Color3.fromRGB(35, 35, 35),
		accent = Color3.fromRGB(100, 200, 255),
		text = Color3.fromRGB(255, 255, 255),
		hover = Color3.fromRGB(50, 50, 50),
	},
	Red = {
		primary = Color3.fromRGB(30, 20, 20),
		secondary = Color3.fromRGB(50, 30, 30),
		accent = Color3.fromRGB(255, 80, 80),
		text = Color3.fromRGB(255, 255, 255),
		hover = Color3.fromRGB(60, 35, 35),
	},
	Purple = {
		primary = Color3.fromRGB(30, 20, 40),
		secondary = Color3.fromRGB(45, 30, 60),
		accent = Color3.fromRGB(200, 100, 255),
		text = Color3.fromRGB(255, 255, 255),
		hover = Color3.fromRGB(55, 35, 70),
	},
	Blue = {
		primary = Color3.fromRGB(20, 30, 45),
		secondary = Color3.fromRGB(30, 45, 65),
		accent = Color3.fromRGB(100, 150, 255),
		text = Color3.fromRGB(255, 255, 255),
		hover = Color3.fromRGB(40, 55, 75),
	},
	AMOLED = {
		primary = Color3.fromRGB(0, 0, 0),
		secondary = Color3.fromRGB(10, 10, 10),
		accent = Color3.fromRGB(100, 200, 255),
		text = Color3.fromRGB(255, 255, 255),
		hover = Color3.fromRGB(15, 15, 15),
	}
}

hub.currentTheme = themes[hub.settings.theme] or themes.Dark

-- GUI Struktur
local screenGui
local mainFrame
local tabButtons = {}
local tabContents = {}

-- ============================================
-- UTILITY: UICorner erstellen
-- ============================================

local function createUICorner(parent, radius)
	pcall(function()
		if not parent then return end
		if parent:FindFirstChild("UICorner") then return end
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, radius or 8)
		corner.Parent = parent
		return corner
	end)
end

-- ============================================
-- UTILITY: Connection Management
-- ============================================

local function storeConnection(connection)
	if connection then
		table.insert(hub.connections, connection)
	end
	return connection
end

local function disconnectAll()
	for i, connection in ipairs(hub.connections) do
		pcall(function()
			if connection and connection.Connected then
				connection:Disconnect()
			end
		end)
	end
	hub.connections = {}
	
	for i, loop in ipairs(hub.loops) do
		pcall(function()
			if loop and loop.Connected then
				loop:Disconnect()
			end
		end)
	end
	hub.loops = {}
end

-- ============================================
-- UTILITY: GUI Loading/Saving
-- ============================================

local function saveSettings()
	pcall(function()
		if mainFrame then
			hub.settings.guiPosition = {
				scale = mainFrame.Position.X.Scale,
				offset = mainFrame.Position.X.Offset,
				yScale = mainFrame.Position.Y.Scale,
				yOffset = mainFrame.Position.Y.Offset,
			}
		end
		print("⚙️ Settings gespeichert")
	end)
end

local function loadSettings()
	pcall(function()
		if hub.settings.guiPosition and mainFrame then
			mainFrame.Position = UDim2.new(
				hub.settings.guiPosition.scale,
				hub.settings.guiPosition.offset,
				hub.settings.guiPosition.yScale,
				hub.settings.guiPosition.yOffset
			)
		end
	end)
end

-- ============================================
-- UTILITY: Check GUI Exists
-- ============================================

local function checkGuiExists()
	if screenGui and screenGui.Parent then
		print("⚠️ GUI existiert bereits!")
		return true
	end
	return false
end

-- ============================================
-- GUI CREATION
-- ============================================

function hub:createGui()
	if checkGuiExists() then
		return mainFrame, tabContents
	end

	pcall(function()
		-- Haupt-ScreenGui
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "RobloxUniversalHub"
		screenGui.ResetOnSpawn = false
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

		-- Main Frame (draggable und resizable)
		mainFrame = Instance.new("Frame")
		mainFrame.Name = "MainFrame"
		mainFrame.Size = UDim2.new(0, 600, 0, 700)
		mainFrame.Position = UDim2.new(0.5, -300, 0.5, -350)
		mainFrame.BackgroundColor3 = hub.currentTheme.primary
		mainFrame.BorderSizePixel = 0
		mainFrame.BackgroundTransparency = hub.settings.transparency
		mainFrame.Parent = screenGui
		
		createUICorner(mainFrame, 12)

		-- Top Bar mit Dragbar
		local topBar = Instance.new("Frame")
		topBar.Name = "TopBar"
		topBar.Size = UDim2.new(1, 0, 0, 40)
		topBar.BackgroundColor3 = hub.currentTheme.secondary
		topBar.BorderSizePixel = 0
		topBar.Parent = mainFrame
		
		createUICorner(topBar, 12)

		-- Title
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "Title"
		titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
		titleLabel.Position = UDim2.new(0.02, 0, 0, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = "🎮 Universal Hub v" .. hub.version
		titleLabel.TextColor3 = hub.currentTheme.text
		titleLabel.TextSize = 14
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.Parent = topBar

		-- Minimize Button
		local minimizeBtn = Instance.new("TextButton")
		minimizeBtn.Name = "MinimizeBtn"
		minimizeBtn.Size = UDim2.new(0, 35, 0, 30)
		minimizeBtn.Position = UDim2.new(1, -75, 0.5, -15)
		minimizeBtn.BackgroundColor3 = hub.currentTheme.accent
		minimizeBtn.TextColor3 = hub.currentTheme.text
		minimizeBtn.Text = "−"
		minimizeBtn.TextSize = 20
		minimizeBtn.Font = Enum.Font.GothamBold
		minimizeBtn.BorderSizePixel = 0
		minimizeBtn.Parent = topBar
		
		createUICorner(minimizeBtn, 6)

		-- Close Button
		local closeBtn = Instance.new("TextButton")
		closeBtn.Name = "CloseBtn"
		closeBtn.Size = UDim2.new(0, 35, 0, 30)
		closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
		closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		closeBtn.TextColor3 = hub.currentTheme.text
		closeBtn.Text = "×"
		closeBtn.TextSize = 22
		closeBtn.Font = Enum.Font.GothamBold
		closeBtn.BorderSizePixel = 0
		closeBtn.Parent = topBar
		
		createUICorner(closeBtn, 6)

		-- Main Content Frame mit Tabs
		local contentFrame = Instance.new("Frame")
		contentFrame.Name = "ContentFrame"
		contentFrame.Size = UDim2.new(1, 0, 1, -40)
		contentFrame.Position = UDim2.new(0, 0, 0, 40)
		contentFrame.BackgroundColor3 = hub.currentTheme.primary
		contentFrame.BorderSizePixel = 0
		contentFrame.Parent = mainFrame

		-- Tab Bar (Links)
		local tabBar = Instance.new("Frame")
		tabBar.Name = "TabBar"
		tabBar.Size = UDim2.new(0, 120, 1, 0)
		tabBar.BackgroundColor3 = hub.currentTheme.secondary
		tabBar.BorderSizePixel = 0
		tabBar.Parent = contentFrame

		-- Tab Scroll Frame
		local tabScroll = Instance.new("ScrollingFrame")
		tabScroll.Name = "TabScroll"
		tabScroll.Size = UDim2.new(1, 0, 1, 0)
		tabScroll.BackgroundTransparency = 1
		tabScroll.BorderSizePixel = 0
		tabScroll.ScrollBarThickness = 4
		tabScroll.Parent = tabBar

		-- Content Area
		local contentArea = Instance.new("Frame")
		contentArea.Name = "ContentArea"
		contentArea.Size = UDim2.new(1, -120, 1, 0)
		contentArea.Position = UDim2.new(0, 120, 0, 0)
		contentArea.BackgroundColor3 = hub.currentTheme.primary
		contentArea.BorderSizePixel = 0
		contentArea.Parent = contentFrame

		-- Tabs erstellen
		local tabs = {
			{name = "Teleport", icon = "📍"},
			{name = "Movement", icon = "🚀"},
			{name = "Utility", icon = "⚙️"},
			{name = "Death Return", icon = "☠️"},
			{name = "Settings", icon = "🔧"}
		}

		local yOffset = 5
		for i, tab in ipairs(tabs) do
			-- Tab Button
			local tabBtn = Instance.new("TextButton")
			tabBtn.Name = tab.name .. "Tab"
			tabBtn.Size = UDim2.new(1, -10, 0, 38)
			tabBtn.Position = UDim2.new(0, 5, 0, yOffset)
			tabBtn.BackgroundColor3 = i == 1 and hub.currentTheme.accent or hub.currentTheme.primary
			tabBtn.TextColor3 = hub.currentTheme.text
			tabBtn.Text = tab.icon .. " " .. tab.name
			tabBtn.TextSize = 11
			tabBtn.Font = Enum.Font.Gotham
			tabBtn.BorderSizePixel = 0
			tabBtn.Parent = tabScroll
			
			createUICorner(tabBtn, 6)
			tabButtons[tab.name] = tabBtn

			-- Tab Content Frame
			local tabContent = Instance.new("ScrollingFrame")
			tabContent.Name = tab.name .. "Content"
			tabContent.Size = UDim2.new(1, 0, 1, 0)
			tabContent.Position = UDim2.new(0, 0, 0, 0)
			tabContent.BackgroundTransparency = 1
			tabContent.BorderSizePixel = 0
			tabContent.ScrollBarThickness = 4
			tabContent.Visible = (i == 1)
			tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
			tabContent.Parent = contentArea
			tabContents[tab.name] = tabContent

			yOffset = yOffset + 43
		end

		tabScroll.CanvasSize = UDim2.new(0, 0, 0, yOffset)

		-- Drag Funktionalität
		hub:makeDraggable(mainFrame, topBar)

		-- Button Funktionen
		storeConnection(minimizeBtn.MouseButton1Click:Connect(function()
			hub.minimized = not hub.minimized
			contentFrame.Visible = not hub.minimized
			
			local targetSize = hub.minimized and UDim2.new(0, 600, 0, 40) or UDim2.new(0, 600, 0, 700)
			local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = targetSize})
			tween:Play()
		end))

		storeConnection(closeBtn.MouseButton1Click:Connect(function()
			hub:destroy()
		end))

		-- Tab Button Callbacks
		for tabName, tabBtn in pairs(tabButtons) do
			storeConnection(tabBtn.MouseButton1Click:Connect(function()
				for tName, tBtn in pairs(tabButtons) do
					local targetColor = tName == tabName and hub.currentTheme.accent or hub.currentTheme.primary
					tBtn.BackgroundColor3 = targetColor
				end
				for tName, tContent in pairs(tabContents) do
					tContent.Visible = tName == tabName
				end
			end))
		end

		loadSettings()
	end)

	return mainFrame, contentArea
end

function hub:makeDraggable(frame, dragHandle)
	local dragging = false
	local dragStart
	local startPos

	storeConnection(dragHandle.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end))

	storeConnection(UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end))

	storeConnection(UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end))
end

function hub:addButton(parent, text, callback, yOffset)
	pcall(function()
		local btn = Instance.new("TextButton")
		btn.Name = text
		btn.Size = UDim2.new(1, -20, 0, 35)
		btn.Position = UDim2.new(0, 10, 0, yOffset)
		btn.BackgroundColor3 = hub.currentTheme.accent
		btn.TextColor3 = hub.currentTheme.text
		btn.Text = text
		btn.TextSize = 13
		btn.Font = Enum.Font.Gotham
		btn.BorderSizePixel = 0
		btn.Parent = parent
		
		createUICorner(btn, 6)

		storeConnection(btn.MouseButton1Click:Connect(callback))
		
		-- Hover Effect
		storeConnection(btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = Color3.new(
				hub.currentTheme.accent.R * 0.8,
				hub.currentTheme.accent.G * 0.8,
				hub.currentTheme.accent.B * 0.8
			)
		end))
		
		storeConnection(btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = hub.currentTheme.accent
		end))
		
		return btn
	end)
end

function hub:addLabel(parent, text, yOffset)
	pcall(function()
		local label = Instance.new("TextLabel")
		label.Name = text
		label.Size = UDim2.new(1, -20, 0, 25)
		label.Position = UDim2.new(0, 10, 0, yOffset)
		label.BackgroundTransparency = 1
		label.TextColor3 = hub.currentTheme.text
		label.Text = text
		label.TextSize = 12
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = parent
		return label
	end)
end

function hub:addSlider(parent, name, min, max, default, callback, yOffset)
	pcall(function()
		local container = Instance.new("Frame")
		container.Name = name .. "Container"
		container.Size = UDim2.new(1, -20, 0, 50)
		container.Position = UDim2.new(0, 10, 0, yOffset)
		container.BackgroundTransparency = 1
		container.Parent = parent

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 0, 20)
		label.BackgroundTransparency = 1
		label.TextColor3 = hub.currentTheme.text
		label.Text = name .. ": " .. math.floor(default * 100) / 100
		label.TextSize = 11
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container

		local slider = Instance.new("Frame")
		slider.Name = "Slider"
		slider.Size = UDim2.new(1, 0, 0, 8)
		slider.Position = UDim2.new(0, 0, 0, 25)
		slider.BackgroundColor3 = hub.currentTheme.secondary
		slider.BorderSizePixel = 0
		slider.Parent = container
		
		createUICorner(slider, 4)

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
		fill.BackgroundColor3 = hub.currentTheme.accent
		fill.BorderSizePixel = 0
		fill.Parent = slider
		
		createUICorner(fill, 4)

		local isDragging = false

		storeConnection(slider.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isDragging = true
			end
		end))

		storeConnection(slider.InputEnded:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isDragging = false
			end
		end))

		storeConnection(UserInputService.InputChanged:Connect(function(input, gameProcessed)
			if isDragging then
				local sliderPosition = (Mouse.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
				sliderPosition = math.max(0, math.min(1, sliderPosition))
				fill.Size = UDim2.new(sliderPosition, 0, 1, 0)
				local value = min + (sliderPosition * (max - min))
				label.Text = name .. ": " .. math.floor(value * 100) / 100
				pcall(callback, value)
			end
		end))

		return container
	end)
end

-- ============================================
-- TELEPORT SYSTEM
-- ============================================

function hub:teleportPlayer(position)
	pcall(function()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
			table.insert(hub.data.teleportHistory, position)
		end
	end)
end

function hub:safeTeleport(position, height)
	pcall(function()
		local safePos = position + Vector3.new(0, height or 3, 0)
		hub:teleportPlayer(safePos)
	end)
end

function hub:saveTeleportSlot(name, position)
	hub.data.teleportSlots[name] = position
end

function hub:loadTeleportSlot(name)
	if hub.data.teleportSlots[name] then
		hub:teleportPlayer(hub.data.teleportSlots[name])
	end
end

function hub:undoTeleport()
	pcall(function()
		if #hub.data.teleportHistory > 1 then
			table.remove(hub.data.teleportHistory)
			hub:teleportPlayer(hub.data.teleportHistory[#hub.data.teleportHistory])
		end
	end)
end

-- ============================================
-- MOVEMENT SYSTEM
-- ============================================

function hub:enableFly(speed)
	if hub.data.isFlying then return end
	
	pcall(function()
		hub.data.isFlying = true
		local character = LocalPlayer.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then
			hub.data.isFlying = false
			return
		end

		local rootPart = character.HumanoidRootPart
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVelocity.Parent = rootPart

		local connection
		connection = RunService.RenderStepped:Connect(function()
			if not hub.data.isFlying or not character or not character:FindFirstChild("HumanoidRootPart") then
				pcall(function() bodyVelocity:Destroy() end)
				if connection and connection.Connected then
					connection:Disconnect()
				end
				hub.data.isFlying = false
				return
			end

			local moveDir = Vector3.new(0, 0, 0)
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + (rootPart.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - (rootPart.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - rootPart.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + rootPart.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

			bodyVelocity.Velocity = moveDir * (speed or 50)
		end)
		
		table.insert(hub.loops, connection)
	end)
end

function hub:disableFly()
	hub.data.isFlying = false
end

function hub:enableNoclip()
	if hub.data.isNoclipping then return end
	
	pcall(function()
		hub.data.isNoclipping = true
		local character = LocalPlayer.Character
		if not character then return end

		local connection
		connection = RunService.Stepped:Connect(function()
			if not hub.data.isNoclipping or not character then
				if connection and connection.Connected then
					connection:Disconnect()
				end
				return
			end

			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
		
		table.insert(hub.loops, connection)
	end)
end

function hub:disableNoclip()
	hub.data.isNoclipping = false
	pcall(function()
		local character = LocalPlayer.Character
		if character then
			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end)
end

function hub:enableInfiniteJump()
	if hub.data.infiniteJumpEnabled then return end
	
	hub.data.infiniteJumpEnabled = true
	storeConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Space and hub.data.infiniteJumpEnabled then
			pcall(function()
				local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		end
	end))
end

function hub:setWalkSpeed(speed)
	pcall(function()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.WalkSpeed = speed
		end
	end)
end

function hub:setJumpPower(power)
	pcall(function()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.JumpPower = power
		end
	end)
end

function hub:setGravity(gravity)
	pcall(function()
		workspace.Gravity = gravity
	end)
end

-- ============================================
-- UTILITY SYSTEM
-- ============================================

function hub:enableESP()
	pcall(function()
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				if not player.Character.Head:FindFirstChild("ESPLabel") then
					local billboard = Instance.new("BillboardGui")
					billboard.Name = "ESPLabel"
					billboard.Size = UDim2.new(4, 0, 2, 0)
					billboard.MaxDistance = math.huge
					billboard.Adornee = player.Character.Head

					local textLabel = Instance.new("TextLabel")
					textLabel.BackgroundTransparency = 1
					textLabel.Size = UDim2.new(1, 0, 1, 0)
					textLabel.Text = player.Name
					textLabel.TextColor3 = hub.currentTheme.accent
					textLabel.TextScaled = true
					textLabel.Font = Enum.Font.Gotham
					textLabel.Parent = billboard

					billboard.Parent = player.Character.Head
				end
			end
		end
	end)
end

function hub:copyCoordinates()
	pcall(function()
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local pos = character.HumanoidRootPart.Position
			local coordText = string.format("X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z)
			if setclipboard then
				setclipboard(coordText)
				print("✅ Koordinaten kopiert: " .. coordText)
			end
		end
	end)
end

function hub:showFPS()
	pcall(function()
		if screenGui:FindFirstChild("FPSLabel") then return end
		
		local fpsLabel = Instance.new("TextLabel")
		fpsLabel.Name = "FPSLabel"
		fpsLabel.Size = UDim2.new(0, 150, 0, 30)
		fpsLabel.Position = UDim2.new(0, 10, 0, 10)
		fpsLabel.BackgroundColor3 = hub.currentTheme.secondary
		fpsLabel.TextColor3 = hub.currentTheme.accent
		fpsLabel.Text = "FPS: 0"
		fpsLabel.TextSize = 12
		fpsLabel.Font = Enum.Font.Gotham
		fpsLabel.BorderSizePixel = 0
		fpsLabel.Parent = screenGui
		
		createUICorner(fpsLabel, 6)

		local lastUpdate = tick()
		local frames = 0

		local connection = RunService.RenderStepped:Connect(function()
			frames = frames + 1
			if tick() - lastUpdate >= 1 then
				fpsLabel.Text = "FPS: " .. frames
				frames = 0
				lastUpdate = tick()
			end
		end)
		
		table.insert(hub.loops, connection)
	end)
end

-- ============================================
-- SETUP TABS
-- ============================================

function hub:setupTabs()
	pcall(function()
		local teleportContent = tabContents["Teleport"]
		local movementContent = tabContents["Movement"]
		local utilityContent = tabContents["Utility"]
		local deathReturnContent = tabContents["Death Return"]
		local settingsContent = tabContents["Settings"]

		-- TELEPORT TAB
		hub:addLabel(teleportContent, "📍 Teleport Slots", 10)
		hub:addButton(teleportContent, "Save Current Position", function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local posName = "Slot_" .. tostring(tick()):sub(1, 8)
				hub:saveTeleportSlot(posName, char.HumanoidRootPart.Position)
				print("✅ Position gespeichert: " .. posName)
			end
		end, 40)

		hub:addButton(teleportContent, "Click to Teleport", function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") and Mouse.Target then
				hub:teleportPlayer(Mouse.Hit.Position + Vector3.new(0, 3, 0))
			end
		end, 85)

		hub:addButton(teleportContent, "Undo Teleport", function()
			hub:undoTeleport()
		end, 130)

		hub:addButton(teleportContent, "Safe Teleport", function()
			if Mouse.Target then
				hub:safeTeleport(Mouse.Hit.Position, 5)
			end
		end, 175)

		-- MOVEMENT TAB
		hub:addLabel(movementContent, "🚀 Movement", 10)
		hub:addButton(movementContent, "Fly [ON/OFF]", function()
			if hub.data.isFlying then
				hub:disableFly()
				print("✅ Fly deaktiviert")
			else
				hub:enableFly(50)
				print("✅ Fly aktiviert")
			end
		end, 40)

		hub:addButton(movementContent, "Noclip [ON/OFF]", function()
			if hub.data.isNoclipping then
				hub:disableNoclip()
				print("✅ Noclip deaktiviert")
			else
				hub:enableNoclip()
				print("✅ Noclip aktiviert")
			end
		end, 85)

		hub:addButton(movementContent, "Infinite Jump", function()
			if not hub.data.infiniteJumpEnabled then
				hub:enableInfiniteJump()
				print("✅ Infinite Jump aktiviert")
			end
		end, 130)

		hub:addSlider(movementContent, "Walk Speed", 0, 100, 16, function(value)
			hub:setWalkSpeed(value)
		end, 175)

		hub:addSlider(movementContent, "Jump Power", 0, 100, 50, function(value)
			hub:setJumpPower(value)
		end, 235)

		hub:addSlider(movementContent, "Gravity", 0, 100, 196.2, function(value)
			hub:setGravity(value)
		end, 295)

		-- UTILITY TAB
		hub:addLabel(utilityContent, "⚙️ Utility", 10)
		hub:addButton(utilityContent, "Enable ESP", function()
			hub:enableESP()
			print("✅ ESP aktiviert")
		end, 40)

		hub:addButton(utilityContent, "Copy Coordinates", function()
			hub:copyCoordinates()
		end, 85)

		hub:addButton(utilityContent, "Show FPS", function()
			hub:showFPS()
			print("✅ FPS angezeigt")
		end, 130)

		-- DEATH RETURN TAB
		hub:addLabel(deathReturnContent, "☠️ Auto Teleport on Death", 10)
		hub:addButton(deathReturnContent, "Set Death Position", function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				hub.data.deathPosition = char.HumanoidRootPart.Position
				print("✅ Death Position gespeichert")
			end
		end, 40)

		hub:addButton(deathReturnContent, "Enable Auto Return", function()
			if hub.data.deathPosition then
				local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
				if humanoid then
					storeConnection(humanoid.Died:Connect(function()
						task.wait(0.5)
						hub:teleportPlayer(hub.data.deathPosition)
						print("✅ Teleportiert nach Tod!")
					end))
				end
				print("✅ Auto Return aktiviert")
			else
				print("⚠️ Bitte erst Position speichern!")
			end
		end, 85)

		-- SETTINGS TAB
		hub:addLabel(settingsContent, "🔧 Settings", 10)
		
		hub:addButton(settingsContent, "Theme: Dark", function()
			hub.currentTheme = themes.Dark
			hub.settings.theme = "Dark"
			saveSettings()
			print("✅ Dark Theme aktiviert")
		end, 40)

		hub:addButton(settingsContent, "Theme: Red", function()
			hub.currentTheme = themes.Red
			hub.settings.theme = "Red"
			saveSettings()
			print("✅ Red Theme aktiviert")
		end, 85)

		hub:addButton(settingsContent, "Theme: Purple", function()
			hub.currentTheme = themes.Purple
			hub.settings.theme = "Purple"
			saveSettings()
			print("✅ Purple Theme aktiviert")
		end, 130)

		hub:addButton(settingsContent, "Theme: Blue", function()
			hub.currentTheme = themes.Blue
			hub.settings.theme = "Blue"
			saveSettings()
			print("✅ Blue Theme aktiviert")
		end, 175)

		hub:addButton(settingsContent, "Theme: AMOLED", function()
			hub.currentTheme = themes.AMOLED
			hub.settings.theme = "AMOLED"
			saveSettings()
			print("✅ AMOLED Theme aktiviert")
		end, 220)

		hub:addSlider(settingsContent, "Transparency", 0, 1, hub.settings.transparency, function(value)
			if mainFrame then
				mainFrame.BackgroundTransparency = value
			end
			hub.settings.transparency = value
			saveSettings()
		end, 270)

		hub:addLabel(settingsContent, "Hotkey: " .. tostring(hub.hotkey), 330)
	end)
end

-- ============================================
-- PANIC BUTTON & CLEANUP
-- ============================================

function hub:destroy()
	print("🛑 Roblox Universal Hub wird beendet...")
	
	hub.running = false
	hub.data.isFlying = false
	hub.data.isNoclipping = false
	hub.data.infiniteJumpEnabled = false

	-- Alle Connections disconnecten
	disconnectAll()

	-- GUI zerstören
	if screenGui then
		pcall(function()
			screenGui:Destroy()
		end)
	end

	-- Character normalisieren
	pcall(function()
		local char = LocalPlayer.Character
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
			if char:FindFirstChild("Humanoid") then
				char.Humanoid.WalkSpeed = 16
				char.Humanoid.JumpPower = 50
			end
		end
	end)

	workspace.Gravity = 196.2
	print("✅ Hub erfolgreich beendet")
end

-- ============================================
-- HOTKEY SYSTEM
-- ============================================

function hub:setupHotkey()
	storeConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		-- Toggle GUI mit Hotkey
		if input.KeyCode == hub.hotkey then
			if screenGui then
				screenGui.Enabled = not screenGui.Enabled
			end
		end

		-- Panic Button: Ctrl + Shift + X
		if input.KeyCode == Enum.KeyCode.X and
		   UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and
		   UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			hub:destroy()
		end
	end))
end

-- ============================================
-- MAIN INITIALIZATION
-- ============================================

function hub:init()
	print("🎮 Roblox Universal Hub v" .. hub.version .. " wird initialisiert...")

	if checkGuiExists() then
		print("⚠️ Hub ist bereits aktiv!")
		return
	end

	pcall(function()
		-- GUI erstellen
		hub:createGui()

		-- Tabs aufbauen
		hub:setupTabs()

		-- Hotkey System
		hub:setupHotkey()

		-- FPS anzeigen
		hub:showFPS()

		print("✅ Roblox Universal Hub erfolgreich geladen!")
		print("📍 Hotkey: " .. tostring(hub.hotkey))
		print("🛑 Panic Button: Ctrl + Shift + X")
		print("💾 Settings werden automatisch gespeichert")
	end)
end

-- Start
if not hub.running then
	hub:init()
end

return hub
