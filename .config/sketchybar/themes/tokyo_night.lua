return {
	name = "Tokyo Night",
	minimal_spaces = false,

	-- ========================================
	-- WIDGET CONFIGURATION
	-- ========================================
	-- Uncomment widgets you want to show, comment out widgets you want to hide
	-- Reorder the widgets in the order you want them to appear (left to right)
	widgets = {
		-- "media", -- Media player (Spotify, Music) with controls
		"cpu", -- CPU usage with graph
		"wifi", -- Network upload/download speeds
		"volume", -- Volume control with percentage
		"battery", -- Battery status with percentage
		"brew", -- Homebrew package updates
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
		black = 0xff1a1b26,
		white = 0xffc0caf5,
		red = 0xfff7768e,
		green = 0xff9ece6a,
		blue = 0xff7aa2f7,
		yellow = 0xffe0af68,
		orange = 0xffff9e64,
		magenta = 0xffbb9af7,
		grey = 0xff565a6e,
		transparent = 0x00000000,

		-- Border colors
		border = 0x3b1a1b26,
		border2 = 0x3bc0caf5,

		-- Bar configuration
		bar = {
			bg = 0xcc1a1b26,
			border = 0xffc0caf5,
		},

		-- Popup configuration
		popup = {
			bg = 0xff1a1b26,
			border = 0x3bc0caf5,
		},

		-- Background colors
		bg1 = 0xff1a1b26,
		bg2 = 0xff24283b,
	},

	bar_config = {
		height = 30,
		corner_radius = 20,
		y_offset = 2,
	},
}

