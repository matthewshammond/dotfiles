return {
	name = "Dracula",
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
		black = 0xff282a36,
		white = 0xfff8f8f2,
		red = 0xffff5555,
		green = 0xff50fa7b,
		blue = 0xff8be9fd,
		yellow = 0xffffb86c,
		orange = 0xffffb86c,
		magenta = 0xffff79c6,
		grey = 0xff6272a4,
		transparent = 0x00000000,

		-- Border colors
		border = 0x3b282a36,
		border2 = 0x3bf8f8f2,

		-- Bar configuration
		bar = {
			bg = 0xfa282a36,
			border = 0xfff8f8f2,
		},

		-- Popup configuration
		popup = {
			bg = 0xff44475a,
			border = 0x3bf8f8f2,
		},

		-- Background colors
		bg1 = 0xff282a36,
		bg2 = 0xff44475a,
	},

	bar_config = {
		height = 30,
		corner_radius = 22,
		y_offset = 2,
	},
}

