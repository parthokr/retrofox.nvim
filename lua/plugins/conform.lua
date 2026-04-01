return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>cf",
            function()
                require("conform").format({ async = true, lsp_format = "fallback" })
            end,
            mode = "",
            desc = "[F]ormat buffer",
        },
    },
    opts = function()
        local mod = require("retrofox.module")

        -- Only read format_on_save from config
        local format_on_save = true
        local ok_rf, rf = pcall(require, "retrofox")
        if ok_rf then
            local val = rf.get("editor.format_on_save")
            if val ~= nil then format_on_save = val end
        end

        -- Build formatters_by_ft based on enabled modules
        local formatters = {
            lua = { "stylua" },
        }
        if mod.enabled("cpp") then
            formatters.c = { "clang-format" }
            formatters.cpp = { "clang-format" }
        end
        if mod.enabled("go") then formatters.go = { "gofmt" } end
        if mod.enabled("python") then formatters.python = { "isort", "ruff_format" } end
        if mod.enabled("java") then formatters.java = { "google-java-format" } end
        if mod.enabled("typescript") then
            formatters.javascript = { "prettier" }
            formatters.typescript = { "prettier" }
            formatters.typescriptreact = { "prettier" }
            formatters.javascriptreact = { "prettier" }
            formatters.css = { "prettier" }
            formatters.html = { "prettier" }
        end
        if mod.enabled("json") then formatters.json = { "prettier" } end
        if mod.enabled("markdown") then formatters.markdown = { "prettier" } end
        -- YAML formatting stays enabled by default.
        formatters.yaml = { "prettier" }

        return {
            notify_on_error = false,
            format_on_save = format_on_save and function(bufnr)
                return {
                    timeout_ms = 500,
                    lsp_format = "fallback",
                }
            end or nil,
            formatters_by_ft = formatters,
        }
    end,
}
