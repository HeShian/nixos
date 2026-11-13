# Dotfile 链接条目由目录树生成

Status: accepted

`modules/_lib/dotfiles.nix` 原先手写 19 条 `xdg.configFile` 条目（17 个文件 + `niri/scripts`、`matugen` 两个目录级）。它的 interface 就是这份枚举：新增 Dotfile 不报错、只是静默不链接，粒度也不一致。

## 决定

1. 条目由 `dotfiles/.config` **递归生成**，规则只剩一条：树里的每个普通文件生成一条链接。interface 缩到 `root` 一个参数。
2. 枚举用 flake source 里的树（`../../dotfiles/.config`）：求值是纯的，不能读仓库外的绝对路径（第一版直接用 `${root}/.config` 枚举，在 `dotfiles-live` 上就报 `access to absolute path … is forbidden in pure evaluation mode`）。链接目标仍用传进来的 `root`：live 是工作树，store 是 store 快照。代价是新文件要先 `git add` 才会出现在枚举里 —— README 的切换流程本来就有 `git add -A`。
3. 文件级而非目录级：`~/.config/niri` 里还有 DMS 运行期写的 `dms/*.kdl`，目录级链接会让那些文件落进仓库工作树。
4. `fish/config.fish` 仍是显式 `overrides` 列表里的 `lib.mkForce`：home-manager 自己的 fish 模块也写这个文件，dotfiles 里那份是唯一来源（ADR-0001 的例外）。冲突是约定，写出来而不是藏进条件。

## 边界

- 不加一致性检查：条目由树生成，「树里每个文件都有条目」是同义反复；真正危险的「运行时文件被提交进仓库」由 `.gitignore` 挡住（`dotfiles/.config/dms/`、`kitty/dank-*.conf`、`fuzzel/colors.ini`、`gtk-*/dank-colors.css`）。
- 本文件仍假定 dotfiles 树在 `<repo>/dotfiles` —— 两种链接模式都是如此。

## 后果

- 新增或删除 Dotfile 自动生效；`_lib/dotfiles.nix` 从 45 行降到 60 行，但其中 20 行是注释与递归本身，不再有需要同步的清单。
- 两种模式（`dotfiles-live` / `dotfiles-store`）枚举同一棵树，条目集合一致（实测两台 Host 都是同一组 35 个文件）。
