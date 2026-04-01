return {
    "sainnhe/gruvbox-material",
    priority = 1000,
    lazy = false,
    config = function()
        vim.g.gruvbox_material_background = "hard"
        vim.g.gruvbox_material_foreground = "mix"
        vim.g.gruvbox_material_enable_italic = 1
        vim.g.gruvbox_material_enable_bold = 1
        vim.g.gruvbox_material_dim_inactive_windows = 1
        vim.g.gruvbox_material_diagnostic_text_highlight = 1
        vim.g.gruvbox_material_diagnostic_line_highlight = 1
        vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
        vim.g.gruvbox_material_better_performance = 1
        vim.g.gruvbox_material_ui_contrast = "high"
        vim.g.gruvbox_material_float_style = "dim"
        -- Available palettes: material, mix, original
        -- Available backgrounds: hard, medium, soft
    end,
}
