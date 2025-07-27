local colors = require("colors")
local settings = require("settings")
local icons = require("icons")
local theme_system = require("themes")
local ThemeManager = theme_system.manager

local front_app = sbar.add("item", "front_app", {
	icon = {
		color = colors.bg2,
		padding_left = 8,
		font = {
			style = settings.font.style_map["Black"],
			size = 14.0,
		},
	},
	label = {
		color = colors.bg2,
		padding_right = 12,
		align = "center",
		font = {
			family = settings.font.numbers,
		},
	},
	position = "left",
	update_freq = 30,
	padding_left = 1,
	padding_right = 1,
	background = {
		color = colors.blue,
		border_color = colors.border2,
		border_width = 1,
		height = 20,
	},
})

front_app:subscribe("front_app_switched", function(env)
	front_app:set({
		label = {
			string = env.INFO,
		},
	})
end)

-- Function to check if current theme is minimal
local function is_minimal_theme()
    local theme = ThemeManager.get_current_theme()
    return theme and theme.minimal_spaces
end

-- Only enable toggle for non-minimal themes
front_app:subscribe("mouse.clicked", function(env)
    if not is_minimal_theme() then
        sbar.trigger("swap_menus_and_spaces")
    end
end)

-- Subscribe to theme changes to update behavior
front_app:subscribe("theme_changed", function()
    -- For minimal themes, ensure front_app is always visible
    if is_minimal_theme() then
        front_app:set({ drawing = true })
    end
end)
