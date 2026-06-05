# System Guide

Operation guide, keyboard shortcuts, and features of this NixOS configuration.

**[中文版](../zh-CN/system-guide.md)**

---

## Login

The system uses **greetd + tuigreet** as the login manager (TUI interface).

- Select user from the menu
- Session defaults to `niri-session` (Niri Wayland compositor)
- Previous session and user are remembered

---

## Keyboard Shortcuts

All shortcuts use **Super** (Windows/Meta key) as the primary modifier.

### Window Management

| Shortcut | Action |
|----------|--------|
| `Super + Q` | Close window |
| `Super + F` | Maximize column |
| `Super + Shift + F` | Fullscreen window |
| `Super + Ctrl + F` | Toggle windowed fullscreen |
| `Super + C` | Center column |
| `Super + Shift + Space` | Toggle floating |
| `Super + Space` | Switch focus between floating and tiling |
| `Super + R` | Switch preset column width |
| `Super + T` | Toggle column tabbed display |
| `Super + Comma` | Consume window into column |
| `Super + Period` | Expel window from column |

### Focus Navigation (Vim-style)

| Shortcut | Action |
|----------|--------|
| `Super + H / L` | Focus column left / right (or switch monitor) |
| `Super + J / K` | Focus window down / up (or switch workspace) |
| `Super + Arrow Keys` | Focus column / window in direction |

### Move Windows

| Shortcut | Action |
|----------|--------|
| `Super + Shift + H / L` | Move column left / right (or to other monitor) |
| `Super + Shift + J / K` | Move window down / up (or to other workspace) |
| `Super + Shift + Arrow Keys` | Move in direction |

### Monitor Management

| Shortcut | Action |
|----------|--------|
| `Super + Ctrl + H / J / K / L` | Focus monitor in direction |
| `Super + Shift + Ctrl + H / J / K / L` | Move window to monitor in direction |

### Workspaces

| Shortcut | Action |
|----------|--------|
| `Super + 1-9` | Switch to workspace 1-9 |
| `Super + Shift + 1-9` | Move window to workspace 1-9 |

### Resize

| Shortcut | Action |
|----------|--------|
| `Super + Minus / Equal` | Decrease / increase column width by 10% |
| `Super + Shift + Minus / Equal` | Decrease / increase window height by 10% |
| `Super + Alt + H / J / K / L` | Move floating window (10px) |

### Launchers & Applications

| Shortcut | Action |
|----------|--------|
| `Super + Return` | Open terminal (Kitty) |
| `Super + P` | Open tofi launcher (run command) |
| `Super + Shift + P` | Open tofi drun (application launcher) |
| `Super + X` | Power menu (shutdown/reboot/logout) |
| `Super + E` | hexecute (hotkey executor) |

### Screenshots & Screen Capture

| Shortcut | Action |
|----------|--------|
| `Print` | Interactive screenshot |
| `Ctrl + Print` | Screenshot entire screen |
| `Alt + Print` | Screenshot focused window |
| `Super + Alt + M` | Start screen cast (monitor) |
| `Super + Alt + W` | Start screen cast (window) |
| `Super + Alt + N` | Clear screen cast target |

### Desktop Shell

| Shortcut | Action |
|----------|--------|
| `Super + W` | Toggle overview (all workspaces) |
| `Super + B` | Toggle status bar |
| `Super + Shift + W` | Change wallpaper / color scheme |
| `Super + Shift + C` | Change color scheme (tofi) |
| `Super + Ctrl + C` | Pick color and copy to clipboard |
| `Super + Alt + C` | Open color picker (wl-color-picker) |

### Audio Controls

| Shortcut | Action |
|----------|--------|
| `XF86AudioRaiseVolume` | Volume up (+10%) |
| `XF86AudioLowerVolume` | Volume down (-10%) |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle microphone mute |

### System

| Shortcut | Action |
|----------|--------|
| `Super + Shift + R` | Restart swhkd (hotkey daemon) |
| `Super + Shift + S` | Show key overlay (wshowkeys) |

---

## Shell Commands

The system uses **Fish** shell with **Starship** prompt and **Zoxide** smart cd.

### Built-in Abbreviations

| Abbreviation | Command | Description |
|-------------|---------|-------------|
| `nixu` | `nh os switch --ask --impure` | Rebuild NixOS system |
| `homeu` | `nh home switch --ask --impure` | Rebuild Home Manager |
| `nixc` | `doas systemctl start nh-clean.service` | Clean old generations |
| `vim` | `nvim` | Open Neovim |
| `cd` | `z` | Use Zoxide for smart cd |

### Useful Commands

```bash
# System rebuild
nh os switch              # Rebuild NixOS
nh home switch            # Rebuild Home Manager
nix flake update          # Update all flake inputs
nix flake update nixpkgs  # Update nixpkgs only

# NVIDIA GPU offload
nvidia-offload glxgears   # Run program on NVIDIA GPU
nvidia-smi                # Check GPU status

# Proxy
curl -x http://127.0.0.1:7890 https://www.google.com  # Test proxy
curl -sL -o ~/.config/mihomo/config.yaml "$(cat ~/.config/age-secrets/clash_subscription_url)"  # Update subscription

# Secrets
agenix -e secrets/<name>.age  # Edit a secret

# Git
git push    # Uses token from agenix automatically
```

---

## System Features

### Niri Wayland Compositor

This system uses **Niri** as the primary desktop compositor instead of GNOME, KDE, or Hyprland.

Key characteristics:
- **Scrollable tiling** — windows are arranged in columns, scrollable horizontally
- **Column-based layout** — windows can be stacked in columns (tabbed display)
- **Dynamic workspaces** — 4 named workspaces: coding, browsing, reading, music
- **XWayland support** — X11 applications work via xwayland-satellite
- **Window rules** — specific apps open at 95% width, floating, or with special opacity
- **Rounded corners** — all windows have 10px corner radius
- **Shadows** — drop shadows on windows and launcher
- **Gradient borders** — active window borders use gradient colors from the color scheme

### Stylix Theming

The entire system uses **Stylix** for consistent theming based on base16 color schemes.

- All applications share the same color palette
- Color scheme can be changed system-wide with `Super + Shift + C`
- Wallpaper changes trigger color scheme regeneration
- Cursor theme, fonts, and GTK/Qt themes are all coordinated

### NVIDIA Hybrid Graphics (Optimus)

The laptop has dual GPUs:
- **Intel UHD Graphics 630** — primary rendering (iGPU)
- **NVIDIA GeForce GTX 1650 Mobile** — on-demand (dGPU)

To run a program on the NVIDIA GPU:

```bash
nvidia-offload <program>
# Example:
nvidia-offload steam
nvidia-offload blender
```

### Hardware Decoding

Video hardware decoding is configured for both GPUs:

**Intel iGPU (VA-API):**
- `intel-media-driver` (iHD) — primary driver for 8th gen+ Intel
- `intel-vaapi-driver` (i965) — fallback for older Intel

**NVIDIA dGPU (NVDEC):**
- `nvidia-vaapi-driver` — VA-API interface via NVDEC

**Firefox** is configured with hardware decoding enabled:
- `media.ffmpeg.vaapi.enabled = true`
- `media.hardware-video-decoding.enabled = true`

Check hardware decoding status:
```bash
vainfo                    # Check VA-API info
nvidia-smi                # Check NVIDIA GPU
```

### Proxy (Mihomo / Clash Meta)

All HTTP/HTTPS traffic is proxied through `127.0.0.1:7890` (mihomo).

- Environment variables are set system-wide (`HTTP_PROXY`, `HTTPS_PROXY`)
- nix-daemon connects directly to Chinese mirrors (tuna/ustc) without proxy
- Subscription URL is stored as an agenix secret
- A systemd timer updates the subscription daily

### Agenix Secret Management

Sensitive data is encrypted with age using SSH keys:
- `mimo_token` — Mimo AI API key
- `nix_github_token` — GitHub token (also used for git push)
- `clash_subscription_url` — Proxy subscription URL

Secrets are decrypted at build time and placed in `~/.config/age-secrets/`.

### Input Method (Fcitx5)

Chinese input is configured via Fcitx5 with:
- Rime engine
- Moegirl Pinyin
- Zhwiki Pinyin

Toggle input method with the system default key (usually `Ctrl+Space` or `Super+Space`).

### Desktop Shell Options

Three desktop shell options are available (selectable in `modules/home-manager/desktop-shell.nix`):

| Shell | Description |
|-------|-------------|
| `dankMaterialShell` | Material Design shell with widgets |
| `caelestiaShell` | Caelestia niri shell with dynamic wallpaper |
| `noctaliaShell` | Noctalia shell |

### Auto-start Programs

On login, the following start automatically:
- `swhkd` — hotkey daemon
- `awww-daemon` — wallpaper daemon
- `mihomo` — proxy
- `wlsunset` — night light (5000K-5001K, effectively disabled)
- `xwayland-satellite` — X11 compatibility

### Containers & Virtualization

- **Docker** — rootless mode with btrfs storage driver
- **Podman** — with DNS enabled
- **libvirtd** — KVM virtual machines
- **virt-manager** — GUI for VM management

---

## File Locations

| Purpose | Path |
|---------|------|
| NixOS config | `~/.config/nixos/` |
| Niri config | `~/.config/niri/` |
| swhkd config | `~/.config/swhkd/` and `~/.config/niri/swhkd/` |
| Mihomo config | `~/.config/mihomo/` |
| Secrets | `~/.config/age-secrets/` |
| Wallpapers | `~/Pictures/Wallpapers/` |
| Fish config | `~/.config/fish/` |
| Starship config | `~/.config/starship.toml` |
| Ghostty config | `~/.config/ghostty/` |
| Kitty config | `~/.config/kitty/` |
