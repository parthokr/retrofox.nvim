vim.lsp.config["lua_ls"] = {
    cmd = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".git", ".luarc.json", ".luarc.jsonc" },
        telemetry = { enabled = false },
        capabilities = vim.lsp.protocol.make_client_capabilities(),
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
        "lua-language-server",
    },
    filetypes = {
        "lua",
    },
    root_markers = {
        ".git",
        ".luacheckrc",
        ".luarc.json",
        ".luarc.jsonc",
        ".stylua.toml",
        "selene.toml",
        "selene.yml",
        "stylua.toml",
    },
    settings = {
        Lua = {
            diagnostics = {
                disable = { "missing-parameters", "missing-fields" },
            },
        },
    },

    single_file_support = true,
    log_level = vim.lsp.protocol.MessageType.Warning,
}

vim.lsp.enable("lua_ls")
