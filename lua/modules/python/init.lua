-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Module: Python (basedpyright LSP)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not require("retrofox.module").enabled("python") then
    return {}
end

-- ── LSP: basedpyright ───────────────────────────────────────

vim.lsp.config["basedpyright"] = {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = {
        ".git",
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "pyrightconfig.json",
        "basedpyrightconfig.json",
    },
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    settings = {
        basedpyright = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "standard",
            },
        },
    },
    single_file_support = true,
}

vim.lsp.enable("basedpyright")

return {}
