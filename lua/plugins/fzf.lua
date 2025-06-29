return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")

		local function get_winopts_with_title(title)
			local winopts = require("fzf-lua.config").defaults.winopts
			winopts = vim.tbl_deep_extend("force", {}, winopts, { title = title })
			return winopts
		end

		local function get_fzf_opts()
			return {
				["--layout"] = "reverse",
				["--info"] = "inline-right",
				["--cycle"] = true,
				["--highlight-line"] = true,
			}
		end

		-- Utility: Create keymaps for various commands with title
		local function map_cmd(lhs, desc, title, fn)
			vim.keymap.set("n", lhs, function() fn(get_winopts_with_title(title)) end, { desc = desc })
		end

		-- File finders
		map_cmd("<leader>ff", "[F]ind [F]iles", "Find Files", function(winopts)
			fzf.files({
				fd_opts = "--color=never --type f --hidden --follow --exclude .git --exclude .env",
				winopts = winopts,
				fzf_opts = get_fzf_opts(),
			})
		end)

		map_cmd("<leader>rf", "[R]esume [F]ind", "Resume Find Files", function(winopts)
			fzf.files({
				fd_opts = "--color=never --type f --hidden --follow --exclude .git --exclude .env",
				resume = true,
				winopts = winopts,
				fzf_opts = get_fzf_opts(),
			})
		end)

		map_cmd("<leader>fih", "[F]ind [i]n [H]idden Files", "Find Files (all)", function(winopts)
			fzf.files({
				hidden = true,
				no_ignore = true,
				-- resume = true,
				winopts = winopts,
				fzf_opts = get_fzf_opts(),
			})
		end)

		map_cmd("<leader>fn", "[F]ind in [N]eovim Config", "Find Neovim Config Files", function(winopts)
			fzf.files({
				hidden = true,
				cwd = vim.fn.stdpath("config"),
				fd_opts = "--color=never --type f --hidden --follow --exclude .git",
				winopts = winopts,
				fzf_opts = get_fzf_opts(),
			})
		end)

		-- Grep & Buffers
		map_cmd("<leader>fg", "[F]ind [G]rep", "Live Grep", function(winopts)
			fzf.live_grep({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("<leader>/", "Find Fuzzily in Current Buffer", "Grep Current Buffer", function(winopts)
			fzf.grep_curbuf({ resume = true, winopts = winopts })
		end)

		map_cmd("<leader>fb", "[F]ind [B]uffers", "Buffers", function(winopts)
			fzf.buffers({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("<leader>fh", "[F]ind [H]elp", "Help Tags", function(winopts)
			fzf.help_tags({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("<leader>fk", "[F]ind [K]eymaps", "Keymaps", function(winopts)
			fzf.keymaps({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("<leader>fr", "[F]ind [R]egisters", "Registers", function(winopts)
			fzf.registers({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("<leader>ft", "[F]ind [T]hemes", "Color Schemes", function(winopts)
			fzf.colorschemes({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		-- LSP
		map_cmd("<leader>dd", "[D]ocument [D]iagnostics", "Document Diagnostics", function(winopts)
			fzf.lsp_document_diagnostics({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("<leader>wd", "[W]orkspace [D]iagnostics", "Workspace Diagnostics", function(winopts)
			fzf.lsp_workspace_diagnostics({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("<leader>ds", "[D]ocument [S]ymbols", "Document Symbols", function(winopts)
			fzf.lsp_document_symbols({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("<leader>ws", "[W]orkspace [S]ymbols", "Workspace Symbols", function(winopts)
			fzf.lsp_workspace_symbols({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("gd", "Go to Definition", "LSP Definitions", function(winopts)
			fzf.lsp_definitions({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("gD", "Go to Declaration", "LSP Declarations", function(winopts)
			fzf.lsp_declarations({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("gi", "Go to Implementation", "LSP Implementations", function(winopts)
			fzf.lsp_implementations({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("gr", "Find References", "LSP References", function(winopts)
			fzf.lsp_references({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("ga", "Code Actions", "LSP Code Actions", function(winopts)
			fzf.lsp_code_actions({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		-- Git
		map_cmd("fgc", "[G]it [C]ommits", "Git Commits", function(winopts)
			fzf.git_commits({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("fgC", "[G]it Buffer [C]ommits", "Git Buffer Commits", function(winopts)
			fzf.git_bcommits({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("fgs", "[G]it [S]tatus", "Git Status", function(winopts)
			fzf.git_status({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("fgS", "[G]it [S]tash", "Git Stash", function(winopts)
			fzf.git_stash({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)

		map_cmd("fgb", "[G]it [B]lame", "Git Blame", function(winopts)
			fzf.git_blame({ resume = true, winopts = winopts, fzf_opts = get_fzf_opts(), })
		end)
	end,

	opts = {
		winopts = {
			height = 0.85,
			width = 0.85,
			row = 0.5,
			col = 0.5,
			backdrop = 60,
			treesitter = true,
		},
		fzf_opts = {
			["--layout"] = "reverse",
			["--info"] = "inline-right",
			["--cycle"] = true,
			["--highlight-line"] = true,
		},
		file_icon_padding = " ",
	},
}
