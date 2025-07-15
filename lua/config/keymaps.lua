-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal modefix
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic [E]rror" })

-- Code action keymaps
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code [C]ode Action" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
-- vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

local delete_without_mutating_register = function()
	-- Delete the current line without affecting the default register
	--  See `:help vim.fn.delete()`
	local current_line = vim.api.nvim_get_current_line()
	vim.api.nvim_set_current_line("")
	vim.fn.delete(current_line)
end

-- Delete the current line without affecting the default register
vim.keymap.set("n", "dD", delete_without_mutating_register, { desc = "Delete line without affecting register" })

-- Enable github copilot
vim.keymap.set("n", "<leader>ec", function()
	vim.cmd("Copilot enable")
	require("notify")("Copilot enabled", "INFO", {
		title = "Copilot",
		timeout = 2000,
	})
end, { desc = "Enable Copilot" })
vim.keymap.set("n", "<leader>dC", function()
	vim.cmd("Copilot disable")
	require("notify")("Copilot disabled", "WARN", {
		title = "Copilot",
		timeout = 2000,
	})
end, { desc = "Disable Copilot" })

-- Switch between buffers
vim.keymap.set("n", "<leader>bn", "<cmd>BufferLineCycleNext<CR>", { desc = "Switch to next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineCyclePrev<CR>", { desc = "Switch to previous buffer" })

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or 'rounded'

	return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- vim.keymap.set('n', 'K', function()
-- 	vim.lsp.util.open_floating_preview({
-- 		width = 80,
-- 	})
-- end)

local function compile_and_run_cpp()
	local file = vim.fn.expand("%:p")
	local ext = vim.fn.expand("%:e")
	local valid_exts = { cpp = true, cc = true, ["c++"] = true }

	if not valid_exts[ext] then
		vim.notify("Not a valid C++ file.", vim.log.levels.WARN)
		return
	end

	local output = "./a.out"
	print("⏳ Compiling " .. file .. "...")

	local compile_cmd = string.format("g++ '%s' -o '%s'", file, output)
	local compile_result = vim.fn.system(compile_cmd)

	if vim.v.shell_error ~= 0 then
		print("❌ Compilation failed:\n" .. compile_result)
		return
	end

	print(" ")

	vim.notify("✅ Compiled successfully. Running...", vim.log.levels.INFO)
	vim.fn.system(output)

	-- Reload output.txt if it's open
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local name = vim.api.nvim_buf_get_name(buf)
		if name:match("output.txt$") then
			vim.api.nvim_buf_call(buf, function()
				vim.cmd("checktime")
			end)
		end
	end
end

vim.keymap.set("n", "<leader><space>", compile_and_run_cpp, { desc = "Compile & Run C++" })

-- Keymap: <leader><space> in normal mode
vim.keymap.set("n", "<leader><space>", compile_and_run_cpp, { desc = "Compile & Run C++" })
