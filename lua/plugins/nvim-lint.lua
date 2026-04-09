return {
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")
            local mod = require("retrofox.module")

            -- Build linters_by_ft based on enabled modules
            local linters = {}
            if mod.enabled("python") then
                linters.python = { "ruff" }
            end
            if mod.enabled("json") then
                linters.json = { "jsonlint" }
            end
            if mod.enabled("markdown") then
                linters.markdown = { "markdownlint-cli2" }
            end
            if mod.enabled("docker") then
                linters.dockerfile = { "hadolint" }
            end

            lint.linters_by_ft = linters

            local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                group = lint_augroup,
                callback = function()
                    if vim.opt_local.modifiable:get() then
                        lint.try_lint()
                    end
                end,
            })
        end,
    },
}
