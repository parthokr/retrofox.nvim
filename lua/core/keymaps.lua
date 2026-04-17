-- [[ Basic Keymaps ]]

-- Transparency toggle (works with any colorscheme)
vim.keymap.set("n", "<leader>tt", function()
    require("colorschemes.utils").toggle_transparency()
end, { desc = "[T]oggle [T]ransparency" })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = -1 })
end, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = 1 })
end, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "Open [D]iagnostic [E]rror float" })



-- Split navigation with CTRL+<hjkl>
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Move windows
vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- Delete without affecting register
vim.keymap.set("n", "dD", '"_dd', { desc = "Delete line without affecting register" })
vim.keymap.set("n", "x", '"_x', { desc = "Delete char without affecting register" })

-- Copilot toggle (only when copilot module is enabled)
if require("retrofox.module").enabled("copilot") then
    vim.keymap.set("n", "<leader>ec", function()
        vim.cmd("Copilot enable")
        vim.notify("Copilot enabled", vim.log.levels.INFO, { title = "Copilot" })
    end, { desc = "Enable Copilot" })
    vim.keymap.set("n", "<leader>xc", function()
        vim.cmd("Copilot disable")
        vim.notify("Copilot disabled", vim.log.levels.WARN, { title = "Copilot" })
    end, { desc = "Disable Copilot" })
end

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", "<cmd>BufferLineCycleNext<CR>", { desc = "Switch to next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineCyclePrev<CR>", { desc = "Switch to previous buffer" })



-- Copy full file path
vim.keymap.set("n", "<leader>fp", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    vim.notify(path, vim.log.levels.INFO, { title = "File Path" })
end, { desc = "Copy file path" })

-- Better indent in visual mode (stay in visual)
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Window resize with Ctrl+Arrow
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })
