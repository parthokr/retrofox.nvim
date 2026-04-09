return {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
        {
            "<leader>sj",
            mode = { "n", "x", "o" },
            function()
                require("flash").jump()
            end,
            desc = "[S]earch [J]ump",
        },
        {
            "<leader>st",
            mode = { "n", "x", "o" },
            function()
                require("flash").treesitter()
            end,
            desc = "[S]earch [T]reesitter",
        },
        {
            "<leader>sr",
            mode = "o",
            function()
                require("flash").remote()
            end,
            desc = "[S]earch [R]emote",
        },
        {
            "<leader>sR",
            mode = { "o", "x" },
            function()
                require("flash").treesitter_search()
            end,
            desc = "[S]earch Treesitter [R]ange",
        },
        {
            "<c-s>",
            mode = "c",
            function()
                require("flash").toggle()
            end,
            desc = "Toggle Flash Search",
        },
    },
}
