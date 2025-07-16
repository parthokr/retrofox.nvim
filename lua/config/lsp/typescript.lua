local inlayHints = {
    includeInlayParameterNameHints = "all",
    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
    includeInlayFunctionParameterTypeHints = true,
    includeInlayVariableTypeHints = true,
    includeInlayPropertyDeclarationTypeHints = true,
    includeInlayFunctionLikeReturnTypeHints = true,
    includeInlayEnumMemberValueHints = true,
}

vim.lsp.config.typescript = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "typescript", "typescriptreact", "javascriptreact" },
    root_markers = { 'tsconfig.json', 'package.json', 'jsconfig.json', '.git' },
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    settings = {
        typescript = {
            inlayHints = inlayHints,
        },
        javascript = {
            inlayHints = inlayHints,
        },
        signatureHelp = {
            enabled = true,
        },
    },
}

vim.lsp.enable("typescript")
