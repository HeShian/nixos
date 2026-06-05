# 首次部署

NixOS 配置的首次部署指南。

**[English](../en/getting-started.md)**

---

## 前置条件

- 已安装 NixOS（最小 ISO 即可）
- 可用的网络连接
- 已生成 SSH 密钥对

## 第 1 步：启用 Flakes

在 `/etc/nixos/configuration.nix` 中添加：

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
```

重建系统：

```bash
sudo nixos-rebuild switch
```

## 第 2 步：生成 SSH 密钥

```bash
ssh-keygen -t ed25519 -C "<用户名>@<主机名>" -f ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub  # 保存公钥，后续步骤需要
```

## 第 3 步：克隆仓库

```bash
git clone https://github.com/HeShian/nixos ~/.config/nixos
cd ~/.config/nixos
```

## 第 4 步：创建主机配置

为你的机器创建目录：

```bash
mkdir -p hosts/<主机名>
```

### 4.1 生成硬件配置

```bash
sudo nixos-generate-config
cp /etc/nixos/hardware-configuration.nix hosts/<主机名>/
```

### 4.2 创建 `hosts/<主机名>/os.nix`

```nix
{ host, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  system.stateVersion = "<你的 NixOS 版本>";  # 例如 "26.05"
  networking.hostName = host;

  # 在此添加硬件相关配置（GPU 驱动、内核参数等）
}
```

### 4.3 创建 `hosts/<主机名>/home.nix`

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
  home.stateVersion = "<你的 NixOS 版本>";
}
```

## 第 5 步：注册主机

编辑 `hosts/hosts.nix`：

```nix
[
  {
    host = "<主机名>";
    user = "<用户名>";
    extraOSModules = [ ./<主机名>/os.nix ];
    extraHomeModules = [ ./<主机名>/home.nix ];
    extraHomeArgs = {
      nixosVersion = "unstable";
      homeManagerVersion = "master";
    };
    publicKey = "<~/.ssh/id_ed25519.pub 的内容>";
  }
]
```

## 第 6 步：配置密钥

### 6.1 更新 `secrets/secrets.nix`

```nix
let
  mykey = "<你的 SSH 公钥>";
  publicKeys = [ mykey ] ++ (map (host: host.publicKey) (import ../hosts/hosts.nix));
  secrets = [
    "mimo_token"
    "nix_github_token"
    "clash_subscription_url"
    # 根据需要添加更多密钥
  ];
in
builtins.listToAttrs (
  map (secret: {
    name = "${secret}.age";
    value = { inherit publicKeys; };
  }) secrets
)
```

### 6.2 更新 `secrets/age.nix`

```nix
{
  age.secrets = {
    mimo_token.file = ./mimo_token.age;
    nix_github_token.file = ./nix_github_token.age;
    clash_subscription_url.file = ./clash_subscription_url.age;
  };
}
```

### 6.3 加密密钥

```bash
# 安装 agenix
nix profile install github:ryantm/agenix

# 加密每个密钥（替换为你的实际值）
echo -n "你的-mimo-api-key" | age -r "<你的 SSH 公钥>" -o secrets/mimo_token.age
echo -n "你的-github-token" | age -r "<你的 SSH 公钥>" -o secrets/nix_github_token.age
echo -n "你的-clash-订阅链接" | age -r "<你的 SSH 公钥>" -o secrets/clash_subscription_url.age
```

## 第 7 步：构建部署

```bash
cd ~/.config/nixos

# 将所有文件添加到 git（flake 要求）
git add -A

# 构建并切换 NixOS 系统
sudo nixos-rebuild switch --flake .#<主机名>

# 构建并切换 Home Manager
nix run home-manager/master -- switch --flake .#<用户名>@<主机名>

# 重启以应用所有更改
sudo reboot
```

## 第 8 步：部署后配置

重启后：

```bash
# 拉取代理订阅
curl -sL -o ~/.config/mihomo/config.yaml "$(cat ~/.config/age-secrets/clash_subscription_url)"

# 验证代理工作
curl -x http://127.0.0.1:7890 https://www.google.com

# 验证 NVIDIA（如适用）
nvidia-smi
nvidia-offload glxgears
```
