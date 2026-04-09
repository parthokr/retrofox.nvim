-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Module: Copilot
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not require("retrofox.module").enabled("copilot") then
    return {}
end

return {
    "github/copilot.vim",
    event = "InsertEnter",
    init = function()
        -- Disable copilot's default Tab mapping so we control it via blink-cmp
        vim.g.copilot_no_tab_map = true

        -- Accept with Ctrl-j as a reliable fallback that never conflicts
        vim.keymap.set("i", "<C-j>", 'copilot#Accept("\\<CR>")', {
            expr = true,
            replace_keycodes = false,
            silent = true,
            desc = "Accept Copilot suggestion",
        })

        -- Cycle through suggestions
        vim.keymap.set("i", "<M-]>", "<Plug>(copilot-next)", { desc = "Next Copilot suggestion" })
        vim.keymap.set("i", "<M-[>", "<Plug>(copilot-previous)", { desc = "Prev Copilot suggestion" })

        -- Dismiss suggestion
        vim.keymap.set("i", "<C-e>", "<Plug>(copilot-dismiss)", { desc = "Dismiss Copilot suggestion" })
    end,
}
