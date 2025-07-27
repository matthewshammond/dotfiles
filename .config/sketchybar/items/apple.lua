local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local theme_system = require("themes")
local ThemeManager = theme_system.manager

-- Padding item required because of bracket
sbar.add("item", { width = 5 })

local apple = sbar.add("item", {
	icon = {
		font = { size = 14.0 },
		string = icons.apple,
		padding_right = 5,
		padding_left = 5,
		color = colors.white,
		width = 20,
	},
	label = { drawing = false },
	background = {
		color = colors.transparent,
		border_color = colors.transparent,
		border_width = 0,
	},
	padding_left = 1,
	padding_right = 1,
})

-- Handle theme selection popup on click
apple:subscribe("mouse.clicked", function()
	-- Get current theme
	local current_theme = ThemeManager.get_current_theme()

	-- Check if popup is already open
	local popup_state = sbar.exec("sketchybar --query theme_selector 2>/dev/null")
	if popup_state and popup_state ~= "" then
		-- Close existing popup
		apple:set({
			popup = {
				drawing = false,
			},
		})
		sbar.exec("sketchybar --remove theme_selector")
		for i = 1, #ThemeManager.theme_names do
			sbar.exec("sketchybar --remove theme_option_" .. i)
		end
		return
	end

	-- Create theme selection popup with better positioning
	local theme_popup = sbar.add("item", "theme_selector", {
		position = "popup." .. apple.name,
		label = {
			string = "Theme Selection",
			font = { size = 14.0, weight = "bold" },
			color = current_theme.colors.white,
			padding_left = 10,
			padding_right = 10,
		},
		background = {
			color = current_theme.colors.bg2,
			border_color = current_theme.colors.blue,
			border_width = 1,
			corner_radius = 8,
		},
		drawing = true,
		width = 200, -- Wider fixed width to prevent text cutoff
	})

	-- Add theme options
	for i, theme_name in ipairs(ThemeManager.theme_names) do
		local theme = ThemeManager.themes[theme_name]
		local is_selected = (i == ThemeManager.current_theme_index)
		local checkmark = is_selected and "✓ " or "  "

		local theme_option = sbar.add("item", "theme_option_" .. i, {
			position = "popup." .. apple.name,
			label = {
				string = checkmark .. theme.name,
				font = { size = 12.0 },
				color = is_selected and current_theme.colors.blue or current_theme.colors.white,
				padding_left = 10,
				padding_right = 10,
			},
			background = {
				color = current_theme.colors.transparent,
			},
			drawing = true,
			width = 200, -- Wider fixed width to match parent
		})

		-- Add click handler for theme selection
		theme_option:subscribe("mouse.clicked", function()
			-- Set the selected theme
			ThemeManager.current_theme_index = i

			-- Save theme state
			local state_file = os.getenv("CONFIG_DIR") and (os.getenv("CONFIG_DIR") .. "/theme_state.txt")
				or "theme_state.txt"
			local file = io.open(state_file, "w")
			if file then
				file:write(tostring(ThemeManager.current_theme_index))
				file:close()
			end

			-- Get the new theme
			local new_theme = ThemeManager.get_current_theme()

			-- Update bar configuration
			sbar.exec(
				string.format(
					"sketchybar --bar height=%d corner_radius=%d y_offset=%d color=0x%x",
					new_theme.bar_config.height,
					new_theme.bar_config.corner_radius,
					new_theme.bar_config.y_offset,
					new_theme.colors.bar.bg
				)
			)

			-- Trigger the theme_changed event
			sbar.exec("sketchybar --trigger theme_changed")

			-- Show notification
			sbar.exec(
				string.format(
					'osascript -e \'display notification "%s" with title "SketchyBar Theme"\'',
					new_theme.name
				)
			)

			-- Update apple icon color
			apple:set({
				icon = {
					color = new_theme.colors.white,
				},
			})

			-- Close the popup
			sbar.exec("sketchybar --remove theme_selector")
			for j = 1, #ThemeManager.theme_names do
				sbar.exec("sketchybar --remove theme_option_" .. j)
			end

			-- Force a full bar reload
			sbar.exec("sketchybar --reload")
		end)
	end

	-- Show the popup
	apple:set({
		popup = {
			drawing = "toggle",
		},
	})
end)

-- Subscribe to theme changes to update the apple icon
apple:subscribe("theme_changed", function()
	local theme = ThemeManager.get_current_theme()
	apple:set({
		icon = {
			color = theme.colors.white,
		},
	})
end)

-- Double border for apple using a single item bracket
sbar.add("bracket", { apple.name }, {
	background = {
		color = colors.transparent,
		height = 20,
		border_color = colors.transparent,
		border_width = 0,
	},
})

-- Padding item required because of bracket
sbar.add("item", { width = 5 })
