return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		require("toggleterm").setup({
			-- Dynamic size: 20 rows or 40% of screen for horizontal, 40 cols or 50% of screen for vertical
			size = function(term)
				if term.direction == "horizontal" then
					return 15
				elseif term.direction == "vertical" then
					return math.floor(vim.o.columns * 0.4)
				end
			end,
			open_mapping = [[<C-\>]],
			hide_numbers = true,
			shade_filetypes = {},
			shade_terminals = true,
			shading_factor = 3,
			start_in_insert = true,
			insert_mappings = true,
			persist_size = true,
			direction = "float", -- You can also let user toggle between float/horizontal if you want
			close_on_exit = true,
			shell = vim.o.shell,
			float_opts = {
				border = "rounded", -- 'curved' is good, but 'rounded' is cleaner
				winblend = 0, -- subtle transparency
				highlights = {
					border = "FloatBorder",
					background = "NormalFloat",
				},
			},
		})
	end,
	keys = {
		{
			"<C-\\>",
			function()
				require("toggleterm").toggle()
			end,
			desc = "Toggle terminal",
		},
		-- Map double ESC to <C-\><C-n> to exit terminal mode
		-- Why double ESC? Guess you are ammeding git commit messages in terminal mode in Neovim
		{
			"<Esc><Esc>",
			function()
				require("toggleterm").toggle()
			end,
			desc = "Exit terminal mode",
			mode = "t",
		},
	},
}
