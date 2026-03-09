return {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    lazy = false,
    config = function()
        require("gruvbox").setup({
            terminal_colors = true,
            undercurl = true,
            underline = true,
            bold = true,
            italic = {
                strings = false,
                emphasis = true,
                comments = true,
                operators = false,
                folds = true,
            },
            contrast = "hard",
            dim_inactive = true,
            transparent_mode = false,
            overrides = {
                FloatBorder = { link = "GruvboxYellow" },
                SignColumn = { link = "Normal" },
                IncSearch = { reverse = true, bold = true },
            },
        })
    end,
}
