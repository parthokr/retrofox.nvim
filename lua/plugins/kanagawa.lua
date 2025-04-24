return {
	"rebelot/kanagawa.nvim",
	config = function()
		require("kanagawa").setup({
			compile = false,
			transparent = false,
			overrides = function(colors)
				return {
					["@markup.link.url.markdown_inline"] = { link = "Special" }, -- (url)
					["@markup.link.label.markdown_inline"] = { link = "WarningMsg" }, -- [label]
					["@markup.italic.markdown_inline"] = { link = "Exception" }, -- *italic*
					["@markup.raw.markdown_inline"] = { link = "String" }, -- `code`
					["@markup.list.markdown"] = { link = "Function" }, -- + list
					["@markup.quote.markdown"] = { link = "Error" },   -- > blockcode
					["@markup.list.checked.markdown"] = { link = "WarningMsg" }, -- - [X] checked list item
				}
			end,
		})
		vim.cmd("colorscheme kanagawa")

		local toggle_transparency = function()
			local current_transparency = vim.g.kanagawa_transparent
			if current_transparency == nil then
				current_transparency = false
			end
			if current_transparency then
				vim.g.kanagawa_transparent = false
				vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")
				vim.cmd("highlight NonText guibg=NONE ctermbg=NONE")
				vim.cmd("highlight SignColumn guibg=NONE ctermbg=NONE")
			else
				vim.g.kanagawa_transparent = true
				vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")
				vim.cmd("highlight NonText guibg=NONE ctermbg=NONE")
				vim.cmd("highlight SignColumn guibg=NONE ctermbg=NONE")
			end
			vim.cmd("redraw")
			vim.notify("Kanagawa transparency " .. (current_transparency and "disabled" or "enabled"),
				vim.log.levels.INFO, { title = "Kanagawa" })
		end
		vim.keymap.set("n", "<leader>tt", toggle_transparency, { desc = "Toggle Kanagawa Transparency" })
	end,
	build = function()
		vim.cmd("KanagawaCompile")
	end,
}
