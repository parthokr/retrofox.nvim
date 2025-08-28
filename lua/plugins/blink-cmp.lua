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
            ghost_text = {
                enabled = true,
            },
            menu = {
                draw = {
                    columns = {
                        { "label",     "label_description", gap = 2 },
                        { "kind_icon", "kind",              gap = 2 },
                    },
                    components = {
                        source_name = {
                            text = function(ctx)
                                if ctx.source_id == 'cmdline' then return end
                                return ctx.source_name:sub(1, 4)
                            end,
                        },
                    }
                }
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 100,
            },
        },
        -- fuzzy = { implementation = "lua" },
        fuzzy = { implementation = "prefer_rust_with_warning" },
        signature = { enabled = true },
    },
}
