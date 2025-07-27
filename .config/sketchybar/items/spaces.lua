local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local theme_system = require("themes")
local ThemeManager = theme_system.manager

local spaces = {}
local brackets = {}
local paddings = {}
local popups = {}

local show_icons = false
local show_numbers = true
local toggle_state = "icons" -- or "numbers"

-- Helper to check if current theme is minimal
local function is_minimal_theme()
	local theme = ThemeManager.get_current_theme()
	local is_minimal = theme and theme.minimal_spaces
	return is_minimal
end

-- Helper to get space count
local function get_space_count()
	return 7 -- Always 7 spaces for all themes
end

-- Helper to get space icon for minimal theme
local function get_space_icon(space_number)
	if not is_minimal_theme() then
		return tostring(space_number)
	end

	-- Use SF Symbols for minimal Nord theme (these were working before)
	local minimal_icons = {
		[1] = "􁕝", -- Notes icon (SF Symbol)
		[2] = "􀎭", -- Safari/Web icon (SF Symbol)
		[3] = "􀌥", -- Messages icon (SF Symbol)
		[4] = "􀎟", -- Home icon (SF Symbol)
		[5] = "􀪏", -- Terminal icon (SF Symbol)
		[6] = "􀍖", -- Mail icon (SF Symbol)
		[7] = "􀉉", -- Calendar icon (SF Symbol)
	}
	return minimal_icons[space_number] or tostring(space_number)
end

-- Remove all space items, brackets, paddings, popups
local function clear_spaces()
	for i = 1, 7 do  -- Only remove 7 spaces, not 10
		sbar.remove("space." .. i)
		sbar.remove("space.padding." .. i)
		sbar.remove("bracket.space." .. i)
		sbar.remove("popup.space." .. i)
	end
	spaces = {}
	brackets = {}
	paddings = {}
	popups = {}
end

-- Create all spaces, brackets, paddings, popups
local function create_spaces()
	clear_spaces()
	local count = get_space_count()
	local theme = ThemeManager.get_current_theme()
	local icon_color = theme.name == "Light" and theme.colors.black or colors.grey
	for i = 1, count do
		local icon_font = is_minimal_theme() and "sketchybar-app-font:Bold:14.0" or settings.font.numbers -- Larger font for minimal themes
		-- Adjust padding based on theme type
		local icon_padding_left = is_minimal_theme() and 2 or 5
		local icon_padding_right = is_minimal_theme() and 1 or 2
		local label_padding_right = is_minimal_theme() and 5 or 10

		local space = sbar.add("space", "space." .. i, {
			space = i,
			icon = {
				font = icon_font,
				string = get_space_icon(i),
				padding_left = icon_padding_left,
				padding_right = icon_padding_right,
				color = icon_color,
			},
			label = {
				padding_right = label_padding_right,
				font = "sketchybar-app-font:Regular:12.0",
				y_offset = -1,
				color = icon_color,
			},
			padding_right = 0,
			padding_left = 0,
			background = {
				color = colors.transparent,
				border_width = 0,
				height = 20,
				border_color = colors.bg2,
			},
			popup = {
				background = {
					border_width = 0,
					border_color = colors.transparent,
				},
			},
		})

		spaces[i] = space

		local bracket = sbar.add("bracket", "bracket.space." .. i, {
			space.name,
		}, {
			label = {
				color = colors.bg2,
			},
			background = {
				border_color = colors.bg1,
				height = 20,
				border_width = 1,
			},
		})
		brackets[i] = bracket

		paddings[i] = sbar.add("space", "space.padding." .. i, {
			space = i,
			script = "",
			width = settings.group_paddings,
		})

		popups[i] = sbar.add("item", "popup.space." .. i, {
			position = "popup." .. space.name,
			padding_left = 5,
			padding_right = 0,
			background = {
				drawing = true,
				image = {
					corner_radius = 25,
					scale = 0.2,
				},
			},
		})

		space:subscribe("space_change", function(env)
			local selected = env.SELECTED == "true"
			if is_minimal_theme() then
				-- Simple icon color change for minimal theme (no background highlighting)
				space:set({
					icon = {
						color = selected and 0xffE5E9F0 or icon_color,
					},
				})
				bracket:set({
					background = {
						color = colors.transparent,
						border_color = colors.transparent,
						border_width = 0,
					},
				})
			else
				-- Standard highlighting for full themes
				space:set({
					icon = {
						highlight = selected,
					},
					label = {
						highlight = selected,
					},
					background = {
						border_color = selected and colors.transparent or colors.bg2,
					},
				})
				bracket:set({
					background = {
						color = selected and colors.blue,
						border_color = selected and colors.black,
						border_width = selected and 1,
					},
					label = {
						color = selected and colors.bg1,
					},
				})
			end
		end)

		space:subscribe("mouse.clicked", function(env)
			if env.BUTTON == "other" then
				popups[i]:set({
					background = {
						image = "space." .. env.SID,
					},
				})
				space:set({
					popup = {
						drawing = "toggle",
					},
				})
			else
				-- Use correct key codes from skhd output for cmd+1, cmd+2, etc.
				local key_codes = { 0x12, 0x13, 0x14, 0x15, 0x17, 0x16, 0x1a }
				local key_code = key_codes[i]
				if key_code then
					sbar.exec(
						'osascript -e \'tell application "System Events" to key code '
							.. key_code
							.. " using {command down}'"
					)
				end
			end
		end)

		space:subscribe("mouse.exited", function(_)
			space:set({
				popup = {
					drawing = false,
				},
			})
		end)
	end
	-- Immediately update all space labels/icons after creation
	if is_minimal_theme() then
		for i, space in pairs(spaces) do
			space:set({ label = "" })
		end
	else
		for i, space in pairs(spaces) do
			-- Simulate the icon label update for full theme
			local icon_line = ""
			local no_app = true
			-- This will be updated by space_windows_change, but we can set a placeholder
			icon_line = " —"
			space:set({ label = icon_line })
		end
	end
	-- Reset toggle state for non-minimal themes
	if not is_minimal_theme() then
		toggle_state = "icons"
	end
end

-- Dummy item to subscribe to theme_changed and rebuild spaces
local theme_watcher = sbar.add("item", "spaces.theme_watcher", { drawing = false })
theme_watcher:subscribe("theme_changed", function()
	create_spaces()

	-- If switching to a full theme, trigger space refresh to populate icons
	if not is_minimal_theme() then
		-- Force refresh of space window observer to populate icons
		space_window_observer:set({ updates = true })
		-- Small delay to ensure spaces are created before triggering refresh
		sbar.exec("sleep 0.1 && sketchybar --trigger space_windows_change")
	end
end)

-- Initial creation
create_spaces()

local space_window_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

local spaces_indicator = sbar.add("item", {
	padding_left = -3,
	padding_right = 0,
	icon = {
		padding_left = 8,
		padding_right = 9,
		color = colors.blue,
		string = icons.switch.on,
	},
	label = {
		width = 0,
		padding_left = 0,
		padding_right = 8,
		string = "Spaces",
		color = colors.bg2,
	},
	background = {
		color = colors.with_alpha(colors.blue, 0.0),
		border_color = colors.with_alpha(colors.border, 0.0),
		height = 20,
	},
})

-- Show/hide spaces indicator based on theme
local function update_spaces_indicator()
	if is_minimal_theme() then
		spaces_indicator:set({ drawing = false })
	else
		spaces_indicator:set({ drawing = true })
	end
end
spaces_indicator:subscribe("theme_changed", function()
	update_spaces_indicator()
end)
update_spaces_indicator()

-- Toggle logic for non-minimal themes
spaces_indicator:subscribe("mouse.clicked", function(env)
	if is_minimal_theme() then
		return
	end
	if toggle_state == "icons" then
		toggle_state = "numbers"
		for i, space in pairs(spaces) do
			space:set({ label = tostring(i) })
		end
	else
		toggle_state = "icons"
		-- Will be set by space_windows_change event
		for i, space in pairs(spaces) do
			space:set({ label = "" })
		end
	end
	sbar.trigger("swap_menus_and_spaces")
	-- After toggling, if we're showing spaces, trigger space_windows_change for all spaces
	if toggle_state == "icons" then
		for i = 1, #spaces do
			sbar.trigger("space_windows_change", { space = i })
		end
	end
end)

-- Subscribe to swap_menus_and_spaces to update toggle icon
spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
	local currently_on = spaces_indicator:query().icon.value == icons.switch.on
	spaces_indicator:set({
		icon = currently_on and icons.switch.off or icons.switch.on,
	})
end)

space_window_observer:subscribe("space_windows_change", function(env)
	if is_minimal_theme() then
		-- For minimal theme, just clear the label
		sbar.animate("tanh", 10, function()
			if spaces[env.INFO.space] then
				spaces[env.INFO.space]:set({
					label = "",
				})
			end
		end)
	else
		if toggle_state == "icons" then
			local icon_line = ""
			local no_app = true
			for app, count in pairs(env.INFO.apps) do
				no_app = false
				local lookup = app_icons[app]
				local icon = ((lookup == nil) and app_icons["default"] or lookup)
				icon_line = icon_line .. " " .. icon
			end

			if no_app then
				icon_line = " —"
			end
			sbar.animate("tanh", 10, function()
				if spaces[env.INFO.space] then
					spaces[env.INFO.space]:set({
						label = icon_line,
					})
				end
			end)
		else
			-- toggle_state == "numbers"
			sbar.animate("tanh", 10, function()
				if spaces[env.INFO.space] then
					spaces[env.INFO.space]:set({
						label = { string = tostring(env.INFO.space) },
					})
				end
			end)
		end
	end
end)

spaces_indicator:subscribe("mouse.entered", function(env)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = {
					alpha = 1.0,
				},
				border_color = {
					alpha = 1.0,
				},
			},
			icon = {
				color = colors.bg1,
			},
			label = {
				width = "dynamic",
			},
		})
	end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = {
					alpha = 0.0,
				},
				border_color = {
					alpha = 0.0,
				},
			},
			icon = {
				color = colors.grey,
			},
			label = {
				width = 0,
			},
		})
	end)
end)
