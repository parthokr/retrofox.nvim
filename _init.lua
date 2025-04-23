require("core.options")
require("core.keymaps")

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require("lazy").setup({
	"tpope/vim-sleuth",
	require("plugins.neo-tree"),
	require("plugins.oil"),
	require("plugins.gitsigns"),
	require("plugins.which-key"),
	require("lua._plugins.telescope"),
	require("plugins.lazydev"),
	require("plugins.nvim-lspconfig"),
	require("plugins.conform"),
	require("plugins.blink-cmp"),
	require("plugins.lualine"),
	require("plugins.tokyonight"),
	require("plugins.catppuccin"),
	require("plugins.kanagawa"),
	require("plugins.themes.nightfox"),
	require("plugins.todo-comments"),
	require("plugins.mini"),
	require("plugins.copilot"),
	require("plugins.debug"),
	require("plugins.autopairs"),
	require("plugins.indent-blankline"),
	require("plugins.nvim-lint"),
	require("plugins.neoscroll"),
	require("plugins.gruvbox"),
	require("plugins.comment"),
	require("plugins.bufferline"),
	require("plugins.cloak"),
	require("plugins.alpha-nvim"),
	require("plugins.vim-fugitive"),
	require("plugins.noice"),
	-- require("plugins.nvim-notify"),
	require("plugins.markdown"),
})
