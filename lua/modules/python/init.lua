-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Module: Python (basedpyright LSP + ruff)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not require("retrofox.module").enabled("python") then
    return {}
end

-- ── LSP: basedpyright (for Types, Completions & Hover) ───────
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
                autoImportCompletions = true,
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "standard",
            },
        },
    },
    single_file_support = true,
}

vim.lsp.enable("basedpyright")

-- ── LSP: ruff (for Code Actions, Linting & Formatting) ───────
vim.lsp.config["ruff"] = {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    single_file_support = true,
}

vim.lsp.enable("ruff")

-- Disable Ruff's hover capabilities to avoid overriding Basedpyright
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("python_lsp_attach", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end
        
        if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
        end
    end,
})

return {}
