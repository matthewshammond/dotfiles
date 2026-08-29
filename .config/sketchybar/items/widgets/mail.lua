local settings = require("settings")
local colors = require("colors")

local config_dir = os.getenv("CONFIG_DIR") or (os.getenv("HOME") .. "/.config/sketchybar")
local mail_helper = "/usr/bin/python3 " .. string.format("%q", config_dir .. "/helpers/mail_counts.py")

sbar.add("item", { position = "right", width = settings.group_paddings })

local mail = sbar.add("item", "widgets.mail", {
	position = "right",
	icon = {
		string = "􀍖",
		color = colors.mail_widget_icon or colors.white,
		padding_left = 4,
		font = {
			style = settings.font.style_map["Regular"],
			size = 16.0,
		},
	},
	label = {
		string = "0",
		color = colors.mail_widget_text or colors.white,
		padding_right = 4,
		font = { family = settings.font.numbers },
	},
	background = {
		color = colors.mail_widget_bg or colors.transparent,
		border_color = colors.mail_widget_border or colors.border2,
		border_width = 1,
		height = 20,
	},
	update_freq = 120,
	click_script = "open -a Mail",
})

sbar.add("item", { position = "right", width = settings.group_paddings })

local function unread_color(count)
	if count == 0 then
		return colors.mail_widget_icon or colors.white
	elseif count < 10 then
		return colors.mail_widget_warning or colors.yellow
	end
	return colors.mail_widget_alert or colors.red
end

local function mail_update()
	sbar.exec(mail_helper, function(result)
		local total = 0
		for line in string.gmatch(result or "", "[^\r\n]+") do
			local count = tonumber(line:match("^(%d+)"))
			if count then
				total = total + count
			end
		end
		local color = unread_color(total)
		mail:set({
			icon = { color = color },
			label = {
				string = tostring(total),
				color = color,
			},
		})
	end)
end

mail:subscribe({ "forced", "routine", "system_woke", "theme_changed" }, mail_update)

mail_update()
