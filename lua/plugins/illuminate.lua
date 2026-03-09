return {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function()
        require("illuminate").configure({
            providers = { "lsp", "treesitter", "regex" },
            delay = 100,
            filetypes_denylist = { "dirbuf", "dirvish", "fugitive" },
            large_file_cutoff = 10000,
            under_cursor = true,
        })
    end,
}
