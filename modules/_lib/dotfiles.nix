# 把仓库里的 dotfiles 目录活链接到 ~/.config。
#
# 条目由目录树生成：dotfiles/.config 下的每个普通文件生成一条 xdg.configFile，
# 新增文件自动生效，不需要改这里（ADR-0009）。
#
# 为什么用 mkOutOfStoreSymlink：
#   ~/.config/xxx -> /nix/store/xxx（指向 dotfiles 的软链） -> <仓库>/dotfiles/xxx
#   因此直接编辑仓库里的文件即可生效，无需 nixos-rebuild。
#   若换成普通 home.file 源，文件会落到只读的 /nix/store，改不动。
#
# 为什么是文件级而不是目录级：~/.config/niri 里还有 DMS 运行期写的 dms/*.kdl，
# 目录级链接会让那些文件落进仓库工作树。文件级链接保持 ~/.config/niri 为普通目录。
#
# 枚举用的是 flake source 里的树（求值是纯的，不能读仓库外的绝对路径）；链接目标
# 才用传进来的 root。两者文件集合相同，唯一的差别是：新增的 dotfile 先 `git add`
# 才会出现在枚举里（README 的切换流程本来就有 `git add -A`）。
#
# 本文件在 modules/_lib/ 下，import-tree 会忽略带 "/_" 的路径，
# 所以它不会被当成 aspect 自动加载，只供 dotfiles-live / dotfiles-store 相对导入。
root:
{ config, lib, ... }:
let
  tree = ../../dotfiles/.config;

  # 递归列出普通文件，返回相对 .config 的路径。
  walk =
    prefix: dir:
    lib.concatLists (
      lib.mapAttrsToList (
        name: type:
        let
          rel = if prefix == "" then name else "${prefix}/${name}";
        in
        if type == "directory" then
          walk rel (dir + "/${name}")
        else if type == "regular" then
          [ rel ]
        else
          [ ]
      ) (builtins.readDir dir)
    );

  files = walk "" tree;

  # 需要强制覆盖的路径：home-manager 自己的 fish 模块也会写 config.fish，
  # dotfiles 里那份是唯一来源，所以这里用 mkForce（ADR-0001 的例外）。
  # 冲突是约定而非偶然，写出来而不是藏在条件里。
  overrides = [ "fish/config.fish" ];

  link = rel: {
    source = config.lib.file.mkOutOfStoreSymlink "${root}/.config/${rel}";
  };
in
{
  xdg.configFile =
    builtins.listToAttrs (
      map (rel: {
        name = rel;
        value = link rel;
      }) (builtins.filter (rel: !(builtins.elem rel overrides)) files)
    )
    // {
      "fish/config.fish" = lib.mkForce (link "fish/config.fish");
    };
}
