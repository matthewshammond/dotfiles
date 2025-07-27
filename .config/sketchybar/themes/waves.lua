return {
	name = "Waves",
	minimal_spaces = true,

	-- Neovim theme name (uncomment and set to automatically change Neovim theme when switching sketchybar themes)
	neovim_theme = "nord",

	-- Ghostty theme name (uncomment and set to automatically change Ghostty theme when switching sketchybar themes)
	ghostty_theme = "nord",

	-- Ghostty background opacity (uncomment and set to automatically change Ghostty opacity when switching sketchybar themes)
	ghostty_opacity = 0.75, -- Medium opacity for waves theme

	-- ========================================
	-- WIDGET CONFIGURATION
	-- ========================================
	-- Uncomment widgets you want to show, comment out widgets you want to hide
	-- Reorder the widgets in the order you want them to appear (left to right)
	widgets = {
		-- "media", -- Media player (Spotify, Music) with controls
		"brew", -- Homebrew package updates
		"mail", -- Mail unread count
		"cpu", -- CPU usage with graph
		"wifi", -- Network upload/download speeds
		"volume", -- Volume control with percentage
		"battery", -- Battery status with percentage
		"calendar", -- Date and time display

		-- Example: Enable only CPU and Battery widgets
		-- "cpu",      -- CPU widget (leftmost)
		-- "battery",  -- Battery widget (rightmost)

		-- Example: Enable all widgets in custom order
		-- "battery",  -- Battery widget (leftmost)
		-- "cpu",      -- CPU widget
		-- "wifi",     -- WiFi widget
		-- "volume",   -- Volume widget (rightmost)
	},

	colors = {
		-- Core colors
		black = color("#1a1a1a"),
		white = color("#ffffff"),
		red = color("#d65d0e"),
		green = color("#689d6a"),
		blue = color("#458588"),
		yellow = color("#d79921"),
		orange = color("#d65d0e"),
		magenta = color("#b16286"),
		grey = color("#d5c4a1"),
		transparent = 0x00000000,

		-- Border colors
		border = transparent("#ffffff", 0),
		border2 = transparent("#ffffff", 0),

		-- Bar configuration
		bar = {
			bg = transparent("#ffffff", 0), -- Completely transparent background
			border = color("#d65d0e"), -- Orange border
		},

		-- Popup configuration
		popup = {
			bg = color("#2d2d2d"),
			border = transparent("#d65d0e", 23), -- 23% opacity (equivalent to 0x3b)
		},

		-- Background colors
		bg1 = color("#2d2d2d"),
		bg2 = color("#3c3836"),

		-- Widget colors for better visibility against light background
		cpu_widget_bg = transparent("#ffffff", 0), -- Transparent background
		cpu_widget_text = color("#1a1a1a"), -- Darker text for better contrast
		cpu_widget_icon = color("#013131"), -- Dark icon for better contrast
		cpu_widget_graph = color("#1a1a1a"), -- Dark graph for better visibility

		wifi_widget_bg = transparent("#ffffff", 0), -- Transparent background
		wifi_widget_text = color("#1a1a1a"), -- Darker text for better contrast
		wifi_widget_icon = color("#ffffff"), -- White icons for better contrast
		wifi_widget_upload = color("#2e3440"), -- Dark teal upload text (from wallpaper left side)
		wifi_widget_download = color("#3b4252"), -- Darker teal download text (from wallpaper left side)

		battery_widget_bg = transparent("#ffffff", 0), -- Transparent background
		battery_widget_text = color("#ffffff"), -- White text for better contrast
		battery_widget_icon = color("#1a1a1a"), -- Dark icon

		volume_widget_bg = transparent("#ffffff", 0), -- Transparent background
		volume_widget_text = color("#CB6E02"), -- White text for better contrast
		volume_widget_icon = color("#d5c4a1"), -- Dark icon

		-- Media Widget
		media_widget_bg = transparent("#ffffff", 0), -- Transparent background
		media_widget_artist = color("#ffffff"), -- White text for artist name
		media_widget_title = color("#ffffff"), -- White text for song title
		media_widget_controls = color("#ffffff"), -- White controls

		-- Calendar Widget
		calendar_widget_bg = color("#458588"), -- Blue background
		calendar_widget_text = color("#1a1a1a"), -- Dark text
		calendar_widget_icon = color("#1a1a1a"), -- Dark icon
		calendar_widget_border = color("#3c3836"), -- Dark border

		-- Brew Widget
		brew_widget_bg = transparent("#ffffff", 0), -- Transparent background
		brew_widget_text = color("#ffffff"), -- White text for better contrast
		brew_widget_icon = color("#1a1a1a"), -- Dark icon
		brew_widget_border = color("#3c3836", 0), -- Dark border
		brew_widget_alert = color("#d65d0e"), -- Orange when packages need updating

		-- Mail Widget
		mail_widget_bg = transparent("#ffffff", 0), -- Transparent background
		mail_widget_text = color("#ffffff"), -- White text for better contrast
		mail_widget_icon = color("#458588"), -- Blue icon (no unread mail) - matches calendar background
		mail_widget_border = color("#3c3836", 0), -- Dark border
		mail_widget_warning = color("#d79921"), -- Yellow warning for 1-9 unread emails
		mail_widget_alert = color("#d65d0e"), -- Orange alert for 10+ unread emails (matches theme accent)

		-- Space colors
		space_bg = transparent("#ffffff", 0), -- Transparent background
		space_text = color("#d5c4a1"), -- Light beige text
		space_icon = color("#d5c4a1"), -- Light beige icons
		space_active_bg = transparent("#ffffff", 0), -- Transparent background
		space_active_text = color("#d65d0e"), -- Orange active text
		space_active_icon = color("#d65d0e"), -- Orange active icon
		space_bracket_bg = transparent("#ffffff", 0), -- Transparent bracket background
		space_bracket_border = transparent("#ffffff", 0), -- Transparent bracket border

		-- App icon colors (for full themes)
		app_icon_bg = transparent("#ffffff", 0), -- Transparent background
		app_icon_text = color("#d5c4a1"), -- Light beige text
		app_icon_active_bg = transparent("#ffffff", 0), -- Transparent background
		app_icon_active_text = color("#d65d0e"), -- Orange active text

		-- Front app colors
		front_app_bg = transparent("#ffffff", 0), -- Transparent background
		front_app_text = color("#d5c4a1"), -- Light beige text

		-- Menu colors
		menu_bg = transparent("#ffffff", 0), -- Transparent background
		menu_text = color("#d5c4a1"), -- Light beige text
		menu_active_bg = transparent("#ffffff", 0), -- Transparent background
		menu_active_text = color("#d65d0e"), -- Orange active text

		-- Toggle colors
		toggle_bg = transparent("#ffffff", 0), -- Transparent background
		toggle_text = color("#d5c4a1"), -- Light beige text
		toggle_active_bg = transparent("#ffffff", 0), -- Transparent background
		toggle_active_text = color("#d65d0e"), -- Orange active text
	},

	bar_config = {
		height = 30,
		corner_radius = 20,
		y_offset = 2,
	},
}
