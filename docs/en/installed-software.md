# Installed Software

Complete list of all installed software in the system.

**[中文版](../zh-CN/installed-software.md)**

---

## System Tools

| Software | Description |
|----------|-------------|
| git | Version control system |
| gcc | GNU Compiler Collection |
| gnumake | Build automation tool |
| cmake | Cross-platform build system generator |
| wget | Network file retriever |
| curl | URL transfer tool |
| ntfs3g | NTFS filesystem read/write support |
| doas | Privilege escalation tool (sudo alternative) |
| nh | NixOS helper (simplified switch commands) |
| agenix | NixOS secret management tool |

## Shell & Terminal

| Software | Description |
|----------|-------------|
| fish | Fish shell (default shell) |
| starship | Cross-shell prompt |
| kitty | GPU-accelerated terminal emulator |
| zoxide | Smarter `cd` command (directory jumper) |
| fzf | Terminal fuzzy finder |
| eza | Modern replacement for `ls` |
| fd | Modern replacement for `find` |
| ripgrep | Fast recursive grep |
| fastfetch | System information display (like neofetch) |
| pay-respects | Wrong command correction suggestions (like thefuck) |

## Editors & IDE

| Software | Description |
|----------|-------------|
| nixvim | Neovim (declaratively configured via Nix, system default editor) |
| zed-editor | Zed code editor |
| neovide | Neovim GUI frontend |

See [Neovim documentation](neovim.md) for detailed keybindings and plugins.

## Programming Languages & Runtimes

| Software | Description |
|----------|-------------|
| python3 | Python 3 interpreter |
| conda | Python package and environment manager |
| R | R statistical computing language (with 80+ packages) |
| RStudio | R integrated development environment |
| texlive | Full TeX Live distribution (LaTeX) |
| matlab | MATLAB numerical computing environment |

### Python Packages

| Package | Description |
|---------|-------------|
| pip | Python package installer |
| virtualenv | Python virtual environment creator |
| numpy | Numerical computing library |
| matplotlib | Plotting library |
| pandas | Data analysis library |
| black | Python code formatter |

### R Packages (partial)

The system includes ~80+ R packages, mainly:

- **Data processing**: tidyverse, dplyr, tidyr, readr, purrr
- **Visualization**: ggplot2, plotly, gganimate
- **Statistical modeling**: brms, lme4, caret, glmnet
- **Bayesian analysis**: cmdstanr, rstan
- **Other**: devtools, roxygen2, testthat

## Code Formatting & LSP

| Software | Description |
|----------|-------------|
| nixfmt | Nix code formatter |
| alejandra | Nix code formatter (alternative) |
| prettier | Web language formatter (JS/TS/JSON/YAML/MD) |
| shfmt | Shell script formatter |
| stylua | Lua code formatter |
| ruff | Python linter and formatter |
| texlab | LaTeX language server |
| tree-sitter | Parser generator tool |

## Browsers

| Software | Description |
|----------|-------------|
| firefox | Mozilla Firefox web browser |
| chromium | Chromium web browser (disabled) |
| qutebrowser | Vim-style keyboard-driven browser (disabled) |

## Desktop Environment

| Software | Description |
|----------|-------------|
| niri | Scrollable tiling Wayland compositor |
| waybar | Wayland status bar |
| tofi | Lightweight Wayland menu/launcher |
| mako | Wayland notification daemon |
| wshowkeys | Key press display tool |
| xwayland-satellite | XWayland compatibility layer |
| awww | Wayland wallpaper daemon |
| swaybg | Sway wallpaper tool |
| kanshi | Dynamic display configuration for Wayland |
| wlsunset | Blue light filter |
| wl-clipboard | Wayland clipboard utilities |
| wl-color-picker | Wayland screen color picker |
| wl-clip-persist | Clipboard persistence service |

### Desktop Shells (selectable)

| Shell | Description |
|-------|-------------|
| DankMaterialShell | Material Design shell with widgets |
| caelestia | Caelestia niri shell with dynamic wallpaper |
| noctalia-shell | Noctalia shell with bar and control center |

## Graphics & Multimedia

| Software | Description |
|----------|-------------|
| gimp3 | GNU Image Manipulation Program (v3) |
| loupe | GNOME image viewer |
| imagemagick | Image manipulation toolkit |
| ffmpeg | Audio/video processing suite |
| kdenlive | KDE video editor |
| obs-studio | Screen recording/streaming tool |
| lmms | Linux MultiMedia Studio (music creation) |
| go-musicfox | TUI NetEase Cloud Music client |
| cava | Audio visualizer |

## Office & Documents

| Software | Description |
|----------|-------------|
| libreoffice | Office suite |
| onlyoffice-desktopeditors | OnlyOffice document editors |
| evince | GNOME PDF/document viewer |
| zathura | Vim-like document viewer |
| pandoc | Universal document converter |

## Network Tools

| Software | Description |
|----------|-------------|
| flclash | Clash Meta GUI client (proxy tool) |
| daed | eBPF-based network proxy (next-gen VPN) |
| networkmanagerapplet | NetworkManager system tray applet |
| wemeet | Tencent WeMeet video conferencing |

## Messaging & Social

| Software | Description |
|----------|-------------|
| wechat | WeChat messaging client |
| telegram-desktop | Telegram desktop client |
| vesktop | Discord client with Vencord |

## Gaming

| Software | Description |
|----------|-------------|
| steam | Valve Steam gaming platform |
| gamemode | Game performance optimization daemon |
| lutris | Open-source gaming platform |
| bottles | Wine prefix manager for Windows games/apps |
| heroic | GOG, Epic, and Amazon Games launcher |

## Academic Tools

| Software | Description |
|----------|-------------|
| zotero | Reference and citation manager |

## AI Tools

| Software | Description |
|----------|-------------|
| claude-code | Anthropic Claude Code CLI |
| opencode | Open-source code AI assistant |
| codex | OpenAI Codex CLI |
| gitingest | Git repository content extraction tool |

## Containers & Virtualization

| Software | Description |
|----------|-------------|
| docker | Docker container engine (rootless mode) |
| podman | Docker-compatible container engine |
| distrobox | Container-based development environments |
| virt-manager | KVM virtual machine GUI manager |
| libvirtd | KVM/QEMU virtualization service |
| android-tools | Android ADB and fastboot tools |

## System Utilities

| Software | Description |
|----------|-------------|
| htop | Interactive process viewer |
| dust | Intuitive disk usage tool (du alternative) |
| jq | Command-line JSON processor |
| sd | Intuitive find-and-replace tool |
| socat | Multipurpose relay tool |
| direnv | Directory-specific environment variables |
| entr | File watcher |
| nautilus | GNOME file manager |
| gparted | GNOME partition editor |
| gnome-disk-utility | GNOME disk management tool |
| brightnessctl | Backlight brightness control |
| upower | Power management client |
| appimage-run | Run AppImage files |

## Input Method

| Software | Description |
|----------|-------------|
| fcitx5 | Input method framework |
| fcitx5-rime | Rime input method engine |
| fcitx5-pinyin-moegirl | Moegirl pinyin dictionary |
| fcitx5-pinyin-zhwiki | ZHWiki pinyin dictionary |

## Color Scheme Tools

| Software | Description |
|----------|-------------|
| lutgen | Color palette generation tool |
| matugen | Material You color generation tool |
| hellwal | Terminal color scheme generator |

## Screen Savers

| Software | Description |
|----------|-------------|
| cmatrix | The Matrix digital rain |
| cbonsai | Bonsai tree screen saver |

## System Services

| Service | Description |
|---------|-------------|
| greetd + tuigreet | TUI login manager |
| pipewire | Audio server (ALSA and PulseAudio compatible) |
| blueman | Bluetooth manager |
| gvfs | Virtual filesystem (trash, mount, etc.) |
| openssh | SSH server |
| flatpak | Flatpak app support |
| printing | Printing support |
| fprintd | Fingerprint reader daemon |
| power-profiles-daemon | Power profile switching |

---

## Disabled Software

The following software is configured but currently disabled (commented out in config files):

| Software | Description |
|----------|-------------|
| chromium | Chromium browser |
| qutebrowser | Vim-style browser |
| ghostty | GPU-accelerated terminal emulator |
| mango | Tiling Wayland compositor (DWM-like) |
| scroll | Scrollable Wayland compositor (Sway fork) |
| COSMIC desktop | System76 COSMIC desktop environment |

To enable, uncomment the relevant config file and rebuild with `nh home switch` or `nh os switch`.
