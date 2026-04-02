return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    },
    opts = {
        cmdline = {
            enabled = true,
            view = "cmdline_popup",
            format = {
                cmdline = { pattern = "^:", icon = " ", lang = "vim" },
                search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
                search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
                filter = { pattern = "^:%s*!", icon = " $", lang = "bash" },
                lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = " ", lang = "lua" },
                help = { pattern = "^:%s*he?l?p?%s+", icon = "󰋖 " },
            },
        },
        messages = {
            enabled = true,
            view = "mini",
            view_error = "notify",
            view_warn = "notify",
            view_history = "messages",
            view_search = "virtualtext",
        },
        popupmenu = {
            enabled = true,
            backend = "nui",
        },
        lsp = {
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
                ["vim.lsp.util.stylize_markdown"] = false,
                ["cmp.entry.get_documentation"] = false,
            },
            hover = {
                enabled = false,
            },
            signature = {
                enabled = true,
                opts = {
                    size = { max_width = 80, max_height = 15 },
                },
            },
            progress = { enabled = true },
        },
        presets = {
            bottom_search = false,
            command_palette = true,
            long_message_to_split = true,
            inc_rename = false,
            lsp_doc_border = true,
        },
        views = {
            hover = {
                border = { style = "rounded", padding = { 0, 1 } },
                position = { row = 2, col = 2 },
                win_options = {
                    wrap = true,
                    linebreak = true,
                    conceallevel = 2,
                    concealcursor = "niv",
                },
                scrollbar = true,
            },
            cmdline_popup = {
                position = { row = "40%", col = "50%" },
                size = { width = 60, height = "auto" },
                border = { style = "rounded", padding = { 0, 1 } },
            },
            popupmenu = {
                relative = "editor",
                position = { row = "48%", col = "50%" },
                size = { width = 60, height = 10 },
                border = { style = "rounded", padding = { 0, 1 } },
            },
        },
        routes = {
            -- Skip "written" messages
            {
                filter = { event = "msg_show", kind = "", find = "written" },
                opts = { skip = true },
            },
            -- Skip search count messages (shown in virtualtext)
            {
                filter = { event = "msg_show", kind = "search_count" },
                opts = { skip = true },
            },
        },
    },
}
