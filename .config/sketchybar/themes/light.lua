return {
	name = "Light",
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
		white = 0xff000000, -- Black for better contrast on white background
		red = 0xffe03131,
		green = 0xff2b8a3e,
		blue = 0xff1971c2,
		yellow = 0xffe67700,
		orange = 0xffd9480f,
		magenta = 0xffae3ec9,
		grey = 0xff6c757d, -- Darker grey for better contrast
		transparent = 0x00000000,

		-- Border colors
		border = 0x3b000000,
		border2 = 0x3bffffff,

		-- Bar configuration
		bar = {
			bg = 0xfaffffff,
			border = 0xff000000,
		},

		-- Popup configuration
		popup = {
			bg = 0xfff8f9fa,
			border = 0x3b000000,
		},

		-- Background colors
		bg1 = 0xffffffff,
		bg2 = 0xfff8f9fa,
	},

	bar_config = {
		height = 30,
		corner_radius = 20,
		y_offset = 2,
	},
}

