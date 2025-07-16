return {
    "saghen/blink.cmp",
    event = "VimEnter",
    version = "1.*",
    dependencies = {
        {
            "L3MON4D3/LuaSnip",
            version = "2.*",
            dependencies = {
                "moyiz/blink-emoji.nvim",
                "rafamadriz/friendly-snippets",
            },
            opts = {},
            config = function()
                require("luasnip.loaders.from_vscode").lazy_load()
                require("luasnip.loaders.from_vscode").lazy_load({
                    paths = { "~/.config/nvim/snippets" },
                })
            end,
        },
        "folke/lazydev.nvim",
    },
    opts = {
        snippets = { preset = "luasnip" },
        sources = {
            default = { "lsp", "path", "snippets", "buffer", "lazydev" },
            providers = {
                lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
                path = { score_offset = 100 },
            },
        },
        -- keymap = {
        -- 	preset = "default",
        -- },
        appearance = {
            nerd_font_variant = "mono",
        },
        completion = {
            documentation = { auto_show = false, auto_show_delay_ms = 500 },
        },
        -- fuzzy = { implementation = "lua" },
        fuzzy = { implementation = "prefer_rust_with_warning" },
        signature = { enabled = true },
    },
}
