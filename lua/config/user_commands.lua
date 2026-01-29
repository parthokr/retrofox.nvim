-- This file defines user commands for Neovim

vim.api.nvim_create_user_command("LspInfo", function()
    -- vim.cmd("checkhealth vim.lsp")
    local lsp_clients = vim.lsp.get_clients()
    if #lsp_clients == 0 then
        print("No LSP clients are attached.")
        return
    end
    print("Attached LSP clients:")
    for _, client in ipairs(lsp_clients) do
        print(string.format("Name: %s, ID: %d", client.name, client.id))
    end
end, {
    desc = "Check LSP information"
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function(args)
        require("config.jdtls.jdtls_setup").setup(args)
    end,
    desc = "Set up Java LSP"
})
