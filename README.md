# retrofox.nvim

A Neovim setup focused on a small core and opt-in language support via a single YAML configuration file.

## Features

-   One primary configuration file: `~/.local/share/retrofox/config.yaml`
-   Opt-in language modules
-   Automated setup script
-   Integrated theme picker
-   Sane defaults, minimal Lua editing required

## Scope

-   **Does:** Provides search, file navigation, completion, diagnostics, formatting, git, terminal, Treesitter, and theme switching. Modules add language servers, formatters, linters, debuggers, and language-specific helpers.
-   **Does not:** Act as a plugin marketplace, support every language, expose full plugin config via YAML, prioritize Windows, or manage your entire machine.

## Install

### Guided Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/parthokr/retrofox.nvim/main/setup.sh)
```

If repo is already cloned:

```bash
cd ~/.config/nvim
./setup.sh
```

To stop script instead of installing missing dependencies:

```bash
./setup.sh --no-install
```

`setup.sh` performs:
1.  Dependency checks and installs (unless `--no-install`).
2.  Downloads `nvim`, `fzf`, `gum`, `tree-sitter-cli`, `yq` to `/usr/local/bin` if missing/old.
3.  Installs `git`, `curl`, `node`, `npm`, C toolchain via system package manager.
4.  Clones/updates repo to `~/.config/nvim`.
5.  Backs up existing config to `~/.config/nvim.bak.<timestamp>`.
6.  Creates `~/.local/share/retrofox/config.yaml` from defaults and runs wizard.
7.  Configures modules, colorscheme, tab width, format-on-save, dashboard banner.
8.  Bootstraps plugins, runs `:TSUpdateSync`, installs Mason language tools.

If `config.yaml` exists, script asks to reconfigure; otherwise, it keeps current and runs banner step.

### Manual Install

```bash
git clone https://github.com/parthokr/retrofox.nvim ~/.config/nvim
mkdir -p ~/.local/share/retrofox
cp ~/.config/nvim/config.default.yaml ~/.local/share/retrofox/config.yaml
nvim
```
(Assumes required binaries are already installed.)

### Supported Platforms

macOS and Linux (`amd64`, `arm64`). Windows is not supported.

### Main Dependencies

-   Neovim `>= 0.12.0`
-   `tree-sitter-cli >= 0.25.0`
-   `git`
-   `curl`
-   Node.js and `npm`
-   C toolchain
-   [mikefarah/yq](https://github.com/mikefarah/yq)
-   `fzf`
-   `gum`

## Configuration

Edit `~/.local/share/retrofox/config.yaml`:

```yaml
modules:
  python: true
  typescript: true
  json: true

editor:
  tab_width: 4
  relative_numbers: true
  format_on_save: true
  colorschemes:
    families:
      - catppuccin
      - kanagawa
    active: "catppuccin-mocha:Mocha"
```

Default config: [config.default.yaml](/Users/parthokr/.config/nvim/config.default.yaml).
Dashboard header: `~/.local/share/retrofox/banner.txt`.

### Useful Commands

| Command | What it does |
|---|---|
| `:RetrofoxEdit` | Open `config.yaml` |
| `:RetrofoxApply` | Reload config, clean disabled modules, refresh checksum |
| `:RetrofoxSync` | Refresh checksum without reapplying |
| `:ThemePicker` | Open the theme picker |

## Modules

Modules are opt-in and configure Neovim; they do not install full language runtimes or SDKs.

| Module | LSP | Formatter | Linter | DAP / extras |
|---|---|---|---|---|
| `go` | `gopls` | `gofmt` | — | `delve`, `vim-go` helpers |
| `python` | `basedpyright` | `isort`, `ruff` | `ruff` | `debugpy` |
| `typescript` | `ts_ls`, `eslint` | `prettier` | — | JS/TS extras |
| `cpp` | `clangd` | `clang-format` | — | lldb auto-detect |
| `rust` | `rust_analyzer` | via LSP | — | lldb auto-detect |
| `java` | `jdtls` | `google-java-format` | — | jdtls code actions |
| `docker` | `dockerls` | — | `hadolint` | — |
| `json` | `jsonls` | `prettier` | `jsonlint` | — |
| `markdown` | — | `prettier` | `markdownlint-cli2` | render helpers |
| `copilot` | — | — | — | Copilot keymaps |
| `competitive_programming` | — | — | — | compile/run + CP layout |

Always-on core tools: `lua_ls`, `bashls`, `stylua`.

## Daily Use

Keymaps are discoverable via `which-key` (hit `<Space>`).

### Essential Keymaps

| Key | Action |
|---|---|
| `<leader>ff` | find files |
| `<leader>fg` | live grep |
| `\\` | toggle Neo-tree |
| `<leader>-` | open Oil in the parent dir |
| `gd`, `gr`, `K` | definitions, references, hover |
| `<leader>cf` | format buffer |
| `<leader>gg` | open LazyGit |
| `<C-\\>` | toggle terminal |
| `<leader>ft` | open theme picker |

## Colorschemes

Configure in `config.yaml` under `editor.colorschemes`. `families` lists installed themes, `active` sets the current theme (format: `colorscheme:variant`). `:ThemePicker` manages `active` and previews themes.

```yaml
editor:
  colorschemes:
    families:
      - catppuccin
      - kanagawa
      - nightfox
    active: "catppuccin-mocha:Mocha"
```

### Available Families

| Family | Config key | Always on |
|---|---|---|
| Tokyo Night | — | yes |
| Gruvbox | — | yes |
| Catppuccin | `catppuccin` | no |
| Kanagawa | `kanagawa` | no |
| Nightfox | `nightfox` | no |
| Rosé Pine | `rose-pine` | no |
| GitHub | `github-nvim-theme` | no |
| Everforest | `everforest` | no |
| Gruvbox Material | `gruvbox-material` | no |

## Layout

Load path:
1.  [init.lua](/Users/parthokr/.config/nvim/init.lua): Loads startup, plugins, options, keymaps, LSP, user commands.
2.  [lua/retrofox/startup.lua](/Users/parthokr/.config/nvim/lua/retrofox/startup.lua): Reads `config.yaml`, applies OS overlays, patches PATH, handles config drift.
3.  [lua/core/](/Users/parthokr/.config/nvim/lua/core): Always active.
4.  [lua/modules/](/Users/parthokr/.config/nvim/lua/modules): Gated by config flags.
5.  [lua/plugins/mason.lua](/Users/parthokr/.config/nvim/lua/plugins/mason.lua): Installs tooling based on enabled modules.

## Uninstall

```bash
bash ~/.config/nvim/uninstall.sh
```
Removes cloned config, retrofox data, Neovim data/state/cache directories, and `/usr/local/bin/yq` (if installed by `setup.sh`). Manual removal of `nvim`, `fzf`, `gum`, `tree-sitter-cli` from `/usr/local/bin` may be required if installed by `setup.sh`.

## License

MIT