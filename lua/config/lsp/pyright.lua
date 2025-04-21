vim.lsp.config["pyright"] = {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = {
		".git",
		"main.py",
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		"pyrightconfig.json",
	},
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
}

vim.lsp.enable("pyright")
