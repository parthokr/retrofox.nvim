return {
    "akinsho/bufferline.nvim",
    dependencies = {
        "moll/vim-bbye",
    },
    config = function()
        local utils = require("core.utils")

        -- ── Color helpers ───────────────────────────────────────
        local function get_hl(name, attr)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            if ok and hl[attr] then return string.format("#%06x", hl[attr]) end
            return nil
        end

        local function hex_to_rgb(hex)
            hex = hex:gsub("#", "")
            return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
        end

        local function darken(hex, amount)
            local r, g, b = hex_to_rgb(hex)
            return string.format("#%02x%02x%02x",
                math.max(0, r - amount), math.max(0, g - amount), math.max(0, b - amount))
        end

        local function lighten(hex, amount)
            local r, g, b = hex_to_rgb(hex)
            return string.format("#%02x%02x%02x",
                math.min(255, r + amount), math.min(255, g + amount), math.min(255, b + amount))
        end

        local function blend(c1, c2, t)
            local r1, g1, b1 = hex_to_rgb(c1)
            local r2, g2, b2 = hex_to_rgb(c2)
            return string.format("#%02x%02x%02x",
                math.floor(r1 + (r2 - r1) * t),
                math.floor(g1 + (g2 - g1) * t),
                math.floor(b1 + (b2 - b1) * t))
        end

        -- ── Derive palette from active colorscheme ──────────────
        local function build_highlights()
            local bg      = get_hl("Normal", "bg")        or "#1a1b26"
            local fg      = get_hl("Normal", "fg")        or "#c0caf5"
            local dim     = get_hl("Comment", "fg")       or "#565f89"
            local accent  = get_hl("Function", "fg")      or "#7aa2f7"
            local green   = get_hl("String", "fg")        or "#9ece6a"
            local red     = get_hl("DiagnosticError", "fg") or "#f7768e"
            local yellow  = get_hl("DiagnosticWarn", "fg")  or "#e0af68"

            -- Derived tones
            local fill_bg    = darken(bg, 8)               -- darkest: the empty bar area
            local tab_bg     = blend(bg, fill_bg, 0.5)     -- inactive tab: slightly darker than editor
            local sel_bg     = bg                           -- selected tab: matches editor exactly
            local sep_fg     = blend(fill_bg, dim, 0.15)   -- barely-visible separators
            local dim_fg     = blend(bg, dim, 0.6)         -- inactive text: faded
            local mod_fg     = yellow                       -- modified dot
            local sel_ind    = accent                       -- active indicator underline

            return {
                -- ── Fill (empty bar background) ─────────────────
                fill                        = { bg = fill_bg },

                -- ── Background (inactive tabs) ──────────────────
                background                  = { fg = dim_fg, bg = tab_bg },

                -- ── Buffers ─────────────────────────────────────
                buffer_visible              = { fg = dim, bg = tab_bg },
                buffer_selected             = { fg = fg, bg = sel_bg, bold = true, italic = false },

                -- ── Close buttons ───────────────────────────────
                close_button                = { fg = blend(tab_bg, dim, 0.4), bg = tab_bg },
                close_button_visible        = { fg = dim, bg = tab_bg },
                close_button_selected       = { fg = red, bg = sel_bg },

                -- ── Modified indicator ──────────────────────────
                modified                    = { fg = blend(tab_bg, mod_fg, 0.5), bg = tab_bg },
                modified_visible            = { fg = mod_fg, bg = tab_bg },
                modified_selected           = { fg = mod_fg, bg = sel_bg },

                -- ── Duplicate labels ────────────────────────────
                duplicate                   = { fg = dim_fg, bg = tab_bg, italic = true },
                duplicate_visible           = { fg = dim, bg = tab_bg, italic = true },
                duplicate_selected          = { fg = blend(fg, dim, 0.3), bg = sel_bg, italic = true },

                -- ── Separators ──────────────────────────────────
                separator                   = { fg = sep_fg, bg = tab_bg },
                separator_visible           = { fg = sep_fg, bg = tab_bg },
                separator_selected          = { fg = sep_fg, bg = sel_bg },

                -- ── Active indicator (underline accent) ─────────
                indicator_visible           = { fg = blend(tab_bg, sel_ind, 0.3), bg = tab_bg },
                indicator_selected          = { fg = sel_ind, bg = sel_bg },

                -- ── Tab pages ───────────────────────────────────
                tab                         = { fg = dim_fg, bg = tab_bg },
                tab_selected                = { fg = fg, bg = sel_bg, bold = true },
                tab_separator               = { fg = sep_fg, bg = tab_bg },
                tab_separator_selected      = { fg = sel_ind, bg = sel_bg },
                tab_close                   = { fg = red, bg = tab_bg },

                -- ── Diagnostics (inline in tabs) ────────────────
                error                       = { fg = blend(tab_bg, red, 0.5), bg = tab_bg },
                error_visible               = { fg = red, bg = tab_bg },
                error_selected              = { fg = red, bg = sel_bg, bold = true },
                error_diagnostic            = { fg = blend(tab_bg, red, 0.4), bg = tab_bg },
                error_diagnostic_visible    = { fg = red, bg = tab_bg },
                error_diagnostic_selected   = { fg = red, bg = sel_bg },

                warning                     = { fg = blend(tab_bg, yellow, 0.5), bg = tab_bg },
                warning_visible             = { fg = yellow, bg = tab_bg },
                warning_selected            = { fg = yellow, bg = sel_bg, bold = true },
                warning_diagnostic          = { fg = blend(tab_bg, yellow, 0.4), bg = tab_bg },
                warning_diagnostic_visible  = { fg = yellow, bg = tab_bg },
                warning_diagnostic_selected = { fg = yellow, bg = sel_bg },

                hint                        = { fg = blend(tab_bg, green, 0.5), bg = tab_bg },
                hint_visible                = { fg = green, bg = tab_bg },
                hint_selected               = { fg = green, bg = sel_bg },
                hint_diagnostic             = { fg = blend(tab_bg, green, 0.4), bg = tab_bg },
                hint_diagnostic_visible     = { fg = green, bg = tab_bg },
                hint_diagnostic_selected    = { fg = green, bg = sel_bg },

                -- ── Truncation markers ──────────────────────────
                trunc_marker                = { fg = dim, bg = fill_bg },

                -- ── Offset (sidebars like neo-tree) ─────────────
                offset_separator            = { fg = sep_fg, bg = fill_bg },

                -- ── Numbers ─────────────────────────────────────
                numbers                     = { fg = dim_fg, bg = tab_bg },
                numbers_visible             = { fg = dim, bg = tab_bg },
                numbers_selected            = { fg = accent, bg = sel_bg, bold = true },

                -- ── Pick letters ────────────────────────────────
                pick                        = { fg = red, bg = tab_bg, bold = true },
                pick_visible                = { fg = red, bg = tab_bg, bold = true },
                pick_selected               = { fg = red, bg = sel_bg, bold = true },
            }
        end

        local function setup_bufferline()
            require("bufferline").setup({
                options = {
                    mode = "buffers",
                    style_preset = require("bufferline").style_preset.minimal,
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
                    buffer_close_icon = "",
                    close_icon = "",
                    path_components = 1,
                    modified_icon = "●",
                    left_trunc_marker = "◂",
                    right_trunc_marker = "▸",
                    max_name_length = 24,
                    max_prefix_length = 16,
                    tab_size = 20,
                    diagnostics = "nvim_lsp",
                    diagnostics_update_in_insert = false,
                    ---@param count integer
                    ---@param level string
                    diagnostics_indicator = function(count, level)
                        local icons = { error = " ", warning = " ", hint = "󰌵 " }
                        return (icons[level] or "") .. count
                    end,
                    color_icons = true,
                    show_buffer_icons = true,
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    show_duplicate_prefix = true,
                    persist_buffer_sort = true,
                    separator_style = "thin",
                    enforce_regular_tabs = false,
                    always_show_bufferline = false,
                    show_tab_indicators = true,
                    indicator = {
                        icon = "▎",
                        style = "icon",
                    },
                    icon_pinned = "󰐃",
                    minimum_padding = 1,
                    maximum_padding = 3,
                    sort_by = "insert_at_end",

                    -- ── Sidebar offset for neo-tree ─────────────
                    offsets = {
                        {
                            filetype = "neo-tree",
                            text = " Files",
                            text_align = "left",
                            separator = true,
                            highlight = "Directory",
                        },
                    },

                    -- ── Hover actions ────────────────────────────
                    hover = {
                        enabled = true,
                        delay = 100,
                        reveal = { "close" },
                    },
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
