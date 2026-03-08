vim.lsp.config["rust_analyzer"] = {
    cmd = { 'rust-analyzer' },
    root_markers = { '.git', 'Cargo.toml' },
    filetypes = { 'rust' },
    capabilities = {
        textDocument = {
            semanticTokens = {
                multilineTokenSupport = true,
            }
        }
    },
    settings = {
        rust_analyzer = {
            cargo = {
                buildScripts = {
                    enable = true,
                },
            },
            procMacro = {
                enable = true,
            },
            check = {
                command = "clippy",
            },
        }
    }
}

vim.lsp.enable("rust_analyzer")
