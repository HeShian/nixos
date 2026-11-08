{
  den.aspects.desktop-localization.nixos = { pkgs, ... }: {
    i18n = {
      defaultLocale = "zh_CN.UTF-8";
      supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
      inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          waylandFrontend = true;
          addons = [
            (pkgs.fcitx5-rime.override { rimeDataPkgs = [ pkgs.rime-data pkgs.rime-ice ]; })
          ];
        };
      };
    };
  };
}
