local settings = require("settings")
local colors = require("colors")
local icon = require("icons")

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

local cal = sbar.add("item", {
	icon = {
		color = colors.calendar_widget_icon or colors.black,
		padding_left = 8,
		font = {
			style = settings.font.style_map["Black"],
			size = 12.0,
		},
	},
	label = {
		color = colors.calendar_widget_text or colors.black,
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
		color = colors.calendar_widget_bg or colors.blue,
		border_color = colors.calendar_widget_border or colors.border2,
		border_width = 1,
		height = 20,
	},
	click_script = "open -a Calendar",
})

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

-- Function to update calendar colors
local function update_calendar_colors()
	cal:set({
		icon = { color = colors.calendar_widget_icon or colors.black },
		label = { color = colors.calendar_widget_text or colors.black },
		background = {
			color = colors.calendar_widget_bg or colors.blue,
			border_color = colors.calendar_widget_border or colors.border2,
		},
	})
end

-- Subscribe to theme changes
cal:subscribe("theme_changed", update_calendar_colors)

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
	cal:set({ icon = os.date("%a %b %d  "), label = os.date("􀐫 %H:%M") })
end)
