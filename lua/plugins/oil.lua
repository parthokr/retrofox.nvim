return {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    lazy = false,
    config = function()
        require("oil").setup({
            -- Show icon, permissions, and size columns for rich context
            columns = {
                "icon",
                "permissions",
                "size",
            },

            -- Safety: deleted files go to trash, not permanent delete
            delete_to_trash = true,

            -- Don't nag for simple renames/creates
            skip_confirm_for_simple_edits = true,

            -- Auto-refresh when files change externally
            watch_for_changes = true,

            -- Keep cursor on editable parts only
            constrain_cursor = "editable",

            -- Clean window appearance
            win_options = {
                wrap = false,
                signcolumn = "no",
                cursorcolumn = false,
                foldcolumn = "0",
                spell = false,
                list = false,
                conceallevel = 3,
                concealcursor = "nvic",
                cursorline = true,
                number = false,
                relativenumber = false,
            },

            -- Smarter file display
            view_options = {
                show_hidden = true,
                natural_order = "fast",
                -- Hide parent dir entry and .git folder
                is_always_hidden = function(name, _)
                    return name == ".." or name == ".git"
                end,
                sort = {
                    { "type", "asc" }, -- directories first
                    { "name", "asc" },
                },
            },

            -- Styled floating window
            float = {
                padding = 4,
                max_width = 0.6,
                max_height = 0.7,
                border = "rounded",
                win_options = {
                    winblend = 0,
                },
                preview_split = "right",
            },

            -- Consistent rounded borders on all popups
            confirmation = {
                border = "rounded",
            },
            progress = {
                border = "rounded",
            },
            ssh = {
                border = "rounded",
            },
            keymaps_help = {
                border = "rounded",
            },
        })

        vim.keymap.set("n", "<leader>-", function()
            require("oil").open_float()
        end, { desc = "Open oil" })
    end,
}
