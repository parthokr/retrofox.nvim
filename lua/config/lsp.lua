vim.diagnostic.config({
    virtual_text = {
        prefix = "●", -- Could be '●', '▎', 'x'
        spacing = 4,
        source = true,
    },
    underline = true,
    signs = {
        text = {
            error = "",
            warn = "",
            info = "",
            hint = "",
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
            [vim.diagnostic.severity.WARN] = "WarningMsg",
            [vim.diagnostic.severity.INFO] = "Normal",
            [vim.diagnostic.severity.HINT] = "Normal",
        }
    },
    update_in_insert = false,
    severity_sort = true,
    float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        source = true,
        header = "",
        prefix = "",
    },
})


local lsp_path = vim.fn.stdpath("config") .. "/lua/config/lsp"

for _, file in ipairs(vim.fn.readdir(lsp_path)) do
    if file:match("%.lua$") then
        local module_name = "config.lsp." .. file:gsub("%.lua$", "")
        require(module_name)
    end
end
