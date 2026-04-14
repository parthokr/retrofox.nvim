-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Module: Lean 4 (lean.nvim + lean-language-server)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Prerequisite: install elan (Lean toolchain manager)
--   curl https://elan.lean-lang.org/elan-init.sh -sSf | sh
--
-- The LSP (lean-language-server) ships with elan — no Mason needed.
-- lean.nvim handles LSP setup, the infoview panel, and filetype detection.

if not require("retrofox.module").enabled("lean") then
    return {}
end

return {
    "Julian/lean.nvim",
    event = { "BufReadPre *.lean", "BufNewFile *.lean" },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
        -- Enable default Lean keybindings (<LocalLeader> prefix)
        mappings = true,
        -- Infoview: the goal/tactic state window
        infoview = {
            autoopen = true,
            autopause = false,
            width = 50,
            indicators = "always",
        },
        -- LSP settings passed to the Lean language server
        lsp = {
            init_options = {
                editDelay = 200,
            },
        },
    },
}
