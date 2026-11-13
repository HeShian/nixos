{
  den.aspects.tools = {
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
    homeManager = { pkgs, ... }: {
      programs = {
      neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };
      git.enable = true;
      gh.enable = true;
    };
      # 终端配置由 Dotfile 管理，安装程序不生成同名配置。
      home.packages = with pkgs; [
        python3 uv nodejs codex deepseek-harness
        kitty fish starship zoxide yazi bat eza xdg-terminal-exec
      ];
    };
  };
}
