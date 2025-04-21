return {
	"saghen/blink.cmp",
	event = "VimEnter",
	version = "1.*",
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			version = "2.*",
			dependencies = {
				"moyiz/blink-emoji.nvim",
			},
			opts = {},
			-- config = function()
			-- 	require("config.snippets")
			-- end,
		},
		"folke/lazydev.nvim",
	},
	opts = {
		snippets = { preset = "luasnip" },
		sources = {
			default = { "lsp", "path", "snippets", "buffer", "lazydev" },
			providers = {
				lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
			},
		},
		-- keymap = {
		-- 	preset = "default",
		-- },
		appearance = {
			nerd_font_variant = "mono",
		},
		completion = {
			documentation = { auto_show = false, auto_show_delay_ms = 500 },
		},
		-- fuzzy = { implementation = "lua" },
		fuzzy = { implementation = "prefer_rust_with_warning" },
		signature = { enabled = true },
	},
}

-- return {
-- 	'saghen/blink.cmp',
-- 	version = '1.*',
-- 	-- !Important! Make sure you're using the latest release of LuaSnip
-- 	-- `main` does not work at the moment
-- 	dependencies = { 'L3MON4D3/LuaSnip', version = 'v2.*' },
-- 	opts = {
-- 		snippets = { preset = 'default' },
-- 		-- ensure you have the `snippets` source (enabled by default)
-- 		sources = {
-- 			default = { 'lsp', 'path', 'snippets', 'buffer' },
-- 		},
-- 	}
-- }
