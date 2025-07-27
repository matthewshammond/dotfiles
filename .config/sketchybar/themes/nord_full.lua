return {
	name = "Nord - Full",
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
		black = 0xff2e3440,
		white = 0xffeceff4,
		red = 0xffbf616a,
		green = 0xffa3be8c,
		blue = 0xff81a1c1,
		yellow = 0xffebcb8b,
		orange = 0xffd08770,
		magenta = 0xffb48ead,
		grey = 0xff4c566a,
		transparent = 0x00000000,

		-- Border colors
		border = 0x3b2e3440,
		border2 = 0x3beceff4,

		-- Bar configuration
		bar = {
			bg = 0xfa2e3440,
			border = 0xffeceff4,
		},

		-- Popup configuration
		popup = {
			bg = 0xff3b4252,
			border = 0x3beceff4,
		},

		-- Background colors
		bg1 = 0xff2e3440,
		bg2 = 0xff3b4252,
	},

	bar_config = {
		height = 30,
		corner_radius = 22,
		y_offset = 2,
	},
}

