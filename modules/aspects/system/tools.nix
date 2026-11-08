{
  den.aspects.system-tools = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ curl git net-tools ];
    };

    homeManager.programs = {
      neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };
      git.enable = true;
    };
  };
}
