return {
    "akinsho/bufferline.nvim",
    dependencies = {
        "moll/vim-bbye",
    },
    config = function()
        local utils = require("core.utils")

        -- ── Colorscheme-reactive highlights ─────────────────────
        local function get_hl(name, attr)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            if ok and hl[attr] then return string.format("#%06x", hl[attr]) end
            return nil
        end

        local function darken(hex, amount)
            local r = math.max(0, tonumber(hex:sub(2, 3), 16) - amount)
            local g = math.max(0, tonumber(hex:sub(4, 5), 16) - amount)
            local b = math.max(0, tonumber(hex:sub(6, 7), 16) - amount)
            return string.format("#%02x%02x%02x", r, g, b)
        end

        local function lighten(hex, amount)
            local r = math.min(255, tonumber(hex:sub(2, 3), 16) + amount)
            local g = math.min(255, tonumber(hex:sub(4, 5), 16) + amount)
            local b = math.min(255, tonumber(hex:sub(6, 7), 16) + amount)
            return string.format("#%02x%02x%02x", r, g, b)
        end

        local function build_highlights()
            local bg = get_hl("Normal", "bg") or "#1a1b26"
            local sep_fg = lighten(bg, 30)
            local fill_bg = darken(bg, 12)
            return {
                separator = { fg = sep_fg },
                buffer_selected = { bold = true, italic = false },
                fill = { bg = fill_bg },
            }
        end

        local function setup_bufferline()
            require("bufferline").setup({
                options = {
                    mode = "buffers",
                    themable = true,
                    name_formatter = function(buf)
                        local path = buf.path or ""
                        if path:match("^jdt://") then
                            local decoded = utils.uri_decode(path)
                            return decoded:match("%(([^%(%)]+%.class)") or decoded:match("([^/]+)$") or buf.name
                        end
                        return buf.name
                    end,
                    numbers = "none",
                    close_command = "Bdelete! %d",
                    buffer_close_icon = "✗",
                    close_icon = "✗",
                    path_components = 1,
                    modified_icon = "●",
                    left_trunc_marker = "",
                    right_trunc_marker = "",
                    max_name_length = 30,
                    max_prefix_length = 30,
                    tab_size = 21,
                    diagnostics = false,
                    diagnostics_update_in_insert = false,
                    color_icons = true,
                    show_buffer_icons = true,
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    persist_buffer_sort = true,
                    separator_style = { "│", "│" },
                    enforce_regular_tabs = true,
                    always_show_bufferline = false,
                    show_tab_indicators = false,
                    indicator = {
                        style = "none",
                    },
                    icon_pinned = "󰐃",
                    minimum_padding = 1,
                    maximum_padding = 5,
                    maximum_length = 15,
                    sort_by = "insert_at_end",
                },
                highlights = build_highlights(),
            })
        end

        setup_bufferline()

        -- Re-derive colors on colorscheme change
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("BufferlineThemeSync", { clear = true }),
            callback = function()
                vim.defer_fn(setup_bufferline, 0)
            end,
        })
    end,
}
