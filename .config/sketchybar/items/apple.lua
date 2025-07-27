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
			
			local image_extensions = {"png", "jpg", "jpeg", "gif", "bmp", "tiff", "webp"}
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
				
				local plist_path = os.getenv("HOME") .. "/Library/Application Support/com.apple.wallpaper/Store/Index.plist"
				
				-- Update the existing plist structure using PlistBuddy
				-- Update SystemDefault
				local command = string.format('/usr/libexec/PlistBuddy -c "set SystemDefault:Desktop:Content:Choices:0:Files:0:relative file://%s" "%s"', absolute_path, plist_path)
				local result = os.execute(command)
				
				-- Update Displays
				command = string.format('/usr/libexec/PlistBuddy -c "set Displays:37D8832A-2D66-02CA-B9F7-8F30A301B230:Desktop:Content:Choices:0:Files:0:relative file://%s" "%s"', absolute_path, plist_path)
				result = os.execute(command) or result
				
				-- Update known space IDs
				local known_space_ids = {
					"7C01335A-6F11-438B-A860-B77627C0A098",
					"54733FBD-7461-40A5-93EA-438A010028B8", 
					"877F7393-DFDD-4C7B-AA73-E16E80BDC4C7",
					"9DD66961-2812-4505-8854-1B209C7F1B8A",
					"CF83B9F3-30DD-4311-BC58-45D159A7792F",
					"158B1F3B-B95F-48D1-83B8-EBDE139B4B2D"
				}
				
				for _, space_id in ipairs(known_space_ids) do
					command = string.format('/usr/libexec/PlistBuddy -c "set Spaces:%s:Default:Desktop:Content:Choices:0:Files:0:relative file://%s" "%s"', space_id, absolute_path, plist_path)
					os.execute(command .. " 2>/dev/null")
					
					command = string.format('/usr/libexec/PlistBuddy -c "set Spaces:%s:Displays:37D8832A-2D66-02CA-B9F7-8F30A301B230:Desktop:Content:Choices:0:Files:0:relative file://%s" "%s"', space_id, absolute_path, plist_path)
					os.execute(command .. " 2>/dev/null")
				end
				
				if result == 0 or result == true then
					os.execute("killall WallpaperAgent 2>/dev/null")
				end
			end
			
			-- Show theme change notification
			sbar.exec(string.format('osascript -e \'display notification "%s" with title "SketchyBar Theme"\'', new_theme.name))

			-- Trigger the theme_changed event
			sbar.exec("sketchybar --trigger theme_changed")

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
