-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- OS overlay: Linux
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Loaded automatically on Linux by retrofox.startup

local os_util = require("retrofox.os")

-- On WSL, use win32yank for clipboard if available
if os_util.is_wsl then
    local yank = vim.fn.exepath("win32yank.exe")
    if yank ~= "" then
        vim.g.clipboard = {
            name = "win32yank-wsl",
            copy = {
                ["+"] = yank .. " -i --crlf",
                ["*"] = yank .. " -i --crlf",
            },
            paste = {
                ["+"] = yank .. " -o --lf",
                ["*"] = yank .. " -o --lf",
            },
            cache_enabled = true,
        }
    end
end
