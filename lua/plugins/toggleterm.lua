return {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        -- Polished terminal highlights that adapt to the active colorscheme
        local function get_hl(name, attr)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            if ok and hl[attr] then return string.format("#%06x", hl[attr]) end
            return nil
        end

        local function darken(hex, amount)
            local r = math.max(0, tonumber(hex:sub(2, 3), 16) - amount)
            local g = math.max(0, tonumber(hex:sub(4, 5), 16) - amount)
            local b = math.max(0, tonumber(hex:sub(6, 7), 16) - amount)
            return string.format("#%02x%02x%02x", r, g, b)
        end

        local bg = get_hl("Normal", "bg") or "#1a1b26"
        local fg = get_hl("Normal", "fg") or "#c0caf5"
        local accent = get_hl("Function", "fg") or "#7aa2f7"
        local term_bg = darken(bg, 12)

        -- Set terminal-specific highlights
        vim.api.nvim_set_hl(0, "ToggleTermBorder", { fg = accent, bg = term_bg })
        vim.api.nvim_set_hl(0, "ToggleTermBg", { bg = term_bg })
        vim.api.nvim_set_hl(0, "ToggleTermTitle", { fg = bg, bg = accent, bold = true })

        require("toggleterm").setup({
            size = function(term)
                if term.direction == "horizontal" then
                    return math.max(12, math.floor(vim.o.lines * 0.3))
                elseif term.direction == "vertical" then
                    return math.floor(vim.o.columns * 0.4)
                end
            end,
            open_mapping = [[<C-\>]],
            hide_numbers = true,
            shade_terminals = false, -- we control bg ourselves
            start_in_insert = true,
            insert_mappings = true,
            persist_size = true,
            direction = "float",
            close_on_exit = true,
            shell = vim.o.shell,
            float_opts = {
                border = "rounded",
                width = function() return math.floor(vim.o.columns * 0.85) end,
                height = function() return math.floor(vim.o.lines * 0.8) end,
                winblend = 3,
                title = " Terminal ",
                title_pos = "center",
                highlights = {
                    border = "ToggleTermBorder",
                    background = "ToggleTermBg",
                },
            },
            highlights = {
                FloatBorder = { link = "ToggleTermBorder" },
                NormalFloat = { link = "ToggleTermBg" },
            },
        })

        -- Named terminal launchers
        local Terminal = require("toggleterm.terminal").Terminal

        local lazygit = Terminal:new({
            cmd = "lazygit",
            direction = "float",
            hidden = true,
            float_opts = {
                border = "rounded",
                width = function() return math.floor(vim.o.columns * 0.92) end,
                height = function() return math.floor(vim.o.lines * 0.9) end,
                title = " LazyGit ",
                title_pos = "center",
                highlights = {
                    border = "ToggleTermBorder",
                    background = "ToggleTermBg",
                },
            },
        })

        vim.keymap.set("n", "<leader>gg", function() lazygit:toggle() end, { desc = "Lazy[G]it" })

        -- Horizontal / vertical toggles
        vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", { desc = "[T]erminal [F]loat" })
        vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", { desc = "[T]erminal [V]ertical" })
        vim.keymap.set("n", "<leader>ts", "<cmd>ToggleTerm direction=horizontal<CR>", { desc = "[T]erminal [S]plit" })
    end,
    keys = {
        { "<C-\\>", function() require("toggleterm").toggle() end, desc = "Toggle terminal" },
        { "<Esc><Esc>", "<C-\\><C-n>", desc = "Exit terminal mode", mode = "t" },
        { "<C-\\>", function() require("toggleterm").toggle() end, desc = "Toggle terminal", mode = "t" },
    },
}
