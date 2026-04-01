#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# retrofox.nvim — Interactive Installer
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Requires: Neovim >= 0.12.0
#   vim.lsp.config / vim.lsp.enable (0.11+)
#   nvim-treesitter main branch (0.12+)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/parthokr/retrofox.nvim/main/setup.sh | bash
#   ./setup.sh --no-install    # skip auto-installing dependencies
#
set -euo pipefail

REPO="https://github.com/parthokr/retrofox.nvim.git"
NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/retrofox"
CONFIG_FILE="$DATA_DIR/config.yaml"
CHECKSUM_FILE="$DATA_DIR/.config_checksum"
BANNER_FILE="$DATA_DIR/banner.txt"
NVIM_MIN_VERSION="0.12.0"

# ── Flags ────────────────────────────────────────────────────
AUTO_INSTALL=true
for arg in "$@"; do
    case "$arg" in
        --no-install) AUTO_INSTALL=false ;;
    esac
done

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OS Detection
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
detect_os() {
    case "$(uname -s)" in
        Darwin) OS="darwin" ;;
        Linux)  OS="linux" ;;
        *)      echo "❌ Unsupported OS: $(uname -s)"; exit 1 ;;
    esac

    case "$(uname -m)" in
        arm64|aarch64) ARCH="arm64" ;;
        x86_64)        ARCH="amd64" ;;
        *)             ARCH="$(uname -m)" ;;
    esac

    # Detect package manager
    if [ "$OS" = "darwin" ]; then
        PKG_MGR="brew"
    elif command -v apt-get &>/dev/null; then
        PKG_MGR="apt"
    elif command -v pacman &>/dev/null; then
        PKG_MGR="pacman"
    elif command -v dnf &>/dev/null; then
        PKG_MGR="dnf"
    else
        PKG_MGR="unknown"
    fi

    # Checksum command
    if [ "$OS" = "darwin" ]; then
        SHA_CMD="shasum -a 256"
    else
        SHA_CMD="sha256sum"
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Helpers
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
info()  { printf "\033[1;34m▸\033[0m %s\n" "$1"; }
ok()    { printf "\033[1;32m✓\033[0m %s\n" "$1"; }
warn()  { printf "\033[1;33m⚠\033[0m %s\n" "$1"; }
err()   { printf "\033[1;31m✗\033[0m %s\n" "$1"; }

install_pkg() {
    local pkg="$1"
    info "Installing $pkg..."
    case "$PKG_MGR" in
        brew)   brew install "$pkg" ;;
        apt)    sudo apt-get install -y "$pkg" ;;
        pacman) sudo pacman -S --noconfirm "$pkg" ;;
        dnf)    sudo dnf install -y "$pkg" ;;
        *)      err "Cannot auto-install '$pkg'. Please install manually."; return 1 ;;
    esac
}

compute_checksum() {
    $SHA_CMD "$1" | cut -d' ' -f1
}

write_default_banner() {
    cp "$NVIM_DIR/banner.default.txt" "$BANNER_FILE"
}

configure_banner() {
    echo ""
    if [ -f "$BANNER_FILE" ]; then
        info "Dashboard banner: $BANNER_FILE"
    else
        info "Dashboard banner"
    fi

    if gum confirm "Customize the dashboard banner?"; then
        local banner
        banner=$(gum write --height 12 --placeholder "Paste or type your banner here")
        if [ -n "${banner//[[:space:]]/}" ]; then
            printf "%s\n" "$banner" > "$BANNER_FILE"
            ok "Custom banner saved"
            return
        fi
        warn "Banner was empty. Using default banner."
    elif [ -f "$BANNER_FILE" ]; then
        ok "Keeping existing banner"
        return
    fi

    write_default_banner
    ok "Default banner saved"
}

# Compare two semver strings: returns 0 if $1 >= $2
version_gte() {
    [ "$(printf '%s\n%s' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Neovim Installation (OS-aware)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
install_neovim() {
    info "Installing Neovim >= $NVIM_MIN_VERSION from GitHub releases..."

    local release_base="https://github.com/neovim/neovim/releases/latest/download"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap 'rm -rf "$tmp_dir"' RETURN

    if [ "$OS" = "linux" ]; then
        local asset=""
        case "$ARCH" in
            amd64) asset="nvim-linux-x86_64.appimage" ;;
            arm64) asset="nvim-linux-arm64.appimage" ;;
            *)
                err "Unsupported Linux architecture for Neovim release installs: $ARCH"
                exit 1
                ;;
        esac

        local appimage_path="$tmp_dir/$asset"
        curl -fsSL "$release_base/$asset" -o "$appimage_path"
        chmod u+x "$appimage_path"
        sudo mkdir -p /usr/local/bin
        sudo mv -f "$appimage_path" /usr/local/bin/nvim
    elif [ "$OS" = "darwin" ]; then
        local asset=""
        case "$ARCH" in
            amd64) asset="nvim-macos-x86_64.tar.gz" ;;
            arm64) asset="nvim-macos-arm64.tar.gz" ;;
            *)
                err "Unsupported macOS architecture for Neovim release installs: $ARCH"
                exit 1
                ;;
        esac

        local tarball_path="$tmp_dir/$asset"
        local extracted_dir="$tmp_dir/${asset%.tar.gz}"
        local install_dir="/usr/local/neovim"

        curl -fsSL "$release_base/$asset" -o "$tarball_path"
        tar -xzf "$tarball_path" -C "$tmp_dir"

        if command -v xattr &>/dev/null; then
            xattr -rc "$extracted_dir" >/dev/null 2>&1 || true
        fi

        sudo rm -rf "$install_dir"
        sudo mv "$extracted_dir" "$install_dir"
        sudo mkdir -p /usr/local/bin
        sudo ln -sf "$install_dir/bin/nvim" /usr/local/bin/nvim
    else
        err "Unsupported OS for Neovim release installs: $OS"
        exit 1
    fi

    rm -rf "$tmp_dir"
    trap - RETURN

    # Verify
    if ! command -v nvim &>/dev/null; then
        err "Neovim installation failed. Please install Neovim >= $NVIM_MIN_VERSION manually."
        err "  https://github.com/neovim/neovim/releases"
        exit 1
    fi

    local installed
    installed=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if version_gte "$installed" "$NVIM_MIN_VERSION"; then
        ok "Neovim $installed installed"
    else
        err "Installed Neovim $installed but need >= $NVIM_MIN_VERSION"
        err "  https://github.com/neovim/neovim/releases"
        exit 1
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Dependency checks
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
check_deps() {
    local missing=()

    info "Checking dependencies..."

    # ── Neovim (special: version check + dedicated installer) ──
    if command -v nvim &>/dev/null; then
        local nvim_ver
        nvim_ver=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        if version_gte "$nvim_ver" "$NVIM_MIN_VERSION"; then
            ok "nvim $nvim_ver found (>= $NVIM_MIN_VERSION)"
        else
            warn "nvim $nvim_ver found but need >= $NVIM_MIN_VERSION"
            if [ "$AUTO_INSTALL" = true ]; then
                install_neovim
            else
                err "Neovim >= $NVIM_MIN_VERSION is required. Install manually or run without --no-install."
                exit 1
            fi
        fi
    else
        warn "nvim not found"
        if [ "$AUTO_INSTALL" = true ]; then
            install_neovim
        else
            err "Neovim >= $NVIM_MIN_VERSION is required. Install manually or run without --no-install."
            exit 1
        fi
    fi

    # ── Other basic tools ──
    for tool in git curl; do
        if command -v "$tool" &>/dev/null; then
            ok "$tool found"
        else
            missing+=("$tool")
            warn "$tool not found"
        fi
    done

    # Node.js and npm (needed for Mason LSP servers)
    local need_node=false
    if command -v node &>/dev/null; then
        ok "node found ($(node --version | head -1))"
    else
        warn "node not found"
        need_node=true
    fi

    if command -v npm &>/dev/null; then
        ok "npm found ($(npm --version | head -1))"
    else
        warn "npm not found"
        need_node=true
    fi

    if [ "$need_node" = true ]; then
        if [ "$PKG_MGR" = "brew" ]; then
            missing+=("node")
        else
            missing+=("nodejs" "npm")
        fi
    fi

    # Tree-sitter parsers need a working C toolchain.
    local compiler_ok=false
    local compiler_name=""
    for tool in cc gcc clang; do
        if command -v "$tool" &>/dev/null; then
            compiler_ok=true
            compiler_name="$tool"
            break
        fi
    done

    if [ "$compiler_ok" = true ]; then
        ok "C compiler found ($compiler_name)"
    else
        warn "C compiler not found (required for Tree-sitter parsers)"
        case "$PKG_MGR" in
            apt)    missing+=("build-essential") ;;
            pacman) missing+=("base-devel") ;;
            dnf)    missing+=("gcc" "gcc-c++" "make") ;;
            brew)   warn "Install Xcode Command Line Tools with: xcode-select --install" ;;
        esac
    fi

    # fzf
    if command -v fzf &>/dev/null; then
        ok "fzf found"
    else
        missing+=("fzf")
        warn "fzf not found"
    fi

    # yq (must be mikefarah/yq, NOT the Python kislyuk/yq)
    local yq_ok=false
    if command -v yq &>/dev/null; then
        # Detect variant: mikefarah's version output contains "mikefarah" or "https://github.com/mikefarah"
        if yq --version 2>&1 | grep -qi "mikefarah"; then
            ok "yq found (mikefarah/yq)"
            yq_ok=true
        else
            warn "Wrong yq variant detected (kislyuk/yq). Need mikefarah/yq."
        fi
    else
        warn "yq not found"
    fi

    if [ "$yq_ok" = false ] && [ "$AUTO_INSTALL" = true ]; then
        info "Installing mikefarah/yq via direct download..."
        local yq_arch="$ARCH"
        local yq_os="linux"
        [ "$OS" = "darwin" ] && yq_os="darwin"
        local yq_url="https://github.com/mikefarah/yq/releases/latest/download/yq_${yq_os}_${yq_arch}"
        (
            sudo curl -fsSL "$yq_url" -o /usr/local/bin/yq
            sudo chmod +x /usr/local/bin/yq
        ) && ok "mikefarah/yq installed" || warn "Failed to install yq — install manually from https://github.com/mikefarah/yq"
    elif [ "$yq_ok" = false ]; then
        err "mikefarah/yq is required. Install from https://github.com/mikefarah/yq"
        err "Note: the Python 'yq' (pip install yq) is NOT compatible."
    fi

    # gum
    if command -v gum &>/dev/null; then
        ok "gum found"
    else
        warn "gum not found"
        if [ "$AUTO_INSTALL" = true ]; then
            if [ "$PKG_MGR" = "brew" ]; then
                missing+=("gum")
            elif [ "$PKG_MGR" = "apt" ]; then
                info "Adding Charm apt repository for gum..."
                (
                    sudo mkdir -p /etc/apt/keyrings
                    curl -fsSL https://repo.charm.sh/apt/gpg.key \
                        | sudo gpg --yes --dearmor -o /etc/apt/keyrings/charm.gpg
                    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
                        | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
                    sudo apt-get update -qq
                ) || warn "Failed to add Charm repo — gum may need manual install"
                missing+=("gum")
            elif [ "$PKG_MGR" = "pacman" ]; then
                missing+=("gum")
            elif [ "$PKG_MGR" = "dnf" ]; then
                info "Adding Charm repo for gum..."
                echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo >/dev/null
                missing+=("gum")
            fi
        fi
    fi

    # Install missing packages
    if [ ${#missing[@]} -gt 0 ]; then
        if [ "$AUTO_INSTALL" = true ]; then
            echo ""
            info "Installing missing packages: ${missing[*]}"
            for pkg in "${missing[@]}"; do
                install_pkg "$pkg" || true
            done
        else
            echo ""
            err "Missing dependencies: ${missing[*]}"
            err "Run without --no-install to auto-install, or install manually."
            exit 1
        fi
    fi

    echo ""

    # ── tree-sitter-cli (>= 0.25.0, needed by nvim-treesitter main) ──
    # npm is already a required dep (Mason), so we use it for tree-sitter-cli too.
    local TS_MIN="0.25.0"
    local ts_needs_install=false

    if command -v tree-sitter &>/dev/null; then
        local ts_ver
        ts_ver=$(tree-sitter --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        if [ -n "$ts_ver" ] && version_gte "$ts_ver" "$TS_MIN"; then
            ok "tree-sitter-cli $ts_ver found (>= $TS_MIN)"
        else
            warn "tree-sitter-cli ${ts_ver:-unknown} is too old (need >= $TS_MIN)"
            ts_needs_install=true
        fi
    else
        warn "tree-sitter-cli not found (required by nvim-treesitter main branch)"
        ts_needs_install=true
    fi

    if [ "$ts_needs_install" = true ]; then
        if [ "$AUTO_INSTALL" = true ]; then
            info "Installing tree-sitter-cli via npm (into ~/.local)..."
            npm install -g --prefix "$HOME/.local" tree-sitter-cli \
                && ok "tree-sitter-cli installed to ~/.local/bin" \
                || warn "tree-sitter-cli install failed — install manually: npm install -g --prefix ~/.local tree-sitter-cli"

            # Ensure ~/.local/bin is in PATH for the rest of this session
            if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
                export PATH="$HOME/.local/bin:$PATH"
            fi
        else
            warn "tree-sitter-cli >= $TS_MIN is required. Install with: npm install -g --prefix ~/.local tree-sitter-cli"
        fi
    fi

    echo ""

    # Final verification
    local failed=false
    for tool in nvim git node npm fzf yq gum curl tree-sitter; do
        if ! command -v "$tool" &>/dev/null; then
            err "$tool is still missing after install attempt"
            failed=true
        fi
    done

    if [ "$failed" = true ]; then
        err "Some dependencies could not be installed. Please install them manually."
        exit 1
    fi

    ok "All dependencies satisfied!"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Clone / update repo
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
setup_repo() {
    if [ -d "$NVIM_DIR/.git" ]; then
        # Check if it's already our repo
        local remote
        remote=$(git -C "$NVIM_DIR" remote get-url origin 2>/dev/null || true)
        if echo "$remote" | grep -q "retrofox.nvim"; then
            info "Updating existing retrofox.nvim..."
            git -C "$NVIM_DIR" pull --rebase --quiet
            ok "Repository updated"
            return
        fi
    fi

    # Backup existing config
    if [ -d "$NVIM_DIR" ]; then
        local backup="$NVIM_DIR.bak.$(date +%Y%m%d%H%M%S)"
        warn "Backing up existing config to $backup"
        mv "$NVIM_DIR" "$backup"
    fi

    info "Cloning retrofox.nvim..."
    git clone --depth 1 "$REPO" "$NVIM_DIR"
    ok "Repository cloned to $NVIM_DIR"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Interactive wizard (using gum)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
run_wizard() {
    mkdir -p "$DATA_DIR"

    # If config already exists, ask if user wants to reconfigure
    if [ -f "$CONFIG_FILE" ]; then
        if ! gum confirm "Config already exists. Reconfigure?"; then
            configure_banner
            ok "Keeping existing config"
            return
        fi
    fi

    # Start from defaults
    cp "$NVIM_DIR/config.default.yaml" "$CONFIG_FILE"

    echo ""
    gum style --border rounded --padding "1 2" --border-foreground 99 \
        "🦊 retrofox.nvim Setup Wizard"
    echo ""

    # ── Modules ──────────────────────────────────────────────
    info "Select language modules to enable (space to toggle, enter to confirm):"
    local modules
    modules=$(gum choose --no-limit --height 15 \
        "copilot" "go" "cpp" "python" "typescript" "rust" \
        "java" "docker" "markdown" "competitive_programming" \
        "json" \
    )

    for mod in copilot go cpp python typescript rust java docker json markdown competitive_programming; do
        if echo "$modules" | grep -q "^${mod}$"; then
            yq -i ".modules.${mod} = true" "$CONFIG_FILE"
        else
            yq -i ".modules.${mod} = false" "$CONFIG_FILE"
        fi
    done
    ok "Modules configured"

    # ── Colorscheme ──────────────────────────────────────────
    echo ""
    info "Choose your colorscheme:"
    local colorscheme
    colorscheme=$(gum choose --height 15 \
        "tokyonight-night" "tokyonight-storm" "tokyonight-moon" \
        "catppuccin-mocha" "catppuccin-macchiato" "catppuccin-frappe" \
        "kanagawa-wave" "kanagawa-dragon" \
        "nightfox" "duskfox" "carbonfox" \
        "rose-pine" "rose-pine-moon" \
        "github_dark" "github_dark_dimmed" \
        "everforest" "gruvbox" "gruvbox-material" \
    )
    yq -i ".appearance.colorscheme = \"$colorscheme\"" "$CONFIG_FILE"
    ok "Colorscheme: $colorscheme"

    # ── Tab width ────────────────────────────────────────────
    echo ""
    info "Tab width:"
    local tab_width
    tab_width=$(gum choose "2" "4" "8")
    yq -i ".editor.tab_width = $tab_width" "$CONFIG_FILE"
    ok "Tab width: $tab_width"

    # ── Format on save ───────────────────────────────────────
    if gum confirm "Format on save?"; then
        yq -i ".editor.format_on_save = true" "$CONFIG_FILE"
        ok "Format on save: enabled"
    else
        yq -i ".editor.format_on_save = false" "$CONFIG_FILE"
        ok "Format on save: disabled"
    fi

    echo ""
    ok "Configuration saved to $CONFIG_FILE"

    configure_banner
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Finalize
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
finalize() {
    # Compute initial checksum
    local checksum
    checksum=$(compute_checksum "$CONFIG_FILE")
    echo "$checksum" > "$CHECKSUM_FILE"
    ok "Checksum stored"

    # Step 1: Install plugins
    echo ""
    info "Bootstrapping plugins (this may take a minute)..."
    if nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1; then
        ok "Plugins installed"
    else
        warn "Plugin bootstrap reported errors. Open Neovim and run :Lazy sync if anything looks missing."
    fi

    # Step 2: Build/sync Tree-sitter parsers
    info "Syncing Tree-sitter parsers (this may take a minute)..."
    if nvim --headless "+TSUpdateSync" +qa >/dev/null 2>&1; then
        ok "Tree-sitter parsers installed"
    else
        warn "Tree-sitter parser sync failed. Install a C compiler/toolchain and run :TSUpdateSync manually."
    fi

    # Step 3: Install LSP servers via Mason
    # Mason's ensure_installed triggers automatically on startup but runs async.
    # Launch headless and give it time to download servers, then quit.
    info "Installing LSP servers via Mason (this may take a minute)..."
    if nvim --headless -c 'lua vim.defer_fn(function() vim.cmd("qa!") end, 45000)' >/dev/null 2>&1; then
        ok "LSP servers installed"
    else
        warn "Mason installation reported errors. Open Neovim and run :Mason if any tools are still missing."
    fi

    echo ""
    gum style --border rounded --padding "1 2" --border-foreground 42 \
        "🎉 retrofox.nvim is ready!" \
        "" \
        "  Config:    $CONFIG_FILE" \
        "  Checksum:  $CHECKSUM_FILE" \
        "" \
        "  Commands:" \
        "    :RetrofoxApply  — re-apply config changes" \
        "    :RetrofoxSync   — update checksum" \
        "    :RetrofoxEdit   — open config.yaml" \
        "    :ThemePicker    — switch colorschemes"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Main
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
main() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🦊 retrofox.nvim installer"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    detect_os
    info "Detected: $OS ($ARCH) — package manager: $PKG_MGR"
    echo ""

    # ── Print requirements ────────────────────────────────
    echo "Required dependencies:"
    echo "  • Neovim >= $NVIM_MIN_VERSION"
    echo "  • git, curl"
    echo "  • node and npm (for Mason LSP servers and tree-sitter-cli)"
    echo "  • fzf (fuzzy finder)"
    echo "  • yq (mikefarah/yq — YAML processing)"
    echo "  • gum (interactive TUI prompts)"
    echo "  • tree-sitter-cli >= 0.25.0 (installed via npm — nvim-treesitter parser compilation)"
    echo ""

    if [ "$AUTO_INSTALL" = true ]; then
        info "Missing dependencies will be installed automatically."
    else
        info "Auto-install disabled (--no-install). Missing deps will abort."
    fi
    echo ""

    check_deps
    setup_repo
    run_wizard
    finalize
}

main "$@"
