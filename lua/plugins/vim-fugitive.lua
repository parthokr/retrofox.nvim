return {
    "tpope/vim-fugitive",
    -- Optional: Add a keymap to open the fugitive status window
    keys = {
        { "gs", "<cmd>Git<cr>",        desc = "[G]it [S]tatus" },
        { "gc", "<cmd>Git commit<cr>", desc = "[G]it [C]ommit" },
        { "gp", "<cmd>Git push<cr>",   desc = "[G]it [P]ush" },
        { "gP", "<cmd>Git pull<cr>",   desc = "[G]it [P]ull" },
        { "gS", "<cmd>Git stash<cr>",  desc = "[G]it [S]tash" },
        { "gB", "<cmd>Git blame<cr>",  desc = "[G]it [B]lame" },
        { "gl", "<cmd>Git log<cr>",    desc = "[G]it [L]og" },
    }
}
