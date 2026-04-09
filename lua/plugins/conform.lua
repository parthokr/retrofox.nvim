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
            if val ~= nil then
                format_on_save = val
            end
        end

        -- Build formatters_by_ft based on enabled modules
        local formatters = {
            lua = { "stylua" },
        }
        if mod.enabled("cpp") then
            formatters.c = { "clang-format" }
            formatters.cpp = { "clang-format" }
        end
        if mod.enabled("go") then
            formatters.go = { "gofmt" }
        end
        if mod.enabled("python") then
            formatters.python = { "isort", "ruff_format" }
        end
        -- We omit 'google-java-format' so Java falls back to JDTLS default formatting
        -- which respects 4 spaces / standard editor tab settings instead of forcing 2 spaces.
        if mod.enabled("typescript") then
            formatters.javascript = { "prettier" }
            formatters.typescript = { "prettier" }
            formatters.typescriptreact = { "prettier" }
            formatters.javascriptreact = { "prettier" }
            formatters.css = { "prettier" }
            formatters.html = { "prettier" }
        end
        if mod.enabled("json") then
            formatters.json = { "prettier" }
        end
        if mod.enabled("markdown") then
            formatters.markdown = { "prettier" }
        end
        -- YAML formatting stays enabled by default.
        formatters.yaml = { "prettier" }

        -- Read tab_width from config (same source as core/options.lua)
        local tab_width = 4
        if ok_rf then
            local tw = rf.get("editor.tab_width")
            if tw ~= nil then
                tab_width = tw
            end
        end

        return {
            notify_on_error = false,
            format_on_save = format_on_save and function(bufnr)
                return {
                    timeout_ms = 500,
                    lsp_format = "fallback",
                }
            end or nil,
            formatters_by_ft = formatters,
            formatters = {
                stylua = {
                    prepend_args = {
                        "--indent-type",
                        "Spaces",
                        "--indent-width",
                        tostring(tab_width),
                    },
                },
                ["clang-format"] = {
                    prepend_args = {
                        "--style",
                        "{UseTab: Never, IndentWidth: " .. tostring(tab_width) .. "}",
                    },
                },
            },
        }
    end,
}
