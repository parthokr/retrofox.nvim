-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- retrofox — Declarative config.yaml reader/writer
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local M = {}
local os_util = require("retrofox.os")

local data_dir = (os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")) .. "/retrofox"
local config_path = data_dir .. "/config.yaml"
local checksum_path = data_dir .. "/.config_checksum"

local _cache = nil

--- @return string
function M.config_path() return config_path end

--- @return string
function M.data_dir() return data_dir end

--- Parse a YAML file via yq → JSON → vim.json.decode
--- @param path string
--- @return table|nil
local function parse_yaml(path)
    if vim.fn.filereadable(path) ~= 1 then return nil end
    local raw = vim.fn.system({ "yq", "-o=json", ".", path })
    if vim.v.shell_error ~= 0 then return nil end
    local ok, data = pcall(vim.json.decode, raw)
    -- vim.json.decode("null") returns vim.NIL (userdata), not nil
    if not ok or type(data) ~= "table" then return nil end
    return data
end

--- Deep merge t2 into t1 (t2 wins on conflicts)
--- @param t1 table
--- @param t2 table
--- @return table
local function deep_merge(t1, t2)
    if type(t1) ~= "table" then return t2 end
    if type(t2) ~= "table" then return t1 end
    local result = vim.deepcopy(t1)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(result[k]) == "table" and not vim.islist(v) then
            result[k] = deep_merge(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

--- Load config.yaml + OS-specific overlay
--- Falls back to config.default.yaml shipped in the repo
--- @return table
function M.load()
    local base = parse_yaml(config_path)
    if not base then
        -- Fallback: use defaults from the repo
        local default_path = vim.fn.stdpath("config") .. "/config.default.yaml"
        base = parse_yaml(default_path) or {}
    end

    -- Merge OS-specific overlay (config.darwin.yaml or config.linux.yaml)
    local overlay_name = os_util.is_mac and "config.darwin.yaml"
                      or os_util.is_linux and "config.linux.yaml"
                      or nil
    if overlay_name then
        local overlay_path = data_dir .. "/" .. overlay_name
        local overlay = parse_yaml(overlay_path)
        if overlay then
            base = deep_merge(base, overlay)
        end
    end

    _cache = base
    return _cache
end

--- Get a value by dot-path (e.g. "editor.tab_width")
--- @param dotpath string
--- @return any
function M.get(dotpath)
    if not _cache then M.load() end
    if not _cache then return nil end
    local keys = vim.split(dotpath, ".", { plain = true })
    local node = _cache
    for _, k in ipairs(keys) do
        if type(node) ~= "table" then return nil end
        node = node[k]
    end
    return node
end

--- Ensure config.yaml exists (bootstrap from defaults if needed)
local function ensure_config_exists()
    vim.fn.mkdir(data_dir, "p")
    if vim.fn.filereadable(config_path) ~= 1 then
        local default_path = vim.fn.stdpath("config") .. "/config.default.yaml"
        if vim.fn.filereadable(default_path) == 1 then
            vim.fn.system({ "cp", default_path, config_path })
        else
            -- Create a minimal config
            local f = io.open(config_path, "w")
            if f then f:write("# retrofox.nvim config\n"); f:close() end
        end
    end
end

--- Set a value in config.yaml via `yq -i` and update checksum
--- @param dotpath string
--- @param value any
function M.set(dotpath, value)
    ensure_config_exists()
    local val_str
    if type(value) == "string" then
        val_str = '"' .. value:gsub('"', '\\"') .. '"'
    elseif type(value) == "boolean" then
        val_str = value and "true" or "false"
    elseif type(value) == "number" then
        val_str = tostring(value)
    else
        val_str = tostring(value)
    end
    vim.fn.system({ "yq", "-i", string.format(".%s = %s", dotpath, val_str), config_path })
    M.update_checksum()
    _cache = nil -- invalidate cache
end

--- Compute SHA-256 checksum of config.yaml
--- @return string|nil
function M.compute_checksum()
    if vim.fn.filereadable(config_path) ~= 1 then return nil end
    local cmd = os_util.sha256_cmd(config_path)
    local result = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then return nil end
    return result:match("^(%S+)")
end

--- Write current checksum to disk
function M.update_checksum()
    vim.fn.mkdir(data_dir, "p")
    local sum = M.compute_checksum()
    if sum then
        local f = io.open(checksum_path, "w")
        if f then f:write(sum); f:close() end
    end
end

--- Check if config.yaml has changed since last stored checksum
--- @return boolean
function M.has_drift()
    local f = io.open(checksum_path, "r")
    if not f then return true end -- no checksum file = treat as drifted
    local stored = f:read("*l"); f:close()
    local current = M.compute_checksum()
    if not current then return false end -- no config file = nothing to drift
    return stored ~= current
end

--- Invalidate cache (force re-read on next get())
function M.invalidate()
    _cache = nil
end

return M
