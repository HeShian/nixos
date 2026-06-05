# Getting Started

First-time deployment guide for this NixOS configuration.

**[中文版](../zh-CN/getting-started.md)**

---

## Prerequisites

- NixOS installed (minimal ISO is fine)
- Internet connection
- SSH key pair generated

## Step 1: Enable Flakes

Add to `/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
```

Rebuild:

```bash
sudo nixos-rebuild switch
```

## Step 2: Generate SSH Key

```bash
ssh-keygen -t ed25519 -C "<user>@<hostname>" -f ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub  # Save this for later
```

## Step 3: Clone Repository

```bash
git clone https://github.com/HeShian/nixos ~/.config/nixos
cd ~/.config/nixos
```

## Step 4: Create Host Configuration

Create a directory for your machine:

```bash
mkdir -p hosts/<hostname>
```

### 4.1 Generate hardware config

```bash
sudo nixos-generate-config
cp /etc/nixos/hardware-configuration.nix hosts/<hostname>/
```

### 4.2 Create `hosts/<hostname>/os.nix`

```nix
{ host, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  system.stateVersion = "<your-nixos-version>";  # e.g. "26.05"
  networking.hostName = host;

  # Add hardware-specific config here (GPU drivers, kernel params, etc.)
}
```

### 4.3 Create `hosts/<hostname>/home.nix`

```nix
{ pkgs, ... }:
{
  monitors = {
    "eDP-1" = {
      isMain = true;
      scale = 1.0;
      mode = { width = 1920; height = 1080; refresh = 60.0; };
      position = { x = 0; y = 0; };
      rotation = 0;
      focus-at-startup = true;
    };
  };
  stylix.cursor = {
    package = pkgs.graphite-cursors;
    name = "graphite-dark";
    size = 24;
  };
  home.stateVersion = "<your-nixos-version>";
}
```

## Step 5: Register Host

Edit `hosts/hosts.nix`:

```nix
[
  {
    host = "<hostname>";
    user = "<username>";
    extraOSModules = [ ./<hostname>/os.nix ];
    extraHomeModules = [ ./<hostname>/home.nix ];
    extraHomeArgs = {
      nixosVersion = "unstable";
      homeManagerVersion = "master";
    };
    publicKey = "<contents of ~/.ssh/id_ed25519.pub>";
  }
]
```

## Step 6: Configure Secrets

### 6.1 Update `secrets/secrets.nix`

```nix
let
  mykey = "<your SSH public key>";
  publicKeys = [ mykey ] ++ (map (host: host.publicKey) (import ../hosts/hosts.nix));
  secrets = [
    "mimo_token"
    "nix_github_token"
    "clash_subscription_url"
    # Add more secrets as needed
  ];
in
builtins.listToAttrs (
  map (secret: {
    name = "${secret}.age";
    value = { inherit publicKeys; };
  }) secrets
)
```

### 6.2 Update `secrets/age.nix`

```nix
{
  age.secrets = {
    mimo_token.file = ./mimo_token.age;
    nix_github_token.file = ./nix_github_token.age;
    clash_subscription_url.file = ./clash_subscription_url.age;
  };
}
```

### 6.3 Encrypt secrets

```bash
# Install agenix
nix profile install github:ryantm/agenix

# Encrypt each secret (replace with your actual values)
echo -n "your-mimo-api-key" | age -r "<your-ssh-public-key>" -o secrets/mimo_token.age
echo -n "your-github-token" | age -r "<your-ssh-public-key>" -o secrets/nix_github_token.age
echo -n "your-clash-subscription-url" | age -r "<your-ssh-public-key>" -o secrets/clash_subscription_url.age
```

## Step 7: Build and Deploy

```bash
cd ~/.config/nixos

# Add all files to git (required for flakes)
git add -A

# Build and switch NixOS system
sudo nixos-rebuild switch --flake .#<hostname>

# Build and switch Home Manager
nix run home-manager/master -- switch --flake .#<username>@<hostname>

# Reboot to apply all changes
sudo reboot
```

## Step 8: Post-Install

After reboot:

```bash
# Pull proxy subscription
curl -sL -o ~/.config/mihomo/config.yaml "$(cat ~/.config/age-secrets/clash_subscription_url)"

# Verify proxy works
curl -x http://127.0.0.1:7890 https://www.google.com

# Verify NVIDIA (if applicable)
nvidia-smi
nvidia-offload glxgears
```
