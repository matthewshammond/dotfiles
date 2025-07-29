-- Catppuccin Theme
-- Based on the Catppuccin color palette
-- https://github.com/catppuccin/catppuccin

return {
	-- ========================================
	-- REQUIRED: Basic Theme Properties
	-- ========================================
	name = "Catppuccin",

	-- Theme behavior: true for minimal themes (icons only), false for full themes (with app icons)
	minimal_spaces = true,

	-- Neovim theme name (uncomment and set to automatically change Neovim theme when switching sketchybar themes)
	neovim_theme = "catppuccin-frappe",

	-- Ghostty theme name (uncomment and set to automatically change Ghostty theme when switching sketchybar themes)
	ghostty_theme = "catppuccin-frappe",

	-- Ghostty background opacity (uncomment and set to automatically change Ghostty opacity when switching sketchybar themes)
	ghostty_opacity = 0.85, -- Medium-high opacity for catppuccin theme

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
		background = "#313244", -- Background color for clock digits (Catppuccin Surface0)
		font = "#CDD6F4", -- Font color for digits and separator (Catppuccin Text)
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
		-- Catppuccin color palette: Base, Surface, Overlay, Mocha, Latte, Frappé, Macchiato
		black = color("#1E1E2E"), -- Catppuccin Base
		white = color("#CDD6F4"), -- Catppuccin Text
		red = color("#F38BA8"), -- Catppuccin Red
		green = color("#A6E3A1"), -- Catppuccin Green
		blue = color("#89B4FA"), -- Catppuccin Blue
		yellow = color("#F9E2AF"), -- Catppuccin Yellow
		orange = color("#FAB387"), -- Catppuccin Peach
		magenta = color("#CBA6F7"), -- Catppuccin Mauve
		grey = color("#6C7086"), -- Catppuccin Subtext0
		transparent = 0x00000000, -- Keep as 0x for transparent

		-- Border colors
		border = 0x00000000, -- Keep as 0x for transparent
		border2 = 0x00000000, -- Keep as 0x for transparent

		-- Bar configuration
		bar = {
			bg = transparent("#1E1E2E", 0), -- Transparent (0% opacity)
			border = color("#89B4FA"), -- Catppuccin Blue
		},

		-- Popup configuration
		popup = {
			bg = color("#313244"), -- Catppuccin Surface0
			border = transparent("#89B4FA", 23), -- 23% opacity
		},

		-- Background colors
		bg1 = color("#1E1E2E"), -- Catppuccin Base
		bg2 = color("#313244"), -- Catppuccin Surface0

		-- ========================================
		-- OPTIONAL: Widget Colors
		-- ========================================
		-- Remove or comment out any widget colors you don't want to customize
		-- Widgets will fall back to standard colors if not defined

		-- CPU Widget
		cpu_widget_bg = transparent("#CDD6F4", 0), -- Transparent
		cpu_widget_text = color("#CDD6F4"), -- Catppuccin Text
		cpu_widget_icon = color("#CDD6F4"), -- Catppuccin Text
		cpu_widget_graph = color("#89B4FA"), -- Catppuccin Blue

		-- WiFi Widget
		wifi_widget_bg = transparent("#CDD6F4", 0), -- Transparent
		wifi_widget_text = color("#CDD6F4"), -- Catppuccin Text
		wifi_widget_icon = color("#CDD6F4"), -- Catppuccin Text
		wifi_widget_upload = color("#A6E3A1"), -- Catppuccin Green
		wifi_widget_download = color("#89B4FA"), -- Catppuccin Blue

		-- Battery Widget
		battery_widget_bg = transparent("#CDD6F4", 0), -- Transparent
		battery_widget_text = color("#CDD6F4"), -- Catppuccin Text
		battery_widget_icon = color("#CDD6F4"), -- Catppuccin Text

		-- Volume Widget
		volume_widget_bg = transparent("#CDD6F4", 0), -- Transparent
		volume_widget_text = color("#CDD6F4"), -- Catppuccin Text
		volume_widget_icon = color("#CDD6F4"), -- Catppuccin Text

		-- Media Widget
		media_widget_bg = transparent("#CDD6F4", 0), -- Transparent
		media_widget_artist = color("#F9E2AF"), -- Catppuccin Yellow (artist name)
		media_widget_title = color("#CDD6F4"), -- Catppuccin Text (song title)
		media_widget_controls = color("#CDD6F4"), -- Catppuccin Text (play/pause/next buttons)

		-- Calendar Widget
		calendar_widget_bg = color("#89B4FA"), -- Catppuccin Blue
		calendar_widget_text = color("#1E1E2E"), -- Catppuccin Base
		calendar_widget_icon = color("#1E1E2E"), -- Catppuccin Base
		calendar_widget_border = color("#313244"), -- Catppuccin Surface0

		-- Brew Widget
		brew_widget_bg = transparent("#CDD6F4", 0), -- Transparent
		brew_widget_text = color("#CDD6F4"), -- Catppuccin Text
		brew_widget_icon = color("#CDD6F4"), -- Catppuccin Text
		brew_widget_border = color("#313244", 0), -- Catppuccin Surface0
		brew_widget_alert = color("#FAB387"), -- Catppuccin Peach when packages need updating

		-- Mail Widget
		mail_widget_bg = transparent("#CDD6F4", 0), -- Transparent
		mail_widget_text = color("#CDD6F4"), -- Catppuccin Text
		mail_widget_icon = color("#CDD6F4"), -- Catppuccin Text (no unread mail)
		mail_widget_border = color("#313244", 0), -- Catppuccin Surface0
		mail_widget_warning = color("#F9E2AF"), -- Catppuccin Yellow for 1-9 unread emails
		mail_widget_alert = color("#F38BA8"), -- Catppuccin Red for 10+ unread emails

		-- ========================================
		-- OPTIONAL: Space Colors
		-- ========================================
		-- Remove or comment out any space colors you don't want to customize

		-- Basic Spaces
		space_bg = transparent("#CDD6F4", 0), -- Transparent
		space_text = color("#6C7086"), -- Catppuccin Subtext0
		space_icon = color("#6C7086"), -- Catppuccin Subtext0

		-- Active Spaces
		space_active_bg = transparent("#CDD6F4", 0), -- Transparent
		space_active_text = color("#89B4FA"), -- Catppuccin Blue
		space_active_icon = color("#CDD6F4"), -- Catppuccin Text

		-- Space Brackets
		space_bracket_bg = transparent("#CDD6F4", 0), -- Transparent
		space_bracket_border = transparent("#CDD6F4", 0), -- Transparent

		-- ========================================
		-- OPTIONAL: App Icon Colors (for full themes)
		-- ========================================
		-- Remove or comment out if using minimal_spaces = true

		app_icon_bg = transparent("#CDD6F4", 0), -- Transparent
		app_icon_text = color("#6C7086"), -- Catppuccin Subtext0
		app_icon_active_bg = transparent("#CDD6F4", 0), -- Transparent
		app_icon_active_text = color("#89B4FA"), -- Catppuccin Blue

		-- ========================================
		-- OPTIONAL: Front App Colors
		-- ========================================

		front_app_bg = transparent("#CDD6F4", 0), -- Transparent
		front_app_text = color("#6C7086"), -- Catppuccin Subtext0

		-- ========================================
		-- OPTIONAL: Menu Colors
		-- ========================================

		menu_bg = transparent("#CDD6F4", 0), -- Transparent
		menu_text = color("#6C7086"), -- Catppuccin Subtext0
		menu_active_bg = transparent("#CDD6F4", 0), -- Transparent
		menu_active_text = color("#89B4FA"), -- Catppuccin Blue

		-- ========================================
		-- OPTIONAL: Toggle Colors
		-- ========================================

		toggle_bg = transparent("#CDD6F4", 0), -- Transparent
		toggle_text = color("#6C7086"), -- Catppuccin Subtext0
		toggle_active_bg = transparent("#CDD6F4", 0), -- Transparent
		toggle_active_text = color("#89B4FA"), -- Catppuccin Blue
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
