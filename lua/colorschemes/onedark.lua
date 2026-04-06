return {
    "navarasu/onedark.nvim",
    priority = 1000,
    lazy = false,
    config = function()
        require("onedark").setup({
            style = "dark",
            transparent = false,
            term_colors = true,
            ending_tildes = false,
            styles = {
                comments = "italic",
                keywords = "bold,italic",
                functions = "bold",
                variables = "none",
                strings = "none",
            },
            diagnostics = {
                darker = true,
                undercurl = true,
            },
            highlights = {
                FloatBorder = { fg = "$blue", bg = "$bg0" },
                IncSearch = { fg = "$bg0", bg = "$orange", fmt = "bold" },
                CursorLine = { bg = "$bg1" },
            },
        })
    end,
}
