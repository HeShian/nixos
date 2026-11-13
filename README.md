# NixOS 配置（acer / nixos-vm）

基于 [shorin-dux-niri](https://github.com/SHORiN-KiWATA/shorin-dux-niri) 的 **niri + Dux 全家桶**（Dux Shell / Search / Files / GOP / Calendar / Greeter）桌面，使用 Den + home-manager 组织。

## 目录

```text
flake.nix                         # flake 输入与 flake-parts 入口
dotfiles/                         # 经常改的纯文本配置（活链接源）
  .config/niri/                   # niri：config / binds / windowrules / layout / animations / blur / supertab / outputs / scripts
  .config/{kitty,fish,fuzzel,mpv,satty,cava,fontconfig,matugen}/
modules/                          # import-tree 递归加载
  flake-parts.nix                   # Den 的 flake 接入（flake-parts 模块）
  nh.nix                          # perSystem：把每台 host 暴露成 `nix build .#acer`
  checks.nix                      # perSystem checks：外观值四处渲染面与唯一来源一致
  aspects/
    den.nix                       # den.hosts 声明 + den.schema
    defaults.nix                  # den.default：所有实体的全局默认
    features/                     # 10 个关注点文件；共同启用的能力合并，实际可选的能力独立
      desktop-applications.nix   # 普通应用与 Flatpak
      desktop-appearance.nix     # 字体、外观设置、首启种子、GTK 迁移
      desktop-localization.nix   # 语言、输入法、XDG 用户目录
      niri.nix                   # niri 会话与桌面音频
      dux.nix                    # Shell、Files、Greeter 与共用主题
      dotfiles.nix               # live / store 两种链接方式
      networking.nix             # NetworkManager、SSH、代理、Clash
      hardware.nix               # GPU、QEMU Guest
      system.nix                 # 系统设置与基础能力
      tools.nix                  # 系统、开发、终端工具
    roles/                        # 组合 aspect：desktop = 桌面这一组 feature 的集合
    hosts/                        # acer、nixos-vm（host aspect：硬件 + 引入哪些 aspect）
    users/                        # claudia、user-vm（user aspect：身份与 git）
  _lib/                           # 非 aspect 的辅助代码（import-tree 忽略 _ 前缀）
    appearance.nix                # 外观值唯一来源（光标、图标 fallback），见 ADR-0006
    dotfiles.nix                  # dotfiles 链接实现
```

> 目录结构参考 Den 的两个官方模板（上游 `github:denful/den`，本仓库 `flake.lock` pin 在 `bf2504f9f2e8621fee091335132ab3ae698cf808`）：
> - `templates/diagram-demo` —— `modules/aspects/{den,defaults,features,roles,hosts,users}` 的类别分层（见 ADR-0003）；
> - `templates/default` —— `modules/nh.nix` 的 perSystem 包、flake-parts 入口与 `flake-parts.nix` 的接线方式（见 ADR-0004）。

后续改进候选（含触发条件）记录在 [docs/backlog.md](docs/backlog.md)。

职责划分：

| 类型 | 位置 | 例子 |
|---|---|---|
| 固定不变 | NixOS / home-manager 模块 | 软件包、systemd 服务、字体、输入法、portal、壁纸首启种子 |
| 经常修改 | `dotfiles/`，由 HM 活链接到 `~/.config` | niri KDL、快捷键、窗口规则、脚本、kitty/fish/fuzzel 配置、matugen 模板 |
| 运行时生成 | 不纳入版本管理 | `~/.config/dms/`、`~/.local/state/dms/`、`~/.config/niri/dms/`、matugen 输出 |

## 应用配置

首次切换前建议先 `git add -A`（flake 在 git 仓库中只打包已跟踪文件；VM 的 dotfiles 软链依赖这一点）：

```bash
cd ~/nixos
git add -A

# 只构建验证（不需要 root）
nixos-rebuild build --flake .#acer

# 回归检查：评估两台 Host、构建外观值检查
nix flake check

# 正式切换
sudo nixos-rebuild switch --flake .#acer
```

重启后由 Dux Greeter 登录界面进入 niri 会话。`nixos-vm` 用同一套桌面：

```bash
nixos-rebuild build --flake .#nixos-vm
```

## 常用修改

- **快捷键 / 窗口规则 / 布局 / 动画 / 模糊**：改 `dotfiles/.config/niri/*.kdl`，保存后 niri 自动重载。
- **显示器**：改 `dotfiles/.config/niri/outputs.kdl`（不要用 DMS 的显示设置页，那里写的文件没有 include）。
- **默认程序 / shell 配置**：`dotfiles/.config/kitty/kitty.conf`、`dotfiles/.config/fish/config.fish`。
- **配色**：DMS 按壁纸生成；额外应用模板在 `dotfiles/.config/matugen/`，换壁纸后自动执行。
- **应用与默认关联**：普通应用的安装、默认关联和接线在 `desktop-applications.nix` 内按应用关注点一起维护；Dux 日历、便签与文件管理关联在 `dux.nix` 中。系统、开发与终端工具在 `tools.nix`。这些文件都在 `modules/aspects/features/`。
- **桌面依赖**：DMS 所需工具与 Dux Files 的缩略图依赖在 `dux.nix`，共用主题在 `dux.nix`，Qt / GTK 主题依赖在 `desktop-appearance.nix`。
- **录屏**：`Mod+F3` 打开菜单，可选择区域、显示器和系统声音；`Mod+Alt+F3` 直接选区。录制中再次按下任一快捷键停止。文件保存在 XDG 视频目录的 `Recordings/`。
- **文件管理**：`Mod+E` 打开 Dux Files，`Mod+Alt+E` 打开并平铺窗口。Dux Files 也负责打开和保存对话框。它的守护进程、文件选择器和默认文件关联由 `dux.nix` 中的文件管理配置 管理。
- **快捷键查询**：`Mod+Shift+/` 查看 Niri 内置帮助，`Mod+Ctrl+/` 搜索当前绑定。
- **壁纸**：登录后 DMS 里选择；首启默认壁纸由 `modules/aspects/features/desktop-appearance.nix` 中的首启种子种下。

## 主题 / 图标 / 光标

- 光标：`Bibata-Modern-Ice`，24px，装在系统 profile。值只有一处来源：`modules/_lib/appearance.nix`。它分发给
  四个渲染面 —— niri 会话变量 `XCURSOR_*`（systemd 用户服务等非 niri 子进程）、dconf（GTK）、DMS
  `settings.json` 首启种子（DMS 界面初始值）、Dux Greeter 的 compositor 配置（登录界面）—— 并生成
  `~/.config/niri/appearance.kdl` 给 niri 的 `cursor {}` 用（`include optional=true`：未激活或回滚到旧代际时
  退回 `XCURSOR_*`）。改光标只改那个文件（ADR-0006）。
- 两个作用域有意不取这个值：Dux Greeter 的 `hide-after-inactive-ms 0`（登录界面不隐藏光标）；
  matugen `folder-icons.sh` 的 `Inherits=Papirus-Dark`（缺图时的继承链，由 Dotfile 自己的 `config.toml` 调用）。
- 图标：登录界面（Dux Greeter）固定用系统 profile 里的 `Papirus-Dark`；登录后的图标主题由 matugen 的
  `folder-icons.sh` 生成 `Adwaita-Matugen-*`，写入 dconf 与 `~/.config/gtk-{3,4}.0/settings.ini`，
  DMS 设置里保持 `System Default` 跟随系统。
- `desktop-appearance.nix` 中的首启种子在首次激活时写入 DMS 默认设置，之后只补齐缺失的键。已有值可在 DMS 中修改。
- Home Manager 激活时会备份已知的 Noctalia / KDE 上代遗留到 XDG 缓存目录下的 `nixos-migration-backup/`。它移除旧样式导入、修复 Breeze 图标和光标，并保留其他用户设置。GTK 迁移与 matugen 使用同一个锁来更新图标主题。
- fcitx5 主题：DMS 的 matugen 会生成 `~/.local/share/fcitx5/themes/dms`，系统配置写 `Theme=dms`；
  DMS 生成主题后通过 D-Bus 重载 classicui（手动重启：`pkill fcitx5; fcitx5 -d` 或 `Mod+F1`）。
- GTK 3/4 的用户样式导入 Dux 生成的 `dank-colors.css`。CAVA 使用 Matugen 生成的主题。
- VS Code 的 `Dynamic Base16 DankShell` 扩展由 `desktop-applications.nix` 中的 VS Code 激活脚本执行 `vscode --install-extension` 装到可写扩展目录（不是 Home Manager 直接装包），Dux 随壁纸更新配色。已有 VS Code 用户设置可在主题菜单选用此主题。
- Fish 中的 `f` 用本地壁纸为 Kitty 中的 Fastfetch 更换图标，`fwatch` 定时刷新，`raw` 下载随机壁纸。
- `dotfiles/.config/matugen/config.toml` 的第一行必须是 `[config]`，注释里不要出现
  `[config]` / `[templates...]` 字面量，否则 DMS 截取配置时会生成非法 TOML。
- **Overview（Mod+O / Mod+G）的暗色模糊壁纸**：`desktop-appearance.nix` 中的首启种子首次把 `blurredWallpaperLayer=true`
  写进 DMS 设置；`dotfiles/.config/niri/windowrules.kdl` 里的
  `layer-rule { match namespace="dms:blurwallpaper"; place-within-backdrop true }` 把它放进 overview 的 backdrop。
  `dotfiles/.config/niri/config.kdl` 另外 `include optional=true "dms/wpblur.kdl"`（该文件由 DMS 生成，仓库里没有）。

## DMS 运行时状态

以下文件由 DMS / matugen / `desktop-appearance.nix` 与 `desktop-applications.nix` 写入，**不要软链/手改**（DMS 使用原子写，会替换符号链接）：

- `~/.config/dms/settings.json`、`clsettings.json`
- `~/.local/state/dms/session.json`
- `~/.config/niri/dms/` 下的 `binds.kdl`、`outputs.kdl`、`colors.kdl`、`alttab.kdl`、`cursor.kdl`、`windowrules.kdl`、`wpblur.kdl`（由 `config.kdl` 可选 include）
- `~/.vscode/extensions/` 的 DankShell 扩展与 `~/.config/Code/User/settings.json`（由 `desktop-applications.nix` 激活时写入）
- `~/.config/kitty/dank-theme.conf`、`dank-tabs.conf`
- `~/.config/fuzzel/colors.ini`、`~/.config/starship.toml`、`~/.config/yazi/theme.toml`、`~/.config/fastfetch/config.jsonc`、`~/.config/dgop/colors.json`
- `~/.config/cava/themes/matugen`、`~/.config/gtk-{3,4}.0/dank-colors.css`、VS Code 的 DankShell 扩展主题文件

## 登录后自检

```bash
systemctl status greetd                   # Dux Greeter
systemctl --user status dms               # Dux Shell
systemctl --user status dsearch           # Dux Search
systemctl --user status dfiles            # Dux Files
systemctl --user status dcal              # Dux Calendar
dfiles portal status                      # 文件选择器是否已由 dfiles 接管
niri msg version
dms ipc ping
```

- `Mod+Shift+/` 打开 niri 快捷键教程。
- `Mod+F10` 切换壁纸，观察 niri/kitty/fcitx5/dgop/fuzzel 的配色是否同步。
- 修改 `dotfiles/.config/niri/binds.kdl` 保存，niri 应立即热重载。

## 备注

- 复刻以当前使用的软件为基准。文件管理使用 Dux Files，系统监视使用 Dux GOP，录屏使用 wl-screenrec。

- 旧的 `umbriel` / `noctalia` 已从配置中移除；`~/.config/umbriel`、`~/.config/noctalia` 属于旧数据，可自行备份后删除。
- 系统更新、清理和系统世代回滚使用 `nh os switch`、`nh clean` 和 `nh os rollback`。这些回滚只覆盖 NixOS 世代，个人文件仍需单独备份。
- Arch 安装器、Btrfs 全盘快照、Miyu、Rime LLM、QQ Wayland 修复和 Shorin Proton Wrapper 未移植。Windows 游戏仍可在 Steam、Heroic 和 Lutris 中设置运行器。
- 现有 `~/.config/fcitx5` 若包含旧的 `classicui.conf`，会覆盖 NixOS 写入的主题设置；想使用 DMS 主题可备份该目录或用 `fcitx5-configtool` 选择 `dms` 主题。
