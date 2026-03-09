return {
    "folke/tokyonight.nvim",
    priority = 1000,
    lazy = false,
    config = function()
        require("tokyonight").setup({
            style = "night",
            transparent = false,
            terminal_colors = true,
            styles = {
                comments = { italic = true },
                keywords = { italic = true, bold = true },
                functions = { bold = true },
                variables = {},
                sidebars = "dark",
                floats = "dark",
            },
            on_highlights = function(hl, c)
                -- Sharper floating windows
                hl.FloatBorder = { fg = c.blue, bg = c.bg_float }
                -- Better visual selection
                hl.Visual = { bg = c.bg_visual, bold = true }
                -- Punchier search highlights
                hl.IncSearch = { bg = c.orange, fg = c.black, bold = true }
                hl.Search = { bg = c.blue0, fg = c.fg, bold = true }
                -- Better diagnostics underline
                hl.DiagnosticUnderlineError = { undercurl = true, sp = c.error }
                hl.DiagnosticUnderlineWarn = { undercurl = true, sp = c.warning }
                hl.DiagnosticUnderlineInfo = { undercurl = true, sp = c.info }
                hl.DiagnosticUnderlineHint = { undercurl = true, sp = c.hint }
            end,
            on_colors = function(c)
                -- Slightly warmer background for night variant
                c.bg_float = c.bg_dark
            end,
        })
        vim.cmd.colorscheme("tokyonight-night")
    end,
}
