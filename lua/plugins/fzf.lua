return {
    "ibhagwan/fzf-lua",
    config = function()
        local fzf = require("fzf-lua")

        -- ── Helper: winopts with title ──────────────────────────
        local function winopts_titled(title)
            return { title = title }
        end

        local function map(lhs, desc, fn)
            vim.keymap.set("n", lhs, fn, { desc = desc })
        end

        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- File finders
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        map("<leader>ff", "[F]ind [F]iles", function()
            fzf.files({
                prompt = "  ",
                fd_opts = "--color=never --type f --hidden --follow --exclude .git --exclude .env",
                winopts = winopts_titled(" Find Files "),
            })
        end)

        map("<leader>rf", "[R]esume [F]ind", function()
            fzf.files({
                prompt = "  ",
                fd_opts = "--color=never --type f --hidden --follow --exclude .git --exclude .env",
                resume = true,
                winopts = winopts_titled(" Resume Find "),
            })
        end)

        map("<leader>fih", "[F]ind [i]n [H]idden Files", function()
            fzf.files({
                prompt = "  ",
                hidden = true,
                no_ignore = true,
                winopts = winopts_titled(" Find Files (all) "),
            })
        end)

        map("<leader>fn", "[F]ind in [N]eovim Config", function()
            fzf.files({
                prompt = "  ",
                hidden = true,
                cwd = vim.fn.stdpath("config"),
                fd_opts = "--color=never --type f --hidden --follow --exclude .git",
                winopts = winopts_titled(" Neovim Config "),
            })
        end)

        map("<leader>f.", "[F]ind Recent Files", function()
            fzf.oldfiles({
                prompt = "  ",
                winopts = winopts_titled(" Recent Files "),
            })
        end)

        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- Grep
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        map("<leader>fg", "[F]ind [G]rep", function()
            fzf.live_grep({
                prompt = " 󰈬 ",
                resume = true,
                winopts = winopts_titled(" Live Grep "),
            })
        end)

        map("<leader>fw", "[F]ind [W]ord under cursor", function()
            fzf.grep_cword({
                prompt = " 󰈬 ",
                winopts = winopts_titled(" Grep: <cword> "),
            })
        end)

        map("<leader>/", "Grep Current Buffer", function()
            fzf.grep_curbuf({
                prompt = "  ",
                resume = true,
                winopts = winopts_titled(" Grep Buffer "),
            })
        end)

        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- Buffers, Help, Keymaps, Registers
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        map("<leader>fb", "[F]ind [B]uffers", function()
            fzf.buffers({
                prompt = "  ",
                resume = true,
                sort_lastused = true,
                winopts = winopts_titled(" Buffers "),
            })
        end)

        map("<leader>fh", "[F]ind [H]elp", function()
            fzf.help_tags({
                prompt = " 󰋖 ",
                resume = true,
                winopts = winopts_titled(" Help Tags "),
            })
        end)

        map("<leader>fk", "[F]ind [K]eymaps", function()
            fzf.keymaps({
                prompt = "  ",
                resume = true,
                winopts = winopts_titled(" Keymaps "),
            })
        end)

        map("<leader>fr", "[F]ind [R]egisters", function()
            fzf.registers({
                prompt = "  ",
                resume = true,
                winopts = winopts_titled(" Registers "),
            })
        end)

        vim.keymap.set("n", "<leader>ft", function()
            require("theme-picker").open()
        end, { desc = "[F]ind [T]hemes" })

        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- LSP
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        local lsp_prompt = "  "

        map("<leader>dd", "[D]ocument [D]iagnostics", function()
            fzf.lsp_document_diagnostics({
                prompt = lsp_prompt,
                resume = true,
                winopts = winopts_titled(" Document Diagnostics "),
            })
        end)

        map("<leader>wd", "[W]orkspace [D]iagnostics", function()
            fzf.lsp_workspace_diagnostics({
                prompt = lsp_prompt,
                resume = true,
                winopts = winopts_titled(" Workspace Diagnostics "),
            })
        end)

        map("<leader>ds", "[D]ocument [S]ymbols", function()
            fzf.lsp_document_symbols({
                prompt = lsp_prompt,
                winopts = winopts_titled(" Document Symbols "),
            })
        end)

        map("<leader>ws", "[W]orkspace [S]ymbols", function()
            fzf.lsp_workspace_symbols({
                prompt = lsp_prompt,
                resume = true,
                winopts = winopts_titled(" Workspace Symbols "),
            })
        end)

        map("gd", "Go to Definition", function()
            fzf.lsp_definitions({
                prompt = lsp_prompt,
                jump1 = true,
                winopts = winopts_titled(" LSP Definitions "),
            })
        end)

        map("gD", "Go to Declaration", function()
            fzf.lsp_declarations({
                prompt = lsp_prompt,
                jump1 = true,
                winopts = winopts_titled(" LSP Declarations "),
            })
        end)

        map("gi", "Go to Implementation", function()
            fzf.lsp_implementations({
                prompt = lsp_prompt,
                jump1 = true,
                winopts = winopts_titled(" LSP Implementations "),
            })
        end)

        map("gr", "Find References", function()
            fzf.lsp_references({
                prompt = lsp_prompt,
                resume = true,
                winopts = winopts_titled(" LSP References "),
            })
        end)

        map("ga", "Code Actions", function()
            fzf.lsp_code_actions({
                prompt = lsp_prompt,
                winopts = winopts_titled(" Code Actions "),
            })
        end)

        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- Git
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        local git_prompt = "  "

        map("fgc", "[G]it [C]ommits", function()
            fzf.git_commits({ prompt = git_prompt, resume = true, winopts = winopts_titled(" Git Commits ") })
        end)

        map("fgC", "[G]it Buffer [C]ommits", function()
            fzf.git_bcommits({ prompt = git_prompt, resume = true, winopts = winopts_titled(" Git Buffer Commits ") })
        end)

        map("fgs", "[G]it [S]tatus", function()
            fzf.git_status({ prompt = git_prompt, resume = true, winopts = winopts_titled(" Git Status ") })
        end)

        map("fgS", "[G]it [S]tash", function()
            fzf.git_stash({ prompt = git_prompt, resume = true, winopts = winopts_titled(" Git Stash ") })
        end)

        map("fgb", "[G]it [B]lame", function()
            fzf.git_blame({ prompt = git_prompt, resume = true, winopts = winopts_titled(" Git Blame ") })
        end)
    end,

    -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    -- Global defaults
    -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    opts = {
        -- ── Window ──────────────────────────────────────────
        winopts = {
            height  = 0.85,
            width   = 0.85,
            row     = 0.5,
            col     = 0.5,
            border  = "rounded",
            backdrop = 60,
            preview = {
                layout   = "flex",       -- auto switch horizontal↔vertical
                flip_columns = 130,      -- switch to vertical when < 130 cols
                scrollbar = "border",
                delay    = 60,           -- slight delay to avoid flicker while scrolling
                title    = true,
            },
        },

        -- ── FZF binary options ──────────────────────────────
        fzf_opts = {
            ["--layout"]         = "reverse",
            ["--info"]           = "inline-right",
            ["--cycle"]          = true,
            ["--highlight-line"] = true,
            ["--marker"]         = "▏",
            ["--pointer"]        = "▌",
            ["--header-first"]   = true,
        },

        -- ── Key bindings inside FZF ─────────────────────────
        keymap = {
            fzf = {
                ["ctrl-q"]     = "select-all+accept",   -- send all/selected to quickfix
                ["ctrl-u"]     = "half-page-up",
                ["ctrl-d"]     = "half-page-down",
                ["ctrl-a"]     = "toggle-all",
            },
            builtin = {
                ["<C-s>"]  = "split",
                ["<C-v>"]  = "vsplit",
                ["<C-t>"]  = "tabedit",
                ["<C-f>"]  = "preview-page-down",
                ["<C-b>"]  = "preview-page-up",
            },
        },

        -- ── File icon padding ───────────────────────────────
        file_icon_padding = " ",

        -- ── Files ───────────────────────────────────────────
        files = {
            formatter   = "path.filename_first",
            git_icons   = true,
            header      = "Actions: ctrl-s split │ ctrl-v vsplit │ ctrl-t tab",
        },

        -- ── Grep ────────────────────────────────────────────
        grep = {
            formatter   = "path.filename_first",
            header      = "Actions: ctrl-q quickfix │ ctrl-s split │ ctrl-v vsplit",
            rg_opts     = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
            multiprocess = true,
        },

        -- ── Buffers ─────────────────────────────────────────
        buffers = {
            formatter    = "path.filename_first",
            sort_lastused = true,
            header       = "Actions: ctrl-x close │ ctrl-s split │ ctrl-v vsplit",
            actions      = {
                ["ctrl-x"] = { fn = function(...) return require("fzf-lua.actions").buf_del(...) end, reload = true },
            },
        },

        -- ── Oldfiles ────────────────────────────────────────
        oldfiles = {
            formatter = "path.filename_first",
        },

        -- ── LSP ─────────────────────────────────────────────
        lsp = {
            jump1 = true,
            formatter = "path.filename_first",
        },
    },
}
