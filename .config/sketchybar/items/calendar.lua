local settings = require("settings")
local colors = require("colors")
local icon = require("icons")

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

local cal = sbar.add("item", {
	icon = {
		color = colors.black,
		padding_left = 8,
		font = {
			style = settings.font.style_map["Black"],
			size = 12.0,
		},
	},
	label = {
		color = colors.black,
		padding_right = 8,
		width = 80,
		align = "right",
		font = { family = settings.font.numbers, size = "14.0" },
	},
	position = "right",
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

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
	cal:set({ icon = os.date("%a %b %d  "), label = os.date("􀐫 %H:%M") })
end)
