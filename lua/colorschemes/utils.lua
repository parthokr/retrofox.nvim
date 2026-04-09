-- Shared colorscheme utilities
-- Provides unified transparency toggle & plugin integration helpers

local M = {}

--- Toggle transparency for the current colorscheme
--- Works with any theme — just clears backgrounds
function M.toggle_transparency()
    vim.g.neovim_transparent = not vim.g.neovim_transparent

    if vim.g.neovim_transparent then
        local groups = {
            "Normal",
            "NormalNC",
            "NormalFloat",
            "SignColumn",
            "NeoTreeNormal",
            "NeoTreeNormalNC",
            "FloatBorder",
            "WinSeparator",
        }
        for _, group in ipairs(groups) do
            vim.cmd("hi " .. group .. " guibg=NONE ctermbg=NONE")
        end
        vim.notify("Transparency ON", vim.log.levels.INFO, { title = "Theme" })
    else
        -- Reload the colorscheme to restore backgrounds
        vim.cmd.colorscheme(vim.g.colors_name)
        vim.notify("Transparency OFF", vim.log.levels.INFO, { title = "Theme" })
    end
end

--- Common plugin integrations table (for themes that support them)
M.integrations = {
    treesitter = true,
    native_lsp = {
        enabled = true,
        underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
        },
    },
    gitsigns = true,
    flash = true,
    indent_blankline = { enabled = true },
    which_key = true,
    neotree = true,
    notify = true,
    noice = true,
    mini = { enabled = true },
    fidget = true,
    blink_cmp = true,
}

return M
