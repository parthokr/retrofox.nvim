return {
    "EdenEast/nightfox.nvim",
    config = function()
        require("nightfox").setup({
            options = {
                transparent = true,
                styles = {
                    comments = "italic",
                    keywords = "bold",
                    functions = "italic,bold",
                    variables = "italic",
                    conditionals = "italic",
                    operators = "bold",
                },
            },
        })
        vim.cmd("highlight WinSeparator guifg=#7f7f7f")
    end,
}
