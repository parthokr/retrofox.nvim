return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		-- Basic FZF keymaps
		{ "<leader>ff",  "<cmd>FzfLua files<cr>",             desc = "[F]ind [F]iles" },
		{ "<leader>fih", "<cmd>FzfLua files hidden=true<cr>", desc = "[F]ind [i]n [H]idden Files" },
		{
			"<leader>fn",
			"<cmd>FzfLua files hidden=true cwd=" .. vim.fn.stdpath("config") .. "<cr>",
			desc = "[F]ind in [N]eovim Config files"
		},
		{ "<leader>fg", "<cmd>FzfLua live_grep<cr>",                 desc = "[F]ind [G]rep" },
		{ "<leader>fb", "<cmd>FzfLua buffers<cr>",                   desc = "[F]ind [B]uffers" },
		{ "<leader>fh", "<cmd>FzfLua help_tags<cr>",                 desc = "[F]ind [H]elp" },
		{ "<leader>fk", "<cmd>FzfLua keymaps<cr>",                   desc = "[F]ind [K]eymaps" },
		{ "<leader>fr", "<cmd>FzfLua registers<cr>",                 desc = "[F]ind [R]egisters" },
		{ "<leader>ft", "<cmd>FzfLua colorschemes<cr>",              desc = "[F]ind [T]hemes" },
		-- LSP related
		{ "<leader>dd", "<cmd>FzfLua lsp_document_diagnostics<cr>",  desc = "[D]ocument [D]iagnostics" },
		{ "<leader>wd", "<cmd>FzfLua lsp_workspace_diagnostics<cr>", desc = "[W]orkspace [D]iagnostics" },
		{ "<leader>ds", "<cmd>FzfLua lsp_document_symbols<cr>",      desc = "[D]ocument [S]ymbols" },
		{ "<leader>ws", "<cmd>FzfLua lsp_workspace_symbols<cr>",     desc = "[W]orkspace [S]ymbols" },
		{ "<leader>/",  "<cmd>FzfLua grep_curbuf<cr>",               desc = "Find Fuzzily in Current Buffer" },
		{ "gd",         "<cmd>FzfLua lsp_definitions<cr>",           desc = "Go to Definition" },
		{ "gD",         "<cmd>FzfLua lsp_declarations<cr>",          desc = "Go to Declaration" },
		{ "gi",         "<cmd>FzfLua lsp_implementations<cr>",       desc = "Go to Implementation" },
		{ "gr",         "<cmd>FzfLua lsp_references<cr>",            desc = "Find References" },
		{ "ga",         "<cmd>FzfLua lsp_code_actions<cr>",          desc = "Code Actions" },
		-- Git related
		{ "fgc",        "<cmd>FzfLua git_commits<cr>",               desc = "[G]it [C]ommits" },
		{ "fgC",        "<cmd>FzfLua git_bcommits<cr>",              desc = "[G]it [B]uffer Commits" },
		{ "fgs",        "<cmd>FzfLua git_status<cr>",                desc = "[G]it [S]tatus" },
		{ "fgS",        "<cmd>FzfLua git_stash<cr>",                 desc = "[G]it [S]tash" },
		{ "fgb",        "<cmd>FzfLua git_blame<cr>",                 desc = "[G]it [B]lame" },
	},
	opts = {
		winopts = {
			height = 0.85,
			width = 0.85,
			row = 0.5,
			col = 0.5,
			backdrop = 60
		},
		fzf_opts = {
			["--layout"]         = "reverse",
			["--info"]           = "inline-right",
			["--cycle"]          = true,
			["--highlight-line"] = true,
		},
		file_icon_padding = " ",
		-- files = {
		-- 	prompt = 'Files❯ ',
		-- cmd = "fd --type f --strip-cwd-prefix --color=never",
		-- }
	},
}
