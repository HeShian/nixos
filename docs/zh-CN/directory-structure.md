# 目录结构与技术栈

仓库结构和使用技术概览。

**[English](../en/directory-structure.md)**

---

## 技术栈

| 组件 | 技术 |
|------|------|
| 窗口合成器 | Niri (Wayland) |
| Shell | Fish + Starship |
| 编辑器 | Nixvim (Neovim) |
| 终端 | Ghostty / Kitty |
| 主题引擎 | Stylix (base16) |
| 密钥管理 | Agenix (age + SSH 密钥) |
| 代理 | Mihomo / Clash Meta |
| 输入法 | Fcitx5（Rime、拼音） |
| 桌面 Shell | dank-material-shell / caelestia-shell / noctalia-shell |
| 构建工具 | nh (Nix Helper) |

## 目录布局

```
.
├── flake.nix                  # Flake 入口文件（flake-parts）
├── flake.lock                 # 锁定的依赖版本
├── hosts/                     # 每台机器的主机定义
│   ├── default.nix            # mkHost 构建函数
│   ├── hosts.nix              # 主机列表（名称、用户、模块、SSH 密钥）
│   └── <主机名>/              # 每台主机的配置目录
│       ├── hardware-configuration.nix  # 自动生成的硬件配置
│       ├── os.nix             # 系统级覆盖（驱动、主机名）
│       └── home.nix           # 用户级覆盖（显示器、光标）
├── os/                        # 系统级 NixOS 模块
│   ├── system/                # 核心系统配置（启动、服务、用户）
│   └── programs/              # 系统程序（niri、tuigreet、doas）
├── home/                      # Home-manager 用户模块
│   ├── default.nix            # 共享用户配置（软件包、代理、git）
│   ├── programs/              # 用户程序（浏览器、编辑器、shell 等）
│   ├── tweaks/                # 桌面调整（配色方案、壁纸、fcitx5）
│   └── lib/                   # 辅助库
├── nix/                       # Nix 守护进程配置
│   ├── substituters.nix       # 二进制缓存镜像
│   ├── nh.nix                 # nh 辅助工具配置
│   └── nixpkgs.nix            # 允许非自由/不安全软件包
├── secrets/                   # Agenix 加密密钥
│   ├── secrets.nix            # 密钥注册（授权密钥列表）
│   ├── age.nix                # 密钥到文件的映射
│   └── *.age                  # 加密的密钥文件
├── modules/                   # 自定义 home-manager 模块
│   └── home-manager/          # 显示器、配色方案、壁纸、桌面 shell
├── overlays/                  # Nixpkgs overlays
├── pkgs/                      # 自定义软件包（字体、光标、壁纸）
└── templates/                 # Flake 模板
```

## 关键文件

| 文件 | 用途 |
|------|------|
| `hosts/hosts.nix` | 注册机器：主机名、用户名、SSH 公钥、额外模块 |
| `hosts/default.nix` | `mkHost` 函数，生成 `nixosConfigurations` 和 `homeConfigurations` |
| `os/system/configuration.nix` | 主系统配置：服务、软件包、用户、虚拟化 |
| `os/system/boot.nix` | 启动加载器配置（GRUB + EFI） |
| `home/default.nix` | 共享用户配置：软件包、代理环境变量、git、fcitx5 |
| `nix/substituters.nix` | 二进制缓存镜像（清华、cache.nixos.org、cachix） |
| `secrets/secrets.nix` | 哪些 SSH 密钥可以解密哪些密钥 |
| `home/programs/network/clash-meta.nix` | 代理配置，mihomo systemd 服务 |
| `home/programs/desktop/niri/` | Niri 合成器配置 |
| `modules/home-manager/desktop-shell.nix` | 桌面 shell 选择 |
| `home/tweaks/colorscheme.nix` | 配色方案配置 |
| `home/tweaks/wallpaper.nix` | 壁纸配置 |

## 工作原理

`hosts/hosts.nix` 文件定义了一组机器列表。每个条目指定：
- `host` — 主机名
- `user` — 用户名
- `extraOSModules` — 该主机的系统级模块
- `extraHomeModules` — 该主机的用户级模块
- `publicKey` — 用于解密密钥的 SSH 公钥

`hosts/default.nix` 中的 `mkHost` 函数处理每个条目并生成：
- `nixosConfigurations.<host>` — NixOS 系统配置
- `homeConfigurations.<user>@<host>` — Home Manager 用户配置

共享模块（stylix、niri、nixvim、agenix、桌面 shell）自动包含。主机特定模块被前置，允许按机器覆盖。
