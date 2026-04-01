return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            transparent_background = false,
            term_colors = true,
            styles = {
                comments = { "italic" },
                conditionals = { "italic" },
                keywords = { "bold", "italic" },
                functions = { "bold" },
                variables = {},
            },
            integrations = {
                blink_cmp = true,
                flash = true,
                gitsigns = true,
                indent_blankline = { enabled = true, colored_indent_levels = true },
                mason = true,
                mini = { enabled = true },
                native_lsp = {
                    enabled = true,
                    underlines = {
                        errors = { "undercurl" },
                        hints = { "undercurl" },
                        warnings = { "undercurl" },
                        information = { "undercurl" },
                    },
                },
                neotree = true,
                noice = true,
                notify = true,
                treesitter = true,
                which_key = true,
            },
            custom_highlights = function(c)
                return {
                    FloatBorder = { fg = c.blue, bg = c.mantle },
                    IncSearch = { bg = c.peach, fg = c.base, style = { "bold" } },
                    CursorLine = { bg = c.surface0 },
                }
            end,
        })
    end,
}
