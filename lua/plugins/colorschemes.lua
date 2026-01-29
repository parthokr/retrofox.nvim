-- lua/plugins/colorschemes.lua
local specs = {}

-- list of Lua files inside colorschemes folder
local themes = { "github-nvim-theme", "gruvbox-material", "kanagawa", "nightfox", "tokyonight", "catppuccin", "gruvbox" }

for _, theme in ipairs(themes) do
    local ok, spec = pcall(require, "colorschemes." .. theme)
    if ok and spec then
        table.insert(specs, spec)
    end
end

return specs
