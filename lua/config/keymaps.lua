-- [[ Basic Keymaps ]]

-- Transparency toggle (works with any colorscheme)
vim.keymap.set("n", "<leader>tt", function()
    require("colorschemes.utils").toggle_transparency()
end, { desc = "[T]oggle [T]ransparency" })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic [E]rror" })

-- Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", "<Nop>", { silent = true, desc = "Disable left arrow" })
vim.keymap.set("n", "<right>", "<Nop>", { silent = true, desc = "Disable right arrow" })
vim.keymap.set("n", "<up>", "<Nop>", { silent = true, desc = "Disable up arrow" })
vim.keymap.set("n", "<down>", "<Nop>", { silent = true, desc = "Disable down arrow" })

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

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Delete line without affecting register
vim.keymap.set("n", "dD", '"_dd', { desc = "Delete line without affecting register" })

-- Copilot toggle
vim.keymap.set("n", "<leader>ec", function()
    vim.cmd("Copilot enable")
    require("notify")("Copilot enabled", "INFO", { title = "Copilot", timeout = 2000 })
end, { desc = "Enable Copilot" })
vim.keymap.set("n", "<leader>dC", function()
    vim.cmd("Copilot disable")
    require("notify")("Copilot disabled", "WARN", { title = "Copilot", timeout = 2000 })
end, { desc = "Disable Copilot" })

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", "<cmd>BufferLineCycleNext<CR>", { desc = "Switch to next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineCyclePrev<CR>", { desc = "Switch to previous buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>Bdelete<CR>", { desc = "Close buffer (keep window)" })

-- Quick save
vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })

-- Move lines up/down
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

-- Better indent in visual mode (stay in visual)
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Window resize with Ctrl+Arrow
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Compile & Run C++
local function compile_and_run_cpp()
    local file = vim.fn.expand("%:p")
    local ext = vim.fn.expand("%:e")
    local valid_exts = { cpp = true, cc = true, ["c++"] = true }

    if not valid_exts[ext] then
        vim.notify("Not a valid C++ file.", vim.log.levels.WARN)
        return
    end

    vim.cmd("write")

    local output = "./a.out"
    print("⏳ Compiling " .. file .. "...")

    local compile_cmd = string.format("g++ '%s' -o '%s'", file, output)
    local compile_result = vim.fn.system(compile_cmd)

    if vim.v.shell_error ~= 0 then
        print("❌ Compilation failed:\n" .. compile_result)
        return
    end

    print(" ")
    print("✅ Compilation successful. Running...")
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

-- CP Layout
function CreateCPLayout()
    if vim.fn.filereadable("input.txt") == 0 or vim.fn.filereadable("output.txt") == 0 then
        vim.notify("input.txt or output.txt not found in the current directory.", vim.log.levels.ERROR)
        return
    end

    local curr_win = vim.api.nvim_get_current_win()
    vim.cmd("vsplit input.txt")
    vim.cmd("split")
    vim.cmd("term watch -n 0.1 'cat output.txt'")
    vim.api.nvim_set_current_win(curr_win)
end

vim.keymap.set("n", "<leader>cp", CreateCPLayout, { desc = "Create CP Layout" })
