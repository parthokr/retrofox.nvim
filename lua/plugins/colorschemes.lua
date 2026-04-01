-- lua/plugins/colorschemes.lua
local specs = {}

local always_on = { tokyonight = true, gruvbox = true }

-- List of colorscheme modules (excludes utils.lua which is a helper, not a plugin spec)
local themes = { "github-nvim-theme", "gruvbox-material", "kanagawa", "nightfox", "tokyonight", "catppuccin", "gruvbox", "rose-pine", "everforest" }

local function is_enabled(theme)
    if always_on[theme] then return true end
    local ok, rf = pcall(require, "retrofox")
    if not ok then return true end
    local val = rf.get("colorschemes." .. theme)
    return val == true
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
