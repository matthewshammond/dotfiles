-- Nord Theme
-- Based on the Nord color palette by Arctic Ice Studio
-- https://www.nordtheme.com/

return {
	-- ========================================
	-- REQUIRED: Basic Theme Properties
	-- ========================================
	name = "Nord",

	-- Theme behavior: true for minimal themes (icons only), false for full themes (with app icons)
	minimal_spaces = true,

	-- Neovim theme name (uncomment and set to automatically change Neovim theme when switching sketchybar themes)
	neovim_theme = "nord",

	-- Ghostty theme name (uncomment and set to automatically change Ghostty theme when switching sketchybar themes)
	ghostty_theme = "nord",

	-- Ghostty background opacity (uncomment and set to automatically change Ghostty opacity when switching sketchybar themes)
	ghostty_opacity = 0.75, -- Dark theme works well with higher opacity

	-- ========================================
	-- OPTIONAL: Übersicht Clock Widget Configuration
	-- ========================================
	-- Uncomment and configure to automatically update Übersicht flip-clock widget
	-- when switching themes
	ubersicht_clock = {
		position = {
			top = "80%", -- Clock position from top (e.g., "80%", "100px")
			left = "50%", -- Clock position from left (e.g., "50%", "200px")
		},
		background = "#434E63", -- Background color for clock digits (Nord Polar Night 3)
		font = "#ECEFF4", -- Font color for digits and separator (Nord Snow Storm 3)
	},

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
		-- "brew",     -- Homebrew package updates
		-- "mail",     -- Mail unread count

		-- Example: Enable all widgets in default order
		"brew", -- Homebrew package updates
		"mail", -- Mail unread count
		"cpu", -- CPU usage with graph
		"wifi", -- Network upload/download speeds
		"volume", -- Volume control with percentage
		"battery", -- Battery status with percentage
		"media", -- Media player (Spotify, Music) with controls
		"calendar", -- Date and time display
	},

	-- ========================================
	-- REQUIRED: Basic Colors
	-- ========================================
	colors = {
		-- Core colors (required for all themes)
		-- Nord color palette: Polar Night, Snow Storm, Frost, Aurora
		black = color("#2E3440"), -- Polar Night 0
		white = color("#ECEFF4"), -- Snow Storm 3
		red = color("#BF616A"), -- Aurora Red
		green = color("#A3BE8C"), -- Aurora Green
		blue = color("#81A1C1"), -- Frost 2
		yellow = color("#EBCB8B"), -- Aurora Yellow
		orange = color("#D08770"), -- Aurora Orange
		magenta = color("#B48EAD"), -- Aurora Purple
		grey = color("#4C566A"), -- Polar Night 3
		transparent = 0x00000000, -- Keep as 0x for transparent

		-- Border colors
		border = 0x00000000, -- Keep as 0x for transparent
		border2 = 0x00000000, -- Keep as 0x for transparent

		-- Bar configuration
		bar = {
			bg = transparent("#2E3440", 0), -- Transparent (0% opacity)
			border = color("#81A1C1"), -- Frost 2
		},

		-- Popup configuration
		popup = {
			bg = color("#3B4252"), -- Polar Night 1
			border = transparent("#81A1C1", 23), -- 23% opacity
		},

		-- Background colors
		bg1 = color("#2E3440"), -- Polar Night 0
		bg2 = color("#3B4252"), -- Polar Night 1

		-- ========================================
		-- OPTIONAL: Widget Colors
		-- ========================================
		-- Remove or comment out any widget colors you don't want to customize
		-- Widgets will fall back to standard colors if not defined

		-- CPU Widget
		cpu_widget_bg = transparent("#ECEFF4", 0), -- Transparent
		cpu_widget_text = color("#ECEFF4"), -- Snow Storm 3
		cpu_widget_icon = color("#ECEFF4"), -- Snow Storm 3
		cpu_widget_graph = color("#81A1C1"), -- Frost 2

		-- WiFi Widget
		wifi_widget_bg = transparent("#ECEFF4", 0), -- Transparent
		wifi_widget_text = color("#ECEFF4"), -- Snow Storm 3
		wifi_widget_icon = color("#ECEFF4"), -- Snow Storm 3
		wifi_widget_upload = color("#A3BE8C"), -- Aurora Green
		wifi_widget_download = color("#81A1C1"), -- Frost 2

		-- Battery Widget
		battery_widget_bg = transparent("#ECEFF4", 0), -- 12% opacity
		battery_widget_text = color("#ECEFF4"), -- Snow Storm 3
		battery_widget_icon = color("#ECEFF4"), -- Snow Storm 3

		-- Volume Widget
		volume_widget_bg = transparent("#ECEFF4", 0), -- 12% opacity
		volume_widget_text = color("#ECEFF4"), -- Snow Storm 3
		volume_widget_icon = color("#ECEFF4"), -- Snow Storm 3

		-- Media Widget
		media_widget_bg = transparent("#ECEFF4", 0), -- Transparent
		media_widget_artist = color("#EBCB8B"), -- Aurora Yellow (artist name)
		media_widget_title = color("#ECEFF4"), -- Snow Storm 3 (song title)
		media_widget_controls = color("#ECEFF4"), -- Snow Storm 3 (play/pause/next buttons)

		-- Calendar Widget
		calendar_widget_bg = color("#5E81AC"), -- Frost 3
		calendar_widget_text = color("#2E3440"), -- Polar Night 0
		calendar_widget_icon = color("#2E3440"), -- Polar Night 0
		calendar_widget_border = color("#3B4252"), -- Polar Night 1

		-- Brew Widget
		brew_widget_bg = transparent("#ECEFF4", 0), -- Transparent
		brew_widget_text = color("#ECEFF4"), -- Snow Storm 3
		brew_widget_icon = color("#ECEFF4"), -- Snow Storm 3
		brew_widget_border = color("#3B4252", 0), -- Polar Night 1
		brew_widget_alert = color("#D08770"), -- Aurora Orange when packages need updating

		-- Mail Widget
		mail_widget_bg = transparent("#ECEFF4", 0), -- Transparent
		mail_widget_text = color("#ECEFF4"), -- Snow Storm 3
		mail_widget_icon = color("#ECEFF4"), -- Snow Storm 3 (no unread mail)
		mail_widget_border = color("#3B4252", 0), -- Polar Night 1
		mail_widget_warning = color("#EBCB8B"), -- Aurora Yellow for 1-9 unread emails
		mail_widget_alert = color("#BF616A"), -- Aurora Red for 10+ unread emails

		-- ========================================
		-- OPTIONAL: Space Colors
		-- ========================================
		-- Remove or comment out any space colors you don't want to customize

		-- Basic Spaces
		space_bg = transparent("#ECEFF4", 0), -- Transparent
		space_text = color("#4C566A"), -- Polar Night 3
		space_icon = color("#4C566A"), -- Polar Night 3

		-- Active Spaces
		space_active_bg = transparent("#ECEFF4", 0), -- Transparent
		space_active_text = color("#81A1C1"), -- Frost 2
		space_active_icon = color("#ECEFF4"), -- Snow Storm 3

		-- Space Brackets
		space_bracket_bg = transparent("#ECEFF4", 0), -- Transparent
		space_bracket_border = transparent("#ECEFF4", 0), -- Transparent

		-- ========================================
		-- OPTIONAL: App Icon Colors (for full themes)
		-- ========================================
		-- Remove or comment out if using minimal_spaces = true

		app_icon_bg = transparent("#ECEFF4", 0), -- Transparent
		app_icon_text = color("#4C566A"), -- Polar Night 3
		app_icon_active_bg = transparent("#ECEFF4", 0), -- Transparent
		app_icon_active_text = color("#81A1C1"), -- Frost 2

		-- ========================================
		-- OPTIONAL: Front App Colors
		-- ========================================

		front_app_bg = transparent("#ECEFF4", 0), -- Transparent
		front_app_text = color("#4C566A"), -- Polar Night 3

		-- ========================================
		-- OPTIONAL: Menu Colors
		-- ========================================

		menu_bg = transparent("#ECEFF4", 0), -- Transparent
		menu_text = color("#4C566A"), -- Polar Night 3
		menu_active_bg = transparent("#ECEFF4", 0), -- Transparent
		menu_active_text = color("#81A1C1"), -- Frost 2

		-- ========================================
		-- OPTIONAL: Toggle Colors
		-- ========================================

		toggle_bg = transparent("#ECEFF4", 0), -- Transparent
		toggle_text = color("#4C566A"), -- Polar Night 3
		toggle_active_bg = transparent("#ECEFF4", 0), -- Transparent
		toggle_active_text = color("#81A1C1"), -- Frost 2
	},

	-- ========================================
	-- REQUIRED: Bar Configuration
	-- ========================================
	bar_config = {
		height = 30,
		corner_radius = 22,
		y_offset = 2,
	},
}
