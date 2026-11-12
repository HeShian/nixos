# NixOS 配置（acer / nixos-vm）

基于 [shorin-dux-niri](https://github.com/SHORiN-KiWATA/shorin-dux-niri) 的 **niri + Dux 全家桶**（Dux Shell / Search / Files / GOP / Calendar / Greeter）桌面，使用 Den + home-manager 组织。

## 目录

```text
flake.nix                         # flake 输入与 Den 求值
dotfiles/                         # 经常改的纯文本配置（活链接源）
  .config/niri/                   # niri：binds / windowrules / layout / animations / blur / outputs / scripts
  .config/{kitty,fish,fuzzel,mpv,satty,fontconfig,matugen}/
modules/
  aspects/desktop/                # 桌面相关 aspect（NixOS + HM）
  aspects/system|network/         # 系统、网络
  hosts/                          # acer / nixos-vm
  users/                          # claudia / user-vm
```

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
- **软件包**：`modules/aspects/desktop/applications.nix`（用户包）、`modules/aspects/desktop/dux-shell.nix`（服务）。
- **录屏**：`Mod+F3` 打开菜单，可选择区域、显示器和系统声音；`Mod+Alt+F3` 直接选区。录制中再次按下任一快捷键停止。文件保存在 XDG 视频目录的 `Recordings/`。
- **文件管理**：`Mod+E` 打开 Dux Files，`Mod+Alt+E` 打开并平铺窗口。Dux Files 也负责打开和保存对话框。
- **快捷键查询**：`Mod+Shift+/` 查看 Niri 内置帮助，`Mod+Ctrl+/` 搜索当前绑定。
- **壁纸**：登录后 DMS 里选择；首启默认壁纸由 `modules/aspects/desktop/appearance.nix` 种下。

## 主题 / 图标 / 光标

- 图标：`Papirus-Dark`；光标：`Bibata-Modern-Ice`，24px。两者装在系统 profile（Dux Greeter 也能用），
  由 dconf + `~/.config/gtk-3.0/settings.ini` + niri `cursor {}` 三处保持一致。
- DMS 的图标/光标默认值由 `appearance.nix` 首次写入 `~/.config/dms/settings.json`；之后可在 DMS 设置里改。
- 旧桌面留下的 `gtk.css`（`@import noctalia.css`）和失效的 `breeze` / `breeze_cursors`
  会在 HM 激活时自动备份到 `~/.cache/nixos-migration-backup/` 并替换为 Papirus/Bibata。
- fcitx5 主题：DMS 的 matugen 会生成 `~/.local/share/fcitx5/themes/dms`，系统配置写 `Theme=dms`；
  DMS 生成主题后通过 D-Bus 重载 classicui（手动重启：`pkill fcitx5; fcitx5 -d` 或 `Mod+F1`）。
- GTK 3/4 的用户样式导入 Dux 生成的 `dank-colors.css`。CAVA 使用 Matugen 生成的主题。
- VS Code 的 `Dynamic Base16 DankShell` 扩展由 Home Manager 从固定版本安装到可写扩展目录，Dux 随壁纸更新配色。已有 VS Code 用户设置可在主题菜单选用此主题。
- Fish 中的 `f` 用本地壁纸为 Kitty 中的 Fastfetch 更换图标，`fwatch` 定时刷新，`raw` 下载随机壁纸。
- `dotfiles/.config/matugen/config.toml` 的第一行必须是 `[config]`，注释里不要出现
  `[config]` / `[templates...]` 字面量，否则 DMS 截取配置时会生成非法 TOML。
- **Overview（Mod+O / Mod+G）的暗色模糊壁纸**：DMS 的 `dms:blurwallpaper` 背景层需要
  `blurredWallpaperLayer=true`，并通过 `include optional=true "dms/wpblur.kdl"` 让 niri
  把它放进 overview 的 backdrop。两个开关由 `appearance.nix` 首次写入 DMS 设置，
  niri 的 include 在 `dotfiles/.config/niri/config.kdl` 里。

## DMS 运行时状态

以下文件由 DMS 自己写入，**不要软链/手改**（DMS 使用原子写，会替换符号链接）：

- `~/.config/dms/settings.json`、`clsettings.json`
- `~/.local/state/dms/session.json`
- `~/.config/niri/dms/colors.kdl`、`alttab.kdl`、`cursor.kdl`、`windowrules.kdl`（由 `config.kdl` 可选 include）
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
