-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- retrofox.module — Module enable/disable gating
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Usage at the top of any module's init.lua:
--   if not require("retrofox.module").enabled("go") then return {} end
--

local M = {}

--- Check if a named module is enabled in config.yaml
--- Returns true if:
---   1. retrofox framework failed to load (graceful degradation)
---   2. The key is absent from config (default = enabled)
---   3. The key is explicitly true
--- Returns false ONLY if modules.<name> is explicitly false
--- @param name string
--- @return boolean
function M.enabled(name)
    local ok, rf = pcall(require, "retrofox")
    if not ok then return true end -- framework unavailable → enable everything
    local val = rf.get("modules." .. name)
    if val == nil then return true end -- not specified → enabled
    return val ~= false
end

return M
