-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- retrofox.os — Cross-platform OS detection utility
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local M = {}

local uname = vim.uv.os_uname()

M.sysname = uname.sysname:lower()  -- "darwin", "linux", "windows_nt"
M.machine = uname.machine           -- "arm64", "x86_64", "aarch64"

M.is_mac     = M.sysname == "darwin"
M.is_linux   = M.sysname == "linux"
M.is_arm     = M.machine == "arm64" or M.machine == "aarch64"
M.is_wsl     = M.is_linux and (os.getenv("WSL_DISTRO_NAME") ~= nil)

--- Return the correct SHA-256 command for this OS
--- macOS uses `shasum -a 256`, Linux uses `sha256sum`
---@param filepath string
---@return string[]
function M.sha256_cmd(filepath)
    if M.is_mac then
        return { "shasum", "-a", "256", filepath }
    else
        return { "sha256sum", filepath }
    end
end

--- Return the JDTLS config directory name for this OS/arch
---@return string
function M.jdtls_config()
    if M.is_mac then
        return M.is_arm and "config_mac_arm" or "config_mac"
    elseif M.is_linux then
        return "config_linux"
    else
        return "config_win"
    end
end

--- Find Java executable (dynamic, not hardcoded)
---@return string
function M.java_cmd()
    -- 1. Try PATH
    local exe = vim.fn.exepath("java")
    if exe ~= "" then return exe end

    -- 2. macOS: try java_home
    if M.is_mac then
        local jh = vim.fn.system("/usr/libexec/java_home 2>/dev/null"):gsub("\n", "")
        if vim.v.shell_error == 0 and jh ~= "" then
            return jh .. "/bin/java"
        end
    end

    -- 3. Linux: common locations
    if M.is_linux then
        local candidates = {
            "/usr/bin/java",
            "/usr/lib/jvm/default/bin/java",
            "/usr/lib/jvm/java-17-openjdk/bin/java",
        }
        for _, path in ipairs(candidates) do
            if vim.fn.filereadable(path) == 1 then return path end
        end
    end

    return "java"  -- fallback
end

--- Find C++ debugger adapter (DAP)
--- Tries lldb-dap → lldb-vscode → codelldb in order
---@return string|nil
function M.cpp_debugger()
    for _, cmd in ipairs({ "lldb-dap", "lldb-vscode", "codelldb" }) do
        if vim.fn.exepath(cmd) ~= "" then return cmd end
    end
    return nil
end

--- Find C++ compiler
--- Tries g++ → clang++ in order
---@return string|nil
function M.cpp_compiler()
    for _, cmd in ipairs({ "g++", "clang++" }) do
        if vim.fn.exepath(cmd) ~= "" then return cmd end
    end
    return nil
end

return M
