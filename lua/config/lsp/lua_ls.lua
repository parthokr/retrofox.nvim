local mason_lua_ls = vim.fn.stdpath("data") .. "/mason/bin/lua-language-server"
local lua_ls_cmd = vim.fn.executable(mason_lua_ls) == 1 and mason_lua_ls or "lua-language-server"

vim.lsp.config["lua_ls"] = {
    cmd = { lua_ls_cmd },
    filetypes = { "lua" },
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
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            diagnostics = {
                disable = { "missing-parameters", "missing-fields" },
            },
            format = {
                enable = true,
                defaultConfig = {
                    indent_style = "space",
                    indent_size = "4",
                },
            },
            signatureHelp = {
                enabled = true,
            },
            telemetry = {
                enabled = false,
            },
        },
    },
    single_file_support = true,
    log_level = vim.lsp.protocol.MessageType.Warning,
}

vim.lsp.enable("lua_ls")
