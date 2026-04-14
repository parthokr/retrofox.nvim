-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Module: C++ (clangd LSP + CMake integration)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not require("retrofox.module").enabled("cpp") then
    return {}
end

-- ── LSP: clangd (enhanced) ──────────────────────────────────
vim.lsp.config["clangd"] = {
    cmd = vim.g.retrofox_clangd_cmd or {
        "clangd",
        "--background-index", -- index project in background
        "--clang-tidy", -- inline clang-tidy diagnostics
        "--header-insertion=iwyu", -- auto-insert missing #includes
        "--completion-style=detailed", -- richer completion items
        "--function-arg-placeholders", -- snippet-style function args
        "--fallback-style=llvm", -- formatting fallback
        "--all-scopes-completion", -- complete from all scopes
        "--pch-storage=memory", -- faster PCH (trades RAM for speed)
    },
    root_markers = { "compile_commands.json", ".clangd", "CMakeLists.txt", ".git" },
    filetypes = { "c", "cc", "cpp", "objc", "objcpp" },
    capabilities = {
        textDocument = {
            semanticTokens = {
                multilineTokenSupport = true,
            },
        },
        offsetEncoding = { "utf-16" },
    },
}

vim.lsp.enable("clangd")

-- ── Clangd-specific keymaps (only for C/C++ buffers) ────────
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("clangd-keymaps", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or client.name ~= "clangd" then
            return
        end

        local buf = args.buf
        local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end

        -- Header ↔ Source toggle (the #1 most-used C++ navigation)
        map("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<CR>", "[C]langd Switch [H]eader/Source")

        -- Symbol info under cursor
        map("n", "<leader>ci", "<cmd>ClangdSymbolInfo<CR>", "[C]langd Symbol [I]nfo")

        -- Type hierarchy
        map("n", "<leader>ct", "<cmd>ClangdTypeHierarchy<CR>", "[C]langd [T]ype Hierarchy")
        
        -- Check for compile_commands.json to prevent silent degradation failure
        vim.schedule(function()
            local root_dir = client.workspace_folders and client.workspace_folders[1].name or vim.fn.getcwd()
            local has_cdb = vim.fn.filereadable(root_dir .. "/compile_commands.json") == 1 
                         or vim.fn.filereadable(root_dir .. "/build/compile_commands.json") == 1
            if not has_cdb then
                vim.notify(
                    "⚠️ No compile_commands.json found!\nClangd cannot find include paths without it.\nYou will see 'Too many errors emitted' and cascading failures.\nUse :CMakeGenerate or configure your build to fix this.",
                    vim.log.levels.WARN,
                    { title = "clangd" }
                )
            end
        end)
    end,
})

-- ── CMake integration (lightweight) ─────────────────────────
-- These commands help generate/manage compile_commands.json
-- which clangd needs for accurate analysis.

vim.api.nvim_create_user_command("CMakeGenerate", function(opts)
    local build_dir = opts.args ~= "" and opts.args or "build"
    local cmd = string.format(
        "cmake -B %s -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && ln -sf %s/compile_commands.json .",
        build_dir,
        build_dir
    )
    vim.notify("⏳ Running: " .. cmd, vim.log.levels.INFO, { title = "CMake" })
    vim.fn.jobstart(cmd, {
        on_exit = function(_, code)
            if code == 0 then
                vim.notify(
                    "✅ CMake configured — compile_commands.json symlinked",
                    vim.log.levels.INFO,
                    { title = "CMake" }
                )
            else
                vim.notify("❌ CMake failed (exit " .. code .. ")", vim.log.levels.ERROR, { title = "CMake" })
            end
        end,
        stdout_buffered = true,
        stderr_buffered = true,
    })
end, {
    nargs = "?",
    desc = "CMake: configure + generate compile_commands.json",
    complete = "dir",
})

vim.api.nvim_create_user_command("CMakeBuild", function(opts)
    local build_dir = opts.args ~= "" and opts.args or "build"
    local cmd = "cmake --build " .. build_dir
    vim.notify("⏳ Building: " .. cmd, vim.log.levels.INFO, { title = "CMake" })
    vim.fn.jobstart(cmd, {
        on_exit = function(_, code)
            if code == 0 then
                vim.notify("✅ Build succeeded", vim.log.levels.INFO, { title = "CMake" })
            else
                vim.notify("❌ Build failed (exit " .. code .. ")", vim.log.levels.ERROR, { title = "CMake" })
            end
        end,
        stdout_buffered = true,
        stderr_buffered = true,
    })
end, {
    nargs = "?",
    desc = "CMake: build the project",
    complete = "dir",
})

vim.api.nvim_create_user_command("CMakeClean", function(opts)
    local build_dir = opts.args ~= "" and opts.args or "build"
    vim.fn.delete(build_dir, "rf")
    -- Remove the symlink too if it points into the build dir
    local link = vim.fn.resolve("compile_commands.json")
    if link:find(build_dir, 1, true) then
        vim.fn.delete("compile_commands.json")
    end
    vim.notify("🗑  Cleaned " .. build_dir .. "/", vim.log.levels.INFO, { title = "CMake" })
end, {
    nargs = "?",
    desc = "CMake: remove build directory",
    complete = "dir",
})

-- No plugin spec needed — clangd is the only requirement.
-- DAP (debugging) is handled by plugins/debugging.lua which checks module flags.
return {}
