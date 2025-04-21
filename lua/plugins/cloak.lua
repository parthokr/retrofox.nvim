return {
	"laytan/cloak.nvim",
	event = "VeryLazy",
	config = function()
		require("cloak").setup({
			enabled = true,
			cloak_character = "*",
			cloak_highlight = "Comment",
			cloak_ignored_filetypes = {
				"help",
				"gitcommit",
				"gitrebase",
				"svn",
				"hgcommit",
				"markdown",
				"txt",
			},
			cloak_ignored_buftypes = { "nofile", "nowrite", "quickfix", "prompt" },
			cloak_ignored_patterns = { "^%s*%-%-%s*TODO%s*:" },
			-- cloak_ignored_patterns = { "^%s*%-%-%s*TODO%s*:", "^%s*%-%-%s*NOTE%s*:" },
			-- cloak_ignored_patterns = { "^%s*%-%-%s*TODO%s*:", "^%s*%-%-%s*NOTE%s*:", "^%s*%-%-%s*FIXME%s*:" },
			-- cloak_ignored_patterns = { "^%s*%-%-%s*TODO%s*:", "^%s*%-%-%s*NOTE%s*:", "^%s*%-%-%s*FIXME%s*:","^%s*%-%-%s*TIPS%s*:","^%s*%-%-%s*SUGGESTIONS%s*:","^%s*%-%-%s*SUGGESTIONS:%S*" },
			-- cloak_ignored_patterns = { "^%s*%-%-%s*TIPS%s*:","^%s*%-%-%s*SUGGESTIONS:%S*" },
			-- cloak_ignored_patterns = { "^%s*TIPS:%S*" },
			-- cloak_ignored_patterns = { "^TIPS:%S*" },
			-- cloak_ignored_patterns = { "^TIPS:%S*" },
			debug = false,
		})
	end,
}
