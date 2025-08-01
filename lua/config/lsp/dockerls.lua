vim.lsp.config["dockerls"] = {
    cmd = {
        "docker-langserver",
        "--stdio",
    },
    filetypes = {
        "dockerfile",
    },
    root_markers = {
        ".git",
        "Dockerfile",
    },

    single_file_support = true,
}

vim.lsp.enable("dockerls")
