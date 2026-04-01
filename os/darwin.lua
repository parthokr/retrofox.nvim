-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- OS overlay: macOS (Darwin)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Loaded automatically on macOS by retrofox.startup

-- macOS clipboard is handled natively by Neovim (pbcopy/pbpaste).
-- No special config needed.

-- If Homebrew LLVM is installed, prefer its clangd for better C++ support
local brew_clangd = "/opt/homebrew/opt/llvm/bin/clangd"
if vim.fn.filereadable(brew_clangd) == 1 then
    vim.g.retrofox_clangd_cmd = { brew_clangd, "--fallback-style=llvm" }
end
