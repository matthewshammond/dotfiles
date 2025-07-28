return {
	{
		"shaunsingh/nord.nvim",
		config = function()
			vim.g.nord_disable_background = true
		end,
	},
	{ "EdenEast/nightfox.nvim" },
	{
		"sainnhe/everforest",
		config = function()
			vim.g.everforest_background = "soft"
			vim.g.everforest_enable_italic = 1
			vim.g.everforest_disable_italic_comment = 0
			vim.g.everforest_better_performance = 1
		end,
	},
}
