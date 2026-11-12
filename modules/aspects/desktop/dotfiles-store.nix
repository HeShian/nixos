{ den, self, ... }:
{
  # nixos-vm：flake 源里的 dotfiles（构建后只读，但保证 VM 与实机同一套配置）
  den.aspects.dotfiles-store.homeManager = {
    imports = [
      ((import ../../_lib/dotfiles.nix) "${self}/dotfiles")
    ];
  };
}
