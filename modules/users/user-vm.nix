{ den, ... }:
{
  den.aspects.user-vm = {
    includes = [ den.batteries.define-user den.batteries.host-aspects ];

    user.extraGroups = [ "wheel" "networkmanager" ];

    nixos = { pkgs, ... }: {
      programs.fish.enable = true;
      users.users.user-vm.shell = pkgs.fish;
    };

    homeManager.home.stateVersion = "26.05";
  };
}
