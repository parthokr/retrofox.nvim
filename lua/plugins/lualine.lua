return {
	"nvim-lualine/lualine.nvim",
	config = function()
		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "tokyonight",
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch" },
				lualine_c = { "filename" },
				lualine_x = {
					"encoding",
					{
						"fileformat",
						symbols = { unix = "", dos = "" },
					},
					"filetype",
					"diff",
					"diagnostics",
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		})

		-- Add LSP status component
		local function get_lsp_clients()
			local clients = vim.lsp.get_active_clients()
			if #clients == 0 then
				return ""
			end
			local client_names = {}
			for _, client in ipairs(clients) do
				table.insert(client_names, client.name)
			end
			return " " .. table.concat(client_names, " ")
		end

		-- Update lualine configuration to include LSP status
		require("lualine").setup({
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch" },
				lualine_c = { "filename" },
				lualine_x = {
					"encoding",
					{
						"fileformat",
						symbols = { unix = "", dos = "" },
					},
					"filetype",
					"diff",
					"diagnostics",
					-- {
					-- 	get_lsp_clients,
					-- 	color = { fg = "#ff9e64" },
					-- },
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		})
	end,
}
