return {
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = function()
            local highlights = {
                "Gray1",
                "Gray2",
                "Gray3",
                "Gray4",
                "Gray5",
                "Gray6",
                "Gray7",
            }

            local hooks = require("ibl.hooks")
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "Gray1", { fg = "#3e3e3e" })
                vim.api.nvim_set_hl(0, "Gray2", { fg = "#484848" })
                vim.api.nvim_set_hl(0, "Gray3", { fg = "#525252" })
                vim.api.nvim_set_hl(0, "Gray4", { fg = "#5c5c5c" })
                vim.api.nvim_set_hl(0, "Gray5", { fg = "#666666" })
                vim.api.nvim_set_hl(0, "Gray6", { fg = "#707070" })
                vim.api.nvim_set_hl(0, "Gray7", { fg = "#7a7a7a" })
                vim.api.nvim_set_hl(0, "IblActiveScope", { fg = "#f9e2af" })
            end)

            -- Register hooks for specific filetypes
            hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

            require("ibl").setup({
                indent = {
                    char = "¦",
                    highlight = highlights,
                },
                scope = {
                    enabled = true,
                    highlight = "IblActiveScope",
                    show_start = false,
                    show_end = false,
                    show_exact_scope = true,
                    injected_languages = true,
                    include = {
                        node_type = {
                            ["*"] = {
                                "*",
                            },
                        },
                    },
                },
                whitespace = {
                    remove_blankline_trail = true,
                },
                exclude = {
                    filetypes = {
                        "help",
                        "dashboard",
                        "neo-tree",
                        "Trouble",
                        "lazy",
                        "mason",
                    },
                },
            })

            -- Enable scope highlighting for specific filetypes
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "python", "typescript", "javascript" },
                callback = function()
                    vim.b.ibl_enabled = true
                    vim.b.ibl_scope_enabled = true
                end,
            })
        end,
    },
}
