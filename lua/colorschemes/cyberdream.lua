return {
    "scottmckendry/cyberdream.nvim",
    priority = 1000,
    lazy = false,
    config = function()
        require("cyberdream").setup({
            transparent = false,
            italic_comments = true,
            hide_fillchars = false,
            borderless_pickers = false,
            terminal_colors = true,
        })
    end,
}
