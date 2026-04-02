-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Module: TypeScript / JavaScript (ts_ls + eslint)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not require("retrofox.module").enabled("typescript") then return {} end

-- ── LSP: ts_ls ──────────────────────────────────────────────

local inlayHints = {
    includeInlayParameterNameHints = "all",
    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
    includeInlayFunctionParameterTypeHints = true,
    includeInlayVariableTypeHints = true,
    includeInlayPropertyDeclarationTypeHints = true,
    includeInlayFunctionLikeReturnTypeHints = true,
    includeInlayEnumMemberValueHints = true,
}

vim.lsp.config["ts_ls"] = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "typescript", "typescriptreact", "javascriptreact" },
    root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    settings = {
        typescript = { inlayHints = inlayHints },
        javascript = { inlayHints = inlayHints },
        signatureHelp = { enabled = true },
    },
    single_file_support = true,
}

vim.lsp.enable("ts_ls")

-- ── LSP: eslint ─────────────────────────────────────────────

local ESLINT_ROOT_MARKERS = {
    ".eslintrc", ".eslintrc.cjs", ".eslintrc.js", ".eslintrc.json",
    ".eslintrc.yaml", ".eslintrc.yml",
    "eslint.config.cjs", "eslint.config.cts", "eslint.config.js",
    "eslint.config.mjs", "eslint.config.mts", "eslint.config.ts",
}

vim.lsp.config["eslint"] = {
    cmd = { "vscode-eslint-language-server", "--stdio" },
    filetypes = {
        "javascript", "javascript.jsx", "javascriptreact",
        "typescript", "typescript.tsx", "typescriptreact",
    },
    root_markers = ESLINT_ROOT_MARKERS,
    root_dir = function(bufnr, on_dir)
        local filename = vim.api.nvim_buf_get_name(bufnr)
        local root_dir = vim.fs.dirname(vim.fs.find(ESLINT_ROOT_MARKERS, { path = filename, upward = true })[1])
        if not root_dir then return nil end
        on_dir(root_dir)
    end,
    settings = {
        validate = "on",
        packageManager = nil,
        useESLintClass = false,
        experimental = { useFlatConfig = false },
        codeActionOnSave = { enable = false, mode = "all" },
        format = true,
        quiet = false,
        onIgnoredFiles = "off",
        rulesCustomizations = {},
        run = "onType",
        problems = { shortenToSingleLine = false },
        nodePath = "",
        workingDirectory = { mode = "location" },
        codeAction = {
            disableRuleComment = { enable = true, location = "separateLine" },
            showDocumentation = { enable = true },
        },
    },
    on_init = function(client, _)
        local new_root_dir = client.config.root_dir
        if not new_root_dir then return end

        client.config.settings.workspaceFolder = {
            uri = new_root_dir,
            name = vim.fn.fnamemodify(new_root_dir, ":t"),
        }

        -- Support flat config
        if vim.fn.filereadable(new_root_dir .. "/eslint.config.js") == 1
            or vim.fn.filereadable(new_root_dir .. "/eslint.config.mjs") == 1
            or vim.fn.filereadable(new_root_dir .. "/eslint.config.cjs") == 1
            or vim.fn.filereadable(new_root_dir .. "/eslint.config.ts") == 1
            or vim.fn.filereadable(new_root_dir .. "/eslint.config.mts") == 1
            or vim.fn.filereadable(new_root_dir .. "/eslint.config.cts") == 1
        then
            client.config.settings.experimental.useFlatConfig = true
        end

        -- Support Yarn2 (PnP) projects
        local pnp_cjs = new_root_dir .. "/.pnp.cjs"
        local pnp_js = new_root_dir .. "/.pnp.js"
        if vim.uv.fs_stat(pnp_cjs) or vim.uv.fs_stat(pnp_js) then
            client.config.cmd = vim.list_extend({ "yarn", "exec" }, client.config.cmd)
        end
        -- Important to tell the client its config changed if we altered things
        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end,
    handlers = {
        ["eslint/openDoc"] = function(_, result)
            if result then vim.ui.open(result.url) end
            return {}
        end,
        ["eslint/confirmESLintExecution"] = function(_, result)
            if not result then return end
            return 4 -- approved
        end,
        ["eslint/probeFailed"] = function()
            vim.notify("[lspconfig] ESLint probe failed.", vim.log.levels.WARN)
            return {}
        end,
        ["eslint/noLibrary"] = function()
            vim.notify("[lspconfig] Unable to find ESLint library.", vim.log.levels.WARN)
            return {}
        end,
    },
}

vim.lsp.enable("eslint")

return {}
