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
        print(string.format("Client ID: %d, Name: %s, Filetypes: %s", client.id, client.name,
            table.concat(client.config.filetypes or {}, ", ")))
    end
end, {
    desc = "Check LSP information"
})
