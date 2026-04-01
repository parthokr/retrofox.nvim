return {
    "saghen/blink.cmp",
    event = "VimEnter",
    version = "1.*",
    dependencies = {
        {
            "L3MON4D3/LuaSnip",
            version = "2.*",
            dependencies = {
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
        keymap = {
            preset = "default",
            ["<Tab>"] = {
                -- If copilot suggestion visible and blink menu NOT open → accept copilot
                function(cmp)
                    if vim.fn.exists("*copilot#GetDisplayedSuggestion") == 1
                        and vim.fn["copilot#GetDisplayedSuggestion"]().text ~= ""
                        and not cmp.is_visible()
                    then
                        vim.api.nvim_feedkeys(
                            vim.fn["copilot#Accept"](vim.api.nvim_replace_termcodes("<Tab>", true, true, true)),
                            "n",
                            true
                        )
                        return true -- handled
                    end
                end,
                "select_and_accept",
                "snippet_forward",
                "fallback",
            },
            ["<S-Tab>"] = { "snippet_backward", "fallback" },
        },
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
                auto_show = false,
            },
        },
        -- fuzzy = { implementation = "lua" },
        fuzzy = { implementation = "prefer_rust_with_warning" },
        signature = { enabled = true },
    },
}
