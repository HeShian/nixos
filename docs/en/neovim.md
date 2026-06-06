# Neovim

This configuration uses [NixVim](https://github.com/nix-community/nixvim) to manage Neovim declaratively through Nix modules. No lazy.nvim or Mason needed.

**[中文版](../zh-CN/neovim.md)**

---

## Launching

- Type `nvim` in the terminal
- Use Niri keybindings in the desktop environment (see `home/programs/desktop/niri/`)

---

## Basic Operations

| Key | Action |
|-----|--------|
| `S` | Save file |
| `Q` | Close current buffer |
| `<Space>1` ~ `<Space>5` | Switch to buffer 1–5 |
| `<Space>o` | Open file explorer (mini.files) |
| `<Esc><Esc>` | Exit terminal mode |

Leader key is `Space`.

---

## File Finding (Telescope)

| Key | Action |
|-----|--------|
| `<Space>ff` | Find files |
| `<Space>fb` | Find buffers |
| `<Space>fd` | View diagnostics |
| `<Space>fr` | View registers |

---

## LSP Operations

All LSP servers are managed through Nix — no Mason required.

### Code Navigation

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Find references |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `K` | Show hover documentation |

### Code Editing

| Key | Action |
|-----|--------|
| `<Space>lr` | Rename symbol |
| `<Space>la` | Code action |
| `<Space>lf` | Find symbol |
| `<Space>lo` | Symbol outline |

### Diagnostic Navigation

| Key | Action |
|-----|--------|
| `[` | Previous diagnostic |
| `]` | Next diagnostic |
| `<Space>lE` | Show diagnostic float |

---

## Jumping (Hop)

| Key | Action |
|-----|--------|
| `<Space>hw` | Jump to word |
| `<Space>hl` | Jump to line |

---

## Moving Code (mini.move)

| Key | Action |
|-----|--------|
| `Ctrl+h` | Move left |
| `Ctrl+l` | Move right |
| `Ctrl+k` | Move up |
| `Ctrl+j` | Move down |

Also works in visual mode to move selected code blocks.

---

## AI Completion (Copilot)

| Key | Action |
|-----|--------|
| `Ctrl+l` | Accept suggestion |
| `Ctrl+Tab` | Next suggestion |
| `Ctrl+Shift+Tab` | Previous suggestion |
| `Ctrl+h` | Dismiss suggestion |

---

## Other Keybindings

| Key | Action |
|-----|--------|
| `<Space>ff` | Telescope find files |
| `<Space>fd` | Telescope diagnostics |
| `<Space>fb` | Telescope buffers |
| `<Space>m` | Minimap |

Press `<Space>` and wait — which-key will show all available keybindings.

---

## Installed LSP Servers

| Language | LSP Server | Notes |
|----------|-----------|-------|
| Python | pyright | Type checker |
| Python | ruff | Linter and formatter |
| Lua | lua_ls | Lua language server |
| Nix | nixd | Nix LS with NixOS/HM option completion |
| Nix | nil_ls | Alternative Nix LS |
| LaTeX | texlab | LaTeX language server |
| QML | qmlls | Qt QML language server |
| Markdown | harper_ls | Grammar and style checker |
| R | r_language_server | R language server |

---

## Installed Formatters

| Filetype | Formatter(s) |
|----------|-------------|
| Bash / Shell | shfmt, shellcheck, shellharden |
| CSS / SCSS / HTML / JSON | prettier |
| Lua | stylua |
| Markdown | prettier + injected |
| Nix | nixfmt + injected |
| YAML | yamlfmt |
| Python | ruff |
| LaTeX | latexindent |

Format-on-save is enabled with a 500ms timeout, falling back to LSP formatting.

---

## Installed Tree-sitter Parsers

The following languages have pre-installed syntax parsers for highlighting and indentation:

bash, fish, python, yaml, lua, json, nix, regex, toml, vim, markdown, rust, jsonc, glsl, css, hyprlang, r, diff

---

## Plugin List

### Editing
- **sleuth** — auto-detect indent settings
- **nvim-surround** — surround text objects
- **repeat** — repeat plugin actions with `.`
- **lastplace** — restore cursor to last edit position
- **nvim-autopairs** — auto-close brackets/quotes
- **endwise** — auto-add `end` (Ruby/Lua etc.)
- **markdown-preview** — preview Markdown in browser

### Completion (nvim-cmp)
- **cmp-buffer** — buffer word completion
- **cmp-path** — filesystem path completion
- **cmp-spell** — spelling suggestions
- **cmp-emoji** — emoji completion
- **cmp-nvim-lsp** — LSP completion

### LSP / Diagnostics
- **conform-nvim** — formatter runner
- **lsp-format** — LSP formatting integration
- **lspsaga** — enhanced LSP UI
- **trouble** — diagnostics list
- **lsp-signature** — function signature help
- **otter** — embedded language support

### UI
- **telescope** — fuzzy finder
- **bufferline** — tab/buffer bar
- **lualine** — statusline
- **which-key** — keybinding hints
- **gitsigns** — git change indicators
- **indent-blankline** — indent guides
- **scrollview** — scroll bar
- **web-devicons** — file icons
- **render-markdown** — rendered Markdown in editor
- **codewindow-nvim** — code minimap
- **navbuddy** — LSP symbol navigation tree
- **colorizer** — color code highlighting
- **smartcolumn** — text width guide
- **fidget** — LSP progress notifications
- **fastaction** — code action hints

### Syntax
- **treesitter** — syntax highlighting, indent, auto-install
- **hmts** — user-defined function argument highlighting
- **rainbow-delimiters** — rainbow colored brackets

### Tools
- **mini.files** — file explorer
- **mini.align** — text alignment
- **mini.hipatterns** — highlight patterns
- **mini.indentscope** — indent scope indicator
- **mini.move** — code movement
- **hop** — quick jump
- **copilot-lua** — GitHub Copilot
- **fcitx-vim** — fcitx input method support (CJK)

---

## Customization

Config files are in `home/programs/coding/nixvim/`:

| File | Contents |
|------|----------|
| `default.nix` | Main entry: global settings, base keymaps, editing plugins |
| `lsp.nix` | LSP servers, formatters, LSP UI |
| `cmp.nix` | Completion engine and sources |
| `treesitter.nix` | Tree-sitter syntax parsers |
| `ui.nix` | UI plugins (Telescope, bufferline, which-key, etc.) |
| `hop.nix` | Hop quick jump |
| `lualine.nix` | Statusline config |
| `mini.nix` | mini.nvim modules |
| `ai.nix` | Copilot AI completion |

After making changes, run `nh home switch` to rebuild.
