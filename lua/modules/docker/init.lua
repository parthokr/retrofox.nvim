-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Module: Docker (dockerls LSP)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not require("retrofox.module").enabled("docker") then
    return {}
end

-- ── LSP: dockerls ───────────────────────────────────────────

vim.lsp.config["dockerls"] = {
    cmd = { "docker-langserver", "--stdio" },
    filetypes = { "dockerfile" },
    root_markers = { ".git", "Dockerfile" },
}

vim.lsp.enable("dockerls")

return {}
