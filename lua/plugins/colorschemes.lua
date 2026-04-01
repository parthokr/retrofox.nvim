local specs = {}
local catalog = require("colorschemes.catalog")
local theme_cfg = require("retrofox.colorscheme")

for _, family_id in ipairs(theme_cfg.enabled_families()) do
    local family = catalog.families[family_id]
    local ok, spec = family and pcall(require, "colorschemes." .. family.module)
    if ok and spec then
        table.insert(specs, spec)
    end
end

return specs
