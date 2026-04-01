vim.api.nvim_create_user_command("LspInfo", function()
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
    desc = "Check LSP information",
})
