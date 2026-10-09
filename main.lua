--[[
	Tom Pearl Menu
	Version: 1.0.0
	Library: dark navy + blue accents
	Load: local T = loadstring(game:HttpGet(".../main.lua"))()
]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local LocalPlayer      = Players.LocalPlayer

local function getParentGui()
	local ok, cg = pcall(function() return game:GetService("CoreGui") end)
	if ok and cg then return cg end
	return LocalPlayer:WaitForChild("PlayerGui")
end

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
}

local Font = {
	Title = Font.new("rbxasset://fonts/families/AccanthisADFStd.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
	Body  = Font.new("rbxasset://fonts/families/AccanthisADFStd.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	UI    = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
	Small = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
}

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

local OpenButton = new("ImageButton", {
	Name = "OpenButton",
	BorderSizePixel = 0,
	AutoButtonColor = false,
	BackgroundColor3 = Theme.ContentBG,
	ZIndex = 100,
	AnchorPoint = Vector2.new(0.5, 0),
	Image = "rbxassetid://132217368448431",
	Size = UDim2.new(0, 50, 0, 50),
	Position = UDim2.new(0.5, 0, 0, 10),
	Parent = ScreenGui,
})
corner(25, OpenButton)
stroke(Theme.Accent, 2, OpenButton)

local NotifyContainer = new("Frame", {
	Name = "Notifications",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -16, 1, -16),
	Size = UDim2.new(0, 300, 1, -32),
	Parent = ScreenGui,
})
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 8),
}, NotifyContainer)

local TomPearl = {}
TomPearl.Theme = Theme
TomPearl.Font = Font
TomPearl.Windows = {}

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

function TomPearl:CreateWindow(cfg)
	cfg = cfg or {}
	local name      = cfg.Name or "Tom Pearl Menu"
	local icon      = cfg.Icon or "rbxassetid://5607058200"
	local size      = cfg.Size or UDim2.new(0, 380, 0, 420)
	local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightControl

	local window = { Tabs = {}, ActiveTab = nil }

	local MainFrame = new("Frame", {
		Name = "MainFrame",
		Visible = false,
		ZIndex = 50,
		BorderSizePixel = 0,
		BackgroundColor3 = Theme.WindowBG,
		BackgroundTransparency = 0.05,
		AnchorPoint = Vector2.new(0.5, 0),
		ClipsDescendants = true,
		Size = size,
		Position = UDim2.new(0.5, 0, 0.15, 70),
		Parent = ScreenGui,
	})
	corner(10, MainFrame)
	stroke(Theme.Border, 1, MainFrame)

	local MainScale = new("UIScale", { Scale = 0.9 }, MainFrame)

	local Title = new("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = Font.Title,
		TextColor3 = Theme.Text,
		Size = UDim2.new(1, -60, 0, 40),
		Position = UDim2.new(0, 20, 0, 10),
		Text = name,
		Parent = MainFrame,
	})

	new("ImageLabel", {
		Name = "icon",
		BackgroundTransparency = 1,
		Image = icon,
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -170, 0, 15),
		Parent = MainFrame,
	})

	local CloseButton = new("TextButton", {
		Name = "CloseButton",
		Text = "X",
		TextSize = 18,
		TextWrapped = true,
		AutoButtonColor = false,
		TextColor3 = Theme.Text,
		BackgroundColor3 = Theme.Close,
		BackgroundTransparency = 1,
		FontFace = Font.UI,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 40, 0, 40),
		Position = UDim2.new(1, -45, 0, 10),
		Parent = MainFrame,
	})
	corner(6, CloseButton)

	new("Frame", {
		Name = "Divider",
		BorderSizePixel = 0,
		BackgroundColor3 = Theme.Divider,
		Size = UDim2.new(1, -30, 0, 1),
		Position = UDim2.new(0, 15, 0, 55),
		Parent = MainFrame,
	})

	local TabBar = new("Frame", {
		Name = "TabBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -30, 0, 28),
		Position = UDim2.new(0, 15, 0, 62),
		Parent = MainFrame,
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

	local function openFrame()
		if isOpen or isAnimating then return end
		isAnimating = true
		MainFrame.Visible = true
		MainFrame.Rotation = -90
		MainScale.Scale = 0.9
		tw(MainFrame, 0.5, { Rotation = 0 }, Enum.EasingStyle.Back)
		tw(MainScale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
		task.wait(0.5)
		MainFrame.Rotation = 0
		isOpen = true
		isAnimating = false
	end

	local function closeFrame()
		if not isOpen or isAnimating then return end
		isAnimating = true
		tw(MainFrame, 0.35, { Rotation = 90 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		tw(MainScale, 0.3, { Scale = 0.9 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.wait(0.35)
		MainFrame.Visible = false
		MainFrame.Rotation = 0
		isOpen = false
		isAnimating = false
	end

	local function toggleFrame()
		if isOpen then closeFrame() else openFrame() end
	end

	OpenButton.MouseButton1Click:Connect(toggleFrame)
	CloseButton.MouseButton1Click:Connect(closeFrame)

	OpenButton.MouseEnter:Connect(function()
		tw(OpenButton, 0.15, { Size = UDim2.new(0, 56, 0, 56), BackgroundColor3 = Theme.Surface })
	end)
	OpenButton.MouseLeave:Connect(function()
		tw(OpenButton, 0.15, { Size = UDim2.new(0, 50, 0, 50), BackgroundColor3 = Theme.ContentBG })
	end)
	CloseButton.MouseEnter:Connect(function()
		tw(CloseButton, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = Theme.Close })
	end)
	CloseButton.MouseLeave:Connect(function()
		tw(CloseButton, 0.15, { BackgroundTransparency = 1 })
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == toggleKey then toggleFrame() end
	end)

	local dragging, dragStart, startPos
	MainFrame.InputBegan:Connect(function(input)
		if isAnimating then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			local pos = input.Position
			local abs = CloseButton.AbsolutePosition
			local sz = CloseButton.AbsoluteSize
			if pos.X >= abs.X and pos.X <= abs.X + sz.X and pos.Y >= abs.Y and pos.Y <= abs.Y + sz.Y then
				return
			end
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local d = input.Position - dragStart
			MainFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

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
			TextSize = 13,
			FontFace = Font.UI,
			AutoButtonColor = false,
			LayoutOrder = idx,
			Parent = TabBar,
		})
		corner(6, btn)
		new("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
		}, btn)

		local page = new("ScrollingFrame", {
			Name = "Page_" .. tabName,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Visible = false,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Theme.Border,
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
				LayoutOrder = sectionOrder,
				Parent = page,
			})
			corner(8, holder)
			stroke(Theme.Border, 1, holder)

			new("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 8),
				Size = UDim2.new(1, -24, 0, 16),
				FontFace = Font.UI,
				Text = sectionName,
				TextColor3 = Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = holder,
			})

			new("Frame", {
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

			local counter = 0
			local function n()
				counter = counter + 1
				return counter
			end

			function section:CreateButton(label, callback)
				local btn = new("TextButton", {
					BackgroundColor3 = Theme.AccentDark,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 32),
					Text = label,
					TextColor3 = Theme.Text,
					TextSize = 14,
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
					if callback then pcall(callback) end
				end)
				return btn
			end

			function section:CreateToggle(label, default, callback)
				local state = default == true
				local row = new("Frame", {
					BackgroundColor3 = Theme.SurfaceAlt,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 34),
					LayoutOrder = n(),
					Parent = body,
				})
				corner(6, row)

				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(1, -70, 1, 0),
					FontFace = Font.UI,
					Text = label,
					TextColor3 = Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row,
				})

				local pill = new("TextButton", {
					BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -50, 0.5, -10),
					Size = UDim2.new(0, 40, 0, 20),
					Text = "",
					AutoButtonColor = false,
					Parent = row,
				})
				corner(10, pill)

				local knob = new("Frame", {
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
					Position = state and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2),
					Size = UDim2.new(0, 16, 0, 16),
					Parent = pill,
				})
				corner(8, knob)

				local function render()
					tw(pill, 0.2, { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff })
					tw(knob, 0.2, { Position = state and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2) })
				end

				pill.MouseButton1Click:Connect(function()
					state = not state
					render()
					if callback then pcall(callback, state) end
				end)

				if callback then pcall(callback, state) end

				return {
					Set = function(_, v) state = v == true; render(); if callback then pcall(callback, state) end end,
					Get = function() return state end,
				}
			end

			function section:CreateSlider(label, minV, maxV, default, callback)
				minV = minV or 0
				maxV = maxV or 100
				local value = default or minV

				local row = new("Frame", {
					BackgroundColor3 = Theme.SurfaceAlt,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 48),
					LayoutOrder = n(),
					Parent = body,
				})
				corner(6, row)

				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 6),
					Size = UDim2.new(1, -70, 0, 16),
					FontFace = Font.UI,
					Text = label,
					TextColor3 = Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row,
				})

				local valLbl = new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -70, 0, 6),
					Size = UDim2.new(0, 58, 0, 16),
					FontFace = Font.UI,
					Text = tostring(value),
					TextColor3 = Theme.Accent,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = row,
				})

				local track = new("Frame", {
					BackgroundColor3 = Theme.ToggleOff,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 12, 0, 32),
					Size = UDim2.new(1, -24, 0, 6),
					Parent = row,
				})
				corner(3, track)

				local fill = new("Frame", {
					BackgroundColor3 = Theme.Accent,
					BorderSizePixel = 0,
					Size = UDim2.new((value - minV) / math.max(maxV - minV, 0.0001), 0, 1, 0),
					Parent = track,
				})
				corner(3, fill)

				local grab = new("Frame", {
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new((value - minV) / math.max(maxV - minV, 0.0001), 0, 0.5, 0),
					Size = UDim2.new(0, 12, 0, 12),
					Parent = track,
				})
				corner(6, grab)
				stroke(Theme.Accent, 2, grab)

				local dragging = false
				local function updateFromInput(input)
					local ap = track.AbsolutePosition.X
					local as = track.AbsoluteSize.X
					local alpha = math.clamp((input.Position.X - ap) / as, 0, 1)
					value = minV + (maxV - minV) * alpha
					fill.Size = UDim2.new(alpha, 0, 1, 0)
					grab.Position = UDim2.new(alpha, 0, 0.5, 0)
					valLbl.Text = string.format("%.2f", value):gsub("%.?0+$", "")
					if callback then pcall(callback, value) end
				end

				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						updateFromInput(input)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if not dragging then return end
					if input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch then
						updateFromInput(input)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
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

			function section:CreateDropdown(label, options, default, callback)
				options = options or {}
				local selected = default or options[1]
				local expanded = false

				local holder = new("Frame", {
					BackgroundColor3 = Theme.SurfaceAlt,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 34),
					ClipsDescendants = true,
					LayoutOrder = n(),
					Parent = body,
				})
				corner(6, holder)

				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(1, -120, 0, 34),
					FontFace = Font.UI,
					Text = label,
					TextColor3 = Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = holder,
				})

				local current = new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -112, 0, 0),
					Size = UDim2.new(0, 90, 0, 34),
					FontFace = Font.UI,
					Text = tostring(selected),
					TextColor3 = Theme.Accent,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = holder,
				})

				local arrow = new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -22, 0, 0),
					Size = UDim2.new(0, 16, 0, 34),
					FontFace = Font.UI,
					Text = "▾",
					TextColor3 = Theme.TextDim,
					TextSize = 12,
					Parent = holder,
				})

				local list = new("Frame", {
					BackgroundColor3 = Theme.ContentBG,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0, 34),
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					Parent = holder,
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
						Size = UDim2.new(1, 0, 0, 26),
						Text = tostring(opt),
						TextColor3 = Theme.Text,
						TextSize = 12,
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
						holder.Size = UDim2.new(1, 0, 0, 34)
						arrow.Text = "▾"
						if callback then pcall(callback, selected) end
					end)
				end

				refreshSelection()

				local header = new("TextButton", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 0),
					Size = UDim2.new(1, 0, 0, 34),
					Text = "",
					Parent = holder,
				})

				header.MouseButton1Click:Connect(function()
					expanded = not expanded
					if expanded then
						holder.Size = UDim2.new(1, 0, 0, 34 + #options * 28 + 8)
						arrow.Text = "▴"
					else
						holder.Size = UDim2.new(1, 0, 0, 34)
						arrow.Text = "▾"
					end
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

			function section:CreateInput(label, placeholder, callback)
				local row = new("Frame", {
					BackgroundColor3 = Theme.SurfaceAlt,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 34),
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
					TextSize = 13,
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
					TextSize = 13,
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

			function section:CreateKeybind(label, defaultKey, callback)
				local key = defaultKey or Enum.KeyCode.F
				local listening = false

				local row = new("Frame", {
					BackgroundColor3 = Theme.SurfaceAlt,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 34),
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
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row,
				})

				local keyBtn = new("TextButton", {
					BackgroundColor3 = Theme.AccentDark,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -76, 0.5, -10),
					Size = UDim2.new(0, 64, 0, 20),
					Text = key.Name,
					TextColor3 = Theme.Text,
					TextSize = 12,
					FontFace = Font.UI,
					AutoButtonColor = false,
					Parent = row,
				})
				corner(4, keyBtn)

				keyBtn.MouseButton1Click:Connect(function()
					listening = true
					keyBtn.Text = "..."
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

			function section:CreateLabel(text)
				return new("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20),
					FontFace = Font.Small,
					Text = text,
					TextColor3 = Theme.TextDim,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = n(),
					Parent = body,
				})
			end

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

	function window:Destroy()
		pcall(function() MainFrame:Destroy() end)
		pcall(function() OpenButton:Destroy() end)
	end

	function window:Toggle()
		toggleFrame()
	end

	table.insert(TomPearl.Windows, window)
	return window
end

print("[TomPearl] main.lua loaded | v1.0.0")
return TomPearl
