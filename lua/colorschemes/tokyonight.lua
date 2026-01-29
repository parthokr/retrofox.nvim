return {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
        -- Initial transparency state (set to true to match setup below)
        vim.g.tokyonight_transparent = false

        ---@diagnostic disable-next-line: missing-fields
        require("tokyonight").setup({
            transparent = vim.g.tokyonight_transparent,
            styles = {
                sidebars = true,
                floats = true,
                comments = { italic = false },
            },
        })

        -- Function to apply transparency highlights
        local function apply_transparency()
            if vim.g.tokyonight_transparent then
                vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
                vim.cmd("hi NormalNC guibg=NONE ctermbg=NONE")
                vim.cmd("hi SignColumn guibg=NONE")
                vim.cmd("hi VertSplit guifg=#ff9e64") -- Keep split visible
            else
                vim.cmd("hi Normal guibg=#1f2335 ctermbg=NONE")
                vim.cmd("hi NormalNC guibg=#1f2335 ctermbg=NONE")
                vim.cmd("hi SignColumn guibg=#1f2335")
                vim.cmd("hi VertSplit guifg=#ff9e64") -- Still keep it visible
            end
        end

        -- Load the colorscheme
        vim.cmd.colorscheme("tokyonight-night")

        -- Apply initial transparency state
        -- apply_transparency()

        -- Toggle transparency with <leader>tt
        vim.keymap.set("n", "<leader>tt", function()
            vim.g.tokyonight_transparent = not vim.g.tokyonight_transparent
            -- apply_transparency()
            print("Transparency: " .. (vim.g.tokyonight_transparent and "ON" or "OFF"))
        end, { desc = "Toggle Transparency" })

        -- Optional: Make window separators more visible
        -- vim.cmd("highlight WinSeparator guifg=#ff9e64 gui=bold")
    end,
}
