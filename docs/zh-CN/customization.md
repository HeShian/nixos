# 自定义与日常使用

如何自定义配置和日常命令。

**[English](../en/customization.md)**

---

## 日常命令

### 系统更新

```bash
# 使用 nh（推荐，首次部署后可用）
nh os switch          # 重建 NixOS 系统
nh home switch        # 重建 Home Manager

# 或直接使用 nixos-rebuild
sudo nixos-rebuild switch --flake .#<主机名>
nix run home-manager/master -- switch --flake .#<用户名>@<主机名>
```

### 更新 Flake 输入

```bash
cd ~/.config/nixos

# 更新所有输入
nix flake update

# 更新特定输入
nix flake update nixpkgs
nix flake update home-manager

# 更新后重建
nh os switch
```

### NVIDIA GPU 按需使用

使用 NVIDIA GPU 运行程序：

```bash
nvidia-offload glxgears        # 测试
nvidia-offload steam           # 游戏
nvidia-offload blender         # 3D 渲染
```

### 代理

代理通过 mihomo 运行在 `127.0.0.1:7890`。所有 HTTP/HTTPS 流量默认通过环境变量代理。

```bash
# 检查代理状态
curl -x http://127.0.0.1:7890 https://www.google.com

# 更新订阅
mihomo -f "$(cat ~/.config/age-secrets/clash_subscription_url)" -d ~/.config/mihomo
```

---

## 添加 / 删除软件包

### 系统软件包（所有用户可用）

编辑 `os/system/configuration.nix`：

```nix
environment.systemPackages = with pkgs; [
  git
  wget
  # 在此添加软件包
  vim
  htop
];
```

### 用户软件包（仅当前用户）

编辑 `home/default.nix`：

```nix
home.packages = with pkgs; [
  ripgrep
  fzf
  # 在此添加软件包
  firefox
  discord
];
```

或在 `home/programs/` 中创建新文件，并在 `home/programs/default.nix` 中导入。

---

## 修改桌面环境

| 内容 | 文件 |
|------|------|
| Niri 合成器 | `home/programs/desktop/niri/default.nix` |
| 桌面 Shell | `modules/home-manager/desktop-shell.nix` |
| 壁纸 | `home/tweaks/wallpaper.nix` |
| 配色方案 | `home/tweaks/colorscheme.nix` |
| 光标主题 | `hosts/<主机名>/home.nix` 中的 `stylix.cursor` |
| 字体 | `os/system/fonts.nix` |

### 切换桌面 Shell

编辑 `modules/home-manager/desktop-shell.nix`，将 `desktopShell` 设置为以下之一：
- `"dankMaterialShell"` — Material Design 风格
- `"caelestiaShell"` — Caelestia niri shell
- `"noctaliaShell"` — Noctalia shell

然后重建：`nh home switch`

---

## 显示器配置

编辑 `hosts/<主机名>/home.nix`：

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

获取显示器名称：`niri msg outputs` 或 `wlr-randr`

---

## 添加新主机

1. 创建 `hosts/<新主机名>/` 目录，包含 `hardware-configuration.nix`、`os.nix`、`home.nix`
2. 在新机器上生成 SSH 密钥
3. 在 `hosts/hosts.nix` 中添加条目
4. 在 `secrets/secrets.nix` 中添加新的 SSH 公钥
5. 如需要，重新加密密钥：`agenix -re secrets/<名称>.age`
6. 构建：`sudo nixos-rebuild switch --flake .#<新主机名>`

---

## 管理密钥

```bash
# 编辑现有密钥
agenix -e secrets/<名称>.age

# 添加新密钥
# 1. 在 secrets/secrets.nix 的 secrets 列表中添加
# 2. 在 secrets/age.nix 中添加
# 3. 加密：echo -n "值" | age -r "<公钥>" -o secrets/<名称>.age

# 使用更新的密钥重新加密所有密钥
agenix -re secrets/<名称>.age
```

---

## 更新 Git 用户信息

编辑 `home/default.nix`：

```nix
programs.git.settings.user = {
  name = "你的名字";
  email = "your-email@example.com";
};
```

---

## 更改系统语言 / 时区

编辑 `os/system/configuration.nix`：

```nix
time.timeZone = "Asia/Shanghai";
i18n.defaultLocale = "zh_CN.UTF-8";
```
