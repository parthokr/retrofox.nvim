-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Theme Picker — A beautiful floating colorscheme switcher
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local M = {}

-- ── Curated theme catalog ───────────────────────────────────
-- Each entry: { colorscheme_name, display_label, icon, accent_hex [, setup_fn] }
-- Optional setup_fn is called before applying the colorscheme (for vim.g settings etc.)
-- Grouped by family with header separators

local catalog = {
    -- ── Tokyonight ──
    { header = "Tokyo Night" },
    { "tokyonight-night", "Night", "󰘪", "#7aa2f7" },
    { "tokyonight-storm", "Storm", "󰖐", "#7dcfff" },
    { "tokyonight-moon", "Moon", "󰽥", "#c099ff" },
    { "tokyonight-day", "Day", "󰖙", "#2e7de9" },

    -- ── Catppuccin ──
    { header = "Catppuccin" },
    { "catppuccin-mocha", "Mocha", "󰄛", "#cba6f7" },
    { "catppuccin-macchiato", "Macchiato", "󰄛", "#c6a0f6" },
    { "catppuccin-frappe", "Frappé", "󰄛", "#ca9ee6" },
    { "catppuccin-latte", "Latte", "󰄛", "#8839ef" },

    -- ── Kanagawa ──
    { header = "Kanagawa" },
    { "kanagawa-wave", "Wave", "󰺣", "#7e9cd8" },
    { "kanagawa-dragon", "Dragon", "󰺣", "#c4b28a" },
    { "kanagawa-lotus", "Lotus", "󰺣", "#c84053" },

    -- ── Nightfox ──
    { header = "Nightfox" },
    { "nightfox", "Nightfox", "", "#719cd6" },
    { "duskfox", "Duskfox", "", "#a3be8c" },
    { "nordfox", "Nordfox", "", "#81a1c1" },
    { "terafox", "Terafox", "", "#5a93aa" },
    { "carbonfox", "Carbonfox", "", "#78a9ff" },
    { "dayfox", "Dayfox", "󰖙", "#4d688e" },
    { "dawnfox", "Dawnfox", "󰖙", "#b4637a" },

    -- ── Rosé Pine ──
    { header = "Rosé Pine" },
    { "rose-pine", "Main", "󰧱", "#eb6f92" },
    { "rose-pine-moon", "Moon", "󰧱", "#ea9a97" },
    { "rose-pine-dawn", "Dawn", "󰧱", "#d7827e" },

    -- ── GitHub ──
    { header = "GitHub" },
    { "github_dark", "Dark", "", "#79c0ff" },
    { "github_dark_dimmed", "Dimmed", "", "#539bf5" },
    { "github_dark_high_contrast", "Hi-Con Dark", "", "#71b7ff" },
    { "github_light", "Light", "󰖙", "#0969da" },
    { "github_light_default", "Light Default", "󰖙", "#0969da" },

    -- ── Everforest ──
    { header = "Everforest" },
    { "everforest", "Dark Hard", "󰌪", "#a7c080", function() vim.o.background = "dark"; vim.g.everforest_background = "hard" end },
    { "everforest", "Dark Medium", "󰌪", "#a7c080", function() vim.o.background = "dark"; vim.g.everforest_background = "medium" end },
    { "everforest", "Dark Soft", "󰌪", "#a7c080", function() vim.o.background = "dark"; vim.g.everforest_background = "soft" end },
    { "everforest", "Light Hard", "󰌪", "#5da111", function() vim.o.background = "light"; vim.g.everforest_background = "hard" end },
    { "everforest", "Light Medium", "󰌪", "#5da111", function() vim.o.background = "light"; vim.g.everforest_background = "medium" end },
    { "everforest", "Light Soft", "󰌪", "#5da111", function() vim.o.background = "light"; vim.g.everforest_background = "soft" end },

    -- ── Gruvbox ──
    { header = "Gruvbox" },
    { "gruvbox", "Dark", "󰊠", "#d79921", function() vim.o.background = "dark" end },
    { "gruvbox", "Light", "󰊠", "#d79921", function() vim.o.background = "light" end },

    -- ── Gruvbox Material ──
    { header = "Gruvbox Material" },
    { "gruvbox-material", "Dark Hard", "󰊠", "#d4be98", function() vim.o.background = "dark"; vim.g.gruvbox_material_background = "hard" end },
    { "gruvbox-material", "Dark Medium", "󰊠", "#d4be98", function() vim.o.background = "dark"; vim.g.gruvbox_material_background = "medium" end },
    { "gruvbox-material", "Dark Soft", "󰊠", "#d4be98", function() vim.o.background = "dark"; vim.g.gruvbox_material_background = "soft" end },
    { "gruvbox-material", "Light Hard", "󰊠", "#a96b2c", function() vim.o.background = "light"; vim.g.gruvbox_material_background = "hard" end },
    { "gruvbox-material", "Light Medium", "󰊠", "#a96b2c", function() vim.o.background = "light"; vim.g.gruvbox_material_background = "medium" end },
    { "gruvbox-material", "Light Soft", "󰊠", "#a96b2c", function() vim.o.background = "light"; vim.g.gruvbox_material_background = "soft" end },

    -- ── OneDark ──
    { header = "OneDark" },
    { "onedark", "Dark", "󰏘", "#61afef", function() require("onedark").setup({style="dark"}); require("onedark").load() end },
    { "onedark", "Darker", "󰏘", "#61afef", function() require("onedark").setup({style="darker"}); require("onedark").load() end },
    { "onedark", "Cool", "󰏘", "#61afef", function() require("onedark").setup({style="cool"}); require("onedark").load() end },
    { "onedark", "Deep", "󰏘", "#61afef", function() require("onedark").setup({style="deep"}); require("onedark").load() end },
    { "onedark", "Warm", "󰏘", "#61afef", function() require("onedark").setup({style="warm"}); require("onedark").load() end },
    { "onedark", "Warmer", "󰏘", "#61afef", function() require("onedark").setup({style="warmer"}); require("onedark").load() end },
    { "onedark", "Light", "󰖙", "#61afef", function() require("onedark").setup({style="light"}); require("onedark").load() end },
}

-- ── Filter catalog to enabled families ──────────────────────
-- Tokyo Night and Gruvbox are always available. Other families
-- must appear in editor.colorschemes.families to be loaded.

local _rf_ok, _rf = pcall(require, "retrofox")

local always_on_families = { tokyonight = true, gruvbox = true }

local header_to_config_key = {
    ["Tokyo Night"]      = "tokyonight",
    ["Catppuccin"]       = "catppuccin",
    ["Kanagawa"]         = "kanagawa",
    ["Nightfox"]         = "nightfox",
    ["Rosé Pine"]        = "rose-pine",
    ["GitHub"]           = "github-nvim-theme",
    ["Everforest"]       = "everforest",
    ["Gruvbox"]          = "gruvbox",
    ["Gruvbox Material"] = "gruvbox-material",
    ["OneDark"]          = "onedark",
}

local function build_active_catalog()
    local enabled = {}
    if _rf_ok then
        local fam_list = _rf.get("editor.colorschemes.families")
        if type(fam_list) == "table" then
            for _, f in ipairs(fam_list) do
                enabled[f] = true
            end
        end
    end

    local result = {}
    local family_enabled = true
    for _, item in ipairs(catalog) do
        if item.header then
            local key = header_to_config_key[item.header]
            if not key or always_on_families[key] then
                family_enabled = true
            elseif not _rf_ok then
                family_enabled = true
            else
                family_enabled = enabled[key] == true
            end
        end
        if family_enabled then
            table.insert(result, item)
        end
    end
    return result
end

local active_catalog = build_active_catalog()

-- ── Persistence ─────────────────────────────────────────────
-- Uses config.yaml for persistence via the retrofox module.

-- Track the confirmed variant label for themes that share a colorscheme name
-- (e.g. all Everforest variants are "everforest" but differ by label)
local active_label = nil

local function read_persisted()
    if not _rf_ok then return nil end
    local raw = _rf.get("editor.colorschemes.active")
    if not raw then return nil end
    local name, label = raw:match("^([^:]+):(.+)$")
    if name then return { name = name, label = label } end
    return { name = raw, label = nil }
end

-- Initialize active_label from persisted data at require-time
local _persisted = read_persisted()
if _persisted and _persisted.label then
    active_label = _persisted.label
end

local function save_colorscheme(entry)
    active_label = entry[2]
    if _rf_ok then
        local val = entry[1]
        if entry[2] then val = val .. ":" .. entry[2] end
        _rf.set("editor.colorschemes.active", val)
    end
end

local function find_catalog_entry(name, label)
    for _, item in ipairs(active_catalog) do
        if not item.header and item[1] == name and item[2] == label then
            return item
        end
    end
    -- Fallback: match by name only (for themes without setup hooks)
    for _, item in ipairs(active_catalog) do
        if not item.header and item[1] == name then
            return item
        end
    end
    return nil
end

local function load_saved_colorscheme()
    local data = read_persisted()
    if not data or not data.name then return end

    active_label = data.label
    local entry = find_catalog_entry(data.name, data.label)
    if entry then
        if entry[5] then entry[5]() end
        pcall(vim.cmd.colorscheme, entry[1])
    else
        pcall(vim.cmd.colorscheme, data.name)
    end
end

-- ── Fuzzy matching ──────────────────────────────────────────

local function fuzzy_match(str, query)
    if not query or query == "" then return true end
    local qi = 1
    local s = str:lower()
    local q = query:lower()
    for i = 1, #s do
        if s:sub(i, i) == q:sub(qi, qi) then
            qi = qi + 1
            if qi > #q then return true end
        end
    end
    return false
end

local function matches_filter(item, filter)
    if not filter or filter == "" then return true end
    return fuzzy_match(item[1], filter) or fuzzy_match(item[2], filter)
end

-- ── Build display lines & index ─────────────────────────────

local function build_lines(filter)
    local lines = {}
    local entries = {}
    local active_cs = vim.g.colors_name or ""
    local idx = 0
    local total_themes = 0
    local visible_themes = 0

    -- Count total available themes
    for _, item in ipairs(active_catalog) do
        if not item.header then total_themes = total_themes + 1 end
    end

    -- Group catalog items by their header
    local current_header = nil
    local group_items = {}

    local function flush_group()
        if not current_header or #group_items == 0 then return end

        local visible = {}
        for _, gi in ipairs(group_items) do
            if matches_filter(gi, filter) then
                table.insert(visible, gi)
            end
        end
        -- Also match against the header name itself
        if filter and filter ~= "" and fuzzy_match(current_header, filter) then
            visible = group_items
        end
        if #visible > 0 then
            idx = idx + 1
            lines[idx] = ""
            entries[idx] = false
            idx = idx + 1
            lines[idx] = "   " .. current_header
            entries[idx] = false
            for _, vi in ipairs(visible) do
                local cs_name, label, icon = vi[1], vi[2], vi[3]
                -- For themes sharing a name (Everforest, Gruvbox etc.), match by label too
                local is_active = (cs_name == active_cs)
                    and (not vi[5] or active_label == label) -- no setup_fn → name match is enough
                local marker = is_active and " ✦" or "  "
                idx = idx + 1
                lines[idx] = string.format("  %s %s  %s · %s", marker, icon, label, cs_name)
                entries[idx] = vi
                visible_themes = visible_themes + 1
            end
        end
    end

    for _, item in ipairs(active_catalog) do
        if item.header then
            flush_group()
            current_header = item.header
            group_items = {}
        else
            table.insert(group_items, item)
        end
    end
    flush_group()

    -- Trailing blank
    idx = idx + 1
    lines[idx] = ""
    entries[idx] = false

    -- If filter produced no results, show a message
    if visible_themes == 0 then
        lines = { "", "   No matching themes", "" }
        entries = { false, false, false }
    end

    return lines, entries, visible_themes, total_themes
end

-- ── Adaptive highlight setup ────────────────────────────────
-- Derives picker colors from the active colorscheme's semantic groups
-- so the UI looks correct on both dark and light themes.

local ns = vim.api.nvim_create_namespace("theme_picker")

local function get_hl_attr(name, attr)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and hl and hl[attr] then
        return string.format("#%06x", hl[attr])
    end
    return nil
end

local function setup_highlights()
    local normal_bg = get_hl_attr("Normal", "bg") or "#1a1b26"
    local normal_fg = get_hl_attr("Normal", "fg") or "#c0caf5"
    local comment_fg = get_hl_attr("Comment", "fg") or "#565f89"
    local func_fg = get_hl_attr("Function", "fg") or "#7aa2f7"
    local string_fg = get_hl_attr("String", "fg") or "#9ece6a"
    local constant_fg = get_hl_attr("Constant", "fg") or "#ff9e64"
    local keyword_fg = get_hl_attr("Keyword", "fg") or "#c099ff"
    local special_fg = get_hl_attr("Special", "fg") or "#7dcfff"

    -- Compute a subtle cursor-line bg: blend normal_bg slightly toward fg
    local function hex_to_rgb(hex)
        hex = hex:gsub("#", "")
        return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
    end
    local function blend(bg_hex, fg_hex, alpha)
        local br, bg, bb = hex_to_rgb(bg_hex)
        local fr, fg_c, fb = hex_to_rgb(fg_hex)
        local r = math.floor(br + (fr - br) * alpha)
        local g = math.floor(bg + (fg_c - bg) * alpha)
        local b = math.floor(bb + (fb - bb) * alpha)
        return string.format("#%02x%02x%02x", r, g, b)
    end

    local cursor_bg = blend(normal_bg, normal_fg, 0.08)

    vim.api.nvim_set_hl(0, "ThemePickerTitle", { fg = keyword_fg, bold = true })
    vim.api.nvim_set_hl(0, "ThemePickerBorder", { fg = comment_fg })
    vim.api.nvim_set_hl(0, "ThemePickerHeader", { fg = constant_fg, bold = true, italic = true })
    vim.api.nvim_set_hl(0, "ThemePickerActive", { fg = string_fg, bold = true })
    vim.api.nvim_set_hl(0, "ThemePickerItem", { fg = normal_fg })
    vim.api.nvim_set_hl(0, "ThemePickerDim", { fg = comment_fg, italic = true })
    vim.api.nvim_set_hl(0, "ThemePickerCursorLine", { bg = cursor_bg, bold = true })
    vim.api.nvim_set_hl(0, "ThemePickerSearch", { fg = special_fg, bold = true })
    vim.api.nvim_set_hl(0, "ThemePickerSearchBorder", { fg = func_fg })
    vim.api.nvim_set_hl(0, "ThemePickerSearchPrompt", { fg = func_fg, bold = true })
end

local function apply_extmarks(buf, lines, entries)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

    for i, line in ipairs(lines) do
        local entry = entries[i]
        if not entry then
            if line ~= "" then
                vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
                    end_col = #line, hl_group = "ThemePickerHeader",
                })
            end
        else
            local active = vim.g.colors_name or ""
            if entry[1] == active then
                vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
                    end_col = #line, hl_group = "ThemePickerActive",
                })
            else
                local dot_pos = line:find("·")
                if dot_pos then
                    vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
                        end_col = dot_pos - 1, hl_group = "ThemePickerItem",
                    })
                    vim.api.nvim_buf_set_extmark(buf, ns, i - 1, dot_pos - 1, {
                        end_col = #line, hl_group = "ThemePickerDim",
                    })
                else
                    vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
                        end_col = #line, hl_group = "ThemePickerItem",
                    })
                end
            end
        end
    end
end

local function apply_accent_marks(buf, entries)
    for i, entry in ipairs(entries) do
        if entry then
            local accent = entry[4]
            local hl_name = "ThemePickerAccent_" .. i
            vim.api.nvim_set_hl(0, hl_name, { fg = accent })
            vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
                virt_text = { { "▎", hl_name } },
                virt_text_pos = "overlay",
            })
        end
    end
end

-- ── Open the picker ─────────────────────────────────────────

function M.open()
    setup_highlights()

    local lines, entries, vis, total = build_lines(nil)
    local original_cs = vim.g.colors_name or "default"
    local original_bg = vim.o.background
    local current_filter = nil

    -- Calculate window size
    local max_width = 0
    for _, l in ipairs(lines) do
        max_width = math.max(max_width, vim.fn.strdisplaywidth(l))
    end
    local width = math.max(max_width + 6, 48)
    local height = math.min(#lines, math.floor(vim.o.lines * 0.75))
    local win_row = math.floor((vim.o.lines - height) / 2)
    local win_col = math.floor((vim.o.columns - width) / 2)

    -- Create main results buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].filetype = "theme-picker"

    local function title_text()
        if current_filter and current_filter ~= "" then
            return string.format(" 󰏘  Choose Theme (%d of %d) ", vis, total)
        end
        return string.format(" 󰏘  Choose Theme (%d) ", total)
    end

    local function footer_text()
        if current_filter and current_filter ~= "" then
            return " 󰈬 \"" .. current_filter .. "\"  /search  <CR>apply  <Esc>cancel "
        end
        return " /search  <CR>apply  <Esc>cancel  ↑↓navigate "
    end

    -- Create floating window
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = win_row,
        col = win_col,
        style = "minimal",
        border = "rounded",
        title = title_text(),
        title_pos = "center",
        footer = footer_text(),
        footer_pos = "center",
    })

    vim.wo[win].cursorline = true
    vim.wo[win].winblend = 8
    vim.wo[win].winhighlight = "NormalFloat:Normal,FloatBorder:ThemePickerBorder,FloatTitle:ThemePickerTitle,FloatFooter:ThemePickerDim,CursorLine:ThemePickerCursorLine"

    -- Apply highlights
    apply_extmarks(buf, lines, entries)
    apply_accent_marks(buf, entries)

    local function preview_current()
        if not vim.api.nvim_win_is_valid(win) then return end
        local row = vim.api.nvim_win_get_cursor(win)[1]
        local entry = entries[row]
        if entry then
            if entry[5] then entry[5]() end
            pcall(vim.cmd.colorscheme, entry[1])
            setup_highlights()
            apply_extmarks(buf, lines, entries)
            apply_accent_marks(buf, entries)
        end
    end

    -- ── Refresh the picker with a filter ─────────────────────

    local function refresh(filter)
        current_filter = filter
        lines, entries, vis, total = build_lines(filter)

        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false

        -- Update window height to fit content
        local new_height = math.min(#lines, math.floor(vim.o.lines * 0.75))
        vim.api.nvim_win_set_config(win, {
            relative = "editor",
            width = width,
            height = new_height,
            row = math.floor((vim.o.lines - new_height) / 2),
            col = win_col,
            title = title_text(),
            title_pos = "center",
            footer = footer_text(),
            footer_pos = "center",
        })

        setup_highlights()
        apply_extmarks(buf, lines, entries)
        apply_accent_marks(buf, entries)

        -- Move cursor to first selectable entry
        for i = 1, #entries do
            if entries[i] then
                pcall(vim.api.nvim_win_set_cursor, win, { i, 0 })
                preview_current()
                return
            end
        end
    end

    -- Move cursor to first selectable line
    local function find_first_entry()
        for i, e in ipairs(entries) do
            if e then return i end
        end
        return 1
    end
    vim.api.nvim_win_set_cursor(win, { find_first_entry(), 0 })

    -- ── Live preview on cursor move ──────────────────────────

    local preview_group = vim.api.nvim_create_augroup("ThemePickerPreview", { clear = true })

    vim.api.nvim_create_autocmd("CursorMoved", {
        group = preview_group,
        buffer = buf,
        callback = preview_current,
    })

    -- ── Skip non-selectable lines ────────────────────────────

    local function skip_to_entry(direction)
        local row = vim.api.nvim_win_get_cursor(win)[1]
        local next_row = row + direction
        while next_row >= 1 and next_row <= #lines do
            if entries[next_row] then
                vim.api.nvim_win_set_cursor(win, { next_row, 0 })
                preview_current()
                return
            end
            next_row = next_row + direction
        end
        -- Wrap around
        if direction == 1 then
            for i = 1, #lines do
                if entries[i] then
                    vim.api.nvim_win_set_cursor(win, { i, 0 })
                    preview_current()
                    return
                end
            end
        else
            for i = #lines, 1, -1 do
                if entries[i] then
                    vim.api.nvim_win_set_cursor(win, { i, 0 })
                    preview_current()
                    return
                end
            end
        end
    end

    -- ── Keymaps ──────────────────────────────────────────────

    local search_win = nil
    local search_buf = nil

    local function close_search()
        if search_win and vim.api.nvim_win_is_valid(search_win) then
            vim.api.nvim_win_close(search_win, true)
        end
        search_win = nil
        search_buf = nil
    end

    local function close_picker()
        close_search()
        pcall(vim.api.nvim_del_augroup_by_id, preview_group)
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    local function restore_original()
        vim.o.background = original_bg
        pcall(vim.cmd.colorscheme, original_cs)
    end

    local map_opts = { buffer = buf, nowait = true, silent = true }

    -- Navigate (skip headers)
    vim.keymap.set("n", "j", function() skip_to_entry(1) end, map_opts)
    vim.keymap.set("n", "k", function() skip_to_entry(-1) end, map_opts)
    vim.keymap.set("n", "<Down>", function() skip_to_entry(1) end, map_opts)
    vim.keymap.set("n", "<Up>", function() skip_to_entry(-1) end, map_opts)
    vim.keymap.set("n", "<C-n>", function() skip_to_entry(1) end, map_opts)
    vim.keymap.set("n", "<C-p>", function() skip_to_entry(-1) end, map_opts)

    -- Confirm
    vim.keymap.set("n", "<CR>", function()
        local row = vim.api.nvim_win_get_cursor(win)[1]
        local entry = entries[row]
        close_picker()
        if entry then
            if entry[5] then entry[5]() end
            pcall(vim.cmd.colorscheme, entry[1])
            save_colorscheme(entry)
            vim.notify("  " .. entry[2] .. " (" .. entry[1] .. ")", vim.log.levels.INFO, { title = "Theme" })
        end
    end, map_opts)

    -- Cancel
    vim.keymap.set("n", "<Esc>", function()
        if current_filter and current_filter ~= "" then
            refresh(nil)
        else
            close_picker()
            restore_original()
        end
    end, map_opts)
    vim.keymap.set("n", "q", function()
        close_picker()
        restore_original()
    end, map_opts)

    -- ── Search mode ──────────────────────────────────────────

    local function open_search()
        search_buf = vim.api.nvim_create_buf(false, true)
        vim.bo[search_buf].bufhidden = "wipe"
        vim.bo[search_buf].buftype = "nofile"

        if current_filter and current_filter ~= "" then
            vim.api.nvim_buf_set_lines(search_buf, 0, -1, false, { current_filter })
        end

        local main_cfg = vim.api.nvim_win_get_config(win)
        search_win = vim.api.nvim_open_win(search_buf, true, {
            relative = "editor",
            width = width,
            height = 1,
            row = main_cfg.row - 3,
            col = win_col,
            style = "minimal",
            border = "rounded",
            title = " 󰍉  Search ",
            title_pos = "center",
        })

        vim.wo[search_win].winblend = 8
        vim.wo[search_win].winhighlight = "NormalFloat:Normal,FloatBorder:ThemePickerSearchBorder,FloatTitle:ThemePickerSearchPrompt"

        vim.cmd("startinsert!")

        local search_group = vim.api.nvim_create_augroup("ThemePickerSearch", { clear = true })

        local function on_text_change()
            if not search_buf or not vim.api.nvim_buf_is_valid(search_buf) then return end
            local text = vim.api.nvim_buf_get_lines(search_buf, 0, 1, false)[1] or ""
            refresh(text ~= "" and text or nil)
        end

        vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
            group = search_group,
            buffer = search_buf,
            callback = on_text_change,
        })

        local search_map = { buffer = search_buf, nowait = true, silent = true }

        vim.keymap.set("i", "<CR>", function()
            local text = vim.api.nvim_buf_get_lines(search_buf, 0, 1, false)[1] or ""
            vim.cmd("stopinsert")
            vim.api.nvim_del_augroup_by_id(search_group)
            close_search()
            refresh(text ~= "" and text or nil)
            vim.api.nvim_set_current_win(win)
        end, search_map)

        vim.keymap.set("i", "<Esc>", function()
            vim.cmd("stopinsert")
            vim.api.nvim_del_augroup_by_id(search_group)
            close_search()
            refresh(nil)
            vim.api.nvim_set_current_win(win)
        end, search_map)

        vim.keymap.set("i", "<C-n>", function()
            vim.api.nvim_set_current_win(win)
            skip_to_entry(1)
            vim.api.nvim_set_current_win(search_win)
        end, search_map)
        vim.keymap.set("i", "<C-p>", function()
            vim.api.nvim_set_current_win(win)
            skip_to_entry(-1)
            vim.api.nvim_set_current_win(search_win)
        end, search_map)
    end

    vim.keymap.set("n", "/", open_search, map_opts)

    -- Close on focus loss (but not when switching to search)
    vim.api.nvim_create_autocmd("WinLeave", {
        group = preview_group,
        buffer = buf,
        callback = function()
            vim.defer_fn(function()
                local cur_win = vim.api.nvim_get_current_win()
                if cur_win ~= win and cur_win ~= search_win then
                    close_picker()
                    restore_original()
                end
            end, 50)
        end,
    })
end

-- ── Auto-load saved colorscheme on startup ──────────────────
-- Load immediately at require-time (after lazy.nvim has loaded colorscheme
-- plugins with lazy=false, priority=1000) to avoid a visible flash on the
-- splash screen.

load_saved_colorscheme()

-- ── Vim command for convenience ─────────────────────────────

vim.api.nvim_create_user_command("ThemePicker", function() M.open() end, { desc = "Open the theme picker" })

return M
