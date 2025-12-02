#!/usr/bin/env lua

-- Standalone theme cycling script
-- Usage: lua theme_cycle.lua [next|prev|theme_name]

-- Add the current directory to the package path
local config_dir = os.getenv("CONFIG_DIR") or "."
package.path = package.path .. ";" .. config_dir .. "/?.lua"

local theme_system = require("themes")
local ThemeManager = theme_system.manager

-- State file to persist current theme index
local state_file = config_dir .. "/theme_state.txt"

-- Load current theme index from state file
local function load_theme_index()
	local file = io.open(state_file, "r")
	if file then
		local index = tonumber(file:read("*line"))
		file:close()
		return index or 1
	end
	return 1
end

-- Save current theme index to state file
local function save_theme_index(index)
	local file = io.open(state_file, "w")
	if file then
		file:write(tostring(index))
		file:close()
	end
end

-- Set the current theme index from state file
ThemeManager.current_theme_index = load_theme_index()

local action = arg[1] or "next"

if action == "next" then
	ThemeManager.next_theme()
	save_theme_index(ThemeManager.current_theme_index)
	print("Switched to theme: " .. ThemeManager.get_current_theme().name)
elseif action == "prev" then
	ThemeManager.prev_theme()
	save_theme_index(ThemeManager.current_theme_index)
	print("Switched to theme: " .. ThemeManager.get_current_theme().name)
elseif action == "list" then
	print("Available themes:")
	for i, theme_name in ipairs(ThemeManager.theme_names) do
		local theme = ThemeManager.themes[theme_name]
		local marker = (i == ThemeManager.current_theme_index) and " *" or ""
		print(string.format("  %d. %s%s", i, theme.name, marker))
	end
elseif action == "current" then
	print("Current theme: " .. ThemeManager.get_current_theme().name)
else
	-- Try to set specific theme
	local theme = ThemeManager.set_theme(action)
	if theme then
		save_theme_index(ThemeManager.current_theme_index)
		print("Switched to theme: " .. theme.name)
	else
		print("Unknown theme: " .. action)
		print("Available themes: " .. table.concat(ThemeManager.theme_names, ", "))
	end
end

-- Wallpaper management functions (duplicated from themes.lua for standalone use)
local function find_wallpaper_for_theme(theme_name)
	local themes_dir = config_dir .. "/themes"
	local image_extensions = { "png", "jpg", "jpeg", "gif", "bmp", "tiff", "webp" }

	for _, ext in ipairs(image_extensions) do
		local wallpaper_path = themes_dir .. "/" .. theme_name .. "." .. ext
		local file = io.open(wallpaper_path, "r")
		if file then
			file:close()
			return wallpaper_path
		end
	end
	return nil
end

local function set_wallpaper_for_all_spaces(wallpaper_path)
	if not wallpaper_path then
		return false
	end

	-- Convert relative path to absolute path
	local absolute_path = wallpaper_path
	if wallpaper_path:sub(1, 1) == "." then
		absolute_path = os.getenv("PWD") .. wallpaper_path:sub(2)
	end

	-- Use the macOS Sonoma .plist method for setting wallpapers on all spaces
	local plist_path = os.getenv("HOME") .. "/Library/Application Support/com.apple.wallpaper/Store/Index.plist"

	-- Check if the plist file exists
	local plist_file = io.open(plist_path, "r")
	if not plist_file then
		-- Fallback to AppleScript if plist doesn't exist
		local script = string.format(
			[[
            tell application "System Events"
                set desktopCount to count of desktops
                repeat with i from 1 to desktopCount
                    set picture of desktop i to "%s"
                end repeat
            end tell
        ]],
			absolute_path
		)

		local result = os.execute("osascript -e '" .. script .. "'")
		return result == 0 or result == true
	end
	plist_file:close()

	-- Function to check if a plist path exists
	local function plist_path_exists(path)
		local command = string.format('/usr/libexec/PlistBuddy -c "Print %s" "%s" 2>/dev/null', path, plist_path)
		local result = os.execute(command)
		return result == 0 or result == true
	end

	-- Function to update Configuration data (for macOS Tahoe)
	-- Uses Python to create binary plist and update the Configuration key
	local function update_configuration_data(choices_path, wallpaper_path)
		local config_path = choices_path .. ":Configuration"

		-- Check if Configuration exists
		if not plist_path_exists(config_path) then
			return false
		end

		-- Create temporary Python script file
		local python_script_file = os.tmpname() .. ".py"
		local python_script = string.format([[
import plistlib
import tempfile
import sys

config = {
    'type': 'imageFile',
    'url': {
        'relative': 'file://%s'
    }
}

# Create binary plist
binary_data = plistlib.dumps(config, fmt=plistlib.FMT_BINARY)

# Write to temp file
temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.plist')
temp_file.write(binary_data)
temp_file.close()
print(temp_file.name)
]], wallpaper_path:gsub("\\", "\\\\"):gsub("'", "\\'"))

		-- Write Python script to temp file
		local script_file = io.open(python_script_file, "w")
		if not script_file then
			return false
		end
		script_file:write(python_script)
		script_file:close()

		-- Execute Python script to create binary plist
		local python_command = string.format('python3 "%s" 2>/dev/null', python_script_file)
		local handle = io.popen(python_command)
		if not handle then
			os.remove(python_script_file)
			return false
		end

		local temp_plist = handle:read("*line")
		handle:close()
		os.remove(python_script_file)

		if not temp_plist or temp_plist == "" then
			return false
		end

		-- Use PlistBuddy to import the binary data
		local import_command = string.format('/usr/libexec/PlistBuddy -c "Import %s %s" "%s" 2>/dev/null', config_path, temp_plist, plist_path)
		local result = os.execute(import_command)

		-- Clean up temp plist file
		os.remove(temp_plist)

		return result == 0 or result == true
	end

	-- Function to get all keys in a dictionary
	local function get_dict_keys(dict_path)
		local command = string.format('/usr/libexec/PlistBuddy -c "Print %s" "%s" 2>/dev/null', dict_path, plist_path)
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

	-- Try to update SystemDefault if it exists (macOS Tahoe uses Configuration data)
	local system_default_choices = "SystemDefault:Desktop:Content:Choices:0"
	if plist_path_exists(system_default_choices) then
		success = update_configuration_data(system_default_choices, absolute_path) or success
	end

	-- Try to update AllSpacesAndDisplays if it exists (macOS Tahoe uses Configuration data)
	local all_spaces_choices = "AllSpacesAndDisplays:Desktop:Content:Choices:0"
	if plist_path_exists(all_spaces_choices) then
		success = update_configuration_data(all_spaces_choices, absolute_path) or success
	end

	-- Try to update Displays section if it exists (macOS Tahoe uses Configuration data)
	if plist_path_exists("Displays") then
		local display_keys = get_dict_keys("Displays")
		for _, display_id in ipairs(display_keys) do
			local display_choices = string.format("Displays:%s:Desktop:Content:Choices:0", display_id)
			if plist_path_exists(display_choices) then
				if update_configuration_data(display_choices, absolute_path) then
					success = true
				end
			end
		end
	end

	-- Try to update Spaces section if it exists (macOS Tahoe uses Configuration data)
	if plist_path_exists("Spaces") then
		local space_keys = get_dict_keys("Spaces")
		for _, space_id in ipairs(space_keys) do
			-- Try different possible paths for each space
			local space_choices_paths = {
				string.format("Spaces:%s:Desktop:Content:Choices:0", space_id),
				string.format("Spaces:%s:Default:Desktop:Content:Choices:0", space_id),
			}

			for _, space_choices in ipairs(space_choices_paths) do
				if plist_path_exists(space_choices) then
					if update_configuration_data(space_choices, absolute_path) then
						success = true
					end
				end
			end

			-- Also try to update any displays within this space
			local space_displays_path = string.format("Spaces:%s:Displays", space_id)
			if plist_path_exists(space_displays_path) then
				local display_keys = get_dict_keys(space_displays_path)
				for _, display_id in ipairs(display_keys) do
					local display_choices = string.format("Spaces:%s:Displays:%s:Desktop:Content:Choices:0", space_id, display_id)
					if plist_path_exists(display_choices) then
						if update_configuration_data(display_choices, absolute_path) then
							success = true
						end
					end
				end
			end
		end
	end

	if success then
		-- Kill WallpaperAgent to apply changes
		os.execute("killall WallpaperAgent 2>/dev/null")
		return true
	else
		-- Fallback to AppleScript if PlistBuddy fails
		local script = string.format(
			[[
            tell application "System Events"
                set desktopCount to count of desktops
                repeat with i from 1 to desktopCount
                    set picture of desktop i to "%s"
                end repeat
            end tell
        ]],
			absolute_path
		)

		local result = os.execute("osascript -e '" .. script .. "'")
		return result == 0 or result == true
	end
end

-- If we're being called from sketchybar, apply the theme
if os.getenv("CONFIG_DIR") or true then
	-- This is being called from sketchybar, so apply the theme
	local theme = ThemeManager.get_current_theme()
	local theme_name = ThemeManager.get_current_theme_name()

	-- Update bar configuration
	os.execute(
		string.format(
			"sketchybar --bar height=%d corner_radius=%d y_offset=%d color=0x%x",
			theme.bar_config.height,
			theme.bar_config.corner_radius,
			theme.bar_config.y_offset,
			theme.colors.bar.bg
		)
	)

	-- Try to set wallpaper for the theme
	local wallpaper_path = find_wallpaper_for_theme(theme_name)
	if wallpaper_path then
		set_wallpaper_for_all_spaces(wallpaper_path)
	end

	-- Update Neovim theme if specified in the current theme
	if theme.neovim_theme then
		local nvim_theme_file = os.getenv("HOME") .. "/.config/nvim/lua/config/theme.lua"
		local file = io.open(nvim_theme_file, "w")
		if file then
			file:write('return "' .. theme.neovim_theme .. '"\n')
			file:close()
			print("Updated Neovim theme to: " .. theme.neovim_theme)
		else
			print("Warning: Could not update Neovim theme file: " .. nvim_theme_file)
		end
	end

	-- Update Ghostty theme and opacity if specified in the current theme
	if theme.ghostty_theme or theme.ghostty_opacity then
		local ghostty_config_file = os.getenv("HOME") .. "/.config/ghostty/config"
		local file = io.open(ghostty_config_file, "r")
		if file then
			local content = file:read("*all")
			file:close()
			local new_content = content

			-- Replace the theme line if specified
			if theme.ghostty_theme then
				new_content = new_content:gsub("theme = [^\n]+", "theme = " .. theme.ghostty_theme)
				print("Updated Ghostty theme to: " .. theme.ghostty_theme)
			end

			-- Replace the background-opacity line if specified
			if theme.ghostty_opacity then
				new_content =
					new_content:gsub("background%-opacity = [^\n]+", "background-opacity = " .. theme.ghostty_opacity)
				print("Updated Ghostty opacity to: " .. theme.ghostty_opacity)
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
				os.execute("osascript -e '" .. applescript .. "' 2>/dev/null")
				print("Triggered Ghostty config reload")
			else
				print("Warning: Could not write to Ghostty config file: " .. ghostty_config_file)
			end
		else
			print("Warning: Could not read Ghostty config file: " .. ghostty_config_file)
		end
	end

	-- Update Übersicht clock widget if specified in the current theme
	if theme.ubersicht_clock then
		local ubersicht_widget_file = os.getenv("HOME") .. "/Library/Application Support/Übersicht/widgets/flip-clock.widget/index.coffee"
		local file = io.open(ubersicht_widget_file, "r")
		if file then
			local content = file:read("*all")
			file:close()
			local new_content = content

			-- Update clock position
			if theme.ubersicht_clock.position then
				if theme.ubersicht_clock.position.top then
					new_content = new_content:gsub(
						"top: [^%s]+",
						function() return "top: " .. theme.ubersicht_clock.position.top end
					)
				end
				if theme.ubersicht_clock.position.left then
					new_content = new_content:gsub(
						"left: [^%s]+",
						function() return "left: " .. theme.ubersicht_clock.position.left end
					)
				end
			end

			-- Update background color
			if theme.ubersicht_clock.background then
				new_content = new_content:gsub(
					"background: #[%x]+",
					"background: " .. theme.ubersicht_clock.background
				)
			end

			-- Update font color (digits and separator)
			if theme.ubersicht_clock.font then
				new_content = new_content:gsub(
					"color: #[%x]+",
					"color: " .. theme.ubersicht_clock.font
				)
			end

			-- Write the updated content back
			local write_file = io.open(ubersicht_widget_file, "w")
			if write_file then
				write_file:write(new_content)
				write_file:close()
				print("Updated Übersicht clock widget colors and position")
				
				-- Trigger Übersicht refresh
				os.execute("osascript -e 'tell application \"Übersicht\" to refresh' 2>/dev/null")
			else
				print("Warning: Could not write to Übersicht widget file: " .. ubersicht_widget_file)
			end
		else
			print("Warning: Could not read Übersicht widget file: " .. ubersicht_widget_file)
		end
	end

	-- Trigger the theme_changed event to recreate spaces and update all widgets
	os.execute("sketchybar --trigger theme_changed")
end

