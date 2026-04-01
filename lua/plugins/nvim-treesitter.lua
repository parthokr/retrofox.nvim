-- nvim-treesitter (main branch) — requires Neovim >= 0.12.0
--
-- The `main` branch is a full rewrite: `nvim-treesitter.configs` no longer
-- exists. Highlighting is now part of Neovim core (vim.treesitter.start),
-- indentation is provided by the plugin via indentexpr, and parsers are
-- installed with require('nvim-treesitter').install().
--
-- Incremental selection (Enter / Backspace in normal/visual mode) is
-- implemented here using vim.treesitter core APIs directly, since the old
-- configs.incremental_selection module no longer exists in main.
return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- plugin does not support lazy-loading
    build = ":TSUpdate",
    config = function()
        local ok, ts = pcall(require, "nvim-treesitter")
        if not ok then return end

        -- Install dir — keep in the standard nvim data path
        ts.setup({
            install_dir = vim.fn.stdpath("data") .. "/site",
        })

        -- Install parsers for all languages we care about.
        -- install() is a no-op for parsers that are already up-to-date.
        ts.install({
            "c", "lua", "vim", "vimdoc", "query",
            "javascript", "html", "python", "markdown", "markdown_inline",
            "go", "rust", "java", "typescript", "tsx", "json", "yaml",
            "bash", "dockerfile", "css", "toml", "groovy", "kotlin",
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
                if not ok then return end
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })

        -- ── Incremental selection via Tree-sitter ─────────────────────────
        -- <CR>  → init / expand to parent node
        -- <BS>  → shrink to previous child node
        --
        -- We keep a simple stack of TSNode references per buffer.
        -- vim.treesitter.get_node() does all the heavy lifting.

        local node_stack = {} -- bufnr → { TSNode, TSNode, … }

        --- Visually select a TSNode using nvim_buf_set_mark + normal gv.
        --- This works reliably across modes because it sets '< and '> marks
        --- then enters visual mode via `gv`, avoiding cursor-position bugs.
        local function select_ts_node(node)
            local sr, sc, er, ec = node:range() -- 0-indexed, ec exclusive
            local bufnr = vim.api.nvim_get_current_buf()
            -- Clamp end column: if ec is 0 the node ends at the last column
            -- of the previous row.
            local end_row, end_col
            if ec == 0 then
                end_row = er - 1
                -- Get the length of the line to set cursor at the last char
                local line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ""
                end_col = math.max(0, #line - 1)
            else
                end_row = er
                end_col = ec - 1
            end
            -- Set '< and '> marks (1-indexed row, 0-indexed col)
            vim.api.nvim_buf_set_mark(bufnr, "<", sr + 1, sc, {})
            vim.api.nvim_buf_set_mark(bufnr, ">", end_row + 1, end_col, {})
            vim.cmd("normal! gv")
        end

        local function init_or_expand()
            local bufnr = vim.api.nvim_get_current_buf()
            local stack = node_stack[bufnr]

            if not stack or #stack == 0 then
                -- Init: get the smallest named node at cursor
                local node = vim.treesitter.get_node({ ignore_injections = false })
                if not node then return end
                node_stack[bufnr] = { node }
                select_ts_node(node)
            else
                -- Expand: go to parent of the top node on the stack
                local current = stack[#stack]
                local parent = current:parent()
                if not parent then return end -- already at root
                table.insert(stack, parent)
                select_ts_node(parent)
            end
        end

        local function shrink()
            local bufnr = vim.api.nvim_get_current_buf()
            local stack = node_stack[bufnr]

            if not stack or #stack <= 1 then
                -- Fully unwound or nothing — exit visual, clear state
                node_stack[bufnr] = nil
                local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
                vim.api.nvim_feedkeys(esc, "nx", false)
                return
            end

            table.remove(stack) -- pop current
            select_ts_node(stack[#stack]) -- re-select previous
        end

        -- Clear state on BufLeave or when exiting visual mode manually
        vim.api.nvim_create_autocmd("ModeChanged", {
            group = vim.api.nvim_create_augroup("RetrofoxTSIncSel", { clear = true }),
            pattern = "[vV\x16]*:*",  -- leaving any visual mode
            callback = function(ev)
                node_stack[ev.buf] = nil
            end,
        })

        vim.keymap.set({ "n", "x" }, "<CR>", init_or_expand,
            { desc = "TS: init/expand incremental selection", silent = true })
        vim.keymap.set({ "n", "x" }, "<BS>", shrink,
            { desc = "TS: shrink incremental selection", silent = true })
    end,
}
