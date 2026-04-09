vim.diagnostic.config({
    virtual_text = false, -- handled by tiny-inline-diagnostic
    underline = true,
    signs = {
        text = {
            error = "",
            warn = "",
            info = "",
            hint = "",
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
            [vim.diagnostic.severity.WARN] = "WarningMsg",
            [vim.diagnostic.severity.INFO] = "Normal",
            [vim.diagnostic.severity.HINT] = "Normal",
        },
    },
    update_in_insert = false,
    severity_sort = true,
    float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        source = true,
        header = "",
        prefix = "",
    },
})

-- Polished inlay hint styling (adapts to any colorscheme)
local function set_inlay_hint_style()
    local function get_hl_fg(name)
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
        if ok and hl.fg then
            return hl.fg
        end
        return nil
    end

    local function get_hl_bg(name)
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
        if ok and hl.bg then
            return hl.bg
        end
        return nil
    end

    local function blend(fg_hex, bg_hex, alpha)
        local fg_r, fg_g, fg_b = bit.rshift(fg_hex, 16), bit.band(bit.rshift(fg_hex, 8), 0xFF), bit.band(fg_hex, 0xFF)
        local bg_r, bg_g, bg_b = bit.rshift(bg_hex, 16), bit.band(bit.rshift(bg_hex, 8), 0xFF), bit.band(bg_hex, 0xFF)
        local r = math.floor(fg_r * alpha + bg_r * (1 - alpha))
        local g = math.floor(fg_g * alpha + bg_g * (1 - alpha))
        local b = math.floor(fg_b * alpha + bg_b * (1 - alpha))
        return string.format("#%02x%02x%02x", r, g, b)
    end

    local comment_fg = get_hl_fg("Comment") or 0x6a737d
    local normal_bg = get_hl_bg("Normal") or 0x1a1b26
    local hint_fg = blend(comment_fg, normal_bg, 0.7)
    local hint_bg = blend(comment_fg, normal_bg, 0.08)

    vim.api.nvim_set_hl(0, "LspInlayHint", { fg = hint_fg, bg = hint_bg, italic = true })
end

set_inlay_hint_style()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_inlay_hint_style })

-- Centralized LspAttach: buffer-local keymaps + inlay hints for all LSP servers
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
            return
        end

        local buf = args.buf
        local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end

        -- Navigation
        map("n", "K", function()
            vim.lsp.buf.hover({ border = "rounded", max_width = 80 })
        end, "LSP Hover")
        map("n", "<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame symbol")
        map("n", "<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

        -- Workspace
        map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd folder")
        map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove folder")
        map("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "[W]orkspace [L]ist folders")

        -- Inlay hints (for any server that supports them)
        if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
            map("n", "<leader>th", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            end, "[T]oggle Inlay [H]ints")
        end
    end,
})

-- Load per-server configs from lua/core/lsp/
local lsp_path = vim.fn.stdpath("config") .. "/lua/core/lsp"

for _, file in ipairs(vim.fn.readdir(lsp_path)) do
    if file:match("%.lua$") then
        local module_name = "core.lsp." .. file:gsub("%.lua$", "")
        require(module_name)
    end
end
