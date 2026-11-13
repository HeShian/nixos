{ self, ... }:
{
  # 两种 Dotfile 链接方式，共用 _lib 中的链接实现。

  # ── dotfiles-live ──
  # acer：~/nixos/dotfiles，保存即生效（活链接回仓库工作树）
  den.aspects.dotfiles-live.homeManager = { config, ... }: {
    imports = [
      ((import ../../_lib/dotfiles.nix) "${config.home.homeDirectory}/nixos/dotfiles")
    ];
  };

  # ── dotfiles-store ──
  # nixos-vm：flake 源里的 dotfiles（构建后只读，但保证 VM 与实机同一套配置）
  den.aspects.dotfiles-store.homeManager = {
    imports = [
      ((import ../../_lib/dotfiles.nix) "${self}/dotfiles")
    ];
  };
}
