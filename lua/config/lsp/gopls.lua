vim.lsp.config["gopls"] = {
    cmd = { "gopls" },
    filetypes = { "go" },
    root_markers = {
        ".git",
        "go.mod",
    },
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    settings = {
        gopls = {
            usePlaceholders = true,
            completeUnimported = true,
            gofumpt = true,
            analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useanytype = true,
            },
            codelenses = {
                generate = true,
                gc_details = true,
                test = true,
                tidy = true,
            },
        },
    },
}

vim.lsp.enable("gopls")
