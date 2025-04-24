return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		vim.keymap.set("n", "<leader>ff", function()
			fzf.files({
				fd_opts = "--color=never --type f --hidden --follow --exclude .git --exclude .env"
			})
		end, { desc = "[F]ind [F]iles (exclude .env)" })

		vim.keymap.set("n", "<leader>fih", function()
			fzf.files({
				hidden = true,
				no_ignore = true, -- Show all hidden/ignored files
			})
		end, { desc = "[F]ind [i]n [H]idden Files (all)" })

		vim.keymap.set("n", "<leader>fn", function()
			fzf.files({
				hidden = true,
				cwd = vim.fn.stdpath("config")
			})
		end, { desc = "[F]ind in [N]eovim Config files" })

		vim.keymap.set("n", "<leader>fg", function() fzf.live_grep() end, { desc = "[F]ind [G]rep" })
		vim.keymap.set("n", "<leader>fb", function() fzf.buffers() end, { desc = "[F]ind [B]uffers" })
		vim.keymap.set("n", "<leader>fh", function() fzf.help_tags() end, { desc = "[F]ind [H]elp" })
		vim.keymap.set("n", "<leader>fk", function() fzf.keymaps() end, { desc = "[F]ind [K]eymaps" })
		vim.keymap.set("n", "<leader>fr", function() fzf.registers() end, { desc = "[F]ind [R]egisters" })
		vim.keymap.set("n", "<leader>ft", function() fzf.colorschemes() end, { desc = "[F]ind [T]hemes" })

		-- LSP related
		vim.keymap.set("n", "<leader>dd", function() fzf.lsp_document_diagnostics() end,
			{ desc = "[D]ocument [D]iagnostics" })
		vim.keymap.set("n", "<leader>wd", function() fzf.lsp_workspace_diagnostics() end,
			{ desc = "[W]orkspace [D]iagnostics" })
		vim.keymap.set("n", "<leader>ds", function() fzf.lsp_document_symbols() end, { desc = "[D]ocument [S]ymbols" })
		vim.keymap.set("n", "<leader>ws", function() fzf.lsp_workspace_symbols() end, { desc = "[W]orkspace [S]ymbols" })
		vim.keymap.set("n", "<leader>/", function() fzf.grep_curbuf() end, { desc = "Find Fuzzily in Current Buffer" })
		vim.keymap.set("n", "gd", function() fzf.lsp_definitions() end, { desc = "Go to Definition" })
		vim.keymap.set("n", "gD", function() fzf.lsp_declarations() end, { desc = "Go to Declaration" })
		vim.keymap.set("n", "gi", function() fzf.lsp_implementations() end, { desc = "Go to Implementation" })
		vim.keymap.set("n", "gr", function() fzf.lsp_references() end, { desc = "Find References" })
		vim.keymap.set("n", "ga", function() fzf.lsp_code_actions() end, { desc = "Code Actions" })

		-- Git related
		vim.keymap.set("n", "fgc", function() fzf.git_commits() end, { desc = "[G]it [C]ommits" })
		vim.keymap.set("n", "fgC", function() fzf.git_bcommits() end, { desc = "[G]it [B]uffer Commits" })
		vim.keymap.set("n", "fgs", function() fzf.git_status() end, { desc = "[G]it [S]tatus" })
		vim.keymap.set("n", "fgS", function() fzf.git_stash() end, { desc = "[G]it [S]tash" })
		vim.keymap.set("n", "fgb", function() fzf.git_blame() end, { desc = "[G]it [B]lame" })
	end,
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
	},
}
