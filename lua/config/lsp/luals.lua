vim.lsp.config["lua"] = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".git", ".luarc.json", ".luarc.jsonc" },
	telemetry = { enabled = false },
	formatters = {
		ignoreComments = false,
	},
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			signatureHelp = { enabled = true },
		},
	},
}

vim.lsp.enable("lua")
