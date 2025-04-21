return {
	"tpope/vim-fugitive",
	-- Optional: Add a keymap to open the fugitive status window
	keymaps = {
		{ "n", "<leader>gs", ":G<CR>", { noremap = true, silent = true } },
		{ "n", "<leader>gc", ":G commit<CR>", { noremap = true, silent = true } },
		{ "n", "<leader>gp", ":G push<CR>", { noremap = true, silent = true } },
		{ "n", "<leader>gl", ":G pull<CR>", { noremap = true, silent = true } },
		{ "n", "<leader>gd", ":G diff<CR>", { noremap = true, silent = true } },
		{ "n", "<leader>gb", ":G blame<CR>", { noremap = true, silent = true } },
		{ "n", "<leader>gco", ":G checkout<CR>", { noremap = true, silent = true } },
	},
	-- Optional: Add a command to open the fugitive status window
	commands = {
		{ "Gstatus", ":G<CR>" },
		{ "Gcommit", ":G commit<CR>" },
		{ "Gpush", ":G push<CR>" },
		{ "Gpull", ":G pull<CR>" },
		{ "Gdiff", ":G diff<CR>" },
		{ "Gblame", ":G blame<CR>" },
		{ "Gcheckout", ":G checkout<CR>" },
		{ "Glog", ":G log<CR>" },
		{ "Gfetch", ":G fetch<CR>" },
		{ "Gmerge", ":G merge<CR>" },
		{ "Gstatus", ":G status<CR>" },
		{ "Greset", ":G reset<CR>" },
		{ "Gclean", ":G clean<CR>" },
		{ "Gstash", ":G stash<CR>" },
		{ "Guntrack", ":G untrack<CR>" },
	},
}
