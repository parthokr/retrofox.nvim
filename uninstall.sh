#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# retrofox.nvim — Uninstaller
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Removes everything that setup.sh installs:
#   • The Neovim config cloned to ~/.config/nvim
#   • The retrofox data dir  ~/.local/share/retrofox
#   • The yq binary          /usr/local/bin/yq  (if installed by setup.sh)
#   • Lazy.nvim plugin cache ~/.local/share/nvim
#   • Mason tool dir
#   • Charm apt/dnf repo files (Linux only)
#
# Packages installed via a system package manager (nvim, git, node, fzf, gum …)
# are NOT removed automatically — the script will list them and let you decide.
#
# Usage:
#   ./uninstall.sh              # interactive (asks before each destructive step)
#   ./uninstall.sh --yes        # non-interactive (assume yes to all prompts)
#   ./uninstall.sh --keep-pkgs  # skip the package-removal advisory
#
set -euo pipefail

NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/retrofox"
NVIM_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
NVIM_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
NVIM_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/nvim"
YQ_BIN="/usr/local/bin/yq"

# ── Flags ────────────────────────────────────────────
ASSUME_YES=false
SKIP_PKG_ADVISORY=false
for arg in "$@"; do
    case "$arg" in
        --yes)        ASSUME_YES=true ;;
        --keep-pkgs)  SKIP_PKG_ADVISORY=true ;;
    esac
done

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Helpers
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
info()  { printf "\033[1;34m▸\033[0m %s\n" "$1"; }
ok()    { printf "\033[1;32m✓\033[0m %s\n" "$1"; }
warn()  { printf "\033[1;33m⚠\033[0m %s\n" "$1"; }
err()   { printf "\033[1;31m✗\033[0m %s\n" "$1"; }
sep()   { echo ""; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; echo ""; }

confirm() {
    local prompt="$1"
    if [ "$ASSUME_YES" = true ]; then
        info "$prompt — auto-confirmed (--yes)"
        return 0
    fi
    printf "\033[1;33m?\033[0m %s [y/N] " "$prompt"
    read -r answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

remove_path() {
    local path="$1"
    local label="$2"
    if [ -e "$path" ] || [ -L "$path" ]; then
        if confirm "Remove $label ($path)?"; then
            rm -rf "$path"
            ok "Removed $label"
        else
            warn "Skipped: $label"
        fi
    else
        info "$label not found — skipping"
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OS Detection
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
detect_os() {
    case "$(uname -s)" in
        Darwin) OS="darwin" ;;
        Linux)  OS="linux" ;;
        *)      OS="unknown" ;;
    esac
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 1. Neovim config directory
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
remove_nvim_config() {
    sep
    info "Step 1 — Neovim config directory"

    if [ ! -d "$NVIM_DIR" ]; then
        info "Neovim config not found at $NVIM_DIR — skipping"
        return
    fi

    # Only remove if it is actually the retrofox repo
    local remote
    remote=$(git -C "$NVIM_DIR" remote get-url origin 2>/dev/null || true)
    if echo "$remote" | grep -q "retrofox.nvim"; then
        remove_path "$NVIM_DIR" "retrofox.nvim config"
    else
        warn "$NVIM_DIR exists but does not appear to be retrofox.nvim (remote: ${remote:-unknown})."
        warn "Skipping to avoid removing an unrelated config."
        if confirm "Remove it anyway?"; then
            rm -rf "$NVIM_DIR"
            ok "Removed $NVIM_DIR"
        fi
    fi

    # Also offer to restore a backup if one exists
    local latest_backup
    latest_backup=$(ls -dt "${NVIM_DIR}.bak."* 2>/dev/null | head -n1 || true)
    if [ -n "$latest_backup" ]; then
        echo ""
        info "Found backup: $latest_backup"
        if confirm "Restore this backup to $NVIM_DIR?"; then
            mv "$latest_backup" "$NVIM_DIR"
            ok "Backup restored"
        fi
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 2. retrofox data directory
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
remove_data_dir() {
    sep
    info "Step 2 — retrofox data directory (~/.local/share/retrofox)"
    remove_path "$DATA_DIR" "retrofox data dir (config.yaml, checksums)"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 3. yq binary (only if installed by setup.sh to /usr/local/bin)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
remove_yq() {
    sep
    info "Step 3 — yq binary ($YQ_BIN)"

    if [ ! -f "$YQ_BIN" ]; then
        info "yq not found at $YQ_BIN — skipping"
        return
    fi

    # Only remove mikefarah/yq that was placed directly by setup.sh
    if yq --version 2>&1 | grep -qi "mikefarah"; then
        if confirm "Remove mikefarah/yq binary from $YQ_BIN?"; then
            sudo rm -f "$YQ_BIN"
            ok "yq removed"
        else
            warn "Skipped: yq"
        fi
    else
        info "yq at $YQ_BIN does not appear to be mikefarah/yq — skipping"
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 4. Neovim plugin/data directories (Lazy.nvim, Mason, Tree-sitter)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
remove_nvim_data() {
    sep
    info "Step 4 — Neovim data / state / cache directories"
    echo "  These contain: Lazy.nvim plugins, Mason tools, Tree-sitter parsers,"
    echo "  and general Neovim runtime state."
    echo ""

    remove_path "$NVIM_DATA_DIR"  "Neovim data    (~/.local/share/nvim)"
    remove_path "$NVIM_STATE_DIR" "Neovim state   (~/.local/state/nvim)"
    remove_path "$NVIM_CACHE_DIR" "Neovim cache   (~/.cache/nvim)"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 5. Linux: Charm repository files (gum apt/dnf source)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
remove_charm_repos() {
    sep
    info "Step 5 — Linux package repository files added by setup.sh"

    # apt (Ubuntu / Debian)
    local apt_keyring="/etc/apt/keyrings/charm.gpg"
    local apt_source="/etc/apt/sources.list.d/charm.list"
    local removed_apt=false

    if [ -f "$apt_keyring" ] || [ -f "$apt_source" ]; then
        if confirm "Remove Charm apt repository (keyring + sources.list.d entry)?"; then
            [ -f "$apt_keyring" ] && sudo rm -f "$apt_keyring" && ok "Removed $apt_keyring"
            [ -f "$apt_source" ] && sudo rm -f "$apt_source"  && ok "Removed $apt_source"
            info "Running apt-get update to refresh source lists..."
            sudo apt-get update -qq
            removed_apt=true
        else
            warn "Skipped: Charm apt repo"
        fi
    fi

    # dnf (Fedora / RHEL)
    local dnf_repo="/etc/yum.repos.d/charm.repo"
    if [ -f "$dnf_repo" ]; then
        if confirm "Remove Charm dnf/yum repository ($dnf_repo)?"; then
            sudo rm -f "$dnf_repo"
            ok "Removed $dnf_repo"
        else
            warn "Skipped: Charm dnf repo"
        fi
    fi

    if [ "$removed_apt" = false ] && [ ! -f "$dnf_repo" ]; then
        info "No Charm repository files found — skipping"
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 6. Advisory — packages installed via system package manager
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pkg_advisory() {
    [ "$SKIP_PKG_ADVISORY" = true ] && return

    sep
    info "Step 6 — System packages installed by setup.sh"
    echo ""
    echo "  The following tools may have been installed by setup.sh via your"
    echo "  system package manager. This script does NOT remove them automatically"
    echo "  because they may be used by other software on your system."
    echo ""
    echo "  To remove them manually:"
    echo ""

    if [ "$OS" = "darwin" ]; then
        echo "    brew uninstall neovim git curl node fzf gum"
    elif command -v apt-get &>/dev/null; then
        echo "    sudo apt-get remove --purge neovim git curl nodejs npm fzf gum"
        echo "    sudo apt-get autoremove"
    elif command -v pacman &>/dev/null; then
        echo "    sudo pacman -Rns neovim git curl nodejs npm fzf gum"
    elif command -v dnf &>/dev/null; then
        echo "    sudo dnf remove neovim git curl nodejs npm fzf gum"
    else
        echo "    Use your package manager to remove: neovim git curl nodejs npm fzf gum"
    fi

    echo ""
    warn "Review the list above before running — these may be needed by other tools."
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Main
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
main() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🦊 retrofox.nvim uninstaller"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  This script will remove:"
    echo "    • $NVIM_DIR               (cloned config)"
    echo "    • $DATA_DIR   (config.yaml, checksums)"
    echo "    • $YQ_BIN                 (if placed by setup.sh)"
    echo "    • $NVIM_DATA_DIR, $NVIM_STATE_DIR, $NVIM_CACHE_DIR"
    echo "      (plugins, Mason tools, Tree-sitter parsers)"
    echo "    • Charm apt/dnf repo files (Linux only)"
    echo ""

    if [ "$ASSUME_YES" != true ]; then
        printf "\033[1;33m?\033[0m Continue? [y/N] "
        read -r answer
        if ! [[ "$answer" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 0
        fi
    fi

    detect_os

    remove_nvim_config
    remove_data_dir
    remove_yq

    remove_nvim_data

    # Linux-only steps
    if [ "$OS" = "linux" ]; then
        remove_charm_repos
    fi

    pkg_advisory

    sep
    ok "retrofox.nvim has been uninstalled."
    echo ""
    echo "  If you restored a backup, open Neovim and run :Lazy sync."
    echo ""
}

main "$@"
