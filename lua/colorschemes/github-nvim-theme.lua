return {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    priority = 1000,
    lazy = false,
    config = function()
        require("github-theme").setup({
            options = {
                transparent = false,
                terminal_colors = true,
                dim_inactive = true,
                styles = {
                    comments = "italic",
                    keywords = "bold",
                    functions = "bold",
                    variables = "NONE",
                    conditionals = "italic",
                    constants = "bold",
                    operators = "NONE",
                },
                darken = {
                    floats = true,
                    sidebars = {
                        enable = true,
                        list = { "qf", "help", "neo-tree" },
                    },
                },
                modules = {
                    gitsigns = true,
                    indent_blankline = true,
                    neotree = true,
                    notify = true,
                    treesitter = true,
                    whichkey = true,
                },
            },
            -- Available: github_dark, github_dark_dimmed, github_dark_high_contrast,
            --            github_light, github_light_default, github_light_high_contrast
        })
    end,
}
