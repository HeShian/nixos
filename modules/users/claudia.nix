{ den, ... }:
{
  den.aspects.claudia = {
    includes = [ den.batteries.define-user den.batteries.host-aspects ];

    user = {
      description = "claudia";
      extraGroups = [ "wheel" "networkmanager" ];
    };

    # fish 由 dotfiles 里的 config.fish 配置；这里只把它设为登录 shell。
    nixos = { pkgs, ... }: {
      programs.fish.enable = true;
      users.users.claudia.shell = pkgs.fish;
    };

    homeManager = { pkgs, ... }: {
      home.stateVersion = "26.05";
      home.packages = [ (pkgs.callPackage ../../packages/dsh-desktop.nix { }) ];
      programs.git.settings.user = {
        name = "claudia";
        email = "96305135+HeShian@users.noreply.github.com";
      };
    };
  };
}
