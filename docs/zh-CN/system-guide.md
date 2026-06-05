# 系统操作指南

操作指南、快捷键和系统特色功能。

**[English](../en/system-guide.md)**

---

## 登录

系统使用 **greetd + tuigreet** 作为登录管理器（TUI 界面）。

- 从菜单选择用户
- 默认会话为 `niri-session`（Niri Wayland 合成器）
- 会记住上次的会话和用户选择

---

## 快捷键

所有快捷键使用 **Super**（Windows/Meta 键）作为主修饰键。

### 窗口管理

| 快捷键 | 功能 |
|--------|------|
| `Super + Q` | 关闭窗口 |
| `Super + F` | 最大化列 |
| `Super + Shift + F` | 全屏窗口 |
| `Super + Ctrl + F` | 切换窗口化全屏 |
| `Super + C` | 居中列 |
| `Super + Shift + Space` | 切换浮动 |
| `Super + Space` | 在浮动和平铺之间切换焦点 |
| `Super + R` | 切换预设列宽 |
| `Super + T` | 切换列标签页显示 |
| `Super + Comma` | 将窗口合并到列中 |
| `Super + Period` | 将窗口从列中排出 |

### 焦点导航（Vim 风格）

| 快捷键 | 功能 |
|--------|------|
| `Super + H / L` | 聚焦左/右列（或切换显示器） |
| `Super + J / K` | 聚焦上/下窗口（或切换工作区） |
| `Super + 方向键` | 按方向聚焦列/窗口 |

### 移动窗口

| 快捷键 | 功能 |
|--------|------|
| `Super + Shift + H / L` | 向左/右移动列（或移动到其他显示器） |
| `Super + Shift + J / K` | 向上/下移动窗口（或移动到其他工作区） |
| `Super + Shift + 方向键` | 按方向移动 |

### 显示器管理

| 快捷键 | 功能 |
|--------|------|
| `Super + Ctrl + H / J / K / L` | 按方向聚焦显示器 |
| `Super + Shift + Ctrl + H / J / K / L` | 将窗口移动到指定方向的显示器 |

### 工作区

| 快捷键 | 功能 |
|--------|------|
| `Super + 1-9` | 切换到工作区 1-9 |
| `Super + Shift + 1-9` | 将窗口移动到工作区 1-9 |

### 调整大小

| 快捷键 | 功能 |
|--------|------|
| `Super + Minus / Equal` | 减小/增大列宽 10% |
| `Super + Shift + Minus / Equal` | 减小/增大窗口高度 10% |
| `Super + Alt + H / J / K / L` | 移动浮动窗口（10px） |

### 启动器和应用

| 快捷键 | 功能 |
|--------|------|
| `Super + Return` | 打开终端（Kitty） |
| `Super + P` | 打开 tofi 启动器（运行命令） |
| `Super + Shift + P` | 打开 tofi drun（应用启动器） |
| `Super + X` | 电源菜单（关机/重启/注销） |
| `Super + E` | hexecute（快捷键执行器） |

### 截图和屏幕录制

| 快捷键 | 功能 |
|--------|------|
| `Print` | 交互式截图 |
| `Ctrl + Print` | 截取整个屏幕 |
| `Alt + Print` | 截取当前窗口 |
| `Super + Alt + M` | 开始屏幕录制（显示器） |
| `Super + Alt + W` | 开始屏幕录制（窗口） |
| `Super + Alt + N` | 清除屏幕录制目标 |

### 桌面 Shell

| 快捷键 | 功能 |
|--------|------|
| `Super + W` | 切换概览（所有工作区） |
| `Super + B` | 切换状态栏 |
| `Super + Shift + W` | 更换壁纸/配色方案 |
| `Super + Shift + C` | 更换配色方案（tofi） |
| `Super + Ctrl + C` | 取色并复制到剪贴板 |
| `Super + Alt + C` | 打开取色器（wl-color-picker） |

### 音频控制

| 快捷键 | 功能 |
|--------|------|
| `XF86AudioRaiseVolume` | 音量增大（+10%） |
| `XF86AudioLowerVolume` | 音量减小（-10%） |
| `XF86AudioMute` | 切换静音 |
| `XF86AudioMicMute` | 切换麦克风静音 |

### 系统

| 快捷键 | 功能 |
|--------|------|
| `Super + Shift + R` | 重载 swhkd 配置 |
| `Super + Shift + S` | 显示按键叠加层（wshowkeys） |
| `Caps Lock` | 映射为 Escape |

---

## Shell 命令

系统使用 **Fish** shell，搭配 **Starship** 提示符和 **Zoxide** 智能 cd。

### 内置缩写

| 缩写 | 命令 | 说明 |
|------|------|------|
| `nixu` | `nh os switch --ask --impure` | 重建 NixOS 系统 |
| `homeu` | `nh home switch --ask --impure` | 重建 Home Manager |
| `nixc` | `doas systemctl start nh-clean.service` | 清理旧版本 |
| `vim` | `nvim` | 打开 Neovim |
| `cd` | `z` | 使用 Zoxide 智能 cd |

### 常用命令

```bash
# 系统重建
nh os switch              # 重建 NixOS
nh home switch            # 重建 Home Manager
nix flake update          # 更新所有 flake 输入
nix flake update nixpkgs  # 仅更新 nixpkgs

# NVIDIA GPU 按需使用
nvidia-offload glxgears   # 在 NVIDIA GPU 上运行程序
nvidia-smi                # 查看 GPU 状态

# 代理
curl -x http://127.0.0.1:7890 https://www.google.com  # 测试代理
curl -sL -o ~/.config/mihomo/config.yaml "$(cat ~/.config/age-secrets/clash_subscription_url)"  # 更新订阅

# 密钥管理
agenix -e secrets/<名称>.age  # 编辑密钥

# Git
git push    # 自动使用 agenix 中的 token 认证
```

---

## 系统特色功能

### Niri Wayland 合成器

系统使用 **Niri** 作为主桌面合成器，替代 GNOME、KDE 或 Hyprland。

核心特点：
- **可滚动平铺** — 窗口按列排列，可水平滚动
- **基于列的布局** — 窗口可在列中堆叠（标签页显示）
- **动态工作区** — 4 个命名工作区：coding、browsing、reading、music
- **XWayland 支持** — X11 应用通过 xwayland-satellite 运行
- **窗口规则** — 特定应用以 95% 宽度打开、浮动或特殊透明度
- **圆角窗口** — 所有窗口 10px 圆角
- **阴影** — 窗口和启动器有阴影效果
- **渐变边框** — 活动窗口边框使用配色方案的渐变色

### Stylix 主题引擎

整个系统使用 **Stylix** 进行统一配色，基于 base16 配色方案。

- 所有应用共享同一配色方案
- 可通过 `Super + Shift + C` 全局切换配色方案
- 壁纸更换会触发配色方案重新生成
- 光标主题、字体、GTK/Qt 主题全部协调一致

### NVIDIA 混合显卡（Optimus）

笔记本配备双 GPU：
- **Intel UHD Graphics 630** — 主渲染（iGPU）
- **NVIDIA GeForce GTX 1650 Mobile** — 按需使用（dGPU）

在 NVIDIA GPU 上运行程序：

```bash
nvidia-offload <程序名>
# 示例：
nvidia-offload steam
nvidia-offload blender
```

### 硬件解码

为两个 GPU 都配置了视频硬件解码：

**Intel iGPU（VA-API）：**
- `intel-media-driver`（iHD）— 第 8 代+ Intel 主驱动
- `intel-vaapi-driver`（i965）— 旧 Intel 后备驱动

**NVIDIA dGPU（NVDEC）：**
- `nvidia-vaapi-driver` — 通过 NVDEC 实现的 VA-API 接口

**Firefox** 已配置硬件解码：
- `media.ffmpeg.vaapi.enabled = true`
- `media.hardware-video-decoding.enabled = true`

检查硬件解码状态：
```bash
vainfo                    # 查看 VA-API 信息
nvidia-smi                # 查看 NVIDIA GPU
```

### 代理（Mihomo / Clash Meta）

所有 HTTP/HTTPS 流量通过 `127.0.0.1:7890`（mihomo）代理。

- 系统级环境变量设置（`HTTP_PROXY`、`HTTPS_PROXY`）
- nix-daemon 直连国内镜像（tuna/ustc），不走代理
- 订阅链接存储为 agenix 密钥
- systemd 定时器每天自动更新订阅

### Agenix 密钥管理

敏感数据使用 age 加密，基于 SSH 密钥：
- `mimo_token` — Mimo AI API 密钥
- `nix_github_token` — GitHub token（也用于 git push）
- `clash_subscription_url` — 代理订阅链接

密钥在构建时解密，放置在 `~/.config/age-secrets/`。

### 输入法（Fcitx5）

通过 Fcitx5 配置中文输入：
- Rime 引擎
- Moegirl 拼音
- Zhwiki 拼音

使用系统默认键切换输入法（通常为 `Ctrl+Space` 或 `Super+Space`）。

### 桌面 Shell 选项

三个可选的桌面 Shell（在 `modules/home-manager/desktop-shell.nix` 中选择）：

| Shell | 说明 |
|-------|------|
| `dankMaterialShell` | Material Design 风格，带小组件 |
| `caelestiaShell` | Caelestia niri shell，支持动态壁纸 |
| `noctaliaShell` | Noctalia shell |

### 自启动程序

登录后自动启动：
- `swhkd` — 快捷键守护进程
- `awww-daemon` — 壁纸守护进程
- `mihomo` — 代理
- `wlsunset` — 夜间模式（5000K-5001K，实际效果已禁用）
- `xwayland-satellite` — X11 兼容层

### 容器和虚拟化

- **Docker** — rootless 模式，btrfs 存储驱动
- **Podman** — 已启用 DNS
- **libvirtd** — KVM 虚拟机
- **virt-manager** — 虚拟机 GUI 管理

---

## 文件位置

| 用途 | 路径 |
|------|------|
| NixOS 配置 | `~/.config/nixos/` |
| Niri 配置 | `~/.config/niri/` |
| swhkd 配置 | `~/.config/swhkd/` 和 `~/.config/niri/swhkd/` |
| Mihomo 配置 | `~/.config/mihomo/` |
| 密钥文件 | `~/.config/age-secrets/` |
| 壁纸 | `~/Pictures/Wallpapers/` |
| Fish 配置 | `~/.config/fish/` |
| Starship 配置 | `~/.config/starship.toml` |
| Ghostty 配置 | `~/.config/ghostty/` |
| Kitty 配置 | `~/.config/kitty/` |
