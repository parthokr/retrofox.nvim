-- nvim-treesitter-textobjects (main branch) — requires nvim-treesitter main
--
-- The new API (main branch):
--   • Options:  require("nvim-treesitter-textobjects").setup { select = {…}, … }
--   • Keymaps:  vim.keymap.set calling select_textobject / swap_next directly
--   Sub-modules do NOT have a .setup(); calling it was the previous error.
return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = {
        { "nvim-treesitter/nvim-treesitter", branch = "main" },
    },
    config = function()
        local ok, tso = pcall(require, "nvim-treesitter-textobjects")
        if not ok then
            return
        end

        -- Global options (select behaviour, move jump-list, etc.)
        tso.setup({
            select = {
                lookahead = true,
                selection_modes = {
                    ["@parameter.outer"] = "v",
                    ["@function.outer"] = "V",
                    ["@class.outer"] = "<c-v>",
                },
                include_surrounding_whitespace = true,
            },
        })

        -- ── Select keymaps ────────────────────────────────────────
        local sel = require("nvim-treesitter-textobjects.select")
        local select_map = {
            ["af"] = { "@function.outer", "textobjects" },
            ["if"] = { "@function.inner", "textobjects" },
            ["ac"] = { "@class.outer", "textobjects" },
            ["ic"] = { "@class.inner", "textobjects" },
            ["ao"] = { "@comment.outer", "textobjects" },
            ["as"] = { "@local.scope", "locals" },
        }
        for key, args in pairs(select_map) do
            vim.keymap.set({ "x", "o" }, key, function()
                sel.select_textobject(args[1], args[2])
            end, { desc = "TS select " .. args[1] })
        end

        -- ── Swap keymaps ──────────────────────────────────────────
        local swap = require("nvim-treesitter-textobjects.swap")
        vim.keymap.set("n", "<leader>a", function()
            swap.swap_next("@parameter.inner")
        end, { desc = "Swap with next parameter" })
        vim.keymap.set("n", "<leader>A", function()
            swap.swap_previous("@parameter.inner")
        end, { desc = "Swap with previous parameter" })
    end,
}
