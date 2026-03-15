return {
    "nvim-lualine/lualine.nvim",
    config = function()
        -- ── Custom Components ──────────────────────────────────────

        local function macro_recording()
            local reg = vim.fn.reg_recording()
            if reg == "" then return "" end
            return "󰑋 " .. reg
        end

        local function lsp_clients()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients == 0 then return "" end
            local names = {}
            for _, c in ipairs(clients) do
                table.insert(names, c.name)
            end
            return "  " .. table.concat(names, "  ")
        end

        local function cursor_position()
            local line = vim.fn.line(".")
            local col = vim.fn.virtcol(".")
            return string.format("%d:%d", line, col)
        end

        local function word_count()
            local ft = vim.bo.filetype
            if ft ~= "markdown" and ft ~= "text" and ft ~= "tex" then return "" end
            local wc = vim.fn.wordcount()
            return "󰈭 " .. (wc.visual_words or wc.words)
        end

        -- ── Custom minimal theme from scratch ──────────────────────
        -- Draws colors from your active colorscheme so it always blends
        local function get_custom_theme()
            local function hl(name)
                local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
                if ok then return h end
                return {}
            end

            local normal = hl("Normal")
            local comment = hl("Comment")
            local string_hl = hl("String")
            local keyword = hl("Keyword")
            local func_hl = hl("Function")
            local diagnostic_warn = hl("DiagnosticWarn")

            local bg = normal.bg and string.format("#%06x", normal.bg) or "#1a1b26"
            local fg = normal.fg and string.format("#%06x", normal.fg) or "#c0caf5"
            local dim = comment.fg and string.format("#%06x", comment.fg) or "#565f89"
            local green = string_hl.fg and string.format("#%06x", string_hl.fg) or "#9ece6a"
            local blue = func_hl.fg and string.format("#%06x", func_hl.fg) or "#7aa2f7"
            local purple = keyword.fg and string.format("#%06x", keyword.fg) or "#bb9af7"
            local yellow = diagnostic_warn.fg and string.format("#%06x", diagnostic_warn.fg) or "#e0af68"

            -- Slightly lighter bg for subtle contrast
            local function lighten(hex, amount)
                local r = tonumber(hex:sub(2, 3), 16)
                local g = tonumber(hex:sub(4, 5), 16)
                local b = tonumber(hex:sub(6, 7), 16)
                r = math.min(255, r + amount)
                g = math.min(255, g + amount)
                b = math.min(255, b + amount)
                return string.format("#%02x%02x%02x", r, g, b)
            end

            local bg1 = lighten(bg, 10)
            local bg2 = lighten(bg, 20)

            return {
                normal = {
                    a = { bg = blue, fg = bg, gui = "bold" },
                    b = { bg = bg2, fg = blue },
                    c = { bg = bg1, fg = fg },
                },
                insert = {
                    a = { bg = green, fg = bg, gui = "bold" },
                    b = { bg = bg2, fg = green },
                },
                visual = {
                    a = { bg = purple, fg = bg, gui = "bold" },
                    b = { bg = bg2, fg = purple },
                },
                replace = {
                    a = { bg = yellow, fg = bg, gui = "bold" },
                    b = { bg = bg2, fg = yellow },
                },
                command = {
                    a = { bg = yellow, fg = bg, gui = "bold" },
                    b = { bg = bg2, fg = yellow },
                },
                inactive = {
                    a = { bg = bg1, fg = dim },
                    b = { bg = bg1, fg = dim },
                    c = { bg = bg1, fg = dim },
                },
            }
        end

        -- ── Mode name mapping (short + iconic) ────────────────────
        local mode_map = {
            ["NORMAL"]   = " NOR",
            ["INSERT"]   = " INS",
            ["VISUAL"]   = "󰈈 VIS",
            ["V-LINE"]   = "󰈈 V·L",
            ["V-BLOCK"]  = "󰈈 V·B",
            ["COMMAND"]  = " CMD",
            ["REPLACE"]  = " REP",
            ["TERMINAL"] = " TER",
            ["SELECT"]   = "󰒉 SEL",
        }

        require("lualine").setup({
            options = {
                icons_enabled = true,
                theme = get_custom_theme(),
                globalstatus = true,
                component_separators = "",
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                    statusline = { "alpha", "neo-tree", "toggleterm" },
                },
            },
            sections = {
                lualine_a = {
                    {
                        "mode",
                        fmt = function(s) return mode_map[s] or s end,
                    },
                },
                lualine_b = {
                    {
                        "branch",
                        icon = "",
                        color = { gui = "bold" },
                    },
                    {
                        "diff",
                        symbols = { added = " ", modified = " ", removed = " " },
                        padding = { left = 1, right = 1 },
                    },
                },
                lualine_c = {
                    {
                        "filetype",
                        icon_only = true,
                        padding = { left = 1, right = 0 },
                    },
                    {
                        "filename",
                        path = 1,
                        symbols = {
                            modified = " ●",
                            readonly = " 󰌾",
                            unnamed = "[No Name]",
                            newfile = " [New]",
                        },
                    },
                    {
                        "diagnostics",
                        sources = { "nvim_diagnostic" },
                        symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
                        padding = { left = 2 },
                    },
                    {
                        macro_recording,
                        color = { fg = "#f38ba8", gui = "bold" },
                    },
                },
                lualine_x = {
                    word_count,
                    {
                        lsp_clients,
                        color = { fg = "#89b4fa" },
                    },
                    { "encoding", padding = { left = 1, right = 1 } },
                    { "filetype", padding = { left = 0, right = 1 } },
                },
                lualine_y = {
                    {
                        "searchcount",
                        icon = "",
                    },
                    {
                        "progress",
                        fmt = function()
                            local cur = vim.fn.line(".")
                            local total = vim.fn.line("$")
                            if cur == 1 then return "Top" end
                            if cur == total then return "Bot" end
                            return math.floor(cur / total * 100) .. "%%"
                        end,
                    },
                },
                lualine_z = {
                    {
                        cursor_position,
                        icon = "",
                        padding = { left = 1, right = 1 },
                    },
                },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {
                    {
                        "filename",
                        path = 1,
                        symbols = { modified = " ●", readonly = " 󰌾" },
                    },
                },
                lualine_x = { "location" },
                lualine_y = {},
                lualine_z = {},
            },
        })
    end,
}
