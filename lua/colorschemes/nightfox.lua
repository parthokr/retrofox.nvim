return {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    lazy = false,
    config = function()
        require("nightfox").setup({
            options = {
                transparent = false,
                terminal_colors = true,
                dim_inactive = true,
                styles = {
                    comments = "italic",
                    keywords = "bold,italic",
                    functions = "bold",
                    variables = "",
                    conditionals = "italic",
                    constants = "bold",
                    operators = "bold",
                    types = "italic",
                },
                inverse = {
                    match_paren = true,
                    visual = false,
                    search = true,
                },
                modules = {
                    alpha = true,
                    gitsigns = true,
                    indent_blankline = true,
                    neotree = true,
                    notify = true,
                    treesitter = true,
                    whichkey = true,
                },
            },
            groups = {
                all = {
                    -- Undercurl diagnostics
                    DiagnosticUnderlineError = { style = "undercurl" },
                    DiagnosticUnderlineWarn = { style = "undercurl" },
                    DiagnosticUnderlineInfo = { style = "undercurl" },
                    DiagnosticUnderlineHint = { style = "undercurl" },
                    -- Better float
                    NormalFloat = { link = "Normal" },
                },
            },
        })
    end,
}
