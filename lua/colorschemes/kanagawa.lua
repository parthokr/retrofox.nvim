return {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    lazy = false,
    config = function()
        require("kanagawa").setup({
            compile = true,
            transparent = false,
            dimInactive = true,
            terminalColors = true,
            theme = "wave",
            background = { dark = "wave", light = "lotus" },
            styles = {
                comments = { italic = true },
                keywords = { bold = true, italic = true },
                functions = { bold = true },
                variables = {},
                types = { italic = true },
            },
            overrides = function(c)
                local palette = c.palette
                local theme = c.theme
                return {
                    -- Markdown (kept from original)
                    ["@markup.link.url.markdown_inline"] = { link = "Special" },
                    ["@markup.link.label.markdown_inline"] = { link = "WarningMsg" },
                    ["@markup.italic.markdown_inline"] = { link = "Exception" },
                    ["@markup.raw.markdown_inline"] = { link = "String" },
                    ["@markup.list.markdown"] = { link = "Function" },
                    ["@markup.quote.markdown"] = { link = "Error" },
                    ["@markup.list.checked.markdown"] = { link = "WarningMsg" },
                    -- Float windows blend with editor
                    NormalFloat = { bg = theme.ui.bg_p1 },
                    FloatBorder = { bg = theme.ui.bg_p1, fg = palette.sumiInk4 },
                    FloatTitle = { bg = theme.ui.bg_p1, fg = palette.springGreen, bold = true },
                    -- Popup menu
                    Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
                    PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
                    PmenuSbar = { bg = theme.ui.bg_m1 },
                    PmenuThumb = { bg = theme.ui.bg_p2 },
                    -- Undercurl diagnostics
                    DiagnosticUnderlineError = { undercurl = true, sp = palette.samuraiRed },
                    DiagnosticUnderlineWarn = { undercurl = true, sp = palette.roninYellow },
                    DiagnosticUnderlineInfo = { undercurl = true, sp = palette.waveAqua1 },
                    DiagnosticUnderlineHint = { undercurl = true, sp = palette.dragonBlue },
                }
            end,
        })

        -- Apply Noice highlights dynamically after any kanagawa variant loads.
        -- This bypasses kanagawa's compile cache so no KanagawaCompile is needed.
        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "kanagawa",
            group = vim.api.nvim_create_augroup("KanagawaNoice", { clear = true }),
            callback = function()
                -- Read live theme colors from the current kanagawa variant
                local ok, colors = pcall(require("kanagawa.colors").setup, {
                    theme = require("kanagawa")._CURRENT_THEME or "wave",
                    colors = require("kanagawa").config.colors,
                })
                if not ok then
                    return
                end

                local theme = colors.theme
                local bg = theme.ui.bg_p1
                local set = vim.api.nvim_set_hl

                -- Cmdline popup
                set(0, "NoiceCmdline", { fg = theme.ui.fg, bg = bg })
                set(0, "NoiceCmdlinePopup", { fg = theme.ui.fg, bg = bg })
                set(0, "NoiceCmdlinePopupBorder", { fg = theme.ui.float.fg_border, bg = bg })
                set(0, "NoiceCmdlinePopupTitle", { fg = theme.syn.fun, bg = bg, bold = true })
                -- Per-kind borders
                set(0, "NoiceCmdlinePopupBorderCmdline", { fg = theme.syn.fun, bg = bg })
                set(0, "NoiceCmdlinePopupBorderSearch", { fg = theme.diag.warning, bg = bg })
                set(0, "NoiceCmdlinePopupBorderFilter", { fg = theme.diag.info, bg = bg })
                set(0, "NoiceCmdlinePopupBorderLua", { fg = theme.syn.keyword, bg = bg })
                set(0, "NoiceCmdlinePopupBorderHelp", { fg = theme.diag.ok, bg = bg })
                -- Per-kind icons
                set(0, "NoiceCmdlineIconCmdline", { fg = theme.syn.fun })
                set(0, "NoiceCmdlineIconSearch", { fg = theme.diag.warning })
                set(0, "NoiceCmdlineIconFilter", { fg = theme.diag.info })
                set(0, "NoiceCmdlineIconLua", { fg = theme.syn.keyword })
                set(0, "NoiceCmdlineIconHelp", { fg = theme.diag.ok })
                -- Popupmenu
                set(0, "NoicePopupmenu", { fg = theme.ui.fg, bg = bg })
                set(0, "NoicePopupmenuBorder", { fg = theme.ui.float.fg_border, bg = bg })
                set(0, "NoicePopupmenuSelected", { bg = theme.ui.bg_p2 })
                set(0, "NoicePopupmenuMatch", { fg = theme.syn.fun, bold = true })
            end,
        })
    end,
    build = function()
        -- KanagawaCompile may not exist during headless Lazy sync on fresh installs
        pcall(vim.cmd, "KanagawaCompile")
    end,
}
