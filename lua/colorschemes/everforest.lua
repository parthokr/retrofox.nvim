return {
    "sainnhe/everforest",
    priority = 1000,
    lazy = false,
    config = function()
        vim.g.everforest_background = "medium"
        vim.g.everforest_enable_italic = 1
        vim.g.everforest_enable_bold = 1
        vim.g.everforest_dim_inactive_windows = 1
        vim.g.everforest_diagnostic_text_highlight = 1
        vim.g.everforest_diagnostic_line_highlight = 1
        vim.g.everforest_diagnostic_virtual_text = "colored"
        vim.g.everforest_better_performance = 1
        vim.g.everforest_ui_contrast = "high"
        vim.g.everforest_float_style = "dim"
        -- Available backgrounds: hard, medium, soft
    end,
}
