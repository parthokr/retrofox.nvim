-- lua/plugins/colorschemes.lua
local specs = {}

-- List of colorscheme modules (excludes utils.lua which is a helper, not a plugin spec)
local themes = { "github-nvim-theme", "gruvbox-material", "kanagawa", "nightfox", "tokyonight", "catppuccin", "gruvbox", "rose-pine" }

for _, theme in ipairs(themes) do
    local ok, spec = pcall(require, "colorschemes." .. theme)
    if ok and spec then
        table.insert(specs, spec)
    end
end

return specs
