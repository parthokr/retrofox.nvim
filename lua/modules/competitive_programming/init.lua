-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Module: Competitive Programming (C++ compile & run + CP layout)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not require("retrofox.module").enabled("competitive_programming") then
    return {}
end

local os_util = require("retrofox.os")

-- ── Compile & Run C++ ───────────────────────────────────────

local function compile_and_run_cpp()
    local file = vim.fn.expand("%:p")
    local ext = vim.fn.expand("%:e")
    local valid_exts = { cpp = true, cc = true, ["c++"] = true }

    if not valid_exts[ext] then
        vim.notify("Not a valid C++ file.", vim.log.levels.WARN)
        return
    end

    vim.cmd("write")

    -- Use OS-aware compiler detection
    local compiler = os_util.cpp_compiler()
    if not compiler then
        vim.notify("No C++ compiler found (tried g++, clang++).", vim.log.levels.ERROR)
        return
    end

    local output = "./" .. vim.fn.expand("%:t:r") -- derive from source filename
    print("⏳ Compiling " .. file .. " with " .. compiler .. "...")

    local compile_result = vim.fn.system({ compiler, file, "-o", output })

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

-- ── CP Layout ───────────────────────────────────────────────

local function create_cp_layout()
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

vim.keymap.set("n", "<leader>cp", create_cp_layout, { desc = "Create CP Layout" })

-- No lazy plugin needed
return {}
