{ den, ... }:
{
  den.aspects.user-vm = {
    includes = [ den.batteries.define-user den.batteries.host-aspects ];

    user = {
      description = "user-vm";
      extraGroups = [ "wheel" "networkmanager" ];
    };

    nixos = { pkgs, ... }: {
      programs.fish.enable = true;
      users.users.user-vm.shell = pkgs.fish;
    };

    homeManager = {
      home.stateVersion = "26.05";
      # 与 claudia 同一身份：VM 里提交到同一仓库时署名一致，且不暴露真实邮箱。
      programs.git.settings.user = {
        name = "claudia";
        email = "96305135+HeShian@users.noreply.github.com";
      };
    };
  };
}
