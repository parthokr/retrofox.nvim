return {
    {
        "williamboman/mason.nvim",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            local mod = require("retrofox.module")

            -- Core servers (always installed)
            local servers = { "lua_ls", "bashls" }

            -- Auto-add servers based on enabled modules
            if mod.enabled("python") then table.insert(servers, "basedpyright") end
            if mod.enabled("typescript") then
                table.insert(servers, "ts_ls")
                table.insert(servers, "eslint")
            end
            if mod.enabled("go") then table.insert(servers, "gopls") end
            if mod.enabled("cpp") then table.insert(servers, "clangd") end
            if mod.enabled("rust") then table.insert(servers, "rust_analyzer") end
            if mod.enabled("java") then table.insert(servers, "jdtls") end
            if mod.enabled("docker") then table.insert(servers, "dockerls") end
            if mod.enabled("json") then table.insert(servers, "jsonls") end

            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = servers,
                automatic_enable = {
                    exclude = { "jdtls", "gradle_ls" },
                },
                automatic_installation = true,
            })

            -- ── Non-LSP tools (formatters, linters, DAP) ────────
            -- Mason-lspconfig only handles LSP servers.
            -- Formatters, linters, and DAP adapters must be installed separately.
            local tools = { "stylua" } -- always useful

            if mod.enabled("python") then
                vim.list_extend(tools, { "ruff", "isort", "debugpy" })
            end
            if mod.enabled("cpp") then
                vim.list_extend(tools, { "clang-format", "codelldb" })
            end
            if mod.enabled("java") then
                table.insert(tools, "google-java-format")
            end
            if mod.enabled("typescript") then
                table.insert(tools, "prettier")
            end
            if mod.enabled("json") then
                vim.list_extend(tools, { "jsonlint", "prettier" })
            end
            if mod.enabled("markdown") then
                vim.list_extend(tools, { "markdownlint-cli2", "prettier" })
            end
            if mod.enabled("docker") then
                table.insert(tools, "hadolint")
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

            -- Deferred install of non-LSP tools
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
