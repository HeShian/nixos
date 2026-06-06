# NixOS 声明式配置

基于 flake-parts 的 NixOS 声明式配置，使用 Niri Wayland 合成器、Stylix 主题引擎、Agenix 密钥管理和 Mihomo 代理。

**[English](README.md)**

---

## 技术栈

| 组件 | 技术 |
|------|------|
| 窗口合成器 | Niri (Wayland) |
| Shell | Fish + Starship |
| 编辑器 | Nixvim (Neovim) |
| 终端 | Ghostty / Kitty |
| 主题引擎 | Stylix (base16) |
| 密钥管理 | Agenix (age + SSH) |
| 代理 | Mihomo / Clash Meta |
| 输入法 | Fcitx5 |
| 桌面 Shell | dank-material-shell / caelestia-shell / noctalia-shell |
| 显卡 | NVIDIA GTX 1650 + Intel UHD 630（Optimus） |
| 硬件解码 | Intel VAAPI + NVIDIA NVDEC |
| 构建工具 | nh |

## 快速开始

```bash
# 克隆
git clone https://github.com/HeShian/nixos ~/.config/nixos
cd ~/.config/nixos

# 构建系统
sudo nixos-rebuild switch --flake .#<主机名>

# 构建用户配置
nix run home-manager/master -- switch --flake .#<用户名>@<主机名>

# 重启
sudo reboot
```

## 日常命令

```bash
nh os switch      # 重建 NixOS
nh home switch    # 重建 Home Manager
nix flake update  # 更新所有输入
```

## 文档

| 主题 | English | 中文 |
|------|---------|------|
| 首次部署 | [getting-started.md](docs/en/getting-started.md) | [getting-started.md](docs/zh-CN/getting-started.md) |
| 目录结构 | [directory-structure.md](docs/en/directory-structure.md) | [directory-structure.md](docs/zh-CN/directory-structure.md) |
| 自定义指南 | [customization.md](docs/en/customization.md) | [customization.md](docs/zh-CN/customization.md) |
| 故障排除 | [troubleshooting.md](docs/en/troubleshooting.md) | [troubleshooting.md](docs/zh-CN/troubleshooting.md) |
| Neovim | [neovim.md](docs/en/neovim.md) | [neovim.md](docs/zh-CN/neovim.md) |
| 已安装软件 | [installed-software.md](docs/en/installed-software.md) | [installed-software.md](docs/zh-CN/installed-software.md) |
| **系统指南** | [system-guide.md](docs/en/system-guide.md) | [system-guide.md](docs/zh-CN/system-guide.md) |

## 许可证

个人配置，使用风险自担。
