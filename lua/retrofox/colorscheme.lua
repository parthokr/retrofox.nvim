local M = {}

local catalog = require("colorschemes.catalog")

local DEFAULT_ACTIVE = {
    name = "tokyonight-night",
    label = "Night",
}

local function escape_yaml_string(value)
    return (value or ""):gsub("\\", "\\\\"):gsub('"', '\\"')
end

local function rf()
    local ok, mod = pcall(require, "retrofox")
    if ok then return mod end
    return nil
end

local function add_family(families, seen, family_id)
    if not family_id or seen[family_id] or not catalog.families[family_id] then return end
    seen[family_id] = true
    table.insert(families, family_id)
end

function M.active()
    local config = rf()
    if config then
        local name = config.get("appearance.colorscheme.active")
        local label = config.get("appearance.colorscheme.active_label")
        if type(name) == "string" and name ~= "" then
            return { name = name, label = label }
        end

        -- Backward compatibility with the older flat shape:
        -- appearance.colorscheme / appearance.colorscheme_label
        name = config.get("appearance.colorscheme")
        label = config.get("appearance.colorscheme_label")
        if type(name) == "string" and name ~= "" then
            return { name = name, label = label }
        end
    end

    return vim.deepcopy(DEFAULT_ACTIVE)
end

function M.default_active()
    return vim.deepcopy(DEFAULT_ACTIVE)
end

function M.enabled_families()
    local families = {}
    local seen = {}

    for _, family_id in ipairs(catalog.defaults) do
        add_family(families, seen, family_id)
    end

    local config = rf()
    local configured = config and config.get("appearance.colorscheme.list") or nil
    if type(configured) == "table" then
        for _, family_id in ipairs(configured) do
            if type(family_id) == "string" then
                add_family(families, seen, family_id)
            end
        end
    else
        local active = M.active()
        add_family(families, seen, catalog.family_for_name(active.name))
    end

    return families
end

local function ensure_nested_shape(config)
    local current = config.get("appearance.colorscheme")
    if type(current) == "table" then return end

    local extras = {}
    local defaults = {}
    for _, family_id in ipairs(catalog.defaults) do
        defaults[family_id] = true
    end

    for _, family_id in ipairs(M.enabled_families()) do
        if not defaults[family_id] then
            table.insert(extras, family_id)
        end
    end

    local active = M.active()
    local list_expr = "[]"
    if #extras > 0 then
        list_expr = '["' .. table.concat(extras, '", "') .. '"]'
    end

    local expr = string.format(
        '.appearance.colorscheme = {"list": %s, "active": "%s", "active_label": "%s"}',
        list_expr,
        escape_yaml_string(active.name),
        escape_yaml_string(active.label or DEFAULT_ACTIVE.label)
    )
    vim.fn.system({ "yq", "-i", expr, config.config_path() })
    config.invalidate()
end

function M.set_active(name, label)
    local config = rf()
    if not config then return end

    ensure_nested_shape(config)
    config.set("appearance.colorscheme.active", name)
    config.set("appearance.colorscheme.active_label", label)
end

return M
