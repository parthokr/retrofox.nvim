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

    ensure_usr_local_bin_in_path
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Helpers
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
info()  { printf "\033[1;34m▸\033[0m %s\n" "$1"; }
ok()    { printf "\033[1;32m✓\033[0m %s\n" "$1"; }
warn()  { printf "\033[1;33m⚠\033[0m %s\n" "$1"; }
err()   { printf "\033[1;31m✗\033[0m %s\n" "$1"; }

ensure_usr_local_bin_in_path() {
    case ":$PATH:" in
        *:/usr/local/bin:*) ;;
        *) export PATH="/usr/local/bin:$PATH" ;;
    esac
}

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

github_latest_tag() {
    local repo="$1"
    local resolved=""
    local tag=""

    resolved=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$repo/releases/latest" 2>/dev/null || true)
    if [ -n "$resolved" ]; then
        tag="${resolved##*/}"
    fi

    if [ -z "$tag" ]; then
        tag=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
            | grep -m1 '"tag_name"' \
            | sed -E 's/.*"([^"]+)".*/\1/' || true)
    fi

    if [ -z "$tag" ]; then
        err "Failed to resolve the latest release tag for $repo"
        return 1
    fi

    printf '%s\n' "$tag"
}

install_release_tarball_binary() {
    local repo="$1"
    local tag="$2"
    local asset="$3"
    local binary_name="$4"
    local tmp_dir
    local tarball_path
    local binary_path=""
    local url="https://github.com/$repo/releases/download/$tag/$asset"

    tmp_dir=$(mktemp -d)
    tarball_path="$tmp_dir/$asset"

    if ! curl -fsSL "$url" -o "$tarball_path"; then
        err "Failed to download $binary_name from $url"
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! tar -xzf "$tarball_path" -C "$tmp_dir"; then
        err "Failed to extract $asset"
        rm -rf "$tmp_dir"
        return 1
    fi

    if [ "$OS" = "darwin" ] && command -v xattr &>/dev/null; then
        xattr -rc "$tmp_dir" >/dev/null 2>&1 || true
    fi

    binary_path=$(find "$tmp_dir" -type f -name "$binary_name" 2>/dev/null | head -n1)

    if [ -z "$binary_path" ]; then
        err "Could not find $binary_name in $asset"
        rm -rf "$tmp_dir"
        return 1
    fi

    chmod u+x "$binary_path"
    ensure_usr_local_bin_in_path
    sudo mkdir -p /usr/local/bin
    sudo mv "$binary_path" "/usr/local/bin/$binary_name"
    sudo chmod 0755 "/usr/local/bin/$binary_name"
    hash -r 2>/dev/null || true

    rm -rf "$tmp_dir"
}

install_release_gzip_binary() {
    local repo="$1"
    local tag="$2"
    local asset="$3"
    local binary_name="$4"
    local tmp_dir
    local archive_path
    local binary_path
    local url="https://github.com/$repo/releases/download/$tag/$asset"

    tmp_dir=$(mktemp -d)
    archive_path="$tmp_dir/$asset"
    binary_path="$tmp_dir/$binary_name"

    if ! curl -fsSL "$url" -o "$archive_path"; then
        err "Failed to download $binary_name from $url"
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! gzip -dc "$archive_path" > "$binary_path"; then
        err "Failed to extract $asset"
        rm -rf "$tmp_dir"
        return 1
    fi

    chmod u+x "$binary_path"
    ensure_usr_local_bin_in_path
    sudo mkdir -p /usr/local/bin
    sudo mv "$binary_path" "/usr/local/bin/$binary_name"
    sudo chmod 0755 "/usr/local/bin/$binary_name"
    hash -r 2>/dev/null || true

    rm -rf "$tmp_dir"
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
        local install_dir="/usr/local/neovim"
        curl -fsSL "$release_base/$asset" -o "$appimage_path"
        chmod u+x "$appimage_path"

        # Containers and some server hosts do not expose FUSE, so we do not try
        # to execute the AppImage directly here. Treat it as a release artifact,
        # extract it, and install the real nvim binary from the extracted tree.
        info "Extracting Neovim AppImage..."
        (
            cd "$tmp_dir"
            "$appimage_path" --appimage-extract >/dev/null
        )
        if [ ! -x "$tmp_dir/squashfs-root/usr/bin/nvim" ]; then
            err "Failed to extract Neovim AppImage."
            exit 1
        fi

        sudo rm -rf "$install_dir"
        sudo mv "$tmp_dir/squashfs-root" "$install_dir"
        sudo mkdir -p /usr/local/bin
        sudo ln -sf "$install_dir/usr/bin/nvim" /usr/local/bin/nvim
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

install_fzf() {
    info "Installing fzf from GitHub releases..."

    local repo="junegunn/fzf"
    local tag=""
    local version=""
    local asset=""

    tag=$(github_latest_tag "$repo") || return 1
    version="${tag#v}"

    case "$OS:$ARCH" in
        linux:amd64)  asset="fzf-${version}-linux_amd64.tar.gz" ;;
        linux:arm64)  asset="fzf-${version}-linux_arm64.tar.gz" ;;
        darwin:amd64) asset="fzf-${version}-darwin_amd64.tar.gz" ;;
        darwin:arm64) asset="fzf-${version}-darwin_arm64.tar.gz" ;;
        *)
            err "Unsupported platform for fzf release installs: $OS/$ARCH"
            return 1
            ;;
    esac

    install_release_tarball_binary "$repo" "$tag" "$asset" "fzf" || return 1
    ok "fzf $version installed"
}

install_gum() {
    info "Installing gum from GitHub releases..."

    local repo="charmbracelet/gum"
    local tag=""
    local version=""
    local asset=""

    tag=$(github_latest_tag "$repo") || return 1
    version="${tag#v}"

    case "$OS:$ARCH" in
        linux:amd64)  asset="gum_${version}_Linux_x86_64.tar.gz" ;;
        linux:arm64)  asset="gum_${version}_Linux_arm64.tar.gz" ;;
        darwin:amd64) asset="gum_${version}_Darwin_x86_64.tar.gz" ;;
        darwin:arm64) asset="gum_${version}_Darwin_arm64.tar.gz" ;;
        *)
            err "Unsupported platform for gum release installs: $OS/$ARCH"
            return 1
            ;;
    esac

    install_release_tarball_binary "$repo" "$tag" "$asset" "gum" || return 1
    ok "gum $version installed"
}

install_tree_sitter() {
    info "Installing tree-sitter-cli from GitHub releases..."

    local repo="tree-sitter/tree-sitter"
    local tag=""
    local version=""
    local asset=""

    tag=$(github_latest_tag "$repo") || return 1
    version="${tag#v}"

    case "$OS:$ARCH" in
        linux:amd64)  asset="tree-sitter-linux-x64.gz" ;;
        linux:arm64)  asset="tree-sitter-linux-arm64.gz" ;;
        darwin:amd64) asset="tree-sitter-macos-x64.gz" ;;
        darwin:arm64) asset="tree-sitter-macos-arm64.gz" ;;
        *)
            err "Unsupported platform for tree-sitter release installs: $OS/$ARCH"
            return 1
            ;;
    esac

    install_release_gzip_binary "$repo" "$tag" "$asset" "tree-sitter" || return 1
    ok "tree-sitter-cli $version installed"
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
        warn "fzf not found"
        if [ "$AUTO_INSTALL" = true ]; then
            install_fzf || warn "Failed to install fzf — install manually from https://github.com/junegunn/fzf/releases"
        else
            err "fzf is required. Install from https://github.com/junegunn/fzf/releases"
        fi
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
            install_gum || warn "Failed to install gum — install manually from https://github.com/charmbracelet/gum/releases"
        else
            err "gum is required. Install from https://github.com/charmbracelet/gum/releases"
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
            install_tree_sitter || warn "tree-sitter-cli install failed — install manually from https://github.com/tree-sitter/tree-sitter/releases"
        else
            err "tree-sitter-cli >= $TS_MIN is required. Install from https://github.com/tree-sitter/tree-sitter/releases"
            exit 1
        fi
    fi

    echo ""

    local ts_verified=false
    if command -v tree-sitter &>/dev/null; then
        local ts_installed
        ts_installed=$(tree-sitter --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        if [ -n "$ts_installed" ] && version_gte "$ts_installed" "$TS_MIN"; then
            ts_verified=true
        else
            err "tree-sitter-cli ${ts_installed:-unknown} found but need >= $TS_MIN"
        fi
    fi

    # Final verification
    local failed=false
    for tool in nvim git node npm fzf yq gum curl tree-sitter; do
        if ! command -v "$tool" &>/dev/null; then
            err "$tool is still missing after install attempt"
            failed=true
        fi
    done

    if [ "$ts_verified" = false ]; then
        failed=true
    fi

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

    # ── Colorscheme families ─────────────────────────────────
    echo ""
    info "Choose extra colorscheme families to install:"
    info "Tokyo Night and Gruvbox are always available."
    local theme_families
    theme_families=$(gum choose --no-limit --height 12 \
        "catppuccin" "kanagawa" "nightfox" "rose-pine" \
        "github" "everforest" "gruvbox-material" \
    )
    yq -i '.appearance.colorscheme.list = []' "$CONFIG_FILE"
    for family in catppuccin kanagawa nightfox rose-pine github everforest gruvbox-material; do
        if echo "$theme_families" | grep -q "^${family}$"; then
            yq -i ".appearance.colorscheme.list += [\"$family\"]" "$CONFIG_FILE"
        fi
    done
    ok "Extra colorscheme families configured"

    # ── Active colorscheme ───────────────────────────────────
    echo ""
    info "Choose your active colorscheme:"
    local -a theme_choices=(
        "Tokyo Night | Night | tokyonight-night"
        "Tokyo Night | Storm | tokyonight-storm"
        "Tokyo Night | Moon | tokyonight-moon"
        "Tokyo Night | Day | tokyonight-day"
        "Gruvbox | Dark | gruvbox"
        "Gruvbox | Light | gruvbox"
    )

    if echo "$theme_families" | grep -q "^catppuccin$"; then
        theme_choices+=(
            "Catppuccin | Mocha | catppuccin-mocha"
            "Catppuccin | Macchiato | catppuccin-macchiato"
            "Catppuccin | Frappé | catppuccin-frappe"
            "Catppuccin | Latte | catppuccin-latte"
        )
    fi
    if echo "$theme_families" | grep -q "^kanagawa$"; then
        theme_choices+=(
            "Kanagawa | Wave | kanagawa-wave"
            "Kanagawa | Dragon | kanagawa-dragon"
            "Kanagawa | Lotus | kanagawa-lotus"
        )
    fi
    if echo "$theme_families" | grep -q "^nightfox$"; then
        theme_choices+=(
            "Nightfox | Nightfox | nightfox"
            "Nightfox | Duskfox | duskfox"
            "Nightfox | Nordfox | nordfox"
            "Nightfox | Terafox | terafox"
            "Nightfox | Carbonfox | carbonfox"
            "Nightfox | Dayfox | dayfox"
            "Nightfox | Dawnfox | dawnfox"
        )
    fi
    if echo "$theme_families" | grep -q "^rose-pine$"; then
        theme_choices+=(
            "Rosé Pine | Main | rose-pine"
            "Rosé Pine | Moon | rose-pine-moon"
            "Rosé Pine | Dawn | rose-pine-dawn"
        )
    fi
    if echo "$theme_families" | grep -q "^github$"; then
        theme_choices+=(
            "GitHub | Dark | github_dark"
            "GitHub | Dimmed | github_dark_dimmed"
            "GitHub | Hi-Con Dark | github_dark_high_contrast"
            "GitHub | Light | github_light"
            "GitHub | Light Default | github_light_default"
        )
    fi
    if echo "$theme_families" | grep -q "^everforest$"; then
        theme_choices+=(
            "Everforest | Dark Hard | everforest"
            "Everforest | Dark Medium | everforest"
            "Everforest | Dark Soft | everforest"
            "Everforest | Light Hard | everforest"
            "Everforest | Light Medium | everforest"
            "Everforest | Light Soft | everforest"
        )
    fi
    if echo "$theme_families" | grep -q "^gruvbox-material$"; then
        theme_choices+=(
            "Gruvbox Material | Dark Hard | gruvbox-material"
            "Gruvbox Material | Dark Medium | gruvbox-material"
            "Gruvbox Material | Dark Soft | gruvbox-material"
            "Gruvbox Material | Light Hard | gruvbox-material"
            "Gruvbox Material | Light Medium | gruvbox-material"
            "Gruvbox Material | Light Soft | gruvbox-material"
        )
    fi

    local colorscheme_choice
    colorscheme_choice=$(gum choose --height 20 "${theme_choices[@]}")

    local family_label=""
    local colorscheme_label=""
    local colorscheme_name=""
    IFS='|' read -r family_label colorscheme_label colorscheme_name <<< "$colorscheme_choice"
    family_label=$(printf '%s' "$family_label" | xargs)
    colorscheme_label=$(printf '%s' "$colorscheme_label" | xargs)
    colorscheme_name=$(printf '%s' "$colorscheme_name" | xargs)

    yq -i ".appearance.colorscheme.active = \"$colorscheme_name\"" "$CONFIG_FILE"
    yq -i ".appearance.colorscheme.active_label = \"$colorscheme_label\"" "$CONFIG_FILE"
    ok "Colorscheme: $family_label / $colorscheme_label"

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
    echo "  • node and npm (for Mason LSP servers)"
    echo "  • fzf (fuzzy finder)"
    echo "  • yq (mikefarah/yq — YAML processing)"
    echo "  • gum (interactive TUI prompts)"
    echo "  • tree-sitter-cli >= 0.25.0 (installed from GitHub releases)"
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
