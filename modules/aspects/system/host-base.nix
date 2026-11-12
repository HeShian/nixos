{ den, ... }:
{
  # 所有 host 共享的系统级设置。
  # 判定标准：换一台机器也照样成立的东西放这里；机器独有的（硬件、dotfiles 链接方式、
  # 有没有仓库克隆）留在各自的 host aspect。
  den.aspects.host-base = { host, ... }: {
    nixos = { ... }: {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-backup";
      system.stateVersion = "26.05";

      # 约定：仓库克隆在该用户家目录的 nixos/（acer 上就是 /home/claudia/nixos）。
      # 这样新增 host 时不需要记任何额外步骤；没有克隆的 host 用 lib.mkForce null 覆盖，
      # 让 nh 退回「未指定 flake」的明确报错，而不是指向一个不存在的路径。
      programs.nh.flake = "/home/${host.defaultUser}/nixos";
    };
  };
}
