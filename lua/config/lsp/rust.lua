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
				loadOutDirsFromCheck = true,
			},
			procMacro = {
				enable = true,
			},
			checkOnSave = {
				command = "clippy",
			},
		}
	}
}

vim.lsp.enable("rust_analyzer")
