vim.g.have_nerd_font = true

vim.opt.number = true

-- Read from config.yaml (only the settings users actually change)
local ok_rf, rf = pcall(require, "retrofox")
local function cfg(path, default)
    if not ok_rf then
        return default
    end
    local val = rf.get(path)
    if val == nil then
        return default
    end
    return val
end

vim.opt.relativenumber = cfg("editor.relative_numbers", true)
vim.opt.mouse = "a"
vim.opt.showmode = false

vim.schedule(function()
    vim.opt.clipboard = "unnamedplus"

    -- Use OSC 52 over SSH so yanks reach the local (Mac) clipboard
    if os.getenv("SSH_TTY") then
        vim.g.clipboard = {
            name = "OSC 52",
            copy = {
                ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
                ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
            },
            paste = {
                ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
                ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
            },
        }
    end
end)

vim.opt.breakindent = true
vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "▸ ", trail = "·", nbsp = "␣" }

vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.confirm = true
vim.opt.fixendofline = true
vim.opt.wrap = false

vim.opt.termguicolors = true

-- Hover / floating-doc UX
vim.opt.pumblend = 10 -- slight transparency on popup-menu
vim.opt.winblend = 10 -- slight transparency on floating windows
vim.opt.pumheight = 15 -- cap popup menu height

vim.api.nvim_create_autocmd("FileType", {
    desc = "Enable conceal for document filetypes",
    group = vim.api.nvim_create_augroup("retrofox-conceal", { clear = true }),
    pattern = { "markdown", "help", "org", "norg" },
    callback = function()
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = "nc"
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("retrofox-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end,
})

vim.opt.foldmethod = "indent"
vim.opt.foldenable = false

local tab_width = cfg("editor.tab_width", 4)
vim.opt.expandtab = true
vim.opt.tabstop = tab_width
vim.opt.shiftwidth = tab_width
vim.opt.softtabstop = tab_width
vim.opt.smarttab = true


vim.opt.fillchars = { diff = "╱", eob = " " }
