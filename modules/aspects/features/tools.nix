{
  den.aspects.tools = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ curl git net-tools ];

      programs.nix-ld.enable = true;

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
        # pnpm 由 nixpkgs 直接提供（不走 corepack 运行时下载），与 nodejs 同代升级。
        python3 uv nodejs pnpm codex deepseek-harness
        kitty fish starship zoxide yazi bat eza xdg-terminal-exec
      ];
    };
  };
}
