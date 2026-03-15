return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        local hooks = require("ibl.hooks")

        -- ── Colorscheme-reactive highlight groups ───────────────
        -- Pulls hues from the active colorscheme so guides always
        -- feel native, not pasted-on.

        local indent_hls = {
            "IblIndent1",
            "IblIndent2",
            "IblIndent3",
            "IblIndent4",
            "IblIndent5",
            "IblIndent6",
        }

        local scope_hls = {
            "IblScope1",
            "IblScope2",
            "IblScope3",
            "IblScope4",
            "IblScope5",
            "IblScope6",
        }

        -- Utility: read fg from a highlight group
        local function get_fg(name)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            return ok and hl.fg and string.format("#%06x", hl.fg) or nil
        end

        local function get_bg(name)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            return ok and hl.bg and string.format("#%06x", hl.bg) or nil
        end

        -- Blend two hex colors: t=0→c1, t=1→c2
        local function blend(c1, c2, t)
            local function hex(s) return tonumber(s, 16) end
            c1, c2 = c1:gsub("#", ""), c2:gsub("#", "")
            local r = math.floor(hex(c1:sub(1, 2)) * (1 - t) + hex(c2:sub(1, 2)) * t)
            local g = math.floor(hex(c1:sub(3, 4)) * (1 - t) + hex(c2:sub(3, 4)) * t)
            local b = math.floor(hex(c1:sub(5, 6)) * (1 - t) + hex(c2:sub(5, 6)) * t)
            return string.format("#%02x%02x%02x", r, g, b)
        end

        -- Build indent + scope colors from the active colorscheme
        local function set_highlights()
            local bg = get_bg("Normal") or "#1a1b26"

            -- Source accent colors from semantic highlight groups
            local accents = {
                get_fg("Function")    or "#7aa2f7",   -- blue
                get_fg("Keyword")     or "#bb9af7",   -- purple
                get_fg("String")      or "#9ece6a",   -- green
                get_fg("Type")        or "#2ac3de",   -- cyan
                get_fg("Constant")    or "#ff9e64",   -- orange
                get_fg("Special")     or "#f7768e",   -- pink
            }

            for i, accent in ipairs(accents) do
                -- Indent guides: very subtle — accent blended heavily toward bg
                vim.api.nvim_set_hl(0, indent_hls[i], { fg = blend(bg, accent, 0.15) })
                -- Scope: brighter — accent blended lightly toward bg
                vim.api.nvim_set_hl(0, scope_hls[i], { fg = blend(bg, accent, 0.55) })
            end
        end

        hooks.register(hooks.type.HIGHLIGHT_SETUP, set_highlights)
        hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

        -- ── Setup ───────────────────────────────────────────────
        require("ibl").setup({
            indent = {
                char = "│",                       -- clean, minimal line
                highlight = indent_hls,           -- rainbow gradient (subtle)
                smart_indent_cap = true,
            },
            scope = {
                enabled = true,
                char = "│",
                highlight = scope_hls,            -- rainbow scope (brighter)
                show_start = false,               -- no underline clutter
                show_end = false,
                show_exact_scope = true,
                include = {
                    node_type = {
                        ["*"] = { "*" },
                    },
                },
            },
            whitespace = {
                remove_blankline_trail = true,
            },
            exclude = {
                filetypes = {
                    "help",
                    "alpha",
                    "dashboard",
                    "neo-tree",
                    "Trouble",
                    "lazy",
                    "mason",
                    "notify",
                    "toggleterm",
                    "oil",
                },
            },
        })
    end,
}
