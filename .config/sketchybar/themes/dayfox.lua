-- Light Theme
-- Based on the Dayfox Neovim colorscheme
-- Designed to match the cool, light aesthetic with muted teal-blues and grays

return {
	-- ========================================
	-- REQUIRED: Basic Theme Properties
	-- ========================================
	name = "Dayfox",

	-- Theme behavior: true for minimal themes (icons only), false for full themes (with app icons)
	minimal_spaces = true,

	-- Neovim theme name (uncomment and set to automatically change Neovim theme when switching sketchybar themes)
	neovim_theme = "dayfox",

	-- Ghostty theme name (uncomment and set to automatically change Ghostty theme when switching sketchybar themes)
	ghostty_theme = "dayfox",

	-- Ghostty background opacity (uncomment and set to automatically change Ghostty opacity when switching sketchybar themes)
	ghostty_opacity = 1.00, -- Light theme works well with lower opacity

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
		-- Dayfox-inspired color palette: light, cool, muted
		black = color("#2E3440"), -- Dark blue-gray for text (Nord Polar Night 0)
		white = color("#2E3440"), -- Dark blue-gray for apple logo and other white elements
		red = color("#BF616A"), -- Aurora Red for errors
		green = color("#A3BE8C"), -- Aurora Green for success
		blue = color("#81A1C1"), -- Frost 2 for primary accents
		yellow = color("#EBCB8B"), -- Aurora Yellow for warnings
		orange = color("#D08770"), -- Aurora Orange for alerts
		magenta = color("#B48EAD"), -- Aurora Purple for magenta
		grey = color("#4C566A"), -- Polar Night 3 for muted text
		transparent = 0x00000000, -- Keep as 0x for transparent

		-- Border colors
		border = 0x00000000, -- Keep as 0x for transparent
		border2 = 0x00000000, -- Keep as 0x for transparent

		-- Bar configuration
		bar = {
			bg = transparent("#E0E8EE", 0), -- Transparent (0% opacity)
			border = color("#81A1C1"), -- Frost 2
		},

		-- Popup configuration
		popup = {
			bg = color("#F0F4F8"), -- Very light blue-gray background
			border = transparent("#81A1C1", 23), -- 23% opacity
		},

		-- Background colors
		bg1 = color("#E0E8EE"), -- Very light blue-gray (Dayfox background)
		bg2 = color("#F0F4F8"), -- Even lighter blue-gray for secondary elements

		-- ========================================
		-- OPTIONAL: Widget Colors
		-- ========================================
		-- Remove or comment out any widget colors you don't want to customize
		-- Widgets will fall back to standard colors if not defined

		-- CPU Widget
		cpu_widget_bg = transparent("#E0E8EE", 0), -- Transparent
		cpu_widget_text = color("#2E3440"), -- Dark blue-gray text
		cpu_widget_icon = color("#4C566A"), -- Muted blue-gray icon
		cpu_widget_graph = color("#81A1C1"), -- Frost 2 for graph

		-- WiFi Widget
		wifi_widget_bg = transparent("#E0E8EE", 0), -- Transparent
		wifi_widget_text = color("#2E3440"), -- Dark blue-gray text
		wifi_widget_icon = color("#4C566A"), -- Muted blue-gray icon
		wifi_widget_upload = color("#A3BE8C"), -- Aurora Green for upload
		wifi_widget_download = color("#81A1C1"), -- Frost 2 for download

		-- Battery Widget
		battery_widget_bg = transparent("#E0E8EE", 0), -- Transparent
		battery_widget_text = color("#2E3440"), -- Dark blue-gray text
		battery_widget_icon = color("#4C566A"), -- Muted blue-gray icon

		-- Volume Widget
		volume_widget_bg = transparent("#E0E8EE", 0), -- Transparent
		volume_widget_text = color("#2E3440"), -- Dark blue-gray text
		volume_widget_icon = color("#4C566A"), -- Muted blue-gray icon

		-- Media Widget
		media_widget_bg = transparent("#E0E8EE", 0), -- Transparent
		media_widget_artist = color("#EBCB8B"), -- Aurora Yellow (artist name)
		media_widget_title = color("#2E3440"), -- Dark blue-gray (song title)
		media_widget_controls = color("#2E3440"), -- Dark blue-gray (play/pause/next buttons)

		-- Calendar Widget
		calendar_widget_bg = color("#5E81AC"), -- Frost 3
		calendar_widget_text = color("#E0E8EE"), -- Light background color
		calendar_widget_icon = color("#E0E8EE"), -- Light background color
		calendar_widget_border = color("#F0F4F8"), -- Secondary background

		-- Brew Widget
		brew_widget_bg = transparent("#E0E8EE", 0), -- Transparent
		brew_widget_text = color("#2E3440"), -- Dark blue-gray text
		brew_widget_icon = color("#4C566A"), -- Muted blue-gray icon
		brew_widget_border = color("#F0F4F8", 0), -- Secondary background
		brew_widget_alert = color("#D08770"), -- Aurora Orange when packages need updating

		-- Mail Widget
		mail_widget_bg = transparent("#E0E8EE", 0), -- Transparent
		mail_widget_text = color("#2E3440"), -- Dark blue-gray text
		mail_widget_icon = color("#4C566A"), -- Muted blue-gray icon (no unread mail)
		mail_widget_border = color("#F0F4F8", 0), -- Secondary background
		mail_widget_warning = color("#EBCB8B"), -- Aurora Yellow for 1-9 unread emails
		mail_widget_alert = color("#BF616A"), -- Aurora Red for 10+ unread emails

		-- ========================================
		-- OPTIONAL: Space Colors
		-- ========================================
		-- Remove or comment out any space colors you don't want to customize

		-- Basic Spaces
		space_bg = transparent("#E0E8EE", 0), -- Transparent
		space_text = color("#4C566A"), -- Polar Night 3
		space_icon = color("#4C566A"), -- Polar Night 3

		-- Active Spaces
		space_active_bg = transparent("#E0E8EE", 0), -- Transparent
		space_active_text = color("#2E3440"), -- Dark blue-gray for better visibility
		space_active_icon = color("#2E3440"), -- Dark blue-gray for better visibility

		-- Space Brackets
		space_bracket_bg = transparent("#E0E8EE", 0), -- Transparent
		space_bracket_border = transparent("#E0E8EE", 0), -- Transparent

		-- ========================================
		-- OPTIONAL: App Icon Colors (for full themes)
		-- ========================================
		-- Remove or comment out if using minimal_spaces = true

		app_icon_bg = transparent("#E0E8EE", 0), -- Transparent
		app_icon_text = color("#4C566A"), -- Polar Night 3
		app_icon_active_bg = transparent("#E0E8EE", 0), -- Transparent
		app_icon_active_text = color("#81A1C1"), -- Frost 2

		-- ========================================
		-- OPTIONAL: Front App Colors
		-- ========================================

		front_app_bg = transparent("#E0E8EE", 0), -- Transparent
		front_app_text = color("#4C566A"), -- Polar Night 3

		-- ========================================
		-- OPTIONAL: Menu Colors
		-- ========================================

		menu_bg = transparent("#E0E8EE", 0), -- Transparent
		menu_text = color("#4C566A"), -- Polar Night 3
		menu_active_bg = transparent("#E0E8EE", 0), -- Transparent
		menu_active_text = color("#81A1C1"), -- Frost 2

		-- ========================================
		-- OPTIONAL: Toggle Colors
		-- ========================================

		toggle_bg = transparent("#E0E8EE", 0), -- Transparent
		toggle_text = color("#4C566A"), -- Polar Night 3
		toggle_active_bg = transparent("#E0E8EE", 0), -- Transparent
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
