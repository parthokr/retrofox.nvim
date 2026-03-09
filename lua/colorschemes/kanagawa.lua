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
    end,
    build = function()
        vim.cmd("KanagawaCompile")
    end,
}
