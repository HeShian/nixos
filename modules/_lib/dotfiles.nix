# 把仓库里的 dotfiles 目录活链接到 ~/.config。
#
# 为什么用 mkOutOfStoreSymlink：
#   ~/.config/xxx -> /nix/store/xxx（指向 dotfiles 的软链） -> <仓库>/dotfiles/xxx
#   因此直接编辑仓库里的文件即可生效，无需 nixos-rebuild。
#   若换成普通 home.file 源，文件会落到只读的 /nix/store，改不动。
#
# 本文件在 modules/_lib/ 下，import-tree 会忽略带 "/_" 的路径，
# 所以它不会被当成 aspect 自动加载，只供 dotfiles-live / dotfiles-store 相对导入。
root:
{ config, lib, ... }:
let
  dotfiles = "${root}/.config";
  link = path: {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
  };
in
{
  xdg.configFile = {
    # niri：主配置与分片；scripts 目录整体链接，保留可执行位
    "niri/config.kdl" = link "niri/config.kdl";
    "niri/layout.kdl" = link "niri/layout.kdl";
    "niri/animations.kdl" = link "niri/animations.kdl";
    "niri/blur.kdl" = link "niri/blur.kdl";
    "niri/binds.kdl" = link "niri/binds.kdl";
    "niri/windowrules.kdl" = link "niri/windowrules.kdl";
    "niri/supertab.kdl" = link "niri/supertab.kdl";
    "niri/outputs.kdl" = link "niri/outputs.kdl";
    "niri/scripts" = link "niri/scripts";

    # 终端 / 常用应用
    "kitty/kitty.conf" = link "kitty/kitty.conf";
    "fish/config.fish" = lib.mkForce (link "fish/config.fish");
    "fish/functions/f.fish" = link "fish/functions/f.fish";
    "fish/functions/fwatch.fish" = link "fish/functions/fwatch.fish";
    "fuzzel/fuzzel.ini" = link "fuzzel/fuzzel.ini";
    "cava/config" = link "cava/config";
    "mpv/config" = link "mpv/config";
    "satty/config.toml" = link "satty/config.toml";
    "fontconfig/fonts.conf" = link "fontconfig/fonts.conf";

    # matugen 用户模板（DMS 每次换壁纸都会读取并执行）
    "matugen" = link "matugen";
  };
}
