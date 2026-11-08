local colors = require("colors")
local settings = require("settings")
local popup = require("helpers.popup")
local theme_system = require("themes")
local ThemeManager = theme_system.manager

-- OBS control menu. Sits right after space 8 (Simon). Three sections:
--   Scenes  - switch the program scene
--   Cameras - show/hide a camera source in every scene that has it
--   Tools   - big cursor, and Screen share in the Demo scene
--
-- name/source must match OBS exactly; label (optional) is the menu text.
-- key_code (optional) is an opt+shift+<key> hotkey fallback used when the
-- OBS websocket is unreachable. Key codes: a=0, s=1, d=2, w=13, m=46
local scenes = {
	{ name = "Southern Company", key_code = 1 },
	{ name = "MHI", label = "Matt Hammond Inc", key_code = 46 },
	{ name = "AeroPoint", key_code = 0 },
	{ name = "Demo", key_code = 2 },
}

local cameras = {
	{ source = "Sony" },
	{ source = "Capcom", label = "iPhone" },
	{ source = "Webcam", key_code = 13 },
}

-- Screen share: full-screen capture source inside the Demo scene only
local SCREEN_SCENE = "Demo"
local SCREEN_SOURCE = "Screen"

local MENU_WIDTH = 200

local function theme_colors()
	local theme = ThemeManager.get_current_theme()
	return (theme and theme.colors) or colors
end

local config_dir = os.getenv("CONFIG_DIR") or (os.getenv("HOME") .. "/.config/sketchybar")
local function helper(name)
	return "/usr/bin/python3 " .. string.format("%q", config_dir .. "/helpers/" .. name)
end
local scene_helper = helper("obs_scene.py")
local camera_helper = helper("obs_camera.py")
local screen_helper = helper("obs_source.py")
	.. " "
	.. string.format("%q", SCREEN_SCENE)
	.. " "
	.. string.format("%q", SCREEN_SOURCE)
local cursor_toggle = string.format("%q", config_dir .. "/helpers/cursor_size/toggle.sh")

local function hotkey(key_code)
	return "osascript -e 'tell application \"System Events\" to key code "
		.. key_code
		.. " using {option down, shift down}' >/dev/null"
end

-- "on" / "off" from helper output, or nil if unknown
local function parse_state(out)
	local v = (out or ""):match("(o[nf]f?)")
	if v == "on" or v == "off" then
		return v
	end
	return nil
end

local function on_off(title, state)
	if state == "on" then
		return title .. ": On"
	elseif state == "off" then
		return title .. ": Off"
	end
	return title .. ": --"
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

sbar.add("item", "obs.padding", {
	position = "left",
	width = settings.group_paddings,
})

local obs_popup = popup.controller(obs, { hide_delay = 0.25 })

local headers = {}
local rows = {}

local function add_header(id, title)
	local header = sbar.add("item", "obs.popup.header." .. id, {
		position = "popup." .. obs.name,
		icon = { drawing = false },
		label = {
			string = title,
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
		width = MENU_WIDTH,
	})
	headers[#headers + 1] = header
	return header
end

local function add_row(id, text, on_click)
	local row = sbar.add("item", "obs.popup." .. id, {
		position = "popup." .. obs.name,
		icon = { drawing = false },
		label = {
			string = text,
			font = { size = 12.0 },
			color = theme_colors().white,
			padding_left = 10,
			padding_right = 10,
		},
		background = { color = colors.transparent, corner_radius = 6, height = 22 },
		width = MENU_WIDTH,
	})
	rows[#rows + 1] = row
	row:subscribe("mouse.entered", function()
		row:set({ label = { color = theme_colors().blue } })
	end)
	row:subscribe("mouse.exited", function()
		row:set({ label = { color = theme_colors().white } })
	end)
	row:subscribe("mouse.clicked", function()
		obs_popup.hide_now()
		on_click()
	end)
	return row
end

-- Scenes ----------------------------------------------------------------

local refresh_all -- defined below; scene switches refresh the toggle labels

add_header("scenes", "Scenes")
for i, scene in ipairs(scenes) do
	add_row("scene." .. i, scene.label or scene.name, function()
		-- websocket first (works from any space); hotkey fallback
		sbar.exec(scene_helper .. " " .. string.format("%q", scene.name) .. " || " .. hotkey(scene.key_code))
		sbar.delay(0.5, refresh_all)
	end)
end

-- Cameras ---------------------------------------------------------------

add_header("cameras", "Cameras")
local camera_refreshers = {}
for i, cam in ipairs(cameras) do
	local title = cam.label or cam.source
	local state = nil
	local base = camera_helper .. " " .. string.format("%q", cam.source)
	local row
	local function apply(out, flip_if_unknown)
		local v = parse_state(out)
		if v then
			state = v
		elseif flip_if_unknown and state then
			state = (state == "on") and "off" or "on"
		end
		row:set({ label = { string = on_off(title, state) } })
	end
	row = add_row("camera." .. i, on_off(title, nil), function()
		local cmd = base .. " toggle 2>/dev/null"
		if cam.key_code then
			cmd = cmd .. " || { " .. hotkey(cam.key_code) .. "; echo fallback; }"
		end
		sbar.exec(cmd, function(out)
			apply(out, true)
		end)
	end)
	camera_refreshers[#camera_refreshers + 1] = function()
		sbar.exec(base .. " status 2>/dev/null", function(out)
			apply(out, false)
		end)
	end
end

-- Tools -----------------------------------------------------------------

add_header("tools", "Tools")

-- Big cursor for demos: pointer size 4.0 <-> previous size
local function cursor_state(out)
	return (out or ""):match("on") and "on" or "off"
end
local cursor_row
cursor_row = add_row("cursor", on_off("Cursor", "off"), function()
	sbar.exec(cursor_toggle, function(out)
		cursor_row:set({ label = { string = on_off("Cursor", cursor_state(out)) } })
	end)
end)
sbar.exec(cursor_toggle .. " status", function(out)
	cursor_row:set({ label = { string = on_off("Cursor", cursor_state(out)) } })
end)

-- Screen share in the Demo scene. Check source names with:
--   obs_source.py Demo --list
local screen_row
local function run_screen(action)
	sbar.exec(screen_helper .. " " .. action .. " 2>/dev/null", function(out)
		screen_row:set({ label = { string = on_off("Screen", parse_state(out)) } })
	end)
end
screen_row = add_row("screen", on_off("Screen", nil), function()
	run_screen("toggle")
end)

-- Refresh + menu behaviour ----------------------------------------------

function refresh_all()
	for _, refresh in ipairs(camera_refreshers) do
		refresh()
	end
	run_screen("status")
end
refresh_all()

-- Icon click toggles the menu open/closed
obs:subscribe("mouse.clicked", function()
	local q = obs:query()
	if q and q.popup and q.popup.drawing == "on" then
		obs_popup.hide_now()
	else
		obs_popup.keep()
		refresh_all()
	end
end)
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
	for _, header in ipairs(headers) do
		header:set({ label = { color = c.white }, background = { color = c.bg2, border_color = c.blue } })
	end
	for _, row in ipairs(rows) do
		row:set({ label = { color = c.white } })
	end
	sbar.delay(0.3, place_after_simon)
end)
