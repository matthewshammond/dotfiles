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

			-- Try to set wallpaper for the theme
			local theme_name = ThemeManager.get_current_theme_name()
			local themes_dir = os.getenv("CONFIG_DIR") and (os.getenv("CONFIG_DIR") .. "/themes") or "themes"

			local image_extensions = { "png", "jpg", "jpeg", "gif", "bmp", "tiff", "webp" }
			local wallpaper_path = nil

			-- Find wallpaper for the theme
			for _, ext in ipairs(image_extensions) do
				local test_path = themes_dir .. "/" .. theme_name .. "." .. ext
				local file = io.open(test_path, "r")
				if file then
					file:close()
					wallpaper_path = test_path
					break
				end
			end

			-- Set wallpaper if found
			if wallpaper_path then
				local absolute_path = wallpaper_path
				if wallpaper_path:sub(1, 1) == "." then
					absolute_path = os.getenv("PWD") .. wallpaper_path:sub(2)
				end

				local plist_path = os.getenv("HOME")
					.. "/Library/Application Support/com.apple.wallpaper/Store/Index.plist"

				-- Function to safely update a plist path
				local function update_plist_path(path, value)
					local command = string.format(
						'/usr/libexec/PlistBuddy -c "set %s file://%s" "%s" 2>/dev/null',
						path,
						value,
						plist_path
					)
					local result = os.execute(command)
					return result == 0 or result == true
				end

				-- Function to check if a plist path exists
				local function plist_path_exists(path)
					local command =
						string.format('/usr/libexec/PlistBuddy -c "Print %s" "%s" 2>/dev/null', path, plist_path)
					local result = os.execute(command)
					return result == 0 or result == true
				end

				-- Function to get all keys in a dictionary
				local function get_dict_keys(dict_path)
					local command =
						string.format('/usr/libexec/PlistBuddy -c "Print %s" "%s" 2>/dev/null', dict_path, plist_path)
					local handle = io.popen(command)
					if not handle then
						return {}
					end

					local content = handle:read("*all")
					handle:close()

					local keys = {}
					for key in content:gmatch("([%w%-]+) = Dict") do
						table.insert(keys, key)
					end
					return keys
				end

				local success = false

				-- Try to update SystemDefault if it exists
				if plist_path_exists("SystemDefault:Desktop:Content:Choices:0:Files:0:relative") then
					success = update_plist_path(
						"SystemDefault:Desktop:Content:Choices:0:Files:0:relative",
						absolute_path
					) or success
				end

				-- Try to update AllSpacesAndDisplays if it exists
				if plist_path_exists("AllSpacesAndDisplays:Desktop:Content:Choices:0:Files:0:relative") then
					success = update_plist_path(
						"AllSpacesAndDisplays:Desktop:Content:Choices:0:Files:0:relative",
						absolute_path
					) or success
				end

				-- Try to update Displays section if it exists
				if plist_path_exists("Displays") then
					local display_keys = get_dict_keys("Displays")
					for _, display_id in ipairs(display_keys) do
						local display_path =
							string.format("Displays:%s:Desktop:Content:Choices:0:Files:0:relative", display_id)
						if plist_path_exists(display_path) then
							update_plist_path(display_path, absolute_path)
						end
					end
				end

				-- Try to update Spaces section if it exists
				if plist_path_exists("Spaces") then
					local space_keys = get_dict_keys("Spaces")
					for _, space_id in ipairs(space_keys) do
						-- Try different possible paths for each space
						local space_paths = {
							string.format("Spaces:%s:Desktop:Content:Choices:0:Files:0:relative", space_id),
							string.format("Spaces:%s:Default:Desktop:Content:Choices:0:Files:0:relative", space_id),
						}

						for _, space_path in ipairs(space_paths) do
							if plist_path_exists(space_path) then
								update_plist_path(space_path, absolute_path)
							end
						end

						-- Also try to update any displays within this space
						local space_displays_path = string.format("Spaces:%s:Displays", space_id)
						if plist_path_exists(space_displays_path) then
							local display_keys = get_dict_keys(space_displays_path)
							for _, display_id in ipairs(display_keys) do
								local display_path = string.format(
									"Spaces:%s:Displays:%s:Desktop:Content:Choices:0:Files:0:relative",
									space_id,
									display_id
								)
								if plist_path_exists(display_path) then
									update_plist_path(display_path, absolute_path)
								end
							end
						end
					end
				end

				if success then
					os.execute("killall WallpaperAgent 2>/dev/null")
				end
			end

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
