{
  # 语言环境：系统 locale，以及让 Qt / SDL 程序接入输入法的环境变量。
  # 输入法本身的配置在 desktop-input-method。
  den.aspects.desktop-locale = {
    nixos = {
      i18n = {
        defaultLocale = "zh_CN.UTF-8";
        supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
      };

      # 参考 niri 的 environment：让 Qt / SDL 程序也接入 fcitx5
      environment.variables = {
        QT_IM_MODULE = "fcitx";
        QT_IM_MODULES = "wayland;fcitx";
        SDL_IM_MODULE = "fcitx";
      };
    };
  };
}
