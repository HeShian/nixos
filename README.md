# NixOS Declarative Configuration

A flake-parts based NixOS configuration featuring Niri Wayland compositor, Stylix theming, Agenix secret management, and Mihomo proxy.

**[中文文档](README.zh-CN.md)**

---

## Tech Stack

| Component | Technology |
|-----------|------------|
| Compositor | Niri (Wayland) |
| Shell | Fish + Starship |
| Editor | Nixvim (Neovim) |
| Terminal | Ghostty / Kitty |
| Theme | Stylix (base16) |
| Secrets | Agenix (age + SSH) |
| Proxy | Mihomo / Clash Meta |
| Input Method | Fcitx5 |
| Desktop Shell | dank-material-shell / caelestia-shell / noctalia-shell |
| Build Tool | nh |

## Quick Start

```bash
# Clone
git clone https://github.com/HeShian/nixos ~/.config/nixos
cd ~/.config/nixos

# Build system
sudo nixos-rebuild switch --flake .#<hostname>

# Build home
nix run home-manager/master -- switch --flake .#<user>@<hostname>

# Reboot
sudo reboot
```

## Daily Commands

```bash
nh os switch      # Rebuild NixOS
nh home switch    # Rebuild Home Manager
nix flake update  # Update all inputs
```

## Documentation

| Topic | English | 中文 |
|-------|---------|------|
| Getting Started | [getting-started.md](docs/en/getting-started.md) | [getting-started.md](docs/zh-CN/getting-started.md) |
| Directory Structure | [directory-structure.md](docs/en/directory-structure.md) | [directory-structure.md](docs/zh-CN/directory-structure.md) |
| Customization | [customization.md](docs/en/customization.md) | [customization.md](docs/zh-CN/customization.md) |
| Troubleshooting | [troubleshooting.md](docs/en/troubleshooting.md) | [troubleshooting.md](docs/zh-CN/troubleshooting.md) |

## License

Personal configuration. Use at your own risk.
