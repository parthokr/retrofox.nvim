-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Module: C++ (clangd LSP)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not require("retrofox.module").enabled("cpp") then return {} end

-- ── LSP: clangd ─────────────────────────────────────────────

vim.lsp.config["clangd"] = {
    cmd = { "clangd", "--fallback-style=llvm" },
    root_markers = { ".git", ".clangd", "compile_commands.json" },
    filetypes = { "c", "cc", "cpp" },
    capabilities = {
        textDocument = {
            semanticTokens = {
                multilineTokenSupport = true,
            },
        },
    },
}

vim.lsp.enable("clangd")

-- No plugin spec needed — clangd is the only requirement.
-- DAP (debugging) is handled by plugins/debugging.lua which checks module flags.
return {}
