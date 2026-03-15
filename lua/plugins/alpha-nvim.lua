return {
    "goolord/alpha-nvim",
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- Quote fetcher (async, non-blocking)
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        local fallback_quote = "Stay focused, keep shipping."
        local loading_quote = "Loading quote..."
        local quote_filters = { "life", "philosophy", "philosphy", "motivation", "coding", "inspirational" }
        local quote_state = { text = loading_quote, is_loading = true, request_started = false, seeded = false }

        local function normalize(s)
            return type(s) == "string" and s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "") or ""
        end

        local function truncate(s, max)
            return #s <= max and s or s:sub(1, max - 3) .. "..."
        end

        local function wrap_text(text, max_width)
            if type(text) ~= "string" or text == "" then return { "" } end
            local width = math.max(30, max_width or 60)
            local lines, line = {}, ""
            for word in text:gmatch("%S+") do
                if line == "" then
                    line = word
                elseif (#line + 1 + #word) <= width then
                    line = line .. " " .. word
                else
                    table.insert(lines, line)
                    line = word
                end
            end
            if line ~= "" then table.insert(lines, line) end
            return #lines > 0 and lines or { text }
        end

        local function set_quote(text)
            quote_state.text, quote_state.is_loading = text, false
            pcall(alpha.redraw)
        end

        local function seed_random()
            if quote_state.seeded then return end
            local seed = os.time()
            local uv = vim.uv or vim.loop
            if uv and uv.hrtime then seed = (seed + uv.hrtime()) % 2147483647 end
            math.randomseed(seed)
            math.random()
            quote_state.seeded = true
        end

        local function fetch_quote_from_favqs()
            if quote_state.request_started then return end
            quote_state.request_started = true

            local api_key = vim.env.FAVQS_API_KEY
            if type(api_key) ~= "string" or api_key == "" then
                local env_key = vim.fn.getenv("FAVQS_API_KEY")
                if type(env_key) == "string" and env_key ~= "" then api_key = env_key end
            end
            if type(api_key) ~= "string" or api_key == "" then
                set_quote(fallback_quote)
                return
            end

            local auth_headers = {
                "Authorization: Token token=" .. api_key,
                "Authorization: Token token=\"" .. api_key .. "\"",
            }
            local filter_index = 1

            local function try_next_filter()
                local filter = quote_filters[filter_index]
                filter_index = filter_index + 1
                if not filter then set_quote(fallback_quote); return end

                local encoded = (vim.uri_encode and vim.uri_encode(filter)) or filter:gsub(" ", "%%20")

                local function try_auth(auth_idx)
                    local auth = auth_headers[auth_idx]
                    if not auth then try_next_filter(); return end

                    vim.system({
                        "curl", "-fsSL", "--connect-timeout", "3", "--max-time", "6",
                        "https://favqs.com/api/quotes/?filter=" .. encoded,
                        "-H", auth, "-H", "Accept: application/json",
                    }, { text = true }, function(result)
                        vim.schedule(function()
                            if result.code ~= 0 or not result.stdout or result.stdout == "" then
                                try_auth(auth_idx + 1); return
                            end
                            local ok, decoded = pcall(vim.json.decode, result.stdout:gsub("^\239\187\191", ""))
                            if ok and type(decoded) == "table" and type(decoded.quotes) == "table" and #decoded.quotes > 0 then
                                local candidates = {}
                                for _, q in ipairs(decoded.quotes) do
                                    local body = normalize(q.body)
                                    if body ~= "" then
                                        local author = normalize(q.author)
                                        if author ~= "" then body = body .. " — " .. author end
                                        table.insert(candidates, truncate(body, 110))
                                    end
                                end
                                if #candidates > 0 then
                                    seed_random()
                                    set_quote(candidates[math.random(#candidates)])
                                    return
                                end
                            end
                            try_auth(auth_idx + 1)
                        end)
                    end)
                end

                try_auth(1)
            end

            try_next_filter()
        end

        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- Animated color-cycling header
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        local header = {
            "",
            "  ██████╗   █████╗  ██████╗  ████████╗ ██╗  ██╗  ██████╗  ",
            "  ██╔══██╗ ██╔══██╗ ██╔══██╗ ╚══██╔══╝ ██║  ██║ ██╔═══██╗ ",
            "  ██████╔╝ ███████║ ██████╔╝    ██║    ████████║ ██║   ██║ ",
            "  ██╔═══╝  ██╔══██║ ██╔══██╗    ██║    ██╔══██║ ██║   ██║ ",
            "  ██║      ██║  ██║ ██║  ██║    ██║    ██║  ██║ ╚██████╔╝ ",
            "  ╚═╝      ╚═╝  ╚═╝ ╚═╝  ╚═╝    ╚═╝    ╚═╝  ╚═╝  ╚═════╝  ",
            "",
        }

        -- HSL → RGB conversion for smooth color cycling
        local function hsl_to_hex(h, s, l)
            h = h / 360
            local function hue2rgb(p, q, t)
                if t < 0 then t = t + 1 end
                if t > 1 then t = t - 1 end
                if t < 1 / 6 then return p + (q - p) * 6 * t end
                if t < 1 / 2 then return q end
                if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
                return p
            end
            local q = l < 0.5 and l * (1 + s) or l + s - l * s
            local p = 2 * l - q
            local r = math.floor(hue2rgb(p, q, h + 1 / 3) * 255)
            local g = math.floor(hue2rgb(p, q, h) * 255)
            local b = math.floor(hue2rgb(p, q, h - 1 / 3) * 255)
            return string.format("#%02x%02x%02x", r, g, b)
        end

        -- Create highlight groups for each header line
        local num_header_lines = #header
        local hl_groups = {}
        for i = 1, num_header_lines do
            hl_groups[i] = "AlphaHeaderAnim" .. i
        end

        local anim_hue = 0
        local anim_timer = nil

        local function update_header_colors()
            for i = 1, num_header_lines do
                -- Each line offset by 25° for a gradient wave effect
                local hue = (anim_hue + (i - 1) * 25) % 360
                local color = hsl_to_hex(hue, 0.65, 0.68)
                vim.api.nvim_set_hl(0, hl_groups[i], { fg = color, bold = true })
            end
        end

        local function start_animation()
            if anim_timer then return end
            anim_timer = (vim.uv or vim.loop).new_timer()
            anim_timer:start(0, 60, vim.schedule_wrap(function()
                anim_hue = (anim_hue + 1) % 360
                update_header_colors()
            end))
        end

        local function stop_animation()
            if anim_timer then
                anim_timer:stop()
                anim_timer:close()
                anim_timer = nil
            end
        end

        -- Build header highlights
        local header_hl = {}
        for i = 1, num_header_lines do
            header_hl[i] = { { hl_groups[i], 0, -1 } }
        end

        dashboard.section.header.val = header
        dashboard.section.header.opts.position = "center"
        dashboard.section.header.opts.hl = header_hl

        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- Context sections (greeting, date, separator)
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        local greeting_section = {
            type = "text",
            val = function()
                local hour = tonumber(os.date("%H"))
                local icon, msg
                if hour < 5 then      icon, msg = "󰖔", "Good night"
                elseif hour < 12 then icon, msg = "󰖙", "Good morning"
                elseif hour < 17 then icon, msg = "", "Good afternoon"
                else                  icon, msg = "󰖔", "Good evening"
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

        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- Quick Actions
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        local function action(shortcut, icon, label, command)
            local button = dashboard.button(shortcut, string.format("%s  %s", icon, label), command)
            button.opts.width = 56
            button.opts.hl = "AlphaButtons"
            button.opts.hl_shortcut = "AlphaShortcut"
            button.opts.cursor = 0
            button.opts.align_shortcut = "right"
            return button
        end

        dashboard.section.buttons.val = {
            action("f", "󰱼", "Find file", "<cmd>FzfLua files<CR>"),
            action("r", "󰋚", "Recent files", "<cmd>FzfLua oldfiles<CR>"),
            action("g", "󰈬", "Live grep", "<cmd>FzfLua live_grep<CR>"),
            action("n", "󰈔", "New file", "<cmd>ene<CR>"),
            action("c", "󰒓", "Config", "<cmd>FzfLua files cwd=" .. vim.fn.stdpath("config") .. "<CR>"),
            action("t", "󰏘", "Themes", "<cmd>lua require('theme-picker').open()<CR>"),
            action("l", "󰒲", "Lazy", "<cmd>Lazy<CR>"),
            action("q", "\u{f011}", "Quit", "<cmd>qa<CR>"),
        }
        dashboard.section.buttons.opts.spacing = 0

        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- Recent Files
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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

        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- Footer
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        dashboard.section.footer.val = function()
            local stats = require("lazy").stats()
            local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
            local lines = {
                string.format("⚡ %d/%d plugins · %.0fms", stats.loaded, stats.count, ms),
            }

            local quote = quote_state.is_loading and loading_quote or quote_state.text
            local max_width = math.max(30, math.min(vim.o.columns - 12, 70))
            for _, wrapped in ipairs(wrap_text(quote, max_width)) do
                table.insert(lines, "  " .. wrapped)
            end

            return lines
        end
        dashboard.section.footer.opts.hl = "AlphaFooter"
        dashboard.section.footer.opts.position = "center"

        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- Layout
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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

        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- Adaptive highlights (colorscheme-reactive)
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        local function set_static_highlights()
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
                return string.format("#%02x%02x%02x",
                    math.floor(r1 + (r2 - r1) * t),
                    math.floor(g1 + (g2 - g1) * t),
                    math.floor(b1 + (b2 - b1) * t))
            end

            local green   = get_fg("String")   or "#9ece6a"
            local orange  = get_fg("Constant")  or "#ff9e64"
            local dim     = get_fg("Comment")   or "#a9b1d6"
            local keyword = get_fg("Keyword")   or "#c099ff"
            local bg      = get_bg("Normal")    or "#1a1b26"

            local sep_fg = blend(bg, dim, 0.45)

            vim.api.nvim_set_hl(0, "AlphaButtons",      { fg = green })
            vim.api.nvim_set_hl(0, "AlphaShortcut",     { fg = orange, bold = true })
            vim.api.nvim_set_hl(0, "AlphaFooter",       { fg = dim, italic = true })
            vim.api.nvim_set_hl(0, "AlphaRecentHeader", { fg = orange, bold = true })
            vim.api.nvim_set_hl(0, "AlphaRecentFile",   { fg = dim })
            vim.api.nvim_set_hl(0, "AlphaGreeting",     { fg = keyword, bold = true })
            vim.api.nvim_set_hl(0, "AlphaDate",         { fg = dim, italic = true })
            vim.api.nvim_set_hl(0, "AlphaSeparator",    { fg = sep_fg })
        end

        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- Autocmds: animation lifecycle + colorscheme reactivity
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        local alpha_group = vim.api.nvim_create_augroup("AlphaDashboard", { clear = true })

        vim.api.nvim_create_autocmd("User", {
            group = alpha_group,
            pattern = "AlphaReady",
            callback = function()
                set_static_highlights()
                update_header_colors()
                start_animation()
                fetch_quote_from_favqs()
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            group = alpha_group,
            pattern = "AlphaClosed",
            callback = stop_animation,
        })

        -- Stop animation when leaving the alpha buffer
        vim.api.nvim_create_autocmd("BufUnload", {
            group = alpha_group,
            callback = function(args)
                if vim.bo[args.buf].filetype == "alpha" then
                    stop_animation()
                end
            end,
        })

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = alpha_group,
            callback = function()
                set_static_highlights()
                update_header_colors()
            end,
        })

        set_static_highlights()
        update_header_colors()
        alpha.setup(dashboard.config)
    end,
}
