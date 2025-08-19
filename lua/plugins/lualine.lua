return {
    "nvim-lualine/lualine.nvim",
    config = function()
        -- Add LSP status component
        local function macro_recording()
            local recording_register = vim.fn.reg_recording()
            if recording_register == "" then
                return ""
            else
                return "Recording @" .. recording_register
            end
        end
        require("lualine").setup({
            options = {
                icons_enabled = true,
                theme = "tokyonight",
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch" },
                lualine_c = {
                    {
                        "filename",
                        path = 1,
                        symbols = {
                            modified = "✎",
                            readonly = "",
                            unnamed = "[No Name]",
                            newfile = "[New File]",
                        },
                    },
                    macro_recording,
                },
                lualine_x = {
                    "encoding",
                    {
                        "fileformat",
                        symbols = { unix = "", dos = "" },
                    },
                    "filetype",
                    "diff",
                    "diagnostics",
                    -- {
                    -- 	get_lsp_clients,
                    -- 	icon = " LSP",
                    -- 	color = { fg = "#ff9e64" },
                    -- },

                },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        })
    end,
}
