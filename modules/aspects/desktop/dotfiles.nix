{
  # 把仓库里的 dotfiles 目录活链接到 ~/.config。
  #
  # 为什么用 mkOutOfStoreSymlink：
  #   ~/.config/xxx -> /nix/store/xxx（指向 dotfiles 的软链） -> <仓库>/dotfiles/xxx
  #   因此直接编辑仓库里的文件即可生效，无需 nixos-rebuild。
  #   若换成普通 home.file 源，文件会落到只读的 /nix/store，改不动。
  #
  # acer 用仓库真实路径（可编辑）；nixos-vm 用 flake store 路径（VM 内无需克隆仓库）。
  den,
  self,
  ...
}:
let
  mkDotfiles =
    root:
    { config, ... }:
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
        "fish/config.fish" = link "fish/config.fish";
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
    };
in
{
  # acer：~/nixos/dotfiles，保存即生效
  den.aspects.dotfiles-live.homeManager = { config, ... }: {
    imports = [
      (mkDotfiles "${config.home.homeDirectory}/nixos/dotfiles")
    ];
  };

  # nixos-vm：flake 源里的 dotfiles（构建后只读，但保证 VM 与实机同一套配置）
  den.aspects.dotfiles-store.homeManager = {
    imports = [
      (mkDotfiles "${self}/dotfiles")
    ];
  };
}
