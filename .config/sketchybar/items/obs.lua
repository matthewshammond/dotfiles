local colors = require("colors")
local settings = require("settings")
local popup = require("helpers.popup")
local theme_system = require("themes")
local ThemeManager = theme_system.manager

-- OBS scene switcher. Sits right after space 8 (Simon).
-- name must match the OBS scene name exactly; label (optional) is the menu text; key_code is the hotkey fallback
-- (opt+shift+<key>). Key codes: a=0, s=1, d=2, m=46
local scenes = {
	{ name = "Southern Company", key_code = 1 },
	{ name = "MHI", label = "Matt Hammond Inc", key_code = 46 },
	{ name = "AeroPoint", key_code = 0 },
	{ name = "Demo", key_code = 2 },
}

local function theme_colors()
	local theme = ThemeManager.get_current_theme()
	return (theme and theme.colors) or colors
end

-- Geometry mirrors the minimal-theme space icons in items/spaces.lua
local obs = sbar.add("item", "obs", {
	position = "left",
	padding_left = 0,
	padding_right = 0,
	icon = {
		string = ":obsstudio:",
		font = "sketchybar-app-font:Regular:15.0",
		color = theme_colors().space_icon or colors.grey,
		padding_left = 2,
		padding_right = 1,
	},
	label = {
		string = "",
		padding_right = 5,
	},
	background = { color = colors.transparent, border_width = 0, height = 20 },
	popup = { align = "left" },
})

local obs_padding = sbar.add("item", "obs.padding", {
	position = "left",
	width = settings.group_paddings,
})

local obs_popup = popup.controller(obs, { hide_delay = 0.25 })

local config_dir = os.getenv("CONFIG_DIR") or (os.getenv("HOME") .. "/.config/sketchybar")
local obs_helper = "/usr/bin/python3 " .. string.format("%q", config_dir .. "/helpers/obs_scene.py")

-- Switch directly through the OBS websocket so it works from any app or space.
-- If the websocket is unreachable, fall back to the scene hotkey.
local function send_scene(scene)
	local cmd = obs_helper
		.. " "
		.. string.format("%q", scene.name)
		.. " || osascript -e 'tell application \"System Events\" to key code "
		.. scene.key_code
		.. " using {option down, shift down}'"
	sbar.exec(cmd)
end

local header = sbar.add("item", "obs.popup.header", {
	position = "popup." .. obs.name,
	icon = { drawing = false },
	label = {
		string = "OBS Scenes",
		font = { size = 14.0, weight = "bold" },
		color = theme_colors().white,
		padding_left = 10,
		padding_right = 10,
	},
	background = {
		color = theme_colors().bg2,
		border_color = theme_colors().blue,
		border_width = 1,
		corner_radius = 8,
	},
	width = 200,
})

local rows = {}
for i, scene in ipairs(scenes) do
	local row = sbar.add("item", "obs.popup.scene." .. i, {
		position = "popup." .. obs.name,
		icon = { drawing = false },
		label = {
			string = scene.label or scene.name,
			font = { size = 12.0 },
			color = theme_colors().white,
			padding_left = 10,
			padding_right = 10,
		},
		background = { color = colors.transparent, corner_radius = 6, height = 22 },
		width = 200,
	})
	rows[i] = row

	row:subscribe("mouse.entered", function()
		row:set({ label = { color = theme_colors().blue } })
	end)
	row:subscribe("mouse.exited", function()
		row:set({ label = { color = theme_colors().white } })
	end)
	row:subscribe("mouse.clicked", function()
		send_scene(scene)
		obs_popup.hide_now()
	end)
end

-- Big cursor toggle for demos: pointer size 4.0 <-> previous size
local cursor_toggle = string.format("%q", config_dir .. "/helpers/cursor_size/toggle.sh")
local function cursor_label(state)
	return "Big Cursor: " .. ((state or ""):match("on") and "On" or "Off")
end
local cursor_row = sbar.add("item", "obs.popup.cursor", {
	position = "popup." .. obs.name,
	icon = { drawing = false },
	label = {
		string = cursor_label("off"),
		font = { size = 12.0 },
		color = theme_colors().white,
		padding_left = 10,
		padding_right = 10,
	},
	background = { color = colors.transparent, corner_radius = 6, height = 22 },
	width = 200,
})
rows[#rows + 1] = cursor_row
sbar.exec(cursor_toggle .. " status", function(out)
	cursor_row:set({ label = { string = cursor_label(out) } })
end)
cursor_row:subscribe("mouse.entered", function()
	cursor_row:set({ label = { color = theme_colors().blue } })
end)
cursor_row:subscribe("mouse.exited", function()
	cursor_row:set({ label = { color = theme_colors().white } })
end)
cursor_row:subscribe("mouse.clicked", function()
	sbar.exec(cursor_toggle, function(out)
		cursor_row:set({ label = { string = cursor_label(out) } })
	end)
end)

obs:subscribe("mouse.clicked", obs_popup.keep)
-- Fires only once the mouse has left both the icon and its menu
obs:subscribe("mouse.exited.global", obs_popup.hide_now)

-- Spaces are rebuilt on theme change, so put OBS back right after the robot
local function place_after_simon()
	sbar.exec("sketchybar --move obs after space.padding.8 --move obs.padding after obs")
end
place_after_simon()

obs:subscribe("theme_changed", function()
	local c = theme_colors()
	obs:set({ icon = { color = c.space_icon or colors.grey } })
	header:set({ label = { color = c.white }, background = { color = c.bg2, border_color = c.blue } })
	for _, row in ipairs(rows) do
		row:set({ label = { color = c.white } })
	end
	sbar.delay(0.3, place_after_simon)
end)
