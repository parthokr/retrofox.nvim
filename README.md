# retrofox.nvim

This is a Neovim setup for getting work done.

The idea is simple. Keep a small core. Add language support only when you ask for it. Put the user-facing switches in one YAML file. Do not turn the editor into a pile of half-connected plugins.

If you want a setup that exposes every option for every plugin, this is not it. If you want a setup that boots, has sane defaults, and lets you turn on Python or Go without spending your night wiring Mason by hand, that is the point.

## why this exists

Most Neovim setups rot the same way. They start small, then every language gets wired in globally, then the docs turn into a plugin graveyard.

retrofox avoids that by splitting the editor into two parts:

- a core that is always there
- modules you opt into when you actually need them

That split is the useful part. It keeps the common path boring. Boring is good.

The core gives you search, file navigation, completion, diagnostics, formatting, git, terminal, Treesitter, and theme switching. Modules add language servers, formatters, linters, debuggers, and a few language-specific helpers.

Tree-sitter is part of the core here. It is not an extra. This setup depends on `nvim-treesitter` and on `tree-sitter-cli >= 0.25.0`.

## what it does well

- One real config file: `~/.local/share/retrofox/config.yaml`
- Opt-in language modules instead of one global mess
- A setup script that handles the dull parts
- A theme picker that is actually nice to use
- Clean enough defaults that you do not need to edit Lua on day one

The core strength is not some fancy plugin trick. It is the boundary between the always-on editor and the optional language layers. That is what keeps the setup understandable.

## what it will not do

Some things are out of scope on purpose.

- It is not trying to be a plugin marketplace.
- It is not trying to support every language.
- It is not trying to expose the full plugin config surface through YAML.
- It is not trying to be Windows-first.
- It is not trying to manage your whole machine.

The setup is opinionated. Thats not a bug.

## install

Guided install:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/parthokr/retrofox.nvim/main/setup.sh)
```

If you already cloned the repo:

```bash
cd ~/.config/nvim
./setup.sh
```

If you want the script to stop instead of installing missing dependencies:

```bash
./setup.sh --no-install
```

`setup.sh` is the real install path, so here is what it actually does:

1. Checks the required dependencies and installs missing ones unless you pass `--no-install`.
2. Downloads `nvim`, `fzf`, `gum`, `tree-sitter-cli`, and `yq` from GitHub releases into `/usr/local/bin` when they are missing or too old.
3. Installs `git`, `curl`, `node`, `npm`, and the C toolchain through `brew`, `apt`, `dnf`, or `pacman` when needed.
4. Clones the repo to `~/.config/nvim`, or updates it in place if that directory is already this repo.
5. Backs up an existing non-retrofox config to `~/.config/nvim.bak.<timestamp>`.
6. Creates `~/.local/share/retrofox/config.yaml` from defaults, then runs the wizard.
7. Asks for modules, extra colorscheme families, the active colorscheme, tab width, format-on-save, and the dashboard banner.
8. Bootstraps plugins, runs `:TSUpdateSync`, and gives Mason time to install language tools.

If `config.yaml` already exists, the script asks whether you want to reconfigure it. If you say no, it keeps the current file and only runs the banner step.

Manual install:

```bash
git clone https://github.com/parthokr/retrofox.nvim ~/.config/nvim
mkdir -p ~/.local/share/retrofox
cp ~/.config/nvim/config.default.yaml ~/.local/share/retrofox/config.yaml
nvim
```

That manual path assumes the required binaries are already installed.

Supported platforms are macOS and Linux. The automatic release-download path currently covers `amd64` and `arm64`. Windows is not a target here.

Main dependencies:

- Neovim `>= 0.12.0`
- `tree-sitter-cli >= 0.25.0`
- `git`
- `curl`
- Node.js and `npm`
- a working C toolchain
- [mikefarah/yq](https://github.com/mikefarah/yq)
- `fzf`
- `gum` for the setup wizard

A few details matter:

- `tree-sitter-cli >= 0.25.0` is required because this setup uses `nvim-treesitter` on its `main` branch.
- `setup.sh` installs `nvim`, `fzf`, `gum`, `tree-sitter-cli`, and `yq` from official GitHub release assets into `/usr/local/bin`.
- On Linux, the Neovim install path downloads the official AppImage release, extracts it, and installs the extracted tree under `/usr/local/neovim`.
- `git`, `curl`, `node`, `npm`, and the C toolchain still come from the system package manager.
- The `yq` dependency must be the Mike Farah one. The Python `yq` is the wrong tool for this setup.
- The C toolchain is there for parser compilation, not as a random nice-to-have.
- `node` and `npm` are here for Mason-managed language servers. They are no longer used to install `tree-sitter-cli`.

## config

For normal use, this is the file you edit:

```yaml
modules:
  python: true
  typescript: true
  json: true

editor:
  tab_width: 4
  relative_numbers: true
  format_on_save: true

appearance:
  colorscheme:
    list:
      - catppuccin
      - github
    active: "tokyonight-night"
    active_label: "Night"
```

The default file lives in [config.default.yaml](/Users/parthokr/.config/nvim/config.default.yaml).

The dashboard header is separate from `config.yaml`. If you use the installer, it lives at `~/.local/share/retrofox/banner.txt`.

Theme config has two layers:

- `appearance.colorscheme.list` is the opt-in list of extra theme families to load.
- `appearance.colorscheme.active` is the currently selected variant.

Tokyo Night and Gruvbox stay available even when the list is empty.

Useful commands:

| Command | What it does |
|---|---|
| `:RetrofoxEdit` | Open `config.yaml` |
| `:RetrofoxApply` | Reload config, clean disabled modules, refresh checksum |
| `:RetrofoxSync` | Refresh checksum without reapplying |
| `:ThemePicker` | Open the theme picker |

## modules

Modules are opt-in. When enabled, retrofox wires the editor around them and asks Mason for the LSP servers and tools Mason can actually provide.

What it does not do is install full language runtimes, SDKs, compilers, or CLIs for you. Enabling a module configures Neovim. It does not try to provision your whole stack.

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

Always-on core tools are small: `lua_ls`, `bashls`, and `stylua`.

A few plain notes:

- `gofmt` comes from the Go toolchain, not from Mason.
- C++ and Rust debugging expect a working debugger on the machine already.
- `competitive_programming` expects a local C++ compiler and `watch`.
- `copilot` still needs normal Copilot authentication on your side.

If a language is not listed here, it is outside the current scope. That may change later. It may also not. Both are fine.

## daily use

You do not need to memorize a wall of keymaps. `which-key` is already there, so hitting `<Space>` and waiting a beat will show the useful ones.

The ones worth knowing early:

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

Module-specific keys stay mostly out of the way until the module is enabled. Go and Java add the most extra surface area. Most of the rest stay pretty quiet.

## themes

This setup does spend real effort on the theme side. Not because themes are important in some grand sense, but because a bad theme switcher is annoying and Neovim has enough annoying things already.

`ThemePicker` previews variants live, stores the selected label, and keeps the surrounding UI in decent shape when you switch.

One important detail: the picker only shows theme families that are actually loaded. Tokyo Night and Gruvbox are built in. Everything else has to be listed under `appearance.colorscheme.list` first.

Theme families included right now:

- Tokyo Night
- Catppuccin
- Kanagawa
- Nightfox
- Rosé Pine
- GitHub
- Everforest
- Gruvbox
- Gruvbox Material

Changing `appearance.colorscheme.list` changes the Lazy spec, so restart Neovim after editing that list.

## layout

The load path is straight forward:

1. [init.lua](/Users/parthokr/.config/nvim/init.lua) loads startup, plugins, options, keymaps, LSP glue, and user commands.
2. [lua/retrofox/startup.lua](/Users/parthokr/.config/nvim/lua/retrofox/startup.lua) reads `config.yaml`, applies OS overlays, patches PATH for GUI launches, and handles config drift.
3. [lua/core/](/Users/parthokr/.config/nvim/lua/core) is always on.
4. [lua/modules/](/Users/parthokr/.config/nvim/lua/modules) is gated by config flags.
5. [lua/plugins/mason.lua](/Users/parthokr/.config/nvim/lua/plugins/mason.lua) installs tooling based on enabled modules.
6. [lua/plugins/colorschemes.lua](/Users/parthokr/.config/nvim/lua/plugins/colorschemes.lua) only loads the built-in theme families plus anything listed in `appearance.colorscheme.list`.

That is the part worth preserving. The code will move around over time. The split should stay.

## uninstall

There is an uninstaller:

```bash
bash ~/.config/nvim/uninstall.sh
```

It removes the cloned config, retrofox data, the Neovim data/state/cache directories, and `/usr/local/bin/yq` if `setup.sh` put it there.

One thing to be plain about: the uninstaller has not caught up with the newer release-download installs yet. If `setup.sh` installed `nvim`, `fzf`, `gum`, or `tree-sitter-cli` into `/usr/local/bin`, you still need to remove those manually.

## license

MIT
