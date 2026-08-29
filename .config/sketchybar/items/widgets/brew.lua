local settings = require("settings")
local colors = require("colors")
local icons = require("icons")
local popup = require("helpers.popup")

local config_dir = os.getenv("CONFIG_DIR") or (os.getenv("HOME") .. "/.config/sketchybar")
local brew_helper = "/usr/bin/python3 " .. string.format("%q", config_dir .. "/helpers/brew_packages.py")

sbar.add("event", "brew_update")

sbar.add("item", { position = "right", width = settings.group_paddings })

local brew = sbar.add("item", "widgets.brew", {
	position = "right",
	icon = {
		string = "􀐛",
		color = colors.brew_widget_icon or colors.white,
		padding_left = 4,
		font = {
			style = settings.font.style_map["Regular"],
			size = 16.0,
		},
	},
	label = {
		string = "…",
		color = colors.brew_widget_text or colors.white,
		padding_right = 4,
		font = { family = settings.font.numbers },
	},
	background = {
		color = colors.brew_widget_bg or colors.transparent,
		border_color = colors.brew_widget_border or colors.border2,
		border_width = 1,
		height = 20,
	},
	update_freq = 300,
	popup = { align = "right" },
})

sbar.add("item", { position = "right", width = settings.group_paddings })

local popup_items = {}
local updating = false
local cached_list = nil
local brew_popup = popup.controller(brew)

local PACKAGE_ICONS = {
	formula = "🍺",
	cask = "📦",
	mas = "📱",
}

local function widget_color(count)
	if count > 0 then
		return colors.brew_widget_alert or colors.red
	end
	return colors.brew_widget_icon or colors.white
end

local function set_count(count)
	local color = widget_color(count)
	brew:set({
		icon = { string = "􀐛", color = color },
		label = {
			string = tostring(count),
			color = colors.brew_widget_text or colors.white,
		},
	})
end

local function clear_popup_items()
	for _, item_name in ipairs(popup_items) do
		sbar.remove(item_name)
	end
	popup_items = {}
end

local function add_popup_row(name, spec)
	sbar.add("item", name, spec)
	table.insert(popup_items, name)
end

local function populate_popup(result)
	if result == cached_list and #popup_items > 0 then
		return
	end
	cached_list = result
	clear_popup_items()

	local index = 0
	for line in string.gmatch(result or "", "[^\r\n]+") do
		local pkg_type, package_name = line:match("^([^\t]+)\t(.+)$")
		if package_name then
			add_popup_row("brew.popup." .. index, {
				position = "popup." .. brew.name,
				icon = {
					string = PACKAGE_ICONS[pkg_type] or "📦",
					color = colors.brew_widget_icon or colors.white,
					font = { size = 14.0 },
				},
				label = {
					string = package_name,
					color = colors.brew_widget_text or colors.white,
					font = { family = settings.font.text },
				},
			})
			index = index + 1
		end
	end

	if index == 0 then
		add_popup_row("brew.popup.empty", {
			position = "popup." .. brew.name,
			icon = { drawing = false },
			label = {
				string = updating and "Updating packages…" or "All packages up to date",
				color = colors.brew_widget_text or colors.white,
				font = { family = settings.font.text },
			},
		})
	end
end

local function refresh()
	sbar.exec(brew_helper .. " count", function(count_result)
		if not updating then
			local count = tonumber((count_result or ""):match("%d+")) or 0
			set_count(count)
		end
	end)
	sbar.exec(brew_helper .. " list", function(list_result)
		populate_popup(list_result)
	end)
end

brew:subscribe("mouse.entered", function()
	brew_popup.keep()
	if #popup_items == 0 then
		sbar.exec(brew_helper .. " list", function(list_result)
			populate_popup(list_result)
		end)
	end
end)

brew:subscribe("mouse.exited", brew_popup.hide_now)

brew:subscribe("mouse.clicked", function()
	if updating then
		return
	end
	updating = true
	brew_popup.hide_now()
	cached_list = nil
	populate_popup("")
	brew:set({
		icon = { string = icons.loading, color = colors.brew_widget_alert or colors.orange },
		label = { string = "…" },
	})
	-- Run detached so SketchyBar does not kill a multi-minute upgrade.
	sbar.exec(brew_helper .. " upgrade >/tmp/sketchybar-brew-upgrade.log 2>&1 &")
end)

brew:subscribe("brew_update", function()
	updating = false
	cached_list = nil
	refresh()
end)

brew:subscribe({ "forced", "routine", "theme_changed" }, function()
	if not updating then
		refresh()
	end
end)

brew:subscribe("system_woke", function()
	sbar.exec(brew_helper .. " fetch", function()
		if not updating then
			refresh()
		end
	end)
end)

refresh()
