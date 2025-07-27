local theme_system = require("themes")
local ThemeManager = theme_system.manager

-- Get current theme
local theme = ThemeManager.get_current_theme()

-- Equivalent to the --bar domain
sbar.bar({
	topmost = "window",
	height = theme.bar_config.height,
	color = theme.colors.bar.bg,
	padding_right = 0,
	padding_left = 0,
	margin = 5,
	corner_radius = theme.bar_config.corner_radius,
	y_offset = theme.bar_config.y_offset,
})
