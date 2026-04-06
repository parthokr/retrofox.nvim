-- lua/plugins/colorschemes.lua
local specs = {}

local always_on = { tokyonight = true, gruvbox = true }

-- List of colorscheme modules (excludes utils.lua which is a helper, not a plugin spec)
local themes = { "github-nvim-theme", "gruvbox-material", "kanagawa", "nightfox", "tokyonight", "catppuccin", "gruvbox", "rose-pine", "everforest", "onedark", "cyberdream", "oxocarbon" }

local function is_enabled(theme)
    if always_on[theme] then return true end
    local ok, rf = pcall(require, "retrofox")
    if not ok then return true end
    local families = rf.get("editor.colorschemes.families")
    if type(families) ~= "table" then return false end
    for _, fam in ipairs(families) do
        if fam == theme then return true end
    end
    return false
end

for _, theme in ipairs(themes) do
    if is_enabled(theme) then
        local ok, spec = pcall(require, "colorschemes." .. theme)
        if ok and spec then
            table.insert(specs, spec)
        end
    end
end

return specs
