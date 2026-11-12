# dotfiles

这里的文件是**经常修改**的纯文本配置，由 home-manager 通过 `mkOutOfStoreSymlink` 活链接到 `~/.config`：

```text
~/.config/niri/config.kdl        -> <repo>/dotfiles/.config/niri/config.kdl
~/.config/niri/scripts           -> <repo>/dotfiles/.config/niri/scripts（目录软链）
~/.config/kitty/kitty.conf       -> <repo>/dotfiles/.config/kitty/kitty.conf
~/.config/fish/config.fish       -> <repo>/dotfiles/.config/fish/config.fish
~/.config/fish/functions/{f,fwatch}.fish -> ...
~/.config/fuzzel/fuzzel.ini      -> ...
~/.config/cava/config             -> ...
~/.config/mpv/config             -> ...
~/.config/satty/config.toml      -> ...
~/.config/fontconfig/fonts.conf  -> ...
~/.config/matugen/               -> <repo>/dotfiles/.config/matugen（配置与用户模板）
```

因此**直接编辑仓库里的文件即可生效**，不需要 `nixos-rebuild`：

- niri 保存后自动重载；
- kitty 重新打开窗口生效；
- fish 执行 `exec fish` 生效；
- 图标/字体配置下次登录或 `fc-cache -f` 生效。

VM（`nixos-vm`）链接的是 flake 源里的同一批文件（只读），构建时生效。

## niri 文件说明

| 文件 | 内容 |
|---|---|
| `config.kdl` | 主入口：include、environment、input、cursor、spawn-at-startup |
| `binds.kdl` | 全部快捷键（参考 shorin-dux-niri + Dux Shell 2.x IPC） |
| `windowrules.kdl` | 窗口规则（浮动、圆角、不透明度、Steam/QQ/画中画等） |
| `layout.kdl` | gaps、预设宽度、阴影、焦点环 |
| `animations.kdl` | 弹簧动画 |
| `blur.kdl` | niri 背景模糊 + xray 窗口规则 |
| `supertab.kdl` | `recent-windows` 缩略图切换器（Mod+Tab） |
| `outputs.kdl` | 显示器/缩放（**改显示器只改这里**） |
| `scripts/` | 截图音效、窗口信息、强杀、录屏、壁纸脚本 |

仓库中的 `binds.kdl` 和 `outputs.kdl` 提供默认值，Dux 设置页生成的 `dms/binds.kdl` 和 `dms/outputs.kdl` 后加载，可覆盖个别绑定和显示器设置。
布局和输入仍由本目录的配置管理。Dux 生成的配色、窗口切换、光标、窗口规则和总览背景也会加载。

## 生成文件（不要手改）

DMS 和 matugen 会覆盖这些文件：

- `~/.config/niri/dms/*.kdl`
- `~/.config/kitty/dank-theme.conf`、`dank-tabs.conf`
- `~/.config/fuzzel/colors.ini`
- `~/.config/starship.toml`
- `~/.config/yazi/theme.toml`
- `~/.config/fastfetch/config.jsonc`
- `~/.config/cava/themes/matugen`
- `~/.config/dgop/colors.json`（Dux GOP 的系统监视器配色）
- `~/.config/dms/*.json`、`~/.local/state/dms/session.json`

首次登录前这些文件可能不存在；`appearance-seed.nix` 只为 `kitty/dank-theme.conf`、`kitty/dank-tabs.conf`、`fuzzel/colors.ini` 建空占位（避免 include 失败），其余在 DMS 首次生成配色后才有。

## 脚本

脚本以 `~/.config/niri/scripts/<name>` 调用（niri 会展开 `~`）。依赖分散在多处：`packages.nix`（jq/fuzzel/fzf/slurp/grim/wl-screenrec/wl-clipboard/satty/libnotify/imagemagick 等）、`system/tools.nix`（curl/git），`dms`/`dfiles`/`pw-play` 来自系统服务与系统包：

- `screenshot-sound.sh`：由 `spawn-at-startup` 启动；截图快捷键先标记截图，剪贴板收到图片后播放快门声。
- `niri-pick`：`Mod+P`，复制窗口信息。
- `niri-force-kill-window`：`Alt+F4` / `Alt+Shift+F4`。
- `niri-binds`：`Mod+Shift+/` 在 Kitty 浮窗中用 fzf 搜索快捷键，`Mod+Ctrl+/` 在 Fuzzel 搜索。
- `screen-record`：`Mod+F3` 打开菜单，`Mod+Alt+F3` 直接选区，录制中再次按任一快捷键停止。
- `wallpaper-random`：`Mod+F10`，DMS 下一张壁纸。
- `wallpaper-download`：`Mod+Shift+F10`，下载随机壁纸并交给 DMS。
- `dfiles-tiled`：`Mod+Alt+E`，新开 Dux Files 窗口并切到平铺（dfiles 默认是浮窗）。
- `annotate-image`：`Mod+Shift+S`，标注图片——剪贴板里有图就标注它，否则先区域截图再标注（satty）。
