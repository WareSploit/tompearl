--[[
	Tom Pearl Menu
	Version: 1.3.0 — SLIDE ANIMATION UPDATE
	Changelog v1.3.0:
		- Open: window slides UP from bottom to center
		- Close: window slides DOWN off-screen
		- Mobile + PC optimized
		- All comments / labels in English
		- Escape key closes window
		- Backdrop dim overlay while open
		- Section collapse, resize handle, config save/load
		- Sound system: click + welcome + error
		- Dropdown search, color picker, keybind
	Load: local T = loadstring(game:HttpGet(".../main.lua"))()
]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer

local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local HAS_FILE  = (typeof(writefile) == "function") and (typeof(readfile) == "function")

local function getParentGui()
	local ok, cg = pcall(function() return game:GetService("CoreGui") end)
	if ok and cg then return cg end
	return LocalPlayer:WaitForChild("PlayerGui")
end

-- ======================
-- THEME
-- ======================

local Theme = {
	WindowBG    = Color3.fromRGB(26, 26, 41),
	ContentBG   = Color3.fromRGB(31, 31, 46),
	Surface     = Color3.fromRGB(38, 38, 55),
	SurfaceAlt  = Color3.fromRGB(46, 46, 66),
	Border      = Color3.fromRGB(61, 61, 91),
	Divider     = Color3.fromRGB(61, 61, 91),
	Text        = Color3.fromRGB(255, 255, 255),
	TextDim     = Color3.fromRGB(170, 170, 195),
	Accent      = Color3.fromRGB(101, 151, 255),
	AccentDark  = Color3.fromRGB(51, 81, 161),
	AccentMid   = Color3.fromRGB(61, 101, 181),
	AccentLight = Color3.fromRGB(71, 121, 201),
	ToggleOn    = Color3.fromRGB(50, 170, 80),
	ToggleOff   = Color3.fromRGB(70, 70, 80),
	Close       = Color3.fromRGB(201, 61, 61),
	CloseHover  = Color3.fromRGB(230, 80, 80),
	Success     = Color3.fromRGB(80, 200, 120),
	Warning     = Color3.fromRGB(240, 190, 80),
	Error       = Color3.fromRGB(230, 80, 100),
	Backdrop    = Color3.fromRGB(0, 0, 0),
}

local Font = {
	Title = Font.new("rbxasset://fonts/families/AccanthisADFStd.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
	Body  = Font.new("rbxasset://fonts/families/AccanthisADFStd.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	UI    = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
	Small = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
}

-- ======================
-- SOUNDS
-- ======================

local SoundConfig = {
	Click         = "rbxassetid://88442833509532",
	Welcome       = "rbxassetid://74921769779219",
	Error         = "rbxassetid://87437489053994",
	VolumeClick   = 0.6,
	VolumeWelcome = 0.8,
	VolumeError   = 0.7,
	Enabled       = true,
}

-- ======================
-- HELPERS
-- ======================

local function new(class, props, parent)
	local i = Instance.new(class)
	for k, v in pairs(props or {}) do i[k] = v end
	if parent then i.Parent = parent end
	return i
end

local function corner(r, parent)
	return new("UICorner", { CornerRadius = UDim.new(0, r) }, parent)
end

local function stroke(color, thickness, parent)
	return new("UIStroke", {
		Color = color or Theme.Border,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

local function tw(inst, t, props, style, dir)
	local ti = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	local tr = TweenService:Create(inst, ti, props)
	tr:Play()
	return tr
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

local function pointInGui(gui, pos)
	local ap = gui.AbsolutePosition
	local as = gui.AbsoluteSize
	return pos.X >= ap.X and pos.X <= ap.X + as.X
		and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
end

-- ======================
-- SCREEN GUI
-- ======================

if getgenv().TomPearlGUI then pcall(function() getgenv().TomPearlGUI:Destroy() end) end

local ScreenGui = new("ScreenGui", {
	Name = "TomPearlLibrary",
	IgnoreGuiInset = true,
	ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	ResetOnSpawn = false,
	Parent = getParentGui(),
})
getgenv().TomPearlGUI = ScreenGui

-- ======================
-- SOUND PLAYER
-- ======================

local SoundFolder = new("Folder", { Name = "Sounds" }, ScreenGui)
local Sounds = {}

for name, id in pairs({
	Click = SoundConfig.Click,
	Welcome = SoundConfig.Welcome,
	Error = SoundConfig.Error,
}) do
	Sounds[name] = new("Sound", {
		Name = name,
		SoundId = id,
		Volume = 0.5,
		Parent = SoundFolder,
	})
end

local function playSound(name)
	if not SoundConfig.Enabled then return end
	local s = Sounds[name]
	if not s then return end
	s.Volume = SoundConfig["Volume" .. name] or 0.6
	s.TimePosition = 0
	s:Play()
end

-- ======================
-- BACKDROP OVERLAY (dim while open)
-- ======================

local Backdrop = new("TextButton", {
	Name = "Backdrop",
	BackgroundColor3 = Theme.Backdrop,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 1, 0),
	Text = "",
	AutoButtonColor = false,
	Visible = false,
	ZIndex = 40,
	Parent = ScreenGui,
})

-- ======================
-- OPEN BUTTON
-- ======================

local OpenButton = new("ImageButton", {
	Name = "OpenButton",
	BorderSizePixel = 0,
	AutoButtonColor = false,
	BackgroundColor3 = Theme.ContentBG,
	ZIndex = 100,
	AnchorPoint = Vector2.new(0.5, 0),
	Image = "rbxassetid://132217368448431",
	Size = UDim2.new(0, IS_MOBILE and 60 or 50, 0, IS_MOBILE and 60 or 50),
	Position = UDim2.new(0.5, 0, 0, 10),
	Parent = ScreenGui,
})
corner(30, OpenButton)
stroke(Theme.Accent, 2, OpenButton)

-- ======================
-- NOTIFICATIONS
-- ======================

local NotifyContainer = new("Frame", {
	Name = "Notifications",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -16, 1, -16),
	Size = UDim2.new(0, IS_MOBILE and 240 or 300, 1, -32),
	Parent = ScreenGui,
})
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 8),
}, NotifyContainer)

-- ======================
-- LIBRARY
-- ======================

local TomPearl = {}
TomPearl.Theme = Theme
TomPearl.Font = Font
TomPearl.Sounds = Sounds
TomPearl.SoundConfig = SoundConfig
TomPearl.Windows = {}
TomPearl.IsMobile = IS_MOBILE
TomPearl.HasFile = HAS_FILE
TomPearl.Backdrop = Backdrop

function TomPearl:PlaySound(name)
	playSound(name)
end

function TomPearl:SetSoundEnabled(state)
	SoundConfig.Enabled = state == true
end

function TomPearl:Notify(opts)
	opts = opts or {}
	local title    = opts.Title or "Notification"
	local content  = opts.Content or ""
	local duration = opts.Duration or 3
	local kind     = opts.Type or "info"

	local accent = Theme.Accent
	if kind == "success" then accent = Theme.Success
	elseif kind == "warning" then accent = Theme.Warning
	elseif kind == "error" then accent = Theme.Error end

	local card = new("Frame", {
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 64),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = NotifyContainer,
	})
	corner(8, card)
	local s = stroke(Theme.Border, 1, card)

	new("Frame", {
		BackgroundColor3 = accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, -12),
		Position = UDim2.new(0, 6, 0, 6),
		Parent = card,
	})

	local t = new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 18, 0, 8),
		Size = UDim2.new(1, -26, 0, 18),
		FontFace = Font.UI,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	local c = new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 18, 0, 28),
		Size = UDim2.new(1, -26, 0, 28),
		FontFace = Font.Small,
		Text = content,
		TextColor3 = Theme.TextDim,
		TextSize = 12,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	card.Position = UDim2.new(0, 40, 0, 0)
	tw(card, 0.25, { BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint)
	tw(s, 0.25, { Transparency = 0 })
	tw(t, 0.25, { TextTransparency = 0 })
	tw(c, 0.25, { TextTransparency = 0 })

	task.delay(duration, function()
		if not card.Parent then return end
		tw(card, 0.25, { BackgroundTransparency = 1, Position = UDim2.new(0, 40, 0, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		tw(s, 0.25, { Transparency = 1 })
		tw(t, 0.25, { TextTransparency = 1 })
		tw(c, 0.25, { TextTransparency = 1 })
		task.wait(0.3)
		pcall(function() card:Destroy() end)
	end)

	return card
end

-- ======================
-- WINDOW
-- ======================

function TomPearl:CreateWindow(cfg)
	cfg = cfg or {}
	local name        = cfg.Name or "Tom Pearl Menu"
	local icon        = cfg.Icon or "rbxassetid://132217368448431"
	local size        = cfg.Size or UDim2.new(0, IS_MOBILE and 320 or 380, 0, IS_MOBILE and 400 or 440)
	local toggleKey   = cfg.ToggleKey or Enum.KeyCode.RightControl
	local playWelcome = cfg.PlayWelcome ~= false
	local useBackdrop = cfg.Backdrop ~= false
	local openPos     = UDim2.new(0.5, 0, 0.5, 0)          -- center
	local closedPos   = UDim2.new(0.5, 0, 1.6, 0)          -- below screen

	local window = { Tabs = {}, ActiveTab = nil, Flags = {} }

	-- ======================
	-- MAIN FRAME
	-- ======================

	local MainFrame = new("Frame", {
		Name = "MainFrame",
		Visible = false,
		ZIndex = 50,
		BorderSizePixel = 0,
		BackgroundColor3 = Theme.WindowBG,
		BackgroundTransparency = 0.05,
		AnchorPoint = Vector2.new(0.5, 0.5),
		ClipsDescendants = true,
		Size = size,
		Position = closedPos,
		Parent = ScreenGui,
	})
	corner(10, MainFrame)
	stroke(Theme.Border, 1, MainFrame)

	local MainScale = new("UIScale", { Scale = 0.95 }, MainFrame)

	local Title = new("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		TextSize = IS_MOBILE and 18 or 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Font.Title,
		TextColor3 = Theme.Text,
		Size = UDim2.new(1, -100, 0, 40),
		Position = UDim2.new(0, 20, 0, 10),
		Text = name,
		Parent = MainFrame,
	})

	local CloseButton = new("TextButton", {
		Name = "CloseButton",
		Text = "X",
		TextSize = IS_MOBILE and 20 or 18,
		AutoButtonColor = false,
		TextColor3 = Theme.Text,
		BackgroundColor3 = Theme.Close,
		BackgroundTransparency = 1,
		FontFace = Font.UI,
		BorderSizePixel = 0,
		Size = UDim2.new(0, IS_MOBILE and 44 or 40, 0, IS_MOBILE and 44 or 40),
		Position = UDim2.new(1, -50, 0, 8),
		Parent = MainFrame,
	})
	corner(6, CloseButton)

	local MinBtn = new("TextButton", {
		Name = "MinButton",
		Text = "—",
		TextSize = IS_MOBILE and 20 or 18,
		AutoButtonColor = false,
		TextColor3 = Theme.Text,
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.6,
		FontFace = Font.UI,
		BorderSizePixel = 0,
		Size = UDim2.new(0, IS_MOBILE and 44 or 40, 0, IS_MOBILE and 44 or 40),
		Position = UDim2.new(1, -100, 0, 8),
		Parent = MainFrame,
	})
	corner(6, MinBtn)

	new("Frame", {
		Name = "Divider",
		BorderSizePixel = 0,
		BackgroundColor3 = Theme.Divider,
		Size = UDim2.new(1, -30, 0, 1),
		Position = UDim2.new(0, 15, 0, 55),
		Parent = MainFrame,
	})

	local TabBarHolder = new("Frame", {
		Name = "TabBarHolder",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -30, 0, 34),
		Position = UDim2.new(0, 15, 0, 62),
		ClipsDescendants = true,
		Parent = MainFrame,
	})

	local TabBar = new("ScrollingFrame", {
		Name = "TabBar",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		Parent = TabBarHolder,
	})
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}, TabBar)

	local ContentArea = new("Frame", {
		Name = "ContentArea",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -30, 1, -160),
		Position = UDim2.new(0, 15, 0, 96),
		Parent = MainFrame,
	})

	local tabOrder = 0
	local isOpen = false
	local isAnimating = false
	local minimized = false
	local savedSize = size

	-- ======================
	-- SLIDE ANIMATIONS
	-- ======================

	local function openFrame()
		if isOpen or isAnimating then return end
		isAnimating = true
		playSound("Welcome")

		-- reset rotation and position
		MainFrame.Rotation = 0
		MainFrame.Position = closedPos
		MainFrame.Visible = true
		MainScale.Scale = 0.95

		-- backdrop fade-in
		if useBackdrop then
			Backdrop.Visible = true
			tw(Backdrop, 0.35, { BackgroundTransparency = 0.55 })
		end

		-- slide up + scale
		tw(MainFrame, 0.55, { Position = openPos }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		tw(MainScale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

		task.wait(0.55)
		MainFrame.Position = openPos
		isOpen = true
		isAnimating = false
	end

	local function closeFrame()
		if not isOpen or isAnimating then return end
		isAnimating = true
		playSound("Click")

		-- backdrop fade-out
		if useBackdrop then
			tw(Backdrop, 0.3, { BackgroundTransparency = 1 })
			task.delay(0.3, function()
				if not isOpen then Backdrop.Visible = false end
			end)
		end

		-- slide down + scale down
		tw(MainFrame, 0.45, { Position = closedPos }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		tw(MainScale, 0.35, { Scale = 0.95 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		task.wait(0.45)
		MainFrame.Visible = false
		MainFrame.Position = closedPos
		MainScale.Scale = 1
		isOpen = false
		isAnimating = false
	end

	local function toggleFrame()
		if isOpen then closeFrame() else openFrame() end
	end

	local function toggleMinimize()
		minimized = not minimized
		if minimized then
			savedSize = MainFrame.Size
			tw(MainFrame, 0.25, { Size = UDim2.new(savedSize.X.Scale, savedSize.X.Offset, 0, 60) })
			ContentArea.Visible = false
			TabBarHolder.Visible = false
			MinBtn.Text = "+"
		else
			tw(MainFrame, 0.25, { Size = savedSize })
			ContentArea.Visible = true
			TabBarHolder.Visible = true
			MinBtn.Text = "—"
		end
	end

	OpenButton.MouseButton1Click:Connect(toggleFrame)
	CloseButton.MouseButton1Click:Connect(closeFrame)
	MinBtn.MouseButton1Click:Connect(toggleMinimize)

	-- backdrop click = close
	if useBackdrop then
		Backdrop.MouseButton1Click:Connect(function()
			if isOpen and not isAnimating then closeFrame() end
		end)
	end

	OpenButton.MouseEnter:Connect(function()
		tw(OpenButton, 0.15, { Size = UDim2.new(0, IS_MOBILE and 66 or 56, 0, IS_MOBILE and 66 or 56), BackgroundColor3 = Theme.Surface })
	end)
	OpenButton.MouseLeave:Connect(function()
		tw(OpenButton, 0.15, { Size = UDim2.new(0, IS_MOBILE and 60 or 50, 0, IS_MOBILE and 60 or 50), BackgroundColor3 = Theme.ContentBG })
	end)
	CloseButton.MouseEnter:Connect(function()
		tw(CloseButton, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = Theme.Close })
	end)
	CloseButton.MouseLeave:Connect(function()
		tw(CloseButton, 0.15, { BackgroundTransparency = 1 })
	end)

	-- keyboard: toggle on key, Escape closes
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == toggleKey then toggleFrame() end
		if input.KeyCode == Enum.KeyCode.Escape and isOpen then closeFrame() end
	end)

	-- ======================
	-- DRAG
	-- ======================

	local dragging, dragStart, startPos
	MainFrame.InputBegan:Connect(function(input)
		if isAnimating then return end
		if not isPress(input) then return end
		if pointInGui(CloseButton, input.Position) then return end
		if pointInGui(MinBtn, input.Position) then return end
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if not isMove(input) then return end
		local d = input.Position - dragStart
		MainFrame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + d.X,
			startPos.Y.Scale, startPos.Y.Offset + d.Y
		)
		-- save last open position for close animation
		openPos = MainFrame.Position
	end)

	UserInputService.InputEnded:Connect(function(input)
		if isPress(input) then dragging = false end
	end)

	-- ======================
	-- RESIZE HANDLE
	-- ======================

	local ResizeHandle = new("TextButton", {
		Name = "ResizeHandle",
		BackgroundColor3 = Theme.Border,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 14, 0, 14),
		Position = UDim2.new(1, -16, 1, -16),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 5,
		Parent = MainFrame,
	})
	corner(3, ResizeHandle)

	local resizing, resizeStart, startSize
	ResizeHandle.InputBegan:Connect(function(input)
		if not isPress(input) then return end
		resizing = true
		resizeStart = input.Position
		startSize = MainFrame.AbsoluteSize
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not resizing then return end
		if not isMove(input) then return end
		local d = input.Position - resizeStart
		local newW = math.clamp(startSize.X + d.X, 260, 600)
		local newH = math.clamp(startSize.Y + d.Y, 280, 700)
		MainFrame.Size = UDim2.new(0, newW, 0, newH)
	end)

	UserInputService.InputEnded:Connect(function(input)
		if isPress(input) then resizing = false end
	end)

	-- ======================
	-- TABS
	-- ======================

	function window:CreateTab(tabName)
		tabOrder = tabOrder + 1
		local idx = tabOrder

		local btn = new("TextButton", {
			Name = "Tab_" .. tabName,
			BackgroundColor3 = Theme.Surface,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = tabName,
			TextColor3 = Theme.TextDim,
			TextSize = IS_MOBILE and 14 or 13,
			FontFace = Font.UI,
			AutoButtonColor = false,
			LayoutOrder = idx,
			Parent = TabBar,
		})
		corner(6, btn)
		new("UIPadding", {
			PaddingLeft = UDim.new(0, 14),
			PaddingRight = UDim.new(0, 14),
		}, btn)

		local page = new("ScrollingFrame", {
			Name = "Page_" .. tabName,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Visible = false,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = IS_MOBILE and 6 or 4,
			ScrollBarImageColor3 = Theme.Border,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
			Parent = ContentArea,
		})
		new("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, page)
		new("UIPadding", { PaddingRight = UDim.new(0, 8) }, page)

		local tab = { Name = tabName, Button = btn, Page = page, Sections = {} }

		local function activate()
			if window.ActiveTab and window.ActiveTab.Button then
				local old = window.ActiveTab
				tw(old.Button, 0.15, { BackgroundColor3 = Theme.Surface })
				old.Button.TextColor3 = Theme.TextDim
				old.Page.Visible = false
			end
			window.ActiveTab = tab
			tw(btn, 0.15, { BackgroundColor3 = Theme.AccentDark })
			btn.TextColor3 = Theme.Text
			page.Visible = true
			playSound("Click")
		end

		btn.MouseEnter:Connect(function()
			if window.ActiveTab ~= tab then
				tw(btn, 0.15, { BackgroundColor3 = Theme.SurfaceAlt })
			end
		end)
		btn.MouseLeave:Connect(function()
			if window.ActiveTab ~= tab then
				tw(btn, 0.15, { BackgroundColor3 = Theme.Surface })
			end
		end)
		btn.MouseButton1Click:Connect(activate)

		local sectionOrder = 0

		function tab:CreateSection(sectionName)
			sectionOrder = sectionOrder + 1
			local section = {}

			local holder = new("Frame", {
				Name = "Section_" .. sectionName,
				BackgroundColor3 = Theme.Surface,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30),
				AutomaticSize = Enum.AutomaticSize.Y,
				ClipsDescendants = true,
				LayoutOrder = sectionOrder,
				Parent = page,
			})
			corner(8, holder)
			stroke(Theme.Border, 1, holder)

			local headerBtn = new("TextButton", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 0, 30),
				Text = "",
				ZIndex = 2,
				Parent = holder,
			})

			new("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 8),
				Size = UDim2.new(1, -50, 0, 16),
				FontFace = Font.UI,
				Text = sectionName,
				TextColor3 = Theme.Text,
				TextSize = IS_MOBILE and 14 or 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = holder,
			})

			local collapseIcon = new("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -26, 0, 8),
				Size = UDim2.new(0, 18, 0, 16),
				FontFace = Font.UI,
				Text = "▾",
				TextColor3 = Theme.TextDim,
				TextSize = 12,
				Parent = holder,
			})

			new("Frame", {
				Name = "SectionDivider",
				BackgroundColor3 = Theme.Divider,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 10, 0, 30),
				Size = UDim2.new(1, -20, 0, 1),
				Parent = holder,
			})

			local body = new("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 38),
				Size = UDim2.new(1, -20, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = holder,
			})
			new("UIListLayout", {
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, body)
			new("UIPadding", { PaddingBottom = UDim.new(0, 10) }, body)

			local collapsed = false
			headerBtn.MouseButton1Click:Connect(function()
				collapsed = not collapsed
				if collapsed then
					body.Visible = false
					collapseIcon.Text = "▸"
					holder.Size = UDim2.new(1, 0, 0, 32)
				else
					body.Visible = true
					collapseIcon.Text = "▾"
					holder.Size = UDim2.new(1, 0, 0, 0)
				end
				playSound("Click")
			end)

			local counter = 0
			local function n()
				counter = counter + 1
				return counter
			end

			local ROW_H = IS_MOBILE and 44 or 34
			local BTN_H = IS_MOBILE and 40 or 32

			-- ============ BUTTON ============
			function section:CreateButton(label, callback)
				local btn = new("TextButton", {
					BackgroundColor3 = Theme.AccentDark,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, BTN_H),
					Text = label,
					TextColor3 = Theme.Text,
					TextSize = IS_MOBILE and 15 or 14,
					FontFace = Font.UI,
					AutoButtonColor = false,
					LayoutOrder = n(),
					Parent = body,
				})
				corner(6, btn)
				btn.MouseEnter:Connect(function()
					tw(btn, 0.15, { BackgroundColor3 = Theme.AccentMid })
				end)
				btn.MouseLeave:Connect(function()
					tw(btn, 0.15, { BackgroundColor3 = Theme.AccentDark })
				end)
				btn.MouseButton1Click:Connect(function()
					playSound("Click")
					if callback then
						local ok, err = pcall(callback)
						if not ok then playSound("Error"); warn("[TomPearl]", err) end
					end
				end)
				return btn
			end

			-- ============ TOGGLE ============
			function section:CreateToggle(label, default, callback)
				local state = default == true
				local row = new("Frame", {
					BackgroundColor3 = Theme.SurfaceAlt,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, ROW_H),
					LayoutOrder = n(),
					Parent = body,
				})
				corner(6, row)

				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(1, -80, 1, 0),
					FontFace = Font.UI,
					Text = label,
					TextColor3 = Theme.Text,
					TextSize = IS_MOBILE and 14 or 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row,
				})

				local pillW = IS_MOBILE and 52 or 40
				local pillH = IS_MOBILE and 26 or 20
				local knobS = IS_MOBILE and 20 or 16
				local knobPad = 3

				local pill = new("TextButton", {
					BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -(pillW + 10), 0.5, -pillH / 2),
					Size = UDim2.new(0, pillW, 0, pillH),
					Text = "",
					AutoButtonColor = false,
					Parent = row,
				})
				corner(math.floor(pillH / 2), pill)

				local knob = new("Frame", {
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
					Position = state and UDim2.new(1, -(knobS + knobPad), 0, knobPad) or UDim2.new(0, knobPad, 0, knobPad),
					Size = UDim2.new(0, knobS, 0, knobS),
					Parent = pill,
				})
				corner(math.floor(knobS / 2), knob)

				local function render()
					tw(pill, 0.2, { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff })
					tw(knob, 0.2, { Position = state and UDim2.new(1, -(knobS + knobPad), 0, knobPad) or UDim2.new(0, knobPad, 0, knobPad) })
				end

				pill.MouseButton1Click:Connect(function()
					state = not state
					render()
					playSound("Click")
					if callback then
						local ok, err = pcall(callback, state)
						if not ok then playSound("Error"); warn("[TomPearl]", err) end
					end
				end)

				if callback then pcall(callback, state) end

				return {
					Set = function(_, v) state = v == true; render(); if callback then pcall(callback, state) end end,
					Get = function() return state end,
				}
			end

			-- ============ SLIDER ============
			function section:CreateSlider(label, minV, maxV, default, callback)
				minV = minV or 0
				maxV = maxV or 100
				local value = default or minV

				local sliderH = IS_MOBILE and 60 or 52
				local trackH  = IS_MOBILE and 10 or 6
				local grabS   = IS_MOBILE and 22 or 14
				local hitH    = IS_MOBILE and 44 or 30

				local row = new("Frame", {
					BackgroundColor3 = Theme.SurfaceAlt,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, sliderH),
					LayoutOrder = n(),
					Parent = body,
				})
				corner(6, row)

				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 6),
					Size = UDim2.new(1, -80, 0, 18),
					FontFace = Font.UI,
					Text = label,
					TextColor3 = Theme.Text,
					TextSize = IS_MOBILE and 14 or 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row,
				})

				local valLbl = new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -80, 0, 6),
					Size = UDim2.new(0, 68, 0, 18),
					FontFace = Font.UI,
					Text = tostring(value),
					TextColor3 = Theme.Accent,
					TextSize = IS_MOBILE and 14 or 12,
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = row,
				})

				local track = new("Frame", {
					BackgroundColor3 = Theme.ToggleOff,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 12, 0, sliderH - 20),
					Size = UDim2.new(1, -24, 0, trackH),
					Parent = row,
				})
				corner(math.floor(trackH / 2), track)

				local fill = new("Frame", {
					BackgroundColor3 = Theme.Accent,
					BorderSizePixel = 0,
					Size = UDim2.new((value - minV) / math.max(maxV - minV, 0.0001), 0, 1, 0),
					Parent = track,
				})
				corner(math.floor(trackH / 2), fill)

				local grab = new("Frame", {
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new((value - minV) / math.max(maxV - minV, 0.0001), 0, 0.5, 0),
					Size = UDim2.new(0, grabS, 0, grabS),
					ZIndex = 2,
					Parent = track,
				})
				corner(math.floor(grabS / 2), grab)
				stroke(Theme.Accent, 2, grab)

				local hitArea = new("TextButton", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 20, 0, hitH),
					Position = UDim2.new(0, -10, 0.5, -hitH / 2),
					Text = "",
					AutoButtonColor = false,
					ZIndex = 5,
					Parent = track,
				})

				local dragging = false

				local function updateFromPosition(posX)
					local ap = track.AbsolutePosition.X
					local as = track.AbsoluteSize.X
					if as <= 0 then return end
					local alpha = math.clamp((posX - ap) / as, 0, 1)
					value = minV + (maxV - minV) * alpha
					fill.Size = UDim2.new(alpha, 0, 1, 0)
					grab.Position = UDim2.new(alpha, 0, 0.5, 0)
					if value % 1 == 0 then
						valLbl.Text = tostring(math.floor(value))
					else
						valLbl.Text = string.format("%.2f", value)
					end
					if callback then pcall(callback, value) end
				end

				hitArea.InputBegan:Connect(function(input)
					if not isPress(input) then return end
					dragging = true
					updateFromPosition(input.Position.X)
				end)

				row.InputBegan:Connect(function(input)
					if not isPress(input) then return end
					local ap = track.AbsolutePosition
					if input.Position.Y < ap.Y - 8 then return end
					dragging = true
					updateFromPosition(input.Position.X)
				end)

				UserInputService.InputChanged:Connect(function(input)
					if not dragging then return end
					if not isMove(input) then return end
					updateFromPosition(input.Position.X)
				end)

				UserInputService.InputEnded:Connect(function(input)
					if isPress(input) then dragging = false end
				end)

				return {
					Set = function(_, v)
						value = math.clamp(v, minV, maxV)
						local alpha = (value - minV) / math.max(maxV - minV, 0.0001)
						fill.Size = UDim2.new(alpha, 0, 1, 0)
						grab.Position = UDim2.new(alpha, 0, 0.5, 0)
						valLbl.Text = tostring(value)
						if callback then pcall(callback, value) end
					end,
					Get = function() return value end,
				}
			end

			-- ============ DROPDOWN ============
			function section:CreateDropdown(label, options, default, callback)
				options = options or {}
				local selected = default or options[1]
				local expanded = false
				local filter = ""

				local holder = new("Frame", {
					BackgroundColor3 = Theme.SurfaceAlt,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, ROW_H),
					ClipsDescendants = true,
					LayoutOrder = n(),
					Parent = body,
				})
				corner(6, holder)

				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(1, -130, 0, ROW_H),
					FontFace = Font.UI,
					Text = label,
					TextColor3 = Theme.Text,
					TextSize = IS_MOBILE and 14 or 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = holder,
				})

				local current = new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -122, 0, 0),
					Size = UDim2.new(0, 96, 0, ROW_H),
					FontFace = Font.UI,
					Text = tostring(selected),
					TextColor3 = Theme.Accent,
					TextSize = IS_MOBILE and 13 or 12,
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = holder,
				})

				local arrow = new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -24, 0, 0),
					Size = UDim2.new(0, 18, 0, ROW_H),
					FontFace = Font.UI,
					Text = "▾",
					TextColor3 = Theme.TextDim,
					TextSize = 12,
					Parent = holder,
				})

				local maxListH = IS_MOBILE and 180 or 220
				local optH = IS_MOBILE and 34 or 26
				local searchH = #options > 6 and 30 or 0

				local listHolder = new("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, ROW_H),
					Size = UDim2.new(1, 0, 0, 0),
					ClipsDescendants = true,
					Parent = holder,
				})

				local searchBox
				if searchH > 0 then
					searchBox = new("TextBox", {
						BackgroundColor3 = Theme.ContentBG,
						BorderSizePixel = 0,
						Position = UDim2.new(0, 4, 0, 4),
						Size = UDim2.new(1, -8, 0, searchH - 6),
						FontFace = Font.UI,
						Text = "",
						PlaceholderText = "search...",
						PlaceholderColor3 = Theme.TextDim,
						TextColor3 = Theme.Text,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						ClearTextOnFocus = false,
						Parent = listHolder,
					})
					corner(4, searchBox)
					new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, searchBox)
				end

				local list = new("ScrollingFrame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0, searchH),
					Size = UDim2.new(1, 0, 1, -searchH),
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ScrollBarThickness = IS_MOBILE and 5 or 3,
					ScrollBarImageColor3 = Theme.Border,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
					Parent = listHolder,
				})
				new("UIListLayout", {
					Padding = UDim.new(0, 2),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}, list)
				new("UIPadding", {
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
					PaddingLeft = UDim.new(0, 4),
					PaddingRight = UDim.new(0, 4),
				}, list)

				local buttons = {}

				local function refreshFilter()
					for opt, b in pairs(buttons) do
						if filter == "" or string.find(string.lower(tostring(opt)), string.lower(filter), 1, true) then
							b.Visible = true
						else
							b.Visible = false
						end
					end
				end

				local function refreshSelection()
					for opt, b in pairs(buttons) do
						if opt == selected then
							b.BackgroundColor3 = Theme.AccentDark
							b.TextColor3 = Theme.Text
						else
							b.BackgroundColor3 = Theme.Surface
							b.TextColor3 = Theme.Text
						end
					end
					current.Text = tostring(selected)
				end

				for i, opt in ipairs(options) do
					local b = new("TextButton", {
						BackgroundColor3 = Theme.Surface,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, optH),
						Text = tostring(opt),
						TextColor3 = Theme.Text,
						TextSize = IS_MOBILE and 14 or 12,
						FontFace = Font.UI,
						AutoButtonColor = false,
						LayoutOrder = i,
						Parent = list,
					})
					corner(4, b)
					buttons[opt] = b
					b.MouseButton1Click:Connect(function()
						selected = opt
						refreshSelection()
						expanded = false
						holder.Size = UDim2.new(1, 0, 0, ROW_H)
						listHolder.Size = UDim2.new(1, 0, 0, 0)
						arrow.Text = "▾"
						playSound("Click")
						if callback then pcall(callback, selected) end
					end)
				end

				refreshSelection()

				if searchBox then
					searchBox:GetPropertyChangedSignal("Text"):Connect(function()
						filter = searchBox.Text
						refreshFilter()
					end)
				end

				local header = new("TextButton", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 0),
					Size = UDim2.new(1, 0, 0, ROW_H),
					Text = "",
					ZIndex = 2,
					Parent = holder,
				})

				header.MouseButton1Click:Connect(function()
					expanded = not expanded
					if expanded then
						local totalH = #options * (optH + 2) + 8
						local shownH = math.min(totalH, maxListH) + searchH
						listHolder.Size = UDim2.new(1, 0, 0, shownH)
						holder.Size = UDim2.new(1, 0, 0, ROW_H + shownH)
						arrow.Text = "▴"
					else
						listHolder.Size = UDim2.new(1, 0, 0, 0)
						holder.Size = UDim2.new(1, 0, 0, ROW_H)
						arrow.Text = "▾"
						if searchBox then searchBox.Text = ""; filter = ""; refreshFilter() end
					end
					playSound("Click")
				end)

				return {
					Set = function(_, v)
						if buttons[v] then
							selected = v
							refreshSelection()
							if callback then pcall(callback, selected) end
						end
					end,
					Get = function() return selected end,
				}
			end

			-- ============ INPUT ============
			function section:CreateInput(label, placeholder, callback)
				local row = new("Frame", {
					BackgroundColor3 = Theme.SurfaceAlt,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, ROW_H),
					LayoutOrder = n(),
					Parent = body,
				})
				corner(6, row)

				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(0, 100, 1, 0),
					FontFace = Font.UI,
					Text = label,
					TextColor3 = Theme.Text,
					TextSize = IS_MOBILE and 14 or 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row,
				})

				local box = new("TextBox", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 114, 0, 0),
					Size = UDim2.new(1, -126, 1, 0),
					FontFace = Font.UI,
					Text = "",
					PlaceholderText = placeholder or "type...",
					PlaceholderColor3 = Theme.TextDim,
					TextColor3 = Theme.Text,
					TextSize = IS_MOBILE and 14 or 13,
					TextXAlignment = Enum.TextXAlignment.Right,
					ClearTextOnFocus = false,
					Parent = row,
				})

				box.FocusLost:Connect(function(enter)
					if enter and callback then pcall(callback, box.Text) end
				end)

				return {
					Set = function(_, v) box.Text = tostring(v) end,
					Get = function() return box.Text end,
				}
			end

			-- ============ KEYBIND ============
			function section:CreateKeybind(label, defaultKey, callback)
				local key = defaultKey or Enum.KeyCode.F
				local listening = false

				local row = new("Frame", {
					BackgroundColor3 = Theme.SurfaceAlt,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, ROW_H),
					LayoutOrder = n(),
					Parent = body,
				})
				corner(6, row)

				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(1, -90, 1, 0),
					FontFace = Font.UI,
					Text = label,
					TextColor3 = Theme.Text,
					TextSize = IS_MOBILE and 14 or 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row,
				})

				local keyBtn = new("TextButton", {
					BackgroundColor3 = Theme.AccentDark,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -84, 0.5, -12),
					Size = UDim2.new(0, 72, 0, 24),
					Text = key.Name,
					TextColor3 = Theme.Text,
					TextSize = IS_MOBILE and 13 or 12,
					FontFace = Font.UI,
					AutoButtonColor = false,
					Parent = row,
				})
				corner(4, keyBtn)

				keyBtn.MouseButton1Click:Connect(function()
					listening = true
					keyBtn.Text = "..."
					playSound("Click")
				end)

				UserInputService.InputBegan:Connect(function(input, gp)
					if gp then return end
					if listening then
						if input.UserInputType == Enum.UserInputType.Keyboard then
							key = input.KeyCode
							keyBtn.Text = key.Name
							listening = false
						end
					elseif input.KeyCode == key then
						if callback then pcall(callback) end
					end
				end)

				return {
					Set = function(_, k) key = k; keyBtn.Text = k.Name end,
					Get = function() return key end,
				}
			end

			-- ============ COLOR PICKER ============
			function section:CreateColorPicker(label, defaultColor, callback)
				local color = defaultColor or Color3.fromRGB(101, 151, 255)

				local row = new("Frame", {
					BackgroundColor3 = Theme.SurfaceAlt,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 90),
					LayoutOrder = n(),
					Parent = body,
				})
				corner(6, row)

				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 6),
					Size = UDim2.new(1, -80, 0, 16),
					FontFace = Font.UI,
					Text = label,
					TextColor3 = Theme.Text,
					TextSize = IS_MOBILE and 14 or 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row,
				})

				local preview = new("Frame", {
					BackgroundColor3 = color,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -50, 0, 4),
					Size = UDim2.new(0, 38, 0, 20),
					Parent = row,
				})
				corner(4, preview)

				local function makeChannel(yPos, ch)
					local track = new("Frame", {
						BackgroundColor3 = Theme.ToggleOff,
						BorderSizePixel = 0,
						Position = UDim2.new(0, 12, 0, yPos),
						Size = UDim2.new(1, -24, 0, 8),
						Parent = row,
					})
					corner(4, track)

					local chColor = ch == "R" and Color3.new(1,0,0) or ch == "G" and Color3.new(0,1,0) or Color3.new(0,0,1)
					local fill = new("Frame", {
						BackgroundColor3 = chColor,
						BorderSizePixel = 0,
						Size = UDim2.new(color[ch], 0, 1, 0),
						Parent = track,
					})
					corner(4, fill)

					local hit = new("TextButton", {
						BackgroundTransparency = 1,
						Position = UDim2.new(0, -8, 0.5, -16),
						Size = UDim2.new(1, 16, 0, 32),
						Text = "",
						AutoButtonColor = false,
						Parent = track,
					})

					local dragging = false
					local function upd(pos)
						local ap = track.AbsolutePosition.X
						local as = track.AbsoluteSize.X
						if as <= 0 then return end
						local a = math.clamp((pos - ap) / as, 0, 1)
						local c = { color.R, color.G, color.B }
						local idx = ch == "R" and 1 or ch == "G" and 2 or 3
						c[idx] = a
						color = Color3.new(c[1], c[2], c[3])
						fill.Size = UDim2.new(a, 0, 1, 0)
						preview.BackgroundColor3 = color
						if callback then pcall(callback, color) end
					end

					hit.InputBegan:Connect(function(i)
						if not isPress(i) then return end
						dragging = true
						upd(i.Position.X)
					end)
					UserInputService.InputChanged:Connect(function(i)
						if dragging and isMove(i) then upd(i.Position.X) end
					end)
					UserInputService.InputEnded:Connect(function(i)
						if isPress(i) then dragging = false end
					end)
				end

				makeChannel(30, "R")
				makeChannel(44, "G")
				makeChannel(58, "B")

				return {
					Set = function(_, c)
						color = c
						preview.BackgroundColor3 = c
						if callback then pcall(callback, color) end
					end,
					Get = function() return color end,
				}
			end

			-- ============ LABEL ============
			function section:CreateLabel(text)
				return new("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 22),
					FontFace = Font.Small,
					Text = text,
					TextColor3 = Theme.TextDim,
					TextSize = IS_MOBILE and 13 or 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
					LayoutOrder = n(),
					Parent = body,
				})
			end

			-- ============ DIVIDER ============
			function section:CreateDivider()
				return new("Frame", {
					BackgroundColor3 = Theme.Divider,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 1),
					LayoutOrder = n(),
					Parent = body,
				})
			end

			tab.Sections[#tab.Sections + 1] = section
			return section
		end

		table.insert(window.Tabs, tab)
		if #window.Tabs == 1 then activate() end

		return tab
	end

	-- ======================
	-- CONFIG SAVE / LOAD
	-- ======================

	function window:SaveConfig(filename)
		if not HAS_FILE then
			TomPearl:Notify({ Title = "Error", Content = "Executor has no writefile", Duration = 3, Type = "error" })
			return
		end
		filename = filename or "tompearl_config.json"
		local data = {}
		for k, v in pairs(window.Flags) do
			data[k] = v
		end
		local ok, encoded = pcall(function() return game:GetService("HttpService"):JSONEncode(data) end)
		if not ok then return end
		pcall(function() writefile(filename, encoded) end)
		TomPearl:Notify({ Title = "Config", Content = "Saved to " .. filename, Duration = 2, Type = "success" })
	end

	function window:LoadConfig(filename)
		if not HAS_FILE then return end
		filename = filename or "tompearl_config.json"
		if not isfile(filename) then return end
		local ok, contents = pcall(function() return readfile(filename) end)
		if not ok or not contents then return end
		local ok2, data = pcall(function() return game:GetService("HttpService"):JSONDecode(contents) end)
		if not ok2 then return end
		for k, v in pairs(data) do
			window.Flags[k] = v
		end
		TomPearl:Notify({ Title = "Config", Content = "Loaded from " .. filename, Duration = 2, Type = "success" })
	end

	function window:Destroy()
		pcall(function() MainFrame:Destroy() end)
		pcall(function() OpenButton:Destroy() end)
	end

	function window:Toggle()
		toggleFrame()
	end

	function window:Open()
		openFrame()
	end

	function window:Close()
		closeFrame()
	end

	function window:IsOpen()
		return isOpen
	end

	table.insert(TomPearl.Windows, window)

	-- auto-open on create
	task.delay(0.1, function()
		openFrame()
		if playWelcome then
			TomPearl:Notify({
				Title = "Tom Pearl Menu",
				Content = "v1.3.0 loaded",
				Duration = 3,
				Type = "success",
			})
		end
	end)

	return window
end

print("[TomPearl] main.lua v1.3.0 loaded | mobile=" .. tostring(IS_MOBILE) .. " | file=" .. tostring(HAS_FILE))
return TomPearl
