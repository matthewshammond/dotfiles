return {
	"folke/snacks.nvim",
	opts = {
		explorer = {},
		picker = {
			sources = {
				explorer = {
					auto_close = true,
					win = {
						list = {
							keys = {
								["s"] = "edit_vsplit",
								["S"] = "edit_split",
							},
						},
					},
				},
			},
		},
	},
}
