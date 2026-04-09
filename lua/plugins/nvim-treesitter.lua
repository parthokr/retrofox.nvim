-- nvim-treesitter (main branch) — requires Neovim >= 0.12.0
--
-- The `main` branch is a full rewrite: `nvim-treesitter.configs` no longer
-- exists. Highlighting is now part of Neovim core (vim.treesitter.start),
-- indentation is provided by the plugin via indentexpr, and parsers are
-- installed with require('nvim-treesitter').install().
--
-- Incremental selection uses Neovim 0.12's native treesitter selection API
-- (vim.treesitter._select). We remap <CR>/<BS> as convenient shortcuts.
return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- plugin does not support lazy-loading
    build = ":TSUpdate",
    config = function()
        local ok, ts = pcall(require, "nvim-treesitter")
        if not ok then
            return
        end

        -- Install dir — keep in the standard nvim data path
        ts.setup({
            install_dir = vim.fn.stdpath("data") .. "/site",
        })

        -- Install parsers for all languages we care about.
        -- install() is a no-op for parsers that are already up-to-date.
        ts.install({
            "c",
            "cpp",
            "lua",
            "vim",
            "vimdoc",
            "query",
            "javascript",
            "html",
            "python",
            "markdown",
            "markdown_inline",
            "go",
            "rust",
            "java",
            "typescript",
            "tsx",
            "json",
            "yaml",
            "bash",
            "dockerfile",
            "css",
            "toml",
            "groovy",
            "kotlin",
            "cmake",
        })
    end,

    -- Highlighting: driven by Neovim core (vim.treesitter.start).
    -- We register a broad FileType autocmd so every buffer with a
    -- Tree-sitter parser gets highlighting automatically.
    init = function()
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("RetrofoxTreesitterHL", { clear = true }),
            callback = function()
                -- pcall: silently ignore filetypes without a parser
                pcall(vim.treesitter.start)
            end,
        })

        -- Indentation: experimental but provided by the plugin.
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("RetrofoxTreesitterIndent", { clear = true }),
            callback = function()
                local ok, _ = pcall(require, "nvim-treesitter")
                if not ok then
                    return
                end
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })

        -- ── Incremental selection via Neovim 0.12 native API ─────────────
        -- Neovim 0.12 provides built-in incremental selection in visual mode:
        --   an  → select parent node (expand)     [vim.treesitter._select.select_parent]
        --   in  → select child node (shrink)      [vim.treesitter._select.select_child]
        --   ]n  → select next sibling node        [vim.treesitter._select.select_next]
        --   [n  → select previous sibling node    [vim.treesitter._select.select_prev]
        --
        -- We map <CR>/<BS> to call these APIs directly (no expr=true needed).

        -- Buftype/filetype exclusions where <CR>/<BS> must keep native behavior
        local excluded_bt = { quickfix = true, help = true, prompt = true, terminal = true }
        local excluded_ft =
            { ["neo-tree"] = true, oil = true, alpha = true, lazy = true, mason = true, toggleterm = true }

        local function is_excluded()
            return excluded_bt[vim.bo.buftype] or excluded_ft[vim.bo.filetype]
        end

        -- <CR> in normal mode: start visual + select the node at cursor
        vim.keymap.set("n", "<CR>", function()
            if is_excluded() then
                -- Feed native <CR>
                local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
                vim.api.nvim_feedkeys(cr, "n", false)
                return
            end
            -- Enter visual charwise first, then select the parent node
            -- This mimics pressing `van` — enter visual and immediately expand to parent
            local sel_ok, sel = pcall(require, "vim.treesitter._select")
            if sel_ok and sel.select_parent then
                vim.cmd("normal! v")
                sel.select_parent(1)
            end
        end, { desc = "TS: init incremental selection", silent = true })

        -- <CR> in visual mode: expand to parent node
        vim.keymap.set("x", "<CR>", function()
            if is_excluded() then
                local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
                vim.api.nvim_feedkeys(cr, "n", false)
                return
            end
            local sel_ok, sel = pcall(require, "vim.treesitter._select")
            if sel_ok and sel.select_parent then
                sel.select_parent(1)
            end
        end, { desc = "TS: expand incremental selection", silent = true })

        -- <BS> in visual mode: shrink to child node
        vim.keymap.set("x", "<BS>", function()
            if is_excluded() then
                local bs = vim.api.nvim_replace_termcodes("<BS>", true, false, true)
                vim.api.nvim_feedkeys(bs, "n", false)
                return
            end
            local sel_ok, sel = pcall(require, "vim.treesitter._select")
            if sel_ok and sel.select_child then
                sel.select_child(1)
            end
        end, { desc = "TS: shrink incremental selection", silent = true })
    end,
}
