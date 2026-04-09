-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Module: Go (vim-go + gopls)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not require("retrofox.module").enabled("go") then
    return {}
end

-- ── LSP: gopls ──────────────────────────────────────────────

vim.lsp.config["gopls"] = {
    cmd = { "gopls" },
    filetypes = { "go" },
    root_markers = { "go.mod", ".git" },
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    settings = {
        gopls = {
            usePlaceholders = true,
            completeUnimported = true,
            gofumpt = true,
            analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useanytype = true,
            },
            codelenses = {
                generate = true,
                gc_details = true,
                test = true,
                tidy = true,
            },
        },
    },
}

vim.lsp.enable("gopls")

-- ── Plugin: vim-go ──────────────────────────────────────────

return {
    "fatih/vim-go",
    ft = { "go" },
    build = ":GoUpdateBinaries",
    init = function()
        -- Disable features already handled by LSP / conform / treesitter
        vim.g.go_fmt_autosave = 0
        vim.g.go_imports_autosave = 0
        vim.g.go_def_mapping_enabled = 0
        vim.g.go_doc_keywordprg_enabled = 0
        vim.g.go_code_completion_enabled = 0

        -- Terminal output
        vim.g.go_term_enabled = 1
        vim.g.go_term_mode = "split"
        vim.g.go_term_reuse = 1
        vim.g.go_term_close_on_exit = 0

        -- Syntax highlighting enhancements
        vim.g.go_highlight_types = 1
        vim.g.go_highlight_fields = 1
        vim.g.go_highlight_functions = 1
        vim.g.go_highlight_function_calls = 1
        vim.g.go_highlight_operators = 1
        vim.g.go_highlight_extra_types = 1
        vim.g.go_highlight_build_constraints = 1
        vim.g.go_highlight_generate_tags = 1
    end,
    keys = {
        { "<leader>gor", "<cmd>GoRun<cr>", ft = "go", desc = "[Go] [R]un" },
        { "<leader>got", "<cmd>GoTest<cr>", ft = "go", desc = "[Go] [T]est" },
        { "<leader>goT", "<cmd>GoTestFunc<cr>", ft = "go", desc = "[Go] [T]est function" },
        { "<leader>gob", "<cmd>GoBuild<cr>", ft = "go", desc = "[Go] [B]uild" },
        { "<leader>goc", "<cmd>GoCoverageToggle<cr>", ft = "go", desc = "[Go] [C]overage toggle" },
        { "<leader>goi", "<cmd>GoImports<cr>", ft = "go", desc = "[Go] [I]mports" },
        { "<leader>goa", "<cmd>GoAddTag<cr>", ft = "go", desc = "[Go] [A]dd struct tags" },
        { "<leader>goA", "<cmd>GoRemoveTag<cr>", ft = "go", desc = "[Go] [A]remove struct tags" },
        { "<leader>goe", "<cmd>GoIfErr<cr>", ft = "go", desc = "[Go] Add if [E]rr" },
        { "<leader>gof", "<cmd>GoFillStruct<cr>", ft = "go", desc = "[Go] [F]ill struct" },
        { "<leader>god", "<cmd>GoDoc<cr>", ft = "go", desc = "[Go] [D]oc" },
        { "<leader>gom", "<cmd>GoMetaLinter<cr>", ft = "go", desc = "[Go] [M]eta linter" },
        { "<leader>gol", "<cmd>GoLint<cr>", ft = "go", desc = "[Go] [L]int" },
        { "<leader>gov", "<cmd>GoVet<cr>", ft = "go", desc = "[Go] [V]et" },
        { "<leader>gox", "<cmd>GoAlternate<cr>", ft = "go", desc = "[Go] Alternate (test file)" },
    },
}
