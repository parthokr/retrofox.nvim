return {
    "goolord/alpha-nvim",
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        local function banner_path()
            local ok, rf = pcall(require, "retrofox")
            if ok then
                return rf.data_dir() .. "/banner.txt"
            end
            return (os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")) .. "/retrofox/banner.txt"
        end

        local function load_header()
            local path = banner_path()
            local lines = { "" }

            if vim.fn.filereadable(path) == 1 then
                local read = vim.fn.readfile(path)
                if type(read) == "table" and #read > 0 then
                    vim.list_extend(lines, read)
                    table.insert(lines, "")
                    return lines
                end
            end

            return {
                "",
                "███╗   ██╗██╗   ██╗██╗███╗   ███╗",
                "████╗  ██║██║   ██║██║████╗ ████║",
                "██╔██╗ ██║██║   ██║██║██╔████╔██║",
                "██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                "██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
                "╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
                "",
            }
        end

        local function action(shortcut, icon, label, command)
            local button = dashboard.button(shortcut, string.format("%s  %s", icon, label), command)
            button.opts.width = 56
            button.opts.hl = "AlphaButtons"
            button.opts.hl_shortcut = "AlphaShortcut"
            button.opts.cursor = 0
            button.opts.align_shortcut = "right"
            return button
        end

        dashboard.section.header.val = load_header()
        dashboard.section.header.opts.position = "center"
        dashboard.section.header.opts.hl = "AlphaHeader"

        local greeting_section = {
            type = "text",
            val = function()
                local hour = tonumber(os.date("%H")) or 12
                local icon, msg
                if hour < 5 then
                    icon, msg = "󰖔", "Good night"
                elseif hour < 12 then
                    icon, msg = "󰖙", "Good morning"
                elseif hour < 17 then
                    icon, msg = "󰖗", "Good afternoon"
                else
                    icon, msg = "󰖔", "Good evening"
                end
                return icon .. "  " .. msg
            end,
            opts = { hl = "AlphaGreeting", position = "center" },
        }

        local date_section = {
            type = "text",
            val = os.date("%A, %d %B %Y"),
            opts = { hl = "AlphaDate", position = "center" },
        }

        local function make_separator()
            return {
                type = "text",
                val = "────────────────────────────────────────",
                opts = { hl = "AlphaSeparator", position = "center" },
            }
        end

        dashboard.section.buttons.val = {
            action("f", "󰱼", "Find file", "<cmd>FzfLua files<CR>"),
            action("r", "󰋚", "Recent files", "<cmd>FzfLua oldfiles<CR>"),
            action("g", "󰈬", "Live grep", "<cmd>FzfLua live_grep<CR>"),
            action("n", "󰈔", "New file", "<cmd>ene<CR>"),
            action("c", "󰒓", "Config", "<cmd>FzfLua files cwd=" .. vim.fn.stdpath("config") .. "<CR>"),
            action("t", "󰏘", "Themes", "<cmd>lua require('theme-picker').open()<CR>"),
            action("l", "󰒲", "Lazy", "<cmd>Lazy<CR>"),
            action("q", "󰗼", "Quit", "<cmd>qa<CR>"),
        }
        dashboard.section.buttons.opts.spacing = 0

        local recent_files_section = {
            type = "group",
            val = function()
                local oldfiles = vim.v.oldfiles or {}
                local items = {}
                local max_display = 55

                table.insert(items, {
                    type = "text",
                    val = "  Recents",
                    opts = { hl = "AlphaRecentHeader", position = "center" },
                })
                table.insert(items, { type = "padding", val = 1 })

                local count = 0
                for _, file in ipairs(oldfiles) do
                    if count >= 5 then break end
                    local path = vim.fn.expand(file)
                    if vim.fn.filereadable(path) == 1 then
                        count = count + 1

                        local filename = vim.fn.fnamemodify(path, ":t")
                        local dir = vim.fn.fnamemodify(path, ":~:h")

                        local avail = max_display - #filename - 4
                        if #dir > avail and avail > 4 then
                            dir = "…" .. dir:sub(-(avail - 1))
                        elseif avail <= 4 then
                            dir = "…"
                        end

                        local label = string.format("  %s  %s", filename, dir)
                        local key = tostring(count)
                        local btn = dashboard.button(key, label, "<cmd>e " .. vim.fn.fnameescape(path) .. "<CR>")
                        btn.opts.width = 60
                        btn.opts.hl = "AlphaRecentFile"
                        btn.opts.hl_shortcut = "AlphaShortcut"
                        btn.opts.cursor = 0
                        btn.opts.align_shortcut = "right"
                        btn.opts.position = "center"
                        table.insert(items, btn)
                    end
                end

                if count == 0 then
                    table.insert(items, {
                        type = "text",
                        val = "  No recent files",
                        opts = { hl = "Comment", position = "center" },
                    })
                end

                return items
            end,
            opts = { position = "center" },
        }

        dashboard.section.footer.val = function()
            local stats = require("lazy").stats()
            local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
            return {
                string.format("⚡ %d/%d plugins · %.0fms", stats.loaded, stats.count, ms),
            }
        end
        dashboard.section.footer.opts.hl = "AlphaFooter"
        dashboard.section.footer.opts.position = "center"

        local top_pad = math.max(1, math.floor((vim.o.lines - 40) / 3))
        dashboard.config.layout = {
            { type = "padding", val = top_pad },
            dashboard.section.header,
            { type = "padding", val = 1 },
            greeting_section,
            date_section,
            { type = "padding", val = 2 },
            make_separator(),
            { type = "padding", val = 1 },
            dashboard.section.buttons,
            { type = "padding", val = 1 },
            make_separator(),
            { type = "padding", val = 1 },
            recent_files_section,
            { type = "padding", val = 2 },
            dashboard.section.footer,
        }

        local function set_highlights()
            local function get_fg(name)
                local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
                return ok and hl.fg and string.format("#%06x", hl.fg) or nil
            end

            local function get_bg(name)
                local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
                return ok and hl.bg and string.format("#%06x", hl.bg) or nil
            end

            local function hex_to_rgb(hex)
                hex = hex:gsub("#", "")
                return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
            end

            local function blend(c1, c2, t)
                local r1, g1, b1 = hex_to_rgb(c1)
                local r2, g2, b2 = hex_to_rgb(c2)
                return string.format(
                    "#%02x%02x%02x",
                    math.floor(r1 + (r2 - r1) * t),
                    math.floor(g1 + (g2 - g1) * t),
                    math.floor(b1 + (b2 - b1) * t)
                )
            end

            local green = get_fg("String") or "#9ece6a"
            local orange = get_fg("Constant") or "#ff9e64"
            local dim = get_fg("Comment") or "#a9b1d6"
            local keyword = get_fg("Keyword") or "#c099ff"
            local blue = get_fg("Function") or "#7aa2f7"
            local bg = get_bg("Normal") or "#1a1b26"
            local sep_fg = blend(bg, dim, 0.45)

            vim.api.nvim_set_hl(0, "AlphaHeader", { fg = blue, bold = true })
            vim.api.nvim_set_hl(0, "AlphaButtons", { fg = green })
            vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = orange, bold = true })
            vim.api.nvim_set_hl(0, "AlphaFooter", { fg = dim, italic = true })
            vim.api.nvim_set_hl(0, "AlphaRecentHeader", { fg = orange, bold = true })
            vim.api.nvim_set_hl(0, "AlphaRecentFile", { fg = dim })
            vim.api.nvim_set_hl(0, "AlphaGreeting", { fg = keyword, bold = true })
            vim.api.nvim_set_hl(0, "AlphaDate", { fg = dim, italic = true })
            vim.api.nvim_set_hl(0, "AlphaSeparator", { fg = sep_fg })
        end

        local alpha_group = vim.api.nvim_create_augroup("AlphaDashboard", { clear = true })
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = alpha_group,
            callback = set_highlights,
        })

        set_highlights()
        alpha.setup(dashboard.config)
    end,
}
