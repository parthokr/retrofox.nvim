return {
    "nvim-lualine/lualine.nvim",
    config = function()
        -- Macro recording indicator
        local function macro_recording()
            local recording_register = vim.fn.reg_recording()
            if recording_register == "" then
                return ""
            else
                return "Recording @" .. recording_register
            end
        end

        -- LSP client names
        local function lsp_clients()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients == 0 then
                return ""
            end
            local names = {}
            for _, client in ipairs(clients) do
                table.insert(names, client.name)
            end
            return " " .. table.concat(names, ", ")
        end

        require("lualine").setup({
            options = {
                icons_enabled = true,
                theme = "auto",
                globalstatus = true,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff" },
                lualine_c = {
                    {
                        "filename",
                        path = 1,
                        symbols = {
                            modified = "✎",
                            readonly = "",
                            unnamed = "[No Name]",
                            newfile = "[New File]",
                        },
                    },
                    macro_recording,
                    "diagnostics",
                },
                lualine_x = {
                    {
                        lsp_clients,
                        color = { fg = "#89b4fa" },
                    },
                    "encoding",
                    {
                        "fileformat",
                        symbols = { unix = "", dos = "" },
                    },
                    "filetype",
                    "searchcount",
                },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        })
    end,
}
