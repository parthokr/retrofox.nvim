require("config.lazy")
require("config.options")
require("config.keymaps")

local lsp_path = vim.fn.stdpath("config") .. "/lua/config/lsp"

for _, file in ipairs(vim.fn.readdir(lsp_path)) do
	if file:match("%.lua$") then
		local module_name = "config.lsp." .. file:gsub("%.lua$", "")
		require(module_name)
	end
end
