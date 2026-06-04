# Directory Structure & Tech Stack

Overview of the repository structure and technologies used.

**[中文版](../zh-CN/directory-structure.md)**

---

## Tech Stack

| Component | Technology |
|-----------|------------|
| Compositor | Niri (Wayland) |
| Shell | Fish + Starship |
| Editor | Nixvim (Neovim) |
| Terminal | Ghostty / Kitty |
| Theme Engine | Stylix (base16) |
| Secret Management | Agenix (age + SSH keys) |
| Proxy | Mihomo / Clash Meta |
| Input Method | Fcitx5 (Rime, Pinyin) |
| Desktop Shell | dank-material-shell / caelestia-shell / noctalia-shell |
| Build Tool | nh (Nix Helper) |

## Directory Layout

```
.
├── flake.nix                  # Flake entry point (flake-parts)
├── flake.lock                 # Pinned dependency versions
├── hosts/                     # Per-machine host definitions
│   ├── default.nix            # mkHost builder function
│   ├── hosts.nix              # Host list (name, user, modules, SSH keys)
│   └── <hostname>/            # Per-host config directory
│       ├── hardware-configuration.nix  # Auto-generated hardware config
│       ├── os.nix             # OS-level overrides (drivers, hostname)
│       └── home.nix           # Home-level overrides (monitors, cursor)
├── os/                        # System-level NixOS modules
│   ├── system/                # Core system config (boot, services, users)
│   └── programs/              # System programs (niri, tuigreet, doas)
├── home/                      # Home-manager user modules
│   ├── default.nix            # Shared home config (packages, proxy, git)
│   ├── programs/              # User programs (browsers, editors, shell, etc.)
│   ├── tweaks/                # Desktop tweaks (colorscheme, wallpaper, fcitx5)
│   └── lib/                   # Helper libraries
├── nix/                       # Nix daemon configuration
│   ├── substituters.nix       # Binary cache mirrors
│   ├── nh.nix                 # nh helper tool config
│   └── nixpkgs.nix            # Allow unfree/insecure packages
├── secrets/                   # Agenix encrypted secrets
│   ├── secrets.nix            # Secret registry (authorized keys)
│   ├── age.nix                # Secret-to-file mappings
│   └── *.age                  # Encrypted secret files
├── modules/                   # Custom home-manager modules
│   └── home-manager/          # monitors, colorscheme, wallpaper, desktop-shell
├── overlays/                  # Nixpkgs overlays
├── pkgs/                      # Custom packages (fonts, cursors, wallpapers)
└── templates/                 # Flake templates
```

## Key Files

| File | Purpose |
|------|---------|
| `hosts/hosts.nix` | Register machines: hostname, username, SSH public key, extra modules |
| `hosts/default.nix` | `mkHost` function that generates `nixosConfigurations` and `homeConfigurations` |
| `os/system/configuration.nix` | Main system config: services, packages, users, virtualisation |
| `os/system/boot.nix` | Boot loader config (GRUB with EFI) |
| `home/default.nix` | Shared user config: packages, proxy env vars, git, fcitx5 |
| `nix/substituters.nix` | Binary cache mirrors (Tsinghua, cache.nixos.org, cachix) |
| `secrets/secrets.nix` | Which SSH keys can decrypt which secrets |
| `home/programs/network/clash-meta.nix` | Proxy setup with mihomo systemd service |
| `home/programs/desktop/niri/` | Niri compositor configuration |
| `modules/home-manager/desktop-shell.nix` | Desktop shell selection |
| `home/tweaks/colorscheme.nix` | Color scheme configuration |
| `home/tweaks/wallpaper.nix` | Wallpaper configuration |

## How It Works

The `hosts/hosts.nix` file defines a list of machines. Each entry specifies:
- `host` — hostname
- `user` — username
- `extraOSModules` — system-level modules for this host
- `extraHomeModules` — user-level modules for this host
- `publicKey` — SSH public key for secret decryption

The `hosts/default.nix` `mkHost` function takes each entry and generates:
- `nixosConfigurations.<host>` — NixOS system configuration
- `homeConfigurations.<user>@<host>` — Home Manager user configuration

Shared modules (stylix, niri, nixvim, agenix, desktop shells) are automatically included. Host-specific modules are prepended, allowing per-machine overrides.
