return {
    "echasnovski/mini.nvim",
    config = function()
        require("mini.ai").setup({
            n_lines = 500,
            -- Disable 'an' and 'in' to avoid conflict with Neovim 0.12 native
            -- treesitter incremental selection (v_an / v_in)
            mappings = {
                around_next = "",
                inside_next = "",
            },
        })
        require("mini.surround").setup()
    end,
}
