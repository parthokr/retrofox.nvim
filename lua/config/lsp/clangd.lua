local on_attach = require("lsp.utils").on_attach

vim.lsp.config["clangd"] = {
	-- From the clangd configuration in <rtp>/lsp/clangd.lua
	cmd = { 'clangd', '--fallback-style=webkit' },
	-- From the clangd configuration in <rtp>/lsp/clangd.lua
	-- Overrides the "*" configuration in init.lua
	root_markers = { '.git', '.clangd', 'compile_commands.json' },
	-- From the clangd configuration in init.lua
	-- Overrides the clangd configuration in <rtp>/lsp/clangd.lua
	filetypes = { 'c', 'cc', 'cpp' },
	on_attach = on_attach,
	-- From the "*" configuration in init.lua
	capabilities = {
		textDocument = {
			semanticTokens = {
				multilineTokenSupport = true,
			}
		}
	}
}

vim.lsp.enable("clangd")
