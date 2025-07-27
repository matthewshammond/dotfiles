-- Sample Theme Template
-- Copy this file and rename it to your theme name (e.g., my_theme.lua)
-- Then edit the colors and remove/comment out any widget variables you don't want to customize

-- ========================================
-- COLOR FORMAT OPTIONS:
-- ========================================
-- Option 1: Use standard hex colors (recommended for readability)
--   color("#2E3440")           -- Fully opaque
--   color("#2E3440", 200)      -- With custom alpha (0-255)
--   transparent("#2E3440", 90) -- With percentage transparency (0-100)
--
-- Option 2: Use traditional 0x format
--   0xff2e3440                 -- Fully opaque
--   0xfa2e3440                 -- With alpha (fa = 250/255 ≈ 98% opacity)
--
-- ========================================

return {
	-- ========================================
	-- REQUIRED: Basic Theme Properties
	-- ========================================
	name = "Sample Theme",

	-- Theme behavior: true for minimal themes (icons only), false for full themes (with app icons)
	minimal_spaces = true,

	-- Neovim theme name (uncomment and set to automatically change Neovim theme when switching sketchybar themes)
	-- neovim_theme = "nord",

	-- Ghostty theme name (uncomment and set to automatically change Ghostty theme when switching sketchybar themes)
	-- ghostty_theme = "nord",

	-- Ghostty background opacity (uncomment and set to automatically change Ghostty opacity when switching sketchybar themes)
	-- ghostty_opacity = 0.75, -- Example: 0.75 for 75% opacity, 1.0 for fully opaque

	-- ========================================
	-- WIDGET CONFIGURATION
	-- ========================================
	-- Uncomment widgets you want to show, comment out widgets you want to hide
	-- Reorder the widgets in the order you want them to appear (left to right)
	widgets = {
		-- Current widgets:
		-- "cpu",      -- CPU usage with graph
		-- "wifi",     -- Network upload/download speeds
		-- "volume",   -- Volume control with percentage
		-- "battery",  -- Battery status with percentage
		-- "media",    -- Media player (Spotify, Music) with controls
		-- "calendar", -- Date and time display

		-- Future widgets (uncomment when created):
		-- "memory",   -- Memory usage widget
		-- "disk",     -- Disk space widget
		-- "weather",  -- Weather information widget
		-- "clock",    -- Clock/time widget

		-- Example: Enable all widgets in default order
		"cpu", -- CPU widget (leftmost)
		"wifi", -- WiFi widget
		"volume", -- Volume widget
		"battery", -- Battery widget
		"media", -- Media widget
		"calendar", -- Calendar widget (rightmost)

		-- Example: Custom order - uncomment and reorder as needed
		-- "calendar", -- Calendar widget (leftmost)
		-- "media",    -- Media widget
		-- "battery",  -- Battery widget
		-- "cpu",      -- CPU widget
		-- "wifi",     -- WiFi widget
		-- "volume",   -- Volume widget (rightmost)
	},

	-- ========================================
	-- REQUIRED: Basic Colors
	-- ========================================
	colors = {
		-- Core colors (required for all themes)
		-- You can use either format - both work!
		black = color("#1a1a1a"), -- Standard hex (recommended)
		white = color("#ffffff"), -- Standard hex (recommended)
		red = color("#d65d0e"), -- Standard hex (recommended)
		green = color("#689d6a"), -- Standard hex (recommended)
		blue = color("#458588"), -- Standard hex (recommended)
		yellow = color("#d79921"), -- Standard hex (recommended)
		orange = color("#d65d0e"), -- Standard hex (recommended)
		magenta = color("#b16286"), -- Standard hex (recommended)
		grey = color("#d5c4a1"), -- Standard hex (recommended)
		transparent = 0x00000000, -- Keep as 0x for transparent

		-- Border colors
		border = 0x00000000, -- Keep as 0x for transparent
		border2 = 0x00000000, -- Keep as 0x for transparent

		-- Bar configuration
		bar = {
			bg = transparent("#2e3440", 0), -- Transparent (0% opacity)
			border = color("#d65d0e"), -- Standard hex
		},

		-- Popup configuration
		popup = {
			bg = color("#2d2d2d"), -- Standard hex
			border = transparent("#d65d0e", 23), -- 23% opacity
		},

		-- Background colors
		bg1 = color("#2d2d2d"), -- Standard hex
		bg2 = color("#3c3836"), -- Standard hex

		-- ========================================
		-- OPTIONAL: Widget Colors
		-- ========================================
		-- Remove or comment out any widget colors you don't want to customize
		-- Widgets will fall back to standard colors if not defined

		-- CPU Widget
		cpu_widget_bg = transparent("#ffffff", 0), -- Transparent
		cpu_widget_text = color("#2d2d2d"), -- Standard hex
		cpu_widget_icon = color("#1a1a1a"), -- Standard hex
		cpu_widget_graph = color("#d65d0e"), -- Standard hex

		-- WiFi Widget
		wifi_widget_bg = transparent("#ffffff", 0), -- Transparent
		wifi_widget_text = color("#2d2d2d"), -- Standard hex
		wifi_widget_icon = color("#1a1a1a"), -- Standard hex
		wifi_widget_upload = color("#2d2d2d"), -- Standard hex
		wifi_widget_download = color("#2d2d2d"), -- Standard hex

		-- Battery Widget
		battery_widget_bg = transparent("#ffffff", 12), -- 12% opacity
		battery_widget_text = color("#2d2d2d"), -- Standard hex
		battery_widget_icon = color("#1a1a1a"), -- Standard hex

		-- Volume Widget
		volume_widget_bg = transparent("#ffffff", 12), -- 12% opacity
		volume_widget_text = color("#2d2d2d"), -- Standard hex
		volume_widget_icon = color("#1a1a1a"), -- Standard hex

		-- Media Widget
		media_widget_bg = transparent("#ffffff", 0), -- Transparent
		media_widget_artist = color("#d79921"), -- Standard hex (artist name)
		media_widget_title = color("#ffffff"), -- Standard hex (song title)
		media_widget_controls = color("#ffffff"), -- Standard hex (play/pause/next buttons)

		-- Calendar Widget
		calendar_widget_bg = color("#458588"), -- Standard hex
		calendar_widget_text = color("#1a1a1a"), -- Standard hex
		calendar_widget_icon = color("#1a1a1a"), -- Standard hex
		calendar_widget_border = color("#3c3836"), -- Standard hex

		-- Brew Widget
		brew_widget_bg = transparent("#ffffff", 12), -- 12% opacity
		brew_widget_text = color("#2d2d2d"), -- Standard hex
		brew_widget_icon = color("#1a1a1a"), -- Standard hex
		brew_widget_border = color("#3c3836"), -- Standard hex
		brew_widget_alert = color("#d65d0e"), -- Orange when packages need updating

		-- Mail Widget
		mail_widget_bg = transparent("#ffffff", 12), -- 12% opacity
		mail_widget_text = color("#2d2d2d"), -- Standard hex
		mail_widget_icon = color("#1a1a1a"), -- Standard hex (no unread mail)
		mail_widget_border = color("#3c3836"), -- Standard hex
		mail_widget_warning = color("#d79921"), -- Yellow for 1-9 unread emails
		mail_widget_alert = color("#cc241d"), -- Red for 10+ unread emails

		-- ========================================
		-- OPTIONAL: Space Colors
		-- ========================================
		-- Remove or comment out any space colors you don't want to customize

		-- Basic Spaces
		space_bg = transparent("#ffffff", 0), -- Transparent
		space_text = color("#d5c4a1"), -- Standard hex
		space_icon = color("#d5c4a1"), -- Standard hex

		-- Active Spaces
		space_active_bg = transparent("#ffffff", 0), -- Transparent
		space_active_text = color("#d65d0e"), -- Standard hex
		space_active_icon = color("#d65d0e"), -- Standard hex

		-- Space Brackets
		space_bracket_bg = transparent("#ffffff", 0), -- Transparent
		space_bracket_border = transparent("#ffffff", 0), -- Transparent

		-- ========================================
		-- OPTIONAL: App Icon Colors (for full themes)
		-- ========================================
		-- Remove or comment out if using minimal_spaces = true

		app_icon_bg = transparent("#ffffff", 0), -- Transparent
		app_icon_text = color("#d5c4a1"), -- Standard hex
		app_icon_active_bg = transparent("#ffffff", 0), -- Transparent
		app_icon_active_text = color("#d65d0e"), -- Standard hex

		-- ========================================
		-- OPTIONAL: Front App Colors
		-- ========================================

		front_app_bg = transparent("#ffffff", 0), -- Transparent
		front_app_text = color("#d5c4a1"), -- Standard hex

		-- ========================================
		-- OPTIONAL: Menu Colors
		-- ========================================

		menu_bg = transparent("#ffffff", 0), -- Transparent
		menu_text = color("#d5c4a1"), -- Standard hex
		menu_active_bg = transparent("#ffffff", 0), -- Transparent
		menu_active_text = color("#d65d0e"), -- Standard hex

		-- ========================================
		-- OPTIONAL: Toggle Colors
		-- ========================================

		toggle_bg = transparent("#ffffff", 0), -- Transparent
		toggle_text = color("#d5c4a1"), -- Standard hex
		toggle_active_bg = transparent("#ffffff", 0), -- Transparent
		toggle_active_text = color("#d65d0e"), -- Standard hex
	},

	-- ========================================
	-- REQUIRED: Bar Configuration
	-- ========================================
	bar_config = {
		height = 30,
		corner_radius = 20,
		y_offset = 2,
	},
}

-- ========================================
-- USAGE INSTRUCTIONS:
-- ========================================
-- 1. Copy this file and rename it to your theme name (e.g., my_theme.lua)
-- 2. Edit the name, colors, and bar_config as needed
-- 3. Remove or comment out any widget/space colors you don't want to customize
-- 4. Set minimal_spaces = true for minimal themes, false for full themes
-- 5. The theme will automatically be detected and added to the theme list
--
-- WIDGET CONFIGURATION:
-- To enable/disable widgets or change their order, edit the WidgetConfig section in themes.lua:
--   - Set widget_name = false to disable a widget
--   - Reorder widgets in widget_order array to change their position
--   - Example: cpu = false to disable CPU widget
--   - Example: Move "battery" before "wifi" to change order
--
-- COLOR FORMAT EXAMPLES:
--   color("#2E3440")           -- Standard hex color (fully opaque)
--   color("#2E3440", 200)      -- With custom alpha (0-255)
--   transparent("#2E3440", 90) -- With percentage transparency (0-100)
--   0xff2e3440                 -- Traditional format (still works)
-- ========================================

