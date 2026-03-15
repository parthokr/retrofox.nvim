vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false

vim.schedule(function()
    vim.opt.clipboard = "unnamedplus"

    if os.getenv("SSH_TTY") then
        -- Over SSH, writing to the local clipboard is reliable via OSC 52.
        -- Reading the local clipboard back is often blocked by the terminal,
        -- so keep a local cache instead of issuing OSC 52 paste requests.
        local osc52 = require("vim.ui.clipboard.osc52")
        local clipboard_cache = {
            ["+"] = { {}, "v" },
            ["*"] = { {}, "v" },
        }

        local function copy(reg)
            local osc52_copy = osc52.copy(reg)
            return function(lines, regtype)
                clipboard_cache[reg] = { vim.deepcopy(lines), regtype }
                osc52_copy(lines, regtype)
            end
        end

        local function paste(reg)
            return function()
                return clipboard_cache[reg]
            end
        end

        vim.g.clipboard = {
            name = "OSC 52 copy-only",
            copy = {
                ["+"] = copy("+"),
                ["*"] = copy("*"),
            },
            paste = {
                ["+"] = paste("+"),
                ["*"] = paste("*"),
            },
        }
    end
end)

vim.opt.breakindent = true
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital letters in search term
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
vim.opt.syntax = "enable"

vim.opt.foldmethod = "indent"
vim.opt.foldenable = false

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.smarttab = true

-- Do not affect register when deleting a character
vim.keymap.set("n", "x", '"_x')

vim.opt.autoread = true
vim.opt.laststatus = 3

-- Prevent braces from jumping to column 0 when typed
vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        vim.opt_local.indentkeys:remove("0{")
        vim.opt_local.indentkeys:remove("0}")
    end,
})
