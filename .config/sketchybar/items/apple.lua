local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local theme_system = require("themes")
local ThemeManager = theme_system.manager
local popup = require("helpers.popup")

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

local apple_popup = popup.controller(apple)
local theme_popup_built = false

local function show_theme_popup()
	local current_theme = ThemeManager.get_current_theme()

	if theme_popup_built then
		apple_popup.keep()
		return
	end
	theme_popup_built = true

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

			-- Set wallpaper asynchronously to avoid blocking the UI
			-- Use the theme_cycle.lua script which already handles wallpaper updates correctly
			local config_dir = os.getenv("CONFIG_DIR") or "."
			local theme_name = ThemeManager.get_current_theme_name()
			sbar.exec(string.format('cd "%s" && lua theme_cycle.lua %s > /dev/null 2>&1 &', config_dir, theme_name))

			-- Update Neovim theme if specified in the current theme
			if new_theme.neovim_theme then
				local nvim_theme_file = os.getenv("HOME") .. "/.config/nvim/lua/config/theme.lua"
				local file = io.open(nvim_theme_file, "w")
				if file then
					file:write('return "' .. new_theme.neovim_theme .. '"\n')
					file:close()
					print("Updated Neovim theme to: " .. new_theme.neovim_theme)
				else
					print("Warning: Could not update Neovim theme file: " .. nvim_theme_file)
				end
			end

			-- Update Ghostty theme and opacity if specified in the current theme
			if new_theme.ghostty_theme or new_theme.ghostty_opacity then
				local ghostty_config_file = os.getenv("HOME") .. "/.config/ghostty/config"
				local file = io.open(ghostty_config_file, "r")
				if file then
					local content = file:read("*all")
					file:close()
					local new_content = content

					-- Replace the theme line if specified
					if new_theme.ghostty_theme then
						new_content = new_content:gsub("theme = [^\n]+", "theme = " .. new_theme.ghostty_theme)
						print("Updated Ghostty theme to: " .. new_theme.ghostty_theme)
					end

					-- Replace the background-opacity line if specified
					if new_theme.ghostty_opacity then
						new_content = new_content:gsub(
							"background%-opacity = [^\n]+",
							"background-opacity = " .. new_theme.ghostty_opacity
						)
						print("Updated Ghostty opacity to: " .. new_theme.ghostty_opacity)
					end

					-- Write the updated content back
					local write_file = io.open(ghostty_config_file, "w")
					if write_file then
						write_file:write(new_content)
						write_file:close()

						-- Trigger Ghostty config reload via AppleScript
						local applescript = [[
							tell application "System Events"
								tell process "Ghostty"
									click menu item "Reload Configuration" of menu "Ghostty" of menu bar item "Ghostty" of menu bar 1
								end tell
							end tell
						]]
						sbar.exec("osascript -e '" .. applescript .. "' 2>/dev/null")
						print("Triggered Ghostty config reload")
					else
						print("Warning: Could not write to Ghostty config file: " .. ghostty_config_file)
					end
				else
					print("Warning: Could not read Ghostty config file: " .. ghostty_config_file)
				end
			end

			-- Update Übersicht clock widget if specified in the current theme
			print("Checking for Übersicht clock configuration...")
			if new_theme.ubersicht_clock then
				print("Found Übersicht clock configuration for theme: " .. new_theme.name)
				local ubersicht_widget_file = os.getenv("HOME") .. "/Library/Application Support/Übersicht/widgets/flip-clock.widget/index.coffee"
				local file = io.open(ubersicht_widget_file, "r")
				if file then
					local content = file:read("*all")
					file:close()
					local new_content = content

					-- Update clock position
					if new_theme.ubersicht_clock.position then
						if new_theme.ubersicht_clock.position.top then
							new_content = new_content:gsub(
								"top: [^%s]+",
								function() return "top: " .. new_theme.ubersicht_clock.position.top end
							)
						end
						if new_theme.ubersicht_clock.position.left then
							new_content = new_content:gsub(
								"left: [^%s]+",
								function() return "left: " .. new_theme.ubersicht_clock.position.left end
							)
						end
					end

					-- Update background color
					if new_theme.ubersicht_clock.background then
						new_content = new_content:gsub(
							"background: #[%x]+",
							"background: " .. new_theme.ubersicht_clock.background
						)
					end

					-- Update font color (digits and separator)
					if new_theme.ubersicht_clock.font then
						new_content = new_content:gsub(
							"color: #[%x]+",
							"color: " .. new_theme.ubersicht_clock.font
						)
					end

					-- Write the updated content back
					local write_file = io.open(ubersicht_widget_file, "w")
					if write_file then
						write_file:write(new_content)
						write_file:close()
						print("Updated Übersicht clock widget colors and position")
						
						-- Trigger Übersicht refresh
						sbar.exec("osascript -e 'tell application \"Übersicht\" to refresh' 2>/dev/null")
					else
						print("Warning: Could not write to Übersicht widget file: " .. ubersicht_widget_file)
					end
				else
					print("Warning: Could not read Übersicht widget file: " .. ubersicht_widget_file)
				end
			else
				print("No Übersicht clock configuration found for theme: " .. new_theme.name)
			end

			-- Trigger the theme_changed event
			sbar.exec("sketchybar --trigger theme_changed")

			-- Update apple icon color
			apple:set({
				icon = {
					color = new_theme.colors.white,
				},
			})

			-- Close the popup
			apple:set({
				popup = {
					drawing = false,
				},
			})
			sbar.exec("sketchybar --remove theme_selector")
			for j = 1, #ThemeManager.theme_names do
				sbar.exec("sketchybar --remove theme_option_" .. j)
			end

			-- Force a full bar reload
			sbar.exec("sketchybar --reload")
		end)
	end

	apple_popup.keep()
end

apple:subscribe("mouse.clicked", show_theme_popup)
apple:subscribe("mouse.entered", show_theme_popup)
apple:subscribe("mouse.exited", apple_popup.hide_now)

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
