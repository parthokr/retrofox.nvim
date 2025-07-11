vim.lsp.config["go"] = {
	cmd = { "gopls" },
	filetypes = { "go" },
	root_markers = {
		".git",
		"go.mod",
	},
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

vim.lsp.enable("go")
