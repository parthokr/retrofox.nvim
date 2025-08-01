vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.opt.number = true

vim.opt.relativenumber = true

vim.opt.mouse = "a"

vim.opt.showmode = false

vim.schedule(function()
    vim.opt.clipboard = "unnamedplus"
end)

vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "▸ ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true
-- Show which column your cursor is on
-- vim.opt.cursorcolumn = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.opt.confirm = true

-- Enable syntax highlighting
vim.opt.syntax = "enable"

-- Enable folding
vim.opt.foldmethod = "indent"

-- Prevent from folding by default
vim.opt.foldenable = false

vim.opt.expandtab = true -- Insert spaces instead of tab chars
vim.opt.tabstop = 4      -- How many spaces a tab char visually equals
vim.opt.shiftwidth = 4   -- How many spaces per indent level
vim.opt.softtabstop = 4  -- How many spaces a tab key inserts
vim.opt.smarttab = true  -- Insert spaces when pressing tab at the beginning of a line

-- Do not affect register when deleting a character
vim.keymap.set("n", "x", '"_x', opts)

vim.opt.autoread = true
