local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local popup = require("helpers.popup")

-- Desktops (Mac mini, Studio, iMac, Mac Pro) have no InternalBattery.
local function has_internal_battery()
	local pipe = io.popen("pmset -g batt 2>/dev/null")
	if not pipe then
		return false
	end
	local info = pipe:read("*a") or ""
	pipe:close()
	return info:find("InternalBattery", 1, true) ~= nil
end

if not has_internal_battery() then
	return
end

local battery = sbar.add("item", "widgets.battery", {
	position = "right",
	icon = {
		font = {
			style = settings.font.style_map["Regular"],
			size = 19.0,
		},
	},
	label = { font = { family = settings.font.numbers } },
	update_freq = 180,
	popup = { align = "center" },
})

local remaining_time = sbar.add("item", {
	position = "popup." .. battery.name,
	icon = {
		string = "Time remaining:",
		width = 100,
		align = "left",
	},
	label = {
		string = "??:??h",
		width = 100,
		align = "right",
	},
})

-- Function to update battery colors based on current theme
local function update_battery_colors()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"
		local label = "?"

		local found, _, charge = batt_info:find("(%d+)%%")
		if found then
			charge = tonumber(charge)
			label = charge .. "%"
		end

		local battery_color = colors.green
		local charging, _, _ = batt_info:find("AC Power")

		if charging then
			icon = icons.battery.charging
		else
			if found and charge > 80 then
				icon = icons.battery._100
			elseif found and charge > 60 then
				icon = icons.battery._75
			elseif found and charge > 40 then
				icon = icons.battery._50
			elseif found and charge > 20 then
				icon = icons.battery._25
				battery_color = colors.orange
			else
				icon = icons.battery._0
				battery_color = colors.red
			end
		end

		local lead = ""
		if found and charge < 10 then
			lead = "0"
		end

		battery:set({
			icon = {
				string = icon,
				color = battery_color,
			},
			label = {
				string = lead .. label,
				color = colors.battery_widget_text or colors.white,
			},
		})
	end)
end

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"
		local label = "?"

		local found, _, charge = batt_info:find("(%d+)%%")
		if found then
			charge = tonumber(charge)
			label = charge .. "%"
		end

		local battery_color = colors.green
		local charging, _, _ = batt_info:find("AC Power")

		if charging then
			icon = icons.battery.charging
		else
			if found and charge > 80 then
				icon = icons.battery._100
			elseif found and charge > 60 then
				icon = icons.battery._75
			elseif found and charge > 40 then
				icon = icons.battery._50
			elseif found and charge > 20 then
				icon = icons.battery._25
				battery_color = colors.orange
			else
				icon = icons.battery._0
				battery_color = colors.red
			end
		end

		local lead = ""
		if found and charge < 10 then
			lead = "0"
		end

		battery:set({
			icon = {
				string = icon,
				color = battery_color,
			},
			label = {
				string = lead .. label,
				color = colors.battery_widget_text or colors.white,
			},
		})
	end)
end)

-- Subscribe to theme changes
battery:subscribe("theme_changed", function()
	update_battery_colors()
end)

local battery_popup = popup.controller(battery)

local function show_battery_details()
	battery_popup.keep()
	sbar.exec("pmset -g batt", function(batt_info)
		local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
		local label = found and remaining .. "h" or "No estimate"
		remaining_time:set({ label = label })
	end)
end

battery:subscribe("mouse.entered", show_battery_details)
battery:subscribe("mouse.exited", battery_popup.hide_now)

sbar.add("bracket", "widgets.battery.bracket", { battery.name }, {
	background = { color = colors.battery_widget_bg or colors.transparent },
})

sbar.add("item", "widgets.battery.padding", {
	position = "right",
	width = settings.group_paddings,
})
