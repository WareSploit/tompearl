--[[
	Tom Pearl Menu — Example v1.3.0
	Auto-opens on load with slide-up animation.
	Load: loadstring(game:HttpGet("https://raw.githubusercontent.com/WareSploit/tompearl/main/example.lua"))()
]]

local LIB_URL = "https://raw.githubusercontent.com/WareSploit/tompearl/main/main.lua"

local ok, TomPearl = pcall(function()
	return loadstring(game:HttpGet(LIB_URL))()
end)

if not ok or not TomPearl then
	warn("[TomPearl] Failed to load library:", TomPearl)
	return
end

local IS_MOBILE = TomPearl.IsMobile

-- ======================
-- WINDOW
-- ======================

local Window = TomPearl:CreateWindow({
	Name = "Tom Pearl Menu",
	Icon = "rbxassetid://132217368448431",
	Size = IS_MOBILE and UDim2.new(0, 320, 0, 420) or UDim2.new(0, 400, 0, 460),
	ToggleKey = Enum.KeyCode.RightControl,
	PlayWelcome = true,
	Backdrop = true,
})

-- ======================
-- TAB: MAIN
-- ======================

local MainTab = Window:CreateTab("Main")
local Combat = MainTab:CreateSection("Combat")

Combat:CreateToggle("Auto Parry", false, function(state)
	Window.Flags.AutoParry = state
	print("[Example] Auto Parry:", state)
end)

Combat:CreateToggle("Auto Block", false, function(state)
	Window.Flags.AutoBlock = state
	print("[Example] Auto Block:", state)
end)

Combat:CreateToggle("Hitbox Expand", false, function(state)
	Window.Flags.HitboxExpand = state
end)

Combat:CreateSlider("Reach", 1, 50, 9, function(v)
	Window.Flags.Reach = v
end)

Combat:CreateSlider("Hitbox Size", 0, 20, 5, function(v)
	Window.Flags.HitboxSize = v
end)

Combat:CreateDropdown("Mode", {
	"Parry", "Dodge", "Hybrid", "Aggressive",
	"Defensive", "Custom", "Random", "Adaptive",
}, "Parry", function(v)
	Window.Flags.Mode = v
end)

Combat:CreateColorPicker("Hitbox Color", Color3.fromRGB(255, 80, 80), function(c)
	Window.Flags.HitboxColor = { c.R, c.G, c.B }
end)

-- ======================
-- TAB: MOVEMENT
-- ======================

local MoveTab = Window:CreateTab("Move")
local Speed = MoveTab:CreateSection("Speed")

Speed:CreateSlider("WalkSpeed", 16, 200, 16, function(v)
	local char = game.Players.LocalPlayer.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		char:FindFirstChildOfClass("Humanoid").WalkSpeed = v
	end
	Window.Flags.WalkSpeed = v
end)

Speed:CreateSlider("JumpPower", 50, 500, 50, function(v)
	local char = game.Players.LocalPlayer.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		char:FindFirstChildOfClass("Humanoid").JumpPower = v
	end
	Window.Flags.JumpPower = v
end)

Speed:CreateToggle("Infinite Jump", false, function(state)
	getgenv().InfJump = state
	Window.Flags.InfJump = state
end)

Speed:CreateToggle("Fly", false, function(state)
	Window.Flags.Fly = state
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
	if getgenv().InfJump then
		local char = game.Players.LocalPlayer.Character
		if char and char:FindFirstChildOfClass("Humanoid") then
			char:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
		end
	end
end)

-- ======================
-- TAB: ACTIONS
-- ======================

local ActTab = Window:CreateTab("Actions")
local Quick = ActTab:CreateSection("Quick Actions")

Quick:CreateButton("Refresh Target", function()
	TomPearl:Notify({
		Title = "Target",
		Content = "Target refreshed",
		Duration = 2,
		Type = "info",
	})
end)

Quick:CreateButton("Rejoin Server", function()
	game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
end)

Quick:CreateButton("Panic — Disable All", function()
	TomPearl:Notify({
		Title = "Panic",
		Content = "All functions disabled",
		Duration = 2,
		Type = "warning",
	})
end)

-- ======================
-- TAB: SETTINGS
-- ======================

local SetTab = Window:CreateTab("Settings")
local Gen = SetTab:CreateSection("General")

Gen:CreateToggle("Sounds", true, function(state)
	TomPearl:SetSoundEnabled(state)
	Window.Flags.Sounds = state
end)

Gen:CreateToggle("Notifications", true, function(state)
	Window.Flags.Notifications = state
end)

Gen:CreateKeybind("Toggle UI", Enum.KeyCode.P, function()
	Window:Toggle()
end)

Gen:CreateInput("Nickname", "type your name...", function(text)
	Window.Flags.Nickname = text
	print("[Example] Nickname:", text)
end)

Gen:CreateDropdown("Theme", {"Dark Blue", "Purple", "Red", "Green"}, "Dark Blue", function(v)
	Window.Flags.Theme = v
end)

local ConfigSec = SetTab:CreateSection("Config")

ConfigSec:CreateInput("Config name", "config.json", function(text)
	getgenv().ConfigName = text
end)

ConfigSec:CreateButton("Save Config", function()
	Window:SaveConfig(getgenv().ConfigName or "tompearl_config.json")
end)

ConfigSec:CreateButton("Load Config", function()
	Window:LoadConfig(getgenv().ConfigName or "tompearl_config.json")
end)

-- ======================
-- TAB: ABOUT
-- ======================

local AboutTab = Window:CreateTab("About")
local Info = AboutTab:CreateSection("Info")

Info:CreateLabel("Tom Pearl Menu")
Info:CreateLabel("Version 1.3.0 (slide animation)")
Info:CreateDivider()
Info:CreateLabel("Tap icon at top to open/close the menu")
Info:CreateLabel("Window slides up from bottom on open")
Info:CreateLabel("Window slides down off-screen on close")
Info:CreateLabel("Drag window by title bar")
Info:CreateLabel("Resize from bottom-right corner")
Info:CreateLabel("RightControl toggles, Escape closes")
Info:CreateDivider()
Info:CreateLabel("github.com/WareSploit/tompearl")

Info:CreateButton("Show notification", function()
	TomPearl:Notify({
		Title = "Hello",
		Content = "Tom Pearl Menu is running",
		Duration = 3,
		Type = "success",
	})
end)

-- ======================
-- DONE
-- ======================

print("[TomPearl] example.lua v1.3.0 executed | mobile=" .. tostring(IS_MOBILE))
