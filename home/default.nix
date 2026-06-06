{
  pkgs,
  lib,
  user,
  config,
  ...
}:
{
  imports = [
    ./lib
    ./programs
    ./tweaks
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";


    packages = with pkgs; [
      # files
      zip
      xz
      unzip

      # utils
      ripgrep
      zoxide
      fzf
      eza
      fd
      brightnessctl
    ];

    sessionVariables = {
      all_proxy = "http://127.0.0.1:7890";
      ALL_PROXY = "http://127.0.0.1:7890";
      HTTP_PROXY = "http://127.0.0.1:7890";
      HTTPS_PROXY = "http://127.0.0.1:7890";
      http_PROXY = "http://127.0.0.1:7890";
      https_PROXY = "http://127.0.0.1:7890";
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
    };

    activation = {
      git-credentials =
        lib.hm.dag.entryAfter [ "writeBoundary" ]
          # bash
          ''
            echo "https://heshian:$(cat ${config.age.secrets.nix_github_token.path})@github.com" > $HOME/.git-credentials
            chmod 600 $HOME/.git-credentials
          '';
      reload-shell =
        lib.hm.dag.entryAfter [ "writeBoundary" ]
          # bash
          ''
            for svc in waybar dms caelestia noctalia-shell; do
              if ${pkgs.systemd}/bin/systemctl --user is-active "$svc.service"; then
                run --silence ${pkgs.systemd}/bin/systemctl --user stop "$svc.service"
              fi
            done
            run --silence ${pkgs.systemd}/bin/systemctl --user start ${config.desktopShell}.service
          '';
    };
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-gtk
        libsForQt5.fcitx5-qt
        qt6Packages.fcitx5-chinese-addons
        fcitx5-rime
        fcitx5-pinyin-moegirl
        fcitx5-pinyin-zhwiki
      ];
      waylandFrontend = true;
    };
  };

  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "heshian";
          email = "3453289292@qq.com";
        };
        safe = {
          directory = "*";
        };
        http.proxy = "http://127.0.0.1:7890";
        credential.helper = "store";
      };
    };

    nix-index = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
    };

    home-manager.enable = true;
  };

  xdg.userDirs = {
    enable = true;
    desktop = "$HOME/Desktop";
    download = "$HOME/Downloads";
    templates = "$HOME/Templates";
    publicShare = "$HOME/Public";
    documents = "$HOME/Documents";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    videos = "$HOME/Videos";
    extraConfig = {
      XDG_PROJECTS_DIR = "$HOME/Projects";
    };
  };
}
