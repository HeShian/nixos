# Customization & Daily Usage

How to customize the configuration and daily commands.

**[中文版](../zh-CN/customization.md)**

---

## Daily Commands

### System Updates

```bash
# Using nh (recommended, after first deploy)
nh os switch          # Rebuild NixOS system
nh home switch        # Rebuild Home Manager

# Or using nixos-rebuild directly
sudo nixos-rebuild switch --flake .#<hostname>
nix run home-manager/master -- switch --flake .#<user>@<hostname>
```

### Update Flake Inputs

```bash
cd ~/.config/nixos

# Update all inputs
nix flake update

# Update a specific input
nix flake update nixpkgs
nix flake update home-manager

# Rebuild after update
nh os switch
```

### NVIDIA GPU Offload

Run a program using the NVIDIA GPU:

```bash
nvidia-offload glxgears        # Test
nvidia-offload steam           # Games
nvidia-offload blender         # 3D rendering
```

### Proxy

The proxy runs at `127.0.0.1:7890` via mihomo. All HTTP/HTTPS traffic is proxied by default through environment variables.

```bash
# Check proxy status
curl -x http://127.0.0.1:7890 https://www.google.com

# Update subscription
mihomo -f "$(cat ~/.config/age-secrets/clash_subscription_url)" -d ~/.config/mihomo
```

---

## Add / Remove Packages

### System packages (all users)

Edit `os/system/configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  git
  wget
  # Add packages here
  vim
  htop
];
```

### User packages (current user only)

Edit `home/default.nix`:

```nix
home.packages = with pkgs; [
  ripgrep
  fzf
  # Add packages here
  firefox
  discord
];
```

Or create a new file in `home/programs/` and import it in `home/programs/default.nix`.

---

## Modify Desktop Environment

| What | File |
|------|------|
| Niri compositor | `home/programs/desktop/niri/default.nix` |
| Desktop shell | `modules/home-manager/desktop-shell.nix` |
| Wallpaper | `home/tweaks/wallpaper.nix` |
| Color scheme | `home/tweaks/colorscheme.nix` |
| Cursor theme | `hosts/<hostname>/home.nix` under `stylix.cursor` |
| Fonts | `os/system/fonts.nix` |

### Switch Desktop Shell

Edit `modules/home-manager/desktop-shell.nix` and set `desktopShell` to one of:
- `"dankMaterialShell"` — Material Design shell
- `"caelestiaShell"` — Caelestia niri shell
- `"noctaliaShell"` — Noctalia shell

Then rebuild: `nh home switch`

---

## Monitor Configuration

Edit `hosts/<hostname>/home.nix`:

```nix
monitors = {
  "eDP-1" = {
    isMain = true;
    scale = 1.0;
    mode = { width = 1920; height = 1080; refresh = 60.0; };
    position = { x = 0; y = 0; };
    rotation = 0;
    focus-at-startup = true;
  };
  "HDMI-A-1" = {
    scale = 1.0;
    mode = { width = 2560; height = 1440; refresh = 144.0; };
    position = { x = 1920; y = 0; };
    rotation = 0;
  };
};
```

Find monitor names with: `niri msg outputs` or `wlr-randr`

---

## Add a New Host

1. Create `hosts/<new-host>/` with `hardware-configuration.nix`, `os.nix`, `home.nix`
2. Generate SSH key on the new machine
3. Add entry to `hosts/hosts.nix`
4. Add the new SSH public key to `secrets/secrets.nix`
5. Re-encrypt secrets if needed: `agenix -re secrets/<name>.age`
6. Build: `sudo nixos-rebuild switch --flake .#<new-host>`

---

## Manage Secrets

```bash
# Edit an existing secret
agenix -e secrets/<name>.age

# Add a new secret
# 1. Add to secrets list in secrets/secrets.nix
# 2. Add to secrets/age.nix
# 3. Encrypt: echo -n "value" | age -r "<pubkey>" -o secrets/<name>.age

# Re-encrypt all secrets with updated keys
agenix -re secrets/<name>.age
```

---

## Update Git User

Edit `home/default.nix`:

```nix
programs.git.settings.user = {
  name = "your-name";
  email = "your-email@example.com";
};
```

---

## Change System Locale / Timezone

Edit `os/system/configuration.nix`:

```nix
time.timeZone = "Asia/Shanghai";
i18n.defaultLocale = "zh_CN.UTF-8";
```
