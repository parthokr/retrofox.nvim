return {
    "tpope/vim-fugitive",
    -- Optional: Add a keymap to open the fugitive status window
    keys = {
        { "<leader>gs", "<cmd>Git<cr>",        desc = "[G]it [S]tatus" },
        { "<leader>gc", "<cmd>Git commit<cr>", desc = "[G]it [C]ommit" },
        { "<leader>gp", "<cmd>Git push<cr>",   desc = "[G]it [P]ush" },
        { "<leader>gP", "<cmd>Git pull<cr>",   desc = "[G]it [P]ull" },
        { "<leader>gS", "<cmd>Git stash<cr>",  desc = "[G]it [S]tash" },
        { "<leader>gB", "<cmd>Git blame<cr>",  desc = "[G]it [B]lame" },
        { "<leader>gl", "<cmd>Git log<cr>",    desc = "[G]it [L]og" },
    }
}
