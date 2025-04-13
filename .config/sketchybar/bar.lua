local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
	topmost = "window",
	height = 30,
	color = colors.bar.bg,
	padding_right = 0,
	padding_left = 0,
	margin = 5,
	corner_radius = 25,
	y_offset = 2,
})
