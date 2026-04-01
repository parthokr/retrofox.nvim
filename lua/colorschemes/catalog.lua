local M = {}

M.defaults = { "tokyonight", "gruvbox" }

M.order = {
    "tokyonight",
    "catppuccin",
    "kanagawa",
    "nightfox",
    "rose-pine",
    "github",
    "everforest",
    "gruvbox",
    "gruvbox-material",
}

M.families = {
    tokyonight = {
        module = "tokyonight",
        header = "Tokyo Night",
        variants = {
            { "tokyonight-night", "Night", "󰘪", "#7aa2f7" },
            { "tokyonight-storm", "Storm", "󰖐", "#7dcfff" },
            { "tokyonight-moon", "Moon", "󰽥", "#c099ff" },
            { "tokyonight-day", "Day", "󰖙", "#2e7de9" },
        },
    },
    catppuccin = {
        module = "catppuccin",
        header = "Catppuccin",
        variants = {
            { "catppuccin-mocha", "Mocha", "󰄛", "#cba6f7" },
            { "catppuccin-macchiato", "Macchiato", "󰄛", "#c6a0f6" },
            { "catppuccin-frappe", "Frappé", "󰄛", "#ca9ee6" },
            { "catppuccin-latte", "Latte", "󰄛", "#8839ef" },
        },
    },
    kanagawa = {
        module = "kanagawa",
        header = "Kanagawa",
        variants = {
            { "kanagawa-wave", "Wave", "󰺣", "#7e9cd8" },
            { "kanagawa-dragon", "Dragon", "󰺣", "#c4b28a" },
            { "kanagawa-lotus", "Lotus", "󰺣", "#c84053" },
        },
    },
    nightfox = {
        module = "nightfox",
        header = "Nightfox",
        variants = {
            { "nightfox", "Nightfox", "", "#719cd6" },
            { "duskfox", "Duskfox", "", "#a3be8c" },
            { "nordfox", "Nordfox", "", "#81a1c1" },
            { "terafox", "Terafox", "", "#5a93aa" },
            { "carbonfox", "Carbonfox", "", "#78a9ff" },
            { "dayfox", "Dayfox", "󰖙", "#4d688e" },
            { "dawnfox", "Dawnfox", "󰖙", "#b4637a" },
        },
    },
    ["rose-pine"] = {
        module = "rose-pine",
        header = "Rosé Pine",
        variants = {
            { "rose-pine", "Main", "󰧱", "#eb6f92" },
            { "rose-pine-moon", "Moon", "󰧱", "#ea9a97" },
            { "rose-pine-dawn", "Dawn", "󰧱", "#d7827e" },
        },
    },
    github = {
        module = "github-nvim-theme",
        header = "GitHub",
        variants = {
            { "github_dark", "Dark", "", "#79c0ff" },
            { "github_dark_dimmed", "Dimmed", "", "#539bf5" },
            { "github_dark_high_contrast", "Hi-Con Dark", "", "#71b7ff" },
            { "github_light", "Light", "󰖙", "#0969da" },
            { "github_light_default", "Light Default", "󰖙", "#0969da" },
        },
    },
    everforest = {
        module = "everforest",
        header = "Everforest",
        variants = {
            { "everforest", "Dark Hard", "󰌪", "#a7c080", function() vim.o.background = "dark"; vim.g.everforest_background = "hard" end },
            { "everforest", "Dark Medium", "󰌪", "#a7c080", function() vim.o.background = "dark"; vim.g.everforest_background = "medium" end },
            { "everforest", "Dark Soft", "󰌪", "#a7c080", function() vim.o.background = "dark"; vim.g.everforest_background = "soft" end },
            { "everforest", "Light Hard", "󰌪", "#5da111", function() vim.o.background = "light"; vim.g.everforest_background = "hard" end },
            { "everforest", "Light Medium", "󰌪", "#5da111", function() vim.o.background = "light"; vim.g.everforest_background = "medium" end },
            { "everforest", "Light Soft", "󰌪", "#5da111", function() vim.o.background = "light"; vim.g.everforest_background = "soft" end },
        },
    },
    gruvbox = {
        module = "gruvbox",
        header = "Gruvbox",
        variants = {
            { "gruvbox", "Dark", "󰊠", "#d79921", function() vim.o.background = "dark" end },
            { "gruvbox", "Light", "󰊠", "#d79921", function() vim.o.background = "light" end },
        },
    },
    ["gruvbox-material"] = {
        module = "gruvbox-material",
        header = "Gruvbox Material",
        variants = {
            { "gruvbox-material", "Dark Hard", "󰊠", "#d4be98", function() vim.o.background = "dark"; vim.g.gruvbox_material_background = "hard" end },
            { "gruvbox-material", "Dark Medium", "󰊠", "#d4be98", function() vim.o.background = "dark"; vim.g.gruvbox_material_background = "medium" end },
            { "gruvbox-material", "Dark Soft", "󰊠", "#d4be98", function() vim.o.background = "dark"; vim.g.gruvbox_material_background = "soft" end },
            { "gruvbox-material", "Light Hard", "󰊠", "#a96b2c", function() vim.o.background = "light"; vim.g.gruvbox_material_background = "hard" end },
            { "gruvbox-material", "Light Medium", "󰊠", "#a96b2c", function() vim.o.background = "light"; vim.g.gruvbox_material_background = "medium" end },
            { "gruvbox-material", "Light Soft", "󰊠", "#a96b2c", function() vim.o.background = "light"; vim.g.gruvbox_material_background = "soft" end },
        },
    },
}

function M.family_for_name(colorscheme_name)
    for _, family_id in ipairs(M.order) do
        local family = M.families[family_id]
        for _, entry in ipairs(family.variants) do
            if entry[1] == colorscheme_name then
                return family_id
            end
        end
    end
    return nil
end

return M
