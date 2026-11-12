{ den, ... }:
{
  # acer：~/nixos/dotfiles，保存即生效（活链接回仓库工作树）
  den.aspects.dotfiles-live.homeManager = { config, ... }: {
    imports = [
      ((import ../../_lib/dotfiles.nix) "${config.home.homeDirectory}/nixos/dotfiles")
    ];
  };
}
