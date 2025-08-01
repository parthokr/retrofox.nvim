vim.lsp.config["jsonls"] = {
    cmd = {
        "vscode-json-language-server",
        "--stdio",
    },
    filetypes = {
        "json",
        "jsonc",
    },
    root_markers = {
        ".git",
    },

    init_options = { provideFormatter = true },
    single_file_support = true,
}

vim.lsp.enable("jsonls")
