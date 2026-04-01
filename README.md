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

That script checks dependencies, clones the repo, asks which modules you want, writes `config.yaml`, syncs plugins, installs Treesitter parsers, and lets Mason fetch the language tools.

Manual install:

```bash
git clone https://github.com/parthokr/retrofox.nvim ~/.config/nvim
mkdir -p ~/.local/share/retrofox
cp ~/.config/nvim/config.default.yaml ~/.local/share/retrofox/config.yaml
nvim
```

Supported platforms are macOS and Linux. Windows is not a target here.

Main dependencies:

- Neovim `>= 0.12.0`
- `git`
- `curl`
- Node.js and `npm`
- a working C toolchain
- [mikefarah/yq](https://github.com/mikefarah/yq)
- `fzf`
- `gum` for the setup wizard

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
  colorscheme: "tokyonight-night"
  colorscheme_label: "Night"
```

The default file lives in [config.default.yaml](/Users/parthokr/.config/nvim/config.default.yaml).

Useful commands:

| Command | What it does |
|---|---|
| `:RetrofoxEdit` | Open `config.yaml` |
| `:RetrofoxApply` | Reload config, clean disabled modules, refresh checksum |
| `:RetrofoxSync` | Refresh checksum without reapplying |
| `:ThemePicker` | Open the theme picker |

## modules

Modules are opt-in. When enabled, retrofox installs the related tools and wires the editor around them.

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

## layout

The load path is straight forward:

1. [init.lua](/Users/parthokr/.config/nvim/init.lua) loads startup, plugins, options, keymaps, LSP glue, and user commands.
2. [lua/retrofox/startup.lua](/Users/parthokr/.config/nvim/lua/retrofox/startup.lua) reads `config.yaml`, applies OS overlays, patches PATH for GUI launches, and handles config drift.
3. [lua/core/](/Users/parthokr/.config/nvim/lua/core) is always on.
4. [lua/modules/](/Users/parthokr/.config/nvim/lua/modules) is gated by config flags.
5. [lua/plugins/mason.lua](/Users/parthokr/.config/nvim/lua/plugins/mason.lua) installs tooling based on enabled modules.

That is the part worth preserving. The code will move around over time. The split should stay.

## uninstall

There is an uninstaller:

```bash
bash ~/.config/nvim/uninstall.sh
```

It removes the cloned config, retrofox data, and the Neovim caches and state around it. System packages are left alone and printed back to you as a manual cleanup step. That is the safer choice.

## license

MIT
