-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- retrofox.startup — Called on every Neovim startup
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Responsibilities:
--   1. Load config.yaml (with OS overlay)
--   2. Apply editor options from config
--   3. Load OS-specific Lua overlays
--   4. Check for config drift → notify user
--
-- Requires Neovim >= 0.12.0
--

local ok_rf, rf = pcall(require, "retrofox")
if not ok_rf then
    -- yq not installed or first run — skip gracefully
    return
end

local os_util = require("retrofox.os")

-- ── Ensure tool directories are in Neovim's PATH ────────────
-- GUI-launched Neovim may not inherit the full shell PATH.
-- We prepend common tool directories if they exist and aren't present.
do
    local extra_paths = {
        vim.env.HOME .. "/.local/bin",  -- npm --prefix ~/.local installs here
    }

    -- macOS: Homebrew paths may be missing from GUI-launched Neovim
    if os_util.is_mac then
        vim.list_extend(extra_paths, {
            "/opt/homebrew/bin",        -- Apple Silicon
            "/opt/homebrew/sbin",
            "/usr/local/bin",           -- Intel
            "/usr/local/sbin",
        })
    end

    local current_path = vim.env.PATH or ""
    local additions = {}
    for _, p in ipairs(extra_paths) do
        if vim.fn.isdirectory(p) == 1 and not current_path:find(p, 1, true) then
            table.insert(additions, p)
        end
    end
    if #additions > 0 then
        vim.env.PATH = table.concat(additions, ":") .. ":" .. current_path
    end
end

-- ── 1. Load config ──────────────────────────────────────────

local cfg = rf.load()
if not cfg then return end

-- ── 2. Load OS-specific Lua overlay ─────────────────────────

local overlay_module = os_util.is_mac and "os.darwin"
                    or os_util.is_linux and "os.linux"
                    or nil
if overlay_module then
    pcall(require, overlay_module)
end

-- ── 3. Drift detection (deferred to avoid blocking startup) ─

vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("RetrofoxDrift", { clear = true }),
    once = true,
    callback = function()
        if rf.has_drift() then
            vim.notify(
                "  retrofox: config.yaml has changed.\n"
                .. "  Run :RetrofoxApply to re-apply, or :RetrofoxSync to update checksum.",
                vim.log.levels.WARN,
                { title = "retrofox" }
            )
        end
    end,
})

-- ── 4. User commands ────────────────────────────────────────

vim.api.nvim_create_user_command("RetrofoxApply", function()
    -- Re-read config
    rf.invalidate()
    local new_cfg = rf.load()
    if not new_cfg then
        vim.notify("Failed to load config.yaml", vim.log.levels.ERROR)
        return
    end

    local mod = require("retrofox.module")

    -- Re-apply editor options
    local ed = new_cfg.editor or {}
    if ed.relative_numbers ~= nil then vim.opt.relativenumber = ed.relative_numbers end
    if ed.tab_width then
        vim.opt.tabstop = ed.tab_width
        vim.opt.shiftwidth = ed.tab_width
        vim.opt.softtabstop = ed.tab_width
    end

    -- Re-apply colorscheme (active is "colorscheme:variant")
    local cs = (ed.colorschemes or {}).active
    if cs then
        local name = cs:match("^([^:]+)") or cs
        pcall(vim.cmd.colorscheme, name)
    end

    -- ── Clean up disabled modules ───────────────────────────
    -- Module → Mason packages mapping
    local module_packages = {
        python     = { "basedpyright", "debugpy", "isort", "ruff" },
        typescript = { "ts_ls", "eslint", "prettier" },
        go         = { "gopls", "delve" },
        cpp        = { "clangd", "clang-format" },
        rust       = { "rust-analyzer" },
        java       = { "jdtls", "google-java-format" },
        docker     = { "dockerls", "hadolint" },
        json       = { "json-lsp", "jsonlint" },
        markdown   = { "markdownlint-cli2" },
    }

    -- Module → LSP server names
    local module_lsp = {
        python     = { "basedpyright" },
        typescript = { "ts_ls", "eslint" },
        go         = { "gopls" },
        cpp        = { "clangd" },
        rust       = { "rust_analyzer" },
        java       = { "jdtls" },
        docker     = { "dockerls" },
        json       = { "jsonls" },
    }

    local cleaned = {}
    local ok_mason, registry = pcall(require, "mason-registry")

    for module_name, packages in pairs(module_packages) do
        if not mod.enabled(module_name) then
            -- Uninstall Mason packages
            if ok_mason then
                for _, pkg_name in ipairs(packages) do
                    local ok_pkg, pkg = pcall(registry.get_package, pkg_name)
                    if ok_pkg and pkg:is_installed() then
                        pkg:uninstall()
                        table.insert(cleaned, pkg_name)
                    end
                end
            end

            -- Stop running LSP clients
            local lsp_names = module_lsp[module_name] or {}
            for _, lsp_name in ipairs(lsp_names) do
                local clients = vim.lsp.get_clients({ name = lsp_name })
                for _, client in ipairs(clients) do
                    client:stop(true)
                end
            end
        end
    end

    rf.update_checksum()

    local msg = "  Config re-applied and checksum updated."
    if #cleaned > 0 then
        msg = msg .. "\n  Cleaned: " .. table.concat(cleaned, ", ")
        msg = msg .. "\n  Restart Neovim for full effect."
    end
    vim.notify(msg, vim.log.levels.INFO, { title = "retrofox" })
end, { desc = "Re-apply config.yaml, clean disabled modules, update checksum" })

vim.api.nvim_create_user_command("RetrofoxSync", function()
    rf.update_checksum()
    vim.notify("  Checksum updated (no config changes applied).", vim.log.levels.INFO, { title = "retrofox" })
end, { desc = "Update config checksum without re-applying" })

vim.api.nvim_create_user_command("RetrofoxEdit", function()
    vim.cmd("edit " .. rf.config_path())
end, { desc = "Open config.yaml for editing" })
