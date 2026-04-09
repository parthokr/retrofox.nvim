return {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
        { "\\", "<cmd>Neotree toggle<CR>", desc = "NeoTree Toggle", silent = true },
        { "<leader>ge", "<cmd>Neotree git_status<CR>", desc = "NeoTree Git Explorer", silent = true },
        { "<leader>be", "<cmd>Neotree buffers<CR>", desc = "NeoTree Buffers", silent = true },
    },
    opts = {
        -- ── Appearance ──────────────────────────────────────
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        sort_case_insensitive = true,

        -- ── Sources ─────────────────────────────────────────
        sources = {
            "filesystem",
            "buffers",
            "git_status",
        },
        source_selector = {
            winbar = false,
            statusline = false,
            separator = "",
            content_layout = "center",
            sources = {
                { source = "filesystem", display_name = "  Files" },
                { source = "buffers", display_name = "  Buffers" },
                { source = "git_status", display_name = "  Git" },
            },
        },

        -- ── Default component configs ───────────────────────
        default_component_configs = {
            indent = {
                indent_size = 2,
                padding = 1,
                with_markers = true,
                indent_marker = "│",
                last_indent_marker = "╰",
                with_expanders = true,
                expander_collapsed = "",
                expander_expanded = "",
                expander_highlight = "NeoTreeExpander",
            },
            modified = {
                symbol = " ",
                highlight = "NeoTreeModified",
            },
            name = {
                trailing_slash = false,
                use_git_status_colors = true,
                highlight = "NeoTreeFileName",
            },
            git_status = {
                symbols = {
                    added = "●",
                    modified = "◐",
                    deleted = "✕",
                    renamed = "→",
                    untracked = "◌",
                    ignored = "○",
                    unstaged = "◆",
                    staged = "●",
                    conflict = "✱",
                },
            },
            diagnostics = {
                symbols = {
                    hint = "󰌵 ",
                    info = " ",
                    warn = " ",
                    error = " ",
                },
                highlights = {
                    hint = "DiagnosticSignHint",
                    info = "DiagnosticSignInfo",
                    warn = "DiagnosticSignWarn",
                    error = "DiagnosticSignError",
                },
            },
        },

        -- ── Window ──────────────────────────────────────────
        window = {
            position = "left",
            width = 36,
            mapping_options = {
                noremap = true,
                nowait = true,
            },
            mappings = {
                ["\\"] = "close_window",
                ["<CR>"] = "open",
                ["l"] = "open",
                ["h"] = "close_node",
                ["<esc>"] = "cancel",
                ["s"] = "open_split",
                ["v"] = "open_vsplit",
                ["t"] = "open_tabnew",
                ["w"] = "open_with_window_picker",
                ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = false } },
                ["z"] = "close_all_nodes",
                ["Z"] = "expand_all_nodes",
                ["R"] = "refresh",
                ["a"] = { "add", config = { show_path = "relative" } },
                ["A"] = { "add_directory", config = { show_path = "relative" } },
                ["d"] = "delete",
                ["r"] = "rename",
                ["y"] = "copy_to_clipboard",
                ["x"] = "cut_to_clipboard",
                ["p"] = "paste_from_clipboard",
                ["c"] = { "copy", config = { show_path = "relative" } },
                ["m"] = { "move", config = { show_path = "relative" } },
                ["q"] = "close_window",
                ["?"] = "show_help",
            },
        },

        -- ── Filesystem ──────────────────────────────────────
        filesystem = {
            filtered_items = {
                visible = false,
                hide_dotfiles = false,
                hide_gitignored = true,
                hide_by_name = {
                    "node_modules",
                    ".DS_Store",
                    "thumbs.db",
                },
                never_show = {
                    ".git",
                },
            },
            follow_current_file = {
                enabled = true,
                leave_dirs_open = true,
            },
            group_empty_dirs = true,
            use_libuv_file_watcher = true,
            window = {
                mappings = {
                    ["H"] = "toggle_hidden",
                    ["/"] = "fuzzy_finder",
                    ["f"] = "filter_on_submit",
                    ["<C-x>"] = "clear_filter",
                    ["[g"] = "prev_git_modified",
                    ["]g"] = "next_git_modified",
                    ["."] = "set_root",
                    ["<BS>"] = "navigate_up",
                },
            },
        },

        -- ── Buffers ─────────────────────────────────────────
        buffers = {
            follow_current_file = {
                enabled = true,
                leave_dirs_open = true,
            },
            group_empty_dirs = true,
            show_unloaded = true,
            window = {
                mappings = {
                    ["bd"] = "buffer_delete",
                },
            },
        },

        -- ── Git status ──────────────────────────────────────
        git_status = {
            window = {
                mappings = {
                    ["A"] = "git_add_all",
                    ["gu"] = "git_unstage_file",
                    ["ga"] = "git_add_file",
                    ["gr"] = "git_revert_file",
                    ["gc"] = "git_commit",
                    ["gp"] = "git_push",
                },
            },
        },

        -- ── Event handlers ──────────────────────────────────
        event_handlers = {
            -- Auto-close neo-tree when opening a file
            {
                event = "file_open_requested",
                handler = function()
                    require("neo-tree.command").execute({ action = "close" })
                end,
            },
        },
    },
}
