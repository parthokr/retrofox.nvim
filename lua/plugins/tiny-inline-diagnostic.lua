return {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
        vim.diagnostic.config({ virtual_text = false })

        require("tiny-inline-diagnostic").setup({
            preset = "ghost",
            transparent_bg = false,
            transparent_cursorline = true,

            hi = {
                error = "DiagnosticError",
                warn = "DiagnosticWarn",
                info = "DiagnosticInfo",
                hint = "DiagnosticHint",
                arrow = "NonText",
                background = "CursorLine",
                mixing_color = "Normal",
            },

            options = {
                show_source = { enabled = true, if_many = true },
                show_code = false,
                set_arrow_to_diag_color = true,
                throttle = 40,
                softwrap = 40,

                add_messages = {
                    messages = false,
                    display_count = false,
                    show_multiple_glyphs = true,
                },

                multilines = {
                    enabled = false,
                    always_show = false,
                },

                show_all_diags_on_cursorline = false,

                show_related = {
                    enabled = false,
                    max_count = 3,
                },

                overflow = { mode = "none" },
                break_line = { enabled = true, after = 60 },

                virt_texts = { priority = 2048 },
            },
        })
    end,
}
