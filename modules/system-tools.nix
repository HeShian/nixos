{
  den.aspects.system-tools = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ curl git net-tools ];

      programs.nh = {
        enable = true;
        clean = {
          enable = true;
          dates = "weekly";
          extraArgs = "--keep-since 3d --keep 3";
        };
      };
    };

    homeManager.programs = {
      neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };
      git.enable = true;
      gh.enable = true;
    };
  };
}
