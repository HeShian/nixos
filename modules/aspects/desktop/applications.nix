{
  den.aspects.desktop-applications = {
    nixos = { lib, ... }: {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "chatgpt"
        "vscode"
      ];
    };

    homeManager = { lib, pkgs, ... }: {
      home.packages = with pkgs; [
        chatgpt
        firefox
        onlyoffice-desktopeditors
        thunar
        vscode
      ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = lib.genAttrs [
          "text/html"
          "application/xhtml+xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ] (_: [ "com.brave.Browser.desktop" ]);
      };
    };
  };
}
