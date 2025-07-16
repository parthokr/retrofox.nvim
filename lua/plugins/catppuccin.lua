return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	lazy = false,
	opts = {
		integrations = {
			cmp = true,
			gitsigns = true,
			treesitter = true,
			native_lsp = {
				enabled = true,
				semantic_tokens = true,
			},
		},
	},
}
