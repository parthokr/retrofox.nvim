-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Module: Rust (rust-analyzer LSP)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not require("retrofox.module").enabled("rust") then return {} end

-- ── LSP: rust-analyzer ──────────────────────────────────────

vim.lsp.config["rust_analyzer"] = {
    cmd = { "rust-analyzer" },
    root_markers = { ".git", "Cargo.toml" },
    filetypes = { "rust" },
    capabilities = {
        textDocument = {
            semanticTokens = {
                multilineTokenSupport = true,
            },
        },
    },
    settings = {
        rust_analyzer = {
            cargo = {
                buildScripts = { enable = true },
            },
            procMacro = { enable = true },
            check = { command = "clippy" },
            inlayHints = {
                typeHints = { enable = true },
                parameterHints = { enable = true },
                chainingHints = { enable = true },
                closureReturnTypeHints = { enable = "always" },
                lifetimeElisionHints = { enable = "skip_trivial" },
            },
        },
    },
}

vim.lsp.enable("rust_analyzer")

return {}
