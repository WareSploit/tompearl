--[[
	Tom Pearl Menu — Example
	Вставь в экзекьютор и Execute.
	Библиотека подгружается с GitHub raw.
]]

-- ======================
-- LOAD LIBRARY
-- ======================

local LIB_URL = "https://raw.githubusercontent.com/ТВОЙ_НИК/tompearl/main/main.lua"

local ok, TomPearl = pcall(function()
	return loadstring(game:HttpGet(LIB_URL))()
end)

if not ok or not TomPearl then
	warn("[TomPearl] Failed to load library:", TomPearl)
	return
end

-- ======================
-- CREATE WINDOW
-- ======================

local Window = TomPearl:CreateWindow({
	Name = "Tom Pearl Menu",
	Icon = "rbxassetid://5607058200",
	Size = UDim2.new(0, 400, 0, 440),
	ToggleKey = Enum.KeyCode.RightControl,
})

-- ======================
-- TAB: MAIN
-- ======================

local MainTab = Window:CreateTab("Main")

-- Section: Combat
local Combat = MainTab:CreateSection("Combat")

Combat:CreateToggle("Auto Parry", false, function(state)
	print("[Example] Auto Parry:", state)
	-- здесь твоя логика auto parry
end)

Combat:CreateToggle("Auto Block", false, function(state)
	print("[Example] Auto Block:", state)
end)

Combat:CreateSlider("Reach", 1, 50, 9, function(value)
	print("[Example] Reach:", value)
end)

Combat:CreateSlider("Hitbox Size", 0, 20, 5, function(value)
	print("[Example] Hitbox:", value)
end)

Combat:CreateDropdown("Mode", {"Parry", "Dodge", "Hybrid", "Aggressive"}, "Parry", function(selected)
	print("[Example] Mode:", selected)
end)

-- Section: Actions
local Actions = MainTab:CreateSection("Actions")

Actions:CreateButton("Refresh Target", function()
	print("[Example] Refresh clicked")
end)

Actions:CreateButton("Panic (Disable All)", function()
	print("[Example] Panic")
	TomPearl:Notify({
		Title = "Panic",
		Content = "All functions disabled",
		Duration = 2,
		Type = "warning",
	})
end)

-- ======================
-- TAB: MISC
-- ======================

local MiscTab = Window:CreateTab("Misc")

local PlayerSection = MiscTab:CreateSection("Player")

PlayerSection:CreateSlider("WalkSpeed", 16, 200, 16, function(v)
	-- game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
	print("[Example] WalkSpeed:", v)
end)

PlayerSection:CreateSlider("JumpPower", 50, 500, 50, function(v)
	print("[Example] JumpPower:", v)
end)

PlayerSection:CreateToggle("Infinite Jump", false, function(state)
	print("[Example] InfJump:", state)
end)

local Settings = MiscTab:CreateSection("Settings")

Settings:CreateInput("Nickname", "type your name...", function(text)
	print("[Example] Input:", text)
end)

Settings:CreateKeybind("Toggle UI", Enum.KeyCode.P, function()
	Window:Toggle()
end)

Settings:CreateLabel("Tom Pearl Menu v1.0.0")
Settings:CreateDivider()
Settings:CreateLabel("github.com/ТВОЙ_НИК/tompearl")

-- ======================
-- TAB: ABOUT
-- ======================

local AboutTab = Window:CreateTab("About")
local About = AboutTab:CreateSection("Info")

About:CreateLabel("Tom Pearl Menu")
About:CreateLabel("Version 1.0.0")
About:CreateDivider()
About:CreateLabel("Press RCTRL to toggle window")
About:CreateLabel("Click the icon at top to open menu")

About:CreateButton("Show notification", function()
	TomPearl:Notify({
		Title = "Hello",
		Content = "This is Tom Pearl Menu",
		Duration = 3,
		Type = "success",
	})
end)

-- ======================
-- WELCOME
-- ======================

TomPearl:Notify({
	Title = "Tom Pearl Menu",
	Content = "Загружено успешно",
	Duration = 3,
	Type = "success",
})

print("[TomPearl] example.lua executed")
