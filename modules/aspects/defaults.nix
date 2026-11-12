{ den, ... }:
{
  # 全局默认：Den 把 den.default 注入每一种 entity kind（host / user / home），
  # 所以这里的东西对所有实体成立，不需要任何文件 include。
  den.default.nixos = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "hm-backup";
    system.stateVersion = "26.05";
  };

  # 每个 home 的 stateVersion 也只在这里写一次。
  den.default.homeManager.home.stateVersion = "26.05";

  # 约定：仓库克隆在该用户家目录的 nixos/。
  # 参数化 include 只在有 host context 的实体上生效，homes 会跳过它。
  den.default.includes = [
    ({ host, ... }: {
      nixos.programs.nh.flake = "/home/${host.defaultUser}/nixos";
    })
  ];
}
