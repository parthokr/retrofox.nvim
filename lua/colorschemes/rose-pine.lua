return {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    lazy = false,
    config = function()
        require("rose-pine").setup({
            variant = "main",
            dark_variant = "main",
            dim_inactive_windows = false,
            extend_background_behind_borders = true,
            styles = {
                bold = true,
                italic = true,
                transparency = false,
            },
            highlight_groups = {
                CursorLine = { bg = "highlight_low" },
                StatusLine = { fg = "love", bg = "love", blend = 10 },
                StatusLineNC = { fg = "subtle", bg = "surface" },
                FloatBorder = { fg = "foam", bg = "base" },
                IncSearch = { bg = "gold", fg = "base", inherit = false },
            },
        })
    end,
}
