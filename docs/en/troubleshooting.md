# Troubleshooting

Common issues and solutions.

**[中文版](../zh-CN/troubleshooting.md)**

---

## Build Fails Due to Network Issues

If mirrors are slow or returning SSL errors:

```bash
# Check which mirror is problematic
curl -sL -o /dev/null -w "%{http_code}" https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store/nix-cache-info

# Remove problematic mirror from nix/substituters.nix
# Then restart nix-daemon
sudo systemctl restart nix-daemon
```

## Hash Mismatch on Fetchurl

If a downloaded file has changed (e.g., wallpaper images):

```bash
# Get the correct hash
nix-prefetch-url <url>

# Update the hash in the corresponding .nix file
```

## Proxy Not Working

```bash
# Check if mihomo is running
systemctl --user status mihomo

# Check if port 7890 is listening
ss -tlnp | grep 7890

# Restart mihomo
systemctl --user restart mihomo
```

## NVIDIA GPU Not Detected

```bash
# Check if nvidia module is loaded
lsmod | grep nvidia

# Check nvidia-smi
nvidia-smi

# If not working, verify hosts/<hostname>/os.nix has correct bus IDs
# Find your bus IDs:
lspci | grep -E "VGA|3D"
```

## Input Method Not Working

```bash
# Check fcitx5 status
fcitx5-diagnose

# Ensure environment variables are set
echo $XMODIFIERS  # Should be @im=fcitx
echo $GTK_IM_MODULE
echo $QT_IM_MODULE

# Restart fcitx5
systemctl --user restart fcitx5-daemon
```

## Boot Loader Issues

If GRUB is not showing after switching from systemd-boot:

```bash
# Install GRUB manually
sudo $(find /nix/store -name "grub-install" -type f | head -1) \
  --target=x86_64-efi \
  --efi-directory=/boot \
  --bootloader-id=NixOS \
  --recheck

# Set GRUB as first boot option
sudo $(find /nix/store -name "efibootmgr" -type f | head -1) -o 0002,0001
```

## Secrets Not Decrypting

```bash
# Check if your SSH key is authorized
cat ~/.ssh/id_ed25519.pub

# Verify it matches the key in secrets/secrets.nix

# Test decryption
age -d -i ~/.ssh/id_ed25519 secrets/mimo_token.age
```

## Home Manager Activation Fails

If existing files conflict:

```bash
# Back up conflicting files
mv ~/.config/fish/config.fish ~/.config/fish/config.fish.bak

# Retry
nh home switch
```

## Flake Evaluation Errors

If you see `experimental Nix feature 'pipe-operators' is disabled`:

```bash
# Ensure pipe-operators is enabled in /etc/nixos/configuration.nix
nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
sudo nixos-rebuild switch
```

If you see `Path '...' in the repository is not tracked by Git`:

```bash
# Add new files to git
git add -A
```
