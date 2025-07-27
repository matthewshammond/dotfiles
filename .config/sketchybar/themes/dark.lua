return {
	name = "Dark",
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
		black = 0xff000000,
		white = 0xffffffff,
		red = 0xffff0000,
		green = 0xff00ff00,
		blue = 0xff0000ff,
		yellow = 0xffffff00,
		orange = 0xffff8000,
		magenta = 0xffff00ff,
		grey = 0xff808080,
		transparent = 0x00000000,

		-- Border colors
		border = 0x3bffffff,
		border2 = 0x3b000000,

		-- Bar configuration
		bar = {
			bg = 0xfa000000,
			border = 0xffffffff,
		},

		-- Popup configuration
		popup = {
			bg = 0xff1a1a1a,
			border = 0x3bffffff,
		},

		-- Background colors
		bg1 = 0xff000000,
		bg2 = 0xff1a1a1a,
	},

	bar_config = {
		height = 30,
		corner_radius = 22,
		y_offset = 2,
	},
}

