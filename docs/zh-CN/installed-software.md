# 已安装软件

系统中所有已安装软件的完整列表。

**[English](../en/installed-software.md)**

---

## 系统工具

| 软件 | 说明 |
|------|------|
| git | 版本控制系统 |
| gcc | GNU 编译器套件 |
| gnumake | 构建自动化工具 |
| cmake | 跨平台构建系统生成器 |
| wget | 网络文件下载工具 |
| curl | URL 传输工具 |
| ntfs3g | NTFS 文件系统读写支持 |
| doas | 权限提升工具（sudo 替代品） |
| nh | NixOS 辅助工具（简化 switch 命令） |
| agagenix | NixOS 密钥管理工具 |

## Shell 和终端

| 软件 | 说明 |
|------|------|
| fish | Fish shell（默认 shell） |
| starship | 跨 shell 提示符 |
| kitty | GPU 加速终端模拟器 |
| zoxide | 智能 cd 命令（目录跳转） |
| fzf | 终端模糊查找器 |
| eza | 现代 ls 替代品 |
| fd | 现代 find 替代品 |
| ripgrep | 快速递归 grep |
| fastfetch | 系统信息显示（类似 neofetch） |
| pay-respects | 错误命令纠正建议（类似 thefuck） |

## 编辑器和 IDE

| 软件 | 说明 |
|------|------|
| nixvim | Neovim（通过 Nix 声明式配置，系统默认编辑器） |
| zed-editor | Zed 代码编辑器 |
| neovide | Neovim GUI 前端 |

详细快捷键和插件请参阅 [Neovim 文档](neovim.md)。

## 编程语言和运行时

| 软件 | 说明 |
|------|------|
| python3 | Python 3 解释器 |
| conda | Python 包和环境管理器 |
| R | R 统计计算语言（含 80+ 扩展包） |
| RStudio | R 集成开发环境 |
| texlive | TeX Live 完整发行版（LaTeX） |
| matlab | MATLAB 数值计算环境 |

### Python 包

| 包 | 说明 |
|----|------|
| pip | Python 包安装器 |
| virtualenv | Python 虚拟环境创建器 |
| numpy | 数值计算库 |
| matplotlib | 绘图库 |
| pandas | 数据分析库 |
| black | Python 代码格式化器 |

### R 包（部分）

系统包含约 80+ 个 R 包，主要包括：

- **数据处理**：tidyverse, dplyr, tidyr, readr, purrr
- **可视化**：ggplot2, plotly, gganimate
- **统计建模**：brms, lme4, caret, glmnet
- **贝叶斯分析**：cmdstanr, rstan
- **其他**：devtools, roxygen2, testthat

## 代码格式化和 LSP

| 软件 | 说明 |
|------|------|
| nixfmt | Nix 代码格式化器 |
| alejandra | Nix 代码格式化器（备选） |
| prettier | Web 语言格式化器（JS/TS/JSON/YAML/MD） |
| shfmt | Shell 脚本格式化器 |
| stylua | Lua 代码格式化器 |
| ruff | Python 代码检查和格式化器 |
| texlab | LaTeX 语言服务器 |
| tree-sitter | 语法解析器生成工具 |

## 浏览器

| 软件 | 说明 |
|------|------|
| firefox | Mozilla Firefox 网页浏览器 |
| chromium | Chromium 网页浏览器（已禁用） |
| qutebrowser | Vim 风格键盘驱动浏览器（已禁用） |

## 桌面环境

| 软件 | 说明 |
|------|------|
| niri | 可滚动平铺 Wayland 合成器 |
| waybar | Wayland 状态栏 |
| tofi | 轻量级 Wayland 菜单/启动器 |
| mako | Wayland 通知守护进程 |
| wshowkeys | 按键显示工具 |
| xwayland-satellite | XWayland 兼容层 |
| awww | Wayland 壁纸守护进程 |
| swaybg | Sway 壁纸工具 |
| kanshi | Wayland 动态显示器配置 |
| wlsunset | 蓝光过滤器 |
| wl-clipboard | Wayland 剪贴板工具 |
| wl-color-picker | Wayland 屏幕取色器 |
| wl-clip-persist | 剪贴板持久化服务 |

### 桌面 Shell（可选）

| Shell | 说明 |
|-------|------|
| DankMaterialShell | Material Design 风格，带小组件 |
| caelestia | Caelestia niri shell，支持动态壁纸 |
| noctalia-shell | Noctalia shell，带状态栏和控制中心 |

## 图形和多媒体

| 软件 | 说明 |
|------|------|
| gimp3 | GNU 图像处理程序（v3） |
| loupe | GNOME 图像查看器 |
| imagemagick | 图像处理工具集 |
| ffmpeg | 音视频处理套件 |
| kdenlive | KDE 视频编辑器 |
| obs-studio | 屏幕录制/直播工具 |
| lmms | Linux 多媒体工作室（音乐创作） |
| go-musicfox | TUI 网易云音乐客户端 |
| cava | 音频可视化器 |

## 办公和文档

| 软件 | 说明 |
|------|------|
| libreoffice | 办公套件 |
| onlyoffice-desktopeditors | OnlyOffice 文档编辑器 |
| evince | GNOME PDF/文档查看器 |
| zathura | Vim 风格文档查看器 |
| pandoc | 通用文档转换器 |

## 网络工具

| 软件 | 说明 |
|------|------|
| flclash | Clash Meta GUI 客户端（代理工具） |
| daed | 基于 eBPF 的网络代理（新一代 VPN） |
| networkmanagerapplet | NetworkManager 系统托盘小程序 |
| wemeet | 腾讯会议 |

## 社交通讯

| 软件 | 说明 |
|------|------|
| wechat | 微信即时通讯客户端 |
| telegram-desktop | Telegram 桌面客户端 |
| vesktop | Discord 客户端（内置 Vencord） |

## 游戏

| 软件 | 说明 |
|------|------|
| steam | Valve Steam 游戏平台 |
| gamemode | 游戏性能优化守护进程 |
| lutris | 开源游戏平台 |
| bottles | Windows 游戏/应用的 Wine 前缀管理器 |
| heroic | GOG、Epic 和 Amazon Games 启动器 |

## 学术工具

| 软件 | 说明 |
|------|------|
| zotero | 文献管理和引用工具 |

## AI 工具

| 软件 | 说明 |
|------|------|
| claude-code | Anthropic Claude Code CLI |
| opencode | 开源代码 AI 助手 |
| codex | OpenAI Codex CLI |
| gitingest | Git 仓库内容提取工具 |

## 容器和虚拟化

| 软件 | 说明 |
|------|------|
| docker | Docker 容器引擎（rootless 模式） |
| podman | Docker 兼容容器引擎 |
| distrobox | 基于容器的开发环境 |
| virt-manager | KVM 虚拟机 GUI 管理 |
| libvirtd | KVM/QEMU 虚拟化服务 |
| android-tools | Android ADB 和 fastboot 工具 |

## 系统工具

| 软件 | 说明 |
|------|------|
| htop | 交互式进程查看器 |
| dust | 直观的磁盘使用工具（du 替代品） |
| jq | 命令行 JSON 处理器 |
| sd | 直观的查找替换工具 |
| socat | 多用途中继工具 |
| direnv | 目录特定环境变量 |
| entr | 文件监视器 |
| nautilus | GNOME 文件管理器 |
| gparted | GNOME 分区编辑器 |
| gnome-disk-utility | GNOME 磁盘管理工具 |
| brightnessctl | 背光亮度控制 |
| upower | 电源管理客户端 |
| appimage-run | 运行 AppImage 文件 |

## 输入法

| 软件 | 说明 |
|------|------|
| fcitx5 | 输入法框架 |
| fcitx5-rime | Rime 输入法引擎 |
| fcitx5-pinyin-moegirl | 萌娘拼音词典 |
| fcitx5-pinyin-zhwiki | 中文维基拼音词典 |

## 配色方案工具

| 软件 | 说明 |
|------|------|
| lutgen | 调色板生成工具 |
| matugen | Material You 配色生成工具 |
| hellwal | 终端配色方案生成器 |

## 屏幕保护

| 软件 | 说明 |
|------|------|
| cmatrix | 黑客帝国数字雨 |
| cbonsai | 盆景树屏幕保护 |

## 系统服务

| 服务 | 说明 |
|------|------|
| greetd + tuigreet | TUI 登录管理器 |
| pipewire | 音频服务器（兼容 ALSA 和 PulseAudio） |
| blueman | 蓝牙管理器 |
| gvfs | 虚拟文件系统（回收站、挂载等） |
| openssh | SSH 服务器 |
| flatpak | Flatpak 应用支持 |
| printing | 打印支持 |
| fprintd | 指纹识别守护进程 |
| power-profiles-daemon | 电源配置切换 |

---

## 已禁用的软件

以下软件已配置但当前禁用（在配置文件中被注释掉）：

| 软件 | 说明 |
|------|------|
| chromium | Chromium 浏览器 |
| qutebrowser | Vim 风格浏览器 |
| ghostty | GPU 加速终端模拟器 |
| mango | 平铺式 Wayland 合成器（DWM 风格） |
| scroll | 可滚动 Wayland 合成器（Sway 分支） |
| COSMIC desktop | System76 COSMIC 桌面环境 |

如需启用，请在相应配置文件中取消注释，然后执行 `nh home switch` 或 `nh os switch` 重建。
