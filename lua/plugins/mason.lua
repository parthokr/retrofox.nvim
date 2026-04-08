return {
    {
        "williamboman/mason.nvim",
        config = function()
            local mod = require("retrofox.module")

            require("mason").setup()

            -- ── All tools: LSP servers + formatters + linters + DAP ──
            -- Mason registry handles everything uniformly.
            -- Your modules already call vim.lsp.config[] + vim.lsp.enable()
            -- so we only need Mason to *install* the binaries.
            local tools = { "lua-language-server", "bash-language-server", "stylua" }

            if mod.enabled("python") then
                vim.list_extend(tools, { "basedpyright", "ruff", "isort", "debugpy" })
            end
            if mod.enabled("typescript") then
                vim.list_extend(tools, { "typescript-language-server", "eslint-lsp", "prettier" })
            end
            if mod.enabled("go") then
                table.insert(tools, "gopls")
            end
            if mod.enabled("cpp") then
                vim.list_extend(tools, { "clangd", "clang-format", "codelldb" })
            end
            if mod.enabled("rust") then
                table.insert(tools, "rust-analyzer")
            end
            if mod.enabled("java") then
                vim.list_extend(tools, { "jdtls", "google-java-format" })
            end
            if mod.enabled("docker") then
                vim.list_extend(tools, { "dockerfile-language-server", "hadolint" })
            end
            if mod.enabled("json") then
                vim.list_extend(tools, { "json-lsp", "jsonlint", "prettier" })
            end
            if mod.enabled("markdown") then
                vim.list_extend(tools, { "markdownlint-cli2", "prettier" })
            end

            -- Deduplicate
            local seen = {}
            local unique = {}
            for _, t in ipairs(tools) do
                if not seen[t] then
                    seen[t] = true
                    table.insert(unique, t)
                end
            end

            -- Deferred install of all tools
            vim.defer_fn(function()
                local registry = require("mason-registry")
                registry.refresh(function()
                    for _, name in ipairs(unique) do
                        local ok, pkg = pcall(registry.get_package, name)
                        if ok and not pkg:is_installed() then
                            pkg:install()
                        end
                    end
                end)
            end, 2000)
        end,
    },
}
